
#include <inc/lib.h>

void handler(struct UTrapframe *utf){
    cprintf("this is floating point error handler!\n");
    exit();
}

void
umain(int argc, char **argv) {
    //_controlfp(_EM_INVALID,_MCW_EM);
    set_fperror_handler(handler);
    short buff;
    float res;
    // The codes below work well on OSX, but can not be compiled in under this tool chain.
    asm volatile("FINIT; FSTCW %0; ANDW $0xfff0, %0; FLDCW %0; FSTCW %0; FLDZ; FLDZ; FDIVP; FSTP %1": "=memory"(buff), "=memory"(res));
    asm volatile("int $16");
}
