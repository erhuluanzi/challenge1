
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
  800090:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800093:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800096:	c1 e0 04             	shl    $0x4,%eax
  800099:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009e:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a3:	85 f6                	test   %esi,%esi
  8000a5:	7e 07                	jle    8000ae <libmain+0x36>
		binaryname = argv[0];
  8000a7:	8b 03                	mov    (%ebx),%eax
  8000a9:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b2:	89 34 24             	mov    %esi,(%esp)
  8000b5:	e8 7a ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000ba:	e8 09 00 00 00       	call   8000c8 <exit>
}
  8000bf:	83 c4 10             	add    $0x10,%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    
	...

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
  800147:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  80014e:	00 
  80014f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800156:	00 
  800157:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  80015e:	e8 e1 07 00 00       	call   800944 <_panic>

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
  8001d9:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  8001e0:	00 
  8001e1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001e8:	00 
  8001e9:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  8001f0:	e8 4f 07 00 00       	call   800944 <_panic>

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
  80022c:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  800233:	00 
  800234:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80023b:	00 
  80023c:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  800243:	e8 fc 06 00 00       	call   800944 <_panic>

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
  80027f:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  800286:	00 
  800287:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80028e:	00 
  80028f:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  800296:	e8 a9 06 00 00       	call   800944 <_panic>

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
  8002d2:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  8002d9:	00 
  8002da:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002e1:	00 
  8002e2:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  8002e9:	e8 56 06 00 00       	call   800944 <_panic>

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
  800325:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  80032c:	00 
  80032d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800334:	00 
  800335:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  80033c:	e8 03 06 00 00       	call   800944 <_panic>

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
  80039a:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  8003a1:	00 
  8003a2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003a9:	00 
  8003aa:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  8003b1:	e8 8e 05 00 00       	call   800944 <_panic>

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

008003be <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	57                   	push   %edi
  8003c2:	56                   	push   %esi
  8003c3:	53                   	push   %ebx
  8003c4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003cc:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d7:	89 df                	mov    %ebx,%edi
  8003d9:	89 de                	mov    %ebx,%esi
  8003db:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003dd:	85 c0                	test   %eax,%eax
  8003df:	7e 28                	jle    800409 <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003e1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003e5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003ec:	00 
  8003ed:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  8003f4:	00 
  8003f5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003fc:	00 
  8003fd:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  800404:	e8 3b 05 00 00       	call   800944 <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800409:	83 c4 2c             	add    $0x2c,%esp
  80040c:	5b                   	pop    %ebx
  80040d:	5e                   	pop    %esi
  80040e:	5f                   	pop    %edi
  80040f:	5d                   	pop    %ebp
  800410:	c3                   	ret    

00800411 <sys_env_set_debug_upcall>:

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	57                   	push   %edi
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
  800417:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80041a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80041f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800424:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800427:	8b 55 08             	mov    0x8(%ebp),%edx
  80042a:	89 df                	mov    %ebx,%edi
  80042c:	89 de                	mov    %ebx,%esi
  80042e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800430:	85 c0                	test   %eax,%eax
  800432:	7e 28                	jle    80045c <sys_env_set_debug_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800434:	89 44 24 10          	mov    %eax,0x10(%esp)
  800438:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80043f:	00 
  800440:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  800447:	00 
  800448:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80044f:	00 
  800450:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  800457:	e8 e8 04 00 00       	call   800944 <_panic>
}

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_debug_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80045c:	83 c4 2c             	add    $0x2c,%esp
  80045f:	5b                   	pop    %ebx
  800460:	5e                   	pop    %esi
  800461:	5f                   	pop    %edi
  800462:	5d                   	pop    %ebp
  800463:	c3                   	ret    

00800464 <sys_env_set_nmskint_upcall>:

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
  800464:	55                   	push   %ebp
  800465:	89 e5                	mov    %esp,%ebp
  800467:	57                   	push   %edi
  800468:	56                   	push   %esi
  800469:	53                   	push   %ebx
  80046a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80046d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800472:	b8 0f 00 00 00       	mov    $0xf,%eax
  800477:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80047a:	8b 55 08             	mov    0x8(%ebp),%edx
  80047d:	89 df                	mov    %ebx,%edi
  80047f:	89 de                	mov    %ebx,%esi
  800481:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800483:	85 c0                	test   %eax,%eax
  800485:	7e 28                	jle    8004af <sys_env_set_nmskint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800487:	89 44 24 10          	mov    %eax,0x10(%esp)
  80048b:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800492:	00 
  800493:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  80049a:	00 
  80049b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004a2:	00 
  8004a3:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  8004aa:	e8 95 04 00 00       	call   800944 <_panic>
}

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_nmskint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8004af:	83 c4 2c             	add    $0x2c,%esp
  8004b2:	5b                   	pop    %ebx
  8004b3:	5e                   	pop    %esi
  8004b4:	5f                   	pop    %edi
  8004b5:	5d                   	pop    %ebp
  8004b6:	c3                   	ret    

008004b7 <sys_env_set_bpoint_upcall>:

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
  8004b7:	55                   	push   %ebp
  8004b8:	89 e5                	mov    %esp,%ebp
  8004ba:	57                   	push   %edi
  8004bb:	56                   	push   %esi
  8004bc:	53                   	push   %ebx
  8004bd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004c5:	b8 10 00 00 00       	mov    $0x10,%eax
  8004ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8004d0:	89 df                	mov    %ebx,%edi
  8004d2:	89 de                	mov    %ebx,%esi
  8004d4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8004d6:	85 c0                	test   %eax,%eax
  8004d8:	7e 28                	jle    800502 <sys_env_set_bpoint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004da:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004de:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  8004e5:	00 
  8004e6:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  8004ed:	00 
  8004ee:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004f5:	00 
  8004f6:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  8004fd:	e8 42 04 00 00       	call   800944 <_panic>
}

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bpoint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800502:	83 c4 2c             	add    $0x2c,%esp
  800505:	5b                   	pop    %ebx
  800506:	5e                   	pop    %esi
  800507:	5f                   	pop    %edi
  800508:	5d                   	pop    %ebp
  800509:	c3                   	ret    

0080050a <sys_env_set_oflow_upcall>:

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
  80050d:	57                   	push   %edi
  80050e:	56                   	push   %esi
  80050f:	53                   	push   %ebx
  800510:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800513:	bb 00 00 00 00       	mov    $0x0,%ebx
  800518:	b8 11 00 00 00       	mov    $0x11,%eax
  80051d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800520:	8b 55 08             	mov    0x8(%ebp),%edx
  800523:	89 df                	mov    %ebx,%edi
  800525:	89 de                	mov    %ebx,%esi
  800527:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800529:	85 c0                	test   %eax,%eax
  80052b:	7e 28                	jle    800555 <sys_env_set_oflow_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80052d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800531:	c7 44 24 0c 11 00 00 	movl   $0x11,0xc(%esp)
  800538:	00 
  800539:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  800540:	00 
  800541:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800548:	00 
  800549:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  800550:	e8 ef 03 00 00       	call   800944 <_panic>
}

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_oflow_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800555:	83 c4 2c             	add    $0x2c,%esp
  800558:	5b                   	pop    %ebx
  800559:	5e                   	pop    %esi
  80055a:	5f                   	pop    %edi
  80055b:	5d                   	pop    %ebp
  80055c:	c3                   	ret    

0080055d <sys_env_set_bdschk_upcall>:

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
  80055d:	55                   	push   %ebp
  80055e:	89 e5                	mov    %esp,%ebp
  800560:	57                   	push   %edi
  800561:	56                   	push   %esi
  800562:	53                   	push   %ebx
  800563:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800566:	bb 00 00 00 00       	mov    $0x0,%ebx
  80056b:	b8 12 00 00 00       	mov    $0x12,%eax
  800570:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800573:	8b 55 08             	mov    0x8(%ebp),%edx
  800576:	89 df                	mov    %ebx,%edi
  800578:	89 de                	mov    %ebx,%esi
  80057a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80057c:	85 c0                	test   %eax,%eax
  80057e:	7e 28                	jle    8005a8 <sys_env_set_bdschk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800580:	89 44 24 10          	mov    %eax,0x10(%esp)
  800584:	c7 44 24 0c 12 00 00 	movl   $0x12,0xc(%esp)
  80058b:	00 
  80058c:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  800593:	00 
  800594:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80059b:	00 
  80059c:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  8005a3:	e8 9c 03 00 00       	call   800944 <_panic>
}

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bdschk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8005a8:	83 c4 2c             	add    $0x2c,%esp
  8005ab:	5b                   	pop    %ebx
  8005ac:	5e                   	pop    %esi
  8005ad:	5f                   	pop    %edi
  8005ae:	5d                   	pop    %ebp
  8005af:	c3                   	ret    

