
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $3");
  800037:	cc                   	int3   
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    
	...

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	56                   	push   %esi
  800040:	53                   	push   %ebx
  800041:	83 ec 10             	sub    $0x10,%esp
  800044:	8b 75 08             	mov    0x8(%ebp),%esi
  800047:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80004a:	e8 e0 00 00 00       	call   80012f <sys_getenvid>
  80004f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800054:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800057:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80005a:	c1 e0 04             	shl    $0x4,%eax
  80005d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800062:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800067:	85 f6                	test   %esi,%esi
  800069:	7e 07                	jle    800072 <libmain+0x36>
		binaryname = argv[0];
  80006b:	8b 03                	mov    (%ebx),%eax
  80006d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800072:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800076:	89 34 24             	mov    %esi,(%esp)
  800079:	e8 b6 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007e:	e8 09 00 00 00       	call   80008c <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	5b                   	pop    %ebx
  800087:	5e                   	pop    %esi
  800088:	5d                   	pop    %ebp
  800089:	c3                   	ret    
	...

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800092:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800099:	e8 3f 00 00 00       	call   8000dd <sys_env_destroy>
}
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b1:	89 c3                	mov    %eax,%ebx
  8000b3:	89 c7                	mov    %eax,%edi
  8000b5:	89 c6                	mov    %eax,%esi
  8000b7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <sys_cgetc>:

int
sys_cgetc(void)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ce:	89 d1                	mov    %edx,%ecx
  8000d0:	89 d3                	mov    %edx,%ebx
  8000d2:	89 d7                	mov    %edx,%edi
  8000d4:	89 d6                	mov    %edx,%esi
  8000d6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d8:	5b                   	pop    %ebx
  8000d9:	5e                   	pop    %esi
  8000da:	5f                   	pop    %edi
  8000db:	5d                   	pop    %ebp
  8000dc:	c3                   	ret    

008000dd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dd:	55                   	push   %ebp
  8000de:	89 e5                	mov    %esp,%ebp
  8000e0:	57                   	push   %edi
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000eb:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f3:	89 cb                	mov    %ecx,%ebx
  8000f5:	89 cf                	mov    %ecx,%edi
  8000f7:	89 ce                	mov    %ecx,%esi
  8000f9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fb:	85 c0                	test   %eax,%eax
  8000fd:	7e 28                	jle    800127 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800103:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80010a:	00 
  80010b:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800112:	00 
  800113:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80011a:	00 
  80011b:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800122:	e8 e1 07 00 00       	call   800908 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800127:	83 c4 2c             	add    $0x2c,%esp
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	57                   	push   %edi
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800135:	ba 00 00 00 00       	mov    $0x0,%edx
  80013a:	b8 02 00 00 00       	mov    $0x2,%eax
  80013f:	89 d1                	mov    %edx,%ecx
  800141:	89 d3                	mov    %edx,%ebx
  800143:	89 d7                	mov    %edx,%edi
  800145:	89 d6                	mov    %edx,%esi
  800147:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5f                   	pop    %edi
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    

0080014e <sys_yield>:

void
sys_yield(void)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	57                   	push   %edi
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800154:	ba 00 00 00 00       	mov    $0x0,%edx
  800159:	b8 0a 00 00 00       	mov    $0xa,%eax
  80015e:	89 d1                	mov    %edx,%ecx
  800160:	89 d3                	mov    %edx,%ebx
  800162:	89 d7                	mov    %edx,%edi
  800164:	89 d6                	mov    %edx,%esi
  800166:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800168:	5b                   	pop    %ebx
  800169:	5e                   	pop    %esi
  80016a:	5f                   	pop    %edi
  80016b:	5d                   	pop    %ebp
  80016c:	c3                   	ret    

0080016d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	57                   	push   %edi
  800171:	56                   	push   %esi
  800172:	53                   	push   %ebx
  800173:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800176:	be 00 00 00 00       	mov    $0x0,%esi
  80017b:	b8 04 00 00 00       	mov    $0x4,%eax
  800180:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	89 f7                	mov    %esi,%edi
  80018b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80018d:	85 c0                	test   %eax,%eax
  80018f:	7e 28                	jle    8001b9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800191:	89 44 24 10          	mov    %eax,0x10(%esp)
  800195:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80019c:	00 
  80019d:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8001a4:	00 
  8001a5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001ac:	00 
  8001ad:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8001b4:	e8 4f 07 00 00       	call   800908 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b9:	83 c4 2c             	add    $0x2c,%esp
  8001bc:	5b                   	pop    %ebx
  8001bd:	5e                   	pop    %esi
  8001be:	5f                   	pop    %edi
  8001bf:	5d                   	pop    %ebp
  8001c0:	c3                   	ret    

008001c1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	57                   	push   %edi
  8001c5:	56                   	push   %esi
  8001c6:	53                   	push   %ebx
  8001c7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8001cf:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001db:	8b 55 08             	mov    0x8(%ebp),%edx
  8001de:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e0:	85 c0                	test   %eax,%eax
  8001e2:	7e 28                	jle    80020c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001e8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001ef:	00 
  8001f0:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8001f7:	00 
  8001f8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001ff:	00 
  800200:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800207:	e8 fc 06 00 00       	call   800908 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80020c:	83 c4 2c             	add    $0x2c,%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800222:	b8 06 00 00 00       	mov    $0x6,%eax
  800227:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022a:	8b 55 08             	mov    0x8(%ebp),%edx
  80022d:	89 df                	mov    %ebx,%edi
  80022f:	89 de                	mov    %ebx,%esi
  800231:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800233:	85 c0                	test   %eax,%eax
  800235:	7e 28                	jle    80025f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800237:	89 44 24 10          	mov    %eax,0x10(%esp)
  80023b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800242:	00 
  800243:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80024a:	00 
  80024b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800252:	00 
  800253:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80025a:	e8 a9 06 00 00       	call   800908 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80025f:	83 c4 2c             	add    $0x2c,%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	b8 08 00 00 00       	mov    $0x8,%eax
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 28                	jle    8002b2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80028e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800295:	00 
  800296:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80029d:	00 
  80029e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002a5:	00 
  8002a6:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8002ad:	e8 56 06 00 00       	call   800908 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002b2:	83 c4 2c             	add    $0x2c,%esp
  8002b5:	5b                   	pop    %ebx
  8002b6:	5e                   	pop    %esi
  8002b7:	5f                   	pop    %edi
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	57                   	push   %edi
  8002be:	56                   	push   %esi
  8002bf:	53                   	push   %ebx
  8002c0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c8:	b8 09 00 00 00       	mov    $0x9,%eax
  8002cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d3:	89 df                	mov    %ebx,%edi
  8002d5:	89 de                	mov    %ebx,%esi
  8002d7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d9:	85 c0                	test   %eax,%eax
  8002db:	7e 28                	jle    800305 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002e1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002e8:	00 
  8002e9:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8002f0:	00 
  8002f1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f8:	00 
  8002f9:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800300:	e8 03 06 00 00       	call   800908 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800305:	83 c4 2c             	add    $0x2c,%esp
  800308:	5b                   	pop    %ebx
  800309:	5e                   	pop    %esi
  80030a:	5f                   	pop    %edi
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	57                   	push   %edi
  800311:	56                   	push   %esi
  800312:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800313:	be 00 00 00 00       	mov    $0x0,%esi
  800318:	b8 0b 00 00 00       	mov    $0xb,%eax
  80031d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800320:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800323:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032b:	5b                   	pop    %ebx
  80032c:	5e                   	pop    %esi
  80032d:	5f                   	pop    %edi
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    

00800330 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	57                   	push   %edi
  800334:	56                   	push   %esi
  800335:	53                   	push   %ebx
  800336:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800339:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800343:	8b 55 08             	mov    0x8(%ebp),%edx
  800346:	89 cb                	mov    %ecx,%ebx
  800348:	89 cf                	mov    %ecx,%edi
  80034a:	89 ce                	mov    %ecx,%esi
  80034c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80034e:	85 c0                	test   %eax,%eax
  800350:	7e 28                	jle    80037a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800352:	89 44 24 10          	mov    %eax,0x10(%esp)
  800356:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80035d:	00 
  80035e:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800365:	00 
  800366:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80036d:	00 
  80036e:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800375:	e8 8e 05 00 00       	call   800908 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80037a:	83 c4 2c             	add    $0x2c,%esp
  80037d:	5b                   	pop    %ebx
  80037e:	5e                   	pop    %esi
  80037f:	5f                   	pop    %edi
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	57                   	push   %edi
  800386:	56                   	push   %esi
  800387:	53                   	push   %ebx
  800388:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80038b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800390:	b8 0d 00 00 00       	mov    $0xd,%eax
  800395:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800398:	8b 55 08             	mov    0x8(%ebp),%edx
  80039b:	89 df                	mov    %ebx,%edi
  80039d:	89 de                	mov    %ebx,%esi
  80039f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003a1:	85 c0                	test   %eax,%eax
  8003a3:	7e 28                	jle    8003cd <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003a9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003b0:	00 
  8003b1:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8003b8:	00 
  8003b9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003c0:	00 
  8003c1:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8003c8:	e8 3b 05 00 00       	call   800908 <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8003cd:	83 c4 2c             	add    $0x2c,%esp
  8003d0:	5b                   	pop    %ebx
  8003d1:	5e                   	pop    %esi
  8003d2:	5f                   	pop    %edi
  8003d3:	5d                   	pop    %ebp
  8003d4:	c3                   	ret    

