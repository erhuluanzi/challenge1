// User-level bpoint handler support.
// Rather than register the C bpoint handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in bptentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language bpt entrypoint defined in lib/bpointentry.S.
extern void _bpoint_upcall(void);

// Pointer to currently installed C-language bpoint handler.
void (*_bpoint_handler)(struct UTrapframe *utf);

//
// Set the bpoint handler function.
// If there isn't one yet, _bpoint_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _bpoint_upcall routine when a bpoint occurs.
//
void
set_bpoint_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_bpoint_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_bpoint_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _bpoint_handler = handler;
    if ((r = sys_env_set_bpoint_upcall(0, _bpoint_upcall)) < 0 )
        panic("set_bpoint_handler: sys_env_set_bpoint_upcall: %e", r);
}

