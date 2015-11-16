// cause a nmi interrupt by 'int 2'
#include <inc/lib.h>
void handler(struct UTrapframe *utf) {
	cprintf("this is non-maskable interrupt handler!\n");
	return;
}

void umain(int argc, char **argv) {
	set_nmskint_handler(handler);
	asm volatile("int $2");
	cprintf("success!\n");
	return;
}