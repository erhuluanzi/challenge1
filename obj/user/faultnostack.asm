
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 f8 03 80 	movl   $0x8003f8,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 8c 02 00 00       	call   8002da <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
	...

0080005c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	56                   	push   %esi
  800060:	53                   	push   %ebx
  800061:	83 ec 10             	sub    $0x10,%esp
  800064:	8b 75 08             	mov    0x8(%ebp),%esi
  800067:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80006a:	e8 e0 00 00 00       	call   80014f <sys_getenvid>
  80006f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800074:	8d 14 80             	lea    (%eax,%eax,4),%edx
  800077:	8d 04 50             	lea    (%eax,%edx,2),%eax
  80007a:	c1 e0 04             	shl    $0x4,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 f6                	test   %esi,%esi
  800089:	7e 07                	jle    800092 <libmain+0x36>
		binaryname = argv[0];
  80008b:	8b 03                	mov    (%ebx),%eax
  80008d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 96 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009e:	e8 09 00 00 00       	call   8000ac <exit>
}
  8000a3:	83 c4 10             	add    $0x10,%esp
  8000a6:	5b                   	pop    %ebx
  8000a7:	5e                   	pop    %esi
  8000a8:	5d                   	pop    %ebp
  8000a9:	c3                   	ret    
	...

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b9:	e8 3f 00 00 00       	call   8000fd <sys_env_destroy>
}
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d1:	89 c3                	mov    %eax,%ebx
  8000d3:	89 c7                	mov    %eax,%edi
  8000d5:	89 c6                	mov    %eax,%esi
  8000d7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <sys_cgetc>:

int
sys_cgetc(void)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	57                   	push   %edi
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ee:	89 d1                	mov    %edx,%ecx
  8000f0:	89 d3                	mov    %edx,%ebx
  8000f2:	89 d7                	mov    %edx,%edi
  8000f4:	89 d6                	mov    %edx,%esi
  8000f6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	5d                   	pop    %ebp
  8000fc:	c3                   	ret    

008000fd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	57                   	push   %edi
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800106:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010b:	b8 03 00 00 00       	mov    $0x3,%eax
  800110:	8b 55 08             	mov    0x8(%ebp),%edx
  800113:	89 cb                	mov    %ecx,%ebx
  800115:	89 cf                	mov    %ecx,%edi
  800117:	89 ce                	mov    %ecx,%esi
  800119:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80011b:	85 c0                	test   %eax,%eax
  80011d:	7e 28                	jle    800147 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80011f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800123:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80012a:	00 
  80012b:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  800132:	00 
  800133:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80013a:	00 
  80013b:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  800142:	e8 d9 02 00 00       	call   800420 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800147:	83 c4 2c             	add    $0x2c,%esp
  80014a:	5b                   	pop    %ebx
  80014b:	5e                   	pop    %esi
  80014c:	5f                   	pop    %edi
  80014d:	5d                   	pop    %ebp
  80014e:	c3                   	ret    

0080014f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	57                   	push   %edi
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800155:	ba 00 00 00 00       	mov    $0x0,%edx
  80015a:	b8 02 00 00 00       	mov    $0x2,%eax
  80015f:	89 d1                	mov    %edx,%ecx
  800161:	89 d3                	mov    %edx,%ebx
  800163:	89 d7                	mov    %edx,%edi
  800165:	89 d6                	mov    %edx,%esi
  800167:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800169:	5b                   	pop    %ebx
  80016a:	5e                   	pop    %esi
  80016b:	5f                   	pop    %edi
  80016c:	5d                   	pop    %ebp
  80016d:	c3                   	ret    

0080016e <sys_yield>:

