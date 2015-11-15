// User-level divide zero fault handler support.
// We register the assembly language wrapper in divzentry.S, which
// in turns calls the registered C function.
// -- by Li Qian

#include <inc/lib.h>

// assembly language entrypoint in lib/divzentry.S
extern void _divzero_upcall(void);

// Pointer to currently install C-language divzero exception handler.
void (*_divzero_handler)(struct UTrapframe *utf);

// set the divide zero exception handler function.
// If there isn't one yet, _divzero_handler will be 0.
// the first time we register a handler, we need to allocate an 
// exception stack, and tell the kernel to call the assembly-language
// _divzero_upcall routine when a page fault occurs.

void set_divzero_handler(void (*handler)(struct UTrapframe *utf)) {
	int r;
	if (_divzero_handler == 0) {
		// first time!
		if ((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
			panic("set_divzero_handler: sys_page_alloc: %e", r);
	}

	// save handler pointer for assembly to call
	_divzero_handler = handler;
	if ((r = sys_env_set_pgfault_upcall(0, _divzero_upcall)) < 0)
		panic("set_divzero_handler: sys_env_set_divzero_upcall: %e", r);
}