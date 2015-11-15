
obj/user/softint:     file format elf32-i386


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
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	5d                   	pop    %ebp
  80003a:	c3                   	ret    
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
  800054:	8d 14 80             	lea    (%eax,%eax,4),%edx
  800057:	8d 04 50             	lea    (%eax,%edx,2),%eax
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
  80010b:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  800112:	00 
  800113:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80011a:	00 
  80011b:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  800122:	e8 b1 02 00 00       	call   8003d8 <_panic>

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
  80019d:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  8001a4:	00 
  8001a5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001ac:	00 
  8001ad:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  8001b4:	e8 1f 02 00 00       	call   8003d8 <_panic>

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
  8001f0:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  8001f7:	00 
  8001f8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001ff:	00 
  800200:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  800207:	e8 cc 01 00 00       	call   8003d8 <_panic>

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
  800243:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  80024a:	00 
  80024b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800252:	00 
  800253:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  80025a:	e8 79 01 00 00       	call   8003d8 <_panic>

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
  800296:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  80029d:	00 
  80029e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002a5:	00 
  8002a6:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  8002ad:	e8 26 01 00 00       	call   8003d8 <_panic>

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
  8002e9:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  8002f0:	00 
  8002f1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f8:	00 
  8002f9:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  800300:	e8 d3 00 00 00       	call   8003d8 <_panic>

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
  80035e:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  800365:	00 
  800366:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80036d:	00 
  80036e:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  800375:	e8 5e 00 00 00       	call   8003d8 <_panic>

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
  8003b1:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  8003b8:	00 
  8003b9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003c0:	00 
  8003c1:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  8003c8:	e8 0b 00 00 00       	call   8003d8 <_panic>
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
  8003d5:	00 00                	add    %al,(%eax)
	...

008003d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	56                   	push   %esi
  8003dc:	53                   	push   %ebx
  8003dd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003e0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003e3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8003e9:	e8 41 fd ff ff       	call   80012f <sys_getenvid>
  8003ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800400:	89 44 24 04          	mov    %eax,0x4(%esp)
  800404:	c7 04 24 38 10 80 00 	movl   $0x801038,(%esp)
  80040b:	e8 c0 00 00 00       	call   8004d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800410:	89 74 24 04          	mov    %esi,0x4(%esp)
  800414:	8b 45 10             	mov    0x10(%ebp),%eax
  800417:	89 04 24             	mov    %eax,(%esp)
  80041a:	e8 50 00 00 00       	call   80046f <vcprintf>
	cprintf("\n");
  80041f:	c7 04 24 5c 10 80 00 	movl   $0x80105c,(%esp)
  800426:	e8 a5 00 00 00       	call   8004d0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80042b:	cc                   	int3   
  80042c:	eb fd                	jmp    80042b <_panic+0x53>
	...

00800430 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	53                   	push   %ebx
  800434:	83 ec 14             	sub    $0x14,%esp
  800437:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80043a:	8b 03                	mov    (%ebx),%eax
  80043c:	8b 55 08             	mov    0x8(%ebp),%edx
  80043f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800443:	40                   	inc    %eax
  800444:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800446:	3d ff 00 00 00       	cmp    $0xff,%eax
  80044b:	75 19                	jne    800466 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80044d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800454:	00 
  800455:	8d 43 08             	lea    0x8(%ebx),%eax
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	e8 40 fc ff ff       	call   8000a0 <sys_cputs>
		b->idx = 0;
  800460:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800466:	ff 43 04             	incl   0x4(%ebx)
}
  800469:	83 c4 14             	add    $0x14,%esp
  80046c:	5b                   	pop    %ebx
  80046d:	5d                   	pop    %ebp
  80046e:	c3                   	ret    

0080046f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80046f:	55                   	push   %ebp
  800470:	89 e5                	mov    %esp,%ebp
  800472:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800478:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80047f:	00 00 00 
	b.cnt = 0;
  800482:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800489:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80048c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80048f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800493:	8b 45 08             	mov    0x8(%ebp),%eax
  800496:	89 44 24 08          	mov    %eax,0x8(%esp)
  80049a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a4:	c7 04 24 30 04 80 00 	movl   $0x800430,(%esp)
  8004ab:	e8 b4 01 00 00       	call   800664 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004b0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ba:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004c0:	89 04 24             	mov    %eax,(%esp)
  8004c3:	e8 d8 fb ff ff       	call   8000a0 <sys_cputs>

	return b.cnt;
}
  8004c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004ce:	c9                   	leave  
  8004cf:	c3                   	ret    

008004d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e0:	89 04 24             	mov    %eax,(%esp)
  8004e3:	e8 87 ff ff ff       	call   80046f <vcprintf>
	va_end(ap);

	return cnt;
}
  8004e8:	c9                   	leave  
  8004e9:	c3                   	ret    
	...

008004ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	57                   	push   %edi
  8004f0:	56                   	push   %esi
  8004f1:	53                   	push   %ebx
  8004f2:	83 ec 3c             	sub    $0x3c,%esp
  8004f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004f8:	89 d7                	mov    %edx,%edi
  8004fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800500:	8b 45 0c             	mov    0xc(%ebp),%eax
  800503:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800506:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800509:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80050c:	85 c0                	test   %eax,%eax
  80050e:	75 08                	jne    800518 <printnum+0x2c>
  800510:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800513:	39 45 10             	cmp    %eax,0x10(%ebp)
  800516:	77 57                	ja     80056f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800518:	89 74 24 10          	mov    %esi,0x10(%esp)
  80051c:	4b                   	dec    %ebx
  80051d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800521:	8b 45 10             	mov    0x10(%ebp),%eax
  800524:	89 44 24 08          	mov    %eax,0x8(%esp)
  800528:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80052c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800530:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800537:	00 
  800538:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80053b:	89 04 24             	mov    %eax,(%esp)
  80053e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800541:	89 44 24 04          	mov    %eax,0x4(%esp)
  800545:	e8 5a 08 00 00       	call   800da4 <__udivdi3>
  80054a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80054e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800552:	89 04 24             	mov    %eax,(%esp)
  800555:	89 54 24 04          	mov    %edx,0x4(%esp)
  800559:	89 fa                	mov    %edi,%edx
  80055b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80055e:	e8 89 ff ff ff       	call   8004ec <printnum>
  800563:	eb 0f                	jmp    800574 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800565:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800569:	89 34 24             	mov    %esi,(%esp)
  80056c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80056f:	4b                   	dec    %ebx
  800570:	85 db                	test   %ebx,%ebx
  800572:	7f f1                	jg     800565 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800574:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800578:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80057c:	8b 45 10             	mov    0x10(%ebp),%eax
  80057f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800583:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80058a:	00 
  80058b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80058e:	89 04 24             	mov    %eax,(%esp)
  800591:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800594:	89 44 24 04          	mov    %eax,0x4(%esp)
  800598:	e8 27 09 00 00       	call   800ec4 <__umoddi3>
  80059d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a1:	0f be 80 5e 10 80 00 	movsbl 0x80105e(%eax),%eax
  8005a8:	89 04 24             	mov    %eax,(%esp)
  8005ab:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8005ae:	83 c4 3c             	add    $0x3c,%esp
  8005b1:	5b                   	pop    %ebx
  8005b2:	5e                   	pop    %esi
  8005b3:	5f                   	pop    %edi
  8005b4:	5d                   	pop    %ebp
  8005b5:	c3                   	ret    