008005b0 <sys_env_set_illopcd_upcall>:

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
  8005b0:	55                   	push   %ebp
  8005b1:	89 e5                	mov    %esp,%ebp
  8005b3:	57                   	push   %edi
  8005b4:	56                   	push   %esi
  8005b5:	53                   	push   %ebx
  8005b6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005be:	b8 13 00 00 00       	mov    $0x13,%eax
  8005c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8005c9:	89 df                	mov    %ebx,%edi
  8005cb:	89 de                	mov    %ebx,%esi
  8005cd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005cf:	85 c0                	test   %eax,%eax
  8005d1:	7e 28                	jle    8005fb <sys_env_set_illopcd_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005d3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005d7:	c7 44 24 0c 13 00 00 	movl   $0x13,0xc(%esp)
  8005de:	00 
  8005df:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  8005e6:	00 
  8005e7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005ee:	00 
  8005ef:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  8005f6:	e8 49 03 00 00       	call   800944 <_panic>
}

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_illopcd_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8005fb:	83 c4 2c             	add    $0x2c,%esp
  8005fe:	5b                   	pop    %ebx
  8005ff:	5e                   	pop    %esi
  800600:	5f                   	pop    %edi
  800601:	5d                   	pop    %ebp
  800602:	c3                   	ret    

00800603 <sys_env_set_dvcntavl_upcall>:

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
  800603:	55                   	push   %ebp
  800604:	89 e5                	mov    %esp,%ebp
  800606:	57                   	push   %edi
  800607:	56                   	push   %esi
  800608:	53                   	push   %ebx
  800609:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80060c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800611:	b8 14 00 00 00       	mov    $0x14,%eax
  800616:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800619:	8b 55 08             	mov    0x8(%ebp),%edx
  80061c:	89 df                	mov    %ebx,%edi
  80061e:	89 de                	mov    %ebx,%esi
  800620:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800622:	85 c0                	test   %eax,%eax
  800624:	7e 28                	jle    80064e <sys_env_set_dvcntavl_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800626:	89 44 24 10          	mov    %eax,0x10(%esp)
  80062a:	c7 44 24 0c 14 00 00 	movl   $0x14,0xc(%esp)
  800631:	00 
  800632:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  800639:	00 
  80063a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800641:	00 
  800642:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  800649:	e8 f6 02 00 00       	call   800944 <_panic>
}

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dvcntavl_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80064e:	83 c4 2c             	add    $0x2c,%esp
  800651:	5b                   	pop    %ebx
  800652:	5e                   	pop    %esi
  800653:	5f                   	pop    %edi
  800654:	5d                   	pop    %ebp
  800655:	c3                   	ret    

00800656 <sys_env_set_dbfault_upcall>:

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
  800656:	55                   	push   %ebp
  800657:	89 e5                	mov    %esp,%ebp
  800659:	57                   	push   %edi
  80065a:	56                   	push   %esi
  80065b:	53                   	push   %ebx
  80065c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80065f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800664:	b8 15 00 00 00       	mov    $0x15,%eax
  800669:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80066c:	8b 55 08             	mov    0x8(%ebp),%edx
  80066f:	89 df                	mov    %ebx,%edi
  800671:	89 de                	mov    %ebx,%esi
  800673:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800675:	85 c0                	test   %eax,%eax
  800677:	7e 28                	jle    8006a1 <sys_env_set_dbfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800679:	89 44 24 10          	mov    %eax,0x10(%esp)
  80067d:	c7 44 24 0c 15 00 00 	movl   $0x15,0xc(%esp)
  800684:	00 
  800685:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  80068c:	00 
  80068d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800694:	00 
  800695:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  80069c:	e8 a3 02 00 00       	call   800944 <_panic>
}

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dbfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8006a1:	83 c4 2c             	add    $0x2c,%esp
  8006a4:	5b                   	pop    %ebx
  8006a5:	5e                   	pop    %esi
  8006a6:	5f                   	pop    %edi
  8006a7:	5d                   	pop    %ebp
  8006a8:	c3                   	ret    

008006a9 <sys_env_set_ivldtss_upcall>:

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
  8006a9:	55                   	push   %ebp
  8006aa:	89 e5                	mov    %esp,%ebp
  8006ac:	57                   	push   %edi
  8006ad:	56                   	push   %esi
  8006ae:	53                   	push   %ebx
  8006af:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b7:	b8 16 00 00 00       	mov    $0x16,%eax
  8006bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c2:	89 df                	mov    %ebx,%edi
  8006c4:	89 de                	mov    %ebx,%esi
  8006c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006c8:	85 c0                	test   %eax,%eax
  8006ca:	7e 28                	jle    8006f4 <sys_env_set_ivldtss_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006cc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006d0:	c7 44 24 0c 16 00 00 	movl   $0x16,0xc(%esp)
  8006d7:	00 
  8006d8:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  8006df:	00 
  8006e0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006e7:	00 
  8006e8:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  8006ef:	e8 50 02 00 00       	call   800944 <_panic>
}

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_ivldtss_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8006f4:	83 c4 2c             	add    $0x2c,%esp
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5f                   	pop    %edi
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <sys_env_set_segntprst_upcall>:

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	57                   	push   %edi
  800700:	56                   	push   %esi
  800701:	53                   	push   %ebx
  800702:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800705:	bb 00 00 00 00       	mov    $0x0,%ebx
  80070a:	b8 17 00 00 00       	mov    $0x17,%eax
  80070f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800712:	8b 55 08             	mov    0x8(%ebp),%edx
  800715:	89 df                	mov    %ebx,%edi
  800717:	89 de                	mov    %ebx,%esi
  800719:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80071b:	85 c0                	test   %eax,%eax
  80071d:	7e 28                	jle    800747 <sys_env_set_segntprst_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80071f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800723:	c7 44 24 0c 17 00 00 	movl   $0x17,0xc(%esp)
  80072a:	00 
  80072b:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  800732:	00 
  800733:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80073a:	00 
  80073b:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  800742:	e8 fd 01 00 00       	call   800944 <_panic>
}

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_segntprst_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800747:	83 c4 2c             	add    $0x2c,%esp
  80074a:	5b                   	pop    %ebx
  80074b:	5e                   	pop    %esi
  80074c:	5f                   	pop    %edi
  80074d:	5d                   	pop    %ebp
  80074e:	c3                   	ret    