void
sys_yield(void)
{
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	57                   	push   %edi
  800172:	56                   	push   %esi
  800173:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800174:	ba 00 00 00 00       	mov    $0x0,%edx
  800179:	b8 0a 00 00 00       	mov    $0xa,%eax
  80017e:	89 d1                	mov    %edx,%ecx
  800180:	89 d3                	mov    %edx,%ebx
  800182:	89 d7                	mov    %edx,%edi
  800184:	89 d6                	mov    %edx,%esi
  800186:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800188:	5b                   	pop    %ebx
  800189:	5e                   	pop    %esi
  80018a:	5f                   	pop    %edi
  80018b:	5d                   	pop    %ebp
  80018c:	c3                   	ret    

0080018d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	57                   	push   %edi
  800191:	56                   	push   %esi
  800192:	53                   	push   %ebx
  800193:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800196:	be 00 00 00 00       	mov    $0x0,%esi
  80019b:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a9:	89 f7                	mov    %esi,%edi
  8001ab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ad:	85 c0                	test   %eax,%eax
  8001af:	7e 28                	jle    8001d9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001bc:	00 
  8001bd:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001cc:	00 
  8001cd:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  8001d4:	e8 47 02 00 00       	call   800420 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d9:	83 c4 2c             	add    $0x2c,%esp
  8001dc:	5b                   	pop    %ebx
  8001dd:	5e                   	pop    %esi
  8001de:	5f                   	pop    %edi
  8001df:	5d                   	pop    %ebp
  8001e0:	c3                   	ret    

008001e1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	57                   	push   %edi
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ef:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800200:	85 c0                	test   %eax,%eax
  800202:	7e 28                	jle    80022c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800204:	89 44 24 10          	mov    %eax,0x10(%esp)
  800208:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80020f:	00 
  800210:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  800217:	00 
  800218:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80021f:	00 
  800220:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  800227:	e8 f4 01 00 00       	call   800420 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80022c:	83 c4 2c             	add    $0x2c,%esp
  80022f:	5b                   	pop    %ebx
  800230:	5e                   	pop    %esi
  800231:	5f                   	pop    %edi
  800232:	5d                   	pop    %ebp
  800233:	c3                   	ret    

00800234 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	57                   	push   %edi
  800238:	56                   	push   %esi
  800239:	53                   	push   %ebx
  80023a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800242:	b8 06 00 00 00       	mov    $0x6,%eax
  800247:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024a:	8b 55 08             	mov    0x8(%ebp),%edx
  80024d:	89 df                	mov    %ebx,%edi
  80024f:	89 de                	mov    %ebx,%esi
  800251:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800253:	85 c0                	test   %eax,%eax
  800255:	7e 28                	jle    80027f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800257:	89 44 24 10          	mov    %eax,0x10(%esp)
  80025b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800262:	00 
  800263:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  80026a:	00 
  80026b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800272:	00 
  800273:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  80027a:	e8 a1 01 00 00       	call   800420 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80027f:	83 c4 2c             	add    $0x2c,%esp
  800282:	5b                   	pop    %ebx
  800283:	5e                   	pop    %esi
  800284:	5f                   	pop    %edi
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    

00800287 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	57                   	push   %edi
  80028b:	56                   	push   %esi
  80028c:	53                   	push   %ebx
  80028d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800290:	bb 00 00 00 00       	mov    $0x0,%ebx
  800295:	b8 08 00 00 00       	mov    $0x8,%eax
  80029a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029d:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a0:	89 df                	mov    %ebx,%edi
  8002a2:	89 de                	mov    %ebx,%esi
  8002a4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002a6:	85 c0                	test   %eax,%eax
  8002a8:	7e 28                	jle    8002d2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ae:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002b5:	00 
  8002b6:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  8002bd:	00 
  8002be:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c5:	00 
  8002c6:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  8002cd:	e8 4e 01 00 00       	call   800420 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002d2:	83 c4 2c             	add    $0x2c,%esp
  8002d5:	5b                   	pop    %ebx
  8002d6:	5e                   	pop    %esi
  8002d7:	5f                   	pop    %edi
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	57                   	push   %edi
  8002de:	56                   	push   %esi
  8002df:	53                   	push   %ebx
  8002e0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e8:	b8 09 00 00 00       	mov    $0x9,%eax
  8002ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f3:	89 df                	mov    %ebx,%edi
  8002f5:	89 de                	mov    %ebx,%esi
  8002f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002f9:	85 c0                	test   %eax,%eax
  8002fb:	7e 28                	jle    800325 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800301:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800308:	00 
  800309:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  800310:	00 
  800311:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800318:	00 
  800319:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  800320:	e8 fb 00 00 00       	call   800420 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800325:	83 c4 2c             	add    $0x2c,%esp
  800328:	5b                   	pop    %ebx
  800329:	5e                   	pop    %esi
  80032a:	5f                   	pop    %edi
  80032b:	5d                   	pop    %ebp
  80032c:	c3                   	ret    

0080032d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	57                   	push   %edi
  800331:	56                   	push   %esi
  800332:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800333:	be 00 00 00 00       	mov    $0x0,%esi
  800338:	b8 0b 00 00 00       	mov    $0xb,%eax
  80033d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800340:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800343:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800346:	8b 55 08             	mov    0x8(%ebp),%edx
  800349:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80034b:	5b                   	pop    %ebx
  80034c:	5e                   	pop    %esi
  80034d:	5f                   	pop    %edi
  80034e:	5d                   	pop    %ebp
  80034f:	c3                   	ret    

00800350 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	57                   	push   %edi
  800354:	56                   	push   %esi
  800355:	53                   	push   %ebx
  800356:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800359:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800363:	8b 55 08             	mov    0x8(%ebp),%edx
  800366:	89 cb                	mov    %ecx,%ebx
  800368:	89 cf                	mov    %ecx,%edi
  80036a:	89 ce                	mov    %ecx,%esi
  80036c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80036e:	85 c0                	test   %eax,%eax
  800370:	7e 28                	jle    80039a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800372:	89 44 24 10          	mov    %eax,0x10(%esp)
  800376:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80037d:	00 
  80037e:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  800385:	00 
  800386:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80038d:	00 
  80038e:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  800395:	e8 86 00 00 00       	call   800420 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80039a:	83 c4 2c             	add    $0x2c,%esp
  80039d:	5b                   	pop    %ebx
  80039e:	5e                   	pop    %esi
  80039f:	5f                   	pop    %edi
  8003a0:	5d                   	pop    %ebp
  8003a1:	c3                   	ret    

008003a2 <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	57                   	push   %edi
  8003a6:	56                   	push   %esi
  8003a7:	53                   	push   %ebx
  8003a8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003b0:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bb:	89 df                	mov    %ebx,%edi
  8003bd:	89 de                	mov    %ebx,%esi
  8003bf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003c1:	85 c0                	test   %eax,%eax
  8003c3:	7e 28                	jle    8003ed <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003c9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003d0:	00 
  8003d1:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  8003d8:	00 
  8003d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003e0:	00 
  8003e1:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  8003e8:	e8 33 00 00 00       	call   800420 <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8003ed:	83 c4 2c             	add    $0x2c,%esp
  8003f0:	5b                   	pop    %ebx
  8003f1:	5e                   	pop    %esi
  8003f2:	5f                   	pop    %edi
  8003f3:	5d                   	pop    %ebp
  8003f4:	c3                   	ret    
  8003f5:	00 00                	add    %al,(%eax)
	...

008003f8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8003f8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8003f9:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8003fe:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800400:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// sub 4 from old esp
	movl 0x30(%esp), %eax
  800403:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  800407:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80040a:	89 44 24 30          	mov    %eax,0x30(%esp)
	// put old eip into the pre-reserved 4-byte space
	movl 0x28(%esp), %ebx
  80040e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800412:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  800414:	83 c4 08             	add    $0x8,%esp
	popal
  800417:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  800418:	83 c4 04             	add    $0x4,%esp
	popfl
  80041b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80041c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80041d:	c3                   	ret    
	...

00800420 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	56                   	push   %esi
  800424:	53                   	push   %ebx
  800425:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800428:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80042b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800431:	e8 19 fd ff ff       	call   80014f <sys_getenvid>
  800436:	8b 55 0c             	mov    0xc(%ebp),%edx
  800439:	89 54 24 10          	mov    %edx,0x10(%esp)
  80043d:	8b 55 08             	mov    0x8(%ebp),%edx
  800440:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800444:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800448:	89 44 24 04          	mov    %eax,0x4(%esp)
  80044c:	c7 04 24 18 11 80 00 	movl   $0x801118,(%esp)
  800453:	e8 c0 00 00 00       	call   800518 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800458:	89 74 24 04          	mov    %esi,0x4(%esp)
  80045c:	8b 45 10             	mov    0x10(%ebp),%eax
  80045f:	89 04 24             	mov    %eax,(%esp)
  800462:	e8 50 00 00 00       	call   8004b7 <vcprintf>
	cprintf("\n");
  800467:	c7 04 24 3b 11 80 00 	movl   $0x80113b,(%esp)
  80046e:	e8 a5 00 00 00       	call   800518 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800473:	cc                   	int3   
  800474:	eb fd                	jmp    800473 <_panic+0x53>
	...

00800478 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	53                   	push   %ebx
  80047c:	83 ec 14             	sub    $0x14,%esp
  80047f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800482:	8b 03                	mov    (%ebx),%eax
  800484:	8b 55 08             	mov    0x8(%ebp),%edx
  800487:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80048b:	40                   	inc    %eax
  80048c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80048e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800493:	75 19                	jne    8004ae <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800495:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80049c:	00 
  80049d:	8d 43 08             	lea    0x8(%ebx),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	e8 18 fc ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  8004a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004ae:	ff 43 04             	incl   0x4(%ebx)
}
  8004b1:	83 c4 14             	add    $0x14,%esp
  8004b4:	5b                   	pop    %ebx
  8004b5:	5d                   	pop    %ebp
  8004b6:	c3                   	ret    

008004b7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004b7:	55                   	push   %ebp
  8004b8:	89 e5                	mov    %esp,%ebp
  8004ba:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004c0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004c7:	00 00 00 
	b.cnt = 0;
  8004ca:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004d1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004db:	8b 45 08             	mov    0x8(%ebp),%eax
  8004de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ec:	c7 04 24 78 04 80 00 	movl   $0x800478,(%esp)
  8004f3:	e8 b4 01 00 00       	call   8006ac <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004f8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800502:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800508:	89 04 24             	mov    %eax,(%esp)
  80050b:	e8 b0 fb ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  800510:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800516:	c9                   	leave  
  800517:	c3                   	ret    

00800518 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800518:	55                   	push   %ebp
  800519:	89 e5                	mov    %esp,%ebp
  80051b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80051e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800521:	89 44 24 04          	mov    %eax,0x4(%esp)
  800525:	8b 45 08             	mov    0x8(%ebp),%eax
  800528:	89 04 24             	mov    %eax,(%esp)
  80052b:	e8 87 ff ff ff       	call   8004b7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800530:	c9                   	leave  
  800531:	c3                   	ret    
	...

