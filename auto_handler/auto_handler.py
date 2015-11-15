# coding: utf-8
descriptor = [
    ('debug exception', 'debug', 'dbg', 'T_DEBUG'),
    ('non_maskable interrupt', 'nmskint', 'nmi', 'T_NMI'),
    ('breakpoint', 'bpoint', 'bpt', 'T_BRKPT'),
    ('overflow', 'oflow', 'oflw', 'T_OFLOW'),
    ('bounds check', 'bdschk', 'bc', 'T_BOUND'),
    ('illegal opcode', 'illopcd', 'illop', 'T_ILLOP'),
    ('device not available', 'dvcntavl', 'dna', 'T_DEVICE'),
    ('double fault', 'dbfault', 'df', 'T_DBLFLT'),
    ('invalid task switch segment', 'ivldtss', 'tss', 'T_TSS'),
    ('segment not present', 'segntprst', 'snp', 'T_SEGNP'),
    ('stack exception', 'stkexception', 'se', 'T_STACK'),
    ('general protection fault', 'gpfault', 'gpf', 'T_GPFLT'),
    # ('page fault', 'pgfault', 'pf', 'T_PGFLT'),
    ('floating point error', 'fperror', 'fpe', 'T_FPERR'),
    ('aligment check', 'algchk', 'ac', 'T_ALIGN'),
    ('machine check', 'mchchk', 'mc', 'T_MCHK'),
    ('SIMD floating point error', 'SIMDfperror', 'sfpe', 'T_SIMDERR'),
]

ref1 = \
'''\
// User-level %s handler support.
// Rather than register the C %s handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in %sentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language %s entrypoint defined in lib/%sentry.S.
extern void _%s_upcall(void);

// Pointer to currently installed C-language %s handler.
void (*_%s_handler)(struct UTrapframe *utf);

//
// Set the %s handler function.
// If there isn't one yet, _%s_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _%s_upcall routine when a %s occurs.
//
void
set_%s_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_%s_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_%s_handler: sys_page_alloc: %%e", r);
    }

    // Save handler pointer for assembly to call.
    _%s_handler = handler;
    if ((r = sys_env_set_%s_upcall(0, _%s_upcall)) < 0 )
        panic("set_%s_handler: sys_env_set_%s_upcall: %%e", r);
}
\
'''

ref2 = \
'''\
// set the %s exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_%s_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_%s_upcall = func;
    return 0;
}
\
'''

ref3 = \
'''\
    case SYS_env_set_%s_upcall:
        return sys_env_set_%s_upcall(a1, (void *)a2);\
'''

ref4 = \
'''\
    case %s:
        %s_handler(tf);
        return;\
'''

ref5 = \
'''\
void %s_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode %s exception
    if ((tf->tf_cs & 3) == 0)
        panic("%s exception in kernel mode!");
    if (curenv->env_%s_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_%s_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%%08x] user fault va %%08x ip %%08x\\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}
\
'''

ref6 = \
'''\
// %s upcall entrypoint.
#include <inc/mmu.h>
#include <inc/memlayout.h>

.text
.globl _%s_upcall
_%s_upcall:
    // call the C %s handler
    pushl %%esp
    movl _%s_handler, %%eax
    call *%%eax
    addl $4, %%esp
    movl 0x30(%%esp), %%eax
    subl $0x4, %%eax
    movl %%eax, 0x30(%%esp)
    // put old eip into the pre-reserved 4-byte space
    movl 0x28(%%esp), %%ebx
    movl %%ebx, (%%eax)

    // Restore the trap-time registers.
    popal

    // Restore eflags from the stack.
    addl $0x4, %%esp
    popfl

    // Switch back to the adjusted trap-time stack.
    popl %%esp

    // Return to re-execute the instruction that faulted.
    ret
\
'''

ref7 = \
'''\
int
sys_env_set_%s_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_%s_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
\
'''

patterns = [
    # inc/env.h 在Env结构体中增加一个入口函数指针 void *env_divzero_upcall;
    ('inc/env.h', "()", 'void *env_%s_upcall;' , "(item[1])"),
    # lib/divzero.c 这是新加的一个库文件，目的是要提供对用户的接口，里面需要有 set_divzero_handler函数
    ('lib/%s.c' , "(item[1])", ref1, "(item[0], item[0], item[2], item[2], item[1], item[1], \
        item[1], item[1], item[0], item[1], item[1], item[0], item[1], item[1], item[1], item[1], \
        item[1], item[1], item[1], item[1])"),
    # inc/lib.h 对set_divzero_handler函数的声明
    ('inc/lib.h', "()", '//%s.c\nvoid\tset_%s_handler(void (*handler)(struct UTrapframe *utf));\n',\
        "(item[1], item[1])"),
    # inc/lib.h 增加系统调用int sys_env_set_divzero_upcall(envid_t env, void *upcall)用于处理设置divzero的处理函数。
    ('inc/lib.h', "()", 'int sys_env_set_%s_upcall(envid_t env, void *upcall);', "(item[1])"),
    # inc/syscall.h 增加系统调用编号SYS_env_set_divzero_upcall
    ('inc/syscall.h', "()", 'SYS_env_set_%s_upcall,', "(item[1])"),
    # kern/env.c 在env_alloc()函数中初始化时清空divzero handler直到用户设置一个 e->env_divzero_upcall = 0;
    ('kern/env.c', "()", 'e->env_%s_upcall = 0;', "(item[1])"),
    # kern/syscall.c 写好sys_env_set_divzero_upcall的函数定义，类似pgfault写
    ('kern/syscall.c', "()", ref2, "(item[0], item[1], item[1])"),
    # kern/syscall.c 记得在syscall()函数中增加一个case进行分派
    ('kern/syscall.c', "()", ref3, "(item[1], item[1])"),
    # kern/trap.h 写divide_zero_handler()的函数声明
    ('kern/trap.h', "()", 'void %s_handler(struct Trapframe *tf);', "(item[0].replace(' ', '_'))"),
    # kern/trap.c 修改trap_dispatch()函数，增加一个divzero的case
    ('kern/trap.c', "()", ref4, "(item[3], item[0].replace(' ', '_'))"),
    # 写一个divzero_handler()函数，分派时处理divzero exception
    ('kern/trap.c', "()", ref5, "(item[0].replace(' ', '_'), item[0], item[0], item[1], item[1])"),
    # lib/divzentry.S 这是个庞大的工程，要仿照lib/pfentry.S写一个，起到统一提供接口的目的
    ('lib/%sentry.S', "(item[2])", ref6, "(item[0], item[1], item[1], item[1], item[1])"),
    # lib/Makefrag 在LIB_SRCFILES条目中增加 lib/divzero.c 和 lib/divzentry.S 这样才能够在编译时加进去我们的新文件
    ('lib/Makefrag', "()", '\t\t\tlib/%s.c \\\n\t\t\tlib/%sentry.S \\', "(item[1], item[2])"),
    # lib/syscall.c 增加一个库包装系统调用int sys_env_set_divzero_upcall(envid_t envid, void *upcall)
    ('lib/syscall.c', "()", ref7, "(item[1], item[1])"),
]

import os
try:
    os.mkdir('./lib')
    os.mkdir('./kern')
    os.mkdir('./inc')
except:
    print "File exists! Please clean the work bench."

for p in patterns:
    for item in descriptor:
        outfile = open((p[0] % eval(p[1])), 'a')
        print >>outfile, p[2] % eval(p[3])