0080074f <sys_env_set_stkexception_upcall>:

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	57                   	push   %edi
  800753:	56                   	push   %esi
  800754:	53                   	push   %ebx
  800755:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800758:	bb 00 00 00 00       	mov    $0x0,%ebx
  80075d:	b8 18 00 00 00       	mov    $0x18,%eax
  800762:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800765:	8b 55 08             	mov    0x8(%ebp),%edx
  800768:	89 df                	mov    %ebx,%edi
  80076a:	89 de                	mov    %ebx,%esi
  80076c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80076e:	85 c0                	test   %eax,%eax
  800770:	7e 28                	jle    80079a <sys_env_set_stkexception_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800772:	89 44 24 10          	mov    %eax,0x10(%esp)
  800776:	c7 44 24 0c 18 00 00 	movl   $0x18,0xc(%esp)
  80077d:	00 
  80077e:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  800785:	00 
  800786:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80078d:	00 
  80078e:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  800795:	e8 aa 01 00 00       	call   800944 <_panic>
}

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_stkexception_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80079a:	83 c4 2c             	add    $0x2c,%esp
  80079d:	5b                   	pop    %ebx
  80079e:	5e                   	pop    %esi
  80079f:	5f                   	pop    %edi
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <sys_env_set_gpfault_upcall>:

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	57                   	push   %edi
  8007a6:	56                   	push   %esi
  8007a7:	53                   	push   %ebx
  8007a8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007b0:	b8 19 00 00 00       	mov    $0x19,%eax
  8007b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8007bb:	89 df                	mov    %ebx,%edi
  8007bd:	89 de                	mov    %ebx,%esi
  8007bf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8007c1:	85 c0                	test   %eax,%eax
  8007c3:	7e 28                	jle    8007ed <sys_env_set_gpfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007c9:	c7 44 24 0c 19 00 00 	movl   $0x19,0xc(%esp)
  8007d0:	00 
  8007d1:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  8007d8:	00 
  8007d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8007e0:	00 
  8007e1:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  8007e8:	e8 57 01 00 00       	call   800944 <_panic>
}

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_gpfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8007ed:	83 c4 2c             	add    $0x2c,%esp
  8007f0:	5b                   	pop    %ebx
  8007f1:	5e                   	pop    %esi
  8007f2:	5f                   	pop    %edi
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <sys_env_set_fperror_upcall>:

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	57                   	push   %edi
  8007f9:	56                   	push   %esi
  8007fa:	53                   	push   %ebx
  8007fb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800803:	b8 1a 00 00 00       	mov    $0x1a,%eax
  800808:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080b:	8b 55 08             	mov    0x8(%ebp),%edx
  80080e:	89 df                	mov    %ebx,%edi
  800810:	89 de                	mov    %ebx,%esi
  800812:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800814:	85 c0                	test   %eax,%eax
  800816:	7e 28                	jle    800840 <sys_env_set_fperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800818:	89 44 24 10          	mov    %eax,0x10(%esp)
  80081c:	c7 44 24 0c 1a 00 00 	movl   $0x1a,0xc(%esp)
  800823:	00 
  800824:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  80082b:	00 
  80082c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800833:	00 
  800834:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  80083b:	e8 04 01 00 00       	call   800944 <_panic>
}

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_fperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800840:	83 c4 2c             	add    $0x2c,%esp
  800843:	5b                   	pop    %ebx
  800844:	5e                   	pop    %esi
  800845:	5f                   	pop    %edi
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <sys_env_set_algchk_upcall>:

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	57                   	push   %edi
  80084c:	56                   	push   %esi
  80084d:	53                   	push   %ebx
  80084e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800851:	bb 00 00 00 00       	mov    $0x0,%ebx
  800856:	b8 1b 00 00 00       	mov    $0x1b,%eax
  80085b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085e:	8b 55 08             	mov    0x8(%ebp),%edx
  800861:	89 df                	mov    %ebx,%edi
  800863:	89 de                	mov    %ebx,%esi
  800865:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800867:	85 c0                	test   %eax,%eax
  800869:	7e 28                	jle    800893 <sys_env_set_algchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80086b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80086f:	c7 44 24 0c 1b 00 00 	movl   $0x1b,0xc(%esp)
  800876:	00 
  800877:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  80087e:	00 
  80087f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800886:	00 
  800887:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  80088e:	e8 b1 00 00 00       	call   800944 <_panic>
}

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_algchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800893:	83 c4 2c             	add    $0x2c,%esp
  800896:	5b                   	pop    %ebx
  800897:	5e                   	pop    %esi
  800898:	5f                   	pop    %edi
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <sys_env_set_mchchk_upcall>:

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	57                   	push   %edi
  80089f:	56                   	push   %esi
  8008a0:	53                   	push   %ebx
  8008a1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8008a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008a9:	b8 1c 00 00 00       	mov    $0x1c,%eax
  8008ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8008b4:	89 df                	mov    %ebx,%edi
  8008b6:	89 de                	mov    %ebx,%esi
  8008b8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8008ba:	85 c0                	test   %eax,%eax
  8008bc:	7e 28                	jle    8008e6 <sys_env_set_mchchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8008be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8008c2:	c7 44 24 0c 1c 00 00 	movl   $0x1c,0xc(%esp)
  8008c9:	00 
  8008ca:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  8008d1:	00 
  8008d2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8008d9:	00 
  8008da:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  8008e1:	e8 5e 00 00 00       	call   800944 <_panic>
}

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_mchchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8008e6:	83 c4 2c             	add    $0x2c,%esp
  8008e9:	5b                   	pop    %ebx
  8008ea:	5e                   	pop    %esi
  8008eb:	5f                   	pop    %edi
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <sys_env_set_SIMDfperror_upcall>:

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	57                   	push   %edi
  8008f2:	56                   	push   %esi
  8008f3:	53                   	push   %ebx
  8008f4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8008f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008fc:	b8 1d 00 00 00       	mov    $0x1d,%eax
  800901:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800904:	8b 55 08             	mov    0x8(%ebp),%edx
  800907:	89 df                	mov    %ebx,%edi
  800909:	89 de                	mov    %ebx,%esi
  80090b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80090d:	85 c0                	test   %eax,%eax
  80090f:	7e 28                	jle    800939 <sys_env_set_SIMDfperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800911:	89 44 24 10          	mov    %eax,0x10(%esp)
  800915:	c7 44 24 0c 1d 00 00 	movl   $0x1d,0xc(%esp)
  80091c:	00 
  80091d:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  800924:	00 
  800925:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80092c:	00 
  80092d:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  800934:	e8 0b 00 00 00       	call   800944 <_panic>
}

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_SIMDfperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800939:	83 c4 2c             	add    $0x2c,%esp
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5f                   	pop    %edi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    
  800941:	00 00                	add    %al,(%eax)
	...

00800944 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	56                   	push   %esi
  800948:	53                   	push   %ebx
  800949:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80094c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80094f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800955:	e8 11 f8 ff ff       	call   80016b <sys_getenvid>
  80095a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800961:	8b 55 08             	mov    0x8(%ebp),%edx
  800964:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800968:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80096c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800970:	c7 04 24 98 15 80 00 	movl   $0x801598,(%esp)
  800977:	e8 c0 00 00 00       	call   800a3c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80097c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800980:	8b 45 10             	mov    0x10(%ebp),%eax
  800983:	89 04 24             	mov    %eax,(%esp)
  800986:	e8 50 00 00 00       	call   8009db <vcprintf>
	cprintf("\n");
  80098b:	c7 04 24 bc 15 80 00 	movl   $0x8015bc,(%esp)
  800992:	e8 a5 00 00 00       	call   800a3c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800997:	cc                   	int3   
  800998:	eb fd                	jmp    800997 <_panic+0x53>
	...

0080099c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	53                   	push   %ebx
  8009a0:	83 ec 14             	sub    $0x14,%esp
  8009a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8009a6:	8b 03                	mov    (%ebx),%eax
  8009a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ab:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8009af:	40                   	inc    %eax
  8009b0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8009b2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8009b7:	75 19                	jne    8009d2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8009b9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8009c0:	00 
  8009c1:	8d 43 08             	lea    0x8(%ebx),%eax
  8009c4:	89 04 24             	mov    %eax,(%esp)
  8009c7:	e8 10 f7 ff ff       	call   8000dc <sys_cputs>
		b->idx = 0;
  8009cc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8009d2:	ff 43 04             	incl   0x4(%ebx)
}
  8009d5:	83 c4 14             	add    $0x14,%esp
  8009d8:	5b                   	pop    %ebx
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8009e4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8009eb:	00 00 00 
	b.cnt = 0;
  8009ee:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8009f5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8009f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800a02:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a06:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a10:	c7 04 24 9c 09 80 00 	movl   $0x80099c,(%esp)
  800a17:	e8 b4 01 00 00       	call   800bd0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800a1c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800a22:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a26:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800a2c:	89 04 24             	mov    %eax,(%esp)
  800a2f:	e8 a8 f6 ff ff       	call   8000dc <sys_cputs>

	return b.cnt;
}
  800a34:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    

00800a3c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800a42:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800a45:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	89 04 24             	mov    %eax,(%esp)
  800a4f:	e8 87 ff ff ff       	call   8009db <vcprintf>
	va_end(ap);

	return cnt;
}
  800a54:	c9                   	leave  
  800a55:	c3                   	ret    
	...

00800a58 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	57                   	push   %edi
  800a5c:	56                   	push   %esi
  800a5d:	53                   	push   %ebx
  800a5e:	83 ec 3c             	sub    $0x3c,%esp
  800a61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a64:	89 d7                	mov    %edx,%edi
  800a66:	8b 45 08             	mov    0x8(%ebp),%eax
  800a69:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a72:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800a75:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800a78:	85 c0                	test   %eax,%eax
  800a7a:	75 08                	jne    800a84 <printnum+0x2c>
  800a7c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a7f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800a82:	77 57                	ja     800adb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800a84:	89 74 24 10          	mov    %esi,0x10(%esp)
  800a88:	4b                   	dec    %ebx
  800a89:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800a8d:	8b 45 10             	mov    0x10(%ebp),%eax
  800a90:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a94:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800a98:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800a9c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800aa3:	00 
  800aa4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800aa7:	89 04 24             	mov    %eax,(%esp)
  800aaa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800aad:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab1:	e8 5a 08 00 00       	call   801310 <__udivdi3>
  800ab6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800aba:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800abe:	89 04 24             	mov    %eax,(%esp)
  800ac1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ac5:	89 fa                	mov    %edi,%edx
  800ac7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800aca:	e8 89 ff ff ff       	call   800a58 <printnum>
  800acf:	eb 0f                	jmp    800ae0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800ad1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ad5:	89 34 24             	mov    %esi,(%esp)
  800ad8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800adb:	4b                   	dec    %ebx
  800adc:	85 db                	test   %ebx,%ebx
  800ade:	7f f1                	jg     800ad1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800ae0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ae4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ae8:	8b 45 10             	mov    0x10(%ebp),%eax
  800aeb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aef:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800af6:	00 
  800af7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800afa:	89 04 24             	mov    %eax,(%esp)
  800afd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b00:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b04:	e8 27 09 00 00       	call   801430 <__umoddi3>
  800b09:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b0d:	0f be 80 be 15 80 00 	movsbl 0x8015be(%eax),%eax
  800b14:	89 04 24             	mov    %eax,(%esp)
  800b17:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800b1a:	83 c4 3c             	add    $0x3c,%esp
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800b25:	83 fa 01             	cmp    $0x1,%edx
  800b28:	7e 0e                	jle    800b38 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800b2a:	8b 10                	mov    (%eax),%edx
  800b2c:	8d 4a 08             	lea    0x8(%edx),%ecx
  800b2f:	89 08                	mov    %ecx,(%eax)
  800b31:	8b 02                	mov    (%edx),%eax
  800b33:	8b 52 04             	mov    0x4(%edx),%edx
  800b36:	eb 22                	jmp    800b5a <getuint+0x38>
	else if (lflag)
  800b38:	85 d2                	test   %edx,%edx
  800b3a:	74 10                	je     800b4c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800b3c:	8b 10                	mov    (%eax),%edx
  800b3e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b41:	89 08                	mov    %ecx,(%eax)
  800b43:	8b 02                	mov    (%edx),%eax
  800b45:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4a:	eb 0e                	jmp    800b5a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800b4c:	8b 10                	mov    (%eax),%edx
  800b4e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b51:	89 08                	mov    %ecx,(%eax)
  800b53:	8b 02                	mov    (%edx),%eax
  800b55:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800b5f:	83 fa 01             	cmp    $0x1,%edx
  800b62:	7e 0e                	jle    800b72 <getint+0x16>
		return va_arg(*ap, long long);
  800b64:	8b 10                	mov    (%eax),%edx
  800b66:	8d 4a 08             	lea    0x8(%edx),%ecx
  800b69:	89 08                	mov    %ecx,(%eax)
  800b6b:	8b 02                	mov    (%edx),%eax
  800b6d:	8b 52 04             	mov    0x4(%edx),%edx
  800b70:	eb 1a                	jmp    800b8c <getint+0x30>
	else if (lflag)
  800b72:	85 d2                	test   %edx,%edx
  800b74:	74 0c                	je     800b82 <getint+0x26>
		return va_arg(*ap, long);
  800b76:	8b 10                	mov    (%eax),%edx
  800b78:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b7b:	89 08                	mov    %ecx,(%eax)
  800b7d:	8b 02                	mov    (%edx),%eax
  800b7f:	99                   	cltd   
  800b80:	eb 0a                	jmp    800b8c <getint+0x30>
	else
		return va_arg(*ap, int);
  800b82:	8b 10                	mov    (%eax),%edx
  800b84:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b87:	89 08                	mov    %ecx,(%eax)
  800b89:	8b 02                	mov    (%edx),%eax
  800b8b:	99                   	cltd   
}
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    

