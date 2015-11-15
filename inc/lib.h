// Main public header file for our user-land support library,
// whose code lives in the lib directory.
// This library is roughly our OS's version of a standard C library,
// and is intended to be linked into all user-mode applications
// (NOT the kernel or boot loader).

#ifndef JOS_INC_LIB_H
#define JOS_INC_LIB_H 1

#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/stdarg.h>
#include <inc/string.h>
#include <inc/error.h>
#include <inc/assert.h>
#include <inc/env.h>
#include <inc/memlayout.h>
#include <inc/syscall.h>
#include <inc/trap.h>

#define USED(x)		(void)(x)

// main user program
void	umain(int argc, char **argv);

// libmain.c or entry.S
extern const char *binaryname;
extern const volatile struct Env *thisenv;
extern const volatile struct Env envs[NENV];
extern const volatile struct PageInfo pages[];

// exit.c
void	exit(void);

// pgfault.c
void	set_pgfault_handler(void (*handler)(struct UTrapframe *utf));

// divzero.c
void set_divzero_handler(void (*handler)(struct UTrapframe *utf));

//debug.c
void	set_debug_handler(void (*handler)(struct UTrapframe *utf));

//nmskint.c
void	set_nmskint_handler(void (*handler)(struct UTrapframe *utf));

//bpoint.c
void	set_bpoint_handler(void (*handler)(struct UTrapframe *utf));

//oflow.c
void	set_oflow_handler(void (*handler)(struct UTrapframe *utf));

//bdschk.c
void	set_bdschk_handler(void (*handler)(struct UTrapframe *utf));

//illopcd.c
void	set_illopcd_handler(void (*handler)(struct UTrapframe *utf));

//dvcntavl.c
void	set_dvcntavl_handler(void (*handler)(struct UTrapframe *utf));

//dbfault.c
void	set_dbfault_handler(void (*handler)(struct UTrapframe *utf));

//ivldtss.c
void	set_ivldtss_handler(void (*handler)(struct UTrapframe *utf));

//segntprst.c
void	set_segntprst_handler(void (*handler)(struct UTrapframe *utf));

//stkexception.c
void	set_stkexception_handler(void (*handler)(struct UTrapframe *utf));

//gpfault.c
void	set_gpfault_handler(void (*handler)(struct UTrapframe *utf));

//fperror.c
void	set_fperror_handler(void (*handler)(struct UTrapframe *utf));

//algchk.c
void	set_algchk_handler(void (*handler)(struct UTrapframe *utf));

//mchchk.c
void	set_mchchk_handler(void (*handler)(struct UTrapframe *utf));

//SIMDfperror.c
void	set_SIMDfperror_handler(void (*handler)(struct UTrapframe *utf));

// readline.c
char*	readline(const char *buf);

// syscall.c
void	sys_cputs(const char *string, size_t len);
int	sys_cgetc(void);
envid_t	sys_getenvid(void);
int	sys_env_destroy(envid_t);
void	sys_yield(void);
static envid_t sys_exofork(void);
int	sys_env_set_status(envid_t env, int status);
int	sys_env_set_pgfault_upcall(envid_t env, void *upcall);
int	sys_page_alloc(envid_t env, void *pg, int perm);
int	sys_page_map(envid_t src_env, void *src_pg,
		     envid_t dst_env, void *dst_pg, int perm);
int	sys_page_unmap(envid_t env, void *pg);
int	sys_ipc_try_send(envid_t to_env, uint32_t value, void *pg, int perm);
int	sys_ipc_recv(void *rcv_pg);
int sys_env_set_divzero_upcall(envid_t env, void *upcall);
int sys_env_set_debug_upcall(envid_t env, void *upcall);
int sys_env_set_nmskint_upcall(envid_t env, void *upcall);
int sys_env_set_bpoint_upcall(envid_t env, void *upcall);
int sys_env_set_oflow_upcall(envid_t env, void *upcall);
int sys_env_set_bdschk_upcall(envid_t env, void *upcall);
int sys_env_set_illopcd_upcall(envid_t env, void *upcall);
int sys_env_set_dvcntavl_upcall(envid_t env, void *upcall);
int sys_env_set_dbfault_upcall(envid_t env, void *upcall);
int sys_env_set_ivldtss_upcall(envid_t env, void *upcall);
int sys_env_set_segntprst_upcall(envid_t env, void *upcall);
int sys_env_set_stkexception_upcall(envid_t env, void *upcall);
int sys_env_set_gpfault_upcall(envid_t env, void *upcall);
int sys_env_set_fperror_upcall(envid_t env, void *upcall);
int sys_env_set_algchk_upcall(envid_t env, void *upcall);
int sys_env_set_mchchk_upcall(envid_t env, void *upcall);
int sys_env_set_SIMDfperror_upcall(envid_t env, void *upcall);

// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
}

// ipc.c
void	ipc_send(envid_t to_env, uint32_t value, void *pg, int perm);
int32_t ipc_recv(envid_t *from_env_store, void *pg, int *perm_store);
envid_t	ipc_find_env(enum EnvType type);

// fork.c
#define	PTE_SHARE	0x400
envid_t	fork(void);
envid_t	sfork(void);	// Challenge!



/* File open modes */
#define	O_RDONLY	0x0000		/* open for reading only */
#define	O_WRONLY	0x0001		/* open for writing only */
#define	O_RDWR		0x0002		/* open for reading and writing */
#define	O_ACCMODE	0x0003		/* mask for above modes */

#define	O_CREAT		0x0100		/* create if nonexistent */
#define	O_TRUNC		0x0200		/* truncate to zero length */
#define	O_EXCL		0x0400		/* error if already exists */
#define O_MKDIR		0x0800		/* create directory, not regular file */

#endif	// !JOS_INC_LIB_H
