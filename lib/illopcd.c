// User-level illegal opcode handler support.
// Rather than register the C illegal opcode handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in illopentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language illop entrypoint defined in lib/illopcdentry.S.
extern void _illopcd_upcall(void);

// Pointer to currently installed C-language illopcd handler.
void (*_illopcd_handler)(struct UTrapframe *utf);

//
// Set the illegal opcode handler function.
// If there isn't one yet, _illopcd_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _illopcd_upcall routine when a illegal opcode occurs.
//
void
set_illopcd_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_illopcd_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_illopcd_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _illopcd_handler = handler;
    if ((r = sys_env_set_illopcd_upcall(0, _illopcd_upcall)) < 0 )
        panic("set_illopcd_handler: sys_env_set_illopcd_upcall: %e", r);
}