00800b8e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800b94:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800b97:	8b 10                	mov    (%eax),%edx
  800b99:	3b 50 04             	cmp    0x4(%eax),%edx
  800b9c:	73 08                	jae    800ba6 <sprintputch+0x18>
		*b->buf++ = ch;
  800b9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba1:	88 0a                	mov    %cl,(%edx)
  800ba3:	42                   	inc    %edx
  800ba4:	89 10                	mov    %edx,(%eax)
}
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800bae:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800bb1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bb5:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc6:	89 04 24             	mov    %eax,(%esp)
  800bc9:	e8 02 00 00 00       	call   800bd0 <vprintfmt>
	va_end(ap);
}
  800bce:	c9                   	leave  
  800bcf:	c3                   	ret    

00800bd0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	57                   	push   %edi
  800bd4:	56                   	push   %esi
  800bd5:	53                   	push   %ebx
  800bd6:	83 ec 4c             	sub    $0x4c,%esp
  800bd9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bdc:	8b 75 10             	mov    0x10(%ebp),%esi
  800bdf:	eb 12                	jmp    800bf3 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800be1:	85 c0                	test   %eax,%eax
  800be3:	0f 84 40 03 00 00    	je     800f29 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800be9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bed:	89 04 24             	mov    %eax,(%esp)
  800bf0:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800bf3:	0f b6 06             	movzbl (%esi),%eax
  800bf6:	46                   	inc    %esi
  800bf7:	83 f8 25             	cmp    $0x25,%eax
  800bfa:	75 e5                	jne    800be1 <vprintfmt+0x11>
  800bfc:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800c00:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800c07:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800c0c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800c13:	ba 00 00 00 00       	mov    $0x0,%edx
  800c18:	eb 26                	jmp    800c40 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c1a:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c1d:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800c21:	eb 1d                	jmp    800c40 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c23:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800c26:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800c2a:	eb 14                	jmp    800c40 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c2c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800c2f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800c36:	eb 08                	jmp    800c40 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800c38:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800c3b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c40:	0f b6 06             	movzbl (%esi),%eax
  800c43:	8d 4e 01             	lea    0x1(%esi),%ecx
  800c46:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800c49:	8a 0e                	mov    (%esi),%cl
  800c4b:	83 e9 23             	sub    $0x23,%ecx
  800c4e:	80 f9 55             	cmp    $0x55,%cl
  800c51:	0f 87 b6 02 00 00    	ja     800f0d <vprintfmt+0x33d>
  800c57:	0f b6 c9             	movzbl %cl,%ecx
  800c5a:	ff 24 8d 80 16 80 00 	jmp    *0x801680(,%ecx,4)
  800c61:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c64:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800c69:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800c6c:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  800c70:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800c73:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800c76:	83 f9 09             	cmp    $0x9,%ecx
  800c79:	77 2a                	ja     800ca5 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c7b:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800c7c:	eb eb                	jmp    800c69 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800c7e:	8b 45 14             	mov    0x14(%ebp),%eax
  800c81:	8d 48 04             	lea    0x4(%eax),%ecx
  800c84:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800c87:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c89:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800c8c:	eb 17                	jmp    800ca5 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800c8e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c92:	78 98                	js     800c2c <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c94:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c97:	eb a7                	jmp    800c40 <vprintfmt+0x70>
  800c99:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800c9c:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800ca3:	eb 9b                	jmp    800c40 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800ca5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ca9:	79 95                	jns    800c40 <vprintfmt+0x70>
  800cab:	eb 8b                	jmp    800c38 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800cad:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cae:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800cb1:	eb 8d                	jmp    800c40 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800cb3:	8b 45 14             	mov    0x14(%ebp),%eax
  800cb6:	8d 50 04             	lea    0x4(%eax),%edx
  800cb9:	89 55 14             	mov    %edx,0x14(%ebp)
  800cbc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cc0:	8b 00                	mov    (%eax),%eax
  800cc2:	89 04 24             	mov    %eax,(%esp)
  800cc5:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cc8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800ccb:	e9 23 ff ff ff       	jmp    800bf3 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800cd0:	8b 45 14             	mov    0x14(%ebp),%eax
  800cd3:	8d 50 04             	lea    0x4(%eax),%edx
  800cd6:	89 55 14             	mov    %edx,0x14(%ebp)
  800cd9:	8b 00                	mov    (%eax),%eax
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	79 02                	jns    800ce1 <vprintfmt+0x111>
  800cdf:	f7 d8                	neg    %eax
  800ce1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800ce3:	83 f8 09             	cmp    $0x9,%eax
  800ce6:	7f 0b                	jg     800cf3 <vprintfmt+0x123>
  800ce8:	8b 04 85 e0 17 80 00 	mov    0x8017e0(,%eax,4),%eax
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	75 23                	jne    800d16 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800cf3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cf7:	c7 44 24 08 d6 15 80 	movl   $0x8015d6,0x8(%esp)
  800cfe:	00 
  800cff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d03:	8b 45 08             	mov    0x8(%ebp),%eax
  800d06:	89 04 24             	mov    %eax,(%esp)
  800d09:	e8 9a fe ff ff       	call   800ba8 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d0e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d11:	e9 dd fe ff ff       	jmp    800bf3 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800d16:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d1a:	c7 44 24 08 df 15 80 	movl   $0x8015df,0x8(%esp)
  800d21:	00 
  800d22:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	89 14 24             	mov    %edx,(%esp)
  800d2c:	e8 77 fe ff ff       	call   800ba8 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d31:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d34:	e9 ba fe ff ff       	jmp    800bf3 <vprintfmt+0x23>
  800d39:	89 f9                	mov    %edi,%ecx
  800d3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d3e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d41:	8b 45 14             	mov    0x14(%ebp),%eax
  800d44:	8d 50 04             	lea    0x4(%eax),%edx
  800d47:	89 55 14             	mov    %edx,0x14(%ebp)
  800d4a:	8b 30                	mov    (%eax),%esi
  800d4c:	85 f6                	test   %esi,%esi
  800d4e:	75 05                	jne    800d55 <vprintfmt+0x185>
				p = "(null)";
  800d50:	be cf 15 80 00       	mov    $0x8015cf,%esi
			if (width > 0 && padc != '-')
  800d55:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800d59:	0f 8e 84 00 00 00    	jle    800de3 <vprintfmt+0x213>
  800d5f:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800d63:	74 7e                	je     800de3 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800d65:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d69:	89 34 24             	mov    %esi,(%esp)
  800d6c:	e8 5d 02 00 00       	call   800fce <strnlen>
  800d71:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800d74:	29 c2                	sub    %eax,%edx
  800d76:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800d79:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800d7d:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800d80:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800d83:	89 de                	mov    %ebx,%esi
  800d85:	89 d3                	mov    %edx,%ebx
  800d87:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d89:	eb 0b                	jmp    800d96 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800d8b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d8f:	89 3c 24             	mov    %edi,(%esp)
  800d92:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d95:	4b                   	dec    %ebx
  800d96:	85 db                	test   %ebx,%ebx
  800d98:	7f f1                	jg     800d8b <vprintfmt+0x1bb>
  800d9a:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800d9d:	89 f3                	mov    %esi,%ebx
  800d9f:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800da2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800da5:	85 c0                	test   %eax,%eax
  800da7:	79 05                	jns    800dae <vprintfmt+0x1de>
  800da9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800db1:	29 c2                	sub    %eax,%edx
  800db3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800db6:	eb 2b                	jmp    800de3 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800db8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800dbc:	74 18                	je     800dd6 <vprintfmt+0x206>
  800dbe:	8d 50 e0             	lea    -0x20(%eax),%edx
  800dc1:	83 fa 5e             	cmp    $0x5e,%edx
  800dc4:	76 10                	jbe    800dd6 <vprintfmt+0x206>
					putch('?', putdat);
  800dc6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dca:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800dd1:	ff 55 08             	call   *0x8(%ebp)
  800dd4:	eb 0a                	jmp    800de0 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800dd6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dda:	89 04 24             	mov    %eax,(%esp)
  800ddd:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800de0:	ff 4d e4             	decl   -0x1c(%ebp)
  800de3:	0f be 06             	movsbl (%esi),%eax
  800de6:	46                   	inc    %esi
  800de7:	85 c0                	test   %eax,%eax
  800de9:	74 21                	je     800e0c <vprintfmt+0x23c>
  800deb:	85 ff                	test   %edi,%edi
  800ded:	78 c9                	js     800db8 <vprintfmt+0x1e8>
  800def:	4f                   	dec    %edi
  800df0:	79 c6                	jns    800db8 <vprintfmt+0x1e8>
  800df2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800df5:	89 de                	mov    %ebx,%esi
  800df7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800dfa:	eb 18                	jmp    800e14 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800dfc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e00:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800e07:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e09:	4b                   	dec    %ebx
  800e0a:	eb 08                	jmp    800e14 <vprintfmt+0x244>
  800e0c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e0f:	89 de                	mov    %ebx,%esi
  800e11:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800e14:	85 db                	test   %ebx,%ebx
  800e16:	7f e4                	jg     800dfc <vprintfmt+0x22c>
  800e18:	89 7d 08             	mov    %edi,0x8(%ebp)
  800e1b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e1d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800e20:	e9 ce fd ff ff       	jmp    800bf3 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800e25:	8d 45 14             	lea    0x14(%ebp),%eax
  800e28:	e8 2f fd ff ff       	call   800b5c <getint>
  800e2d:	89 c6                	mov    %eax,%esi
  800e2f:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800e31:	85 d2                	test   %edx,%edx
  800e33:	78 07                	js     800e3c <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800e35:	be 0a 00 00 00       	mov    $0xa,%esi
  800e3a:	eb 7e                	jmp    800eba <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800e3c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e40:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800e47:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800e4a:	89 f0                	mov    %esi,%eax
  800e4c:	89 fa                	mov    %edi,%edx
  800e4e:	f7 d8                	neg    %eax
  800e50:	83 d2 00             	adc    $0x0,%edx
  800e53:	f7 da                	neg    %edx
			}
			base = 10;
  800e55:	be 0a 00 00 00       	mov    $0xa,%esi
  800e5a:	eb 5e                	jmp    800eba <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800e5c:	8d 45 14             	lea    0x14(%ebp),%eax
  800e5f:	e8 be fc ff ff       	call   800b22 <getuint>
			base = 10;
  800e64:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800e69:	eb 4f                	jmp    800eba <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800e6b:	8d 45 14             	lea    0x14(%ebp),%eax
  800e6e:	e8 af fc ff ff       	call   800b22 <getuint>
			base = 8;
  800e73:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800e78:	eb 40                	jmp    800eba <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  800e7a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e7e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800e85:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800e88:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e8c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800e93:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800e96:	8b 45 14             	mov    0x14(%ebp),%eax
  800e99:	8d 50 04             	lea    0x4(%eax),%edx
  800e9c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800e9f:	8b 00                	mov    (%eax),%eax
  800ea1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ea6:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800eab:	eb 0d                	jmp    800eba <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ead:	8d 45 14             	lea    0x14(%ebp),%eax
  800eb0:	e8 6d fc ff ff       	call   800b22 <getuint>
			base = 16;
  800eb5:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800eba:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800ebe:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800ec2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800ec5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ec9:	89 74 24 08          	mov    %esi,0x8(%esp)
  800ecd:	89 04 24             	mov    %eax,(%esp)
  800ed0:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ed4:	89 da                	mov    %ebx,%edx
  800ed6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed9:	e8 7a fb ff ff       	call   800a58 <printnum>
			break;
  800ede:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ee1:	e9 0d fd ff ff       	jmp    800bf3 <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  800ee6:	8d 45 14             	lea    0x14(%ebp),%eax
  800ee9:	e8 6e fc ff ff       	call   800b5c <getint>
  800eee:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ef3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  800ef6:	e9 f8 fc ff ff       	jmp    800bf3 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800efb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800eff:	89 04 24             	mov    %eax,(%esp)
  800f02:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f05:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800f08:	e9 e6 fc ff ff       	jmp    800bf3 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800f0d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f11:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800f18:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800f1b:	eb 01                	jmp    800f1e <vprintfmt+0x34e>
  800f1d:	4e                   	dec    %esi
  800f1e:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800f22:	75 f9                	jne    800f1d <vprintfmt+0x34d>
  800f24:	e9 ca fc ff ff       	jmp    800bf3 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800f29:	83 c4 4c             	add    $0x4c,%esp
  800f2c:	5b                   	pop    %ebx
  800f2d:	5e                   	pop    %esi
  800f2e:	5f                   	pop    %edi
  800f2f:	5d                   	pop    %ebp
  800f30:	c3                   	ret    

