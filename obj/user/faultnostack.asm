
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
  80003a:	c7 44 24 04 28 09 80 	movl   $0x800928,0x4(%esp)
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
  800074:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800077:	8d 04 80             	lea    (%eax,%eax,4),%eax
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
  80012b:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  800132:	00 
  800133:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80013a:	00 
  80013b:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  800142:	e8 09 08 00 00       	call   800950 <_panic>

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
  8001bd:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001cc:	00 
  8001cd:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  8001d4:	e8 77 07 00 00       	call   800950 <_panic>

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
  800210:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  800217:	00 
  800218:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80021f:	00 
  800220:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  800227:	e8 24 07 00 00       	call   800950 <_panic>

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
  800263:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  80026a:	00 
  80026b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800272:	00 
  800273:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  80027a:	e8 d1 06 00 00       	call   800950 <_panic>

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
  8002b6:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  8002bd:	00 
  8002be:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c5:	00 
  8002c6:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  8002cd:	e8 7e 06 00 00       	call   800950 <_panic>

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
  800309:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  800310:	00 
  800311:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800318:	00 
  800319:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  800320:	e8 2b 06 00 00       	call   800950 <_panic>

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
  80037e:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  800385:	00 
  800386:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80038d:	00 
  80038e:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  800395:	e8 b6 05 00 00       	call   800950 <_panic>

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
  8003d1:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  8003d8:	00 
  8003d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003e0:	00 
  8003e1:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  8003e8:	e8 63 05 00 00       	call   800950 <_panic>
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

008003f5 <sys_env_set_debug_upcall>:

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	57                   	push   %edi
  8003f9:	56                   	push   %esi
  8003fa:	53                   	push   %ebx
  8003fb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800403:	b8 0e 00 00 00       	mov    $0xe,%eax
  800408:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80040b:	8b 55 08             	mov    0x8(%ebp),%edx
  80040e:	89 df                	mov    %ebx,%edi
  800410:	89 de                	mov    %ebx,%esi
  800412:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800414:	85 c0                	test   %eax,%eax
  800416:	7e 28                	jle    800440 <sys_env_set_debug_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800418:	89 44 24 10          	mov    %eax,0x10(%esp)
  80041c:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800423:	00 
  800424:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  80042b:	00 
  80042c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800433:	00 
  800434:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  80043b:	e8 10 05 00 00       	call   800950 <_panic>
}

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_debug_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800440:	83 c4 2c             	add    $0x2c,%esp
  800443:	5b                   	pop    %ebx
  800444:	5e                   	pop    %esi
  800445:	5f                   	pop    %edi
  800446:	5d                   	pop    %ebp
  800447:	c3                   	ret    

00800448 <sys_env_set_nmskint_upcall>:

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	57                   	push   %edi
  80044c:	56                   	push   %esi
  80044d:	53                   	push   %ebx
  80044e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800451:	bb 00 00 00 00       	mov    $0x0,%ebx
  800456:	b8 0f 00 00 00       	mov    $0xf,%eax
  80045b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80045e:	8b 55 08             	mov    0x8(%ebp),%edx
  800461:	89 df                	mov    %ebx,%edi
  800463:	89 de                	mov    %ebx,%esi
  800465:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800467:	85 c0                	test   %eax,%eax
  800469:	7e 28                	jle    800493 <sys_env_set_nmskint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80046b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80046f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800476:	00 
  800477:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  80047e:	00 
  80047f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800486:	00 
  800487:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  80048e:	e8 bd 04 00 00       	call   800950 <_panic>
}

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_nmskint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800493:	83 c4 2c             	add    $0x2c,%esp
  800496:	5b                   	pop    %ebx
  800497:	5e                   	pop    %esi
  800498:	5f                   	pop    %edi
  800499:	5d                   	pop    %ebp
  80049a:	c3                   	ret    

0080049b <sys_env_set_bpoint_upcall>:

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
  80049b:	55                   	push   %ebp
  80049c:	89 e5                	mov    %esp,%ebp
  80049e:	57                   	push   %edi
  80049f:	56                   	push   %esi
  8004a0:	53                   	push   %ebx
  8004a1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004a9:	b8 10 00 00 00       	mov    $0x10,%eax
  8004ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8004b4:	89 df                	mov    %ebx,%edi
  8004b6:	89 de                	mov    %ebx,%esi
  8004b8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8004ba:	85 c0                	test   %eax,%eax
  8004bc:	7e 28                	jle    8004e6 <sys_env_set_bpoint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004c2:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  8004c9:	00 
  8004ca:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  8004d1:	00 
  8004d2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004d9:	00 
  8004da:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  8004e1:	e8 6a 04 00 00       	call   800950 <_panic>
}

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bpoint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8004e6:	83 c4 2c             	add    $0x2c,%esp
  8004e9:	5b                   	pop    %ebx
  8004ea:	5e                   	pop    %esi
  8004eb:	5f                   	pop    %edi
  8004ec:	5d                   	pop    %ebp
  8004ed:	c3                   	ret    

008004ee <sys_env_set_oflow_upcall>:

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  8004f1:	57                   	push   %edi
  8004f2:	56                   	push   %esi
  8004f3:	53                   	push   %ebx
  8004f4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004fc:	b8 11 00 00 00       	mov    $0x11,%eax
  800501:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800504:	8b 55 08             	mov    0x8(%ebp),%edx
  800507:	89 df                	mov    %ebx,%edi
  800509:	89 de                	mov    %ebx,%esi
  80050b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80050d:	85 c0                	test   %eax,%eax
  80050f:	7e 28                	jle    800539 <sys_env_set_oflow_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800511:	89 44 24 10          	mov    %eax,0x10(%esp)
  800515:	c7 44 24 0c 11 00 00 	movl   $0x11,0xc(%esp)
  80051c:	00 
  80051d:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  800524:	00 
  800525:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80052c:	00 
  80052d:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  800534:	e8 17 04 00 00       	call   800950 <_panic>
}

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_oflow_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800539:	83 c4 2c             	add    $0x2c,%esp
  80053c:	5b                   	pop    %ebx
  80053d:	5e                   	pop    %esi
  80053e:	5f                   	pop    %edi
  80053f:	5d                   	pop    %ebp
  800540:	c3                   	ret    

00800541 <sys_env_set_bdschk_upcall>:

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
  800541:	55                   	push   %ebp
  800542:	89 e5                	mov    %esp,%ebp
  800544:	57                   	push   %edi
  800545:	56                   	push   %esi
  800546:	53                   	push   %ebx
  800547:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80054a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80054f:	b8 12 00 00 00       	mov    $0x12,%eax
  800554:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800557:	8b 55 08             	mov    0x8(%ebp),%edx
  80055a:	89 df                	mov    %ebx,%edi
  80055c:	89 de                	mov    %ebx,%esi
  80055e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800560:	85 c0                	test   %eax,%eax
  800562:	7e 28                	jle    80058c <sys_env_set_bdschk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800564:	89 44 24 10          	mov    %eax,0x10(%esp)
  800568:	c7 44 24 0c 12 00 00 	movl   $0x12,0xc(%esp)
  80056f:	00 
  800570:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  800577:	00 
  800578:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80057f:	00 
  800580:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  800587:	e8 c4 03 00 00       	call   800950 <_panic>
}

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bdschk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80058c:	83 c4 2c             	add    $0x2c,%esp
  80058f:	5b                   	pop    %ebx
  800590:	5e                   	pop    %esi
  800591:	5f                   	pop    %edi
  800592:	5d                   	pop    %ebp
  800593:	c3                   	ret    

00800594 <sys_env_set_illopcd_upcall>:

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
  800594:	55                   	push   %ebp
  800595:	89 e5                	mov    %esp,%ebp
  800597:	57                   	push   %edi
  800598:	56                   	push   %esi
  800599:	53                   	push   %ebx
  80059a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80059d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005a2:	b8 13 00 00 00       	mov    $0x13,%eax
  8005a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8005ad:	89 df                	mov    %ebx,%edi
  8005af:	89 de                	mov    %ebx,%esi
  8005b1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005b3:	85 c0                	test   %eax,%eax
  8005b5:	7e 28                	jle    8005df <sys_env_set_illopcd_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005bb:	c7 44 24 0c 13 00 00 	movl   $0x13,0xc(%esp)
  8005c2:	00 
  8005c3:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  8005ca:	00 
  8005cb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005d2:	00 
  8005d3:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  8005da:	e8 71 03 00 00       	call   800950 <_panic>
}

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_illopcd_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8005df:	83 c4 2c             	add    $0x2c,%esp
  8005e2:	5b                   	pop    %ebx
  8005e3:	5e                   	pop    %esi
  8005e4:	5f                   	pop    %edi
  8005e5:	5d                   	pop    %ebp
  8005e6:	c3                   	ret    