008003d5 <sys_env_set_debug_upcall>:

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
  8003d5:	55                   	push   %ebp
  8003d6:	89 e5                	mov    %esp,%ebp
  8003d8:	57                   	push   %edi
  8003d9:	56                   	push   %esi
  8003da:	53                   	push   %ebx
  8003db:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003e3:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ee:	89 df                	mov    %ebx,%edi
  8003f0:	89 de                	mov    %ebx,%esi
  8003f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003f4:	85 c0                	test   %eax,%eax
  8003f6:	7e 28                	jle    800420 <sys_env_set_debug_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003f8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003fc:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800403:	00 
  800404:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80040b:	00 
  80040c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800413:	00 
  800414:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80041b:	e8 e8 04 00 00       	call   800908 <_panic>
}

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_debug_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800420:	83 c4 2c             	add    $0x2c,%esp
  800423:	5b                   	pop    %ebx
  800424:	5e                   	pop    %esi
  800425:	5f                   	pop    %edi
  800426:	5d                   	pop    %ebp
  800427:	c3                   	ret    

00800428 <sys_env_set_nmskint_upcall>:

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800431:	bb 00 00 00 00       	mov    $0x0,%ebx
  800436:	b8 0f 00 00 00       	mov    $0xf,%eax
  80043b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043e:	8b 55 08             	mov    0x8(%ebp),%edx
  800441:	89 df                	mov    %ebx,%edi
  800443:	89 de                	mov    %ebx,%esi
  800445:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800447:	85 c0                	test   %eax,%eax
  800449:	7e 28                	jle    800473 <sys_env_set_nmskint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80044b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80044f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800456:	00 
  800457:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80045e:	00 
  80045f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800466:	00 
  800467:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80046e:	e8 95 04 00 00       	call   800908 <_panic>
}

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_nmskint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800473:	83 c4 2c             	add    $0x2c,%esp
  800476:	5b                   	pop    %ebx
  800477:	5e                   	pop    %esi
  800478:	5f                   	pop    %edi
  800479:	5d                   	pop    %ebp
  80047a:	c3                   	ret    

0080047b <sys_env_set_bpoint_upcall>:

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
  80047b:	55                   	push   %ebp
  80047c:	89 e5                	mov    %esp,%ebp
  80047e:	57                   	push   %edi
  80047f:	56                   	push   %esi
  800480:	53                   	push   %ebx
  800481:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800484:	bb 00 00 00 00       	mov    $0x0,%ebx
  800489:	b8 10 00 00 00       	mov    $0x10,%eax
  80048e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800491:	8b 55 08             	mov    0x8(%ebp),%edx
  800494:	89 df                	mov    %ebx,%edi
  800496:	89 de                	mov    %ebx,%esi
  800498:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80049a:	85 c0                	test   %eax,%eax
  80049c:	7e 28                	jle    8004c6 <sys_env_set_bpoint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80049e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004a2:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  8004a9:	00 
  8004aa:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8004b1:	00 
  8004b2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004b9:	00 
  8004ba:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8004c1:	e8 42 04 00 00       	call   800908 <_panic>
}

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bpoint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8004c6:	83 c4 2c             	add    $0x2c,%esp
  8004c9:	5b                   	pop    %ebx
  8004ca:	5e                   	pop    %esi
  8004cb:	5f                   	pop    %edi
  8004cc:	5d                   	pop    %ebp
  8004cd:	c3                   	ret    

008004ce <sys_env_set_oflow_upcall>:

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
  8004ce:	55                   	push   %ebp
  8004cf:	89 e5                	mov    %esp,%ebp
  8004d1:	57                   	push   %edi
  8004d2:	56                   	push   %esi
  8004d3:	53                   	push   %ebx
  8004d4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004dc:	b8 11 00 00 00       	mov    $0x11,%eax
  8004e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004e7:	89 df                	mov    %ebx,%edi
  8004e9:	89 de                	mov    %ebx,%esi
  8004eb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8004ed:	85 c0                	test   %eax,%eax
  8004ef:	7e 28                	jle    800519 <sys_env_set_oflow_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004f1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004f5:	c7 44 24 0c 11 00 00 	movl   $0x11,0xc(%esp)
  8004fc:	00 
  8004fd:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800504:	00 
  800505:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80050c:	00 
  80050d:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800514:	e8 ef 03 00 00       	call   800908 <_panic>
}

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_oflow_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800519:	83 c4 2c             	add    $0x2c,%esp
  80051c:	5b                   	pop    %ebx
  80051d:	5e                   	pop    %esi
  80051e:	5f                   	pop    %edi
  80051f:	5d                   	pop    %ebp
  800520:	c3                   	ret    

00800521 <sys_env_set_bdschk_upcall>:

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
  800521:	55                   	push   %ebp
  800522:	89 e5                	mov    %esp,%ebp
  800524:	57                   	push   %edi
  800525:	56                   	push   %esi
  800526:	53                   	push   %ebx
  800527:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80052a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80052f:	b8 12 00 00 00       	mov    $0x12,%eax
  800534:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800537:	8b 55 08             	mov    0x8(%ebp),%edx
  80053a:	89 df                	mov    %ebx,%edi
  80053c:	89 de                	mov    %ebx,%esi
  80053e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800540:	85 c0                	test   %eax,%eax
  800542:	7e 28                	jle    80056c <sys_env_set_bdschk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800544:	89 44 24 10          	mov    %eax,0x10(%esp)
  800548:	c7 44 24 0c 12 00 00 	movl   $0x12,0xc(%esp)
  80054f:	00 
  800550:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800557:	00 
  800558:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80055f:	00 
  800560:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800567:	e8 9c 03 00 00       	call   800908 <_panic>
}

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bdschk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80056c:	83 c4 2c             	add    $0x2c,%esp
  80056f:	5b                   	pop    %ebx
  800570:	5e                   	pop    %esi
  800571:	5f                   	pop    %edi
  800572:	5d                   	pop    %ebp
  800573:	c3                   	ret    

00800574 <sys_env_set_illopcd_upcall>:

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
  800574:	55                   	push   %ebp
  800575:	89 e5                	mov    %esp,%ebp
  800577:	57                   	push   %edi
  800578:	56                   	push   %esi
  800579:	53                   	push   %ebx
  80057a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80057d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800582:	b8 13 00 00 00       	mov    $0x13,%eax
  800587:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80058a:	8b 55 08             	mov    0x8(%ebp),%edx
  80058d:	89 df                	mov    %ebx,%edi
  80058f:	89 de                	mov    %ebx,%esi
  800591:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800593:	85 c0                	test   %eax,%eax
  800595:	7e 28                	jle    8005bf <sys_env_set_illopcd_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800597:	89 44 24 10          	mov    %eax,0x10(%esp)
  80059b:	c7 44 24 0c 13 00 00 	movl   $0x13,0xc(%esp)
  8005a2:	00 
  8005a3:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8005aa:	00 
  8005ab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005b2:	00 
  8005b3:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8005ba:	e8 49 03 00 00       	call   800908 <_panic>
}

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_illopcd_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8005bf:	83 c4 2c             	add    $0x2c,%esp
  8005c2:	5b                   	pop    %ebx
  8005c3:	5e                   	pop    %esi
  8005c4:	5f                   	pop    %edi
  8005c5:	5d                   	pop    %ebp
  8005c6:	c3                   	ret    

008005c7 <sys_env_set_dvcntavl_upcall>:

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
  8005c7:	55                   	push   %ebp
  8005c8:	89 e5                	mov    %esp,%ebp
  8005ca:	57                   	push   %edi
  8005cb:	56                   	push   %esi
  8005cc:	53                   	push   %ebx
  8005cd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005d5:	b8 14 00 00 00       	mov    $0x14,%eax
  8005da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8005e0:	89 df                	mov    %ebx,%edi
  8005e2:	89 de                	mov    %ebx,%esi
  8005e4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005e6:	85 c0                	test   %eax,%eax
  8005e8:	7e 28                	jle    800612 <sys_env_set_dvcntavl_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005ea:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005ee:	c7 44 24 0c 14 00 00 	movl   $0x14,0xc(%esp)
  8005f5:	00 
  8005f6:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8005fd:	00 
  8005fe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800605:	00 
  800606:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80060d:	e8 f6 02 00 00       	call   800908 <_panic>
}

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dvcntavl_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800612:	83 c4 2c             	add    $0x2c,%esp
  800615:	5b                   	pop    %ebx
  800616:	5e                   	pop    %esi
  800617:	5f                   	pop    %edi
  800618:	5d                   	pop    %ebp
  800619:	c3                   	ret    

0080061a <sys_env_set_dbfault_upcall>:

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
  80061a:	55                   	push   %ebp
  80061b:	89 e5                	mov    %esp,%ebp
  80061d:	57                   	push   %edi
  80061e:	56                   	push   %esi
  80061f:	53                   	push   %ebx
  800620:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800623:	bb 00 00 00 00       	mov    $0x0,%ebx
  800628:	b8 15 00 00 00       	mov    $0x15,%eax
  80062d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800630:	8b 55 08             	mov    0x8(%ebp),%edx
  800633:	89 df                	mov    %ebx,%edi
  800635:	89 de                	mov    %ebx,%esi
  800637:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800639:	85 c0                	test   %eax,%eax
  80063b:	7e 28                	jle    800665 <sys_env_set_dbfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80063d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800641:	c7 44 24 0c 15 00 00 	movl   $0x15,0xc(%esp)
  800648:	00 
  800649:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800650:	00 
  800651:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800658:	00 
  800659:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800660:	e8 a3 02 00 00       	call   800908 <_panic>
}

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dbfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800665:	83 c4 2c             	add    $0x2c,%esp
  800668:	5b                   	pop    %ebx
  800669:	5e                   	pop    %esi
  80066a:	5f                   	pop    %edi
  80066b:	5d                   	pop    %ebp
  80066c:	c3                   	ret    

