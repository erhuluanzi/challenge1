// User-level algchk handler support.
// Rather than register the C algchk handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in acentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language ac entrypoint defined in lib/algchkentry.S.
extern void _algchk_upcall(void);

// Pointer to currently installed C-language algchk handler.
void (*_algchk_handler)(struct UTrapframe *utf);

//
// Set the algchk handler function.
// If there isn't one yet, _algchk_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _algchk_upcall routine when a algchk occurs.
//
void
set_algchk_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_algchk_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_algchk_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _algchk_handler = handler;
    if ((r = sys_env_set_algchk_upcall(0, _algchk_upcall)) < 0 )
        panic("set_algchk_handler: sys_env_set_algchk_upcall: %e", r);
}

// User-level algchk handler support.
// Rather than register the C algchk handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in acentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language ac entrypoint defined in lib/algchkentry.S.
extern void _algchk_upcall(void);

// Pointer to currently installed C-language algchk handler.
void (*_algchk_handler)(struct UTrapframe *utf);

//
// Set the algchk handler function.
// If there isn't one yet, _algchk_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _algchk_upcall routine when a algchk occurs.
//
void
set_algchk_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_algchk_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_algchk_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _algchk_handler = handler;
    if ((r = sys_env_set_algchk_upcall(0, _algchk_upcall)) < 0 )
        panic("set_algchk_handler: sys_env_set_algchk_upcall: %e", r);
}