008005e7 <sys_env_set_dvcntavl_upcall>:

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
  8005e7:	55                   	push   %ebp
  8005e8:	89 e5                	mov    %esp,%ebp
  8005ea:	57                   	push   %edi
  8005eb:	56                   	push   %esi
  8005ec:	53                   	push   %ebx
  8005ed:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f5:	b8 14 00 00 00       	mov    $0x14,%eax
  8005fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800600:	89 df                	mov    %ebx,%edi
  800602:	89 de                	mov    %ebx,%esi
  800604:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800606:	85 c0                	test   %eax,%eax
  800608:	7e 28                	jle    800632 <sys_env_set_dvcntavl_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80060a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80060e:	c7 44 24 0c 14 00 00 	movl   $0x14,0xc(%esp)
  800615:	00 
  800616:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  80061d:	00 
  80061e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800625:	00 
  800626:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  80062d:	e8 1e 03 00 00       	call   800950 <_panic>
}

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dvcntavl_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800632:	83 c4 2c             	add    $0x2c,%esp
  800635:	5b                   	pop    %ebx
  800636:	5e                   	pop    %esi
  800637:	5f                   	pop    %edi
  800638:	5d                   	pop    %ebp
  800639:	c3                   	ret    

0080063a <sys_env_set_dbfault_upcall>:

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
  80063a:	55                   	push   %ebp
  80063b:	89 e5                	mov    %esp,%ebp
  80063d:	57                   	push   %edi
  80063e:	56                   	push   %esi
  80063f:	53                   	push   %ebx
  800640:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800643:	bb 00 00 00 00       	mov    $0x0,%ebx
  800648:	b8 15 00 00 00       	mov    $0x15,%eax
  80064d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800650:	8b 55 08             	mov    0x8(%ebp),%edx
  800653:	89 df                	mov    %ebx,%edi
  800655:	89 de                	mov    %ebx,%esi
  800657:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800659:	85 c0                	test   %eax,%eax
  80065b:	7e 28                	jle    800685 <sys_env_set_dbfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80065d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800661:	c7 44 24 0c 15 00 00 	movl   $0x15,0xc(%esp)
  800668:	00 
  800669:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  800670:	00 
  800671:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800678:	00 
  800679:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  800680:	e8 cb 02 00 00       	call   800950 <_panic>
}

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dbfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800685:	83 c4 2c             	add    $0x2c,%esp
  800688:	5b                   	pop    %ebx
  800689:	5e                   	pop    %esi
  80068a:	5f                   	pop    %edi
  80068b:	5d                   	pop    %ebp
  80068c:	c3                   	ret    

0080068d <sys_env_set_ivldtss_upcall>:

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	57                   	push   %edi
  800691:	56                   	push   %esi
  800692:	53                   	push   %ebx
  800693:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800696:	bb 00 00 00 00       	mov    $0x0,%ebx
  80069b:	b8 16 00 00 00       	mov    $0x16,%eax
  8006a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a6:	89 df                	mov    %ebx,%edi
  8006a8:	89 de                	mov    %ebx,%esi
  8006aa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006ac:	85 c0                	test   %eax,%eax
  8006ae:	7e 28                	jle    8006d8 <sys_env_set_ivldtss_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006b4:	c7 44 24 0c 16 00 00 	movl   $0x16,0xc(%esp)
  8006bb:	00 
  8006bc:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  8006c3:	00 
  8006c4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006cb:	00 
  8006cc:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  8006d3:	e8 78 02 00 00       	call   800950 <_panic>
}

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_ivldtss_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8006d8:	83 c4 2c             	add    $0x2c,%esp
  8006db:	5b                   	pop    %ebx
  8006dc:	5e                   	pop    %esi
  8006dd:	5f                   	pop    %edi
  8006de:	5d                   	pop    %ebp
  8006df:	c3                   	ret    

008006e0 <sys_env_set_segntprst_upcall>:

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	57                   	push   %edi
  8006e4:	56                   	push   %esi
  8006e5:	53                   	push   %ebx
  8006e6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ee:	b8 17 00 00 00       	mov    $0x17,%eax
  8006f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f9:	89 df                	mov    %ebx,%edi
  8006fb:	89 de                	mov    %ebx,%esi
  8006fd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006ff:	85 c0                	test   %eax,%eax
  800701:	7e 28                	jle    80072b <sys_env_set_segntprst_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800703:	89 44 24 10          	mov    %eax,0x10(%esp)
  800707:	c7 44 24 0c 17 00 00 	movl   $0x17,0xc(%esp)
  80070e:	00 
  80070f:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  800716:	00 
  800717:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80071e:	00 
  80071f:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  800726:	e8 25 02 00 00       	call   800950 <_panic>
}

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_segntprst_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80072b:	83 c4 2c             	add    $0x2c,%esp
  80072e:	5b                   	pop    %ebx
  80072f:	5e                   	pop    %esi
  800730:	5f                   	pop    %edi
  800731:	5d                   	pop    %ebp
  800732:	c3                   	ret    

00800733 <sys_env_set_stkexception_upcall>:

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
  800733:	55                   	push   %ebp
  800734:	89 e5                	mov    %esp,%ebp
  800736:	57                   	push   %edi
  800737:	56                   	push   %esi
  800738:	53                   	push   %ebx
  800739:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80073c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800741:	b8 18 00 00 00       	mov    $0x18,%eax
  800746:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800749:	8b 55 08             	mov    0x8(%ebp),%edx
  80074c:	89 df                	mov    %ebx,%edi
  80074e:	89 de                	mov    %ebx,%esi
  800750:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800752:	85 c0                	test   %eax,%eax
  800754:	7e 28                	jle    80077e <sys_env_set_stkexception_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800756:	89 44 24 10          	mov    %eax,0x10(%esp)
  80075a:	c7 44 24 0c 18 00 00 	movl   $0x18,0xc(%esp)
  800761:	00 
  800762:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  800769:	00 
  80076a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800771:	00 
  800772:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  800779:	e8 d2 01 00 00       	call   800950 <_panic>
}

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_stkexception_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80077e:	83 c4 2c             	add    $0x2c,%esp
  800781:	5b                   	pop    %ebx
  800782:	5e                   	pop    %esi
  800783:	5f                   	pop    %edi
  800784:	5d                   	pop    %ebp
  800785:	c3                   	ret    

00800786 <sys_env_set_gpfault_upcall>:

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	57                   	push   %edi
  80078a:	56                   	push   %esi
  80078b:	53                   	push   %ebx
  80078c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80078f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800794:	b8 19 00 00 00       	mov    $0x19,%eax
  800799:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079c:	8b 55 08             	mov    0x8(%ebp),%edx
  80079f:	89 df                	mov    %ebx,%edi
  8007a1:	89 de                	mov    %ebx,%esi
  8007a3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8007a5:	85 c0                	test   %eax,%eax
  8007a7:	7e 28                	jle    8007d1 <sys_env_set_gpfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007a9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007ad:	c7 44 24 0c 19 00 00 	movl   $0x19,0xc(%esp)
  8007b4:	00 
  8007b5:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  8007bc:	00 
  8007bd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8007c4:	00 
  8007c5:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  8007cc:	e8 7f 01 00 00       	call   800950 <_panic>
}

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_gpfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8007d1:	83 c4 2c             	add    $0x2c,%esp
  8007d4:	5b                   	pop    %ebx
  8007d5:	5e                   	pop    %esi
  8007d6:	5f                   	pop    %edi
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <sys_env_set_fperror_upcall>:

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	57                   	push   %edi
  8007dd:	56                   	push   %esi
  8007de:	53                   	push   %ebx
  8007df:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007e7:	b8 1a 00 00 00       	mov    $0x1a,%eax
  8007ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8007f2:	89 df                	mov    %ebx,%edi
  8007f4:	89 de                	mov    %ebx,%esi
  8007f6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8007f8:	85 c0                	test   %eax,%eax
  8007fa:	7e 28                	jle    800824 <sys_env_set_fperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800800:	c7 44 24 0c 1a 00 00 	movl   $0x1a,0xc(%esp)
  800807:	00 
  800808:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  80080f:	00 
  800810:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800817:	00 
  800818:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  80081f:	e8 2c 01 00 00       	call   800950 <_panic>
}

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_fperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800824:	83 c4 2c             	add    $0x2c,%esp
  800827:	5b                   	pop    %ebx
  800828:	5e                   	pop    %esi
  800829:	5f                   	pop    %edi
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <sys_env_set_algchk_upcall>:

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	57                   	push   %edi
  800830:	56                   	push   %esi
  800831:	53                   	push   %ebx
  800832:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800835:	bb 00 00 00 00       	mov    $0x0,%ebx
  80083a:	b8 1b 00 00 00       	mov    $0x1b,%eax
  80083f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800842:	8b 55 08             	mov    0x8(%ebp),%edx
  800845:	89 df                	mov    %ebx,%edi
  800847:	89 de                	mov    %ebx,%esi
  800849:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80084b:	85 c0                	test   %eax,%eax
  80084d:	7e 28                	jle    800877 <sys_env_set_algchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80084f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800853:	c7 44 24 0c 1b 00 00 	movl   $0x1b,0xc(%esp)
  80085a:	00 
  80085b:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  800862:	00 
  800863:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80086a:	00 
  80086b:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  800872:	e8 d9 00 00 00       	call   800950 <_panic>
}

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_algchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800877:	83 c4 2c             	add    $0x2c,%esp
  80087a:	5b                   	pop    %ebx
  80087b:	5e                   	pop    %esi
  80087c:	5f                   	pop    %edi
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <sys_env_set_mchchk_upcall>:

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	57                   	push   %edi
  800883:	56                   	push   %esi
  800884:	53                   	push   %ebx
  800885:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800888:	bb 00 00 00 00       	mov    $0x0,%ebx
  80088d:	b8 1c 00 00 00       	mov    $0x1c,%eax
  800892:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800895:	8b 55 08             	mov    0x8(%ebp),%edx
  800898:	89 df                	mov    %ebx,%edi
  80089a:	89 de                	mov    %ebx,%esi
  80089c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80089e:	85 c0                	test   %eax,%eax
  8008a0:	7e 28                	jle    8008ca <sys_env_set_mchchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8008a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8008a6:	c7 44 24 0c 1c 00 00 	movl   $0x1c,0xc(%esp)
  8008ad:	00 
  8008ae:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  8008b5:	00 
  8008b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8008bd:	00 
  8008be:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  8008c5:	e8 86 00 00 00       	call   800950 <_panic>
}

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_mchchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8008ca:	83 c4 2c             	add    $0x2c,%esp
  8008cd:	5b                   	pop    %ebx
  8008ce:	5e                   	pop    %esi
  8008cf:	5f                   	pop    %edi
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <sys_env_set_SIMDfperror_upcall>:

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	57                   	push   %edi
  8008d6:	56                   	push   %esi
  8008d7:	53                   	push   %ebx
  8008d8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8008db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008e0:	b8 1d 00 00 00       	mov    $0x1d,%eax
  8008e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8008eb:	89 df                	mov    %ebx,%edi
  8008ed:	89 de                	mov    %ebx,%esi
  8008ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8008f1:	85 c0                	test   %eax,%eax
  8008f3:	7e 28                	jle    80091d <sys_env_set_SIMDfperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8008f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8008f9:	c7 44 24 0c 1d 00 00 	movl   $0x1d,0xc(%esp)
  800900:	00 
  800901:	c7 44 24 08 0a 16 80 	movl   $0x80160a,0x8(%esp)
  800908:	00 
  800909:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800910:	00 
  800911:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  800918:	e8 33 00 00 00       	call   800950 <_panic>
}

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_SIMDfperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80091d:	83 c4 2c             	add    $0x2c,%esp
  800920:	5b                   	pop    %ebx
  800921:	5e                   	pop    %esi
  800922:	5f                   	pop    %edi
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    
  800925:	00 00                	add    %al,(%eax)
	...

