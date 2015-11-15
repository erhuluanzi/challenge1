    case T_DEBUG:
        debug_handler(tf);
        return;
    case T_NMI:
        nmskint_handler(tf);
        return;
    case T_BRKPT:
        bpoint_handler(tf);
        return;
    case T_OFLOW:
        oflow_handler(tf);
        return;
    case T_BOUND:
        bdschk_handler(tf);
        return;
    case T_ILLOP:
        illopcd_handler(tf);
        return;
    case T_DEVICE:
        dvcntavl_handler(tf);
        return;
    case T_DBLFLT:
        dbfault_handler(tf);
        return;
    case T_TSS:
        ivldtss_handler(tf);
        return;
    case T_SEGNP:
        segntprst_handler(tf);
        return;
    case T_STACK:
        stkexception_handler(tf);
        return;
    case T_GPFLT:
        gpfault_handler(tf);
        return;
    case T_FPERR:
        fperror_handler(tf);
        return;
    case T_ALIGN:
        algchk_handler(tf);
        return;
    case T_MCHK:
        mchchk_handler(tf);
        return;
    case T_SIMDERR:
        SIMDfperror_handler(tf);
        return;
void debug_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode debug exception
    if ((tf->tf_cs & 3) == 0)
        panic("debug exception in kernel mode!");
    if (curenv->env_debug_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_debug_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void nmskint_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode nmskint exception
    if ((tf->tf_cs & 3) == 0)
        panic("nmskint exception in kernel mode!");
    if (curenv->env_nmskint_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_nmskint_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void bpoint_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode bpoint exception
    if ((tf->tf_cs & 3) == 0)
        panic("bpoint exception in kernel mode!");
    if (curenv->env_bpoint_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_bpoint_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void oflow_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode oflow exception
    if ((tf->tf_cs & 3) == 0)
        panic("oflow exception in kernel mode!");
    if (curenv->env_oflow_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_oflow_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void bdschk_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode bdschk exception
    if ((tf->tf_cs & 3) == 0)
        panic("bdschk exception in kernel mode!");
    if (curenv->env_bdschk_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_bdschk_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void illopcd_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode illopcd exception
    if ((tf->tf_cs & 3) == 0)
        panic("illopcd exception in kernel mode!");
    if (curenv->env_illopcd_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_illopcd_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void dvcntavl_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode dvcntavl exception
    if ((tf->tf_cs & 3) == 0)
        panic("dvcntavl exception in kernel mode!");
    if (curenv->env_dvcntavl_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_dvcntavl_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void dbfault_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode dbfault exception
    if ((tf->tf_cs & 3) == 0)
        panic("dbfault exception in kernel mode!");
    if (curenv->env_dbfault_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_dbfault_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void ivldtss_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode ivldtss exception
    if ((tf->tf_cs & 3) == 0)
        panic("ivldtss exception in kernel mode!");
    if (curenv->env_ivldtss_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_ivldtss_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void segntprst_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode segntprst exception
    if ((tf->tf_cs & 3) == 0)
        panic("segntprst exception in kernel mode!");
    if (curenv->env_segntprst_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_segntprst_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void stkexception_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode stkexception exception
    if ((tf->tf_cs & 3) == 0)
        panic("stkexception exception in kernel mode!");
    if (curenv->env_stkexception_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_stkexception_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void gpfault_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode gpfault exception
    if ((tf->tf_cs & 3) == 0)
        panic("gpfault exception in kernel mode!");
    if (curenv->env_gpfault_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_gpfault_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void fperror_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode fperror exception
    if ((tf->tf_cs & 3) == 0)
        panic("fperror exception in kernel mode!");
    if (curenv->env_fperror_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_fperror_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void algchk_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode algchk exception
    if ((tf->tf_cs & 3) == 0)
        panic("algchk exception in kernel mode!");
    if (curenv->env_algchk_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_algchk_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void mchchk_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode mchchk exception
    if ((tf->tf_cs & 3) == 0)
        panic("mchchk exception in kernel mode!");
    if (curenv->env_mchchk_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_mchchk_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void SIMDfperror_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode SIMDfperror exception
    if ((tf->tf_cs & 3) == 0)
        panic("SIMDfperror exception in kernel mode!");
    if (curenv->env_SIMDfperror_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_SIMDfperror_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

    case T_DEBUG:
        debug_handler(tf);
        return;
    case T_NMI:
        nmskint_handler(tf);
        return;
    case T_BRKPT:
        bpoint_handler(tf);
        return;
    case T_OFLOW:
        oflow_handler(tf);
        return;
    case T_BOUND:
        bdschk_handler(tf);
        return;
    case T_ILLOP:
        illopcd_handler(tf);
        return;
    case T_DEVICE:
        dvcntavl_handler(tf);
        return;
    case T_DBLFLT:
        dbfault_handler(tf);
        return;
    case T_TSS:
        ivldtss_handler(tf);
        return;
    case T_SEGNP:
        segntprst_handler(tf);
        return;
    case T_STACK:
        stkexception_handler(tf);
        return;
    case T_GPFLT:
        gpfault_handler(tf);
        return;
    case T_FPERR:
        fperror_handler(tf);
        return;
    case T_ALIGN:
        algchk_handler(tf);
        return;
    case T_MCHK:
        mchchk_handler(tf);
        return;
    case T_SIMDERR:
        SIMDfperror_handler(tf);
        return;
void debug_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode debug exception
    if ((tf->tf_cs & 3) == 0)
        panic("debug exception in kernel mode!");
    if (curenv->env_debug_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_debug_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void nmskint_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode nmskint exception
    if ((tf->tf_cs & 3) == 0)
        panic("nmskint exception in kernel mode!");
    if (curenv->env_nmskint_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_nmskint_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void bpoint_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode bpoint exception
    if ((tf->tf_cs & 3) == 0)
        panic("bpoint exception in kernel mode!");
    if (curenv->env_bpoint_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_bpoint_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void oflow_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode oflow exception
    if ((tf->tf_cs & 3) == 0)
        panic("oflow exception in kernel mode!");
    if (curenv->env_oflow_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_oflow_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void bdschk_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode bdschk exception
    if ((tf->tf_cs & 3) == 0)
        panic("bdschk exception in kernel mode!");
    if (curenv->env_bdschk_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_bdschk_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void illopcd_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode illopcd exception
    if ((tf->tf_cs & 3) == 0)
        panic("illopcd exception in kernel mode!");
    if (curenv->env_illopcd_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_illopcd_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void dvcntavl_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode dvcntavl exception
    if ((tf->tf_cs & 3) == 0)
        panic("dvcntavl exception in kernel mode!");
    if (curenv->env_dvcntavl_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_dvcntavl_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void dbfault_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode dbfault exception
    if ((tf->tf_cs & 3) == 0)
        panic("dbfault exception in kernel mode!");
    if (curenv->env_dbfault_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_dbfault_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void ivldtss_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode ivldtss exception
    if ((tf->tf_cs & 3) == 0)
        panic("ivldtss exception in kernel mode!");
    if (curenv->env_ivldtss_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_ivldtss_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void segntprst_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode segntprst exception
    if ((tf->tf_cs & 3) == 0)
        panic("segntprst exception in kernel mode!");
    if (curenv->env_segntprst_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_segntprst_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void stkexception_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode stkexception exception
    if ((tf->tf_cs & 3) == 0)
        panic("stkexception exception in kernel mode!");
    if (curenv->env_stkexception_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_stkexception_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void gpfault_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode gpfault exception
    if ((tf->tf_cs & 3) == 0)
        panic("gpfault exception in kernel mode!");
    if (curenv->env_gpfault_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_gpfault_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void fperror_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode fperror exception
    if ((tf->tf_cs & 3) == 0)
        panic("fperror exception in kernel mode!");
    if (curenv->env_fperror_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_fperror_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void algchk_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode algchk exception
    if ((tf->tf_cs & 3) == 0)
        panic("algchk exception in kernel mode!");
    if (curenv->env_algchk_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_algchk_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void mchchk_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode mchchk exception
    if ((tf->tf_cs & 3) == 0)
        panic("mchchk exception in kernel mode!");
    if (curenv->env_mchchk_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_mchchk_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

void SIMDfperror_handler(struct Trapframe *tf) {
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode SIMDfperror exception
    if ((tf->tf_cs & 3) == 0)
        panic("SIMDfperror exception in kernel mode!");
    if (curenv->env_SIMDfperror_upcall) {
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
        utf->utf_fault_va = fault_va;
        utf->utf_err = tf->tf_err;
        utf->utf_regs = tf->tf_regs;
        utf->utf_eip = tf->tf_eip;
        utf->utf_eflags = tf->tf_eflags;
        utf->utf_esp = tf->tf_esp;
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_SIMDfperror_upcall;
        curenv->env_tf.tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }

    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}