00800534 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	57                   	push   %edi
  800538:	56                   	push   %esi
  800539:	53                   	push   %ebx
  80053a:	83 ec 3c             	sub    $0x3c,%esp
  80053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800540:	89 d7                	mov    %edx,%edi
  800542:	8b 45 08             	mov    0x8(%ebp),%eax
  800545:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800548:	8b 45 0c             	mov    0xc(%ebp),%eax
  80054b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800551:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800554:	85 c0                	test   %eax,%eax
  800556:	75 08                	jne    800560 <printnum+0x2c>
  800558:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80055b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80055e:	77 57                	ja     8005b7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800560:	89 74 24 10          	mov    %esi,0x10(%esp)
  800564:	4b                   	dec    %ebx
  800565:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800569:	8b 45 10             	mov    0x10(%ebp),%eax
  80056c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800570:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800574:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800578:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80057f:	00 
  800580:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800583:	89 04 24             	mov    %eax,(%esp)
  800586:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800589:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058d:	e8 ee 08 00 00       	call   800e80 <__udivdi3>
  800592:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800596:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80059a:	89 04 24             	mov    %eax,(%esp)
  80059d:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005a1:	89 fa                	mov    %edi,%edx
  8005a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005a6:	e8 89 ff ff ff       	call   800534 <printnum>
  8005ab:	eb 0f                	jmp    8005bc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005ad:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b1:	89 34 24             	mov    %esi,(%esp)
  8005b4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005b7:	4b                   	dec    %ebx
  8005b8:	85 db                	test   %ebx,%ebx
  8005ba:	7f f1                	jg     8005ad <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8005c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005cb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005d2:	00 
  8005d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005d6:	89 04 24             	mov    %eax,(%esp)
  8005d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e0:	e8 bb 09 00 00       	call   800fa0 <__umoddi3>
  8005e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e9:	0f be 80 3d 11 80 00 	movsbl 0x80113d(%eax),%eax
  8005f0:	89 04 24             	mov    %eax,(%esp)
  8005f3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8005f6:	83 c4 3c             	add    $0x3c,%esp
  8005f9:	5b                   	pop    %ebx
  8005fa:	5e                   	pop    %esi
  8005fb:	5f                   	pop    %edi
  8005fc:	5d                   	pop    %ebp
  8005fd:	c3                   	ret    

008005fe <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005fe:	55                   	push   %ebp
  8005ff:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800601:	83 fa 01             	cmp    $0x1,%edx
  800604:	7e 0e                	jle    800614 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800606:	8b 10                	mov    (%eax),%edx
  800608:	8d 4a 08             	lea    0x8(%edx),%ecx
  80060b:	89 08                	mov    %ecx,(%eax)
  80060d:	8b 02                	mov    (%edx),%eax
  80060f:	8b 52 04             	mov    0x4(%edx),%edx
  800612:	eb 22                	jmp    800636 <getuint+0x38>
	else if (lflag)
  800614:	85 d2                	test   %edx,%edx
  800616:	74 10                	je     800628 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800618:	8b 10                	mov    (%eax),%edx
  80061a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80061d:	89 08                	mov    %ecx,(%eax)
  80061f:	8b 02                	mov    (%edx),%eax
  800621:	ba 00 00 00 00       	mov    $0x0,%edx
  800626:	eb 0e                	jmp    800636 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800628:	8b 10                	mov    (%eax),%edx
  80062a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80062d:	89 08                	mov    %ecx,(%eax)
  80062f:	8b 02                	mov    (%edx),%eax
  800631:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800636:	5d                   	pop    %ebp
  800637:	c3                   	ret    

00800638 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800638:	55                   	push   %ebp
  800639:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80063b:	83 fa 01             	cmp    $0x1,%edx
  80063e:	7e 0e                	jle    80064e <getint+0x16>
		return va_arg(*ap, long long);
  800640:	8b 10                	mov    (%eax),%edx
  800642:	8d 4a 08             	lea    0x8(%edx),%ecx
  800645:	89 08                	mov    %ecx,(%eax)
  800647:	8b 02                	mov    (%edx),%eax
  800649:	8b 52 04             	mov    0x4(%edx),%edx
  80064c:	eb 1a                	jmp    800668 <getint+0x30>
	else if (lflag)
  80064e:	85 d2                	test   %edx,%edx
  800650:	74 0c                	je     80065e <getint+0x26>
		return va_arg(*ap, long);
  800652:	8b 10                	mov    (%eax),%edx
  800654:	8d 4a 04             	lea    0x4(%edx),%ecx
  800657:	89 08                	mov    %ecx,(%eax)
  800659:	8b 02                	mov    (%edx),%eax
  80065b:	99                   	cltd   
  80065c:	eb 0a                	jmp    800668 <getint+0x30>
	else
		return va_arg(*ap, int);
  80065e:	8b 10                	mov    (%eax),%edx
  800660:	8d 4a 04             	lea    0x4(%edx),%ecx
  800663:	89 08                	mov    %ecx,(%eax)
  800665:	8b 02                	mov    (%edx),%eax
  800667:	99                   	cltd   
}
  800668:	5d                   	pop    %ebp
  800669:	c3                   	ret    

0080066a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80066a:	55                   	push   %ebp
  80066b:	89 e5                	mov    %esp,%ebp
  80066d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800670:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800673:	8b 10                	mov    (%eax),%edx
  800675:	3b 50 04             	cmp    0x4(%eax),%edx
  800678:	73 08                	jae    800682 <sprintputch+0x18>
		*b->buf++ = ch;
  80067a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80067d:	88 0a                	mov    %cl,(%edx)
  80067f:	42                   	inc    %edx
  800680:	89 10                	mov    %edx,(%eax)
}
  800682:	5d                   	pop    %ebp
  800683:	c3                   	ret    

00800684 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800684:	55                   	push   %ebp
  800685:	89 e5                	mov    %esp,%ebp
  800687:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80068a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80068d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800691:	8b 45 10             	mov    0x10(%ebp),%eax
  800694:	89 44 24 08          	mov    %eax,0x8(%esp)
  800698:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069f:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a2:	89 04 24             	mov    %eax,(%esp)
  8006a5:	e8 02 00 00 00       	call   8006ac <vprintfmt>
	va_end(ap);
}
  8006aa:	c9                   	leave  
  8006ab:	c3                   	ret    

