// User-level fperror handler support.
// Rather than register the C fperror handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in fpeentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language fpe entrypoint defined in lib/fperrorentry.S.
extern void _fperror_upcall(void);

// Pointer to currently installed C-language fperror handler.
void (*_fperror_handler)(struct UTrapframe *utf);

//
// Set the fperror handler function.
// If there isn't one yet, _fperror_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _fperror_upcall routine when a fperror occurs.
//
void
set_fperror_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_fperror_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_fperror_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _fperror_handler = handler;
    if ((r = sys_env_set_fperror_upcall(0, _fperror_upcall)) < 0 )
        panic("set_fperror_handler: sys_env_set_fperror_upcall: %e", r);
}

// User-level fperror handler support.
// Rather than register the C fperror handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in fpeentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language fpe entrypoint defined in lib/fperrorentry.S.
extern void _fperror_upcall(void);

// Pointer to currently installed C-language fperror handler.
void (*_fperror_handler)(struct UTrapframe *utf);

//
// Set the fperror handler function.
// If there isn't one yet, _fperror_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _fperror_upcall routine when a fperror occurs.
//
void
set_fperror_handler(void (*handler)(struct UTrapframe *utf))
{
    int r;

    if (_fperror_handler == 0) {
        // First time through!
        if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
            panic("set_fperror_handler: sys_page_alloc: %e", r);
    }

    // Save handler pointer for assembly to call.
    _fperror_handler = handler;
    if ((r = sys_env_set_fperror_upcall(0, _fperror_upcall)) < 0 )
        panic("set_fperror_handler: sys_env_set_fperror_upcall: %e", r);
}

