// buggy program - causes an illegal software interrupt

#include <inc/lib.h>

void handler(struct UTrapframe *utf){
    cprintf("this is general protection fault handler!\n");
    exit();
}

void
umain(int argc, char **argv)
{
    set_gpfault_handler(handler);
	asm volatile("int $14");	// page fault
}