008006ac <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ac:	55                   	push   %ebp
  8006ad:	89 e5                	mov    %esp,%ebp
  8006af:	57                   	push   %edi
  8006b0:	56                   	push   %esi
  8006b1:	53                   	push   %ebx
  8006b2:	83 ec 4c             	sub    $0x4c,%esp
  8006b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b8:	8b 75 10             	mov    0x10(%ebp),%esi
  8006bb:	eb 12                	jmp    8006cf <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006bd:	85 c0                	test   %eax,%eax
  8006bf:	0f 84 40 03 00 00    	je     800a05 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  8006c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c9:	89 04 24             	mov    %eax,(%esp)
  8006cc:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006cf:	0f b6 06             	movzbl (%esi),%eax
  8006d2:	46                   	inc    %esi
  8006d3:	83 f8 25             	cmp    $0x25,%eax
  8006d6:	75 e5                	jne    8006bd <vprintfmt+0x11>
  8006d8:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006dc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006e3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006e8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f4:	eb 26                	jmp    80071c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f6:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006f9:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8006fd:	eb 1d                	jmp    80071c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800702:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800706:	eb 14                	jmp    80071c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800708:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80070b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800712:	eb 08                	jmp    80071c <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800714:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800717:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071c:	0f b6 06             	movzbl (%esi),%eax
  80071f:	8d 4e 01             	lea    0x1(%esi),%ecx
  800722:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800725:	8a 0e                	mov    (%esi),%cl
  800727:	83 e9 23             	sub    $0x23,%ecx
  80072a:	80 f9 55             	cmp    $0x55,%cl
  80072d:	0f 87 b6 02 00 00    	ja     8009e9 <vprintfmt+0x33d>
  800733:	0f b6 c9             	movzbl %cl,%ecx
  800736:	ff 24 8d 00 12 80 00 	jmp    *0x801200(,%ecx,4)
  80073d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800740:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800745:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800748:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  80074c:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80074f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800752:	83 f9 09             	cmp    $0x9,%ecx
  800755:	77 2a                	ja     800781 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800757:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800758:	eb eb                	jmp    800745 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80075a:	8b 45 14             	mov    0x14(%ebp),%eax
  80075d:	8d 48 04             	lea    0x4(%eax),%ecx
  800760:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800763:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800765:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800768:	eb 17                	jmp    800781 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80076a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80076e:	78 98                	js     800708 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800770:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800773:	eb a7                	jmp    80071c <vprintfmt+0x70>
  800775:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800778:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80077f:	eb 9b                	jmp    80071c <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800781:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800785:	79 95                	jns    80071c <vprintfmt+0x70>
  800787:	eb 8b                	jmp    800714 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800789:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80078d:	eb 8d                	jmp    80071c <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	8d 50 04             	lea    0x4(%eax),%edx
  800795:	89 55 14             	mov    %edx,0x14(%ebp)
  800798:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079c:	8b 00                	mov    (%eax),%eax
  80079e:	89 04 24             	mov    %eax,(%esp)
  8007a1:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007a7:	e9 23 ff ff ff       	jmp    8006cf <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8007af:	8d 50 04             	lea    0x4(%eax),%edx
  8007b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b5:	8b 00                	mov    (%eax),%eax
  8007b7:	85 c0                	test   %eax,%eax
  8007b9:	79 02                	jns    8007bd <vprintfmt+0x111>
  8007bb:	f7 d8                	neg    %eax
  8007bd:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007bf:	83 f8 09             	cmp    $0x9,%eax
  8007c2:	7f 0b                	jg     8007cf <vprintfmt+0x123>
  8007c4:	8b 04 85 60 13 80 00 	mov    0x801360(,%eax,4),%eax
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	75 23                	jne    8007f2 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8007cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007d3:	c7 44 24 08 55 11 80 	movl   $0x801155,0x8(%esp)
  8007da:	00 
  8007db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	89 04 24             	mov    %eax,(%esp)
  8007e5:	e8 9a fe ff ff       	call   800684 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007ed:	e9 dd fe ff ff       	jmp    8006cf <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8007f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f6:	c7 44 24 08 5e 11 80 	movl   $0x80115e,0x8(%esp)
  8007fd:	00 
  8007fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800802:	8b 55 08             	mov    0x8(%ebp),%edx
  800805:	89 14 24             	mov    %edx,(%esp)
  800808:	e8 77 fe ff ff       	call   800684 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800810:	e9 ba fe ff ff       	jmp    8006cf <vprintfmt+0x23>
  800815:	89 f9                	mov    %edi,%ecx
  800817:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80081a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80081d:	8b 45 14             	mov    0x14(%ebp),%eax
  800820:	8d 50 04             	lea    0x4(%eax),%edx
  800823:	89 55 14             	mov    %edx,0x14(%ebp)
  800826:	8b 30                	mov    (%eax),%esi
  800828:	85 f6                	test   %esi,%esi
  80082a:	75 05                	jne    800831 <vprintfmt+0x185>
				p = "(null)";
  80082c:	be 4e 11 80 00       	mov    $0x80114e,%esi
			if (width > 0 && padc != '-')
  800831:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800835:	0f 8e 84 00 00 00    	jle    8008bf <vprintfmt+0x213>
  80083b:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80083f:	74 7e                	je     8008bf <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800841:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800845:	89 34 24             	mov    %esi,(%esp)
  800848:	e8 5d 02 00 00       	call   800aaa <strnlen>
  80084d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800850:	29 c2                	sub    %eax,%edx
  800852:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800855:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800859:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80085c:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80085f:	89 de                	mov    %ebx,%esi
  800861:	89 d3                	mov    %edx,%ebx
  800863:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800865:	eb 0b                	jmp    800872 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800867:	89 74 24 04          	mov    %esi,0x4(%esp)
  80086b:	89 3c 24             	mov    %edi,(%esp)
  80086e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800871:	4b                   	dec    %ebx
  800872:	85 db                	test   %ebx,%ebx
  800874:	7f f1                	jg     800867 <vprintfmt+0x1bb>
  800876:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800879:	89 f3                	mov    %esi,%ebx
  80087b:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80087e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800881:	85 c0                	test   %eax,%eax
  800883:	79 05                	jns    80088a <vprintfmt+0x1de>
  800885:	b8 00 00 00 00       	mov    $0x0,%eax
  80088a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80088d:	29 c2                	sub    %eax,%edx
  80088f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800892:	eb 2b                	jmp    8008bf <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800894:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800898:	74 18                	je     8008b2 <vprintfmt+0x206>
  80089a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80089d:	83 fa 5e             	cmp    $0x5e,%edx
  8008a0:	76 10                	jbe    8008b2 <vprintfmt+0x206>
					putch('?', putdat);
  8008a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008ad:	ff 55 08             	call   *0x8(%ebp)
  8008b0:	eb 0a                	jmp    8008bc <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8008b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b6:	89 04 24             	mov    %eax,(%esp)
  8008b9:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008bc:	ff 4d e4             	decl   -0x1c(%ebp)
  8008bf:	0f be 06             	movsbl (%esi),%eax
  8008c2:	46                   	inc    %esi
  8008c3:	85 c0                	test   %eax,%eax
  8008c5:	74 21                	je     8008e8 <vprintfmt+0x23c>
  8008c7:	85 ff                	test   %edi,%edi
  8008c9:	78 c9                	js     800894 <vprintfmt+0x1e8>
  8008cb:	4f                   	dec    %edi
  8008cc:	79 c6                	jns    800894 <vprintfmt+0x1e8>
  8008ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d1:	89 de                	mov    %ebx,%esi
  8008d3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008d6:	eb 18                	jmp    8008f0 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008dc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008e3:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008e5:	4b                   	dec    %ebx
  8008e6:	eb 08                	jmp    8008f0 <vprintfmt+0x244>
  8008e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008eb:	89 de                	mov    %ebx,%esi
  8008ed:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008f0:	85 db                	test   %ebx,%ebx
  8008f2:	7f e4                	jg     8008d8 <vprintfmt+0x22c>
  8008f4:	89 7d 08             	mov    %edi,0x8(%ebp)
  8008f7:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008fc:	e9 ce fd ff ff       	jmp    8006cf <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800901:	8d 45 14             	lea    0x14(%ebp),%eax
  800904:	e8 2f fd ff ff       	call   800638 <getint>
  800909:	89 c6                	mov    %eax,%esi
  80090b:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  80090d:	85 d2                	test   %edx,%edx
  80090f:	78 07                	js     800918 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800911:	be 0a 00 00 00       	mov    $0xa,%esi
  800916:	eb 7e                	jmp    800996 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800918:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80091c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800923:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800926:	89 f0                	mov    %esi,%eax
  800928:	89 fa                	mov    %edi,%edx
  80092a:	f7 d8                	neg    %eax
  80092c:	83 d2 00             	adc    $0x0,%edx
  80092f:	f7 da                	neg    %edx
			}
			base = 10;
  800931:	be 0a 00 00 00       	mov    $0xa,%esi
  800936:	eb 5e                	jmp    800996 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800938:	8d 45 14             	lea    0x14(%ebp),%eax
  80093b:	e8 be fc ff ff       	call   8005fe <getuint>
			base = 10;
  800940:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800945:	eb 4f                	jmp    800996 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800947:	8d 45 14             	lea    0x14(%ebp),%eax
  80094a:	e8 af fc ff ff       	call   8005fe <getuint>
			base = 8;
  80094f:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800954:	eb 40                	jmp    800996 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  800956:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80095a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800961:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800964:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800968:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80096f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800972:	8b 45 14             	mov    0x14(%ebp),%eax
  800975:	8d 50 04             	lea    0x4(%eax),%edx
  800978:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80097b:	8b 00                	mov    (%eax),%eax
  80097d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800982:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800987:	eb 0d                	jmp    800996 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800989:	8d 45 14             	lea    0x14(%ebp),%eax
  80098c:	e8 6d fc ff ff       	call   8005fe <getuint>
			base = 16;
  800991:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800996:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  80099a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80099e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8009a1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8009a5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8009a9:	89 04 24             	mov    %eax,(%esp)
  8009ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009b0:	89 da                	mov    %ebx,%edx
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	e8 7a fb ff ff       	call   800534 <printnum>
			break;
  8009ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8009bd:	e9 0d fd ff ff       	jmp    8006cf <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  8009c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8009c5:	e8 6e fc ff ff       	call   800638 <getint>
  8009ca:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  8009d2:	e9 f8 fc ff ff       	jmp    8006cf <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009db:	89 04 24             	mov    %eax,(%esp)
  8009de:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009e1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009e4:	e9 e6 fc ff ff       	jmp    8006cf <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ed:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009f4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009f7:	eb 01                	jmp    8009fa <vprintfmt+0x34e>
  8009f9:	4e                   	dec    %esi
  8009fa:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009fe:	75 f9                	jne    8009f9 <vprintfmt+0x34d>
  800a00:	e9 ca fc ff ff       	jmp    8006cf <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a05:	83 c4 4c             	add    $0x4c,%esp
  800a08:	5b                   	pop    %ebx
  800a09:	5e                   	pop    %esi
  800a0a:	5f                   	pop    %edi
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    

