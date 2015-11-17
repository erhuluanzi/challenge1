// cause BOUND exception!
#include <inc/lib.h>
void handler(struct UTrapframe *utf) {
	cprintf("this is bound check exception handler!\n");
	exit();
}

short arrayBounds[2] = {12, 1};
void umain(int argc, char **argv) {
	set_bdschk_handler(handler);
	asm volatile("movl $0, %eax");
	asm volatile("bound %eax, arrayBounds");
	return;
}