00800928 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800928:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800929:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80092e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800930:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// sub 4 from old esp
	movl 0x30(%esp), %eax
  800933:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  800937:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80093a:	89 44 24 30          	mov    %eax,0x30(%esp)
	// put old eip into the pre-reserved 4-byte space
	movl 0x28(%esp), %ebx
  80093e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800942:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  800944:	83 c4 08             	add    $0x8,%esp
	popal
  800947:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  800948:	83 c4 04             	add    $0x4,%esp
	popfl
  80094b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80094c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80094d:	c3                   	ret    
	...

00800950 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	56                   	push   %esi
  800954:	53                   	push   %ebx
  800955:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800958:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80095b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800961:	e8 e9 f7 ff ff       	call   80014f <sys_getenvid>
  800966:	8b 55 0c             	mov    0xc(%ebp),%edx
  800969:	89 54 24 10          	mov    %edx,0x10(%esp)
  80096d:	8b 55 08             	mov    0x8(%ebp),%edx
  800970:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800974:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800978:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097c:	c7 04 24 38 16 80 00 	movl   $0x801638,(%esp)
  800983:	e8 c0 00 00 00       	call   800a48 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800988:	89 74 24 04          	mov    %esi,0x4(%esp)
  80098c:	8b 45 10             	mov    0x10(%ebp),%eax
  80098f:	89 04 24             	mov    %eax,(%esp)
  800992:	e8 50 00 00 00       	call   8009e7 <vcprintf>
	cprintf("\n");
  800997:	c7 04 24 5b 16 80 00 	movl   $0x80165b,(%esp)
  80099e:	e8 a5 00 00 00       	call   800a48 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8009a3:	cc                   	int3   
  8009a4:	eb fd                	jmp    8009a3 <_panic+0x53>
	...

008009a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	53                   	push   %ebx
  8009ac:	83 ec 14             	sub    $0x14,%esp
  8009af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8009b2:	8b 03                	mov    (%ebx),%eax
  8009b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009b7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8009bb:	40                   	inc    %eax
  8009bc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8009be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8009c3:	75 19                	jne    8009de <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8009c5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8009cc:	00 
  8009cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8009d0:	89 04 24             	mov    %eax,(%esp)
  8009d3:	e8 e8 f6 ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  8009d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8009de:	ff 43 04             	incl   0x4(%ebx)
}
  8009e1:	83 c4 14             	add    $0x14,%esp
  8009e4:	5b                   	pop    %ebx
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8009f0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8009f7:	00 00 00 
	b.cnt = 0;
  8009fa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800a01:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800a04:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a07:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a12:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800a18:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1c:	c7 04 24 a8 09 80 00 	movl   $0x8009a8,(%esp)
  800a23:	e8 b4 01 00 00       	call   800bdc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800a28:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800a2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a32:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800a38:	89 04 24             	mov    %eax,(%esp)
  800a3b:	e8 80 f6 ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  800a40:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800a46:	c9                   	leave  
  800a47:	c3                   	ret    

00800a48 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800a4e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800a51:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	89 04 24             	mov    %eax,(%esp)
  800a5b:	e8 87 ff ff ff       	call   8009e7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800a60:	c9                   	leave  
  800a61:	c3                   	ret    
	...

00800a64 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
  800a6a:	83 ec 3c             	sub    $0x3c,%esp
  800a6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a70:	89 d7                	mov    %edx,%edi
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a7e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800a81:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800a84:	85 c0                	test   %eax,%eax
  800a86:	75 08                	jne    800a90 <printnum+0x2c>
  800a88:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a8b:	39 45 10             	cmp    %eax,0x10(%ebp)
  800a8e:	77 57                	ja     800ae7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800a90:	89 74 24 10          	mov    %esi,0x10(%esp)
  800a94:	4b                   	dec    %ebx
  800a95:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800a99:	8b 45 10             	mov    0x10(%ebp),%eax
  800a9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800aa4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800aa8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800aaf:	00 
  800ab0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ab3:	89 04 24             	mov    %eax,(%esp)
  800ab6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ab9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800abd:	e8 ee 08 00 00       	call   8013b0 <__udivdi3>
  800ac2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ac6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800aca:	89 04 24             	mov    %eax,(%esp)
  800acd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ad1:	89 fa                	mov    %edi,%edx
  800ad3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ad6:	e8 89 ff ff ff       	call   800a64 <printnum>
  800adb:	eb 0f                	jmp    800aec <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800add:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ae1:	89 34 24             	mov    %esi,(%esp)
  800ae4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800ae7:	4b                   	dec    %ebx
  800ae8:	85 db                	test   %ebx,%ebx
  800aea:	7f f1                	jg     800add <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800aec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800af0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800af4:	8b 45 10             	mov    0x10(%ebp),%eax
  800af7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800afb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800b02:	00 
  800b03:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b06:	89 04 24             	mov    %eax,(%esp)
  800b09:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b10:	e8 bb 09 00 00       	call   8014d0 <__umoddi3>
  800b15:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b19:	0f be 80 5d 16 80 00 	movsbl 0x80165d(%eax),%eax
  800b20:	89 04 24             	mov    %eax,(%esp)
  800b23:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800b26:	83 c4 3c             	add    $0x3c,%esp
  800b29:	5b                   	pop    %ebx
  800b2a:	5e                   	pop    %esi
  800b2b:	5f                   	pop    %edi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    

