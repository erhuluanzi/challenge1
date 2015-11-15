## 实现divide zero用户态处理程序接口

#### 需要修改的文件：
* inc/env.h
	在Env结构体中增加一个入口函数指针 `void *env_divzero_upcall;`

* lib/divzero.c
	这是新加的一个库文件，目的是要提供对用户的接口，里面需要有 `set_divzero_handler`函数

* inc/lib.h
	- 对`set_divzero_handler`函数的声明
	- 增加系统调用`int sys_env_set_divzero_upcall(envid_t env, void *upcall)`用于处理设置divzero的处理函数。

* inc/syscall.h
	增加系统调用编号`SYS_env_set_divzero_upcall`

* kern/env.c
	在`env_alloc()`函数中初始化时清空divzero handler直到用户设置一个
	`e->env_divzero_upcall = 0;`

* kern/syscall.c
	- 写好`sys_env_set_divzero_upcall`的函数定义，类似pgfault写
	- 记得在syscall()函数中增加一个case进行分派

* kern/trap.h
	写`divide_zero_handler()`的函数声明

* kern/trap.c
	- 修改`trap_dispatch()`函数，增加一个divzero的case
	- 写一个`divzero_handler()`函数，分派时处理divzero exception

* lib/divzentry.S
	这是个庞大的工程，要仿照lib/pfentry.S写一个，起到统一提供接口的目的

* lib/Makefrag
	在LIB_SRCFILES条目中增加 lib/divzero.c 和 lib/divzentry.S 这样才能够在编译时加进去我们的新文件 

* lib/syscall.c
	增加一个库包装系统调用`int sys_env_set_divzero_upcall(envid_t envid, void *upcall)`

最后利用user文件夹下的divzero.c做测试即可，记得补充一个divzero_handler来测试接口

> mark一下完成啦！现在我的测试程序是divzero.c，目前我的处理方法是只输出一句`this is divide zero handler!`然后直接退出程序。用户如果有需求可以自行处理divide zero。只需要调用`set_divzero_handler()`注册一个handler就可以啦。

