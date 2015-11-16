// program to cause a breakpoint trap

#include <inc/lib.h>
void handler(struct UTrapframe *utf) {
	cprintf("this is breakpoint handler!\n");
	return;
}

void umain(int argc, char **argv) {
	set_bpoint_handler(handler);
	asm volatile("int $3");
	cprintf("success!\n");
	return;
}

