
obj/user/faultbadhandler:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 53 01 00 00       	call   8001a9 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800056:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80005d:	de 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 8c 02 00 00       	call   8002f6 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
	...

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	56                   	push   %esi
  80007c:	53                   	push   %ebx
  80007d:	83 ec 10             	sub    $0x10,%esp
  800080:	8b 75 08             	mov    0x8(%ebp),%esi
  800083:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800086:	e8 e0 00 00 00       	call   80016b <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	8d 14 80             	lea    (%eax,%eax,4),%edx
  800093:	8d 14 90             	lea    (%eax,%edx,4),%edx
  800096:	8d 04 50             	lea    (%eax,%edx,2),%eax
  800099:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  8000a0:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a5:	85 f6                	test   %esi,%esi
  8000a7:	7e 07                	jle    8000b0 <libmain+0x38>
		binaryname = argv[0];
  8000a9:	8b 03                	mov    (%ebx),%eax
  8000ab:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b4:	89 34 24             	mov    %esi,(%esp)
  8000b7:	e8 78 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000bc:	e8 07 00 00 00       	call   8000c8 <exit>
}
  8000c1:	83 c4 10             	add    $0x10,%esp
  8000c4:	5b                   	pop    %ebx
  8000c5:	5e                   	pop    %esi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d5:	e8 3f 00 00 00       	call   800119 <sys_env_destroy>
}
  8000da:	c9                   	leave  
  8000db:	c3                   	ret    

008000dc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	56                   	push   %esi
  8000e1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	89 c3                	mov    %eax,%ebx
  8000ef:	89 c7                	mov    %eax,%edi
  8000f1:	89 c6                	mov    %eax,%esi
  8000f3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5f                   	pop    %edi
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <sys_cgetc>:

int
sys_cgetc(void)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	57                   	push   %edi
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800100:	ba 00 00 00 00       	mov    $0x0,%edx
  800105:	b8 01 00 00 00       	mov    $0x1,%eax
  80010a:	89 d1                	mov    %edx,%ecx
  80010c:	89 d3                	mov    %edx,%ebx
  80010e:	89 d7                	mov    %edx,%edi
  800110:	89 d6                	mov    %edx,%esi
  800112:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800114:	5b                   	pop    %ebx
  800115:	5e                   	pop    %esi
  800116:	5f                   	pop    %edi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	57                   	push   %edi
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800122:	b9 00 00 00 00       	mov    $0x0,%ecx
  800127:	b8 03 00 00 00       	mov    $0x3,%eax
  80012c:	8b 55 08             	mov    0x8(%ebp),%edx
  80012f:	89 cb                	mov    %ecx,%ebx
  800131:	89 cf                	mov    %ecx,%edi
  800133:	89 ce                	mov    %ecx,%esi
  800135:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800137:	85 c0                	test   %eax,%eax
  800139:	7e 28                	jle    800163 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80013b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80013f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800146:	00 
  800147:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  80014e:	00 
  80014f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800156:	00 
  800157:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  80015e:	e8 5d 02 00 00       	call   8003c0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800163:	83 c4 2c             	add    $0x2c,%esp
  800166:	5b                   	pop    %ebx
  800167:	5e                   	pop    %esi
  800168:	5f                   	pop    %edi
  800169:	5d                   	pop    %ebp
  80016a:	c3                   	ret    

0080016b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	57                   	push   %edi
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800171:	ba 00 00 00 00       	mov    $0x0,%edx
  800176:	b8 02 00 00 00       	mov    $0x2,%eax
  80017b:	89 d1                	mov    %edx,%ecx
  80017d:	89 d3                	mov    %edx,%ebx
  80017f:	89 d7                	mov    %edx,%edi
  800181:	89 d6                	mov    %edx,%esi
  800183:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800185:	5b                   	pop    %ebx
  800186:	5e                   	pop    %esi
  800187:	5f                   	pop    %edi
  800188:	5d                   	pop    %ebp
  800189:	c3                   	ret    

0080018a <sys_yield>:

void
sys_yield(void)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	57                   	push   %edi
  80018e:	56                   	push   %esi
  80018f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800190:	ba 00 00 00 00       	mov    $0x0,%edx
  800195:	b8 0a 00 00 00       	mov    $0xa,%eax
  80019a:	89 d1                	mov    %edx,%ecx
  80019c:	89 d3                	mov    %edx,%ebx
  80019e:	89 d7                	mov    %edx,%edi
  8001a0:	89 d6                	mov    %edx,%esi
  8001a2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001a4:	5b                   	pop    %ebx
  8001a5:	5e                   	pop    %esi
  8001a6:	5f                   	pop    %edi
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    

008001a9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b2:	be 00 00 00 00       	mov    $0x0,%esi
  8001b7:	b8 04 00 00 00       	mov    $0x4,%eax
  8001bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c5:	89 f7                	mov    %esi,%edi
  8001c7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c9:	85 c0                	test   %eax,%eax
  8001cb:	7e 28                	jle    8001f5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001d8:	00 
  8001d9:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  8001e0:	00 
  8001e1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001e8:	00 
  8001e9:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  8001f0:	e8 cb 01 00 00       	call   8003c0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001f5:	83 c4 2c             	add    $0x2c,%esp
  8001f8:	5b                   	pop    %ebx
  8001f9:	5e                   	pop    %esi
  8001fa:	5f                   	pop    %edi
  8001fb:	5d                   	pop    %ebp
  8001fc:	c3                   	ret    

008001fd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	57                   	push   %edi
  800201:	56                   	push   %esi
  800202:	53                   	push   %ebx
  800203:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800206:	b8 05 00 00 00       	mov    $0x5,%eax
  80020b:	8b 75 18             	mov    0x18(%ebp),%esi
  80020e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800211:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800214:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800217:	8b 55 08             	mov    0x8(%ebp),%edx
  80021a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80021c:	85 c0                	test   %eax,%eax
  80021e:	7e 28                	jle    800248 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800220:	89 44 24 10          	mov    %eax,0x10(%esp)
  800224:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80022b:	00 
  80022c:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  800233:	00 
  800234:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80023b:	00 
  80023c:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  800243:	e8 78 01 00 00       	call   8003c0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800248:	83 c4 2c             	add    $0x2c,%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	57                   	push   %edi
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
  800256:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800259:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025e:	b8 06 00 00 00       	mov    $0x6,%eax
  800263:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800266:	8b 55 08             	mov    0x8(%ebp),%edx
  800269:	89 df                	mov    %ebx,%edi
  80026b:	89 de                	mov    %ebx,%esi
  80026d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80026f:	85 c0                	test   %eax,%eax
  800271:	7e 28                	jle    80029b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800273:	89 44 24 10          	mov    %eax,0x10(%esp)
  800277:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80027e:	00 
  80027f:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  800286:	00 
  800287:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80028e:	00 
  80028f:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  800296:	e8 25 01 00 00       	call   8003c0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80029b:	83 c4 2c             	add    $0x2c,%esp
  80029e:	5b                   	pop    %ebx
  80029f:	5e                   	pop    %esi
  8002a0:	5f                   	pop    %edi
  8002a1:	5d                   	pop    %ebp
  8002a2:	c3                   	ret    