0080066d <sys_env_set_ivldtss_upcall>:

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
  80066d:	55                   	push   %ebp
  80066e:	89 e5                	mov    %esp,%ebp
  800670:	57                   	push   %edi
  800671:	56                   	push   %esi
  800672:	53                   	push   %ebx
  800673:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800676:	bb 00 00 00 00       	mov    $0x0,%ebx
  80067b:	b8 16 00 00 00       	mov    $0x16,%eax
  800680:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800683:	8b 55 08             	mov    0x8(%ebp),%edx
  800686:	89 df                	mov    %ebx,%edi
  800688:	89 de                	mov    %ebx,%esi
  80068a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80068c:	85 c0                	test   %eax,%eax
  80068e:	7e 28                	jle    8006b8 <sys_env_set_ivldtss_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800690:	89 44 24 10          	mov    %eax,0x10(%esp)
  800694:	c7 44 24 0c 16 00 00 	movl   $0x16,0xc(%esp)
  80069b:	00 
  80069c:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8006a3:	00 
  8006a4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006ab:	00 
  8006ac:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8006b3:	e8 50 02 00 00       	call   800908 <_panic>
}

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_ivldtss_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8006b8:	83 c4 2c             	add    $0x2c,%esp
  8006bb:	5b                   	pop    %ebx
  8006bc:	5e                   	pop    %esi
  8006bd:	5f                   	pop    %edi
  8006be:	5d                   	pop    %ebp
  8006bf:	c3                   	ret    

008006c0 <sys_env_set_segntprst_upcall>:

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	57                   	push   %edi
  8006c4:	56                   	push   %esi
  8006c5:	53                   	push   %ebx
  8006c6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ce:	b8 17 00 00 00       	mov    $0x17,%eax
  8006d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d9:	89 df                	mov    %ebx,%edi
  8006db:	89 de                	mov    %ebx,%esi
  8006dd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006df:	85 c0                	test   %eax,%eax
  8006e1:	7e 28                	jle    80070b <sys_env_set_segntprst_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006e3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006e7:	c7 44 24 0c 17 00 00 	movl   $0x17,0xc(%esp)
  8006ee:	00 
  8006ef:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8006f6:	00 
  8006f7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006fe:	00 
  8006ff:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800706:	e8 fd 01 00 00       	call   800908 <_panic>
}

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_segntprst_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80070b:	83 c4 2c             	add    $0x2c,%esp
  80070e:	5b                   	pop    %ebx
  80070f:	5e                   	pop    %esi
  800710:	5f                   	pop    %edi
  800711:	5d                   	pop    %ebp
  800712:	c3                   	ret    

00800713 <sys_env_set_stkexception_upcall>:

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	57                   	push   %edi
  800717:	56                   	push   %esi
  800718:	53                   	push   %ebx
  800719:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80071c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800721:	b8 18 00 00 00       	mov    $0x18,%eax
  800726:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800729:	8b 55 08             	mov    0x8(%ebp),%edx
  80072c:	89 df                	mov    %ebx,%edi
  80072e:	89 de                	mov    %ebx,%esi
  800730:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800732:	85 c0                	test   %eax,%eax
  800734:	7e 28                	jle    80075e <sys_env_set_stkexception_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800736:	89 44 24 10          	mov    %eax,0x10(%esp)
  80073a:	c7 44 24 0c 18 00 00 	movl   $0x18,0xc(%esp)
  800741:	00 
  800742:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800749:	00 
  80074a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800751:	00 
  800752:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800759:	e8 aa 01 00 00       	call   800908 <_panic>
}

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_stkexception_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80075e:	83 c4 2c             	add    $0x2c,%esp
  800761:	5b                   	pop    %ebx
  800762:	5e                   	pop    %esi
  800763:	5f                   	pop    %edi
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <sys_env_set_gpfault_upcall>:

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	57                   	push   %edi
  80076a:	56                   	push   %esi
  80076b:	53                   	push   %ebx
  80076c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80076f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800774:	b8 19 00 00 00       	mov    $0x19,%eax
  800779:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077c:	8b 55 08             	mov    0x8(%ebp),%edx
  80077f:	89 df                	mov    %ebx,%edi
  800781:	89 de                	mov    %ebx,%esi
  800783:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800785:	85 c0                	test   %eax,%eax
  800787:	7e 28                	jle    8007b1 <sys_env_set_gpfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800789:	89 44 24 10          	mov    %eax,0x10(%esp)
  80078d:	c7 44 24 0c 19 00 00 	movl   $0x19,0xc(%esp)
  800794:	00 
  800795:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80079c:	00 
  80079d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8007a4:	00 
  8007a5:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8007ac:	e8 57 01 00 00       	call   800908 <_panic>
}

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_gpfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8007b1:	83 c4 2c             	add    $0x2c,%esp
  8007b4:	5b                   	pop    %ebx
  8007b5:	5e                   	pop    %esi
  8007b6:	5f                   	pop    %edi
  8007b7:	5d                   	pop    %ebp
  8007b8:	c3                   	ret    

008007b9 <sys_env_set_fperror_upcall>:

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	57                   	push   %edi
  8007bd:	56                   	push   %esi
  8007be:	53                   	push   %ebx
  8007bf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007c7:	b8 1a 00 00 00       	mov    $0x1a,%eax
  8007cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8007d2:	89 df                	mov    %ebx,%edi
  8007d4:	89 de                	mov    %ebx,%esi
  8007d6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	7e 28                	jle    800804 <sys_env_set_fperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007dc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007e0:	c7 44 24 0c 1a 00 00 	movl   $0x1a,0xc(%esp)
  8007e7:	00 
  8007e8:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8007ef:	00 
  8007f0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8007f7:	00 
  8007f8:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8007ff:	e8 04 01 00 00       	call   800908 <_panic>
}

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_fperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800804:	83 c4 2c             	add    $0x2c,%esp
  800807:	5b                   	pop    %ebx
  800808:	5e                   	pop    %esi
  800809:	5f                   	pop    %edi
  80080a:	5d                   	pop    %ebp
  80080b:	c3                   	ret    

0080080c <sys_env_set_algchk_upcall>:

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	57                   	push   %edi
  800810:	56                   	push   %esi
  800811:	53                   	push   %ebx
  800812:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800815:	bb 00 00 00 00       	mov    $0x0,%ebx
  80081a:	b8 1b 00 00 00       	mov    $0x1b,%eax
  80081f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800822:	8b 55 08             	mov    0x8(%ebp),%edx
  800825:	89 df                	mov    %ebx,%edi
  800827:	89 de                	mov    %ebx,%esi
  800829:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80082b:	85 c0                	test   %eax,%eax
  80082d:	7e 28                	jle    800857 <sys_env_set_algchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80082f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800833:	c7 44 24 0c 1b 00 00 	movl   $0x1b,0xc(%esp)
  80083a:	00 
  80083b:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800842:	00 
  800843:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80084a:	00 
  80084b:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800852:	e8 b1 00 00 00       	call   800908 <_panic>
}

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_algchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800857:	83 c4 2c             	add    $0x2c,%esp
  80085a:	5b                   	pop    %ebx
  80085b:	5e                   	pop    %esi
  80085c:	5f                   	pop    %edi
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <sys_env_set_mchchk_upcall>:

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	57                   	push   %edi
  800863:	56                   	push   %esi
  800864:	53                   	push   %ebx
  800865:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800868:	bb 00 00 00 00       	mov    $0x0,%ebx
  80086d:	b8 1c 00 00 00       	mov    $0x1c,%eax
  800872:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800875:	8b 55 08             	mov    0x8(%ebp),%edx
  800878:	89 df                	mov    %ebx,%edi
  80087a:	89 de                	mov    %ebx,%esi
  80087c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80087e:	85 c0                	test   %eax,%eax
  800880:	7e 28                	jle    8008aa <sys_env_set_mchchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800882:	89 44 24 10          	mov    %eax,0x10(%esp)
  800886:	c7 44 24 0c 1c 00 00 	movl   $0x1c,0xc(%esp)
  80088d:	00 
  80088e:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800895:	00 
  800896:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80089d:	00 
  80089e:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8008a5:	e8 5e 00 00 00       	call   800908 <_panic>
}

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_mchchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8008aa:	83 c4 2c             	add    $0x2c,%esp
  8008ad:	5b                   	pop    %ebx
  8008ae:	5e                   	pop    %esi
  8008af:	5f                   	pop    %edi
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <sys_env_set_SIMDfperror_upcall>:

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	57                   	push   %edi
  8008b6:	56                   	push   %esi
  8008b7:	53                   	push   %ebx
  8008b8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8008bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008c0:	b8 1d 00 00 00       	mov    $0x1d,%eax
  8008c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8008cb:	89 df                	mov    %ebx,%edi
  8008cd:	89 de                	mov    %ebx,%esi
  8008cf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8008d1:	85 c0                	test   %eax,%eax
  8008d3:	7e 28                	jle    8008fd <sys_env_set_SIMDfperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8008d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8008d9:	c7 44 24 0c 1d 00 00 	movl   $0x1d,0xc(%esp)
  8008e0:	00 
  8008e1:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8008e8:	00 
  8008e9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8008f0:	00 
  8008f1:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8008f8:	e8 0b 00 00 00       	call   800908 <_panic>
}

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_SIMDfperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8008fd:	83 c4 2c             	add    $0x2c,%esp
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5f                   	pop    %edi
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    
  800905:	00 00                	add    %al,(%eax)
	...

00800908 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	56                   	push   %esi
  80090c:	53                   	push   %ebx
  80090d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800910:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800913:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800919:	e8 11 f8 ff ff       	call   80012f <sys_getenvid>
  80091e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800921:	89 54 24 10          	mov    %edx,0x10(%esp)
  800925:	8b 55 08             	mov    0x8(%ebp),%edx
  800928:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80092c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800930:	89 44 24 04          	mov    %eax,0x4(%esp)
  800934:	c7 04 24 78 15 80 00 	movl   $0x801578,(%esp)
  80093b:	e8 c0 00 00 00       	call   800a00 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800940:	89 74 24 04          	mov    %esi,0x4(%esp)
  800944:	8b 45 10             	mov    0x10(%ebp),%eax
  800947:	89 04 24             	mov    %eax,(%esp)
  80094a:	e8 50 00 00 00       	call   80099f <vcprintf>
	cprintf("\n");
  80094f:	c7 04 24 9c 15 80 00 	movl   $0x80159c,(%esp)
  800956:	e8 a5 00 00 00       	call   800a00 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80095b:	cc                   	int3   
  80095c:	eb fd                	jmp    80095b <_panic+0x53>
	...

