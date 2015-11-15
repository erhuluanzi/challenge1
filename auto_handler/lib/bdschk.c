// User-level bdschk handler support.
// Rather than register the C bdschk handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in bcentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language bc entrypoint defined in lib/bdschkentry.S.
extern void _bdschk_upcall(void);

// Pointer to currently installed C-language bdschk handler.
void (*_bdschk_handler)(struct UTrapframe *utf);

//
// Set the bdschk handler function.
// If there isn't one yet, _bdschk_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _bdschk_upcall routine when a bdschk occurs.
//
void
set_bdschk_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_bdschk_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_bdschk_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _bdschk_handler = handler;
    if ((r = sys_env_set_bdschk_upcall(0, _bdschk_upcall)) < 0 )
        panic("set_bdschk_handler: sys_env_set_bdschk_upcall: %e", r);
}

// User-level bdschk handler support.
// Rather than register the C bdschk handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in bcentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language bc entrypoint defined in lib/bdschkentry.S.
extern void _bdschk_upcall(void);

// Pointer to currently installed C-language bdschk handler.
void (*_bdschk_handler)(struct UTrapframe *utf);

//
// Set the bdschk handler function.
// If there isn't one yet, _bdschk_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _bdschk_upcall routine when a bdschk occurs.
//
void
set_bdschk_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_bdschk_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_bdschk_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _bdschk_handler = handler;
    if ((r = sys_env_set_bdschk_upcall(0, _bdschk_upcall)) < 0 )
        panic("set_bdschk_handler: sys_env_set_bdschk_upcall: %e", r);
}