008002a3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	57                   	push   %edi
  8002a7:	56                   	push   %esi
  8002a8:	53                   	push   %ebx
  8002a9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b1:	b8 08 00 00 00       	mov    $0x8,%eax
  8002b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bc:	89 df                	mov    %ebx,%edi
  8002be:	89 de                	mov    %ebx,%esi
  8002c0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c2:	85 c0                	test   %eax,%eax
  8002c4:	7e 28                	jle    8002ee <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ca:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002d1:	00 
  8002d2:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  8002d9:	00 
  8002da:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002e1:	00 
  8002e2:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  8002e9:	e8 d2 00 00 00       	call   8003c0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ee:	83 c4 2c             	add    $0x2c,%esp
  8002f1:	5b                   	pop    %ebx
  8002f2:	5e                   	pop    %esi
  8002f3:	5f                   	pop    %edi
  8002f4:	5d                   	pop    %ebp
  8002f5:	c3                   	ret    

008002f6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	57                   	push   %edi
  8002fa:	56                   	push   %esi
  8002fb:	53                   	push   %ebx
  8002fc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800304:	b8 09 00 00 00       	mov    $0x9,%eax
  800309:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030c:	8b 55 08             	mov    0x8(%ebp),%edx
  80030f:	89 df                	mov    %ebx,%edi
  800311:	89 de                	mov    %ebx,%esi
  800313:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800315:	85 c0                	test   %eax,%eax
  800317:	7e 28                	jle    800341 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800319:	89 44 24 10          	mov    %eax,0x10(%esp)
  80031d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800324:	00 
  800325:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  80032c:	00 
  80032d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800334:	00 
  800335:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  80033c:	e8 7f 00 00 00       	call   8003c0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800341:	83 c4 2c             	add    $0x2c,%esp
  800344:	5b                   	pop    %ebx
  800345:	5e                   	pop    %esi
  800346:	5f                   	pop    %edi
  800347:	5d                   	pop    %ebp
  800348:	c3                   	ret    

00800349 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	57                   	push   %edi
  80034d:	56                   	push   %esi
  80034e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034f:	be 00 00 00 00       	mov    $0x0,%esi
  800354:	b8 0b 00 00 00       	mov    $0xb,%eax
  800359:	8b 7d 14             	mov    0x14(%ebp),%edi
  80035c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80035f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800362:	8b 55 08             	mov    0x8(%ebp),%edx
  800365:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800367:	5b                   	pop    %ebx
  800368:	5e                   	pop    %esi
  800369:	5f                   	pop    %edi
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	57                   	push   %edi
  800370:	56                   	push   %esi
  800371:	53                   	push   %ebx
  800372:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800375:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80037f:	8b 55 08             	mov    0x8(%ebp),%edx
  800382:	89 cb                	mov    %ecx,%ebx
  800384:	89 cf                	mov    %ecx,%edi
  800386:	89 ce                	mov    %ecx,%esi
  800388:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80038a:	85 c0                	test   %eax,%eax
  80038c:	7e 28                	jle    8003b6 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80038e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800392:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800399:	00 
  80039a:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  8003a1:	00 
  8003a2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003a9:	00 
  8003aa:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  8003b1:	e8 0a 00 00 00       	call   8003c0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003b6:	83 c4 2c             	add    $0x2c,%esp
  8003b9:	5b                   	pop    %ebx
  8003ba:	5e                   	pop    %esi
  8003bb:	5f                   	pop    %edi
  8003bc:	5d                   	pop    %ebp
  8003bd:	c3                   	ret    
	...

008003c0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	56                   	push   %esi
  8003c4:	53                   	push   %ebx
  8003c5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003c8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003cb:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8003d1:	e8 95 fd ff ff       	call   80016b <sys_getenvid>
  8003d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ec:	c7 04 24 18 10 80 00 	movl   $0x801018,(%esp)
  8003f3:	e8 c0 00 00 00       	call   8004b8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ff:	89 04 24             	mov    %eax,(%esp)
  800402:	e8 50 00 00 00       	call   800457 <vcprintf>
	cprintf("\n");
  800407:	c7 04 24 3c 10 80 00 	movl   $0x80103c,(%esp)
  80040e:	e8 a5 00 00 00       	call   8004b8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800413:	cc                   	int3   
  800414:	eb fd                	jmp    800413 <_panic+0x53>
	...

00800418 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800418:	55                   	push   %ebp
  800419:	89 e5                	mov    %esp,%ebp
  80041b:	53                   	push   %ebx
  80041c:	83 ec 14             	sub    $0x14,%esp
  80041f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800422:	8b 03                	mov    (%ebx),%eax
  800424:	8b 55 08             	mov    0x8(%ebp),%edx
  800427:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80042b:	40                   	inc    %eax
  80042c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80042e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800433:	75 19                	jne    80044e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800435:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80043c:	00 
  80043d:	8d 43 08             	lea    0x8(%ebx),%eax
  800440:	89 04 24             	mov    %eax,(%esp)
  800443:	e8 94 fc ff ff       	call   8000dc <sys_cputs>
		b->idx = 0;
  800448:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80044e:	ff 43 04             	incl   0x4(%ebx)
}
  800451:	83 c4 14             	add    $0x14,%esp
  800454:	5b                   	pop    %ebx
  800455:	5d                   	pop    %ebp
  800456:	c3                   	ret    

00800457 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800457:	55                   	push   %ebp
  800458:	89 e5                	mov    %esp,%ebp
  80045a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800460:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800467:	00 00 00 
	b.cnt = 0;
  80046a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800471:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800474:	8b 45 0c             	mov    0xc(%ebp),%eax
  800477:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80047b:	8b 45 08             	mov    0x8(%ebp),%eax
  80047e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800482:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800488:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048c:	c7 04 24 18 04 80 00 	movl   $0x800418,(%esp)
  800493:	e8 b4 01 00 00       	call   80064c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800498:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80049e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004a8:	89 04 24             	mov    %eax,(%esp)
  8004ab:	e8 2c fc ff ff       	call   8000dc <sys_cputs>

	return b.cnt;
}
  8004b0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004b6:	c9                   	leave  
  8004b7:	c3                   	ret    

008004b8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004be:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c8:	89 04 24             	mov    %eax,(%esp)
  8004cb:	e8 87 ff ff ff       	call   800457 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004d0:	c9                   	leave  
  8004d1:	c3                   	ret    
	...

008004d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	57                   	push   %edi
  8004d8:	56                   	push   %esi
  8004d9:	53                   	push   %ebx
  8004da:	83 ec 3c             	sub    $0x3c,%esp
  8004dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004e0:	89 d7                	mov    %edx,%edi
  8004e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ee:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004f1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004f4:	85 c0                	test   %eax,%eax
  8004f6:	75 08                	jne    800500 <printnum+0x2c>
  8004f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004fb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004fe:	77 57                	ja     800557 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800500:	89 74 24 10          	mov    %esi,0x10(%esp)
  800504:	4b                   	dec    %ebx
  800505:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800509:	8b 45 10             	mov    0x10(%ebp),%eax
  80050c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800510:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800514:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800518:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80051f:	00 
  800520:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800523:	89 04 24             	mov    %eax,(%esp)
  800526:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800529:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052d:	e8 5a 08 00 00       	call   800d8c <__udivdi3>
  800532:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800536:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80053a:	89 04 24             	mov    %eax,(%esp)
  80053d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800541:	89 fa                	mov    %edi,%edx
  800543:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800546:	e8 89 ff ff ff       	call   8004d4 <printnum>
  80054b:	eb 0f                	jmp    80055c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80054d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800551:	89 34 24             	mov    %esi,(%esp)
  800554:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800557:	4b                   	dec    %ebx
  800558:	85 db                	test   %ebx,%ebx
  80055a:	7f f1                	jg     80054d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80055c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800560:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800564:	8b 45 10             	mov    0x10(%ebp),%eax
  800567:	89 44 24 08          	mov    %eax,0x8(%esp)
  80056b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800572:	00 
  800573:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800576:	89 04 24             	mov    %eax,(%esp)
  800579:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80057c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800580:	e8 27 09 00 00       	call   800eac <__umoddi3>
  800585:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800589:	0f be 80 3e 10 80 00 	movsbl 0x80103e(%eax),%eax
  800590:	89 04 24             	mov    %eax,(%esp)
  800593:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800596:	83 c4 3c             	add    $0x3c,%esp
  800599:	5b                   	pop    %ebx
  80059a:	5e                   	pop    %esi
  80059b:	5f                   	pop    %edi
  80059c:	5d                   	pop    %ebp
  80059d:	c3                   	ret    