00800960 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	53                   	push   %ebx
  800964:	83 ec 14             	sub    $0x14,%esp
  800967:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80096a:	8b 03                	mov    (%ebx),%eax
  80096c:	8b 55 08             	mov    0x8(%ebp),%edx
  80096f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800973:	40                   	inc    %eax
  800974:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800976:	3d ff 00 00 00       	cmp    $0xff,%eax
  80097b:	75 19                	jne    800996 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80097d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800984:	00 
  800985:	8d 43 08             	lea    0x8(%ebx),%eax
  800988:	89 04 24             	mov    %eax,(%esp)
  80098b:	e8 10 f7 ff ff       	call   8000a0 <sys_cputs>
		b->idx = 0;
  800990:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800996:	ff 43 04             	incl   0x4(%ebx)
}
  800999:	83 c4 14             	add    $0x14,%esp
  80099c:	5b                   	pop    %ebx
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8009a8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8009af:	00 00 00 
	b.cnt = 0;
  8009b2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8009b9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8009bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8009d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d4:	c7 04 24 60 09 80 00 	movl   $0x800960,(%esp)
  8009db:	e8 b4 01 00 00       	call   800b94 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8009e0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8009e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ea:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8009f0:	89 04 24             	mov    %eax,(%esp)
  8009f3:	e8 a8 f6 ff ff       	call   8000a0 <sys_cputs>

	return b.cnt;
}
  8009f8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800a06:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800a09:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	89 04 24             	mov    %eax,(%esp)
  800a13:	e8 87 ff ff ff       	call   80099f <vcprintf>
	va_end(ap);

	return cnt;
}
  800a18:	c9                   	leave  
  800a19:	c3                   	ret    
	...

00800a1c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	57                   	push   %edi
  800a20:	56                   	push   %esi
  800a21:	53                   	push   %ebx
  800a22:	83 ec 3c             	sub    $0x3c,%esp
  800a25:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a28:	89 d7                	mov    %edx,%edi
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a33:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a36:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800a39:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800a3c:	85 c0                	test   %eax,%eax
  800a3e:	75 08                	jne    800a48 <printnum+0x2c>
  800a40:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a43:	39 45 10             	cmp    %eax,0x10(%ebp)
  800a46:	77 57                	ja     800a9f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800a48:	89 74 24 10          	mov    %esi,0x10(%esp)
  800a4c:	4b                   	dec    %ebx
  800a4d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800a51:	8b 45 10             	mov    0x10(%ebp),%eax
  800a54:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a58:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800a5c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800a60:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a67:	00 
  800a68:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a6b:	89 04 24             	mov    %eax,(%esp)
  800a6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a75:	e8 5a 08 00 00       	call   8012d4 <__udivdi3>
  800a7a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a7e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a82:	89 04 24             	mov    %eax,(%esp)
  800a85:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a89:	89 fa                	mov    %edi,%edx
  800a8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a8e:	e8 89 ff ff ff       	call   800a1c <printnum>
  800a93:	eb 0f                	jmp    800aa4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800a95:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a99:	89 34 24             	mov    %esi,(%esp)
  800a9c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800a9f:	4b                   	dec    %ebx
  800aa0:	85 db                	test   %ebx,%ebx
  800aa2:	7f f1                	jg     800a95 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800aa4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aa8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800aac:	8b 45 10             	mov    0x10(%ebp),%eax
  800aaf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800aba:	00 
  800abb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800abe:	89 04 24             	mov    %eax,(%esp)
  800ac1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ac4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac8:	e8 27 09 00 00       	call   8013f4 <__umoddi3>
  800acd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ad1:	0f be 80 9e 15 80 00 	movsbl 0x80159e(%eax),%eax
  800ad8:	89 04 24             	mov    %eax,(%esp)
  800adb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800ade:	83 c4 3c             	add    $0x3c,%esp
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800ae9:	83 fa 01             	cmp    $0x1,%edx
  800aec:	7e 0e                	jle    800afc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800aee:	8b 10                	mov    (%eax),%edx
  800af0:	8d 4a 08             	lea    0x8(%edx),%ecx
  800af3:	89 08                	mov    %ecx,(%eax)
  800af5:	8b 02                	mov    (%edx),%eax
  800af7:	8b 52 04             	mov    0x4(%edx),%edx
  800afa:	eb 22                	jmp    800b1e <getuint+0x38>
	else if (lflag)
  800afc:	85 d2                	test   %edx,%edx
  800afe:	74 10                	je     800b10 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800b00:	8b 10                	mov    (%eax),%edx
  800b02:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b05:	89 08                	mov    %ecx,(%eax)
  800b07:	8b 02                	mov    (%edx),%eax
  800b09:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0e:	eb 0e                	jmp    800b1e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800b10:	8b 10                	mov    (%eax),%edx
  800b12:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b15:	89 08                	mov    %ecx,(%eax)
  800b17:	8b 02                	mov    (%edx),%eax
  800b19:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800b23:	83 fa 01             	cmp    $0x1,%edx
  800b26:	7e 0e                	jle    800b36 <getint+0x16>
		return va_arg(*ap, long long);
  800b28:	8b 10                	mov    (%eax),%edx
  800b2a:	8d 4a 08             	lea    0x8(%edx),%ecx
  800b2d:	89 08                	mov    %ecx,(%eax)
  800b2f:	8b 02                	mov    (%edx),%eax
  800b31:	8b 52 04             	mov    0x4(%edx),%edx
  800b34:	eb 1a                	jmp    800b50 <getint+0x30>
	else if (lflag)
  800b36:	85 d2                	test   %edx,%edx
  800b38:	74 0c                	je     800b46 <getint+0x26>
		return va_arg(*ap, long);
  800b3a:	8b 10                	mov    (%eax),%edx
  800b3c:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b3f:	89 08                	mov    %ecx,(%eax)
  800b41:	8b 02                	mov    (%edx),%eax
  800b43:	99                   	cltd   
  800b44:	eb 0a                	jmp    800b50 <getint+0x30>
	else
		return va_arg(*ap, int);
  800b46:	8b 10                	mov    (%eax),%edx
  800b48:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b4b:	89 08                	mov    %ecx,(%eax)
  800b4d:	8b 02                	mov    (%edx),%eax
  800b4f:	99                   	cltd   
}
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800b58:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800b5b:	8b 10                	mov    (%eax),%edx
  800b5d:	3b 50 04             	cmp    0x4(%eax),%edx
  800b60:	73 08                	jae    800b6a <sprintputch+0x18>
		*b->buf++ = ch;
  800b62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b65:	88 0a                	mov    %cl,(%edx)
  800b67:	42                   	inc    %edx
  800b68:	89 10                	mov    %edx,(%eax)
}
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800b72:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800b75:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b79:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b83:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b87:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8a:	89 04 24             	mov    %eax,(%esp)
  800b8d:	e8 02 00 00 00       	call   800b94 <vprintfmt>
	va_end(ap);
}
  800b92:	c9                   	leave  
  800b93:	c3                   	ret    

