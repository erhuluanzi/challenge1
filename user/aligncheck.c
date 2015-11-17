
#include <inc/lib.h>

void handler(struct UTrapframe *utf){
    cprintf("this is alignment check handler!\n");
    exit();
}

void
umain(int argc, char **argv) {
    set_algchk_handler(handler);
    //asm volatile("pushfd");
    asm volatile("popl %eax");
    asm volatile("orl 0x00020000, %eax");
    asm volatile("pushl %eax");
    //asm volatile("popfd");
}
