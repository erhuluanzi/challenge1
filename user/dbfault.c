// generate a double fault (but failed)

// int zero, a;
// void handler1(struct UTrapframe *utf){
// 	cprintf("this is divide zero handler!\n");
// 	exit();
// }
// void handler2(struct UTrapframe *utf) {
// 	cprintf("this is page fault handler!\n");
// 	a = 1 / zero;
// 	return;
// }

// void
// umain(int argc, char **argv)
// {
// 	set_divzero_handler(handler1);
// 	set_pgfault_handler(handler2);
// 	zero = 0;
// 	cprintf("%s", 0xDeadBeef);
// 	cprintf("%d\n", a);
// 	return;
// }

void handler(struct UTrapframe *utf){
 	cprintf("this is double fault handler!\n");
}

void umain(int argc, char **argv) {
	set_dbfault_handler(handler);
	asm volatile("int $0x8");
	cprintf("success!\n");
	return;
}