008005b6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005b6:	55                   	push   %ebp
  8005b7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005b9:	83 fa 01             	cmp    $0x1,%edx
  8005bc:	7e 0e                	jle    8005cc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005be:	8b 10                	mov    (%eax),%edx
  8005c0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005c3:	89 08                	mov    %ecx,(%eax)
  8005c5:	8b 02                	mov    (%edx),%eax
  8005c7:	8b 52 04             	mov    0x4(%edx),%edx
  8005ca:	eb 22                	jmp    8005ee <getuint+0x38>
	else if (lflag)
  8005cc:	85 d2                	test   %edx,%edx
  8005ce:	74 10                	je     8005e0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005d0:	8b 10                	mov    (%eax),%edx
  8005d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005d5:	89 08                	mov    %ecx,(%eax)
  8005d7:	8b 02                	mov    (%edx),%eax
  8005d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005de:	eb 0e                	jmp    8005ee <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005e0:	8b 10                	mov    (%eax),%edx
  8005e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005e5:	89 08                	mov    %ecx,(%eax)
  8005e7:	8b 02                	mov    (%edx),%eax
  8005e9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005ee:	5d                   	pop    %ebp
  8005ef:	c3                   	ret    

008005f0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8005f0:	55                   	push   %ebp
  8005f1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005f3:	83 fa 01             	cmp    $0x1,%edx
  8005f6:	7e 0e                	jle    800606 <getint+0x16>
		return va_arg(*ap, long long);
  8005f8:	8b 10                	mov    (%eax),%edx
  8005fa:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005fd:	89 08                	mov    %ecx,(%eax)
  8005ff:	8b 02                	mov    (%edx),%eax
  800601:	8b 52 04             	mov    0x4(%edx),%edx
  800604:	eb 1a                	jmp    800620 <getint+0x30>
	else if (lflag)
  800606:	85 d2                	test   %edx,%edx
  800608:	74 0c                	je     800616 <getint+0x26>
		return va_arg(*ap, long);
  80060a:	8b 10                	mov    (%eax),%edx
  80060c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80060f:	89 08                	mov    %ecx,(%eax)
  800611:	8b 02                	mov    (%edx),%eax
  800613:	99                   	cltd   
  800614:	eb 0a                	jmp    800620 <getint+0x30>
	else
		return va_arg(*ap, int);
  800616:	8b 10                	mov    (%eax),%edx
  800618:	8d 4a 04             	lea    0x4(%edx),%ecx
  80061b:	89 08                	mov    %ecx,(%eax)
  80061d:	8b 02                	mov    (%edx),%eax
  80061f:	99                   	cltd   
}
  800620:	5d                   	pop    %ebp
  800621:	c3                   	ret    

00800622 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800622:	55                   	push   %ebp
  800623:	89 e5                	mov    %esp,%ebp
  800625:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800628:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80062b:	8b 10                	mov    (%eax),%edx
  80062d:	3b 50 04             	cmp    0x4(%eax),%edx
  800630:	73 08                	jae    80063a <sprintputch+0x18>
		*b->buf++ = ch;
  800632:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800635:	88 0a                	mov    %cl,(%edx)
  800637:	42                   	inc    %edx
  800638:	89 10                	mov    %edx,(%eax)
}
  80063a:	5d                   	pop    %ebp
  80063b:	c3                   	ret    

0080063c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80063c:	55                   	push   %ebp
  80063d:	89 e5                	mov    %esp,%ebp
  80063f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800642:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800645:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800649:	8b 45 10             	mov    0x10(%ebp),%eax
  80064c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800650:	8b 45 0c             	mov    0xc(%ebp),%eax
  800653:	89 44 24 04          	mov    %eax,0x4(%esp)
  800657:	8b 45 08             	mov    0x8(%ebp),%eax
  80065a:	89 04 24             	mov    %eax,(%esp)
  80065d:	e8 02 00 00 00       	call   800664 <vprintfmt>
	va_end(ap);
}
  800662:	c9                   	leave  
  800663:	c3                   	ret    

