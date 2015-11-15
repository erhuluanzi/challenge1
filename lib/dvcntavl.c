// User-level device not available handler support.
// Rather than register the C device not available handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in dnaentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language dna entrypoint defined in lib/dvcntavlentry.S.
extern void _dvcntavl_upcall(void);

// Pointer to currently installed C-language dvcntavl handler.
void (*_dvcntavl_handler)(struct UTrapframe *utf);

//
// Set the device not available handler function.
// If there isn't one yet, _dvcntavl_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _dvcntavl_upcall routine when a device not available occurs.
//
void
set_dvcntavl_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_dvcntavl_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_dvcntavl_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _dvcntavl_handler = handler;
    if ((r = sys_env_set_dvcntavl_upcall(0, _dvcntavl_upcall)) < 0 )
        panic("set_dvcntavl_handler: sys_env_set_dvcntavl_upcall: %e", r);
}