0080059e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80059e:	55                   	push   %ebp
  80059f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005a1:	83 fa 01             	cmp    $0x1,%edx
  8005a4:	7e 0e                	jle    8005b4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005a6:	8b 10                	mov    (%eax),%edx
  8005a8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005ab:	89 08                	mov    %ecx,(%eax)
  8005ad:	8b 02                	mov    (%edx),%eax
  8005af:	8b 52 04             	mov    0x4(%edx),%edx
  8005b2:	eb 22                	jmp    8005d6 <getuint+0x38>
	else if (lflag)
  8005b4:	85 d2                	test   %edx,%edx
  8005b6:	74 10                	je     8005c8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005b8:	8b 10                	mov    (%eax),%edx
  8005ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005bd:	89 08                	mov    %ecx,(%eax)
  8005bf:	8b 02                	mov    (%edx),%eax
  8005c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c6:	eb 0e                	jmp    8005d6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005c8:	8b 10                	mov    (%eax),%edx
  8005ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005cd:	89 08                	mov    %ecx,(%eax)
  8005cf:	8b 02                	mov    (%edx),%eax
  8005d1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005d6:	5d                   	pop    %ebp
  8005d7:	c3                   	ret    

008005d8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8005d8:	55                   	push   %ebp
  8005d9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005db:	83 fa 01             	cmp    $0x1,%edx
  8005de:	7e 0e                	jle    8005ee <getint+0x16>
		return va_arg(*ap, long long);
  8005e0:	8b 10                	mov    (%eax),%edx
  8005e2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005e5:	89 08                	mov    %ecx,(%eax)
  8005e7:	8b 02                	mov    (%edx),%eax
  8005e9:	8b 52 04             	mov    0x4(%edx),%edx
  8005ec:	eb 1a                	jmp    800608 <getint+0x30>
	else if (lflag)
  8005ee:	85 d2                	test   %edx,%edx
  8005f0:	74 0c                	je     8005fe <getint+0x26>
		return va_arg(*ap, long);
  8005f2:	8b 10                	mov    (%eax),%edx
  8005f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005f7:	89 08                	mov    %ecx,(%eax)
  8005f9:	8b 02                	mov    (%edx),%eax
  8005fb:	99                   	cltd   
  8005fc:	eb 0a                	jmp    800608 <getint+0x30>
	else
		return va_arg(*ap, int);
  8005fe:	8b 10                	mov    (%eax),%edx
  800600:	8d 4a 04             	lea    0x4(%edx),%ecx
  800603:	89 08                	mov    %ecx,(%eax)
  800605:	8b 02                	mov    (%edx),%eax
  800607:	99                   	cltd   
}
  800608:	5d                   	pop    %ebp
  800609:	c3                   	ret    

0080060a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80060a:	55                   	push   %ebp
  80060b:	89 e5                	mov    %esp,%ebp
  80060d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800610:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800613:	8b 10                	mov    (%eax),%edx
  800615:	3b 50 04             	cmp    0x4(%eax),%edx
  800618:	73 08                	jae    800622 <sprintputch+0x18>
		*b->buf++ = ch;
  80061a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80061d:	88 0a                	mov    %cl,(%edx)
  80061f:	42                   	inc    %edx
  800620:	89 10                	mov    %edx,(%eax)
}
  800622:	5d                   	pop    %ebp
  800623:	c3                   	ret    

00800624 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800624:	55                   	push   %ebp
  800625:	89 e5                	mov    %esp,%ebp
  800627:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80062a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80062d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800631:	8b 45 10             	mov    0x10(%ebp),%eax
  800634:	89 44 24 08          	mov    %eax,0x8(%esp)
  800638:	8b 45 0c             	mov    0xc(%ebp),%eax
  80063b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063f:	8b 45 08             	mov    0x8(%ebp),%eax
  800642:	89 04 24             	mov    %eax,(%esp)
  800645:	e8 02 00 00 00       	call   80064c <vprintfmt>
	va_end(ap);
}
  80064a:	c9                   	leave  
  80064b:	c3                   	ret    