00800a0d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	83 ec 28             	sub    $0x28,%esp
  800a13:	8b 45 08             	mov    0x8(%ebp),%eax
  800a16:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a19:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a1c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a20:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a2a:	85 c0                	test   %eax,%eax
  800a2c:	74 30                	je     800a5e <vsnprintf+0x51>
  800a2e:	85 d2                	test   %edx,%edx
  800a30:	7e 33                	jle    800a65 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a32:	8b 45 14             	mov    0x14(%ebp),%eax
  800a35:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a39:	8b 45 10             	mov    0x10(%ebp),%eax
  800a3c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a40:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a43:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a47:	c7 04 24 6a 06 80 00 	movl   $0x80066a,(%esp)
  800a4e:	e8 59 fc ff ff       	call   8006ac <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a53:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a56:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a5c:	eb 0c                	jmp    800a6a <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a5e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a63:	eb 05                	jmp    800a6a <vsnprintf+0x5d>
  800a65:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a6a:	c9                   	leave  
  800a6b:	c3                   	ret    

00800a6c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a72:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a75:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a79:	8b 45 10             	mov    0x10(%ebp),%eax
  800a7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a83:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a87:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8a:	89 04 24             	mov    %eax,(%esp)
  800a8d:	e8 7b ff ff ff       	call   800a0d <vsnprintf>
	va_end(ap);

	return rc;
}
  800a92:	c9                   	leave  
  800a93:	c3                   	ret    

00800a94 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9f:	eb 01                	jmp    800aa2 <strlen+0xe>
		n++;
  800aa1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800aa2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800aa6:	75 f9                	jne    800aa1 <strlen+0xd>
		n++;
	return n;
}
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800ab0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ab3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab8:	eb 01                	jmp    800abb <strnlen+0x11>
		n++;
  800aba:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800abb:	39 d0                	cmp    %edx,%eax
  800abd:	74 06                	je     800ac5 <strnlen+0x1b>
  800abf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800ac3:	75 f5                	jne    800aba <strnlen+0x10>
		n++;
	return n;
}
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	53                   	push   %ebx
  800acb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ace:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ad1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800ad9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800adc:	42                   	inc    %edx
  800add:	84 c9                	test   %cl,%cl
  800adf:	75 f5                	jne    800ad6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	53                   	push   %ebx
  800ae8:	83 ec 08             	sub    $0x8,%esp
  800aeb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aee:	89 1c 24             	mov    %ebx,(%esp)
  800af1:	e8 9e ff ff ff       	call   800a94 <strlen>
	strcpy(dst + len, src);
  800af6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800afd:	01 d8                	add    %ebx,%eax
  800aff:	89 04 24             	mov    %eax,(%esp)
  800b02:	e8 c0 ff ff ff       	call   800ac7 <strcpy>
	return dst;
}
  800b07:	89 d8                	mov    %ebx,%eax
  800b09:	83 c4 08             	add    $0x8,%esp
  800b0c:	5b                   	pop    %ebx
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
  800b14:	8b 45 08             	mov    0x8(%ebp),%eax
  800b17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b22:	eb 0c                	jmp    800b30 <strncpy+0x21>
		*dst++ = *src;
  800b24:	8a 1a                	mov    (%edx),%bl
  800b26:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b29:	80 3a 01             	cmpb   $0x1,(%edx)
  800b2c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b2f:	41                   	inc    %ecx
  800b30:	39 f1                	cmp    %esi,%ecx
  800b32:	75 f0                	jne    800b24 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	8b 75 08             	mov    0x8(%ebp),%esi
  800b40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b43:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b46:	85 d2                	test   %edx,%edx
  800b48:	75 0a                	jne    800b54 <strlcpy+0x1c>
  800b4a:	89 f0                	mov    %esi,%eax
  800b4c:	eb 1a                	jmp    800b68 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b4e:	88 18                	mov    %bl,(%eax)
  800b50:	40                   	inc    %eax
  800b51:	41                   	inc    %ecx
  800b52:	eb 02                	jmp    800b56 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b54:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b56:	4a                   	dec    %edx
  800b57:	74 0a                	je     800b63 <strlcpy+0x2b>
  800b59:	8a 19                	mov    (%ecx),%bl
  800b5b:	84 db                	test   %bl,%bl
  800b5d:	75 ef                	jne    800b4e <strlcpy+0x16>
  800b5f:	89 c2                	mov    %eax,%edx
  800b61:	eb 02                	jmp    800b65 <strlcpy+0x2d>
  800b63:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b65:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b68:	29 f0                	sub    %esi,%eax
}
  800b6a:	5b                   	pop    %ebx
  800b6b:	5e                   	pop    %esi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b74:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b77:	eb 02                	jmp    800b7b <strcmp+0xd>
		p++, q++;
  800b79:	41                   	inc    %ecx
  800b7a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b7b:	8a 01                	mov    (%ecx),%al
  800b7d:	84 c0                	test   %al,%al
  800b7f:	74 04                	je     800b85 <strcmp+0x17>
  800b81:	3a 02                	cmp    (%edx),%al
  800b83:	74 f4                	je     800b79 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b85:	0f b6 c0             	movzbl %al,%eax
  800b88:	0f b6 12             	movzbl (%edx),%edx
  800b8b:	29 d0                	sub    %edx,%eax
}
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	53                   	push   %ebx
  800b93:	8b 45 08             	mov    0x8(%ebp),%eax
  800b96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b99:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b9c:	eb 03                	jmp    800ba1 <strncmp+0x12>
		n--, p++, q++;
  800b9e:	4a                   	dec    %edx
  800b9f:	40                   	inc    %eax
  800ba0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ba1:	85 d2                	test   %edx,%edx
  800ba3:	74 14                	je     800bb9 <strncmp+0x2a>
  800ba5:	8a 18                	mov    (%eax),%bl
  800ba7:	84 db                	test   %bl,%bl
  800ba9:	74 04                	je     800baf <strncmp+0x20>
  800bab:	3a 19                	cmp    (%ecx),%bl
  800bad:	74 ef                	je     800b9e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800baf:	0f b6 00             	movzbl (%eax),%eax
  800bb2:	0f b6 11             	movzbl (%ecx),%edx
  800bb5:	29 d0                	sub    %edx,%eax
  800bb7:	eb 05                	jmp    800bbe <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bb9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bbe:	5b                   	pop    %ebx
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bca:	eb 05                	jmp    800bd1 <strchr+0x10>
		if (*s == c)
  800bcc:	38 ca                	cmp    %cl,%dl
  800bce:	74 0c                	je     800bdc <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bd0:	40                   	inc    %eax
  800bd1:	8a 10                	mov    (%eax),%dl
  800bd3:	84 d2                	test   %dl,%dl
  800bd5:	75 f5                	jne    800bcc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800bd7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	8b 45 08             	mov    0x8(%ebp),%eax
  800be4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800be7:	eb 05                	jmp    800bee <strfind+0x10>
		if (*s == c)
  800be9:	38 ca                	cmp    %cl,%dl
  800beb:	74 07                	je     800bf4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bed:	40                   	inc    %eax
  800bee:	8a 10                	mov    (%eax),%dl
  800bf0:	84 d2                	test   %dl,%dl
  800bf2:	75 f5                	jne    800be9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
  800bfc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c05:	85 c9                	test   %ecx,%ecx
  800c07:	74 30                	je     800c39 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c09:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c0f:	75 25                	jne    800c36 <memset+0x40>
  800c11:	f6 c1 03             	test   $0x3,%cl
  800c14:	75 20                	jne    800c36 <memset+0x40>
		c &= 0xFF;
  800c16:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c19:	89 d3                	mov    %edx,%ebx
  800c1b:	c1 e3 08             	shl    $0x8,%ebx
  800c1e:	89 d6                	mov    %edx,%esi
  800c20:	c1 e6 18             	shl    $0x18,%esi
  800c23:	89 d0                	mov    %edx,%eax
  800c25:	c1 e0 10             	shl    $0x10,%eax
  800c28:	09 f0                	or     %esi,%eax
  800c2a:	09 d0                	or     %edx,%eax
  800c2c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c2e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c31:	fc                   	cld    
  800c32:	f3 ab                	rep stos %eax,%es:(%edi)
  800c34:	eb 03                	jmp    800c39 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c36:	fc                   	cld    
  800c37:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c39:	89 f8                	mov    %edi,%eax
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	8b 45 08             	mov    0x8(%ebp),%eax
  800c48:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c4b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c4e:	39 c6                	cmp    %eax,%esi
  800c50:	73 34                	jae    800c86 <memmove+0x46>
  800c52:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c55:	39 d0                	cmp    %edx,%eax
  800c57:	73 2d                	jae    800c86 <memmove+0x46>
		s += n;
		d += n;
  800c59:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c5c:	f6 c2 03             	test   $0x3,%dl
  800c5f:	75 1b                	jne    800c7c <memmove+0x3c>
  800c61:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c67:	75 13                	jne    800c7c <memmove+0x3c>
  800c69:	f6 c1 03             	test   $0x3,%cl
  800c6c:	75 0e                	jne    800c7c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c6e:	83 ef 04             	sub    $0x4,%edi
  800c71:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c74:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c77:	fd                   	std    
  800c78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c7a:	eb 07                	jmp    800c83 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c7c:	4f                   	dec    %edi
  800c7d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c80:	fd                   	std    
  800c81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c83:	fc                   	cld    
  800c84:	eb 20                	jmp    800ca6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c86:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c8c:	75 13                	jne    800ca1 <memmove+0x61>
  800c8e:	a8 03                	test   $0x3,%al
  800c90:	75 0f                	jne    800ca1 <memmove+0x61>
  800c92:	f6 c1 03             	test   $0x3,%cl
  800c95:	75 0a                	jne    800ca1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c97:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c9a:	89 c7                	mov    %eax,%edi
  800c9c:	fc                   	cld    
  800c9d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c9f:	eb 05                	jmp    800ca6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ca1:	89 c7                	mov    %eax,%edi
  800ca3:	fc                   	cld    
  800ca4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cb0:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cba:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc1:	89 04 24             	mov    %eax,(%esp)
  800cc4:	e8 77 ff ff ff       	call   800c40 <memmove>
}
  800cc9:	c9                   	leave  
  800cca:	c3                   	ret    