00800f31 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	83 ec 28             	sub    $0x28,%esp
  800f37:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800f3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f40:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800f44:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	74 30                	je     800f82 <vsnprintf+0x51>
  800f52:	85 d2                	test   %edx,%edx
  800f54:	7e 33                	jle    800f89 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f56:	8b 45 14             	mov    0x14(%ebp),%eax
  800f59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f5d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f60:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f64:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f67:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f6b:	c7 04 24 8e 0b 80 00 	movl   $0x800b8e,(%esp)
  800f72:	e8 59 fc ff ff       	call   800bd0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f77:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f7a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f80:	eb 0c                	jmp    800f8e <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800f82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f87:	eb 05                	jmp    800f8e <vsnprintf+0x5d>
  800f89:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800f8e:	c9                   	leave  
  800f8f:	c3                   	ret    

00800f90 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800f96:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800f99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f9d:	8b 45 10             	mov    0x10(%ebp),%eax
  800fa0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fa4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fab:	8b 45 08             	mov    0x8(%ebp),%eax
  800fae:	89 04 24             	mov    %eax,(%esp)
  800fb1:	e8 7b ff ff ff       	call   800f31 <vsnprintf>
	va_end(ap);

	return rc;
}
  800fb6:	c9                   	leave  
  800fb7:	c3                   	ret    

00800fb8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800fbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc3:	eb 01                	jmp    800fc6 <strlen+0xe>
		n++;
  800fc5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800fc6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800fca:	75 f9                	jne    800fc5 <strlen+0xd>
		n++;
	return n;
}
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    

00800fce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800fd4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800fdc:	eb 01                	jmp    800fdf <strnlen+0x11>
		n++;
  800fde:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fdf:	39 d0                	cmp    %edx,%eax
  800fe1:	74 06                	je     800fe9 <strnlen+0x1b>
  800fe3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800fe7:	75 f5                	jne    800fde <strnlen+0x10>
		n++;
	return n;
}
  800fe9:	5d                   	pop    %ebp
  800fea:	c3                   	ret    

00800feb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	53                   	push   %ebx
  800fef:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ff5:	ba 00 00 00 00       	mov    $0x0,%edx
  800ffa:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800ffd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801000:	42                   	inc    %edx
  801001:	84 c9                	test   %cl,%cl
  801003:	75 f5                	jne    800ffa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801005:	5b                   	pop    %ebx
  801006:	5d                   	pop    %ebp
  801007:	c3                   	ret    

00801008 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	53                   	push   %ebx
  80100c:	83 ec 08             	sub    $0x8,%esp
  80100f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801012:	89 1c 24             	mov    %ebx,(%esp)
  801015:	e8 9e ff ff ff       	call   800fb8 <strlen>
	strcpy(dst + len, src);
  80101a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80101d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801021:	01 d8                	add    %ebx,%eax
  801023:	89 04 24             	mov    %eax,(%esp)
  801026:	e8 c0 ff ff ff       	call   800feb <strcpy>
	return dst;
}
  80102b:	89 d8                	mov    %ebx,%eax
  80102d:	83 c4 08             	add    $0x8,%esp
  801030:	5b                   	pop    %ebx
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	56                   	push   %esi
  801037:	53                   	push   %ebx
  801038:	8b 45 08             	mov    0x8(%ebp),%eax
  80103b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80103e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801041:	b9 00 00 00 00       	mov    $0x0,%ecx
  801046:	eb 0c                	jmp    801054 <strncpy+0x21>
		*dst++ = *src;
  801048:	8a 1a                	mov    (%edx),%bl
  80104a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80104d:	80 3a 01             	cmpb   $0x1,(%edx)
  801050:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801053:	41                   	inc    %ecx
  801054:	39 f1                	cmp    %esi,%ecx
  801056:	75 f0                	jne    801048 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801058:	5b                   	pop    %ebx
  801059:	5e                   	pop    %esi
  80105a:	5d                   	pop    %ebp
  80105b:	c3                   	ret    

