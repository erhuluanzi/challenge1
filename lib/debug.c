// User-level debug exception handler support.
// Rather than register the C debug exception handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in dbgentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language dbg entrypoint defined in lib/debugentry.S.
extern void _debug_upcall(void);

// Pointer to currently installed C-language debug handler.
void (*_debug_handler)(struct UTrapframe *utf);

//
// Set the debug exception handler function.
// If there isn't one yet, _debug_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _debug_upcall routine when a debug exception occurs.
//
void
set_debug_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_debug_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_debug_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _debug_handler = handler;
    if ((r = sys_env_set_debug_upcall(0, _debug_upcall)) < 0 )
        panic("set_debug_handler: sys_env_set_debug_upcall: %e", r);
}