00800b94 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
  800b9a:	83 ec 4c             	sub    $0x4c,%esp
  800b9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ba0:	8b 75 10             	mov    0x10(%ebp),%esi
  800ba3:	eb 12                	jmp    800bb7 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800ba5:	85 c0                	test   %eax,%eax
  800ba7:	0f 84 40 03 00 00    	je     800eed <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800bad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bb1:	89 04 24             	mov    %eax,(%esp)
  800bb4:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800bb7:	0f b6 06             	movzbl (%esi),%eax
  800bba:	46                   	inc    %esi
  800bbb:	83 f8 25             	cmp    $0x25,%eax
  800bbe:	75 e5                	jne    800ba5 <vprintfmt+0x11>
  800bc0:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800bc4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800bcb:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800bd0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800bd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdc:	eb 26                	jmp    800c04 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bde:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800be1:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800be5:	eb 1d                	jmp    800c04 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800be7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800bea:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800bee:	eb 14                	jmp    800c04 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bf0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800bf3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800bfa:	eb 08                	jmp    800c04 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800bfc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800bff:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c04:	0f b6 06             	movzbl (%esi),%eax
  800c07:	8d 4e 01             	lea    0x1(%esi),%ecx
  800c0a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800c0d:	8a 0e                	mov    (%esi),%cl
  800c0f:	83 e9 23             	sub    $0x23,%ecx
  800c12:	80 f9 55             	cmp    $0x55,%cl
  800c15:	0f 87 b6 02 00 00    	ja     800ed1 <vprintfmt+0x33d>
  800c1b:	0f b6 c9             	movzbl %cl,%ecx
  800c1e:	ff 24 8d 60 16 80 00 	jmp    *0x801660(,%ecx,4)
  800c25:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c28:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800c2d:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800c30:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  800c34:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800c37:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800c3a:	83 f9 09             	cmp    $0x9,%ecx
  800c3d:	77 2a                	ja     800c69 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c3f:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800c40:	eb eb                	jmp    800c2d <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800c42:	8b 45 14             	mov    0x14(%ebp),%eax
  800c45:	8d 48 04             	lea    0x4(%eax),%ecx
  800c48:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800c4b:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c4d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800c50:	eb 17                	jmp    800c69 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800c52:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c56:	78 98                	js     800bf0 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c58:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c5b:	eb a7                	jmp    800c04 <vprintfmt+0x70>
  800c5d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800c60:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800c67:	eb 9b                	jmp    800c04 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800c69:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c6d:	79 95                	jns    800c04 <vprintfmt+0x70>
  800c6f:	eb 8b                	jmp    800bfc <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800c71:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c72:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800c75:	eb 8d                	jmp    800c04 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800c77:	8b 45 14             	mov    0x14(%ebp),%eax
  800c7a:	8d 50 04             	lea    0x4(%eax),%edx
  800c7d:	89 55 14             	mov    %edx,0x14(%ebp)
  800c80:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c84:	8b 00                	mov    (%eax),%eax
  800c86:	89 04 24             	mov    %eax,(%esp)
  800c89:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c8c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800c8f:	e9 23 ff ff ff       	jmp    800bb7 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800c94:	8b 45 14             	mov    0x14(%ebp),%eax
  800c97:	8d 50 04             	lea    0x4(%eax),%edx
  800c9a:	89 55 14             	mov    %edx,0x14(%ebp)
  800c9d:	8b 00                	mov    (%eax),%eax
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	79 02                	jns    800ca5 <vprintfmt+0x111>
  800ca3:	f7 d8                	neg    %eax
  800ca5:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800ca7:	83 f8 09             	cmp    $0x9,%eax
  800caa:	7f 0b                	jg     800cb7 <vprintfmt+0x123>
  800cac:	8b 04 85 c0 17 80 00 	mov    0x8017c0(,%eax,4),%eax
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	75 23                	jne    800cda <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800cb7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cbb:	c7 44 24 08 b6 15 80 	movl   $0x8015b6,0x8(%esp)
  800cc2:	00 
  800cc3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cca:	89 04 24             	mov    %eax,(%esp)
  800ccd:	e8 9a fe ff ff       	call   800b6c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cd2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800cd5:	e9 dd fe ff ff       	jmp    800bb7 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800cda:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cde:	c7 44 24 08 bf 15 80 	movl   $0x8015bf,0x8(%esp)
  800ce5:	00 
  800ce6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ced:	89 14 24             	mov    %edx,(%esp)
  800cf0:	e8 77 fe ff ff       	call   800b6c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cf5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800cf8:	e9 ba fe ff ff       	jmp    800bb7 <vprintfmt+0x23>
  800cfd:	89 f9                	mov    %edi,%ecx
  800cff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d02:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d05:	8b 45 14             	mov    0x14(%ebp),%eax
  800d08:	8d 50 04             	lea    0x4(%eax),%edx
  800d0b:	89 55 14             	mov    %edx,0x14(%ebp)
  800d0e:	8b 30                	mov    (%eax),%esi
  800d10:	85 f6                	test   %esi,%esi
  800d12:	75 05                	jne    800d19 <vprintfmt+0x185>
				p = "(null)";
  800d14:	be af 15 80 00       	mov    $0x8015af,%esi
			if (width > 0 && padc != '-')
  800d19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800d1d:	0f 8e 84 00 00 00    	jle    800da7 <vprintfmt+0x213>
  800d23:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800d27:	74 7e                	je     800da7 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800d29:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d2d:	89 34 24             	mov    %esi,(%esp)
  800d30:	e8 5d 02 00 00       	call   800f92 <strnlen>
  800d35:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800d38:	29 c2                	sub    %eax,%edx
  800d3a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800d3d:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800d41:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800d44:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800d47:	89 de                	mov    %ebx,%esi
  800d49:	89 d3                	mov    %edx,%ebx
  800d4b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d4d:	eb 0b                	jmp    800d5a <vprintfmt+0x1c6>
					putch(padc, putdat);
  800d4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d53:	89 3c 24             	mov    %edi,(%esp)
  800d56:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d59:	4b                   	dec    %ebx
  800d5a:	85 db                	test   %ebx,%ebx
  800d5c:	7f f1                	jg     800d4f <vprintfmt+0x1bb>
  800d5e:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800d61:	89 f3                	mov    %esi,%ebx
  800d63:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800d66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	79 05                	jns    800d72 <vprintfmt+0x1de>
  800d6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d72:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d75:	29 c2                	sub    %eax,%edx
  800d77:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800d7a:	eb 2b                	jmp    800da7 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800d7c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800d80:	74 18                	je     800d9a <vprintfmt+0x206>
  800d82:	8d 50 e0             	lea    -0x20(%eax),%edx
  800d85:	83 fa 5e             	cmp    $0x5e,%edx
  800d88:	76 10                	jbe    800d9a <vprintfmt+0x206>
					putch('?', putdat);
  800d8a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d8e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800d95:	ff 55 08             	call   *0x8(%ebp)
  800d98:	eb 0a                	jmp    800da4 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800d9a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d9e:	89 04 24             	mov    %eax,(%esp)
  800da1:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800da4:	ff 4d e4             	decl   -0x1c(%ebp)
  800da7:	0f be 06             	movsbl (%esi),%eax
  800daa:	46                   	inc    %esi
  800dab:	85 c0                	test   %eax,%eax
  800dad:	74 21                	je     800dd0 <vprintfmt+0x23c>
  800daf:	85 ff                	test   %edi,%edi
  800db1:	78 c9                	js     800d7c <vprintfmt+0x1e8>
  800db3:	4f                   	dec    %edi
  800db4:	79 c6                	jns    800d7c <vprintfmt+0x1e8>
  800db6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800db9:	89 de                	mov    %ebx,%esi
  800dbb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800dbe:	eb 18                	jmp    800dd8 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800dc0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dc4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800dcb:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800dcd:	4b                   	dec    %ebx
  800dce:	eb 08                	jmp    800dd8 <vprintfmt+0x244>
  800dd0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dd3:	89 de                	mov    %ebx,%esi
  800dd5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800dd8:	85 db                	test   %ebx,%ebx
  800dda:	7f e4                	jg     800dc0 <vprintfmt+0x22c>
  800ddc:	89 7d 08             	mov    %edi,0x8(%ebp)
  800ddf:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800de1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800de4:	e9 ce fd ff ff       	jmp    800bb7 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800de9:	8d 45 14             	lea    0x14(%ebp),%eax
  800dec:	e8 2f fd ff ff       	call   800b20 <getint>
  800df1:	89 c6                	mov    %eax,%esi
  800df3:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800df5:	85 d2                	test   %edx,%edx
  800df7:	78 07                	js     800e00 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800df9:	be 0a 00 00 00       	mov    $0xa,%esi
  800dfe:	eb 7e                	jmp    800e7e <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800e00:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e04:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800e0b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800e0e:	89 f0                	mov    %esi,%eax
  800e10:	89 fa                	mov    %edi,%edx
  800e12:	f7 d8                	neg    %eax
  800e14:	83 d2 00             	adc    $0x0,%edx
  800e17:	f7 da                	neg    %edx
			}
			base = 10;
  800e19:	be 0a 00 00 00       	mov    $0xa,%esi
  800e1e:	eb 5e                	jmp    800e7e <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800e20:	8d 45 14             	lea    0x14(%ebp),%eax
  800e23:	e8 be fc ff ff       	call   800ae6 <getuint>
			base = 10;
  800e28:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800e2d:	eb 4f                	jmp    800e7e <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800e2f:	8d 45 14             	lea    0x14(%ebp),%eax
  800e32:	e8 af fc ff ff       	call   800ae6 <getuint>
			base = 8;
  800e37:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800e3c:	eb 40                	jmp    800e7e <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  800e3e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e42:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800e49:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800e4c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e50:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800e57:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800e5a:	8b 45 14             	mov    0x14(%ebp),%eax
  800e5d:	8d 50 04             	lea    0x4(%eax),%edx
  800e60:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800e63:	8b 00                	mov    (%eax),%eax
  800e65:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800e6a:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800e6f:	eb 0d                	jmp    800e7e <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800e71:	8d 45 14             	lea    0x14(%ebp),%eax
  800e74:	e8 6d fc ff ff       	call   800ae6 <getuint>
			base = 16;
  800e79:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800e7e:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800e82:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800e86:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800e89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e8d:	89 74 24 08          	mov    %esi,0x8(%esp)
  800e91:	89 04 24             	mov    %eax,(%esp)
  800e94:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e98:	89 da                	mov    %ebx,%edx
  800e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9d:	e8 7a fb ff ff       	call   800a1c <printnum>
			break;
  800ea2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ea5:	e9 0d fd ff ff       	jmp    800bb7 <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  800eaa:	8d 45 14             	lea    0x14(%ebp),%eax
  800ead:	e8 6e fc ff ff       	call   800b20 <getint>
  800eb2:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800eb7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  800eba:	e9 f8 fc ff ff       	jmp    800bb7 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ebf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ec3:	89 04 24             	mov    %eax,(%esp)
  800ec6:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ec9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ecc:	e9 e6 fc ff ff       	jmp    800bb7 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ed1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ed5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800edc:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800edf:	eb 01                	jmp    800ee2 <vprintfmt+0x34e>
  800ee1:	4e                   	dec    %esi
  800ee2:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800ee6:	75 f9                	jne    800ee1 <vprintfmt+0x34d>
  800ee8:	e9 ca fc ff ff       	jmp    800bb7 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800eed:	83 c4 4c             	add    $0x4c,%esp
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	83 ec 28             	sub    $0x28,%esp
  800efb:	8b 45 08             	mov    0x8(%ebp),%eax
  800efe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800f01:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f04:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800f08:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f0b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800f12:	85 c0                	test   %eax,%eax
  800f14:	74 30                	je     800f46 <vsnprintf+0x51>
  800f16:	85 d2                	test   %edx,%edx
  800f18:	7e 33                	jle    800f4d <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f1a:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f21:	8b 45 10             	mov    0x10(%ebp),%eax
  800f24:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f28:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f2f:	c7 04 24 52 0b 80 00 	movl   $0x800b52,(%esp)
  800f36:	e8 59 fc ff ff       	call   800b94 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f3e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f44:	eb 0c                	jmp    800f52 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800f46:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f4b:	eb 05                	jmp    800f52 <vsnprintf+0x5d>
  800f4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800f52:	c9                   	leave  
  800f53:	c3                   	ret    