00800ccb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cd4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cda:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdf:	eb 16                	jmp    800cf7 <memcmp+0x2c>
		if (*s1 != *s2)
  800ce1:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ce4:	42                   	inc    %edx
  800ce5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800ce9:	38 c8                	cmp    %cl,%al
  800ceb:	74 0a                	je     800cf7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ced:	0f b6 c0             	movzbl %al,%eax
  800cf0:	0f b6 c9             	movzbl %cl,%ecx
  800cf3:	29 c8                	sub    %ecx,%eax
  800cf5:	eb 09                	jmp    800d00 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf7:	39 da                	cmp    %ebx,%edx
  800cf9:	75 e6                	jne    800ce1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cfb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d0e:	89 c2                	mov    %eax,%edx
  800d10:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d13:	eb 05                	jmp    800d1a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d15:	38 08                	cmp    %cl,(%eax)
  800d17:	74 05                	je     800d1e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d19:	40                   	inc    %eax
  800d1a:	39 d0                	cmp    %edx,%eax
  800d1c:	72 f7                	jb     800d15 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	57                   	push   %edi
  800d24:	56                   	push   %esi
  800d25:	53                   	push   %ebx
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d2c:	eb 01                	jmp    800d2f <strtol+0xf>
		s++;
  800d2e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d2f:	8a 02                	mov    (%edx),%al
  800d31:	3c 20                	cmp    $0x20,%al
  800d33:	74 f9                	je     800d2e <strtol+0xe>
  800d35:	3c 09                	cmp    $0x9,%al
  800d37:	74 f5                	je     800d2e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d39:	3c 2b                	cmp    $0x2b,%al
  800d3b:	75 08                	jne    800d45 <strtol+0x25>
		s++;
  800d3d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d3e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d43:	eb 13                	jmp    800d58 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d45:	3c 2d                	cmp    $0x2d,%al
  800d47:	75 0a                	jne    800d53 <strtol+0x33>
		s++, neg = 1;
  800d49:	8d 52 01             	lea    0x1(%edx),%edx
  800d4c:	bf 01 00 00 00       	mov    $0x1,%edi
  800d51:	eb 05                	jmp    800d58 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d53:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d58:	85 db                	test   %ebx,%ebx
  800d5a:	74 05                	je     800d61 <strtol+0x41>
  800d5c:	83 fb 10             	cmp    $0x10,%ebx
  800d5f:	75 28                	jne    800d89 <strtol+0x69>
  800d61:	8a 02                	mov    (%edx),%al
  800d63:	3c 30                	cmp    $0x30,%al
  800d65:	75 10                	jne    800d77 <strtol+0x57>
  800d67:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d6b:	75 0a                	jne    800d77 <strtol+0x57>
		s += 2, base = 16;
  800d6d:	83 c2 02             	add    $0x2,%edx
  800d70:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d75:	eb 12                	jmp    800d89 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d77:	85 db                	test   %ebx,%ebx
  800d79:	75 0e                	jne    800d89 <strtol+0x69>
  800d7b:	3c 30                	cmp    $0x30,%al
  800d7d:	75 05                	jne    800d84 <strtol+0x64>
		s++, base = 8;
  800d7f:	42                   	inc    %edx
  800d80:	b3 08                	mov    $0x8,%bl
  800d82:	eb 05                	jmp    800d89 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d84:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d89:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d90:	8a 0a                	mov    (%edx),%cl
  800d92:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d95:	80 fb 09             	cmp    $0x9,%bl
  800d98:	77 08                	ja     800da2 <strtol+0x82>
			dig = *s - '0';
  800d9a:	0f be c9             	movsbl %cl,%ecx
  800d9d:	83 e9 30             	sub    $0x30,%ecx
  800da0:	eb 1e                	jmp    800dc0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800da2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800da5:	80 fb 19             	cmp    $0x19,%bl
  800da8:	77 08                	ja     800db2 <strtol+0x92>
			dig = *s - 'a' + 10;
  800daa:	0f be c9             	movsbl %cl,%ecx
  800dad:	83 e9 57             	sub    $0x57,%ecx
  800db0:	eb 0e                	jmp    800dc0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800db2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800db5:	80 fb 19             	cmp    $0x19,%bl
  800db8:	77 12                	ja     800dcc <strtol+0xac>
			dig = *s - 'A' + 10;
  800dba:	0f be c9             	movsbl %cl,%ecx
  800dbd:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dc0:	39 f1                	cmp    %esi,%ecx
  800dc2:	7d 0c                	jge    800dd0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800dc4:	42                   	inc    %edx
  800dc5:	0f af c6             	imul   %esi,%eax
  800dc8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800dca:	eb c4                	jmp    800d90 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800dcc:	89 c1                	mov    %eax,%ecx
  800dce:	eb 02                	jmp    800dd2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800dd0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800dd2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dd6:	74 05                	je     800ddd <strtol+0xbd>
		*endptr = (char *) s;
  800dd8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ddb:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ddd:	85 ff                	test   %edi,%edi
  800ddf:	74 04                	je     800de5 <strtol+0xc5>
  800de1:	89 c8                	mov    %ecx,%eax
  800de3:	f7 d8                	neg    %eax
}
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    
	...