00800664 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800664:	55                   	push   %ebp
  800665:	89 e5                	mov    %esp,%ebp
  800667:	57                   	push   %edi
  800668:	56                   	push   %esi
  800669:	53                   	push   %ebx
  80066a:	83 ec 4c             	sub    $0x4c,%esp
  80066d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800670:	8b 75 10             	mov    0x10(%ebp),%esi
  800673:	eb 12                	jmp    800687 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800675:	85 c0                	test   %eax,%eax
  800677:	0f 84 40 03 00 00    	je     8009bd <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  80067d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800681:	89 04 24             	mov    %eax,(%esp)
  800684:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800687:	0f b6 06             	movzbl (%esi),%eax
  80068a:	46                   	inc    %esi
  80068b:	83 f8 25             	cmp    $0x25,%eax
  80068e:	75 e5                	jne    800675 <vprintfmt+0x11>
  800690:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800694:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80069b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006a0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ac:	eb 26                	jmp    8006d4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ae:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006b1:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8006b5:	eb 1d                	jmp    8006d4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006ba:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8006be:	eb 14                	jmp    8006d4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8006c3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8006ca:	eb 08                	jmp    8006d4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8006cc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006cf:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d4:	0f b6 06             	movzbl (%esi),%eax
  8006d7:	8d 4e 01             	lea    0x1(%esi),%ecx
  8006da:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006dd:	8a 0e                	mov    (%esi),%cl
  8006df:	83 e9 23             	sub    $0x23,%ecx
  8006e2:	80 f9 55             	cmp    $0x55,%cl
  8006e5:	0f 87 b6 02 00 00    	ja     8009a1 <vprintfmt+0x33d>
  8006eb:	0f b6 c9             	movzbl %cl,%ecx
  8006ee:	ff 24 8d 20 11 80 00 	jmp    *0x801120(,%ecx,4)
  8006f5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006f8:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006fd:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800700:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  800704:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800707:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80070a:	83 f9 09             	cmp    $0x9,%ecx
  80070d:	77 2a                	ja     800739 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80070f:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800710:	eb eb                	jmp    8006fd <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8d 48 04             	lea    0x4(%eax),%ecx
  800718:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80071b:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800720:	eb 17                	jmp    800739 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800722:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800726:	78 98                	js     8006c0 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800728:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80072b:	eb a7                	jmp    8006d4 <vprintfmt+0x70>
  80072d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800730:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800737:	eb 9b                	jmp    8006d4 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800739:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80073d:	79 95                	jns    8006d4 <vprintfmt+0x70>
  80073f:	eb 8b                	jmp    8006cc <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800741:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800742:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800745:	eb 8d                	jmp    8006d4 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8d 50 04             	lea    0x4(%eax),%edx
  80074d:	89 55 14             	mov    %edx,0x14(%ebp)
  800750:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800754:	8b 00                	mov    (%eax),%eax
  800756:	89 04 24             	mov    %eax,(%esp)
  800759:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80075f:	e9 23 ff ff ff       	jmp    800687 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800764:	8b 45 14             	mov    0x14(%ebp),%eax
  800767:	8d 50 04             	lea    0x4(%eax),%edx
  80076a:	89 55 14             	mov    %edx,0x14(%ebp)
  80076d:	8b 00                	mov    (%eax),%eax
  80076f:	85 c0                	test   %eax,%eax
  800771:	79 02                	jns    800775 <vprintfmt+0x111>
  800773:	f7 d8                	neg    %eax
  800775:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800777:	83 f8 09             	cmp    $0x9,%eax
  80077a:	7f 0b                	jg     800787 <vprintfmt+0x123>
  80077c:	8b 04 85 80 12 80 00 	mov    0x801280(,%eax,4),%eax
  800783:	85 c0                	test   %eax,%eax
  800785:	75 23                	jne    8007aa <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800787:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80078b:	c7 44 24 08 76 10 80 	movl   $0x801076,0x8(%esp)
  800792:	00 
  800793:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800797:	8b 45 08             	mov    0x8(%ebp),%eax
  80079a:	89 04 24             	mov    %eax,(%esp)
  80079d:	e8 9a fe ff ff       	call   80063c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007a5:	e9 dd fe ff ff       	jmp    800687 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8007aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ae:	c7 44 24 08 7f 10 80 	movl   $0x80107f,0x8(%esp)
  8007b5:	00 
  8007b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8007bd:	89 14 24             	mov    %edx,(%esp)
  8007c0:	e8 77 fe ff ff       	call   80063c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007c8:	e9 ba fe ff ff       	jmp    800687 <vprintfmt+0x23>
  8007cd:	89 f9                	mov    %edi,%ecx
  8007cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d8:	8d 50 04             	lea    0x4(%eax),%edx
  8007db:	89 55 14             	mov    %edx,0x14(%ebp)
  8007de:	8b 30                	mov    (%eax),%esi
  8007e0:	85 f6                	test   %esi,%esi
  8007e2:	75 05                	jne    8007e9 <vprintfmt+0x185>
				p = "(null)";
  8007e4:	be 6f 10 80 00       	mov    $0x80106f,%esi
			if (width > 0 && padc != '-')
  8007e9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007ed:	0f 8e 84 00 00 00    	jle    800877 <vprintfmt+0x213>
  8007f3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007f7:	74 7e                	je     800877 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007f9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007fd:	89 34 24             	mov    %esi,(%esp)
  800800:	e8 5d 02 00 00       	call   800a62 <strnlen>
  800805:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800808:	29 c2                	sub    %eax,%edx
  80080a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80080d:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800811:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800814:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800817:	89 de                	mov    %ebx,%esi
  800819:	89 d3                	mov    %edx,%ebx
  80081b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80081d:	eb 0b                	jmp    80082a <vprintfmt+0x1c6>
					putch(padc, putdat);
  80081f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800823:	89 3c 24             	mov    %edi,(%esp)
  800826:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800829:	4b                   	dec    %ebx
  80082a:	85 db                	test   %ebx,%ebx
  80082c:	7f f1                	jg     80081f <vprintfmt+0x1bb>
  80082e:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800831:	89 f3                	mov    %esi,%ebx
  800833:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800836:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800839:	85 c0                	test   %eax,%eax
  80083b:	79 05                	jns    800842 <vprintfmt+0x1de>
  80083d:	b8 00 00 00 00       	mov    $0x0,%eax
  800842:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800845:	29 c2                	sub    %eax,%edx
  800847:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80084a:	eb 2b                	jmp    800877 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80084c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800850:	74 18                	je     80086a <vprintfmt+0x206>
  800852:	8d 50 e0             	lea    -0x20(%eax),%edx
  800855:	83 fa 5e             	cmp    $0x5e,%edx
  800858:	76 10                	jbe    80086a <vprintfmt+0x206>
					putch('?', putdat);
  80085a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80085e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800865:	ff 55 08             	call   *0x8(%ebp)
  800868:	eb 0a                	jmp    800874 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80086a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086e:	89 04 24             	mov    %eax,(%esp)
  800871:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800874:	ff 4d e4             	decl   -0x1c(%ebp)
  800877:	0f be 06             	movsbl (%esi),%eax
  80087a:	46                   	inc    %esi
  80087b:	85 c0                	test   %eax,%eax
  80087d:	74 21                	je     8008a0 <vprintfmt+0x23c>
  80087f:	85 ff                	test   %edi,%edi
  800881:	78 c9                	js     80084c <vprintfmt+0x1e8>
  800883:	4f                   	dec    %edi
  800884:	79 c6                	jns    80084c <vprintfmt+0x1e8>
  800886:	8b 7d 08             	mov    0x8(%ebp),%edi
  800889:	89 de                	mov    %ebx,%esi
  80088b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80088e:	eb 18                	jmp    8008a8 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800890:	89 74 24 04          	mov    %esi,0x4(%esp)
  800894:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80089b:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80089d:	4b                   	dec    %ebx
  80089e:	eb 08                	jmp    8008a8 <vprintfmt+0x244>
  8008a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a3:	89 de                	mov    %ebx,%esi
  8008a5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008a8:	85 db                	test   %ebx,%ebx
  8008aa:	7f e4                	jg     800890 <vprintfmt+0x22c>
  8008ac:	89 7d 08             	mov    %edi,0x8(%ebp)
  8008af:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008b4:	e9 ce fd ff ff       	jmp    800687 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8008bc:	e8 2f fd ff ff       	call   8005f0 <getint>
  8008c1:	89 c6                	mov    %eax,%esi
  8008c3:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8008c5:	85 d2                	test   %edx,%edx
  8008c7:	78 07                	js     8008d0 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008c9:	be 0a 00 00 00       	mov    $0xa,%esi
  8008ce:	eb 7e                	jmp    80094e <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008db:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008de:	89 f0                	mov    %esi,%eax
  8008e0:	89 fa                	mov    %edi,%edx
  8008e2:	f7 d8                	neg    %eax
  8008e4:	83 d2 00             	adc    $0x0,%edx
  8008e7:	f7 da                	neg    %edx
			}
			base = 10;
  8008e9:	be 0a 00 00 00       	mov    $0xa,%esi
  8008ee:	eb 5e                	jmp    80094e <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8008f3:	e8 be fc ff ff       	call   8005b6 <getuint>
			base = 10;
  8008f8:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8008fd:	eb 4f                	jmp    80094e <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8008ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800902:	e8 af fc ff ff       	call   8005b6 <getuint>
			base = 8;
  800907:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80090c:	eb 40                	jmp    80094e <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  80090e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800912:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800919:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80091c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800920:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800927:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80092a:	8b 45 14             	mov    0x14(%ebp),%eax
  80092d:	8d 50 04             	lea    0x4(%eax),%edx
  800930:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800933:	8b 00                	mov    (%eax),%eax
  800935:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80093a:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80093f:	eb 0d                	jmp    80094e <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800941:	8d 45 14             	lea    0x14(%ebp),%eax
  800944:	e8 6d fc ff ff       	call   8005b6 <getuint>
			base = 16;
  800949:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80094e:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800952:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800956:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800959:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80095d:	89 74 24 08          	mov    %esi,0x8(%esp)
  800961:	89 04 24             	mov    %eax,(%esp)
  800964:	89 54 24 04          	mov    %edx,0x4(%esp)
  800968:	89 da                	mov    %ebx,%edx
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	e8 7a fb ff ff       	call   8004ec <printnum>
			break;
  800972:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800975:	e9 0d fd ff ff       	jmp    800687 <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  80097a:	8d 45 14             	lea    0x14(%ebp),%eax
  80097d:	e8 6e fc ff ff       	call   8005f0 <getint>
  800982:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800987:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  80098a:	e9 f8 fc ff ff       	jmp    800687 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80098f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800993:	89 04 24             	mov    %eax,(%esp)
  800996:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800999:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80099c:	e9 e6 fc ff ff       	jmp    800687 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009ac:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009af:	eb 01                	jmp    8009b2 <vprintfmt+0x34e>
  8009b1:	4e                   	dec    %esi
  8009b2:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009b6:	75 f9                	jne    8009b1 <vprintfmt+0x34d>
  8009b8:	e9 ca fc ff ff       	jmp    800687 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009bd:	83 c4 4c             	add    $0x4c,%esp
  8009c0:	5b                   	pop    %ebx
  8009c1:	5e                   	pop    %esi
  8009c2:	5f                   	pop    %edi
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	83 ec 28             	sub    $0x28,%esp
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009d4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009d8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009e2:	85 c0                	test   %eax,%eax
  8009e4:	74 30                	je     800a16 <vsnprintf+0x51>
  8009e6:	85 d2                	test   %edx,%edx
  8009e8:	7e 33                	jle    800a1d <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ff:	c7 04 24 22 06 80 00 	movl   $0x800622,(%esp)
  800a06:	e8 59 fc ff ff       	call   800664 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a0e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a14:	eb 0c                	jmp    800a22 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a16:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a1b:	eb 05                	jmp    800a22 <vsnprintf+0x5d>
  800a1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a2a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a31:	8b 45 10             	mov    0x10(%ebp),%eax
  800a34:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	89 04 24             	mov    %eax,(%esp)
  800a45:	e8 7b ff ff ff       	call   8009c5 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a4a:	c9                   	leave  
  800a4b:	c3                   	ret    