00800b2e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800b31:	83 fa 01             	cmp    $0x1,%edx
  800b34:	7e 0e                	jle    800b44 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800b36:	8b 10                	mov    (%eax),%edx
  800b38:	8d 4a 08             	lea    0x8(%edx),%ecx
  800b3b:	89 08                	mov    %ecx,(%eax)
  800b3d:	8b 02                	mov    (%edx),%eax
  800b3f:	8b 52 04             	mov    0x4(%edx),%edx
  800b42:	eb 22                	jmp    800b66 <getuint+0x38>
	else if (lflag)
  800b44:	85 d2                	test   %edx,%edx
  800b46:	74 10                	je     800b58 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800b48:	8b 10                	mov    (%eax),%edx
  800b4a:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b4d:	89 08                	mov    %ecx,(%eax)
  800b4f:	8b 02                	mov    (%edx),%eax
  800b51:	ba 00 00 00 00       	mov    $0x0,%edx
  800b56:	eb 0e                	jmp    800b66 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800b58:	8b 10                	mov    (%eax),%edx
  800b5a:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b5d:	89 08                	mov    %ecx,(%eax)
  800b5f:	8b 02                	mov    (%edx),%eax
  800b61:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800b6b:	83 fa 01             	cmp    $0x1,%edx
  800b6e:	7e 0e                	jle    800b7e <getint+0x16>
		return va_arg(*ap, long long);
  800b70:	8b 10                	mov    (%eax),%edx
  800b72:	8d 4a 08             	lea    0x8(%edx),%ecx
  800b75:	89 08                	mov    %ecx,(%eax)
  800b77:	8b 02                	mov    (%edx),%eax
  800b79:	8b 52 04             	mov    0x4(%edx),%edx
  800b7c:	eb 1a                	jmp    800b98 <getint+0x30>
	else if (lflag)
  800b7e:	85 d2                	test   %edx,%edx
  800b80:	74 0c                	je     800b8e <getint+0x26>
		return va_arg(*ap, long);
  800b82:	8b 10                	mov    (%eax),%edx
  800b84:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b87:	89 08                	mov    %ecx,(%eax)
  800b89:	8b 02                	mov    (%edx),%eax
  800b8b:	99                   	cltd   
  800b8c:	eb 0a                	jmp    800b98 <getint+0x30>
	else
		return va_arg(*ap, int);
  800b8e:	8b 10                	mov    (%eax),%edx
  800b90:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b93:	89 08                	mov    %ecx,(%eax)
  800b95:	8b 02                	mov    (%edx),%eax
  800b97:	99                   	cltd   
}
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800ba0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800ba3:	8b 10                	mov    (%eax),%edx
  800ba5:	3b 50 04             	cmp    0x4(%eax),%edx
  800ba8:	73 08                	jae    800bb2 <sprintputch+0x18>
		*b->buf++ = ch;
  800baa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bad:	88 0a                	mov    %cl,(%edx)
  800baf:	42                   	inc    %edx
  800bb0:	89 10                	mov    %edx,(%eax)
}
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800bba:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800bbd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bc1:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd2:	89 04 24             	mov    %eax,(%esp)
  800bd5:	e8 02 00 00 00       	call   800bdc <vprintfmt>
	va_end(ap);
}
  800bda:	c9                   	leave  
  800bdb:	c3                   	ret    

00800bdc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	83 ec 4c             	sub    $0x4c,%esp
  800be5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800be8:	8b 75 10             	mov    0x10(%ebp),%esi
  800beb:	eb 12                	jmp    800bff <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800bed:	85 c0                	test   %eax,%eax
  800bef:	0f 84 40 03 00 00    	je     800f35 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800bf5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bf9:	89 04 24             	mov    %eax,(%esp)
  800bfc:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800bff:	0f b6 06             	movzbl (%esi),%eax
  800c02:	46                   	inc    %esi
  800c03:	83 f8 25             	cmp    $0x25,%eax
  800c06:	75 e5                	jne    800bed <vprintfmt+0x11>
  800c08:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800c0c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800c13:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800c18:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800c1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c24:	eb 26                	jmp    800c4c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c26:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c29:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800c2d:	eb 1d                	jmp    800c4c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c2f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800c32:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800c36:	eb 14                	jmp    800c4c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c38:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800c3b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800c42:	eb 08                	jmp    800c4c <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800c44:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800c47:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c4c:	0f b6 06             	movzbl (%esi),%eax
  800c4f:	8d 4e 01             	lea    0x1(%esi),%ecx
  800c52:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800c55:	8a 0e                	mov    (%esi),%cl
  800c57:	83 e9 23             	sub    $0x23,%ecx
  800c5a:	80 f9 55             	cmp    $0x55,%cl
  800c5d:	0f 87 b6 02 00 00    	ja     800f19 <vprintfmt+0x33d>
  800c63:	0f b6 c9             	movzbl %cl,%ecx
  800c66:	ff 24 8d 20 17 80 00 	jmp    *0x801720(,%ecx,4)
  800c6d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c70:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800c75:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800c78:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  800c7c:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800c7f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800c82:	83 f9 09             	cmp    $0x9,%ecx
  800c85:	77 2a                	ja     800cb1 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c87:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800c88:	eb eb                	jmp    800c75 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800c8a:	8b 45 14             	mov    0x14(%ebp),%eax
  800c8d:	8d 48 04             	lea    0x4(%eax),%ecx
  800c90:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800c93:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c95:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800c98:	eb 17                	jmp    800cb1 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800c9a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c9e:	78 98                	js     800c38 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ca3:	eb a7                	jmp    800c4c <vprintfmt+0x70>
  800ca5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800ca8:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800caf:	eb 9b                	jmp    800c4c <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800cb1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800cb5:	79 95                	jns    800c4c <vprintfmt+0x70>
  800cb7:	eb 8b                	jmp    800c44 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800cb9:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800cbd:	eb 8d                	jmp    800c4c <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800cbf:	8b 45 14             	mov    0x14(%ebp),%eax
  800cc2:	8d 50 04             	lea    0x4(%eax),%edx
  800cc5:	89 55 14             	mov    %edx,0x14(%ebp)
  800cc8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ccc:	8b 00                	mov    (%eax),%eax
  800cce:	89 04 24             	mov    %eax,(%esp)
  800cd1:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cd4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800cd7:	e9 23 ff ff ff       	jmp    800bff <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800cdc:	8b 45 14             	mov    0x14(%ebp),%eax
  800cdf:	8d 50 04             	lea    0x4(%eax),%edx
  800ce2:	89 55 14             	mov    %edx,0x14(%ebp)
  800ce5:	8b 00                	mov    (%eax),%eax
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	79 02                	jns    800ced <vprintfmt+0x111>
  800ceb:	f7 d8                	neg    %eax
  800ced:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800cef:	83 f8 09             	cmp    $0x9,%eax
  800cf2:	7f 0b                	jg     800cff <vprintfmt+0x123>
  800cf4:	8b 04 85 80 18 80 00 	mov    0x801880(,%eax,4),%eax
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	75 23                	jne    800d22 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800cff:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d03:	c7 44 24 08 75 16 80 	movl   $0x801675,0x8(%esp)
  800d0a:	00 
  800d0b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d12:	89 04 24             	mov    %eax,(%esp)
  800d15:	e8 9a fe ff ff       	call   800bb4 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d1a:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d1d:	e9 dd fe ff ff       	jmp    800bff <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800d22:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d26:	c7 44 24 08 7e 16 80 	movl   $0x80167e,0x8(%esp)
  800d2d:	00 
  800d2e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	89 14 24             	mov    %edx,(%esp)
  800d38:	e8 77 fe ff ff       	call   800bb4 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d3d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d40:	e9 ba fe ff ff       	jmp    800bff <vprintfmt+0x23>
  800d45:	89 f9                	mov    %edi,%ecx
  800d47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d4a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d4d:	8b 45 14             	mov    0x14(%ebp),%eax
  800d50:	8d 50 04             	lea    0x4(%eax),%edx
  800d53:	89 55 14             	mov    %edx,0x14(%ebp)
  800d56:	8b 30                	mov    (%eax),%esi
  800d58:	85 f6                	test   %esi,%esi
  800d5a:	75 05                	jne    800d61 <vprintfmt+0x185>
				p = "(null)";
  800d5c:	be 6e 16 80 00       	mov    $0x80166e,%esi
			if (width > 0 && padc != '-')
  800d61:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800d65:	0f 8e 84 00 00 00    	jle    800def <vprintfmt+0x213>
  800d6b:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800d6f:	74 7e                	je     800def <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800d71:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d75:	89 34 24             	mov    %esi,(%esp)
  800d78:	e8 5d 02 00 00       	call   800fda <strnlen>
  800d7d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800d80:	29 c2                	sub    %eax,%edx
  800d82:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800d85:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800d89:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800d8c:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800d8f:	89 de                	mov    %ebx,%esi
  800d91:	89 d3                	mov    %edx,%ebx
  800d93:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d95:	eb 0b                	jmp    800da2 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800d97:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d9b:	89 3c 24             	mov    %edi,(%esp)
  800d9e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800da1:	4b                   	dec    %ebx
  800da2:	85 db                	test   %ebx,%ebx
  800da4:	7f f1                	jg     800d97 <vprintfmt+0x1bb>
  800da6:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800da9:	89 f3                	mov    %esi,%ebx
  800dab:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800dae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800db1:	85 c0                	test   %eax,%eax
  800db3:	79 05                	jns    800dba <vprintfmt+0x1de>
  800db5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800dbd:	29 c2                	sub    %eax,%edx
  800dbf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800dc2:	eb 2b                	jmp    800def <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800dc4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800dc8:	74 18                	je     800de2 <vprintfmt+0x206>
  800dca:	8d 50 e0             	lea    -0x20(%eax),%edx
  800dcd:	83 fa 5e             	cmp    $0x5e,%edx
  800dd0:	76 10                	jbe    800de2 <vprintfmt+0x206>
					putch('?', putdat);
  800dd2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dd6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800ddd:	ff 55 08             	call   *0x8(%ebp)
  800de0:	eb 0a                	jmp    800dec <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800de2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800de6:	89 04 24             	mov    %eax,(%esp)
  800de9:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800dec:	ff 4d e4             	decl   -0x1c(%ebp)
  800def:	0f be 06             	movsbl (%esi),%eax
  800df2:	46                   	inc    %esi
  800df3:	85 c0                	test   %eax,%eax
  800df5:	74 21                	je     800e18 <vprintfmt+0x23c>
  800df7:	85 ff                	test   %edi,%edi
  800df9:	78 c9                	js     800dc4 <vprintfmt+0x1e8>
  800dfb:	4f                   	dec    %edi
  800dfc:	79 c6                	jns    800dc4 <vprintfmt+0x1e8>
  800dfe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e01:	89 de                	mov    %ebx,%esi
  800e03:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800e06:	eb 18                	jmp    800e20 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e08:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e0c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800e13:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e15:	4b                   	dec    %ebx
  800e16:	eb 08                	jmp    800e20 <vprintfmt+0x244>
  800e18:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e1b:	89 de                	mov    %ebx,%esi
  800e1d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800e20:	85 db                	test   %ebx,%ebx
  800e22:	7f e4                	jg     800e08 <vprintfmt+0x22c>
  800e24:	89 7d 08             	mov    %edi,0x8(%ebp)
  800e27:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e29:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800e2c:	e9 ce fd ff ff       	jmp    800bff <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800e31:	8d 45 14             	lea    0x14(%ebp),%eax
  800e34:	e8 2f fd ff ff       	call   800b68 <getint>
  800e39:	89 c6                	mov    %eax,%esi
  800e3b:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800e3d:	85 d2                	test   %edx,%edx
  800e3f:	78 07                	js     800e48 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800e41:	be 0a 00 00 00       	mov    $0xa,%esi
  800e46:	eb 7e                	jmp    800ec6 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800e48:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e4c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800e53:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800e56:	89 f0                	mov    %esi,%eax
  800e58:	89 fa                	mov    %edi,%edx
  800e5a:	f7 d8                	neg    %eax
  800e5c:	83 d2 00             	adc    $0x0,%edx
  800e5f:	f7 da                	neg    %edx
			}
			base = 10;
  800e61:	be 0a 00 00 00       	mov    $0xa,%esi
  800e66:	eb 5e                	jmp    800ec6 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800e68:	8d 45 14             	lea    0x14(%ebp),%eax
  800e6b:	e8 be fc ff ff       	call   800b2e <getuint>
			base = 10;
  800e70:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800e75:	eb 4f                	jmp    800ec6 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800e77:	8d 45 14             	lea    0x14(%ebp),%eax
  800e7a:	e8 af fc ff ff       	call   800b2e <getuint>
			base = 8;
  800e7f:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800e84:	eb 40                	jmp    800ec6 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  800e86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e8a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800e91:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800e94:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e98:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800e9f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ea2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ea5:	8d 50 04             	lea    0x4(%eax),%edx
  800ea8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800eab:	8b 00                	mov    (%eax),%eax
  800ead:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800eb2:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800eb7:	eb 0d                	jmp    800ec6 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800eb9:	8d 45 14             	lea    0x14(%ebp),%eax
  800ebc:	e8 6d fc ff ff       	call   800b2e <getuint>
			base = 16;
  800ec1:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ec6:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800eca:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800ece:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800ed1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ed5:	89 74 24 08          	mov    %esi,0x8(%esp)
  800ed9:	89 04 24             	mov    %eax,(%esp)
  800edc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ee0:	89 da                	mov    %ebx,%edx
  800ee2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee5:	e8 7a fb ff ff       	call   800a64 <printnum>
			break;
  800eea:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800eed:	e9 0d fd ff ff       	jmp    800bff <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  800ef2:	8d 45 14             	lea    0x14(%ebp),%eax
  800ef5:	e8 6e fc ff ff       	call   800b68 <getint>
  800efa:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800eff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  800f02:	e9 f8 fc ff ff       	jmp    800bff <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800f07:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f0b:	89 04 24             	mov    %eax,(%esp)
  800f0e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f11:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800f14:	e9 e6 fc ff ff       	jmp    800bff <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800f19:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f1d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800f24:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800f27:	eb 01                	jmp    800f2a <vprintfmt+0x34e>
  800f29:	4e                   	dec    %esi
  800f2a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800f2e:	75 f9                	jne    800f29 <vprintfmt+0x34d>
  800f30:	e9 ca fc ff ff       	jmp    800bff <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800f35:	83 c4 4c             	add    $0x4c,%esp
  800f38:	5b                   	pop    %ebx
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	83 ec 28             	sub    $0x28,%esp
  800f43:	8b 45 08             	mov    0x8(%ebp),%eax
  800f46:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800f49:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f4c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800f50:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f53:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	74 30                	je     800f8e <vsnprintf+0x51>
  800f5e:	85 d2                	test   %edx,%edx
  800f60:	7e 33                	jle    800f95 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f62:	8b 45 14             	mov    0x14(%ebp),%eax
  800f65:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f69:	8b 45 10             	mov    0x10(%ebp),%eax
  800f6c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f70:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f73:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f77:	c7 04 24 9a 0b 80 00 	movl   $0x800b9a,(%esp)
  800f7e:	e8 59 fc ff ff       	call   800bdc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f83:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f86:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f8c:	eb 0c                	jmp    800f9a <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800f8e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f93:	eb 05                	jmp    800f9a <vsnprintf+0x5d>
  800f95:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800f9a:	c9                   	leave  
  800f9b:	c3                   	ret    

