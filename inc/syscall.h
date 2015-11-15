#ifndef JOS_INC_SYSCALL_H
#define JOS_INC_SYSCALL_H

/* system call numbers */
enum {
	SYS_cputs = 0,
	SYS_cgetc,
	SYS_getenvid,
	SYS_env_destroy,
	SYS_page_alloc,
	SYS_page_map,
	SYS_page_unmap,
	SYS_exofork,
	SYS_env_set_status,
	SYS_env_set_pgfault_upcall,
	SYS_yield,
	SYS_ipc_try_send,
	SYS_ipc_recv,
	SYS_env_set_divzero_upcall,
	SYS_env_set_debug_upcall,
	SYS_env_set_nmskint_upcall,
	SYS_env_set_bpoint_upcall,
	SYS_env_set_oflow_upcall,
	SYS_env_set_bdschk_upcall,
	SYS_env_set_illopcd_upcall,
	SYS_env_set_dvcntavl_upcall,
	SYS_env_set_dbfault_upcall,
	SYS_env_set_ivldtss_upcall,
	SYS_env_set_segntprst_upcall,
	SYS_env_set_stkexception_upcall,
	SYS_env_set_gpfault_upcall,
	SYS_env_set_fperror_upcall,
	SYS_env_set_algchk_upcall,
	SYS_env_set_mchchk_upcall,
	SYS_env_set_SIMDfperror_upcall,
	NSYSCALLS
};

#endif /* !JOS_INC_SYSCALL_H */