0080105c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	56                   	push   %esi
  801060:	53                   	push   %ebx
  801061:	8b 75 08             	mov    0x8(%ebp),%esi
  801064:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801067:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80106a:	85 d2                	test   %edx,%edx
  80106c:	75 0a                	jne    801078 <strlcpy+0x1c>
  80106e:	89 f0                	mov    %esi,%eax
  801070:	eb 1a                	jmp    80108c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801072:	88 18                	mov    %bl,(%eax)
  801074:	40                   	inc    %eax
  801075:	41                   	inc    %ecx
  801076:	eb 02                	jmp    80107a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801078:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80107a:	4a                   	dec    %edx
  80107b:	74 0a                	je     801087 <strlcpy+0x2b>
  80107d:	8a 19                	mov    (%ecx),%bl
  80107f:	84 db                	test   %bl,%bl
  801081:	75 ef                	jne    801072 <strlcpy+0x16>
  801083:	89 c2                	mov    %eax,%edx
  801085:	eb 02                	jmp    801089 <strlcpy+0x2d>
  801087:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801089:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80108c:	29 f0                	sub    %esi,%eax
}
  80108e:	5b                   	pop    %ebx
  80108f:	5e                   	pop    %esi
  801090:	5d                   	pop    %ebp
  801091:	c3                   	ret    

00801092 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801098:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80109b:	eb 02                	jmp    80109f <strcmp+0xd>
		p++, q++;
  80109d:	41                   	inc    %ecx
  80109e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80109f:	8a 01                	mov    (%ecx),%al
  8010a1:	84 c0                	test   %al,%al
  8010a3:	74 04                	je     8010a9 <strcmp+0x17>
  8010a5:	3a 02                	cmp    (%edx),%al
  8010a7:	74 f4                	je     80109d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8010a9:	0f b6 c0             	movzbl %al,%eax
  8010ac:	0f b6 12             	movzbl (%edx),%edx
  8010af:	29 d0                	sub    %edx,%eax
}
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	53                   	push   %ebx
  8010b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010bd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8010c0:	eb 03                	jmp    8010c5 <strncmp+0x12>
		n--, p++, q++;
  8010c2:	4a                   	dec    %edx
  8010c3:	40                   	inc    %eax
  8010c4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8010c5:	85 d2                	test   %edx,%edx
  8010c7:	74 14                	je     8010dd <strncmp+0x2a>
  8010c9:	8a 18                	mov    (%eax),%bl
  8010cb:	84 db                	test   %bl,%bl
  8010cd:	74 04                	je     8010d3 <strncmp+0x20>
  8010cf:	3a 19                	cmp    (%ecx),%bl
  8010d1:	74 ef                	je     8010c2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8010d3:	0f b6 00             	movzbl (%eax),%eax
  8010d6:	0f b6 11             	movzbl (%ecx),%edx
  8010d9:	29 d0                	sub    %edx,%eax
  8010db:	eb 05                	jmp    8010e2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8010dd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010e2:	5b                   	pop    %ebx
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    

008010e5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010eb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8010ee:	eb 05                	jmp    8010f5 <strchr+0x10>
		if (*s == c)
  8010f0:	38 ca                	cmp    %cl,%dl
  8010f2:	74 0c                	je     801100 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8010f4:	40                   	inc    %eax
  8010f5:	8a 10                	mov    (%eax),%dl
  8010f7:	84 d2                	test   %dl,%dl
  8010f9:	75 f5                	jne    8010f0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8010fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801100:	5d                   	pop    %ebp
  801101:	c3                   	ret    

00801102 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	8b 45 08             	mov    0x8(%ebp),%eax
  801108:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80110b:	eb 05                	jmp    801112 <strfind+0x10>
		if (*s == c)
  80110d:	38 ca                	cmp    %cl,%dl
  80110f:	74 07                	je     801118 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801111:	40                   	inc    %eax
  801112:	8a 10                	mov    (%eax),%dl
  801114:	84 d2                	test   %dl,%dl
  801116:	75 f5                	jne    80110d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    

0080111a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	57                   	push   %edi
  80111e:	56                   	push   %esi
  80111f:	53                   	push   %ebx
  801120:	8b 7d 08             	mov    0x8(%ebp),%edi
  801123:	8b 45 0c             	mov    0xc(%ebp),%eax
  801126:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801129:	85 c9                	test   %ecx,%ecx
  80112b:	74 30                	je     80115d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80112d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801133:	75 25                	jne    80115a <memset+0x40>
  801135:	f6 c1 03             	test   $0x3,%cl
  801138:	75 20                	jne    80115a <memset+0x40>
		c &= 0xFF;
  80113a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80113d:	89 d3                	mov    %edx,%ebx
  80113f:	c1 e3 08             	shl    $0x8,%ebx
  801142:	89 d6                	mov    %edx,%esi
  801144:	c1 e6 18             	shl    $0x18,%esi
  801147:	89 d0                	mov    %edx,%eax
  801149:	c1 e0 10             	shl    $0x10,%eax
  80114c:	09 f0                	or     %esi,%eax
  80114e:	09 d0                	or     %edx,%eax
  801150:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801152:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801155:	fc                   	cld    
  801156:	f3 ab                	rep stos %eax,%es:(%edi)
  801158:	eb 03                	jmp    80115d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80115a:	fc                   	cld    
  80115b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80115d:	89 f8                	mov    %edi,%eax
  80115f:	5b                   	pop    %ebx
  801160:	5e                   	pop    %esi
  801161:	5f                   	pop    %edi
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	57                   	push   %edi
  801168:	56                   	push   %esi
  801169:	8b 45 08             	mov    0x8(%ebp),%eax
  80116c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80116f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801172:	39 c6                	cmp    %eax,%esi
  801174:	73 34                	jae    8011aa <memmove+0x46>
  801176:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801179:	39 d0                	cmp    %edx,%eax
  80117b:	73 2d                	jae    8011aa <memmove+0x46>
		s += n;
		d += n;
  80117d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801180:	f6 c2 03             	test   $0x3,%dl
  801183:	75 1b                	jne    8011a0 <memmove+0x3c>
  801185:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80118b:	75 13                	jne    8011a0 <memmove+0x3c>
  80118d:	f6 c1 03             	test   $0x3,%cl
  801190:	75 0e                	jne    8011a0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801192:	83 ef 04             	sub    $0x4,%edi
  801195:	8d 72 fc             	lea    -0x4(%edx),%esi
  801198:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80119b:	fd                   	std    
  80119c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80119e:	eb 07                	jmp    8011a7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8011a0:	4f                   	dec    %edi
  8011a1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8011a4:	fd                   	std    
  8011a5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8011a7:	fc                   	cld    
  8011a8:	eb 20                	jmp    8011ca <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8011aa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8011b0:	75 13                	jne    8011c5 <memmove+0x61>
  8011b2:	a8 03                	test   $0x3,%al
  8011b4:	75 0f                	jne    8011c5 <memmove+0x61>
  8011b6:	f6 c1 03             	test   $0x3,%cl
  8011b9:	75 0a                	jne    8011c5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8011bb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8011be:	89 c7                	mov    %eax,%edi
  8011c0:	fc                   	cld    
  8011c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8011c3:	eb 05                	jmp    8011ca <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8011c5:	89 c7                	mov    %eax,%edi
  8011c7:	fc                   	cld    
  8011c8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8011ca:	5e                   	pop    %esi
  8011cb:	5f                   	pop    %edi
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8011d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e5:	89 04 24             	mov    %eax,(%esp)
  8011e8:	e8 77 ff ff ff       	call   801164 <memmove>
}
  8011ed:	c9                   	leave  
  8011ee:	c3                   	ret    

008011ef <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	57                   	push   %edi
  8011f3:	56                   	push   %esi
  8011f4:	53                   	push   %ebx
  8011f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801203:	eb 16                	jmp    80121b <memcmp+0x2c>
		if (*s1 != *s2)
  801205:	8a 04 17             	mov    (%edi,%edx,1),%al
  801208:	42                   	inc    %edx
  801209:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80120d:	38 c8                	cmp    %cl,%al
  80120f:	74 0a                	je     80121b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801211:	0f b6 c0             	movzbl %al,%eax
  801214:	0f b6 c9             	movzbl %cl,%ecx
  801217:	29 c8                	sub    %ecx,%eax
  801219:	eb 09                	jmp    801224 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80121b:	39 da                	cmp    %ebx,%edx
  80121d:	75 e6                	jne    801205 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80121f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801224:	5b                   	pop    %ebx
  801225:	5e                   	pop    %esi
  801226:	5f                   	pop    %edi
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    