00800f9c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800fa2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800fa5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fa9:	8b 45 10             	mov    0x10(%ebp),%eax
  800fac:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fba:	89 04 24             	mov    %eax,(%esp)
  800fbd:	e8 7b ff ff ff       	call   800f3d <vsnprintf>
	va_end(ap);

	return rc;
}
  800fc2:	c9                   	leave  
  800fc3:	c3                   	ret    

00800fc4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800fca:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcf:	eb 01                	jmp    800fd2 <strlen+0xe>
		n++;
  800fd1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800fd2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800fd6:	75 f9                	jne    800fd1 <strlen+0xd>
		n++;
	return n;
}
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    

00800fda <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800fe0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fe3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe8:	eb 01                	jmp    800feb <strnlen+0x11>
		n++;
  800fea:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800feb:	39 d0                	cmp    %edx,%eax
  800fed:	74 06                	je     800ff5 <strnlen+0x1b>
  800fef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800ff3:	75 f5                	jne    800fea <strnlen+0x10>
		n++;
	return n;
}
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	53                   	push   %ebx
  800ffb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ffe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801001:	ba 00 00 00 00       	mov    $0x0,%edx
  801006:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801009:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80100c:	42                   	inc    %edx
  80100d:	84 c9                	test   %cl,%cl
  80100f:	75 f5                	jne    801006 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801011:	5b                   	pop    %ebx
  801012:	5d                   	pop    %ebp
  801013:	c3                   	ret    

00801014 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	53                   	push   %ebx
  801018:	83 ec 08             	sub    $0x8,%esp
  80101b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80101e:	89 1c 24             	mov    %ebx,(%esp)
  801021:	e8 9e ff ff ff       	call   800fc4 <strlen>
	strcpy(dst + len, src);
  801026:	8b 55 0c             	mov    0xc(%ebp),%edx
  801029:	89 54 24 04          	mov    %edx,0x4(%esp)
  80102d:	01 d8                	add    %ebx,%eax
  80102f:	89 04 24             	mov    %eax,(%esp)
  801032:	e8 c0 ff ff ff       	call   800ff7 <strcpy>
	return dst;
}
  801037:	89 d8                	mov    %ebx,%eax
  801039:	83 c4 08             	add    $0x8,%esp
  80103c:	5b                   	pop    %ebx
  80103d:	5d                   	pop    %ebp
  80103e:	c3                   	ret    

0080103f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80103f:	55                   	push   %ebp
  801040:	89 e5                	mov    %esp,%ebp
  801042:	56                   	push   %esi
  801043:	53                   	push   %ebx
  801044:	8b 45 08             	mov    0x8(%ebp),%eax
  801047:	8b 55 0c             	mov    0xc(%ebp),%edx
  80104a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80104d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801052:	eb 0c                	jmp    801060 <strncpy+0x21>
		*dst++ = *src;
  801054:	8a 1a                	mov    (%edx),%bl
  801056:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801059:	80 3a 01             	cmpb   $0x1,(%edx)
  80105c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80105f:	41                   	inc    %ecx
  801060:	39 f1                	cmp    %esi,%ecx
  801062:	75 f0                	jne    801054 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801064:	5b                   	pop    %ebx
  801065:	5e                   	pop    %esi
  801066:	5d                   	pop    %ebp
  801067:	c3                   	ret    

00801068 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	56                   	push   %esi
  80106c:	53                   	push   %ebx
  80106d:	8b 75 08             	mov    0x8(%ebp),%esi
  801070:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801073:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801076:	85 d2                	test   %edx,%edx
  801078:	75 0a                	jne    801084 <strlcpy+0x1c>
  80107a:	89 f0                	mov    %esi,%eax
  80107c:	eb 1a                	jmp    801098 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80107e:	88 18                	mov    %bl,(%eax)
  801080:	40                   	inc    %eax
  801081:	41                   	inc    %ecx
  801082:	eb 02                	jmp    801086 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801084:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801086:	4a                   	dec    %edx
  801087:	74 0a                	je     801093 <strlcpy+0x2b>
  801089:	8a 19                	mov    (%ecx),%bl
  80108b:	84 db                	test   %bl,%bl
  80108d:	75 ef                	jne    80107e <strlcpy+0x16>
  80108f:	89 c2                	mov    %eax,%edx
  801091:	eb 02                	jmp    801095 <strlcpy+0x2d>
  801093:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801095:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801098:	29 f0                	sub    %esi,%eax
}
  80109a:	5b                   	pop    %ebx
  80109b:	5e                   	pop    %esi
  80109c:	5d                   	pop    %ebp
  80109d:	c3                   	ret    

