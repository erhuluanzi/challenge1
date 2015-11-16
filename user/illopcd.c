// generaet illegal opcode exception!
#include <inc/lib.h>
void handler(struct UTrapframe *utf) {
	cprintf("this is illegal opcode exception handler!\n");
	exit();
}

void umain(int argc, char **argv) {
	set_illopcd_handler(handler);
	asm volatile("addpd %xmm2, %xmm1");
	cprintf("success!\n");
	return;
}
