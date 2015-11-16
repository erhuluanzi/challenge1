// cause an overflow use "INTO"
#include <inc/lib.h>
void handler(struct UTrapframe *utf) {
	cprintf("this is overflow exception handler!\n");
	return;
}

void umain(int argc, char **argv) {
	set_oflow_handler(handler);
	//int a = 0x80000000;
	//a = a - 10;
	asm volatile("movl $0x80000000, %ebx");
	asm volatile("subl $10, %ebx");
	asm volatile("into");
	cprintf("success!\n");
	return;
}