0080109e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8010a7:	eb 02                	jmp    8010ab <strcmp+0xd>
		p++, q++;
  8010a9:	41                   	inc    %ecx
  8010aa:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8010ab:	8a 01                	mov    (%ecx),%al
  8010ad:	84 c0                	test   %al,%al
  8010af:	74 04                	je     8010b5 <strcmp+0x17>
  8010b1:	3a 02                	cmp    (%edx),%al
  8010b3:	74 f4                	je     8010a9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8010b5:	0f b6 c0             	movzbl %al,%eax
  8010b8:	0f b6 12             	movzbl (%edx),%edx
  8010bb:	29 d0                	sub    %edx,%eax
}
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    

008010bf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	53                   	push   %ebx
  8010c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8010cc:	eb 03                	jmp    8010d1 <strncmp+0x12>
		n--, p++, q++;
  8010ce:	4a                   	dec    %edx
  8010cf:	40                   	inc    %eax
  8010d0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8010d1:	85 d2                	test   %edx,%edx
  8010d3:	74 14                	je     8010e9 <strncmp+0x2a>
  8010d5:	8a 18                	mov    (%eax),%bl
  8010d7:	84 db                	test   %bl,%bl
  8010d9:	74 04                	je     8010df <strncmp+0x20>
  8010db:	3a 19                	cmp    (%ecx),%bl
  8010dd:	74 ef                	je     8010ce <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8010df:	0f b6 00             	movzbl (%eax),%eax
  8010e2:	0f b6 11             	movzbl (%ecx),%edx
  8010e5:	29 d0                	sub    %edx,%eax
  8010e7:	eb 05                	jmp    8010ee <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8010e9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010ee:	5b                   	pop    %ebx
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    

008010f1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8010fa:	eb 05                	jmp    801101 <strchr+0x10>
		if (*s == c)
  8010fc:	38 ca                	cmp    %cl,%dl
  8010fe:	74 0c                	je     80110c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801100:	40                   	inc    %eax
  801101:	8a 10                	mov    (%eax),%dl
  801103:	84 d2                	test   %dl,%dl
  801105:	75 f5                	jne    8010fc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  801107:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80110c:	5d                   	pop    %ebp
  80110d:	c3                   	ret    

0080110e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80110e:	55                   	push   %ebp
  80110f:	89 e5                	mov    %esp,%ebp
  801111:	8b 45 08             	mov    0x8(%ebp),%eax
  801114:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801117:	eb 05                	jmp    80111e <strfind+0x10>
		if (*s == c)
  801119:	38 ca                	cmp    %cl,%dl
  80111b:	74 07                	je     801124 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80111d:	40                   	inc    %eax
  80111e:	8a 10                	mov    (%eax),%dl
  801120:	84 d2                	test   %dl,%dl
  801122:	75 f5                	jne    801119 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801124:	5d                   	pop    %ebp
  801125:	c3                   	ret    

00801126 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	57                   	push   %edi
  80112a:	56                   	push   %esi
  80112b:	53                   	push   %ebx
  80112c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80112f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801132:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801135:	85 c9                	test   %ecx,%ecx
  801137:	74 30                	je     801169 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801139:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80113f:	75 25                	jne    801166 <memset+0x40>
  801141:	f6 c1 03             	test   $0x3,%cl
  801144:	75 20                	jne    801166 <memset+0x40>
		c &= 0xFF;
  801146:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801149:	89 d3                	mov    %edx,%ebx
  80114b:	c1 e3 08             	shl    $0x8,%ebx
  80114e:	89 d6                	mov    %edx,%esi
  801150:	c1 e6 18             	shl    $0x18,%esi
  801153:	89 d0                	mov    %edx,%eax
  801155:	c1 e0 10             	shl    $0x10,%eax
  801158:	09 f0                	or     %esi,%eax
  80115a:	09 d0                	or     %edx,%eax
  80115c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80115e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801161:	fc                   	cld    
  801162:	f3 ab                	rep stos %eax,%es:(%edi)
  801164:	eb 03                	jmp    801169 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801166:	fc                   	cld    
  801167:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801169:	89 f8                	mov    %edi,%eax
  80116b:	5b                   	pop    %ebx
  80116c:	5e                   	pop    %esi
  80116d:	5f                   	pop    %edi
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    

00801170 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	57                   	push   %edi
  801174:	56                   	push   %esi
  801175:	8b 45 08             	mov    0x8(%ebp),%eax
  801178:	8b 75 0c             	mov    0xc(%ebp),%esi
  80117b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80117e:	39 c6                	cmp    %eax,%esi
  801180:	73 34                	jae    8011b6 <memmove+0x46>
  801182:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801185:	39 d0                	cmp    %edx,%eax
  801187:	73 2d                	jae    8011b6 <memmove+0x46>
		s += n;
		d += n;
  801189:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80118c:	f6 c2 03             	test   $0x3,%dl
  80118f:	75 1b                	jne    8011ac <memmove+0x3c>
  801191:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801197:	75 13                	jne    8011ac <memmove+0x3c>
  801199:	f6 c1 03             	test   $0x3,%cl
  80119c:	75 0e                	jne    8011ac <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80119e:	83 ef 04             	sub    $0x4,%edi
  8011a1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8011a4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8011a7:	fd                   	std    
  8011a8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8011aa:	eb 07                	jmp    8011b3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8011ac:	4f                   	dec    %edi
  8011ad:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8011b0:	fd                   	std    
  8011b1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8011b3:	fc                   	cld    
  8011b4:	eb 20                	jmp    8011d6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8011b6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8011bc:	75 13                	jne    8011d1 <memmove+0x61>
  8011be:	a8 03                	test   $0x3,%al
  8011c0:	75 0f                	jne    8011d1 <memmove+0x61>
  8011c2:	f6 c1 03             	test   $0x3,%cl
  8011c5:	75 0a                	jne    8011d1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8011c7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8011ca:	89 c7                	mov    %eax,%edi
  8011cc:	fc                   	cld    
  8011cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8011cf:	eb 05                	jmp    8011d6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8011d1:	89 c7                	mov    %eax,%edi
  8011d3:	fc                   	cld    
  8011d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8011d6:	5e                   	pop    %esi
  8011d7:	5f                   	pop    %edi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8011e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8011e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f1:	89 04 24             	mov    %eax,(%esp)
  8011f4:	e8 77 ff ff ff       	call   801170 <memmove>
}
  8011f9:	c9                   	leave  
  8011fa:	c3                   	ret    

008011fb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	57                   	push   %edi
  8011ff:	56                   	push   %esi
  801200:	53                   	push   %ebx
  801201:	8b 7d 08             	mov    0x8(%ebp),%edi
  801204:	8b 75 0c             	mov    0xc(%ebp),%esi
  801207:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80120a:	ba 00 00 00 00       	mov    $0x0,%edx
  80120f:	eb 16                	jmp    801227 <memcmp+0x2c>
		if (*s1 != *s2)
  801211:	8a 04 17             	mov    (%edi,%edx,1),%al
  801214:	42                   	inc    %edx
  801215:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801219:	38 c8                	cmp    %cl,%al
  80121b:	74 0a                	je     801227 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  80121d:	0f b6 c0             	movzbl %al,%eax
  801220:	0f b6 c9             	movzbl %cl,%ecx
  801223:	29 c8                	sub    %ecx,%eax
  801225:	eb 09                	jmp    801230 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801227:	39 da                	cmp    %ebx,%edx
  801229:	75 e6                	jne    801211 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80122b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801230:	5b                   	pop    %ebx
  801231:	5e                   	pop    %esi
  801232:	5f                   	pop    %edi
  801233:	5d                   	pop    %ebp
  801234:	c3                   	ret    

