// User-level SIMDfperror handler support.
// Rather than register the C SIMDfperror handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in sfpeentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language sfpe entrypoint defined in lib/SIMDfperrorentry.S.
extern void _SIMDfperror_upcall(void);

// Pointer to currently installed C-language SIMDfperror handler.
void (*_SIMDfperror_handler)(struct UTrapframe *utf);

//
// Set the SIMDfperror handler function.
// If there isn't one yet, _SIMDfperror_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _SIMDfperror_upcall routine when a SIMDfperror occurs.
//
void
set_SIMDfperror_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_SIMDfperror_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_SIMDfperror_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _SIMDfperror_handler = handler;
    if ((r = sys_env_set_SIMDfperror_upcall(0, _SIMDfperror_upcall)) < 0 )
        panic("set_SIMDfperror_handler: sys_env_set_SIMDfperror_upcall: %e", r);
}