00800dec <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800df2:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800df9:	75 40                	jne    800e3b <set_pgfault_handler+0x4f>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
  800dfb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e02:	00 
  800e03:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800e0a:	ee 
  800e0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e12:	e8 76 f3 ff ff       	call   80018d <sys_page_alloc>
  800e17:	85 c0                	test   %eax,%eax
  800e19:	79 20                	jns    800e3b <set_pgfault_handler+0x4f>
            panic("set_pgfault_handler: sys_page_alloc: %e", r);
  800e1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e1f:	c7 44 24 08 88 13 80 	movl   $0x801388,0x8(%esp)
  800e26:	00 
  800e27:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800e2e:	00 
  800e2f:	c7 04 24 e4 13 80 00 	movl   $0x8013e4,(%esp)
  800e36:	e8 e5 f5 ff ff       	call   800420 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3e:	a3 0c 20 80 00       	mov    %eax,0x80200c
    if ((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0 )
  800e43:	c7 44 24 04 f8 03 80 	movl   $0x8003f8,0x4(%esp)
  800e4a:	00 
  800e4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e52:	e8 83 f4 ff ff       	call   8002da <sys_env_set_pgfault_upcall>
  800e57:	85 c0                	test   %eax,%eax
  800e59:	79 20                	jns    800e7b <set_pgfault_handler+0x8f>
        panic("set_pgfault_handler: sys_env_set_pgfault_upcall: %e", r);
  800e5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e5f:	c7 44 24 08 b0 13 80 	movl   $0x8013b0,0x8(%esp)
  800e66:	00 
  800e67:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800e6e:	00 
  800e6f:	c7 04 24 e4 13 80 00 	movl   $0x8013e4,(%esp)
  800e76:	e8 a5 f5 ff ff       	call   800420 <_panic>
}
  800e7b:	c9                   	leave  
  800e7c:	c3                   	ret    
  800e7d:	00 00                	add    %al,(%eax)
	...

00800e80 <__udivdi3>:
  800e80:	55                   	push   %ebp
  800e81:	57                   	push   %edi
  800e82:	56                   	push   %esi
  800e83:	83 ec 10             	sub    $0x10,%esp
  800e86:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e8a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800e8e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e92:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800e96:	89 cd                	mov    %ecx,%ebp
  800e98:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	75 2c                	jne    800ecc <__udivdi3+0x4c>
  800ea0:	39 f9                	cmp    %edi,%ecx
  800ea2:	77 68                	ja     800f0c <__udivdi3+0x8c>
  800ea4:	85 c9                	test   %ecx,%ecx
  800ea6:	75 0b                	jne    800eb3 <__udivdi3+0x33>
  800ea8:	b8 01 00 00 00       	mov    $0x1,%eax
  800ead:	31 d2                	xor    %edx,%edx
  800eaf:	f7 f1                	div    %ecx
  800eb1:	89 c1                	mov    %eax,%ecx
  800eb3:	31 d2                	xor    %edx,%edx
  800eb5:	89 f8                	mov    %edi,%eax
  800eb7:	f7 f1                	div    %ecx
  800eb9:	89 c7                	mov    %eax,%edi
  800ebb:	89 f0                	mov    %esi,%eax
  800ebd:	f7 f1                	div    %ecx
  800ebf:	89 c6                	mov    %eax,%esi
  800ec1:	89 f0                	mov    %esi,%eax
  800ec3:	89 fa                	mov    %edi,%edx
  800ec5:	83 c4 10             	add    $0x10,%esp
  800ec8:	5e                   	pop    %esi
  800ec9:	5f                   	pop    %edi
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    
  800ecc:	39 f8                	cmp    %edi,%eax
  800ece:	77 2c                	ja     800efc <__udivdi3+0x7c>
  800ed0:	0f bd f0             	bsr    %eax,%esi
  800ed3:	83 f6 1f             	xor    $0x1f,%esi
  800ed6:	75 4c                	jne    800f24 <__udivdi3+0xa4>
  800ed8:	39 f8                	cmp    %edi,%eax
  800eda:	bf 00 00 00 00       	mov    $0x0,%edi
  800edf:	72 0a                	jb     800eeb <__udivdi3+0x6b>
  800ee1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800ee5:	0f 87 ad 00 00 00    	ja     800f98 <__udivdi3+0x118>
  800eeb:	be 01 00 00 00       	mov    $0x1,%esi
  800ef0:	89 f0                	mov    %esi,%eax
  800ef2:	89 fa                	mov    %edi,%edx
  800ef4:	83 c4 10             	add    $0x10,%esp
  800ef7:	5e                   	pop    %esi
  800ef8:	5f                   	pop    %edi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    
  800efb:	90                   	nop
  800efc:	31 ff                	xor    %edi,%edi
  800efe:	31 f6                	xor    %esi,%esi
  800f00:	89 f0                	mov    %esi,%eax
  800f02:	89 fa                	mov    %edi,%edx
  800f04:	83 c4 10             	add    $0x10,%esp
  800f07:	5e                   	pop    %esi
  800f08:	5f                   	pop    %edi
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    
  800f0b:	90                   	nop
  800f0c:	89 fa                	mov    %edi,%edx
  800f0e:	89 f0                	mov    %esi,%eax
  800f10:	f7 f1                	div    %ecx
  800f12:	89 c6                	mov    %eax,%esi
  800f14:	31 ff                	xor    %edi,%edi
  800f16:	89 f0                	mov    %esi,%eax
  800f18:	89 fa                	mov    %edi,%edx
  800f1a:	83 c4 10             	add    $0x10,%esp
  800f1d:	5e                   	pop    %esi
  800f1e:	5f                   	pop    %edi
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    
  800f21:	8d 76 00             	lea    0x0(%esi),%esi
  800f24:	89 f1                	mov    %esi,%ecx
  800f26:	d3 e0                	shl    %cl,%eax
  800f28:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f2c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f31:	29 f0                	sub    %esi,%eax
  800f33:	89 ea                	mov    %ebp,%edx
  800f35:	88 c1                	mov    %al,%cl
  800f37:	d3 ea                	shr    %cl,%edx
  800f39:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800f3d:	09 ca                	or     %ecx,%edx
  800f3f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f43:	89 f1                	mov    %esi,%ecx
  800f45:	d3 e5                	shl    %cl,%ebp
  800f47:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800f4b:	89 fd                	mov    %edi,%ebp
  800f4d:	88 c1                	mov    %al,%cl
  800f4f:	d3 ed                	shr    %cl,%ebp
  800f51:	89 fa                	mov    %edi,%edx
  800f53:	89 f1                	mov    %esi,%ecx
  800f55:	d3 e2                	shl    %cl,%edx
  800f57:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f5b:	88 c1                	mov    %al,%cl
  800f5d:	d3 ef                	shr    %cl,%edi
  800f5f:	09 d7                	or     %edx,%edi
  800f61:	89 f8                	mov    %edi,%eax
  800f63:	89 ea                	mov    %ebp,%edx
  800f65:	f7 74 24 08          	divl   0x8(%esp)
  800f69:	89 d1                	mov    %edx,%ecx
  800f6b:	89 c7                	mov    %eax,%edi
  800f6d:	f7 64 24 0c          	mull   0xc(%esp)
  800f71:	39 d1                	cmp    %edx,%ecx
  800f73:	72 17                	jb     800f8c <__udivdi3+0x10c>
  800f75:	74 09                	je     800f80 <__udivdi3+0x100>
  800f77:	89 fe                	mov    %edi,%esi
  800f79:	31 ff                	xor    %edi,%edi
  800f7b:	e9 41 ff ff ff       	jmp    800ec1 <__udivdi3+0x41>
  800f80:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f84:	89 f1                	mov    %esi,%ecx
  800f86:	d3 e2                	shl    %cl,%edx
  800f88:	39 c2                	cmp    %eax,%edx
  800f8a:	73 eb                	jae    800f77 <__udivdi3+0xf7>
  800f8c:	8d 77 ff             	lea    -0x1(%edi),%esi
  800f8f:	31 ff                	xor    %edi,%edi
  800f91:	e9 2b ff ff ff       	jmp    800ec1 <__udivdi3+0x41>
  800f96:	66 90                	xchg   %ax,%ax
  800f98:	31 f6                	xor    %esi,%esi
  800f9a:	e9 22 ff ff ff       	jmp    800ec1 <__udivdi3+0x41>
	...