00800a4c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a52:	b8 00 00 00 00       	mov    $0x0,%eax
  800a57:	eb 01                	jmp    800a5a <strlen+0xe>
		n++;
  800a59:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a5a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a5e:	75 f9                	jne    800a59 <strlen+0xd>
		n++;
	return n;
}
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a68:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a70:	eb 01                	jmp    800a73 <strnlen+0x11>
		n++;
  800a72:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a73:	39 d0                	cmp    %edx,%eax
  800a75:	74 06                	je     800a7d <strnlen+0x1b>
  800a77:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a7b:	75 f5                	jne    800a72 <strnlen+0x10>
		n++;
	return n;
}
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	53                   	push   %ebx
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a89:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a91:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a94:	42                   	inc    %edx
  800a95:	84 c9                	test   %cl,%cl
  800a97:	75 f5                	jne    800a8e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a99:	5b                   	pop    %ebx
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	53                   	push   %ebx
  800aa0:	83 ec 08             	sub    $0x8,%esp
  800aa3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aa6:	89 1c 24             	mov    %ebx,(%esp)
  800aa9:	e8 9e ff ff ff       	call   800a4c <strlen>
	strcpy(dst + len, src);
  800aae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ab5:	01 d8                	add    %ebx,%eax
  800ab7:	89 04 24             	mov    %eax,(%esp)
  800aba:	e8 c0 ff ff ff       	call   800a7f <strcpy>
	return dst;
}
  800abf:	89 d8                	mov    %ebx,%eax
  800ac1:	83 c4 08             	add    $0x8,%esp
  800ac4:	5b                   	pop    %ebx
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	56                   	push   %esi
  800acb:	53                   	push   %ebx
  800acc:	8b 45 08             	mov    0x8(%ebp),%eax
  800acf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ad5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ada:	eb 0c                	jmp    800ae8 <strncpy+0x21>
		*dst++ = *src;
  800adc:	8a 1a                	mov    (%edx),%bl
  800ade:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ae1:	80 3a 01             	cmpb   $0x1,(%edx)
  800ae4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae7:	41                   	inc    %ecx
  800ae8:	39 f1                	cmp    %esi,%ecx
  800aea:	75 f0                	jne    800adc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
  800af5:	8b 75 08             	mov    0x8(%ebp),%esi
  800af8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800afe:	85 d2                	test   %edx,%edx
  800b00:	75 0a                	jne    800b0c <strlcpy+0x1c>
  800b02:	89 f0                	mov    %esi,%eax
  800b04:	eb 1a                	jmp    800b20 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b06:	88 18                	mov    %bl,(%eax)
  800b08:	40                   	inc    %eax
  800b09:	41                   	inc    %ecx
  800b0a:	eb 02                	jmp    800b0e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b0c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b0e:	4a                   	dec    %edx
  800b0f:	74 0a                	je     800b1b <strlcpy+0x2b>
  800b11:	8a 19                	mov    (%ecx),%bl
  800b13:	84 db                	test   %bl,%bl
  800b15:	75 ef                	jne    800b06 <strlcpy+0x16>
  800b17:	89 c2                	mov    %eax,%edx
  800b19:	eb 02                	jmp    800b1d <strlcpy+0x2d>
  800b1b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b1d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b20:	29 f0                	sub    %esi,%eax
}
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b2f:	eb 02                	jmp    800b33 <strcmp+0xd>
		p++, q++;
  800b31:	41                   	inc    %ecx
  800b32:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b33:	8a 01                	mov    (%ecx),%al
  800b35:	84 c0                	test   %al,%al
  800b37:	74 04                	je     800b3d <strcmp+0x17>
  800b39:	3a 02                	cmp    (%edx),%al
  800b3b:	74 f4                	je     800b31 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b3d:	0f b6 c0             	movzbl %al,%eax
  800b40:	0f b6 12             	movzbl (%edx),%edx
  800b43:	29 d0                	sub    %edx,%eax
}
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	53                   	push   %ebx
  800b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b51:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b54:	eb 03                	jmp    800b59 <strncmp+0x12>
		n--, p++, q++;
  800b56:	4a                   	dec    %edx
  800b57:	40                   	inc    %eax
  800b58:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b59:	85 d2                	test   %edx,%edx
  800b5b:	74 14                	je     800b71 <strncmp+0x2a>
  800b5d:	8a 18                	mov    (%eax),%bl
  800b5f:	84 db                	test   %bl,%bl
  800b61:	74 04                	je     800b67 <strncmp+0x20>
  800b63:	3a 19                	cmp    (%ecx),%bl
  800b65:	74 ef                	je     800b56 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b67:	0f b6 00             	movzbl (%eax),%eax
  800b6a:	0f b6 11             	movzbl (%ecx),%edx
  800b6d:	29 d0                	sub    %edx,%eax
  800b6f:	eb 05                	jmp    800b76 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b71:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b76:	5b                   	pop    %ebx
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b82:	eb 05                	jmp    800b89 <strchr+0x10>
		if (*s == c)
  800b84:	38 ca                	cmp    %cl,%dl
  800b86:	74 0c                	je     800b94 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b88:	40                   	inc    %eax
  800b89:	8a 10                	mov    (%eax),%dl
  800b8b:	84 d2                	test   %dl,%dl
  800b8d:	75 f5                	jne    800b84 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b9f:	eb 05                	jmp    800ba6 <strfind+0x10>
		if (*s == c)
  800ba1:	38 ca                	cmp    %cl,%dl
  800ba3:	74 07                	je     800bac <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ba5:	40                   	inc    %eax
  800ba6:	8a 10                	mov    (%eax),%dl
  800ba8:	84 d2                	test   %dl,%dl
  800baa:	75 f5                	jne    800ba1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bbd:	85 c9                	test   %ecx,%ecx
  800bbf:	74 30                	je     800bf1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bc1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bc7:	75 25                	jne    800bee <memset+0x40>
  800bc9:	f6 c1 03             	test   $0x3,%cl
  800bcc:	75 20                	jne    800bee <memset+0x40>
		c &= 0xFF;
  800bce:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bd1:	89 d3                	mov    %edx,%ebx
  800bd3:	c1 e3 08             	shl    $0x8,%ebx
  800bd6:	89 d6                	mov    %edx,%esi
  800bd8:	c1 e6 18             	shl    $0x18,%esi
  800bdb:	89 d0                	mov    %edx,%eax
  800bdd:	c1 e0 10             	shl    $0x10,%eax
  800be0:	09 f0                	or     %esi,%eax
  800be2:	09 d0                	or     %edx,%eax
  800be4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800be6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800be9:	fc                   	cld    
  800bea:	f3 ab                	rep stos %eax,%es:(%edi)
  800bec:	eb 03                	jmp    800bf1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bee:	fc                   	cld    
  800bef:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bf1:	89 f8                	mov    %edi,%eax
  800bf3:	5b                   	pop    %ebx
  800bf4:	5e                   	pop    %esi
  800bf5:	5f                   	pop    %edi
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    