0080064c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	57                   	push   %edi
  800650:	56                   	push   %esi
  800651:	53                   	push   %ebx
  800652:	83 ec 4c             	sub    $0x4c,%esp
  800655:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800658:	8b 75 10             	mov    0x10(%ebp),%esi
  80065b:	eb 12                	jmp    80066f <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80065d:	85 c0                	test   %eax,%eax
  80065f:	0f 84 40 03 00 00    	je     8009a5 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800665:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800669:	89 04 24             	mov    %eax,(%esp)
  80066c:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80066f:	0f b6 06             	movzbl (%esi),%eax
  800672:	46                   	inc    %esi
  800673:	83 f8 25             	cmp    $0x25,%eax
  800676:	75 e5                	jne    80065d <vprintfmt+0x11>
  800678:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80067c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800683:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800688:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80068f:	ba 00 00 00 00       	mov    $0x0,%edx
  800694:	eb 26                	jmp    8006bc <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800696:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800699:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80069d:	eb 1d                	jmp    8006bc <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006a2:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8006a6:	eb 14                	jmp    8006bc <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8006ab:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8006b2:	eb 08                	jmp    8006bc <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8006b4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006b7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bc:	0f b6 06             	movzbl (%esi),%eax
  8006bf:	8d 4e 01             	lea    0x1(%esi),%ecx
  8006c2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006c5:	8a 0e                	mov    (%esi),%cl
  8006c7:	83 e9 23             	sub    $0x23,%ecx
  8006ca:	80 f9 55             	cmp    $0x55,%cl
  8006cd:	0f 87 b6 02 00 00    	ja     800989 <vprintfmt+0x33d>
  8006d3:	0f b6 c9             	movzbl %cl,%ecx
  8006d6:	ff 24 8d 00 11 80 00 	jmp    *0x801100(,%ecx,4)
  8006dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006e0:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006e5:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  8006e8:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  8006ec:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006ef:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8006f2:	83 f9 09             	cmp    $0x9,%ecx
  8006f5:	77 2a                	ja     800721 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006f7:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006f8:	eb eb                	jmp    8006e5 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8d 48 04             	lea    0x4(%eax),%ecx
  800700:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800703:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800705:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800708:	eb 17                	jmp    800721 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80070a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80070e:	78 98                	js     8006a8 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800710:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800713:	eb a7                	jmp    8006bc <vprintfmt+0x70>
  800715:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800718:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80071f:	eb 9b                	jmp    8006bc <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800721:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800725:	79 95                	jns    8006bc <vprintfmt+0x70>
  800727:	eb 8b                	jmp    8006b4 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800729:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80072d:	eb 8d                	jmp    8006bc <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80072f:	8b 45 14             	mov    0x14(%ebp),%eax
  800732:	8d 50 04             	lea    0x4(%eax),%edx
  800735:	89 55 14             	mov    %edx,0x14(%ebp)
  800738:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073c:	8b 00                	mov    (%eax),%eax
  80073e:	89 04 24             	mov    %eax,(%esp)
  800741:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800744:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800747:	e9 23 ff ff ff       	jmp    80066f <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80074c:	8b 45 14             	mov    0x14(%ebp),%eax
  80074f:	8d 50 04             	lea    0x4(%eax),%edx
  800752:	89 55 14             	mov    %edx,0x14(%ebp)
  800755:	8b 00                	mov    (%eax),%eax
  800757:	85 c0                	test   %eax,%eax
  800759:	79 02                	jns    80075d <vprintfmt+0x111>
  80075b:	f7 d8                	neg    %eax
  80075d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80075f:	83 f8 09             	cmp    $0x9,%eax
  800762:	7f 0b                	jg     80076f <vprintfmt+0x123>
  800764:	8b 04 85 60 12 80 00 	mov    0x801260(,%eax,4),%eax
  80076b:	85 c0                	test   %eax,%eax
  80076d:	75 23                	jne    800792 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80076f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800773:	c7 44 24 08 56 10 80 	movl   $0x801056,0x8(%esp)
  80077a:	00 
  80077b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077f:	8b 45 08             	mov    0x8(%ebp),%eax
  800782:	89 04 24             	mov    %eax,(%esp)
  800785:	e8 9a fe ff ff       	call   800624 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078a:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80078d:	e9 dd fe ff ff       	jmp    80066f <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800792:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800796:	c7 44 24 08 5f 10 80 	movl   $0x80105f,0x8(%esp)
  80079d:	00 
  80079e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a5:	89 14 24             	mov    %edx,(%esp)
  8007a8:	e8 77 fe ff ff       	call   800624 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ad:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007b0:	e9 ba fe ff ff       	jmp    80066f <vprintfmt+0x23>
  8007b5:	89 f9                	mov    %edi,%ecx
  8007b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007ba:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8d 50 04             	lea    0x4(%eax),%edx
  8007c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c6:	8b 30                	mov    (%eax),%esi
  8007c8:	85 f6                	test   %esi,%esi
  8007ca:	75 05                	jne    8007d1 <vprintfmt+0x185>
				p = "(null)";
  8007cc:	be 4f 10 80 00       	mov    $0x80104f,%esi
			if (width > 0 && padc != '-')
  8007d1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007d5:	0f 8e 84 00 00 00    	jle    80085f <vprintfmt+0x213>
  8007db:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007df:	74 7e                	je     80085f <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007e5:	89 34 24             	mov    %esi,(%esp)
  8007e8:	e8 5d 02 00 00       	call   800a4a <strnlen>
  8007ed:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007f0:	29 c2                	sub    %eax,%edx
  8007f2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8007f5:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8007f9:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007fc:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007ff:	89 de                	mov    %ebx,%esi
  800801:	89 d3                	mov    %edx,%ebx
  800803:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800805:	eb 0b                	jmp    800812 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800807:	89 74 24 04          	mov    %esi,0x4(%esp)
  80080b:	89 3c 24             	mov    %edi,(%esp)
  80080e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800811:	4b                   	dec    %ebx
  800812:	85 db                	test   %ebx,%ebx
  800814:	7f f1                	jg     800807 <vprintfmt+0x1bb>
  800816:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800819:	89 f3                	mov    %esi,%ebx
  80081b:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80081e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800821:	85 c0                	test   %eax,%eax
  800823:	79 05                	jns    80082a <vprintfmt+0x1de>
  800825:	b8 00 00 00 00       	mov    $0x0,%eax
  80082a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80082d:	29 c2                	sub    %eax,%edx
  80082f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800832:	eb 2b                	jmp    80085f <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800834:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800838:	74 18                	je     800852 <vprintfmt+0x206>
  80083a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80083d:	83 fa 5e             	cmp    $0x5e,%edx
  800840:	76 10                	jbe    800852 <vprintfmt+0x206>
					putch('?', putdat);
  800842:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800846:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80084d:	ff 55 08             	call   *0x8(%ebp)
  800850:	eb 0a                	jmp    80085c <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800852:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800856:	89 04 24             	mov    %eax,(%esp)
  800859:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80085c:	ff 4d e4             	decl   -0x1c(%ebp)
  80085f:	0f be 06             	movsbl (%esi),%eax
  800862:	46                   	inc    %esi
  800863:	85 c0                	test   %eax,%eax
  800865:	74 21                	je     800888 <vprintfmt+0x23c>
  800867:	85 ff                	test   %edi,%edi
  800869:	78 c9                	js     800834 <vprintfmt+0x1e8>
  80086b:	4f                   	dec    %edi
  80086c:	79 c6                	jns    800834 <vprintfmt+0x1e8>
  80086e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800871:	89 de                	mov    %ebx,%esi
  800873:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800876:	eb 18                	jmp    800890 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800878:	89 74 24 04          	mov    %esi,0x4(%esp)
  80087c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800883:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800885:	4b                   	dec    %ebx
  800886:	eb 08                	jmp    800890 <vprintfmt+0x244>
  800888:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088b:	89 de                	mov    %ebx,%esi
  80088d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800890:	85 db                	test   %ebx,%ebx
  800892:	7f e4                	jg     800878 <vprintfmt+0x22c>
  800894:	89 7d 08             	mov    %edi,0x8(%ebp)
  800897:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800899:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80089c:	e9 ce fd ff ff       	jmp    80066f <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a4:	e8 2f fd ff ff       	call   8005d8 <getint>
  8008a9:	89 c6                	mov    %eax,%esi
  8008ab:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8008ad:	85 d2                	test   %edx,%edx
  8008af:	78 07                	js     8008b8 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008b1:	be 0a 00 00 00       	mov    $0xa,%esi
  8008b6:	eb 7e                	jmp    800936 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008bc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008c3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008c6:	89 f0                	mov    %esi,%eax
  8008c8:	89 fa                	mov    %edi,%edx
  8008ca:	f7 d8                	neg    %eax
  8008cc:	83 d2 00             	adc    $0x0,%edx
  8008cf:	f7 da                	neg    %edx
			}
			base = 10;
  8008d1:	be 0a 00 00 00       	mov    $0xa,%esi
  8008d6:	eb 5e                	jmp    800936 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8008db:	e8 be fc ff ff       	call   80059e <getuint>
			base = 10;
  8008e0:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8008e5:	eb 4f                	jmp    800936 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8008e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ea:	e8 af fc ff ff       	call   80059e <getuint>
			base = 8;
  8008ef:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8008f4:	eb 40                	jmp    800936 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  8008f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008fa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800901:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800904:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800908:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80090f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800912:	8b 45 14             	mov    0x14(%ebp),%eax
  800915:	8d 50 04             	lea    0x4(%eax),%edx
  800918:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80091b:	8b 00                	mov    (%eax),%eax
  80091d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800922:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800927:	eb 0d                	jmp    800936 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800929:	8d 45 14             	lea    0x14(%ebp),%eax
  80092c:	e8 6d fc ff ff       	call   80059e <getuint>
			base = 16;
  800931:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800936:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  80093a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80093e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800941:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800945:	89 74 24 08          	mov    %esi,0x8(%esp)
  800949:	89 04 24             	mov    %eax,(%esp)
  80094c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800950:	89 da                	mov    %ebx,%edx
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	e8 7a fb ff ff       	call   8004d4 <printnum>
			break;
  80095a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80095d:	e9 0d fd ff ff       	jmp    80066f <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  800962:	8d 45 14             	lea    0x14(%ebp),%eax
  800965:	e8 6e fc ff ff       	call   8005d8 <getint>
  80096a:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  800972:	e9 f8 fc ff ff       	jmp    80066f <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800977:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80097b:	89 04 24             	mov    %eax,(%esp)
  80097e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800981:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800984:	e9 e6 fc ff ff       	jmp    80066f <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800989:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80098d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800994:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800997:	eb 01                	jmp    80099a <vprintfmt+0x34e>
  800999:	4e                   	dec    %esi
  80099a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80099e:	75 f9                	jne    800999 <vprintfmt+0x34d>
  8009a0:	e9 ca fc ff ff       	jmp    80066f <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009a5:	83 c4 4c             	add    $0x4c,%esp
  8009a8:	5b                   	pop    %ebx
  8009a9:	5e                   	pop    %esi
  8009aa:	5f                   	pop    %edi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	83 ec 28             	sub    $0x28,%esp
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009bc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009c0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009ca:	85 c0                	test   %eax,%eax
  8009cc:	74 30                	je     8009fe <vsnprintf+0x51>
  8009ce:	85 d2                	test   %edx,%edx
  8009d0:	7e 33                	jle    800a05 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8009dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e7:	c7 04 24 0a 06 80 00 	movl   $0x80060a,(%esp)
  8009ee:	e8 59 fc ff ff       	call   80064c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009f6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009fc:	eb 0c                	jmp    800a0a <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a03:	eb 05                	jmp    800a0a <vsnprintf+0x5d>
  800a05:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a0a:	c9                   	leave  
  800a0b:	c3                   	ret    

