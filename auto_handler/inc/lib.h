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
