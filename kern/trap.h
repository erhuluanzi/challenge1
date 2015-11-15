/* See COPYRIGHT for copyright information. */

#ifndef JOS_KERN_TRAP_H
#define JOS_KERN_TRAP_H
#ifndef JOS_KERNEL
# error "This is a JOS kernel header; user programs should not #include it"
#endif

#include <inc/trap.h>
#include <inc/mmu.h>

/* The kernel's interrupt descriptor table */
extern struct Gatedesc idt[];
extern struct Pseudodesc idt_pd;

void trap_init(void);
void trap_init_percpu(void);
void print_regs(struct PushRegs *regs);
void print_trapframe(struct Trapframe *tf);
void page_fault_handler(struct Trapframe *tf);
void backtrace(struct Trapframe *);
void divide_zero_handler(struct Trapframe *tf);
void debug_exception_handler(struct Trapframe *tf);
void non_maskable_interrupt_handler(struct Trapframe *tf);
void breakpoint_handler(struct Trapframe *tf);
void overflow_handler(struct Trapframe *tf);
void bounds_check_handler(struct Trapframe *tf);
void illegal_opcode_handler(struct Trapframe *tf);
void device_not_available_handler(struct Trapframe *tf);
void double_fault_handler(struct Trapframe *tf);
void invalid_task_switch_segment_handler(struct Trapframe *tf);
void segment_not_present_handler(struct Trapframe *tf);
void stack_exception_handler(struct Trapframe *tf);
void general_protection_fault_handler(struct Trapframe *tf);
void floating_point_error_handler(struct Trapframe *tf);
void aligment_check_handler(struct Trapframe *tf);
void machine_check_handler(struct Trapframe *tf);
void SIMD_floating_point_error_handler(struct Trapframe *tf);

#endif /* JOS_KERN_TRAP_H */