00800a0c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a12:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a15:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a19:	8b 45 10             	mov    0x10(%ebp),%eax
  800a1c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a23:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	89 04 24             	mov    %eax,(%esp)
  800a2d:	e8 7b ff ff ff       	call   8009ad <vsnprintf>
	va_end(ap);

	return rc;
}
  800a32:	c9                   	leave  
  800a33:	c3                   	ret    

00800a34 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3f:	eb 01                	jmp    800a42 <strlen+0xe>
		n++;
  800a41:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a42:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a46:	75 f9                	jne    800a41 <strlen+0xd>
		n++;
	return n;
}
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a50:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a53:	b8 00 00 00 00       	mov    $0x0,%eax
  800a58:	eb 01                	jmp    800a5b <strnlen+0x11>
		n++;
  800a5a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a5b:	39 d0                	cmp    %edx,%eax
  800a5d:	74 06                	je     800a65 <strnlen+0x1b>
  800a5f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a63:	75 f5                	jne    800a5a <strnlen+0x10>
		n++;
	return n;
}
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	53                   	push   %ebx
  800a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a71:	ba 00 00 00 00       	mov    $0x0,%edx
  800a76:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a79:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a7c:	42                   	inc    %edx
  800a7d:	84 c9                	test   %cl,%cl
  800a7f:	75 f5                	jne    800a76 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a81:	5b                   	pop    %ebx
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	53                   	push   %ebx
  800a88:	83 ec 08             	sub    $0x8,%esp
  800a8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a8e:	89 1c 24             	mov    %ebx,(%esp)
  800a91:	e8 9e ff ff ff       	call   800a34 <strlen>
	strcpy(dst + len, src);
  800a96:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a99:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a9d:	01 d8                	add    %ebx,%eax
  800a9f:	89 04 24             	mov    %eax,(%esp)
  800aa2:	e8 c0 ff ff ff       	call   800a67 <strcpy>
	return dst;
}
  800aa7:	89 d8                	mov    %ebx,%eax
  800aa9:	83 c4 08             	add    $0x8,%esp
  800aac:	5b                   	pop    %ebx
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aba:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800abd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac2:	eb 0c                	jmp    800ad0 <strncpy+0x21>
		*dst++ = *src;
  800ac4:	8a 1a                	mov    (%edx),%bl
  800ac6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ac9:	80 3a 01             	cmpb   $0x1,(%edx)
  800acc:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800acf:	41                   	inc    %ecx
  800ad0:	39 f1                	cmp    %esi,%ecx
  800ad2:	75 f0                	jne    800ac4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
  800add:	8b 75 08             	mov    0x8(%ebp),%esi
  800ae0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ae6:	85 d2                	test   %edx,%edx
  800ae8:	75 0a                	jne    800af4 <strlcpy+0x1c>
  800aea:	89 f0                	mov    %esi,%eax
  800aec:	eb 1a                	jmp    800b08 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aee:	88 18                	mov    %bl,(%eax)
  800af0:	40                   	inc    %eax
  800af1:	41                   	inc    %ecx
  800af2:	eb 02                	jmp    800af6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800af4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800af6:	4a                   	dec    %edx
  800af7:	74 0a                	je     800b03 <strlcpy+0x2b>
  800af9:	8a 19                	mov    (%ecx),%bl
  800afb:	84 db                	test   %bl,%bl
  800afd:	75 ef                	jne    800aee <strlcpy+0x16>
  800aff:	89 c2                	mov    %eax,%edx
  800b01:	eb 02                	jmp    800b05 <strlcpy+0x2d>
  800b03:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b05:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b08:	29 f0                	sub    %esi,%eax
}
  800b0a:	5b                   	pop    %ebx
  800b0b:	5e                   	pop    %esi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b14:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b17:	eb 02                	jmp    800b1b <strcmp+0xd>
		p++, q++;
  800b19:	41                   	inc    %ecx
  800b1a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b1b:	8a 01                	mov    (%ecx),%al
  800b1d:	84 c0                	test   %al,%al
  800b1f:	74 04                	je     800b25 <strcmp+0x17>
  800b21:	3a 02                	cmp    (%edx),%al
  800b23:	74 f4                	je     800b19 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b25:	0f b6 c0             	movzbl %al,%eax
  800b28:	0f b6 12             	movzbl (%edx),%edx
  800b2b:	29 d0                	sub    %edx,%eax
}
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	53                   	push   %ebx
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b39:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b3c:	eb 03                	jmp    800b41 <strncmp+0x12>
		n--, p++, q++;
  800b3e:	4a                   	dec    %edx
  800b3f:	40                   	inc    %eax
  800b40:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b41:	85 d2                	test   %edx,%edx
  800b43:	74 14                	je     800b59 <strncmp+0x2a>
  800b45:	8a 18                	mov    (%eax),%bl
  800b47:	84 db                	test   %bl,%bl
  800b49:	74 04                	je     800b4f <strncmp+0x20>
  800b4b:	3a 19                	cmp    (%ecx),%bl
  800b4d:	74 ef                	je     800b3e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b4f:	0f b6 00             	movzbl (%eax),%eax
  800b52:	0f b6 11             	movzbl (%ecx),%edx
  800b55:	29 d0                	sub    %edx,%eax
  800b57:	eb 05                	jmp    800b5e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b59:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b5e:	5b                   	pop    %ebx
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	8b 45 08             	mov    0x8(%ebp),%eax
  800b67:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b6a:	eb 05                	jmp    800b71 <strchr+0x10>
		if (*s == c)
  800b6c:	38 ca                	cmp    %cl,%dl
  800b6e:	74 0c                	je     800b7c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b70:	40                   	inc    %eax
  800b71:	8a 10                	mov    (%eax),%dl
  800b73:	84 d2                	test   %dl,%dl
  800b75:	75 f5                	jne    800b6c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	8b 45 08             	mov    0x8(%ebp),%eax
  800b84:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b87:	eb 05                	jmp    800b8e <strfind+0x10>
		if (*s == c)
  800b89:	38 ca                	cmp    %cl,%dl
  800b8b:	74 07                	je     800b94 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b8d:	40                   	inc    %eax
  800b8e:	8a 10                	mov    (%eax),%dl
  800b90:	84 d2                	test   %dl,%dl
  800b92:	75 f5                	jne    800b89 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	57                   	push   %edi
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
  800b9c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ba5:	85 c9                	test   %ecx,%ecx
  800ba7:	74 30                	je     800bd9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ba9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800baf:	75 25                	jne    800bd6 <memset+0x40>
  800bb1:	f6 c1 03             	test   $0x3,%cl
  800bb4:	75 20                	jne    800bd6 <memset+0x40>
		c &= 0xFF;
  800bb6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bb9:	89 d3                	mov    %edx,%ebx
  800bbb:	c1 e3 08             	shl    $0x8,%ebx
  800bbe:	89 d6                	mov    %edx,%esi
  800bc0:	c1 e6 18             	shl    $0x18,%esi
  800bc3:	89 d0                	mov    %edx,%eax
  800bc5:	c1 e0 10             	shl    $0x10,%eax
  800bc8:	09 f0                	or     %esi,%eax
  800bca:	09 d0                	or     %edx,%eax
  800bcc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bce:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bd1:	fc                   	cld    
  800bd2:	f3 ab                	rep stos %eax,%es:(%edi)
  800bd4:	eb 03                	jmp    800bd9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bd6:	fc                   	cld    
  800bd7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bd9:	89 f8                	mov    %edi,%eax
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	8b 45 08             	mov    0x8(%ebp),%eax
  800be8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800beb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bee:	39 c6                	cmp    %eax,%esi
  800bf0:	73 34                	jae    800c26 <memmove+0x46>
  800bf2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bf5:	39 d0                	cmp    %edx,%eax
  800bf7:	73 2d                	jae    800c26 <memmove+0x46>
		s += n;
		d += n;
  800bf9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bfc:	f6 c2 03             	test   $0x3,%dl
  800bff:	75 1b                	jne    800c1c <memmove+0x3c>
  800c01:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c07:	75 13                	jne    800c1c <memmove+0x3c>
  800c09:	f6 c1 03             	test   $0x3,%cl
  800c0c:	75 0e                	jne    800c1c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c0e:	83 ef 04             	sub    $0x4,%edi
  800c11:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c14:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c17:	fd                   	std    
  800c18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c1a:	eb 07                	jmp    800c23 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c1c:	4f                   	dec    %edi
  800c1d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c20:	fd                   	std    
  800c21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c23:	fc                   	cld    
  800c24:	eb 20                	jmp    800c46 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c26:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c2c:	75 13                	jne    800c41 <memmove+0x61>
  800c2e:	a8 03                	test   $0x3,%al
  800c30:	75 0f                	jne    800c41 <memmove+0x61>
  800c32:	f6 c1 03             	test   $0x3,%cl
  800c35:	75 0a                	jne    800c41 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c37:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c3a:	89 c7                	mov    %eax,%edi
  800c3c:	fc                   	cld    
  800c3d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c3f:	eb 05                	jmp    800c46 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c41:	89 c7                	mov    %eax,%edi
  800c43:	fc                   	cld    
  800c44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c50:	8b 45 10             	mov    0x10(%ebp),%eax
  800c53:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c61:	89 04 24             	mov    %eax,(%esp)
  800c64:	e8 77 ff ff ff       	call   800be0 <memmove>
}
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    