00800bf8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	57                   	push   %edi
  800bfc:	56                   	push   %esi
  800bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800c00:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c03:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c06:	39 c6                	cmp    %eax,%esi
  800c08:	73 34                	jae    800c3e <memmove+0x46>
  800c0a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c0d:	39 d0                	cmp    %edx,%eax
  800c0f:	73 2d                	jae    800c3e <memmove+0x46>
		s += n;
		d += n;
  800c11:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c14:	f6 c2 03             	test   $0x3,%dl
  800c17:	75 1b                	jne    800c34 <memmove+0x3c>
  800c19:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c1f:	75 13                	jne    800c34 <memmove+0x3c>
  800c21:	f6 c1 03             	test   $0x3,%cl
  800c24:	75 0e                	jne    800c34 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c26:	83 ef 04             	sub    $0x4,%edi
  800c29:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c2c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c2f:	fd                   	std    
  800c30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c32:	eb 07                	jmp    800c3b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c34:	4f                   	dec    %edi
  800c35:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c38:	fd                   	std    
  800c39:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c3b:	fc                   	cld    
  800c3c:	eb 20                	jmp    800c5e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c3e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c44:	75 13                	jne    800c59 <memmove+0x61>
  800c46:	a8 03                	test   $0x3,%al
  800c48:	75 0f                	jne    800c59 <memmove+0x61>
  800c4a:	f6 c1 03             	test   $0x3,%cl
  800c4d:	75 0a                	jne    800c59 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c4f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c52:	89 c7                	mov    %eax,%edi
  800c54:	fc                   	cld    
  800c55:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c57:	eb 05                	jmp    800c5e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c59:	89 c7                	mov    %eax,%edi
  800c5b:	fc                   	cld    
  800c5c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c68:	8b 45 10             	mov    0x10(%ebp),%eax
  800c6b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c72:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c76:	8b 45 08             	mov    0x8(%ebp),%eax
  800c79:	89 04 24             	mov    %eax,(%esp)
  800c7c:	e8 77 ff ff ff       	call   800bf8 <memmove>
}
  800c81:	c9                   	leave  
  800c82:	c3                   	ret    