00801235 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	8b 45 08             	mov    0x8(%ebp),%eax
  80123b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80123e:	89 c2                	mov    %eax,%edx
  801240:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801243:	eb 05                	jmp    80124a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801245:	38 08                	cmp    %cl,(%eax)
  801247:	74 05                	je     80124e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801249:	40                   	inc    %eax
  80124a:	39 d0                	cmp    %edx,%eax
  80124c:	72 f7                	jb     801245 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	57                   	push   %edi
  801254:	56                   	push   %esi
  801255:	53                   	push   %ebx
  801256:	8b 55 08             	mov    0x8(%ebp),%edx
  801259:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80125c:	eb 01                	jmp    80125f <strtol+0xf>
		s++;
  80125e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80125f:	8a 02                	mov    (%edx),%al
  801261:	3c 20                	cmp    $0x20,%al
  801263:	74 f9                	je     80125e <strtol+0xe>
  801265:	3c 09                	cmp    $0x9,%al
  801267:	74 f5                	je     80125e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801269:	3c 2b                	cmp    $0x2b,%al
  80126b:	75 08                	jne    801275 <strtol+0x25>
		s++;
  80126d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80126e:	bf 00 00 00 00       	mov    $0x0,%edi
  801273:	eb 13                	jmp    801288 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801275:	3c 2d                	cmp    $0x2d,%al
  801277:	75 0a                	jne    801283 <strtol+0x33>
		s++, neg = 1;
  801279:	8d 52 01             	lea    0x1(%edx),%edx
  80127c:	bf 01 00 00 00       	mov    $0x1,%edi
  801281:	eb 05                	jmp    801288 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801283:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801288:	85 db                	test   %ebx,%ebx
  80128a:	74 05                	je     801291 <strtol+0x41>
  80128c:	83 fb 10             	cmp    $0x10,%ebx
  80128f:	75 28                	jne    8012b9 <strtol+0x69>
  801291:	8a 02                	mov    (%edx),%al
  801293:	3c 30                	cmp    $0x30,%al
  801295:	75 10                	jne    8012a7 <strtol+0x57>
  801297:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80129b:	75 0a                	jne    8012a7 <strtol+0x57>
		s += 2, base = 16;
  80129d:	83 c2 02             	add    $0x2,%edx
  8012a0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8012a5:	eb 12                	jmp    8012b9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8012a7:	85 db                	test   %ebx,%ebx
  8012a9:	75 0e                	jne    8012b9 <strtol+0x69>
  8012ab:	3c 30                	cmp    $0x30,%al
  8012ad:	75 05                	jne    8012b4 <strtol+0x64>
		s++, base = 8;
  8012af:	42                   	inc    %edx
  8012b0:	b3 08                	mov    $0x8,%bl
  8012b2:	eb 05                	jmp    8012b9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8012b4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8012b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012be:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8012c0:	8a 0a                	mov    (%edx),%cl
  8012c2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8012c5:	80 fb 09             	cmp    $0x9,%bl
  8012c8:	77 08                	ja     8012d2 <strtol+0x82>
			dig = *s - '0';
  8012ca:	0f be c9             	movsbl %cl,%ecx
  8012cd:	83 e9 30             	sub    $0x30,%ecx
  8012d0:	eb 1e                	jmp    8012f0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8012d2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8012d5:	80 fb 19             	cmp    $0x19,%bl
  8012d8:	77 08                	ja     8012e2 <strtol+0x92>
			dig = *s - 'a' + 10;
  8012da:	0f be c9             	movsbl %cl,%ecx
  8012dd:	83 e9 57             	sub    $0x57,%ecx
  8012e0:	eb 0e                	jmp    8012f0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8012e2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8012e5:	80 fb 19             	cmp    $0x19,%bl
  8012e8:	77 12                	ja     8012fc <strtol+0xac>
			dig = *s - 'A' + 10;
  8012ea:	0f be c9             	movsbl %cl,%ecx
  8012ed:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8012f0:	39 f1                	cmp    %esi,%ecx
  8012f2:	7d 0c                	jge    801300 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8012f4:	42                   	inc    %edx
  8012f5:	0f af c6             	imul   %esi,%eax
  8012f8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8012fa:	eb c4                	jmp    8012c0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8012fc:	89 c1                	mov    %eax,%ecx
  8012fe:	eb 02                	jmp    801302 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801300:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801302:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801306:	74 05                	je     80130d <strtol+0xbd>
		*endptr = (char *) s;
  801308:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80130b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  80130d:	85 ff                	test   %edi,%edi
  80130f:	74 04                	je     801315 <strtol+0xc5>
  801311:	89 c8                	mov    %ecx,%eax
  801313:	f7 d8                	neg    %eax
}
  801315:	5b                   	pop    %ebx
  801316:	5e                   	pop    %esi
  801317:	5f                   	pop    %edi
  801318:	5d                   	pop    %ebp
  801319:	c3                   	ret    
	...

0080131c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801322:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801329:	75 40                	jne    80136b <set_pgfault_handler+0x4f>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
  80132b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801332:	00 
  801333:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80133a:	ee 
  80133b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801342:	e8 46 ee ff ff       	call   80018d <sys_page_alloc>
  801347:	85 c0                	test   %eax,%eax
  801349:	79 20                	jns    80136b <set_pgfault_handler+0x4f>
            panic("set_pgfault_handler: sys_page_alloc: %e", r);
  80134b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80134f:	c7 44 24 08 a8 18 80 	movl   $0x8018a8,0x8(%esp)
  801356:	00 
  801357:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80135e:	00 
  80135f:	c7 04 24 04 19 80 00 	movl   $0x801904,(%esp)
  801366:	e8 e5 f5 ff ff       	call   800950 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80136b:	8b 45 08             	mov    0x8(%ebp),%eax
  80136e:	a3 0c 20 80 00       	mov    %eax,0x80200c
    if ((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0 )
  801373:	c7 44 24 04 28 09 80 	movl   $0x800928,0x4(%esp)
  80137a:	00 
  80137b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801382:	e8 53 ef ff ff       	call   8002da <sys_env_set_pgfault_upcall>
  801387:	85 c0                	test   %eax,%eax
  801389:	79 20                	jns    8013ab <set_pgfault_handler+0x8f>
        panic("set_pgfault_handler: sys_env_set_pgfault_upcall: %e", r);
  80138b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80138f:	c7 44 24 08 d0 18 80 	movl   $0x8018d0,0x8(%esp)
  801396:	00 
  801397:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80139e:	00 
  80139f:	c7 04 24 04 19 80 00 	movl   $0x801904,(%esp)
  8013a6:	e8 a5 f5 ff ff       	call   800950 <_panic>
}
  8013ab:	c9                   	leave  
  8013ac:	c3                   	ret    
  8013ad:	00 00                	add    %al,(%eax)
	...

008013b0 <__udivdi3>:
  8013b0:	55                   	push   %ebp
  8013b1:	57                   	push   %edi
  8013b2:	56                   	push   %esi
  8013b3:	83 ec 10             	sub    $0x10,%esp
  8013b6:	8b 74 24 20          	mov    0x20(%esp),%esi
  8013ba:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8013be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013c2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8013c6:	89 cd                	mov    %ecx,%ebp
  8013c8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	75 2c                	jne    8013fc <__udivdi3+0x4c>
  8013d0:	39 f9                	cmp    %edi,%ecx
  8013d2:	77 68                	ja     80143c <__udivdi3+0x8c>
  8013d4:	85 c9                	test   %ecx,%ecx
  8013d6:	75 0b                	jne    8013e3 <__udivdi3+0x33>
  8013d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8013dd:	31 d2                	xor    %edx,%edx
  8013df:	f7 f1                	div    %ecx
  8013e1:	89 c1                	mov    %eax,%ecx
  8013e3:	31 d2                	xor    %edx,%edx
  8013e5:	89 f8                	mov    %edi,%eax
  8013e7:	f7 f1                	div    %ecx
  8013e9:	89 c7                	mov    %eax,%edi
  8013eb:	89 f0                	mov    %esi,%eax
  8013ed:	f7 f1                	div    %ecx
  8013ef:	89 c6                	mov    %eax,%esi
  8013f1:	89 f0                	mov    %esi,%eax
  8013f3:	89 fa                	mov    %edi,%edx
  8013f5:	83 c4 10             	add    $0x10,%esp
  8013f8:	5e                   	pop    %esi
  8013f9:	5f                   	pop    %edi
  8013fa:	5d                   	pop    %ebp
  8013fb:	c3                   	ret    
  8013fc:	39 f8                	cmp    %edi,%eax
  8013fe:	77 2c                	ja     80142c <__udivdi3+0x7c>
  801400:	0f bd f0             	bsr    %eax,%esi
  801403:	83 f6 1f             	xor    $0x1f,%esi
  801406:	75 4c                	jne    801454 <__udivdi3+0xa4>
  801408:	39 f8                	cmp    %edi,%eax
  80140a:	bf 00 00 00 00       	mov    $0x0,%edi
  80140f:	72 0a                	jb     80141b <__udivdi3+0x6b>
  801411:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801415:	0f 87 ad 00 00 00    	ja     8014c8 <__udivdi3+0x118>
  80141b:	be 01 00 00 00       	mov    $0x1,%esi
  801420:	89 f0                	mov    %esi,%eax
  801422:	89 fa                	mov    %edi,%edx
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	5e                   	pop    %esi
  801428:	5f                   	pop    %edi
  801429:	5d                   	pop    %ebp
  80142a:	c3                   	ret    
  80142b:	90                   	nop
  80142c:	31 ff                	xor    %edi,%edi
  80142e:	31 f6                	xor    %esi,%esi
  801430:	89 f0                	mov    %esi,%eax
  801432:	89 fa                	mov    %edi,%edx
  801434:	83 c4 10             	add    $0x10,%esp
  801437:	5e                   	pop    %esi
  801438:	5f                   	pop    %edi
  801439:	5d                   	pop    %ebp
  80143a:	c3                   	ret    
  80143b:	90                   	nop
  80143c:	89 fa                	mov    %edi,%edx
  80143e:	89 f0                	mov    %esi,%eax
  801440:	f7 f1                	div    %ecx
  801442:	89 c6                	mov    %eax,%esi
  801444:	31 ff                	xor    %edi,%edi
  801446:	89 f0                	mov    %esi,%eax
  801448:	89 fa                	mov    %edi,%edx
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	5e                   	pop    %esi
  80144e:	5f                   	pop    %edi
  80144f:	5d                   	pop    %ebp
  801450:	c3                   	ret    
  801451:	8d 76 00             	lea    0x0(%esi),%esi
  801454:	89 f1                	mov    %esi,%ecx
  801456:	d3 e0                	shl    %cl,%eax
  801458:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80145c:	b8 20 00 00 00       	mov    $0x20,%eax
  801461:	29 f0                	sub    %esi,%eax
  801463:	89 ea                	mov    %ebp,%edx
  801465:	88 c1                	mov    %al,%cl
  801467:	d3 ea                	shr    %cl,%edx
  801469:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80146d:	09 ca                	or     %ecx,%edx
  80146f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801473:	89 f1                	mov    %esi,%ecx
  801475:	d3 e5                	shl    %cl,%ebp
  801477:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80147b:	89 fd                	mov    %edi,%ebp
  80147d:	88 c1                	mov    %al,%cl
  80147f:	d3 ed                	shr    %cl,%ebp
  801481:	89 fa                	mov    %edi,%edx
  801483:	89 f1                	mov    %esi,%ecx
  801485:	d3 e2                	shl    %cl,%edx
  801487:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80148b:	88 c1                	mov    %al,%cl
  80148d:	d3 ef                	shr    %cl,%edi
  80148f:	09 d7                	or     %edx,%edi
  801491:	89 f8                	mov    %edi,%eax
  801493:	89 ea                	mov    %ebp,%edx
  801495:	f7 74 24 08          	divl   0x8(%esp)
  801499:	89 d1                	mov    %edx,%ecx
  80149b:	89 c7                	mov    %eax,%edi
  80149d:	f7 64 24 0c          	mull   0xc(%esp)
  8014a1:	39 d1                	cmp    %edx,%ecx
  8014a3:	72 17                	jb     8014bc <__udivdi3+0x10c>
  8014a5:	74 09                	je     8014b0 <__udivdi3+0x100>
  8014a7:	89 fe                	mov    %edi,%esi
  8014a9:	31 ff                	xor    %edi,%edi
  8014ab:	e9 41 ff ff ff       	jmp    8013f1 <__udivdi3+0x41>
  8014b0:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014b4:	89 f1                	mov    %esi,%ecx
  8014b6:	d3 e2                	shl    %cl,%edx
  8014b8:	39 c2                	cmp    %eax,%edx
  8014ba:	73 eb                	jae    8014a7 <__udivdi3+0xf7>
  8014bc:	8d 77 ff             	lea    -0x1(%edi),%esi
  8014bf:	31 ff                	xor    %edi,%edi
  8014c1:	e9 2b ff ff ff       	jmp    8013f1 <__udivdi3+0x41>
  8014c6:	66 90                	xchg   %ax,%ax
  8014c8:	31 f6                	xor    %esi,%esi
  8014ca:	e9 22 ff ff ff       	jmp    8013f1 <__udivdi3+0x41>
	...