00800f54 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800f5a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800f5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f61:	8b 45 10             	mov    0x10(%ebp),%eax
  800f64:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f72:	89 04 24             	mov    %eax,(%esp)
  800f75:	e8 7b ff ff ff       	call   800ef5 <vsnprintf>
	va_end(ap);

	return rc;
}
  800f7a:	c9                   	leave  
  800f7b:	c3                   	ret    

00800f7c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800f82:	b8 00 00 00 00       	mov    $0x0,%eax
  800f87:	eb 01                	jmp    800f8a <strlen+0xe>
		n++;
  800f89:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800f8a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800f8e:	75 f9                	jne    800f89 <strlen+0xd>
		n++;
	return n;
}
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    

00800f92 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800f98:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa0:	eb 01                	jmp    800fa3 <strnlen+0x11>
		n++;
  800fa2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fa3:	39 d0                	cmp    %edx,%eax
  800fa5:	74 06                	je     800fad <strnlen+0x1b>
  800fa7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800fab:	75 f5                	jne    800fa2 <strnlen+0x10>
		n++;
	return n;
}
  800fad:	5d                   	pop    %ebp
  800fae:	c3                   	ret    

00800faf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	53                   	push   %ebx
  800fb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800fb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800fbe:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800fc1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800fc4:	42                   	inc    %edx
  800fc5:	84 c9                	test   %cl,%cl
  800fc7:	75 f5                	jne    800fbe <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800fc9:	5b                   	pop    %ebx
  800fca:	5d                   	pop    %ebp
  800fcb:	c3                   	ret    

00800fcc <strcat>:

char *
strcat(char *dst, const char *src)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 08             	sub    $0x8,%esp
  800fd3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800fd6:	89 1c 24             	mov    %ebx,(%esp)
  800fd9:	e8 9e ff ff ff       	call   800f7c <strlen>
	strcpy(dst + len, src);
  800fde:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fe1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fe5:	01 d8                	add    %ebx,%eax
  800fe7:	89 04 24             	mov    %eax,(%esp)
  800fea:	e8 c0 ff ff ff       	call   800faf <strcpy>
	return dst;
}
  800fef:	89 d8                	mov    %ebx,%eax
  800ff1:	83 c4 08             	add    $0x8,%esp
  800ff4:	5b                   	pop    %ebx
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	56                   	push   %esi
  800ffb:	53                   	push   %ebx
  800ffc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801002:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801005:	b9 00 00 00 00       	mov    $0x0,%ecx
  80100a:	eb 0c                	jmp    801018 <strncpy+0x21>
		*dst++ = *src;
  80100c:	8a 1a                	mov    (%edx),%bl
  80100e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801011:	80 3a 01             	cmpb   $0x1,(%edx)
  801014:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801017:	41                   	inc    %ecx
  801018:	39 f1                	cmp    %esi,%ecx
  80101a:	75 f0                	jne    80100c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80101c:	5b                   	pop    %ebx
  80101d:	5e                   	pop    %esi
  80101e:	5d                   	pop    %ebp
  80101f:	c3                   	ret    

00801020 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	56                   	push   %esi
  801024:	53                   	push   %ebx
  801025:	8b 75 08             	mov    0x8(%ebp),%esi
  801028:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80102b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80102e:	85 d2                	test   %edx,%edx
  801030:	75 0a                	jne    80103c <strlcpy+0x1c>
  801032:	89 f0                	mov    %esi,%eax
  801034:	eb 1a                	jmp    801050 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801036:	88 18                	mov    %bl,(%eax)
  801038:	40                   	inc    %eax
  801039:	41                   	inc    %ecx
  80103a:	eb 02                	jmp    80103e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80103c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80103e:	4a                   	dec    %edx
  80103f:	74 0a                	je     80104b <strlcpy+0x2b>
  801041:	8a 19                	mov    (%ecx),%bl
  801043:	84 db                	test   %bl,%bl
  801045:	75 ef                	jne    801036 <strlcpy+0x16>
  801047:	89 c2                	mov    %eax,%edx
  801049:	eb 02                	jmp    80104d <strlcpy+0x2d>
  80104b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80104d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801050:	29 f0                	sub    %esi,%eax
}
  801052:	5b                   	pop    %ebx
  801053:	5e                   	pop    %esi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80105f:	eb 02                	jmp    801063 <strcmp+0xd>
		p++, q++;
  801061:	41                   	inc    %ecx
  801062:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801063:	8a 01                	mov    (%ecx),%al
  801065:	84 c0                	test   %al,%al
  801067:	74 04                	je     80106d <strcmp+0x17>
  801069:	3a 02                	cmp    (%edx),%al
  80106b:	74 f4                	je     801061 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80106d:	0f b6 c0             	movzbl %al,%eax
  801070:	0f b6 12             	movzbl (%edx),%edx
  801073:	29 d0                	sub    %edx,%eax
}
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    

00801077 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	53                   	push   %ebx
  80107b:	8b 45 08             	mov    0x8(%ebp),%eax
  80107e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801081:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801084:	eb 03                	jmp    801089 <strncmp+0x12>
		n--, p++, q++;
  801086:	4a                   	dec    %edx
  801087:	40                   	inc    %eax
  801088:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801089:	85 d2                	test   %edx,%edx
  80108b:	74 14                	je     8010a1 <strncmp+0x2a>
  80108d:	8a 18                	mov    (%eax),%bl
  80108f:	84 db                	test   %bl,%bl
  801091:	74 04                	je     801097 <strncmp+0x20>
  801093:	3a 19                	cmp    (%ecx),%bl
  801095:	74 ef                	je     801086 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801097:	0f b6 00             	movzbl (%eax),%eax
  80109a:	0f b6 11             	movzbl (%ecx),%edx
  80109d:	29 d0                	sub    %edx,%eax
  80109f:	eb 05                	jmp    8010a6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8010a1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010a6:	5b                   	pop    %ebx
  8010a7:	5d                   	pop    %ebp
  8010a8:	c3                   	ret    

008010a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8010a9:	55                   	push   %ebp
  8010aa:	89 e5                	mov    %esp,%ebp
  8010ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8010af:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8010b2:	eb 05                	jmp    8010b9 <strchr+0x10>
		if (*s == c)
  8010b4:	38 ca                	cmp    %cl,%dl
  8010b6:	74 0c                	je     8010c4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8010b8:	40                   	inc    %eax
  8010b9:	8a 10                	mov    (%eax),%dl
  8010bb:	84 d2                	test   %dl,%dl
  8010bd:	75 f5                	jne    8010b4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8010bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010c4:	5d                   	pop    %ebp
  8010c5:	c3                   	ret    

008010c6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8010cf:	eb 05                	jmp    8010d6 <strfind+0x10>
		if (*s == c)
  8010d1:	38 ca                	cmp    %cl,%dl
  8010d3:	74 07                	je     8010dc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8010d5:	40                   	inc    %eax
  8010d6:	8a 10                	mov    (%eax),%dl
  8010d8:	84 d2                	test   %dl,%dl
  8010da:	75 f5                	jne    8010d1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8010dc:	5d                   	pop    %ebp
  8010dd:	c3                   	ret    

008010de <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	57                   	push   %edi
  8010e2:	56                   	push   %esi
  8010e3:	53                   	push   %ebx
  8010e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8010ed:	85 c9                	test   %ecx,%ecx
  8010ef:	74 30                	je     801121 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8010f1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8010f7:	75 25                	jne    80111e <memset+0x40>
  8010f9:	f6 c1 03             	test   $0x3,%cl
  8010fc:	75 20                	jne    80111e <memset+0x40>
		c &= 0xFF;
  8010fe:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801101:	89 d3                	mov    %edx,%ebx
  801103:	c1 e3 08             	shl    $0x8,%ebx
  801106:	89 d6                	mov    %edx,%esi
  801108:	c1 e6 18             	shl    $0x18,%esi
  80110b:	89 d0                	mov    %edx,%eax
  80110d:	c1 e0 10             	shl    $0x10,%eax
  801110:	09 f0                	or     %esi,%eax
  801112:	09 d0                	or     %edx,%eax
  801114:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801116:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801119:	fc                   	cld    
  80111a:	f3 ab                	rep stos %eax,%es:(%edi)
  80111c:	eb 03                	jmp    801121 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80111e:	fc                   	cld    
  80111f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801121:	89 f8                	mov    %edi,%eax
  801123:	5b                   	pop    %ebx
  801124:	5e                   	pop    %esi
  801125:	5f                   	pop    %edi
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    

00801128 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	57                   	push   %edi
  80112c:	56                   	push   %esi
  80112d:	8b 45 08             	mov    0x8(%ebp),%eax
  801130:	8b 75 0c             	mov    0xc(%ebp),%esi
  801133:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801136:	39 c6                	cmp    %eax,%esi
  801138:	73 34                	jae    80116e <memmove+0x46>
  80113a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80113d:	39 d0                	cmp    %edx,%eax
  80113f:	73 2d                	jae    80116e <memmove+0x46>
		s += n;
		d += n;
  801141:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801144:	f6 c2 03             	test   $0x3,%dl
  801147:	75 1b                	jne    801164 <memmove+0x3c>
  801149:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80114f:	75 13                	jne    801164 <memmove+0x3c>
  801151:	f6 c1 03             	test   $0x3,%cl
  801154:	75 0e                	jne    801164 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801156:	83 ef 04             	sub    $0x4,%edi
  801159:	8d 72 fc             	lea    -0x4(%edx),%esi
  80115c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80115f:	fd                   	std    
  801160:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801162:	eb 07                	jmp    80116b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801164:	4f                   	dec    %edi
  801165:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801168:	fd                   	std    
  801169:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80116b:	fc                   	cld    
  80116c:	eb 20                	jmp    80118e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80116e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801174:	75 13                	jne    801189 <memmove+0x61>
  801176:	a8 03                	test   $0x3,%al
  801178:	75 0f                	jne    801189 <memmove+0x61>
  80117a:	f6 c1 03             	test   $0x3,%cl
  80117d:	75 0a                	jne    801189 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80117f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801182:	89 c7                	mov    %eax,%edi
  801184:	fc                   	cld    
  801185:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801187:	eb 05                	jmp    80118e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801189:	89 c7                	mov    %eax,%edi
  80118b:	fc                   	cld    
  80118c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80118e:	5e                   	pop    %esi
  80118f:	5f                   	pop    %edi
  801190:	5d                   	pop    %ebp
  801191:	c3                   	ret    

