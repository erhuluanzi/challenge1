// set the debug exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_debug_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_debug_upcall = func;
    return 0;
}

// set the nmskint exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_nmskint_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_nmskint_upcall = func;
    return 0;
}

// set the bpoint exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_bpoint_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_bpoint_upcall = func;
    return 0;
}

// set the oflow exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_oflow_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_oflow_upcall = func;
    return 0;
}

// set the bdschk exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_bdschk_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_bdschk_upcall = func;
    return 0;
}

// set the illopcd exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_illopcd_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_illopcd_upcall = func;
    return 0;
}

// set the dvcntavl exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_dvcntavl_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_dvcntavl_upcall = func;
    return 0;
}

// set the dbfault exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_dbfault_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_dbfault_upcall = func;
    return 0;
}

// set the ivldtss exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_ivldtss_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_ivldtss_upcall = func;
    return 0;
}

// set the segntprst exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_segntprst_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_segntprst_upcall = func;
    return 0;
}

// set the stkexception exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_stkexception_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_stkexception_upcall = func;
    return 0;
}

// set the gpfault exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_gpfault_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_gpfault_upcall = func;
    return 0;
}

// set the fperror exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_fperror_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_fperror_upcall = func;
    return 0;
}

// set the algchk exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_algchk_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_algchk_upcall = func;
    return 0;
}

// set the mchchk exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_mchchk_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_mchchk_upcall = func;
    return 0;
}

// set the SIMDfperror exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_SIMDfperror_upcall = func;
    return 0;
}

    case SYS_env_set_debug_upcall:
        return sys_env_set_debug_upcall(a1, (void *)a2);
    case SYS_env_set_nmskint_upcall:
        return sys_env_set_nmskint_upcall(a1, (void *)a2);
    case SYS_env_set_bpoint_upcall:
        return sys_env_set_bpoint_upcall(a1, (void *)a2);
    case SYS_env_set_oflow_upcall:
        return sys_env_set_oflow_upcall(a1, (void *)a2);
    case SYS_env_set_bdschk_upcall:
        return sys_env_set_bdschk_upcall(a1, (void *)a2);
    case SYS_env_set_illopcd_upcall:
        return sys_env_set_illopcd_upcall(a1, (void *)a2);
    case SYS_env_set_dvcntavl_upcall:
        return sys_env_set_dvcntavl_upcall(a1, (void *)a2);
    case SYS_env_set_dbfault_upcall:
        return sys_env_set_dbfault_upcall(a1, (void *)a2);
    case SYS_env_set_ivldtss_upcall:
        return sys_env_set_ivldtss_upcall(a1, (void *)a2);
    case SYS_env_set_segntprst_upcall:
        return sys_env_set_segntprst_upcall(a1, (void *)a2);
    case SYS_env_set_stkexception_upcall:
        return sys_env_set_stkexception_upcall(a1, (void *)a2);
    case SYS_env_set_gpfault_upcall:
        return sys_env_set_gpfault_upcall(a1, (void *)a2);
    case SYS_env_set_fperror_upcall:
        return sys_env_set_fperror_upcall(a1, (void *)a2);
    case SYS_env_set_algchk_upcall:
        return sys_env_set_algchk_upcall(a1, (void *)a2);
    case SYS_env_set_mchchk_upcall:
        return sys_env_set_mchchk_upcall(a1, (void *)a2);
    case SYS_env_set_SIMDfperror_upcall:
        return sys_env_set_SIMDfperror_upcall(a1, (void *)a2);
// set the debug exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_debug_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_debug_upcall = func;
    return 0;
}

// set the nmskint exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_nmskint_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_nmskint_upcall = func;
    return 0;
}

// set the bpoint exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_bpoint_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_bpoint_upcall = func;
    return 0;
}

// set the oflow exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_oflow_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_oflow_upcall = func;
    return 0;
}

// set the bdschk exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_bdschk_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_bdschk_upcall = func;
    return 0;
}

// set the illopcd exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_illopcd_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_illopcd_upcall = func;
    return 0;
}

// set the dvcntavl exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_dvcntavl_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_dvcntavl_upcall = func;
    return 0;
}

// set the dbfault exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_dbfault_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_dbfault_upcall = func;
    return 0;
}

// set the ivldtss exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_ivldtss_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_ivldtss_upcall = func;
    return 0;
}

// set the segntprst exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_segntprst_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_segntprst_upcall = func;
    return 0;
}

// set the stkexception exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_stkexception_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_stkexception_upcall = func;
    return 0;
}

// set the gpfault exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_gpfault_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_gpfault_upcall = func;
    return 0;
}

// set the fperror exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_fperror_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_fperror_upcall = func;
    return 0;
}

// set the algchk exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_algchk_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_algchk_upcall = func;
    return 0;
}

// set the mchchk exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_mchchk_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_mchchk_upcall = func;
    return 0;
}

// set the SIMDfperror exception upcall for 'envid'
// Returns 0 on success, < 0 on error.
static int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    e->env_SIMDfperror_upcall = func;
    return 0;
}

    case SYS_env_set_debug_upcall:
        return sys_env_set_debug_upcall(a1, (void *)a2);
    case SYS_env_set_nmskint_upcall:
        return sys_env_set_nmskint_upcall(a1, (void *)a2);
    case SYS_env_set_bpoint_upcall:
        return sys_env_set_bpoint_upcall(a1, (void *)a2);
    case SYS_env_set_oflow_upcall:
        return sys_env_set_oflow_upcall(a1, (void *)a2);
    case SYS_env_set_bdschk_upcall:
        return sys_env_set_bdschk_upcall(a1, (void *)a2);
    case SYS_env_set_illopcd_upcall:
        return sys_env_set_illopcd_upcall(a1, (void *)a2);
    case SYS_env_set_dvcntavl_upcall:
        return sys_env_set_dvcntavl_upcall(a1, (void *)a2);
    case SYS_env_set_dbfault_upcall:
        return sys_env_set_dbfault_upcall(a1, (void *)a2);
    case SYS_env_set_ivldtss_upcall:
        return sys_env_set_ivldtss_upcall(a1, (void *)a2);
    case SYS_env_set_segntprst_upcall:
        return sys_env_set_segntprst_upcall(a1, (void *)a2);
    case SYS_env_set_stkexception_upcall:
        return sys_env_set_stkexception_upcall(a1, (void *)a2);
    case SYS_env_set_gpfault_upcall:
        return sys_env_set_gpfault_upcall(a1, (void *)a2);
    case SYS_env_set_fperror_upcall:
        return sys_env_set_fperror_upcall(a1, (void *)a2);
    case SYS_env_set_algchk_upcall:
        return sys_env_set_algchk_upcall(a1, (void *)a2);
    case SYS_env_set_mchchk_upcall:
        return sys_env_set_mchchk_upcall(a1, (void *)a2);
    case SYS_env_set_SIMDfperror_upcall:
        return sys_env_set_SIMDfperror_upcall(a1, (void *)a2);