008014d0 <__umoddi3>:
  8014d0:	55                   	push   %ebp
  8014d1:	57                   	push   %edi
  8014d2:	56                   	push   %esi
  8014d3:	83 ec 20             	sub    $0x20,%esp
  8014d6:	8b 44 24 30          	mov    0x30(%esp),%eax
  8014da:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8014de:	89 44 24 14          	mov    %eax,0x14(%esp)
  8014e2:	8b 74 24 34          	mov    0x34(%esp),%esi
  8014e6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8014ea:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8014ee:	89 c7                	mov    %eax,%edi
  8014f0:	89 f2                	mov    %esi,%edx
  8014f2:	85 ed                	test   %ebp,%ebp
  8014f4:	75 16                	jne    80150c <__umoddi3+0x3c>
  8014f6:	39 f1                	cmp    %esi,%ecx
  8014f8:	0f 86 a6 00 00 00    	jbe    8015a4 <__umoddi3+0xd4>
  8014fe:	f7 f1                	div    %ecx
  801500:	89 d0                	mov    %edx,%eax
  801502:	31 d2                	xor    %edx,%edx
  801504:	83 c4 20             	add    $0x20,%esp
  801507:	5e                   	pop    %esi
  801508:	5f                   	pop    %edi
  801509:	5d                   	pop    %ebp
  80150a:	c3                   	ret    
  80150b:	90                   	nop
  80150c:	39 f5                	cmp    %esi,%ebp
  80150e:	0f 87 ac 00 00 00    	ja     8015c0 <__umoddi3+0xf0>
  801514:	0f bd c5             	bsr    %ebp,%eax
  801517:	83 f0 1f             	xor    $0x1f,%eax
  80151a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80151e:	0f 84 a8 00 00 00    	je     8015cc <__umoddi3+0xfc>
  801524:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801528:	d3 e5                	shl    %cl,%ebp
  80152a:	bf 20 00 00 00       	mov    $0x20,%edi
  80152f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801533:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801537:	89 f9                	mov    %edi,%ecx
  801539:	d3 e8                	shr    %cl,%eax
  80153b:	09 e8                	or     %ebp,%eax
  80153d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801541:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801545:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801549:	d3 e0                	shl    %cl,%eax
  80154b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80154f:	89 f2                	mov    %esi,%edx
  801551:	d3 e2                	shl    %cl,%edx
  801553:	8b 44 24 14          	mov    0x14(%esp),%eax
  801557:	d3 e0                	shl    %cl,%eax
  801559:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  80155d:	8b 44 24 14          	mov    0x14(%esp),%eax
  801561:	89 f9                	mov    %edi,%ecx
  801563:	d3 e8                	shr    %cl,%eax
  801565:	09 d0                	or     %edx,%eax
  801567:	d3 ee                	shr    %cl,%esi
  801569:	89 f2                	mov    %esi,%edx
  80156b:	f7 74 24 18          	divl   0x18(%esp)
  80156f:	89 d6                	mov    %edx,%esi
  801571:	f7 64 24 0c          	mull   0xc(%esp)
  801575:	89 c5                	mov    %eax,%ebp
  801577:	89 d1                	mov    %edx,%ecx
  801579:	39 d6                	cmp    %edx,%esi
  80157b:	72 67                	jb     8015e4 <__umoddi3+0x114>
  80157d:	74 75                	je     8015f4 <__umoddi3+0x124>
  80157f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801583:	29 e8                	sub    %ebp,%eax
  801585:	19 ce                	sbb    %ecx,%esi
  801587:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80158b:	d3 e8                	shr    %cl,%eax
  80158d:	89 f2                	mov    %esi,%edx
  80158f:	89 f9                	mov    %edi,%ecx
  801591:	d3 e2                	shl    %cl,%edx
  801593:	09 d0                	or     %edx,%eax
  801595:	89 f2                	mov    %esi,%edx
  801597:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80159b:	d3 ea                	shr    %cl,%edx
  80159d:	83 c4 20             	add    $0x20,%esp
  8015a0:	5e                   	pop    %esi
  8015a1:	5f                   	pop    %edi
  8015a2:	5d                   	pop    %ebp
  8015a3:	c3                   	ret    
  8015a4:	85 c9                	test   %ecx,%ecx
  8015a6:	75 0b                	jne    8015b3 <__umoddi3+0xe3>
  8015a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ad:	31 d2                	xor    %edx,%edx
  8015af:	f7 f1                	div    %ecx
  8015b1:	89 c1                	mov    %eax,%ecx
  8015b3:	89 f0                	mov    %esi,%eax
  8015b5:	31 d2                	xor    %edx,%edx
  8015b7:	f7 f1                	div    %ecx
  8015b9:	89 f8                	mov    %edi,%eax
  8015bb:	e9 3e ff ff ff       	jmp    8014fe <__umoddi3+0x2e>
  8015c0:	89 f2                	mov    %esi,%edx
  8015c2:	83 c4 20             	add    $0x20,%esp
  8015c5:	5e                   	pop    %esi
  8015c6:	5f                   	pop    %edi
  8015c7:	5d                   	pop    %ebp
  8015c8:	c3                   	ret    
  8015c9:	8d 76 00             	lea    0x0(%esi),%esi
  8015cc:	39 f5                	cmp    %esi,%ebp
  8015ce:	72 04                	jb     8015d4 <__umoddi3+0x104>
  8015d0:	39 f9                	cmp    %edi,%ecx
  8015d2:	77 06                	ja     8015da <__umoddi3+0x10a>
  8015d4:	89 f2                	mov    %esi,%edx
  8015d6:	29 cf                	sub    %ecx,%edi
  8015d8:	19 ea                	sbb    %ebp,%edx
  8015da:	89 f8                	mov    %edi,%eax
  8015dc:	83 c4 20             	add    $0x20,%esp
  8015df:	5e                   	pop    %esi
  8015e0:	5f                   	pop    %edi
  8015e1:	5d                   	pop    %ebp
  8015e2:	c3                   	ret    
  8015e3:	90                   	nop
  8015e4:	89 d1                	mov    %edx,%ecx
  8015e6:	89 c5                	mov    %eax,%ebp
  8015e8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8015ec:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8015f0:	eb 8d                	jmp    80157f <__umoddi3+0xaf>
  8015f2:	66 90                	xchg   %ax,%ax
  8015f4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8015f8:	72 ea                	jb     8015e4 <__umoddi3+0x114>
  8015fa:	89 f1                	mov    %esi,%ecx
  8015fc:	eb 81                	jmp    80157f <__umoddi3+0xaf>
