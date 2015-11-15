// User-level machine check handler support.
// Rather than register the C machine check handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in mcentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language mc entrypoint defined in lib/mchchkentry.S.
extern void _mchchk_upcall(void);

// Pointer to currently installed C-language mchchk handler.
void (*_mchchk_handler)(struct UTrapframe *utf);

//
// Set the machine check handler function.
// If there isn't one yet, _mchchk_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _mchchk_upcall routine when a machine check occurs.
//
void
set_mchchk_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_mchchk_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_mchchk_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _mchchk_handler = handler;
    if ((r = sys_env_set_mchchk_upcall(0, _mchchk_upcall)) < 0 )
        panic("set_mchchk_handler: sys_env_set_mchchk_upcall: %e", r);
}