00800c83 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c92:	ba 00 00 00 00       	mov    $0x0,%edx
  800c97:	eb 16                	jmp    800caf <memcmp+0x2c>
		if (*s1 != *s2)
  800c99:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c9c:	42                   	inc    %edx
  800c9d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800ca1:	38 c8                	cmp    %cl,%al
  800ca3:	74 0a                	je     800caf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ca5:	0f b6 c0             	movzbl %al,%eax
  800ca8:	0f b6 c9             	movzbl %cl,%ecx
  800cab:	29 c8                	sub    %ecx,%eax
  800cad:	eb 09                	jmp    800cb8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800caf:	39 da                	cmp    %ebx,%edx
  800cb1:	75 e6                	jne    800c99 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cc6:	89 c2                	mov    %eax,%edx
  800cc8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ccb:	eb 05                	jmp    800cd2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ccd:	38 08                	cmp    %cl,(%eax)
  800ccf:	74 05                	je     800cd6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cd1:	40                   	inc    %eax
  800cd2:	39 d0                	cmp    %edx,%eax
  800cd4:	72 f7                	jb     800ccd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cd6:	5d                   	pop    %ebp
  800cd7:	c3                   	ret    

00800cd8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ce4:	eb 01                	jmp    800ce7 <strtol+0xf>
		s++;
  800ce6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ce7:	8a 02                	mov    (%edx),%al
  800ce9:	3c 20                	cmp    $0x20,%al
  800ceb:	74 f9                	je     800ce6 <strtol+0xe>
  800ced:	3c 09                	cmp    $0x9,%al
  800cef:	74 f5                	je     800ce6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cf1:	3c 2b                	cmp    $0x2b,%al
  800cf3:	75 08                	jne    800cfd <strtol+0x25>
		s++;
  800cf5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cf6:	bf 00 00 00 00       	mov    $0x0,%edi
  800cfb:	eb 13                	jmp    800d10 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cfd:	3c 2d                	cmp    $0x2d,%al
  800cff:	75 0a                	jne    800d0b <strtol+0x33>
		s++, neg = 1;
  800d01:	8d 52 01             	lea    0x1(%edx),%edx
  800d04:	bf 01 00 00 00       	mov    $0x1,%edi
  800d09:	eb 05                	jmp    800d10 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d0b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d10:	85 db                	test   %ebx,%ebx
  800d12:	74 05                	je     800d19 <strtol+0x41>
  800d14:	83 fb 10             	cmp    $0x10,%ebx
  800d17:	75 28                	jne    800d41 <strtol+0x69>
  800d19:	8a 02                	mov    (%edx),%al
  800d1b:	3c 30                	cmp    $0x30,%al
  800d1d:	75 10                	jne    800d2f <strtol+0x57>
  800d1f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d23:	75 0a                	jne    800d2f <strtol+0x57>
		s += 2, base = 16;
  800d25:	83 c2 02             	add    $0x2,%edx
  800d28:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d2d:	eb 12                	jmp    800d41 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d2f:	85 db                	test   %ebx,%ebx
  800d31:	75 0e                	jne    800d41 <strtol+0x69>
  800d33:	3c 30                	cmp    $0x30,%al
  800d35:	75 05                	jne    800d3c <strtol+0x64>
		s++, base = 8;
  800d37:	42                   	inc    %edx
  800d38:	b3 08                	mov    $0x8,%bl
  800d3a:	eb 05                	jmp    800d41 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d3c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d41:	b8 00 00 00 00       	mov    $0x0,%eax
  800d46:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d48:	8a 0a                	mov    (%edx),%cl
  800d4a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d4d:	80 fb 09             	cmp    $0x9,%bl
  800d50:	77 08                	ja     800d5a <strtol+0x82>
			dig = *s - '0';
  800d52:	0f be c9             	movsbl %cl,%ecx
  800d55:	83 e9 30             	sub    $0x30,%ecx
  800d58:	eb 1e                	jmp    800d78 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d5a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d5d:	80 fb 19             	cmp    $0x19,%bl
  800d60:	77 08                	ja     800d6a <strtol+0x92>
			dig = *s - 'a' + 10;
  800d62:	0f be c9             	movsbl %cl,%ecx
  800d65:	83 e9 57             	sub    $0x57,%ecx
  800d68:	eb 0e                	jmp    800d78 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d6a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d6d:	80 fb 19             	cmp    $0x19,%bl
  800d70:	77 12                	ja     800d84 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d72:	0f be c9             	movsbl %cl,%ecx
  800d75:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d78:	39 f1                	cmp    %esi,%ecx
  800d7a:	7d 0c                	jge    800d88 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d7c:	42                   	inc    %edx
  800d7d:	0f af c6             	imul   %esi,%eax
  800d80:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d82:	eb c4                	jmp    800d48 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d84:	89 c1                	mov    %eax,%ecx
  800d86:	eb 02                	jmp    800d8a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d88:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d8a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d8e:	74 05                	je     800d95 <strtol+0xbd>
		*endptr = (char *) s;
  800d90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d93:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d95:	85 ff                	test   %edi,%edi
  800d97:	74 04                	je     800d9d <strtol+0xc5>
  800d99:	89 c8                	mov    %ecx,%eax
  800d9b:	f7 d8                	neg    %eax
}
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    
	...

