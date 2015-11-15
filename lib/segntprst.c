// User-level segntprst handler support.
// Rather than register the C segntprst handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in snpentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language snp entrypoint defined in lib/segntprstentry.S.
extern void _segntprst_upcall(void);

// Pointer to currently installed C-language segntprst handler.
void (*_segntprst_handler)(struct UTrapframe *utf);

//
// Set the segntprst handler function.
// If there isn't one yet, _segntprst_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _segntprst_upcall routine when a segntprst occurs.
//
void
set_segntprst_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_segntprst_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_segntprst_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _segntprst_handler = handler;
    if ((r = sys_env_set_segntprst_upcall(0, _segntprst_upcall)) < 0 )
        panic("set_segntprst_handler: sys_env_set_segntprst_upcall: %e", r);
}