00801229 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	8b 45 08             	mov    0x8(%ebp),%eax
  80122f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801232:	89 c2                	mov    %eax,%edx
  801234:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801237:	eb 05                	jmp    80123e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801239:	38 08                	cmp    %cl,(%eax)
  80123b:	74 05                	je     801242 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80123d:	40                   	inc    %eax
  80123e:	39 d0                	cmp    %edx,%eax
  801240:	72 f7                	jb     801239 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    

00801244 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	57                   	push   %edi
  801248:	56                   	push   %esi
  801249:	53                   	push   %ebx
  80124a:	8b 55 08             	mov    0x8(%ebp),%edx
  80124d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801250:	eb 01                	jmp    801253 <strtol+0xf>
		s++;
  801252:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801253:	8a 02                	mov    (%edx),%al
  801255:	3c 20                	cmp    $0x20,%al
  801257:	74 f9                	je     801252 <strtol+0xe>
  801259:	3c 09                	cmp    $0x9,%al
  80125b:	74 f5                	je     801252 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80125d:	3c 2b                	cmp    $0x2b,%al
  80125f:	75 08                	jne    801269 <strtol+0x25>
		s++;
  801261:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801262:	bf 00 00 00 00       	mov    $0x0,%edi
  801267:	eb 13                	jmp    80127c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801269:	3c 2d                	cmp    $0x2d,%al
  80126b:	75 0a                	jne    801277 <strtol+0x33>
		s++, neg = 1;
  80126d:	8d 52 01             	lea    0x1(%edx),%edx
  801270:	bf 01 00 00 00       	mov    $0x1,%edi
  801275:	eb 05                	jmp    80127c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801277:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80127c:	85 db                	test   %ebx,%ebx
  80127e:	74 05                	je     801285 <strtol+0x41>
  801280:	83 fb 10             	cmp    $0x10,%ebx
  801283:	75 28                	jne    8012ad <strtol+0x69>
  801285:	8a 02                	mov    (%edx),%al
  801287:	3c 30                	cmp    $0x30,%al
  801289:	75 10                	jne    80129b <strtol+0x57>
  80128b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80128f:	75 0a                	jne    80129b <strtol+0x57>
		s += 2, base = 16;
  801291:	83 c2 02             	add    $0x2,%edx
  801294:	bb 10 00 00 00       	mov    $0x10,%ebx
  801299:	eb 12                	jmp    8012ad <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80129b:	85 db                	test   %ebx,%ebx
  80129d:	75 0e                	jne    8012ad <strtol+0x69>
  80129f:	3c 30                	cmp    $0x30,%al
  8012a1:	75 05                	jne    8012a8 <strtol+0x64>
		s++, base = 8;
  8012a3:	42                   	inc    %edx
  8012a4:	b3 08                	mov    $0x8,%bl
  8012a6:	eb 05                	jmp    8012ad <strtol+0x69>
	else if (base == 0)
		base = 10;
  8012a8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8012ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8012b4:	8a 0a                	mov    (%edx),%cl
  8012b6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8012b9:	80 fb 09             	cmp    $0x9,%bl
  8012bc:	77 08                	ja     8012c6 <strtol+0x82>
			dig = *s - '0';
  8012be:	0f be c9             	movsbl %cl,%ecx
  8012c1:	83 e9 30             	sub    $0x30,%ecx
  8012c4:	eb 1e                	jmp    8012e4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8012c6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8012c9:	80 fb 19             	cmp    $0x19,%bl
  8012cc:	77 08                	ja     8012d6 <strtol+0x92>
			dig = *s - 'a' + 10;
  8012ce:	0f be c9             	movsbl %cl,%ecx
  8012d1:	83 e9 57             	sub    $0x57,%ecx
  8012d4:	eb 0e                	jmp    8012e4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8012d6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8012d9:	80 fb 19             	cmp    $0x19,%bl
  8012dc:	77 12                	ja     8012f0 <strtol+0xac>
			dig = *s - 'A' + 10;
  8012de:	0f be c9             	movsbl %cl,%ecx
  8012e1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8012e4:	39 f1                	cmp    %esi,%ecx
  8012e6:	7d 0c                	jge    8012f4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8012e8:	42                   	inc    %edx
  8012e9:	0f af c6             	imul   %esi,%eax
  8012ec:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8012ee:	eb c4                	jmp    8012b4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8012f0:	89 c1                	mov    %eax,%ecx
  8012f2:	eb 02                	jmp    8012f6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8012f4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8012f6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8012fa:	74 05                	je     801301 <strtol+0xbd>
		*endptr = (char *) s;
  8012fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012ff:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801301:	85 ff                	test   %edi,%edi
  801303:	74 04                	je     801309 <strtol+0xc5>
  801305:	89 c8                	mov    %ecx,%eax
  801307:	f7 d8                	neg    %eax
}
  801309:	5b                   	pop    %ebx
  80130a:	5e                   	pop    %esi
  80130b:	5f                   	pop    %edi
  80130c:	5d                   	pop    %ebp
  80130d:	c3                   	ret    
	...

00801310 <__udivdi3>:
  801310:	55                   	push   %ebp
  801311:	57                   	push   %edi
  801312:	56                   	push   %esi
  801313:	83 ec 10             	sub    $0x10,%esp
  801316:	8b 74 24 20          	mov    0x20(%esp),%esi
  80131a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80131e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801322:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801326:	89 cd                	mov    %ecx,%ebp
  801328:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  80132c:	85 c0                	test   %eax,%eax
  80132e:	75 2c                	jne    80135c <__udivdi3+0x4c>
  801330:	39 f9                	cmp    %edi,%ecx
  801332:	77 68                	ja     80139c <__udivdi3+0x8c>
  801334:	85 c9                	test   %ecx,%ecx
  801336:	75 0b                	jne    801343 <__udivdi3+0x33>
  801338:	b8 01 00 00 00       	mov    $0x1,%eax
  80133d:	31 d2                	xor    %edx,%edx
  80133f:	f7 f1                	div    %ecx
  801341:	89 c1                	mov    %eax,%ecx
  801343:	31 d2                	xor    %edx,%edx
  801345:	89 f8                	mov    %edi,%eax
  801347:	f7 f1                	div    %ecx
  801349:	89 c7                	mov    %eax,%edi
  80134b:	89 f0                	mov    %esi,%eax
  80134d:	f7 f1                	div    %ecx
  80134f:	89 c6                	mov    %eax,%esi
  801351:	89 f0                	mov    %esi,%eax
  801353:	89 fa                	mov    %edi,%edx
  801355:	83 c4 10             	add    $0x10,%esp
  801358:	5e                   	pop    %esi
  801359:	5f                   	pop    %edi
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    
  80135c:	39 f8                	cmp    %edi,%eax
  80135e:	77 2c                	ja     80138c <__udivdi3+0x7c>
  801360:	0f bd f0             	bsr    %eax,%esi
  801363:	83 f6 1f             	xor    $0x1f,%esi
  801366:	75 4c                	jne    8013b4 <__udivdi3+0xa4>
  801368:	39 f8                	cmp    %edi,%eax
  80136a:	bf 00 00 00 00       	mov    $0x0,%edi
  80136f:	72 0a                	jb     80137b <__udivdi3+0x6b>
  801371:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801375:	0f 87 ad 00 00 00    	ja     801428 <__udivdi3+0x118>
  80137b:	be 01 00 00 00       	mov    $0x1,%esi
  801380:	89 f0                	mov    %esi,%eax
  801382:	89 fa                	mov    %edi,%edx
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	5e                   	pop    %esi
  801388:	5f                   	pop    %edi
  801389:	5d                   	pop    %ebp
  80138a:	c3                   	ret    
  80138b:	90                   	nop
  80138c:	31 ff                	xor    %edi,%edi
  80138e:	31 f6                	xor    %esi,%esi
  801390:	89 f0                	mov    %esi,%eax
  801392:	89 fa                	mov    %edi,%edx
  801394:	83 c4 10             	add    $0x10,%esp
  801397:	5e                   	pop    %esi
  801398:	5f                   	pop    %edi
  801399:	5d                   	pop    %ebp
  80139a:	c3                   	ret    
  80139b:	90                   	nop
  80139c:	89 fa                	mov    %edi,%edx
  80139e:	89 f0                	mov    %esi,%eax
  8013a0:	f7 f1                	div    %ecx
  8013a2:	89 c6                	mov    %eax,%esi
  8013a4:	31 ff                	xor    %edi,%edi
  8013a6:	89 f0                	mov    %esi,%eax
  8013a8:	89 fa                	mov    %edi,%edx
  8013aa:	83 c4 10             	add    $0x10,%esp
  8013ad:	5e                   	pop    %esi
  8013ae:	5f                   	pop    %edi
  8013af:	5d                   	pop    %ebp
  8013b0:	c3                   	ret    
  8013b1:	8d 76 00             	lea    0x0(%esi),%esi
  8013b4:	89 f1                	mov    %esi,%ecx
  8013b6:	d3 e0                	shl    %cl,%eax
  8013b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013bc:	b8 20 00 00 00       	mov    $0x20,%eax
  8013c1:	29 f0                	sub    %esi,%eax
  8013c3:	89 ea                	mov    %ebp,%edx
  8013c5:	88 c1                	mov    %al,%cl
  8013c7:	d3 ea                	shr    %cl,%edx
  8013c9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8013cd:	09 ca                	or     %ecx,%edx
  8013cf:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013d3:	89 f1                	mov    %esi,%ecx
  8013d5:	d3 e5                	shl    %cl,%ebp
  8013d7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8013db:	89 fd                	mov    %edi,%ebp
  8013dd:	88 c1                	mov    %al,%cl
  8013df:	d3 ed                	shr    %cl,%ebp
  8013e1:	89 fa                	mov    %edi,%edx
  8013e3:	89 f1                	mov    %esi,%ecx
  8013e5:	d3 e2                	shl    %cl,%edx
  8013e7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013eb:	88 c1                	mov    %al,%cl
  8013ed:	d3 ef                	shr    %cl,%edi
  8013ef:	09 d7                	or     %edx,%edi
  8013f1:	89 f8                	mov    %edi,%eax
  8013f3:	89 ea                	mov    %ebp,%edx
  8013f5:	f7 74 24 08          	divl   0x8(%esp)
  8013f9:	89 d1                	mov    %edx,%ecx
  8013fb:	89 c7                	mov    %eax,%edi
  8013fd:	f7 64 24 0c          	mull   0xc(%esp)
  801401:	39 d1                	cmp    %edx,%ecx
  801403:	72 17                	jb     80141c <__udivdi3+0x10c>
  801405:	74 09                	je     801410 <__udivdi3+0x100>
  801407:	89 fe                	mov    %edi,%esi
  801409:	31 ff                	xor    %edi,%edi
  80140b:	e9 41 ff ff ff       	jmp    801351 <__udivdi3+0x41>
  801410:	8b 54 24 04          	mov    0x4(%esp),%edx
  801414:	89 f1                	mov    %esi,%ecx
  801416:	d3 e2                	shl    %cl,%edx
  801418:	39 c2                	cmp    %eax,%edx
  80141a:	73 eb                	jae    801407 <__udivdi3+0xf7>
  80141c:	8d 77 ff             	lea    -0x1(%edi),%esi
  80141f:	31 ff                	xor    %edi,%edi
  801421:	e9 2b ff ff ff       	jmp    801351 <__udivdi3+0x41>
  801426:	66 90                	xchg   %ax,%ax
  801428:	31 f6                	xor    %esi,%esi
  80142a:	e9 22 ff ff ff       	jmp    801351 <__udivdi3+0x41>
	...