00800da4 <__udivdi3>:
  800da4:	55                   	push   %ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	83 ec 10             	sub    $0x10,%esp
  800daa:	8b 74 24 20          	mov    0x20(%esp),%esi
  800dae:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800db2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800db6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800dba:	89 cd                	mov    %ecx,%ebp
  800dbc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	75 2c                	jne    800df0 <__udivdi3+0x4c>
  800dc4:	39 f9                	cmp    %edi,%ecx
  800dc6:	77 68                	ja     800e30 <__udivdi3+0x8c>
  800dc8:	85 c9                	test   %ecx,%ecx
  800dca:	75 0b                	jne    800dd7 <__udivdi3+0x33>
  800dcc:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd1:	31 d2                	xor    %edx,%edx
  800dd3:	f7 f1                	div    %ecx
  800dd5:	89 c1                	mov    %eax,%ecx
  800dd7:	31 d2                	xor    %edx,%edx
  800dd9:	89 f8                	mov    %edi,%eax
  800ddb:	f7 f1                	div    %ecx
  800ddd:	89 c7                	mov    %eax,%edi
  800ddf:	89 f0                	mov    %esi,%eax
  800de1:	f7 f1                	div    %ecx
  800de3:	89 c6                	mov    %eax,%esi
  800de5:	89 f0                	mov    %esi,%eax
  800de7:	89 fa                	mov    %edi,%edx
  800de9:	83 c4 10             	add    $0x10,%esp
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    
  800df0:	39 f8                	cmp    %edi,%eax
  800df2:	77 2c                	ja     800e20 <__udivdi3+0x7c>
  800df4:	0f bd f0             	bsr    %eax,%esi
  800df7:	83 f6 1f             	xor    $0x1f,%esi
  800dfa:	75 4c                	jne    800e48 <__udivdi3+0xa4>
  800dfc:	39 f8                	cmp    %edi,%eax
  800dfe:	bf 00 00 00 00       	mov    $0x0,%edi
  800e03:	72 0a                	jb     800e0f <__udivdi3+0x6b>
  800e05:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e09:	0f 87 ad 00 00 00    	ja     800ebc <__udivdi3+0x118>
  800e0f:	be 01 00 00 00       	mov    $0x1,%esi
  800e14:	89 f0                	mov    %esi,%eax
  800e16:	89 fa                	mov    %edi,%edx
  800e18:	83 c4 10             	add    $0x10,%esp
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    
  800e1f:	90                   	nop
  800e20:	31 ff                	xor    %edi,%edi
  800e22:	31 f6                	xor    %esi,%esi
  800e24:	89 f0                	mov    %esi,%eax
  800e26:	89 fa                	mov    %edi,%edx
  800e28:	83 c4 10             	add    $0x10,%esp
  800e2b:	5e                   	pop    %esi
  800e2c:	5f                   	pop    %edi
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    
  800e2f:	90                   	nop
  800e30:	89 fa                	mov    %edi,%edx
  800e32:	89 f0                	mov    %esi,%eax
  800e34:	f7 f1                	div    %ecx
  800e36:	89 c6                	mov    %eax,%esi
  800e38:	31 ff                	xor    %edi,%edi
  800e3a:	89 f0                	mov    %esi,%eax
  800e3c:	89 fa                	mov    %edi,%edx
  800e3e:	83 c4 10             	add    $0x10,%esp
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    
  800e45:	8d 76 00             	lea    0x0(%esi),%esi
  800e48:	89 f1                	mov    %esi,%ecx
  800e4a:	d3 e0                	shl    %cl,%eax
  800e4c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e50:	b8 20 00 00 00       	mov    $0x20,%eax
  800e55:	29 f0                	sub    %esi,%eax
  800e57:	89 ea                	mov    %ebp,%edx
  800e59:	88 c1                	mov    %al,%cl
  800e5b:	d3 ea                	shr    %cl,%edx
  800e5d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e61:	09 ca                	or     %ecx,%edx
  800e63:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e67:	89 f1                	mov    %esi,%ecx
  800e69:	d3 e5                	shl    %cl,%ebp
  800e6b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800e6f:	89 fd                	mov    %edi,%ebp
  800e71:	88 c1                	mov    %al,%cl
  800e73:	d3 ed                	shr    %cl,%ebp
  800e75:	89 fa                	mov    %edi,%edx
  800e77:	89 f1                	mov    %esi,%ecx
  800e79:	d3 e2                	shl    %cl,%edx
  800e7b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e7f:	88 c1                	mov    %al,%cl
  800e81:	d3 ef                	shr    %cl,%edi
  800e83:	09 d7                	or     %edx,%edi
  800e85:	89 f8                	mov    %edi,%eax
  800e87:	89 ea                	mov    %ebp,%edx
  800e89:	f7 74 24 08          	divl   0x8(%esp)
  800e8d:	89 d1                	mov    %edx,%ecx
  800e8f:	89 c7                	mov    %eax,%edi
  800e91:	f7 64 24 0c          	mull   0xc(%esp)
  800e95:	39 d1                	cmp    %edx,%ecx
  800e97:	72 17                	jb     800eb0 <__udivdi3+0x10c>
  800e99:	74 09                	je     800ea4 <__udivdi3+0x100>
  800e9b:	89 fe                	mov    %edi,%esi
  800e9d:	31 ff                	xor    %edi,%edi
  800e9f:	e9 41 ff ff ff       	jmp    800de5 <__udivdi3+0x41>
  800ea4:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ea8:	89 f1                	mov    %esi,%ecx
  800eaa:	d3 e2                	shl    %cl,%edx
  800eac:	39 c2                	cmp    %eax,%edx
  800eae:	73 eb                	jae    800e9b <__udivdi3+0xf7>
  800eb0:	8d 77 ff             	lea    -0x1(%edi),%esi
  800eb3:	31 ff                	xor    %edi,%edi
  800eb5:	e9 2b ff ff ff       	jmp    800de5 <__udivdi3+0x41>
  800eba:	66 90                	xchg   %ax,%ax
  800ebc:	31 f6                	xor    %esi,%esi
  800ebe:	e9 22 ff ff ff       	jmp    800de5 <__udivdi3+0x41>
	...