00801192 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801198:	8b 45 10             	mov    0x10(%ebp),%eax
  80119b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80119f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a9:	89 04 24             	mov    %eax,(%esp)
  8011ac:	e8 77 ff ff ff       	call   801128 <memmove>
}
  8011b1:	c9                   	leave  
  8011b2:	c3                   	ret    

008011b3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	57                   	push   %edi
  8011b7:	56                   	push   %esi
  8011b8:	53                   	push   %ebx
  8011b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c7:	eb 16                	jmp    8011df <memcmp+0x2c>
		if (*s1 != *s2)
  8011c9:	8a 04 17             	mov    (%edi,%edx,1),%al
  8011cc:	42                   	inc    %edx
  8011cd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8011d1:	38 c8                	cmp    %cl,%al
  8011d3:	74 0a                	je     8011df <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8011d5:	0f b6 c0             	movzbl %al,%eax
  8011d8:	0f b6 c9             	movzbl %cl,%ecx
  8011db:	29 c8                	sub    %ecx,%eax
  8011dd:	eb 09                	jmp    8011e8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011df:	39 da                	cmp    %ebx,%edx
  8011e1:	75 e6                	jne    8011c9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8011e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011e8:	5b                   	pop    %ebx
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8011f6:	89 c2                	mov    %eax,%edx
  8011f8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8011fb:	eb 05                	jmp    801202 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8011fd:	38 08                	cmp    %cl,(%eax)
  8011ff:	74 05                	je     801206 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801201:	40                   	inc    %eax
  801202:	39 d0                	cmp    %edx,%eax
  801204:	72 f7                	jb     8011fd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	57                   	push   %edi
  80120c:	56                   	push   %esi
  80120d:	53                   	push   %ebx
  80120e:	8b 55 08             	mov    0x8(%ebp),%edx
  801211:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801214:	eb 01                	jmp    801217 <strtol+0xf>
		s++;
  801216:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801217:	8a 02                	mov    (%edx),%al
  801219:	3c 20                	cmp    $0x20,%al
  80121b:	74 f9                	je     801216 <strtol+0xe>
  80121d:	3c 09                	cmp    $0x9,%al
  80121f:	74 f5                	je     801216 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801221:	3c 2b                	cmp    $0x2b,%al
  801223:	75 08                	jne    80122d <strtol+0x25>
		s++;
  801225:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801226:	bf 00 00 00 00       	mov    $0x0,%edi
  80122b:	eb 13                	jmp    801240 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80122d:	3c 2d                	cmp    $0x2d,%al
  80122f:	75 0a                	jne    80123b <strtol+0x33>
		s++, neg = 1;
  801231:	8d 52 01             	lea    0x1(%edx),%edx
  801234:	bf 01 00 00 00       	mov    $0x1,%edi
  801239:	eb 05                	jmp    801240 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80123b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801240:	85 db                	test   %ebx,%ebx
  801242:	74 05                	je     801249 <strtol+0x41>
  801244:	83 fb 10             	cmp    $0x10,%ebx
  801247:	75 28                	jne    801271 <strtol+0x69>
  801249:	8a 02                	mov    (%edx),%al
  80124b:	3c 30                	cmp    $0x30,%al
  80124d:	75 10                	jne    80125f <strtol+0x57>
  80124f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801253:	75 0a                	jne    80125f <strtol+0x57>
		s += 2, base = 16;
  801255:	83 c2 02             	add    $0x2,%edx
  801258:	bb 10 00 00 00       	mov    $0x10,%ebx
  80125d:	eb 12                	jmp    801271 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80125f:	85 db                	test   %ebx,%ebx
  801261:	75 0e                	jne    801271 <strtol+0x69>
  801263:	3c 30                	cmp    $0x30,%al
  801265:	75 05                	jne    80126c <strtol+0x64>
		s++, base = 8;
  801267:	42                   	inc    %edx
  801268:	b3 08                	mov    $0x8,%bl
  80126a:	eb 05                	jmp    801271 <strtol+0x69>
	else if (base == 0)
		base = 10;
  80126c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801271:	b8 00 00 00 00       	mov    $0x0,%eax
  801276:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801278:	8a 0a                	mov    (%edx),%cl
  80127a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80127d:	80 fb 09             	cmp    $0x9,%bl
  801280:	77 08                	ja     80128a <strtol+0x82>
			dig = *s - '0';
  801282:	0f be c9             	movsbl %cl,%ecx
  801285:	83 e9 30             	sub    $0x30,%ecx
  801288:	eb 1e                	jmp    8012a8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80128a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80128d:	80 fb 19             	cmp    $0x19,%bl
  801290:	77 08                	ja     80129a <strtol+0x92>
			dig = *s - 'a' + 10;
  801292:	0f be c9             	movsbl %cl,%ecx
  801295:	83 e9 57             	sub    $0x57,%ecx
  801298:	eb 0e                	jmp    8012a8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80129a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80129d:	80 fb 19             	cmp    $0x19,%bl
  8012a0:	77 12                	ja     8012b4 <strtol+0xac>
			dig = *s - 'A' + 10;
  8012a2:	0f be c9             	movsbl %cl,%ecx
  8012a5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8012a8:	39 f1                	cmp    %esi,%ecx
  8012aa:	7d 0c                	jge    8012b8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8012ac:	42                   	inc    %edx
  8012ad:	0f af c6             	imul   %esi,%eax
  8012b0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8012b2:	eb c4                	jmp    801278 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8012b4:	89 c1                	mov    %eax,%ecx
  8012b6:	eb 02                	jmp    8012ba <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8012b8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8012ba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8012be:	74 05                	je     8012c5 <strtol+0xbd>
		*endptr = (char *) s;
  8012c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012c3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8012c5:	85 ff                	test   %edi,%edi
  8012c7:	74 04                	je     8012cd <strtol+0xc5>
  8012c9:	89 c8                	mov    %ecx,%eax
  8012cb:	f7 d8                	neg    %eax
}
  8012cd:	5b                   	pop    %ebx
  8012ce:	5e                   	pop    %esi
  8012cf:	5f                   	pop    %edi
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    
	...