00800c6b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c74:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7f:	eb 16                	jmp    800c97 <memcmp+0x2c>
		if (*s1 != *s2)
  800c81:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c84:	42                   	inc    %edx
  800c85:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c89:	38 c8                	cmp    %cl,%al
  800c8b:	74 0a                	je     800c97 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c8d:	0f b6 c0             	movzbl %al,%eax
  800c90:	0f b6 c9             	movzbl %cl,%ecx
  800c93:	29 c8                	sub    %ecx,%eax
  800c95:	eb 09                	jmp    800ca0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c97:	39 da                	cmp    %ebx,%edx
  800c99:	75 e6                	jne    800c81 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cae:	89 c2                	mov    %eax,%edx
  800cb0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cb3:	eb 05                	jmp    800cba <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb5:	38 08                	cmp    %cl,(%eax)
  800cb7:	74 05                	je     800cbe <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cb9:	40                   	inc    %eax
  800cba:	39 d0                	cmp    %edx,%eax
  800cbc:	72 f7                	jb     800cb5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	53                   	push   %ebx
  800cc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ccc:	eb 01                	jmp    800ccf <strtol+0xf>
		s++;
  800cce:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ccf:	8a 02                	mov    (%edx),%al
  800cd1:	3c 20                	cmp    $0x20,%al
  800cd3:	74 f9                	je     800cce <strtol+0xe>
  800cd5:	3c 09                	cmp    $0x9,%al
  800cd7:	74 f5                	je     800cce <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cd9:	3c 2b                	cmp    $0x2b,%al
  800cdb:	75 08                	jne    800ce5 <strtol+0x25>
		s++;
  800cdd:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cde:	bf 00 00 00 00       	mov    $0x0,%edi
  800ce3:	eb 13                	jmp    800cf8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ce5:	3c 2d                	cmp    $0x2d,%al
  800ce7:	75 0a                	jne    800cf3 <strtol+0x33>
		s++, neg = 1;
  800ce9:	8d 52 01             	lea    0x1(%edx),%edx
  800cec:	bf 01 00 00 00       	mov    $0x1,%edi
  800cf1:	eb 05                	jmp    800cf8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cf3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cf8:	85 db                	test   %ebx,%ebx
  800cfa:	74 05                	je     800d01 <strtol+0x41>
  800cfc:	83 fb 10             	cmp    $0x10,%ebx
  800cff:	75 28                	jne    800d29 <strtol+0x69>
  800d01:	8a 02                	mov    (%edx),%al
  800d03:	3c 30                	cmp    $0x30,%al
  800d05:	75 10                	jne    800d17 <strtol+0x57>
  800d07:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d0b:	75 0a                	jne    800d17 <strtol+0x57>
		s += 2, base = 16;
  800d0d:	83 c2 02             	add    $0x2,%edx
  800d10:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d15:	eb 12                	jmp    800d29 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d17:	85 db                	test   %ebx,%ebx
  800d19:	75 0e                	jne    800d29 <strtol+0x69>
  800d1b:	3c 30                	cmp    $0x30,%al
  800d1d:	75 05                	jne    800d24 <strtol+0x64>
		s++, base = 8;
  800d1f:	42                   	inc    %edx
  800d20:	b3 08                	mov    $0x8,%bl
  800d22:	eb 05                	jmp    800d29 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d24:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d29:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d30:	8a 0a                	mov    (%edx),%cl
  800d32:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d35:	80 fb 09             	cmp    $0x9,%bl
  800d38:	77 08                	ja     800d42 <strtol+0x82>
			dig = *s - '0';
  800d3a:	0f be c9             	movsbl %cl,%ecx
  800d3d:	83 e9 30             	sub    $0x30,%ecx
  800d40:	eb 1e                	jmp    800d60 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d42:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d45:	80 fb 19             	cmp    $0x19,%bl
  800d48:	77 08                	ja     800d52 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d4a:	0f be c9             	movsbl %cl,%ecx
  800d4d:	83 e9 57             	sub    $0x57,%ecx
  800d50:	eb 0e                	jmp    800d60 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d52:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d55:	80 fb 19             	cmp    $0x19,%bl
  800d58:	77 12                	ja     800d6c <strtol+0xac>
			dig = *s - 'A' + 10;
  800d5a:	0f be c9             	movsbl %cl,%ecx
  800d5d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d60:	39 f1                	cmp    %esi,%ecx
  800d62:	7d 0c                	jge    800d70 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d64:	42                   	inc    %edx
  800d65:	0f af c6             	imul   %esi,%eax
  800d68:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d6a:	eb c4                	jmp    800d30 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d6c:	89 c1                	mov    %eax,%ecx
  800d6e:	eb 02                	jmp    800d72 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d70:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d72:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d76:	74 05                	je     800d7d <strtol+0xbd>
		*endptr = (char *) s;
  800d78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d7b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d7d:	85 ff                	test   %edi,%edi
  800d7f:	74 04                	je     800d85 <strtol+0xc5>
  800d81:	89 c8                	mov    %ecx,%eax
  800d83:	f7 d8                	neg    %eax
}
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    
	...

