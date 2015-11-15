// User-level ivldtss handler support.
// Rather than register the C ivldtss handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in tssentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language tss entrypoint defined in lib/ivldtssentry.S.
extern void _ivldtss_upcall(void);

// Pointer to currently installed C-language ivldtss handler.
void (*_ivldtss_handler)(struct UTrapframe *utf);

//
// Set the ivldtss handler function.
// If there isn't one yet, _ivldtss_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _ivldtss_upcall routine when a ivldtss occurs.
//
void
set_ivldtss_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_ivldtss_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_ivldtss_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _ivldtss_handler = handler;
    if ((r = sys_env_set_ivldtss_upcall(0, _ivldtss_upcall)) < 0 )
        panic("set_ivldtss_handler: sys_env_set_ivldtss_upcall: %e", r);
}

// User-level ivldtss handler support.
// Rather than register the C ivldtss handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in tssentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language tss entrypoint defined in lib/ivldtssentry.S.
extern void _ivldtss_upcall(void);

// Pointer to currently installed C-language ivldtss handler.
void (*_ivldtss_handler)(struct UTrapframe *utf);

//
// Set the ivldtss handler function.
// If there isn't one yet, _ivldtss_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _ivldtss_upcall routine when a ivldtss occurs.
//
void
set_ivldtss_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_ivldtss_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_ivldtss_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _ivldtss_handler = handler;
    if ((r = sys_env_set_ivldtss_upcall(0, _ivldtss_upcall)) < 0 )
        panic("set_ivldtss_handler: sys_env_set_ivldtss_upcall: %e", r);
}

