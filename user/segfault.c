
#include <inc/lib.h>

void handler(struct UTrapframe *utf){
    cprintf("this is stack exception handler!\n");
    exit();
}

void
umain(int argc, char **argv) {
    set_stkexception_handler(handler);
    asm volatile("pushl %eax");
}