00800d8c <__udivdi3>:
  800d8c:	55                   	push   %ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	83 ec 10             	sub    $0x10,%esp
  800d92:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d96:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800d9a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d9e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800da2:	89 cd                	mov    %ecx,%ebp
  800da4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800da8:	85 c0                	test   %eax,%eax
  800daa:	75 2c                	jne    800dd8 <__udivdi3+0x4c>
  800dac:	39 f9                	cmp    %edi,%ecx
  800dae:	77 68                	ja     800e18 <__udivdi3+0x8c>
  800db0:	85 c9                	test   %ecx,%ecx
  800db2:	75 0b                	jne    800dbf <__udivdi3+0x33>
  800db4:	b8 01 00 00 00       	mov    $0x1,%eax
  800db9:	31 d2                	xor    %edx,%edx
  800dbb:	f7 f1                	div    %ecx
  800dbd:	89 c1                	mov    %eax,%ecx
  800dbf:	31 d2                	xor    %edx,%edx
  800dc1:	89 f8                	mov    %edi,%eax
  800dc3:	f7 f1                	div    %ecx
  800dc5:	89 c7                	mov    %eax,%edi
  800dc7:	89 f0                	mov    %esi,%eax
  800dc9:	f7 f1                	div    %ecx
  800dcb:	89 c6                	mov    %eax,%esi
  800dcd:	89 f0                	mov    %esi,%eax
  800dcf:	89 fa                	mov    %edi,%edx
  800dd1:	83 c4 10             	add    $0x10,%esp
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    
  800dd8:	39 f8                	cmp    %edi,%eax
  800dda:	77 2c                	ja     800e08 <__udivdi3+0x7c>
  800ddc:	0f bd f0             	bsr    %eax,%esi
  800ddf:	83 f6 1f             	xor    $0x1f,%esi
  800de2:	75 4c                	jne    800e30 <__udivdi3+0xa4>
  800de4:	39 f8                	cmp    %edi,%eax
  800de6:	bf 00 00 00 00       	mov    $0x0,%edi
  800deb:	72 0a                	jb     800df7 <__udivdi3+0x6b>
  800ded:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800df1:	0f 87 ad 00 00 00    	ja     800ea4 <__udivdi3+0x118>
  800df7:	be 01 00 00 00       	mov    $0x1,%esi
  800dfc:	89 f0                	mov    %esi,%eax
  800dfe:	89 fa                	mov    %edi,%edx
  800e00:	83 c4 10             	add    $0x10,%esp
  800e03:	5e                   	pop    %esi
  800e04:	5f                   	pop    %edi
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    
  800e07:	90                   	nop
  800e08:	31 ff                	xor    %edi,%edi
  800e0a:	31 f6                	xor    %esi,%esi
  800e0c:	89 f0                	mov    %esi,%eax
  800e0e:	89 fa                	mov    %edi,%edx
  800e10:	83 c4 10             	add    $0x10,%esp
  800e13:	5e                   	pop    %esi
  800e14:	5f                   	pop    %edi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    
  800e17:	90                   	nop
  800e18:	89 fa                	mov    %edi,%edx
  800e1a:	89 f0                	mov    %esi,%eax
  800e1c:	f7 f1                	div    %ecx
  800e1e:	89 c6                	mov    %eax,%esi
  800e20:	31 ff                	xor    %edi,%edi
  800e22:	89 f0                	mov    %esi,%eax
  800e24:	89 fa                	mov    %edi,%edx
  800e26:	83 c4 10             	add    $0x10,%esp
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    
  800e2d:	8d 76 00             	lea    0x0(%esi),%esi
  800e30:	89 f1                	mov    %esi,%ecx
  800e32:	d3 e0                	shl    %cl,%eax
  800e34:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e38:	b8 20 00 00 00       	mov    $0x20,%eax
  800e3d:	29 f0                	sub    %esi,%eax
  800e3f:	89 ea                	mov    %ebp,%edx
  800e41:	88 c1                	mov    %al,%cl
  800e43:	d3 ea                	shr    %cl,%edx
  800e45:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e49:	09 ca                	or     %ecx,%edx
  800e4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e4f:	89 f1                	mov    %esi,%ecx
  800e51:	d3 e5                	shl    %cl,%ebp
  800e53:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800e57:	89 fd                	mov    %edi,%ebp
  800e59:	88 c1                	mov    %al,%cl
  800e5b:	d3 ed                	shr    %cl,%ebp
  800e5d:	89 fa                	mov    %edi,%edx
  800e5f:	89 f1                	mov    %esi,%ecx
  800e61:	d3 e2                	shl    %cl,%edx
  800e63:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e67:	88 c1                	mov    %al,%cl
  800e69:	d3 ef                	shr    %cl,%edi
  800e6b:	09 d7                	or     %edx,%edi
  800e6d:	89 f8                	mov    %edi,%eax
  800e6f:	89 ea                	mov    %ebp,%edx
  800e71:	f7 74 24 08          	divl   0x8(%esp)
  800e75:	89 d1                	mov    %edx,%ecx
  800e77:	89 c7                	mov    %eax,%edi
  800e79:	f7 64 24 0c          	mull   0xc(%esp)
  800e7d:	39 d1                	cmp    %edx,%ecx
  800e7f:	72 17                	jb     800e98 <__udivdi3+0x10c>
  800e81:	74 09                	je     800e8c <__udivdi3+0x100>
  800e83:	89 fe                	mov    %edi,%esi
  800e85:	31 ff                	xor    %edi,%edi
  800e87:	e9 41 ff ff ff       	jmp    800dcd <__udivdi3+0x41>
  800e8c:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e90:	89 f1                	mov    %esi,%ecx
  800e92:	d3 e2                	shl    %cl,%edx
  800e94:	39 c2                	cmp    %eax,%edx
  800e96:	73 eb                	jae    800e83 <__udivdi3+0xf7>
  800e98:	8d 77 ff             	lea    -0x1(%edi),%esi
  800e9b:	31 ff                	xor    %edi,%edi
  800e9d:	e9 2b ff ff ff       	jmp    800dcd <__udivdi3+0x41>
  800ea2:	66 90                	xchg   %ax,%ax
  800ea4:	31 f6                	xor    %esi,%esi
  800ea6:	e9 22 ff ff ff       	jmp    800dcd <__udivdi3+0x41>
	...