00800fa0 <__umoddi3>:
  800fa0:	55                   	push   %ebp
  800fa1:	57                   	push   %edi
  800fa2:	56                   	push   %esi
  800fa3:	83 ec 20             	sub    $0x20,%esp
  800fa6:	8b 44 24 30          	mov    0x30(%esp),%eax
  800faa:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800fae:	89 44 24 14          	mov    %eax,0x14(%esp)
  800fb2:	8b 74 24 34          	mov    0x34(%esp),%esi
  800fb6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800fba:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800fbe:	89 c7                	mov    %eax,%edi
  800fc0:	89 f2                	mov    %esi,%edx
  800fc2:	85 ed                	test   %ebp,%ebp
  800fc4:	75 16                	jne    800fdc <__umoddi3+0x3c>
  800fc6:	39 f1                	cmp    %esi,%ecx
  800fc8:	0f 86 a6 00 00 00    	jbe    801074 <__umoddi3+0xd4>
  800fce:	f7 f1                	div    %ecx
  800fd0:	89 d0                	mov    %edx,%eax
  800fd2:	31 d2                	xor    %edx,%edx
  800fd4:	83 c4 20             	add    $0x20,%esp
  800fd7:	5e                   	pop    %esi
  800fd8:	5f                   	pop    %edi
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    
  800fdb:	90                   	nop
  800fdc:	39 f5                	cmp    %esi,%ebp
  800fde:	0f 87 ac 00 00 00    	ja     801090 <__umoddi3+0xf0>
  800fe4:	0f bd c5             	bsr    %ebp,%eax
  800fe7:	83 f0 1f             	xor    $0x1f,%eax
  800fea:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fee:	0f 84 a8 00 00 00    	je     80109c <__umoddi3+0xfc>
  800ff4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ff8:	d3 e5                	shl    %cl,%ebp
  800ffa:	bf 20 00 00 00       	mov    $0x20,%edi
  800fff:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801003:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801007:	89 f9                	mov    %edi,%ecx
  801009:	d3 e8                	shr    %cl,%eax
  80100b:	09 e8                	or     %ebp,%eax
  80100d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801011:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801015:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801019:	d3 e0                	shl    %cl,%eax
  80101b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80101f:	89 f2                	mov    %esi,%edx
  801021:	d3 e2                	shl    %cl,%edx
  801023:	8b 44 24 14          	mov    0x14(%esp),%eax
  801027:	d3 e0                	shl    %cl,%eax
  801029:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  80102d:	8b 44 24 14          	mov    0x14(%esp),%eax
  801031:	89 f9                	mov    %edi,%ecx
  801033:	d3 e8                	shr    %cl,%eax
  801035:	09 d0                	or     %edx,%eax
  801037:	d3 ee                	shr    %cl,%esi
  801039:	89 f2                	mov    %esi,%edx
  80103b:	f7 74 24 18          	divl   0x18(%esp)
  80103f:	89 d6                	mov    %edx,%esi
  801041:	f7 64 24 0c          	mull   0xc(%esp)
  801045:	89 c5                	mov    %eax,%ebp
  801047:	89 d1                	mov    %edx,%ecx
  801049:	39 d6                	cmp    %edx,%esi
  80104b:	72 67                	jb     8010b4 <__umoddi3+0x114>
  80104d:	74 75                	je     8010c4 <__umoddi3+0x124>
  80104f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801053:	29 e8                	sub    %ebp,%eax
  801055:	19 ce                	sbb    %ecx,%esi
  801057:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80105b:	d3 e8                	shr    %cl,%eax
  80105d:	89 f2                	mov    %esi,%edx
  80105f:	89 f9                	mov    %edi,%ecx
  801061:	d3 e2                	shl    %cl,%edx
  801063:	09 d0                	or     %edx,%eax
  801065:	89 f2                	mov    %esi,%edx
  801067:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80106b:	d3 ea                	shr    %cl,%edx
  80106d:	83 c4 20             	add    $0x20,%esp
  801070:	5e                   	pop    %esi
  801071:	5f                   	pop    %edi
  801072:	5d                   	pop    %ebp
  801073:	c3                   	ret    
  801074:	85 c9                	test   %ecx,%ecx
  801076:	75 0b                	jne    801083 <__umoddi3+0xe3>
  801078:	b8 01 00 00 00       	mov    $0x1,%eax
  80107d:	31 d2                	xor    %edx,%edx
  80107f:	f7 f1                	div    %ecx
  801081:	89 c1                	mov    %eax,%ecx
  801083:	89 f0                	mov    %esi,%eax
  801085:	31 d2                	xor    %edx,%edx
  801087:	f7 f1                	div    %ecx
  801089:	89 f8                	mov    %edi,%eax
  80108b:	e9 3e ff ff ff       	jmp    800fce <__umoddi3+0x2e>
  801090:	89 f2                	mov    %esi,%edx
  801092:	83 c4 20             	add    $0x20,%esp
  801095:	5e                   	pop    %esi
  801096:	5f                   	pop    %edi
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    
  801099:	8d 76 00             	lea    0x0(%esi),%esi
  80109c:	39 f5                	cmp    %esi,%ebp
  80109e:	72 04                	jb     8010a4 <__umoddi3+0x104>
  8010a0:	39 f9                	cmp    %edi,%ecx
  8010a2:	77 06                	ja     8010aa <__umoddi3+0x10a>
  8010a4:	89 f2                	mov    %esi,%edx
  8010a6:	29 cf                	sub    %ecx,%edi
  8010a8:	19 ea                	sbb    %ebp,%edx
  8010aa:	89 f8                	mov    %edi,%eax
  8010ac:	83 c4 20             	add    $0x20,%esp
  8010af:	5e                   	pop    %esi
  8010b0:	5f                   	pop    %edi
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    
  8010b3:	90                   	nop
  8010b4:	89 d1                	mov    %edx,%ecx
  8010b6:	89 c5                	mov    %eax,%ebp
  8010b8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8010bc:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8010c0:	eb 8d                	jmp    80104f <__umoddi3+0xaf>
  8010c2:	66 90                	xchg   %ax,%ax
  8010c4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8010c8:	72 ea                	jb     8010b4 <__umoddi3+0x114>
  8010ca:	89 f1                	mov    %esi,%ecx
  8010cc:	eb 81                	jmp    80104f <__umoddi3+0xaf>
