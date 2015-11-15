// User-level double fault handler support.
// Rather than register the C double fault handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in dfentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language df entrypoint defined in lib/dbfaultentry.S.
extern void _dbfault_upcall(void);

// Pointer to currently installed C-language dbfault handler.
void (*_dbfault_handler)(struct UTrapframe *utf);

//
// Set the double fault handler function.
// If there isn't one yet, _dbfault_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _dbfault_upcall routine when a double fault occurs.
//
void
set_dbfault_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_dbfault_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_dbfault_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _dbfault_handler = handler;
    if ((r = sys_env_set_dbfault_upcall(0, _dbfault_upcall)) < 0 )
        panic("set_dbfault_handler: sys_env_set_dbfault_upcall: %e", r);
}

