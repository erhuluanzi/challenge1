// buggy program - causes a divide by zero exception

#include <inc/lib.h>

int zero;
void handler(struct UTrapframe *utf){
	cprintf("this is divide zero handler!\n");
	exit();
}

void
umain(int argc, char **argv)
{
	set_divzero_handler(handler);
	zero = 0;
	int a = 1 / zero;
	cprintf("%d\n", a);
}