00801430 <__umoddi3>:
  801430:	55                   	push   %ebp
  801431:	57                   	push   %edi
  801432:	56                   	push   %esi
  801433:	83 ec 20             	sub    $0x20,%esp
  801436:	8b 44 24 30          	mov    0x30(%esp),%eax
  80143a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80143e:	89 44 24 14          	mov    %eax,0x14(%esp)
  801442:	8b 74 24 34          	mov    0x34(%esp),%esi
  801446:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80144a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80144e:	89 c7                	mov    %eax,%edi
  801450:	89 f2                	mov    %esi,%edx
  801452:	85 ed                	test   %ebp,%ebp
  801454:	75 16                	jne    80146c <__umoddi3+0x3c>
  801456:	39 f1                	cmp    %esi,%ecx
  801458:	0f 86 a6 00 00 00    	jbe    801504 <__umoddi3+0xd4>
  80145e:	f7 f1                	div    %ecx
  801460:	89 d0                	mov    %edx,%eax
  801462:	31 d2                	xor    %edx,%edx
  801464:	83 c4 20             	add    $0x20,%esp
  801467:	5e                   	pop    %esi
  801468:	5f                   	pop    %edi
  801469:	5d                   	pop    %ebp
  80146a:	c3                   	ret    
  80146b:	90                   	nop
  80146c:	39 f5                	cmp    %esi,%ebp
  80146e:	0f 87 ac 00 00 00    	ja     801520 <__umoddi3+0xf0>
  801474:	0f bd c5             	bsr    %ebp,%eax
  801477:	83 f0 1f             	xor    $0x1f,%eax
  80147a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80147e:	0f 84 a8 00 00 00    	je     80152c <__umoddi3+0xfc>
  801484:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801488:	d3 e5                	shl    %cl,%ebp
  80148a:	bf 20 00 00 00       	mov    $0x20,%edi
  80148f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801493:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801497:	89 f9                	mov    %edi,%ecx
  801499:	d3 e8                	shr    %cl,%eax
  80149b:	09 e8                	or     %ebp,%eax
  80149d:	89 44 24 18          	mov    %eax,0x18(%esp)
  8014a1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014a5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014a9:	d3 e0                	shl    %cl,%eax
  8014ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014af:	89 f2                	mov    %esi,%edx
  8014b1:	d3 e2                	shl    %cl,%edx
  8014b3:	8b 44 24 14          	mov    0x14(%esp),%eax
  8014b7:	d3 e0                	shl    %cl,%eax
  8014b9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8014bd:	8b 44 24 14          	mov    0x14(%esp),%eax
  8014c1:	89 f9                	mov    %edi,%ecx
  8014c3:	d3 e8                	shr    %cl,%eax
  8014c5:	09 d0                	or     %edx,%eax
  8014c7:	d3 ee                	shr    %cl,%esi
  8014c9:	89 f2                	mov    %esi,%edx
  8014cb:	f7 74 24 18          	divl   0x18(%esp)
  8014cf:	89 d6                	mov    %edx,%esi
  8014d1:	f7 64 24 0c          	mull   0xc(%esp)
  8014d5:	89 c5                	mov    %eax,%ebp
  8014d7:	89 d1                	mov    %edx,%ecx
  8014d9:	39 d6                	cmp    %edx,%esi
  8014db:	72 67                	jb     801544 <__umoddi3+0x114>
  8014dd:	74 75                	je     801554 <__umoddi3+0x124>
  8014df:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8014e3:	29 e8                	sub    %ebp,%eax
  8014e5:	19 ce                	sbb    %ecx,%esi
  8014e7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014eb:	d3 e8                	shr    %cl,%eax
  8014ed:	89 f2                	mov    %esi,%edx
  8014ef:	89 f9                	mov    %edi,%ecx
  8014f1:	d3 e2                	shl    %cl,%edx
  8014f3:	09 d0                	or     %edx,%eax
  8014f5:	89 f2                	mov    %esi,%edx
  8014f7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014fb:	d3 ea                	shr    %cl,%edx
  8014fd:	83 c4 20             	add    $0x20,%esp
  801500:	5e                   	pop    %esi
  801501:	5f                   	pop    %edi
  801502:	5d                   	pop    %ebp
  801503:	c3                   	ret    
  801504:	85 c9                	test   %ecx,%ecx
  801506:	75 0b                	jne    801513 <__umoddi3+0xe3>
  801508:	b8 01 00 00 00       	mov    $0x1,%eax
  80150d:	31 d2                	xor    %edx,%edx
  80150f:	f7 f1                	div    %ecx
  801511:	89 c1                	mov    %eax,%ecx
  801513:	89 f0                	mov    %esi,%eax
  801515:	31 d2                	xor    %edx,%edx
  801517:	f7 f1                	div    %ecx
  801519:	89 f8                	mov    %edi,%eax
  80151b:	e9 3e ff ff ff       	jmp    80145e <__umoddi3+0x2e>
  801520:	89 f2                	mov    %esi,%edx
  801522:	83 c4 20             	add    $0x20,%esp
  801525:	5e                   	pop    %esi
  801526:	5f                   	pop    %edi
  801527:	5d                   	pop    %ebp
  801528:	c3                   	ret    
  801529:	8d 76 00             	lea    0x0(%esi),%esi
  80152c:	39 f5                	cmp    %esi,%ebp
  80152e:	72 04                	jb     801534 <__umoddi3+0x104>
  801530:	39 f9                	cmp    %edi,%ecx
  801532:	77 06                	ja     80153a <__umoddi3+0x10a>
  801534:	89 f2                	mov    %esi,%edx
  801536:	29 cf                	sub    %ecx,%edi
  801538:	19 ea                	sbb    %ebp,%edx
  80153a:	89 f8                	mov    %edi,%eax
  80153c:	83 c4 20             	add    $0x20,%esp
  80153f:	5e                   	pop    %esi
  801540:	5f                   	pop    %edi
  801541:	5d                   	pop    %ebp
  801542:	c3                   	ret    
  801543:	90                   	nop
  801544:	89 d1                	mov    %edx,%ecx
  801546:	89 c5                	mov    %eax,%ebp
  801548:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80154c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801550:	eb 8d                	jmp    8014df <__umoddi3+0xaf>
  801552:	66 90                	xchg   %ax,%ax
  801554:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801558:	72 ea                	jb     801544 <__umoddi3+0x114>
  80155a:	89 f1                	mov    %esi,%ecx
  80155c:	eb 81                	jmp    8014df <__umoddi3+0xaf>
