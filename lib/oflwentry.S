// oflow upcall entrypoint.
#include <inc/mmu.h>
#include <inc/memlayout.h>

.text
.globl _oflow_upcall
_oflow_upcall:
    // call the C oflow handler
    pushl %esp
    movl _oflow_handler, %eax
    call *%eax
    addl $4, %esp
    movl 0x30(%esp), %eax
    subl $0x4, %eax
    movl %eax, 0x30(%esp)
    // put old eip into the pre-reserved 4-byte space
    movl 0x28(%esp), %ebx
    movl %ebx, (%eax)

    // Restore the trap-time registers.
    popal

    // Restore eflags from the stack.
    addl $0x4, %esp
    popfl

    // Switch back to the adjusted trap-time stack.
    popl %esp

    // Return to re-execute the instruction that faulted.
    ret

