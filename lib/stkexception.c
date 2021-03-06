// User-level stack exception handler support.
// Rather than register the C stack exception handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in seentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language se entrypoint defined in lib/stkexceptionentry.S.
extern void _stkexception_upcall(void);

// Pointer to currently installed C-language stkexception handler.
void (*_stkexception_handler)(struct UTrapframe *utf);

//
// Set the stack exception handler function.
// If there isn't one yet, _stkexception_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _stkexception_upcall routine when a stack exception occurs.
//
void
set_stkexception_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_stkexception_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_stkexception_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _stkexception_handler = handler;
    if ((r = sys_env_set_stkexception_upcall(0, _stkexception_upcall)) < 0 )
        panic("set_stkexception_handler: sys_env_set_stkexception_upcall: %e", r);
}