00800eac <__umoddi3>:
  800eac:	55                   	push   %ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	83 ec 20             	sub    $0x20,%esp
  800eb2:	8b 44 24 30          	mov    0x30(%esp),%eax
  800eb6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800eba:	89 44 24 14          	mov    %eax,0x14(%esp)
  800ebe:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ec2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ec6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800eca:	89 c7                	mov    %eax,%edi
  800ecc:	89 f2                	mov    %esi,%edx
  800ece:	85 ed                	test   %ebp,%ebp
  800ed0:	75 16                	jne    800ee8 <__umoddi3+0x3c>
  800ed2:	39 f1                	cmp    %esi,%ecx
  800ed4:	0f 86 a6 00 00 00    	jbe    800f80 <__umoddi3+0xd4>
  800eda:	f7 f1                	div    %ecx
  800edc:	89 d0                	mov    %edx,%eax
  800ede:	31 d2                	xor    %edx,%edx
  800ee0:	83 c4 20             	add    $0x20,%esp
  800ee3:	5e                   	pop    %esi
  800ee4:	5f                   	pop    %edi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    
  800ee7:	90                   	nop
  800ee8:	39 f5                	cmp    %esi,%ebp
  800eea:	0f 87 ac 00 00 00    	ja     800f9c <__umoddi3+0xf0>
  800ef0:	0f bd c5             	bsr    %ebp,%eax
  800ef3:	83 f0 1f             	xor    $0x1f,%eax
  800ef6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800efa:	0f 84 a8 00 00 00    	je     800fa8 <__umoddi3+0xfc>
  800f00:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f04:	d3 e5                	shl    %cl,%ebp
  800f06:	bf 20 00 00 00       	mov    $0x20,%edi
  800f0b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800f0f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f13:	89 f9                	mov    %edi,%ecx
  800f15:	d3 e8                	shr    %cl,%eax
  800f17:	09 e8                	or     %ebp,%eax
  800f19:	89 44 24 18          	mov    %eax,0x18(%esp)
  800f1d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f21:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f25:	d3 e0                	shl    %cl,%eax
  800f27:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f2b:	89 f2                	mov    %esi,%edx
  800f2d:	d3 e2                	shl    %cl,%edx
  800f2f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f33:	d3 e0                	shl    %cl,%eax
  800f35:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800f39:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f3d:	89 f9                	mov    %edi,%ecx
  800f3f:	d3 e8                	shr    %cl,%eax
  800f41:	09 d0                	or     %edx,%eax
  800f43:	d3 ee                	shr    %cl,%esi
  800f45:	89 f2                	mov    %esi,%edx
  800f47:	f7 74 24 18          	divl   0x18(%esp)
  800f4b:	89 d6                	mov    %edx,%esi
  800f4d:	f7 64 24 0c          	mull   0xc(%esp)
  800f51:	89 c5                	mov    %eax,%ebp
  800f53:	89 d1                	mov    %edx,%ecx
  800f55:	39 d6                	cmp    %edx,%esi
  800f57:	72 67                	jb     800fc0 <__umoddi3+0x114>
  800f59:	74 75                	je     800fd0 <__umoddi3+0x124>
  800f5b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f5f:	29 e8                	sub    %ebp,%eax
  800f61:	19 ce                	sbb    %ecx,%esi
  800f63:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f67:	d3 e8                	shr    %cl,%eax
  800f69:	89 f2                	mov    %esi,%edx
  800f6b:	89 f9                	mov    %edi,%ecx
  800f6d:	d3 e2                	shl    %cl,%edx
  800f6f:	09 d0                	or     %edx,%eax
  800f71:	89 f2                	mov    %esi,%edx
  800f73:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f77:	d3 ea                	shr    %cl,%edx
  800f79:	83 c4 20             	add    $0x20,%esp
  800f7c:	5e                   	pop    %esi
  800f7d:	5f                   	pop    %edi
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    
  800f80:	85 c9                	test   %ecx,%ecx
  800f82:	75 0b                	jne    800f8f <__umoddi3+0xe3>
  800f84:	b8 01 00 00 00       	mov    $0x1,%eax
  800f89:	31 d2                	xor    %edx,%edx
  800f8b:	f7 f1                	div    %ecx
  800f8d:	89 c1                	mov    %eax,%ecx
  800f8f:	89 f0                	mov    %esi,%eax
  800f91:	31 d2                	xor    %edx,%edx
  800f93:	f7 f1                	div    %ecx
  800f95:	89 f8                	mov    %edi,%eax
  800f97:	e9 3e ff ff ff       	jmp    800eda <__umoddi3+0x2e>
  800f9c:	89 f2                	mov    %esi,%edx
  800f9e:	83 c4 20             	add    $0x20,%esp
  800fa1:	5e                   	pop    %esi
  800fa2:	5f                   	pop    %edi
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    
  800fa5:	8d 76 00             	lea    0x0(%esi),%esi
  800fa8:	39 f5                	cmp    %esi,%ebp
  800faa:	72 04                	jb     800fb0 <__umoddi3+0x104>
  800fac:	39 f9                	cmp    %edi,%ecx
  800fae:	77 06                	ja     800fb6 <__umoddi3+0x10a>
  800fb0:	89 f2                	mov    %esi,%edx
  800fb2:	29 cf                	sub    %ecx,%edi
  800fb4:	19 ea                	sbb    %ebp,%edx
  800fb6:	89 f8                	mov    %edi,%eax
  800fb8:	83 c4 20             	add    $0x20,%esp
  800fbb:	5e                   	pop    %esi
  800fbc:	5f                   	pop    %edi
  800fbd:	5d                   	pop    %ebp
  800fbe:	c3                   	ret    
  800fbf:	90                   	nop
  800fc0:	89 d1                	mov    %edx,%ecx
  800fc2:	89 c5                	mov    %eax,%ebp
  800fc4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fc8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fcc:	eb 8d                	jmp    800f5b <__umoddi3+0xaf>
  800fce:	66 90                	xchg   %ax,%ax
  800fd0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fd4:	72 ea                	jb     800fc0 <__umoddi3+0x114>
  800fd6:	89 f1                	mov    %esi,%ecx
  800fd8:	eb 81                	jmp    800f5b <__umoddi3+0xaf>
