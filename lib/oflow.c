// User-level oflow handler support.
// Rather than register the C oflow handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in oflwentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language oflw entrypoint defined in lib/oflowentry.S.
extern void _oflow_upcall(void);

// Pointer to currently installed C-language oflow handler.
void (*_oflow_handler)(struct UTrapframe *utf);

//
// Set the oflow handler function.
// If there isn't one yet, _oflow_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _oflow_upcall routine when a oflow occurs.
//
void
set_oflow_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_oflow_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_oflow_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _oflow_handler = handler;
    if ((r = sys_env_set_oflow_upcall(0, _oflow_upcall)) < 0 )
        panic("set_oflow_handler: sys_env_set_oflow_upcall: %e", r);
}

