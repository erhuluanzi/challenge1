// User-level nmskint handler support.
// Rather than register the C nmskint handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in nmientry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language nmi entrypoint defined in lib/nmskintentry.S.
extern void _nmskint_upcall(void);

// Pointer to currently installed C-language nmskint handler.
void (*_nmskint_handler)(struct UTrapframe *utf);

//
// Set the nmskint handler function.
// If there isn't one yet, _nmskint_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _nmskint_upcall routine when a nmskint occurs.
//
void
set_nmskint_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_nmskint_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_nmskint_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _nmskint_handler = handler;
    if ((r = sys_env_set_nmskint_upcall(0, _nmskint_upcall)) < 0 )
        panic("set_nmskint_handler: sys_env_set_nmskint_upcall: %e", r);
}

// User-level nmskint handler support.
// Rather than register the C nmskint handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in nmientry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language nmi entrypoint defined in lib/nmskintentry.S.
extern void _nmskint_upcall(void);

// Pointer to currently installed C-language nmskint handler.
void (*_nmskint_handler)(struct UTrapframe *utf);

//
// Set the nmskint handler function.
// If there isn't one yet, _nmskint_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _nmskint_upcall routine when a nmskint occurs.
//
void
set_nmskint_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_nmskint_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_nmskint_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _nmskint_handler = handler;
    if ((r = sys_env_set_nmskint_upcall(0, _nmskint_upcall)) < 0 )
        panic("set_nmskint_handler: sys_env_set_nmskint_upcall: %e", r);
}

