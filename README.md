# challenge1


### Part1: exception 0~8 survey by Qian

####0: divide error
```c
  #include <inc/lib.h>
  int zero;
  void umain(int argc, char **argv) {
  	zero = 0;
  	cprintf("1/0 is %08x!\n", 1/zero);
  }
```
直接用divzero.c程序就可以测试了

####1: debug exception
一般用户程序不会触发debug exception。因为需要设置eflags 的TF标志位，所以我们在用户态应该是产生不了的。也就不考虑用户去处理debug exception的问题了。

####2: non-maskable interrupt
非屏蔽中断，用于响应外部硬件中断的，所以我们在用户态也不会写出代码能产生它。一般就是外部中断设备连接上来的。而且NMI一般用于处理特别紧急的情况，所以用户也不应该去自己注册handler吧。

####3: breakpoint
需要把trap.c的第268行的	`assert(!(read_eflags() & FL_IF));`去掉才行，否则breakpoint时这里会报错。因为用户态产生的异常没有关中断，这条语句是检查中断关没关的。然后去掉之后就用写好的breakpoint.c测试就可以看到breakpoint。
```c
  #include <inc/lib.h>
  
  void
  umain(int argc, char **argv)
  {
  	asm volatile("int $3");
  }
```
####4: overflow
可以用INTO指令产生int 4，但是我们在用户态设置的权限好像不能使用INTO指令，所以我尝试写程序也没有成功产生，只能导致general protection fault。除非我们把它的权限改成user的？我觉得overflow在用户态程序运行时是可能产生的，只是我没找到直接写代码产生的方法，所以可以暂时修改权限已完成challenge题目。

####5: bounds check
这个异常是通过BOUND指令产生的，和INTO工作效果差不多，如果检查元素在边界内部，则相当于nop指令，否则就回导致int 5产生。但是我们应该也不能在用户态下产生这个异常吧。如果想用，就得修改trap.c把它的权限改为user的。但是这个也可能在用户程序中发生，所以也得手动暂时改一下它的权限。

####6: illegal opcode
当执行一条语句它的操作数和opcode不匹配时，就会产生int 6。例如跨段的jmp指令操作数写成寄存器，或者les指令操作数是寄存器时。我不知道如何直接产生int 6，因为尝试过各种情况都会在汇编时直接报错，而不会到运行时才发现。但是我觉得用户程序运行的时候可能会发生这种情况，所以我们可以把它的权限暂时改为user，然后用int 6产生。

####7: device not available
在80386用户手册上讲的是coprocessor not available，我觉得用户程序应该不会导致它的发生，即使遇到也不应该由用户处理。

####8: double fault
虽然我看80386用户手册上写，如果第一个fault是page fault，第二个是divide zero时会产生double fault，然而我尝试在page fault handler中产生divide zero，但是最后跑出来结果是只产生了divide zero。不知道为何没有double fault？难道是因为我在用户态下处理的page fault吗？但是double fault应该是操作系统作异常处理时又遇到另一个异常导致的，我不知道为何试不出来啊。那最后可能只能通过int 8来测试效果了。

> 综上，我们需要做的是除了1、2、7号异常的用户级处理接口，仿制page fault handler的做法，增加它们的用户接口。

####--------------------The end-----------------------


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