00800ec4 <__umoddi3>:
  800ec4:	55                   	push   %ebp
  800ec5:	57                   	push   %edi
  800ec6:	56                   	push   %esi
  800ec7:	83 ec 20             	sub    $0x20,%esp
  800eca:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ece:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800ed2:	89 44 24 14          	mov    %eax,0x14(%esp)
  800ed6:	8b 74 24 34          	mov    0x34(%esp),%esi
  800eda:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ede:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800ee2:	89 c7                	mov    %eax,%edi
  800ee4:	89 f2                	mov    %esi,%edx
  800ee6:	85 ed                	test   %ebp,%ebp
  800ee8:	75 16                	jne    800f00 <__umoddi3+0x3c>
  800eea:	39 f1                	cmp    %esi,%ecx
  800eec:	0f 86 a6 00 00 00    	jbe    800f98 <__umoddi3+0xd4>
  800ef2:	f7 f1                	div    %ecx
  800ef4:	89 d0                	mov    %edx,%eax
  800ef6:	31 d2                	xor    %edx,%edx
  800ef8:	83 c4 20             	add    $0x20,%esp
  800efb:	5e                   	pop    %esi
  800efc:	5f                   	pop    %edi
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    
  800eff:	90                   	nop
  800f00:	39 f5                	cmp    %esi,%ebp
  800f02:	0f 87 ac 00 00 00    	ja     800fb4 <__umoddi3+0xf0>
  800f08:	0f bd c5             	bsr    %ebp,%eax
  800f0b:	83 f0 1f             	xor    $0x1f,%eax
  800f0e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f12:	0f 84 a8 00 00 00    	je     800fc0 <__umoddi3+0xfc>
  800f18:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f1c:	d3 e5                	shl    %cl,%ebp
  800f1e:	bf 20 00 00 00       	mov    $0x20,%edi
  800f23:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800f27:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f2b:	89 f9                	mov    %edi,%ecx
  800f2d:	d3 e8                	shr    %cl,%eax
  800f2f:	09 e8                	or     %ebp,%eax
  800f31:	89 44 24 18          	mov    %eax,0x18(%esp)
  800f35:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f39:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f3d:	d3 e0                	shl    %cl,%eax
  800f3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f43:	89 f2                	mov    %esi,%edx
  800f45:	d3 e2                	shl    %cl,%edx
  800f47:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f4b:	d3 e0                	shl    %cl,%eax
  800f4d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800f51:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f55:	89 f9                	mov    %edi,%ecx
  800f57:	d3 e8                	shr    %cl,%eax
  800f59:	09 d0                	or     %edx,%eax
  800f5b:	d3 ee                	shr    %cl,%esi
  800f5d:	89 f2                	mov    %esi,%edx
  800f5f:	f7 74 24 18          	divl   0x18(%esp)
  800f63:	89 d6                	mov    %edx,%esi
  800f65:	f7 64 24 0c          	mull   0xc(%esp)
  800f69:	89 c5                	mov    %eax,%ebp
  800f6b:	89 d1                	mov    %edx,%ecx
  800f6d:	39 d6                	cmp    %edx,%esi
  800f6f:	72 67                	jb     800fd8 <__umoddi3+0x114>
  800f71:	74 75                	je     800fe8 <__umoddi3+0x124>
  800f73:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f77:	29 e8                	sub    %ebp,%eax
  800f79:	19 ce                	sbb    %ecx,%esi
  800f7b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f7f:	d3 e8                	shr    %cl,%eax
  800f81:	89 f2                	mov    %esi,%edx
  800f83:	89 f9                	mov    %edi,%ecx
  800f85:	d3 e2                	shl    %cl,%edx
  800f87:	09 d0                	or     %edx,%eax
  800f89:	89 f2                	mov    %esi,%edx
  800f8b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f8f:	d3 ea                	shr    %cl,%edx
  800f91:	83 c4 20             	add    $0x20,%esp
  800f94:	5e                   	pop    %esi
  800f95:	5f                   	pop    %edi
  800f96:	5d                   	pop    %ebp
  800f97:	c3                   	ret    
  800f98:	85 c9                	test   %ecx,%ecx
  800f9a:	75 0b                	jne    800fa7 <__umoddi3+0xe3>
  800f9c:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa1:	31 d2                	xor    %edx,%edx
  800fa3:	f7 f1                	div    %ecx
  800fa5:	89 c1                	mov    %eax,%ecx
  800fa7:	89 f0                	mov    %esi,%eax
  800fa9:	31 d2                	xor    %edx,%edx
  800fab:	f7 f1                	div    %ecx
  800fad:	89 f8                	mov    %edi,%eax
  800faf:	e9 3e ff ff ff       	jmp    800ef2 <__umoddi3+0x2e>
  800fb4:	89 f2                	mov    %esi,%edx
  800fb6:	83 c4 20             	add    $0x20,%esp
  800fb9:	5e                   	pop    %esi
  800fba:	5f                   	pop    %edi
  800fbb:	5d                   	pop    %ebp
  800fbc:	c3                   	ret    
  800fbd:	8d 76 00             	lea    0x0(%esi),%esi
  800fc0:	39 f5                	cmp    %esi,%ebp
  800fc2:	72 04                	jb     800fc8 <__umoddi3+0x104>
  800fc4:	39 f9                	cmp    %edi,%ecx
  800fc6:	77 06                	ja     800fce <__umoddi3+0x10a>
  800fc8:	89 f2                	mov    %esi,%edx
  800fca:	29 cf                	sub    %ecx,%edi
  800fcc:	19 ea                	sbb    %ebp,%edx
  800fce:	89 f8                	mov    %edi,%eax
  800fd0:	83 c4 20             	add    $0x20,%esp
  800fd3:	5e                   	pop    %esi
  800fd4:	5f                   	pop    %edi
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    
  800fd7:	90                   	nop
  800fd8:	89 d1                	mov    %edx,%ecx
  800fda:	89 c5                	mov    %eax,%ebp
  800fdc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fe0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fe4:	eb 8d                	jmp    800f73 <__umoddi3+0xaf>
  800fe6:	66 90                	xchg   %ax,%ax
  800fe8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fec:	72 ea                	jb     800fd8 <__umoddi3+0x114>
  800fee:	89 f1                	mov    %esi,%ecx
  800ff0:	eb 81                	jmp    800f73 <__umoddi3+0xaf>