008012d4 <__udivdi3>:
  8012d4:	55                   	push   %ebp
  8012d5:	57                   	push   %edi
  8012d6:	56                   	push   %esi
  8012d7:	83 ec 10             	sub    $0x10,%esp
  8012da:	8b 74 24 20          	mov    0x20(%esp),%esi
  8012de:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8012e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012e6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8012ea:	89 cd                	mov    %ecx,%ebp
  8012ec:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	75 2c                	jne    801320 <__udivdi3+0x4c>
  8012f4:	39 f9                	cmp    %edi,%ecx
  8012f6:	77 68                	ja     801360 <__udivdi3+0x8c>
  8012f8:	85 c9                	test   %ecx,%ecx
  8012fa:	75 0b                	jne    801307 <__udivdi3+0x33>
  8012fc:	b8 01 00 00 00       	mov    $0x1,%eax
  801301:	31 d2                	xor    %edx,%edx
  801303:	f7 f1                	div    %ecx
  801305:	89 c1                	mov    %eax,%ecx
  801307:	31 d2                	xor    %edx,%edx
  801309:	89 f8                	mov    %edi,%eax
  80130b:	f7 f1                	div    %ecx
  80130d:	89 c7                	mov    %eax,%edi
  80130f:	89 f0                	mov    %esi,%eax
  801311:	f7 f1                	div    %ecx
  801313:	89 c6                	mov    %eax,%esi
  801315:	89 f0                	mov    %esi,%eax
  801317:	89 fa                	mov    %edi,%edx
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	5e                   	pop    %esi
  80131d:	5f                   	pop    %edi
  80131e:	5d                   	pop    %ebp
  80131f:	c3                   	ret    
  801320:	39 f8                	cmp    %edi,%eax
  801322:	77 2c                	ja     801350 <__udivdi3+0x7c>
  801324:	0f bd f0             	bsr    %eax,%esi
  801327:	83 f6 1f             	xor    $0x1f,%esi
  80132a:	75 4c                	jne    801378 <__udivdi3+0xa4>
  80132c:	39 f8                	cmp    %edi,%eax
  80132e:	bf 00 00 00 00       	mov    $0x0,%edi
  801333:	72 0a                	jb     80133f <__udivdi3+0x6b>
  801335:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801339:	0f 87 ad 00 00 00    	ja     8013ec <__udivdi3+0x118>
  80133f:	be 01 00 00 00       	mov    $0x1,%esi
  801344:	89 f0                	mov    %esi,%eax
  801346:	89 fa                	mov    %edi,%edx
  801348:	83 c4 10             	add    $0x10,%esp
  80134b:	5e                   	pop    %esi
  80134c:	5f                   	pop    %edi
  80134d:	5d                   	pop    %ebp
  80134e:	c3                   	ret    
  80134f:	90                   	nop
  801350:	31 ff                	xor    %edi,%edi
  801352:	31 f6                	xor    %esi,%esi
  801354:	89 f0                	mov    %esi,%eax
  801356:	89 fa                	mov    %edi,%edx
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	5e                   	pop    %esi
  80135c:	5f                   	pop    %edi
  80135d:	5d                   	pop    %ebp
  80135e:	c3                   	ret    
  80135f:	90                   	nop
  801360:	89 fa                	mov    %edi,%edx
  801362:	89 f0                	mov    %esi,%eax
  801364:	f7 f1                	div    %ecx
  801366:	89 c6                	mov    %eax,%esi
  801368:	31 ff                	xor    %edi,%edi
  80136a:	89 f0                	mov    %esi,%eax
  80136c:	89 fa                	mov    %edi,%edx
  80136e:	83 c4 10             	add    $0x10,%esp
  801371:	5e                   	pop    %esi
  801372:	5f                   	pop    %edi
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    
  801375:	8d 76 00             	lea    0x0(%esi),%esi
  801378:	89 f1                	mov    %esi,%ecx
  80137a:	d3 e0                	shl    %cl,%eax
  80137c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801380:	b8 20 00 00 00       	mov    $0x20,%eax
  801385:	29 f0                	sub    %esi,%eax
  801387:	89 ea                	mov    %ebp,%edx
  801389:	88 c1                	mov    %al,%cl
  80138b:	d3 ea                	shr    %cl,%edx
  80138d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801391:	09 ca                	or     %ecx,%edx
  801393:	89 54 24 08          	mov    %edx,0x8(%esp)
  801397:	89 f1                	mov    %esi,%ecx
  801399:	d3 e5                	shl    %cl,%ebp
  80139b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80139f:	89 fd                	mov    %edi,%ebp
  8013a1:	88 c1                	mov    %al,%cl
  8013a3:	d3 ed                	shr    %cl,%ebp
  8013a5:	89 fa                	mov    %edi,%edx
  8013a7:	89 f1                	mov    %esi,%ecx
  8013a9:	d3 e2                	shl    %cl,%edx
  8013ab:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013af:	88 c1                	mov    %al,%cl
  8013b1:	d3 ef                	shr    %cl,%edi
  8013b3:	09 d7                	or     %edx,%edi
  8013b5:	89 f8                	mov    %edi,%eax
  8013b7:	89 ea                	mov    %ebp,%edx
  8013b9:	f7 74 24 08          	divl   0x8(%esp)
  8013bd:	89 d1                	mov    %edx,%ecx
  8013bf:	89 c7                	mov    %eax,%edi
  8013c1:	f7 64 24 0c          	mull   0xc(%esp)
  8013c5:	39 d1                	cmp    %edx,%ecx
  8013c7:	72 17                	jb     8013e0 <__udivdi3+0x10c>
  8013c9:	74 09                	je     8013d4 <__udivdi3+0x100>
  8013cb:	89 fe                	mov    %edi,%esi
  8013cd:	31 ff                	xor    %edi,%edi
  8013cf:	e9 41 ff ff ff       	jmp    801315 <__udivdi3+0x41>
  8013d4:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013d8:	89 f1                	mov    %esi,%ecx
  8013da:	d3 e2                	shl    %cl,%edx
  8013dc:	39 c2                	cmp    %eax,%edx
  8013de:	73 eb                	jae    8013cb <__udivdi3+0xf7>
  8013e0:	8d 77 ff             	lea    -0x1(%edi),%esi
  8013e3:	31 ff                	xor    %edi,%edi
  8013e5:	e9 2b ff ff ff       	jmp    801315 <__udivdi3+0x41>
  8013ea:	66 90                	xchg   %ax,%ax
  8013ec:	31 f6                	xor    %esi,%esi
  8013ee:	e9 22 ff ff ff       	jmp    801315 <__udivdi3+0x41>
	...

008013f4 <__umoddi3>:
  8013f4:	55                   	push   %ebp
  8013f5:	57                   	push   %edi
  8013f6:	56                   	push   %esi
  8013f7:	83 ec 20             	sub    $0x20,%esp
  8013fa:	8b 44 24 30          	mov    0x30(%esp),%eax
  8013fe:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801402:	89 44 24 14          	mov    %eax,0x14(%esp)
  801406:	8b 74 24 34          	mov    0x34(%esp),%esi
  80140a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80140e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801412:	89 c7                	mov    %eax,%edi
  801414:	89 f2                	mov    %esi,%edx
  801416:	85 ed                	test   %ebp,%ebp
  801418:	75 16                	jne    801430 <__umoddi3+0x3c>
  80141a:	39 f1                	cmp    %esi,%ecx
  80141c:	0f 86 a6 00 00 00    	jbe    8014c8 <__umoddi3+0xd4>
  801422:	f7 f1                	div    %ecx
  801424:	89 d0                	mov    %edx,%eax
  801426:	31 d2                	xor    %edx,%edx
  801428:	83 c4 20             	add    $0x20,%esp
  80142b:	5e                   	pop    %esi
  80142c:	5f                   	pop    %edi
  80142d:	5d                   	pop    %ebp
  80142e:	c3                   	ret    
  80142f:	90                   	nop
  801430:	39 f5                	cmp    %esi,%ebp
  801432:	0f 87 ac 00 00 00    	ja     8014e4 <__umoddi3+0xf0>
  801438:	0f bd c5             	bsr    %ebp,%eax
  80143b:	83 f0 1f             	xor    $0x1f,%eax
  80143e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801442:	0f 84 a8 00 00 00    	je     8014f0 <__umoddi3+0xfc>
  801448:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80144c:	d3 e5                	shl    %cl,%ebp
  80144e:	bf 20 00 00 00       	mov    $0x20,%edi
  801453:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801457:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80145b:	89 f9                	mov    %edi,%ecx
  80145d:	d3 e8                	shr    %cl,%eax
  80145f:	09 e8                	or     %ebp,%eax
  801461:	89 44 24 18          	mov    %eax,0x18(%esp)
  801465:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801469:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80146d:	d3 e0                	shl    %cl,%eax
  80146f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801473:	89 f2                	mov    %esi,%edx
  801475:	d3 e2                	shl    %cl,%edx
  801477:	8b 44 24 14          	mov    0x14(%esp),%eax
  80147b:	d3 e0                	shl    %cl,%eax
  80147d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801481:	8b 44 24 14          	mov    0x14(%esp),%eax
  801485:	89 f9                	mov    %edi,%ecx
  801487:	d3 e8                	shr    %cl,%eax
  801489:	09 d0                	or     %edx,%eax
  80148b:	d3 ee                	shr    %cl,%esi
  80148d:	89 f2                	mov    %esi,%edx
  80148f:	f7 74 24 18          	divl   0x18(%esp)
  801493:	89 d6                	mov    %edx,%esi
  801495:	f7 64 24 0c          	mull   0xc(%esp)
  801499:	89 c5                	mov    %eax,%ebp
  80149b:	89 d1                	mov    %edx,%ecx
  80149d:	39 d6                	cmp    %edx,%esi
  80149f:	72 67                	jb     801508 <__umoddi3+0x114>
  8014a1:	74 75                	je     801518 <__umoddi3+0x124>
  8014a3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8014a7:	29 e8                	sub    %ebp,%eax
  8014a9:	19 ce                	sbb    %ecx,%esi
  8014ab:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014af:	d3 e8                	shr    %cl,%eax
  8014b1:	89 f2                	mov    %esi,%edx
  8014b3:	89 f9                	mov    %edi,%ecx
  8014b5:	d3 e2                	shl    %cl,%edx
  8014b7:	09 d0                	or     %edx,%eax
  8014b9:	89 f2                	mov    %esi,%edx
  8014bb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014bf:	d3 ea                	shr    %cl,%edx
  8014c1:	83 c4 20             	add    $0x20,%esp
  8014c4:	5e                   	pop    %esi
  8014c5:	5f                   	pop    %edi
  8014c6:	5d                   	pop    %ebp
  8014c7:	c3                   	ret    
  8014c8:	85 c9                	test   %ecx,%ecx
  8014ca:	75 0b                	jne    8014d7 <__umoddi3+0xe3>
  8014cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8014d1:	31 d2                	xor    %edx,%edx
  8014d3:	f7 f1                	div    %ecx
  8014d5:	89 c1                	mov    %eax,%ecx
  8014d7:	89 f0                	mov    %esi,%eax
  8014d9:	31 d2                	xor    %edx,%edx
  8014db:	f7 f1                	div    %ecx
  8014dd:	89 f8                	mov    %edi,%eax
  8014df:	e9 3e ff ff ff       	jmp    801422 <__umoddi3+0x2e>
  8014e4:	89 f2                	mov    %esi,%edx
  8014e6:	83 c4 20             	add    $0x20,%esp
  8014e9:	5e                   	pop    %esi
  8014ea:	5f                   	pop    %edi
  8014eb:	5d                   	pop    %ebp
  8014ec:	c3                   	ret    
  8014ed:	8d 76 00             	lea    0x0(%esi),%esi
  8014f0:	39 f5                	cmp    %esi,%ebp
  8014f2:	72 04                	jb     8014f8 <__umoddi3+0x104>
  8014f4:	39 f9                	cmp    %edi,%ecx
  8014f6:	77 06                	ja     8014fe <__umoddi3+0x10a>
  8014f8:	89 f2                	mov    %esi,%edx
  8014fa:	29 cf                	sub    %ecx,%edi
  8014fc:	19 ea                	sbb    %ebp,%edx
  8014fe:	89 f8                	mov    %edi,%eax
  801500:	83 c4 20             	add    $0x20,%esp
  801503:	5e                   	pop    %esi
  801504:	5f                   	pop    %edi
  801505:	5d                   	pop    %ebp
  801506:	c3                   	ret    
  801507:	90                   	nop
  801508:	89 d1                	mov    %edx,%ecx
  80150a:	89 c5                	mov    %eax,%ebp
  80150c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801510:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801514:	eb 8d                	jmp    8014a3 <__umoddi3+0xaf>
  801516:	66 90                	xchg   %ax,%ax
  801518:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80151c:	72 ea                	jb     801508 <__umoddi3+0x114>
  80151e:	89 f1                	mov    %esi,%ecx
  801520:	eb 81                	jmp    8014a3 <__umoddi3+0xaf>
