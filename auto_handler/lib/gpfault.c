// User-level gpfault handler support.
// Rather than register the C gpfault handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in gpfentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language gpf entrypoint defined in lib/gpfaultentry.S.
extern void _gpfault_upcall(void);

// Pointer to currently installed C-language gpfault handler.
void (*_gpfault_handler)(struct UTrapframe *utf);

//
// Set the gpfault handler function.
// If there isn't one yet, _gpfault_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _gpfault_upcall routine when a gpfault occurs.
//
void
set_gpfault_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_gpfault_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_gpfault_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _gpfault_handler = handler;
    if ((r = sys_env_set_gpfault_upcall(0, _gpfault_upcall)) < 0 )
        panic("set_gpfault_handler: sys_env_set_gpfault_upcall: %e", r);
}

// User-level gpfault handler support.
// Rather than register the C gpfault handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in gpfentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language gpf entrypoint defined in lib/gpfaultentry.S.
extern void _gpfault_upcall(void);

// Pointer to currently installed C-language gpfault handler.
void (*_gpfault_handler)(struct UTrapframe *utf);

//
// Set the gpfault handler function.
// If there isn't one yet, _gpfault_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _gpfault_upcall routine when a gpfault occurs.
//
void
set_gpfault_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_gpfault_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_gpfault_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _gpfault_handler = handler;
    if ((r = sys_env_set_gpfault_upcall(0, _gpfault_upcall)) < 0 )
        panic("set_gpfault_handler: sys_env_set_gpfault_upcall: %e", r);
}

