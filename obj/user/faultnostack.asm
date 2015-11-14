
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
  80003a:	c7 44 24 04 a4 03 80 	movl   $0x8003a4,0x4(%esp)
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
  800077:	8d 14 90             	lea    (%eax,%edx,4),%edx
  80007a:	8d 04 50             	lea    (%eax,%edx,2),%eax
  80007d:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  800084:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800089:	85 f6                	test   %esi,%esi
  80008b:	7e 07                	jle    800094 <libmain+0x38>
		binaryname = argv[0];
  80008d:	8b 03                	mov    (%ebx),%eax
  80008f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800094:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800098:	89 34 24             	mov    %esi,(%esp)
  80009b:	e8 94 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a0:	e8 07 00 00 00       	call   8000ac <exit>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	5b                   	pop    %ebx
  8000a9:	5e                   	pop    %esi
  8000aa:	5d                   	pop    %ebp
  8000ab:	c3                   	ret    

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
  80012b:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800132:	00 
  800133:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80013a:	00 
  80013b:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800142:	e8 85 02 00 00       	call   8003cc <_panic>

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
  8001bd:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001cc:	00 
  8001cd:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8001d4:	e8 f3 01 00 00       	call   8003cc <_panic>

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
  800210:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800217:	00 
  800218:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80021f:	00 
  800220:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800227:	e8 a0 01 00 00       	call   8003cc <_panic>

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
  800263:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  80026a:	00 
  80026b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800272:	00 
  800273:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  80027a:	e8 4d 01 00 00       	call   8003cc <_panic>

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
  8002b6:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8002bd:	00 
  8002be:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c5:	00 
  8002c6:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8002cd:	e8 fa 00 00 00       	call   8003cc <_panic>

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
  800309:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800310:	00 
  800311:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800318:	00 
  800319:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800320:	e8 a7 00 00 00       	call   8003cc <_panic>

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
  80037e:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800385:	00 
  800386:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80038d:	00 
  80038e:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800395:	e8 32 00 00 00       	call   8003cc <_panic>

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
	...

008003a4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8003a4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8003a5:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8003aa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8003ac:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// sub 4 from old esp
	movl 0x30(%esp), %eax
  8003af:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8003b3:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8003b6:	89 44 24 30          	mov    %eax,0x30(%esp)
	// put old eip into the pre-reserved 4-byte space
	movl 0x28(%esp), %ebx
  8003ba:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8003be:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8003c0:	83 c4 08             	add    $0x8,%esp
	popal
  8003c3:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  8003c4:	83 c4 04             	add    $0x4,%esp
	popfl
  8003c7:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8003c8:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8003c9:	c3                   	ret    
	...

008003cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	56                   	push   %esi
  8003d0:	53                   	push   %ebx
  8003d1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003d7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8003dd:	e8 6d fd ff ff       	call   80014f <sys_getenvid>
  8003e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f8:	c7 04 24 b8 10 80 00 	movl   $0x8010b8,(%esp)
  8003ff:	e8 c0 00 00 00       	call   8004c4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800404:	89 74 24 04          	mov    %esi,0x4(%esp)
  800408:	8b 45 10             	mov    0x10(%ebp),%eax
  80040b:	89 04 24             	mov    %eax,(%esp)
  80040e:	e8 50 00 00 00       	call   800463 <vcprintf>
	cprintf("\n");
  800413:	c7 04 24 db 10 80 00 	movl   $0x8010db,(%esp)
  80041a:	e8 a5 00 00 00       	call   8004c4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80041f:	cc                   	int3   
  800420:	eb fd                	jmp    80041f <_panic+0x53>
	...

00800424 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	53                   	push   %ebx
  800428:	83 ec 14             	sub    $0x14,%esp
  80042b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80042e:	8b 03                	mov    (%ebx),%eax
  800430:	8b 55 08             	mov    0x8(%ebp),%edx
  800433:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800437:	40                   	inc    %eax
  800438:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80043a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80043f:	75 19                	jne    80045a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800441:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800448:	00 
  800449:	8d 43 08             	lea    0x8(%ebx),%eax
  80044c:	89 04 24             	mov    %eax,(%esp)
  80044f:	e8 6c fc ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  800454:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80045a:	ff 43 04             	incl   0x4(%ebx)
}
  80045d:	83 c4 14             	add    $0x14,%esp
  800460:	5b                   	pop    %ebx
  800461:	5d                   	pop    %ebp
  800462:	c3                   	ret    

00800463 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800463:	55                   	push   %ebp
  800464:	89 e5                	mov    %esp,%ebp
  800466:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80046c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800473:	00 00 00 
	b.cnt = 0;
  800476:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80047d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800480:	8b 45 0c             	mov    0xc(%ebp),%eax
  800483:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800487:	8b 45 08             	mov    0x8(%ebp),%eax
  80048a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80048e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800494:	89 44 24 04          	mov    %eax,0x4(%esp)
  800498:	c7 04 24 24 04 80 00 	movl   $0x800424,(%esp)
  80049f:	e8 b4 01 00 00       	call   800658 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004a4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ae:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004b4:	89 04 24             	mov    %eax,(%esp)
  8004b7:	e8 04 fc ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  8004bc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004c2:	c9                   	leave  
  8004c3:	c3                   	ret    

008004c4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004ca:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d4:	89 04 24             	mov    %eax,(%esp)
  8004d7:	e8 87 ff ff ff       	call   800463 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004dc:	c9                   	leave  
  8004dd:	c3                   	ret    
	...

008004e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	57                   	push   %edi
  8004e4:	56                   	push   %esi
  8004e5:	53                   	push   %ebx
  8004e6:	83 ec 3c             	sub    $0x3c,%esp
  8004e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ec:	89 d7                	mov    %edx,%edi
  8004ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004fd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800500:	85 c0                	test   %eax,%eax
  800502:	75 08                	jne    80050c <printnum+0x2c>
  800504:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800507:	39 45 10             	cmp    %eax,0x10(%ebp)
  80050a:	77 57                	ja     800563 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80050c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800510:	4b                   	dec    %ebx
  800511:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800515:	8b 45 10             	mov    0x10(%ebp),%eax
  800518:	89 44 24 08          	mov    %eax,0x8(%esp)
  80051c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800520:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800524:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80052b:	00 
  80052c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80052f:	89 04 24             	mov    %eax,(%esp)
  800532:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800535:	89 44 24 04          	mov    %eax,0x4(%esp)
  800539:	e8 ee 08 00 00       	call   800e2c <__udivdi3>
  80053e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800542:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800546:	89 04 24             	mov    %eax,(%esp)
  800549:	89 54 24 04          	mov    %edx,0x4(%esp)
  80054d:	89 fa                	mov    %edi,%edx
  80054f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800552:	e8 89 ff ff ff       	call   8004e0 <printnum>
  800557:	eb 0f                	jmp    800568 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800559:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80055d:	89 34 24             	mov    %esi,(%esp)
  800560:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800563:	4b                   	dec    %ebx
  800564:	85 db                	test   %ebx,%ebx
  800566:	7f f1                	jg     800559 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800568:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80056c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800570:	8b 45 10             	mov    0x10(%ebp),%eax
  800573:	89 44 24 08          	mov    %eax,0x8(%esp)
  800577:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80057e:	00 
  80057f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800582:	89 04 24             	mov    %eax,(%esp)
  800585:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800588:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058c:	e8 bb 09 00 00       	call   800f4c <__umoddi3>
  800591:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800595:	0f be 80 dd 10 80 00 	movsbl 0x8010dd(%eax),%eax
  80059c:	89 04 24             	mov    %eax,(%esp)
  80059f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8005a2:	83 c4 3c             	add    $0x3c,%esp
  8005a5:	5b                   	pop    %ebx
  8005a6:	5e                   	pop    %esi
  8005a7:	5f                   	pop    %edi
  8005a8:	5d                   	pop    %ebp
  8005a9:	c3                   	ret    

008005aa <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005aa:	55                   	push   %ebp
  8005ab:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005ad:	83 fa 01             	cmp    $0x1,%edx
  8005b0:	7e 0e                	jle    8005c0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005b2:	8b 10                	mov    (%eax),%edx
  8005b4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005b7:	89 08                	mov    %ecx,(%eax)
  8005b9:	8b 02                	mov    (%edx),%eax
  8005bb:	8b 52 04             	mov    0x4(%edx),%edx
  8005be:	eb 22                	jmp    8005e2 <getuint+0x38>
	else if (lflag)
  8005c0:	85 d2                	test   %edx,%edx
  8005c2:	74 10                	je     8005d4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005c4:	8b 10                	mov    (%eax),%edx
  8005c6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005c9:	89 08                	mov    %ecx,(%eax)
  8005cb:	8b 02                	mov    (%edx),%eax
  8005cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8005d2:	eb 0e                	jmp    8005e2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005d4:	8b 10                	mov    (%eax),%edx
  8005d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005d9:	89 08                	mov    %ecx,(%eax)
  8005db:	8b 02                	mov    (%edx),%eax
  8005dd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005e2:	5d                   	pop    %ebp
  8005e3:	c3                   	ret    

008005e4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8005e4:	55                   	push   %ebp
  8005e5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005e7:	83 fa 01             	cmp    $0x1,%edx
  8005ea:	7e 0e                	jle    8005fa <getint+0x16>
		return va_arg(*ap, long long);
  8005ec:	8b 10                	mov    (%eax),%edx
  8005ee:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005f1:	89 08                	mov    %ecx,(%eax)
  8005f3:	8b 02                	mov    (%edx),%eax
  8005f5:	8b 52 04             	mov    0x4(%edx),%edx
  8005f8:	eb 1a                	jmp    800614 <getint+0x30>
	else if (lflag)
  8005fa:	85 d2                	test   %edx,%edx
  8005fc:	74 0c                	je     80060a <getint+0x26>
		return va_arg(*ap, long);
  8005fe:	8b 10                	mov    (%eax),%edx
  800600:	8d 4a 04             	lea    0x4(%edx),%ecx
  800603:	89 08                	mov    %ecx,(%eax)
  800605:	8b 02                	mov    (%edx),%eax
  800607:	99                   	cltd   
  800608:	eb 0a                	jmp    800614 <getint+0x30>
	else
		return va_arg(*ap, int);
  80060a:	8b 10                	mov    (%eax),%edx
  80060c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80060f:	89 08                	mov    %ecx,(%eax)
  800611:	8b 02                	mov    (%edx),%eax
  800613:	99                   	cltd   
}
  800614:	5d                   	pop    %ebp
  800615:	c3                   	ret    

00800616 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800616:	55                   	push   %ebp
  800617:	89 e5                	mov    %esp,%ebp
  800619:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80061c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80061f:	8b 10                	mov    (%eax),%edx
  800621:	3b 50 04             	cmp    0x4(%eax),%edx
  800624:	73 08                	jae    80062e <sprintputch+0x18>
		*b->buf++ = ch;
  800626:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800629:	88 0a                	mov    %cl,(%edx)
  80062b:	42                   	inc    %edx
  80062c:	89 10                	mov    %edx,(%eax)
}
  80062e:	5d                   	pop    %ebp
  80062f:	c3                   	ret    

00800630 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800636:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800639:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80063d:	8b 45 10             	mov    0x10(%ebp),%eax
  800640:	89 44 24 08          	mov    %eax,0x8(%esp)
  800644:	8b 45 0c             	mov    0xc(%ebp),%eax
  800647:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064b:	8b 45 08             	mov    0x8(%ebp),%eax
  80064e:	89 04 24             	mov    %eax,(%esp)
  800651:	e8 02 00 00 00       	call   800658 <vprintfmt>
	va_end(ap);
}
  800656:	c9                   	leave  
  800657:	c3                   	ret    

00800658 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800658:	55                   	push   %ebp
  800659:	89 e5                	mov    %esp,%ebp
  80065b:	57                   	push   %edi
  80065c:	56                   	push   %esi
  80065d:	53                   	push   %ebx
  80065e:	83 ec 4c             	sub    $0x4c,%esp
  800661:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800664:	8b 75 10             	mov    0x10(%ebp),%esi
  800667:	eb 12                	jmp    80067b <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800669:	85 c0                	test   %eax,%eax
  80066b:	0f 84 40 03 00 00    	je     8009b1 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800671:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800675:	89 04 24             	mov    %eax,(%esp)
  800678:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80067b:	0f b6 06             	movzbl (%esi),%eax
  80067e:	46                   	inc    %esi
  80067f:	83 f8 25             	cmp    $0x25,%eax
  800682:	75 e5                	jne    800669 <vprintfmt+0x11>
  800684:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800688:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80068f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800694:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80069b:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a0:	eb 26                	jmp    8006c8 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a2:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006a5:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8006a9:	eb 1d                	jmp    8006c8 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006ae:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8006b2:	eb 14                	jmp    8006c8 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8006b7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8006be:	eb 08                	jmp    8006c8 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8006c0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006c3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c8:	0f b6 06             	movzbl (%esi),%eax
  8006cb:	8d 4e 01             	lea    0x1(%esi),%ecx
  8006ce:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006d1:	8a 0e                	mov    (%esi),%cl
  8006d3:	83 e9 23             	sub    $0x23,%ecx
  8006d6:	80 f9 55             	cmp    $0x55,%cl
  8006d9:	0f 87 b6 02 00 00    	ja     800995 <vprintfmt+0x33d>
  8006df:	0f b6 c9             	movzbl %cl,%ecx
  8006e2:	ff 24 8d a0 11 80 00 	jmp    *0x8011a0(,%ecx,4)
  8006e9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ec:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006f1:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  8006f4:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  8006f8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006fb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8006fe:	83 f9 09             	cmp    $0x9,%ecx
  800701:	77 2a                	ja     80072d <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800703:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800704:	eb eb                	jmp    8006f1 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8d 48 04             	lea    0x4(%eax),%ecx
  80070c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80070f:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800711:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800714:	eb 17                	jmp    80072d <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800716:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80071a:	78 98                	js     8006b4 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80071f:	eb a7                	jmp    8006c8 <vprintfmt+0x70>
  800721:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800724:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80072b:	eb 9b                	jmp    8006c8 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80072d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800731:	79 95                	jns    8006c8 <vprintfmt+0x70>
  800733:	eb 8b                	jmp    8006c0 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800735:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800736:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800739:	eb 8d                	jmp    8006c8 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80073b:	8b 45 14             	mov    0x14(%ebp),%eax
  80073e:	8d 50 04             	lea    0x4(%eax),%edx
  800741:	89 55 14             	mov    %edx,0x14(%ebp)
  800744:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800748:	8b 00                	mov    (%eax),%eax
  80074a:	89 04 24             	mov    %eax,(%esp)
  80074d:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800750:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800753:	e9 23 ff ff ff       	jmp    80067b <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8d 50 04             	lea    0x4(%eax),%edx
  80075e:	89 55 14             	mov    %edx,0x14(%ebp)
  800761:	8b 00                	mov    (%eax),%eax
  800763:	85 c0                	test   %eax,%eax
  800765:	79 02                	jns    800769 <vprintfmt+0x111>
  800767:	f7 d8                	neg    %eax
  800769:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80076b:	83 f8 09             	cmp    $0x9,%eax
  80076e:	7f 0b                	jg     80077b <vprintfmt+0x123>
  800770:	8b 04 85 00 13 80 00 	mov    0x801300(,%eax,4),%eax
  800777:	85 c0                	test   %eax,%eax
  800779:	75 23                	jne    80079e <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80077b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80077f:	c7 44 24 08 f5 10 80 	movl   $0x8010f5,0x8(%esp)
  800786:	00 
  800787:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	89 04 24             	mov    %eax,(%esp)
  800791:	e8 9a fe ff ff       	call   800630 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800796:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800799:	e9 dd fe ff ff       	jmp    80067b <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80079e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a2:	c7 44 24 08 fe 10 80 	movl   $0x8010fe,0x8(%esp)
  8007a9:	00 
  8007aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8007b1:	89 14 24             	mov    %edx,(%esp)
  8007b4:	e8 77 fe ff ff       	call   800630 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007bc:	e9 ba fe ff ff       	jmp    80067b <vprintfmt+0x23>
  8007c1:	89 f9                	mov    %edi,%ecx
  8007c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007c6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cc:	8d 50 04             	lea    0x4(%eax),%edx
  8007cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d2:	8b 30                	mov    (%eax),%esi
  8007d4:	85 f6                	test   %esi,%esi
  8007d6:	75 05                	jne    8007dd <vprintfmt+0x185>
				p = "(null)";
  8007d8:	be ee 10 80 00       	mov    $0x8010ee,%esi
			if (width > 0 && padc != '-')
  8007dd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007e1:	0f 8e 84 00 00 00    	jle    80086b <vprintfmt+0x213>
  8007e7:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007eb:	74 7e                	je     80086b <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ed:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007f1:	89 34 24             	mov    %esi,(%esp)
  8007f4:	e8 5d 02 00 00       	call   800a56 <strnlen>
  8007f9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007fc:	29 c2                	sub    %eax,%edx
  8007fe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800801:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800805:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800808:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80080b:	89 de                	mov    %ebx,%esi
  80080d:	89 d3                	mov    %edx,%ebx
  80080f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800811:	eb 0b                	jmp    80081e <vprintfmt+0x1c6>
					putch(padc, putdat);
  800813:	89 74 24 04          	mov    %esi,0x4(%esp)
  800817:	89 3c 24             	mov    %edi,(%esp)
  80081a:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80081d:	4b                   	dec    %ebx
  80081e:	85 db                	test   %ebx,%ebx
  800820:	7f f1                	jg     800813 <vprintfmt+0x1bb>
  800822:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800825:	89 f3                	mov    %esi,%ebx
  800827:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80082a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80082d:	85 c0                	test   %eax,%eax
  80082f:	79 05                	jns    800836 <vprintfmt+0x1de>
  800831:	b8 00 00 00 00       	mov    $0x0,%eax
  800836:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800839:	29 c2                	sub    %eax,%edx
  80083b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80083e:	eb 2b                	jmp    80086b <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800840:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800844:	74 18                	je     80085e <vprintfmt+0x206>
  800846:	8d 50 e0             	lea    -0x20(%eax),%edx
  800849:	83 fa 5e             	cmp    $0x5e,%edx
  80084c:	76 10                	jbe    80085e <vprintfmt+0x206>
					putch('?', putdat);
  80084e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800852:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800859:	ff 55 08             	call   *0x8(%ebp)
  80085c:	eb 0a                	jmp    800868 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80085e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800862:	89 04 24             	mov    %eax,(%esp)
  800865:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800868:	ff 4d e4             	decl   -0x1c(%ebp)
  80086b:	0f be 06             	movsbl (%esi),%eax
  80086e:	46                   	inc    %esi
  80086f:	85 c0                	test   %eax,%eax
  800871:	74 21                	je     800894 <vprintfmt+0x23c>
  800873:	85 ff                	test   %edi,%edi
  800875:	78 c9                	js     800840 <vprintfmt+0x1e8>
  800877:	4f                   	dec    %edi
  800878:	79 c6                	jns    800840 <vprintfmt+0x1e8>
  80087a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087d:	89 de                	mov    %ebx,%esi
  80087f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800882:	eb 18                	jmp    80089c <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800884:	89 74 24 04          	mov    %esi,0x4(%esp)
  800888:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80088f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800891:	4b                   	dec    %ebx
  800892:	eb 08                	jmp    80089c <vprintfmt+0x244>
  800894:	8b 7d 08             	mov    0x8(%ebp),%edi
  800897:	89 de                	mov    %ebx,%esi
  800899:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80089c:	85 db                	test   %ebx,%ebx
  80089e:	7f e4                	jg     800884 <vprintfmt+0x22c>
  8008a0:	89 7d 08             	mov    %edi,0x8(%ebp)
  8008a3:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008a8:	e9 ce fd ff ff       	jmp    80067b <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008ad:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b0:	e8 2f fd ff ff       	call   8005e4 <getint>
  8008b5:	89 c6                	mov    %eax,%esi
  8008b7:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8008b9:	85 d2                	test   %edx,%edx
  8008bb:	78 07                	js     8008c4 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008bd:	be 0a 00 00 00       	mov    $0xa,%esi
  8008c2:	eb 7e                	jmp    800942 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008cf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008d2:	89 f0                	mov    %esi,%eax
  8008d4:	89 fa                	mov    %edi,%edx
  8008d6:	f7 d8                	neg    %eax
  8008d8:	83 d2 00             	adc    $0x0,%edx
  8008db:	f7 da                	neg    %edx
			}
			base = 10;
  8008dd:	be 0a 00 00 00       	mov    $0xa,%esi
  8008e2:	eb 5e                	jmp    800942 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e7:	e8 be fc ff ff       	call   8005aa <getuint>
			base = 10;
  8008ec:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8008f1:	eb 4f                	jmp    800942 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8008f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8008f6:	e8 af fc ff ff       	call   8005aa <getuint>
			base = 8;
  8008fb:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800900:	eb 40                	jmp    800942 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  800902:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800906:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80090d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800910:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800914:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80091b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80091e:	8b 45 14             	mov    0x14(%ebp),%eax
  800921:	8d 50 04             	lea    0x4(%eax),%edx
  800924:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800927:	8b 00                	mov    (%eax),%eax
  800929:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80092e:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800933:	eb 0d                	jmp    800942 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800935:	8d 45 14             	lea    0x14(%ebp),%eax
  800938:	e8 6d fc ff ff       	call   8005aa <getuint>
			base = 16;
  80093d:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800942:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800946:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80094a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80094d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800951:	89 74 24 08          	mov    %esi,0x8(%esp)
  800955:	89 04 24             	mov    %eax,(%esp)
  800958:	89 54 24 04          	mov    %edx,0x4(%esp)
  80095c:	89 da                	mov    %ebx,%edx
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	e8 7a fb ff ff       	call   8004e0 <printnum>
			break;
  800966:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800969:	e9 0d fd ff ff       	jmp    80067b <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  80096e:	8d 45 14             	lea    0x14(%ebp),%eax
  800971:	e8 6e fc ff ff       	call   8005e4 <getint>
  800976:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80097b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  80097e:	e9 f8 fc ff ff       	jmp    80067b <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800983:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800987:	89 04 24             	mov    %eax,(%esp)
  80098a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80098d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800990:	e9 e6 fc ff ff       	jmp    80067b <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800995:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800999:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009a0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009a3:	eb 01                	jmp    8009a6 <vprintfmt+0x34e>
  8009a5:	4e                   	dec    %esi
  8009a6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009aa:	75 f9                	jne    8009a5 <vprintfmt+0x34d>
  8009ac:	e9 ca fc ff ff       	jmp    80067b <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009b1:	83 c4 4c             	add    $0x4c,%esp
  8009b4:	5b                   	pop    %ebx
  8009b5:	5e                   	pop    %esi
  8009b6:	5f                   	pop    %edi
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	83 ec 28             	sub    $0x28,%esp
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009c8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009cc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009d6:	85 c0                	test   %eax,%eax
  8009d8:	74 30                	je     800a0a <vsnprintf+0x51>
  8009da:	85 d2                	test   %edx,%edx
  8009dc:	7e 33                	jle    800a11 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009de:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ec:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f3:	c7 04 24 16 06 80 00 	movl   $0x800616,(%esp)
  8009fa:	e8 59 fc ff ff       	call   800658 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a02:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a08:	eb 0c                	jmp    800a16 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a0a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a0f:	eb 05                	jmp    800a16 <vsnprintf+0x5d>
  800a11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a16:	c9                   	leave  
  800a17:	c3                   	ret    

00800a18 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a1e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a21:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a25:	8b 45 10             	mov    0x10(%ebp),%eax
  800a28:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	89 04 24             	mov    %eax,(%esp)
  800a39:	e8 7b ff ff ff       	call   8009b9 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a3e:	c9                   	leave  
  800a3f:	c3                   	ret    

00800a40 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4b:	eb 01                	jmp    800a4e <strlen+0xe>
		n++;
  800a4d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a4e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a52:	75 f9                	jne    800a4d <strlen+0xd>
		n++;
	return n;
}
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a5c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a64:	eb 01                	jmp    800a67 <strnlen+0x11>
		n++;
  800a66:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a67:	39 d0                	cmp    %edx,%eax
  800a69:	74 06                	je     800a71 <strnlen+0x1b>
  800a6b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a6f:	75 f5                	jne    800a66 <strnlen+0x10>
		n++;
	return n;
}
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    

00800a73 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	53                   	push   %ebx
  800a77:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a82:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a85:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a88:	42                   	inc    %edx
  800a89:	84 c9                	test   %cl,%cl
  800a8b:	75 f5                	jne    800a82 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	53                   	push   %ebx
  800a94:	83 ec 08             	sub    $0x8,%esp
  800a97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a9a:	89 1c 24             	mov    %ebx,(%esp)
  800a9d:	e8 9e ff ff ff       	call   800a40 <strlen>
	strcpy(dst + len, src);
  800aa2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aa9:	01 d8                	add    %ebx,%eax
  800aab:	89 04 24             	mov    %eax,(%esp)
  800aae:	e8 c0 ff ff ff       	call   800a73 <strcpy>
	return dst;
}
  800ab3:	89 d8                	mov    %ebx,%eax
  800ab5:	83 c4 08             	add    $0x8,%esp
  800ab8:	5b                   	pop    %ebx
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ace:	eb 0c                	jmp    800adc <strncpy+0x21>
		*dst++ = *src;
  800ad0:	8a 1a                	mov    (%edx),%bl
  800ad2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ad5:	80 3a 01             	cmpb   $0x1,(%edx)
  800ad8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800adb:	41                   	inc    %ecx
  800adc:	39 f1                	cmp    %esi,%ecx
  800ade:	75 f0                	jne    800ad0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	8b 75 08             	mov    0x8(%ebp),%esi
  800aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aef:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800af2:	85 d2                	test   %edx,%edx
  800af4:	75 0a                	jne    800b00 <strlcpy+0x1c>
  800af6:	89 f0                	mov    %esi,%eax
  800af8:	eb 1a                	jmp    800b14 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800afa:	88 18                	mov    %bl,(%eax)
  800afc:	40                   	inc    %eax
  800afd:	41                   	inc    %ecx
  800afe:	eb 02                	jmp    800b02 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b00:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b02:	4a                   	dec    %edx
  800b03:	74 0a                	je     800b0f <strlcpy+0x2b>
  800b05:	8a 19                	mov    (%ecx),%bl
  800b07:	84 db                	test   %bl,%bl
  800b09:	75 ef                	jne    800afa <strlcpy+0x16>
  800b0b:	89 c2                	mov    %eax,%edx
  800b0d:	eb 02                	jmp    800b11 <strlcpy+0x2d>
  800b0f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b11:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b14:	29 f0                	sub    %esi,%eax
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b20:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b23:	eb 02                	jmp    800b27 <strcmp+0xd>
		p++, q++;
  800b25:	41                   	inc    %ecx
  800b26:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b27:	8a 01                	mov    (%ecx),%al
  800b29:	84 c0                	test   %al,%al
  800b2b:	74 04                	je     800b31 <strcmp+0x17>
  800b2d:	3a 02                	cmp    (%edx),%al
  800b2f:	74 f4                	je     800b25 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b31:	0f b6 c0             	movzbl %al,%eax
  800b34:	0f b6 12             	movzbl (%edx),%edx
  800b37:	29 d0                	sub    %edx,%eax
}
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	53                   	push   %ebx
  800b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b45:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b48:	eb 03                	jmp    800b4d <strncmp+0x12>
		n--, p++, q++;
  800b4a:	4a                   	dec    %edx
  800b4b:	40                   	inc    %eax
  800b4c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b4d:	85 d2                	test   %edx,%edx
  800b4f:	74 14                	je     800b65 <strncmp+0x2a>
  800b51:	8a 18                	mov    (%eax),%bl
  800b53:	84 db                	test   %bl,%bl
  800b55:	74 04                	je     800b5b <strncmp+0x20>
  800b57:	3a 19                	cmp    (%ecx),%bl
  800b59:	74 ef                	je     800b4a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b5b:	0f b6 00             	movzbl (%eax),%eax
  800b5e:	0f b6 11             	movzbl (%ecx),%edx
  800b61:	29 d0                	sub    %edx,%eax
  800b63:	eb 05                	jmp    800b6a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b65:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b6a:	5b                   	pop    %ebx
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	8b 45 08             	mov    0x8(%ebp),%eax
  800b73:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b76:	eb 05                	jmp    800b7d <strchr+0x10>
		if (*s == c)
  800b78:	38 ca                	cmp    %cl,%dl
  800b7a:	74 0c                	je     800b88 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b7c:	40                   	inc    %eax
  800b7d:	8a 10                	mov    (%eax),%dl
  800b7f:	84 d2                	test   %dl,%dl
  800b81:	75 f5                	jne    800b78 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b90:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b93:	eb 05                	jmp    800b9a <strfind+0x10>
		if (*s == c)
  800b95:	38 ca                	cmp    %cl,%dl
  800b97:	74 07                	je     800ba0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b99:	40                   	inc    %eax
  800b9a:	8a 10                	mov    (%eax),%dl
  800b9c:	84 d2                	test   %dl,%dl
  800b9e:	75 f5                	jne    800b95 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bb1:	85 c9                	test   %ecx,%ecx
  800bb3:	74 30                	je     800be5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bb5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bbb:	75 25                	jne    800be2 <memset+0x40>
  800bbd:	f6 c1 03             	test   $0x3,%cl
  800bc0:	75 20                	jne    800be2 <memset+0x40>
		c &= 0xFF;
  800bc2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bc5:	89 d3                	mov    %edx,%ebx
  800bc7:	c1 e3 08             	shl    $0x8,%ebx
  800bca:	89 d6                	mov    %edx,%esi
  800bcc:	c1 e6 18             	shl    $0x18,%esi
  800bcf:	89 d0                	mov    %edx,%eax
  800bd1:	c1 e0 10             	shl    $0x10,%eax
  800bd4:	09 f0                	or     %esi,%eax
  800bd6:	09 d0                	or     %edx,%eax
  800bd8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bda:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bdd:	fc                   	cld    
  800bde:	f3 ab                	rep stos %eax,%es:(%edi)
  800be0:	eb 03                	jmp    800be5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800be2:	fc                   	cld    
  800be3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800be5:	89 f8                	mov    %edi,%eax
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bfa:	39 c6                	cmp    %eax,%esi
  800bfc:	73 34                	jae    800c32 <memmove+0x46>
  800bfe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c01:	39 d0                	cmp    %edx,%eax
  800c03:	73 2d                	jae    800c32 <memmove+0x46>
		s += n;
		d += n;
  800c05:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c08:	f6 c2 03             	test   $0x3,%dl
  800c0b:	75 1b                	jne    800c28 <memmove+0x3c>
  800c0d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c13:	75 13                	jne    800c28 <memmove+0x3c>
  800c15:	f6 c1 03             	test   $0x3,%cl
  800c18:	75 0e                	jne    800c28 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c1a:	83 ef 04             	sub    $0x4,%edi
  800c1d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c20:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c23:	fd                   	std    
  800c24:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c26:	eb 07                	jmp    800c2f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c28:	4f                   	dec    %edi
  800c29:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c2c:	fd                   	std    
  800c2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c2f:	fc                   	cld    
  800c30:	eb 20                	jmp    800c52 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c32:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c38:	75 13                	jne    800c4d <memmove+0x61>
  800c3a:	a8 03                	test   $0x3,%al
  800c3c:	75 0f                	jne    800c4d <memmove+0x61>
  800c3e:	f6 c1 03             	test   $0x3,%cl
  800c41:	75 0a                	jne    800c4d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c43:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c46:	89 c7                	mov    %eax,%edi
  800c48:	fc                   	cld    
  800c49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4b:	eb 05                	jmp    800c52 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c4d:	89 c7                	mov    %eax,%edi
  800c4f:	fc                   	cld    
  800c50:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c5f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c66:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6d:	89 04 24             	mov    %eax,(%esp)
  800c70:	e8 77 ff ff ff       	call   800bec <memmove>
}
  800c75:	c9                   	leave  
  800c76:	c3                   	ret    

00800c77 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	57                   	push   %edi
  800c7b:	56                   	push   %esi
  800c7c:	53                   	push   %ebx
  800c7d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c86:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8b:	eb 16                	jmp    800ca3 <memcmp+0x2c>
		if (*s1 != *s2)
  800c8d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c90:	42                   	inc    %edx
  800c91:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c95:	38 c8                	cmp    %cl,%al
  800c97:	74 0a                	je     800ca3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c99:	0f b6 c0             	movzbl %al,%eax
  800c9c:	0f b6 c9             	movzbl %cl,%ecx
  800c9f:	29 c8                	sub    %ecx,%eax
  800ca1:	eb 09                	jmp    800cac <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca3:	39 da                	cmp    %ebx,%edx
  800ca5:	75 e6                	jne    800c8d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ca7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cba:	89 c2                	mov    %eax,%edx
  800cbc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cbf:	eb 05                	jmp    800cc6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cc1:	38 08                	cmp    %cl,(%eax)
  800cc3:	74 05                	je     800cca <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cc5:	40                   	inc    %eax
  800cc6:	39 d0                	cmp    %edx,%eax
  800cc8:	72 f7                	jb     800cc1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd8:	eb 01                	jmp    800cdb <strtol+0xf>
		s++;
  800cda:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cdb:	8a 02                	mov    (%edx),%al
  800cdd:	3c 20                	cmp    $0x20,%al
  800cdf:	74 f9                	je     800cda <strtol+0xe>
  800ce1:	3c 09                	cmp    $0x9,%al
  800ce3:	74 f5                	je     800cda <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ce5:	3c 2b                	cmp    $0x2b,%al
  800ce7:	75 08                	jne    800cf1 <strtol+0x25>
		s++;
  800ce9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cea:	bf 00 00 00 00       	mov    $0x0,%edi
  800cef:	eb 13                	jmp    800d04 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cf1:	3c 2d                	cmp    $0x2d,%al
  800cf3:	75 0a                	jne    800cff <strtol+0x33>
		s++, neg = 1;
  800cf5:	8d 52 01             	lea    0x1(%edx),%edx
  800cf8:	bf 01 00 00 00       	mov    $0x1,%edi
  800cfd:	eb 05                	jmp    800d04 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cff:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d04:	85 db                	test   %ebx,%ebx
  800d06:	74 05                	je     800d0d <strtol+0x41>
  800d08:	83 fb 10             	cmp    $0x10,%ebx
  800d0b:	75 28                	jne    800d35 <strtol+0x69>
  800d0d:	8a 02                	mov    (%edx),%al
  800d0f:	3c 30                	cmp    $0x30,%al
  800d11:	75 10                	jne    800d23 <strtol+0x57>
  800d13:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d17:	75 0a                	jne    800d23 <strtol+0x57>
		s += 2, base = 16;
  800d19:	83 c2 02             	add    $0x2,%edx
  800d1c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d21:	eb 12                	jmp    800d35 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d23:	85 db                	test   %ebx,%ebx
  800d25:	75 0e                	jne    800d35 <strtol+0x69>
  800d27:	3c 30                	cmp    $0x30,%al
  800d29:	75 05                	jne    800d30 <strtol+0x64>
		s++, base = 8;
  800d2b:	42                   	inc    %edx
  800d2c:	b3 08                	mov    $0x8,%bl
  800d2e:	eb 05                	jmp    800d35 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d30:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d35:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d3c:	8a 0a                	mov    (%edx),%cl
  800d3e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d41:	80 fb 09             	cmp    $0x9,%bl
  800d44:	77 08                	ja     800d4e <strtol+0x82>
			dig = *s - '0';
  800d46:	0f be c9             	movsbl %cl,%ecx
  800d49:	83 e9 30             	sub    $0x30,%ecx
  800d4c:	eb 1e                	jmp    800d6c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d4e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d51:	80 fb 19             	cmp    $0x19,%bl
  800d54:	77 08                	ja     800d5e <strtol+0x92>
			dig = *s - 'a' + 10;
  800d56:	0f be c9             	movsbl %cl,%ecx
  800d59:	83 e9 57             	sub    $0x57,%ecx
  800d5c:	eb 0e                	jmp    800d6c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d5e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d61:	80 fb 19             	cmp    $0x19,%bl
  800d64:	77 12                	ja     800d78 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d66:	0f be c9             	movsbl %cl,%ecx
  800d69:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d6c:	39 f1                	cmp    %esi,%ecx
  800d6e:	7d 0c                	jge    800d7c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d70:	42                   	inc    %edx
  800d71:	0f af c6             	imul   %esi,%eax
  800d74:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d76:	eb c4                	jmp    800d3c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d78:	89 c1                	mov    %eax,%ecx
  800d7a:	eb 02                	jmp    800d7e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d7c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d7e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d82:	74 05                	je     800d89 <strtol+0xbd>
		*endptr = (char *) s;
  800d84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d87:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d89:	85 ff                	test   %edi,%edi
  800d8b:	74 04                	je     800d91 <strtol+0xc5>
  800d8d:	89 c8                	mov    %ecx,%eax
  800d8f:	f7 d8                	neg    %eax
}
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    
	...

00800d98 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d9e:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800da5:	75 40                	jne    800de7 <set_pgfault_handler+0x4f>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
  800da7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800dae:	00 
  800daf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800db6:	ee 
  800db7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800dbe:	e8 ca f3 ff ff       	call   80018d <sys_page_alloc>
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	79 20                	jns    800de7 <set_pgfault_handler+0x4f>
            panic("set_pgfault_handler: sys_page_alloc: %e", r);
  800dc7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dcb:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800dd2:	00 
  800dd3:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800dda:	00 
  800ddb:	c7 04 24 84 13 80 00 	movl   $0x801384,(%esp)
  800de2:	e8 e5 f5 ff ff       	call   8003cc <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800de7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dea:	a3 0c 20 80 00       	mov    %eax,0x80200c
    if ((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0 )
  800def:	c7 44 24 04 a4 03 80 	movl   $0x8003a4,0x4(%esp)
  800df6:	00 
  800df7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800dfe:	e8 d7 f4 ff ff       	call   8002da <sys_env_set_pgfault_upcall>
  800e03:	85 c0                	test   %eax,%eax
  800e05:	79 20                	jns    800e27 <set_pgfault_handler+0x8f>
        panic("set_pgfault_handler: sys_env_set_pgfault_upcall: %e", r);
  800e07:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e0b:	c7 44 24 08 50 13 80 	movl   $0x801350,0x8(%esp)
  800e12:	00 
  800e13:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800e1a:	00 
  800e1b:	c7 04 24 84 13 80 00 	movl   $0x801384,(%esp)
  800e22:	e8 a5 f5 ff ff       	call   8003cc <_panic>
}
  800e27:	c9                   	leave  
  800e28:	c3                   	ret    
  800e29:	00 00                	add    %al,(%eax)
	...

00800e2c <__udivdi3>:
  800e2c:	55                   	push   %ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	83 ec 10             	sub    $0x10,%esp
  800e32:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e36:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800e3a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e3e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800e42:	89 cd                	mov    %ecx,%ebp
  800e44:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	75 2c                	jne    800e78 <__udivdi3+0x4c>
  800e4c:	39 f9                	cmp    %edi,%ecx
  800e4e:	77 68                	ja     800eb8 <__udivdi3+0x8c>
  800e50:	85 c9                	test   %ecx,%ecx
  800e52:	75 0b                	jne    800e5f <__udivdi3+0x33>
  800e54:	b8 01 00 00 00       	mov    $0x1,%eax
  800e59:	31 d2                	xor    %edx,%edx
  800e5b:	f7 f1                	div    %ecx
  800e5d:	89 c1                	mov    %eax,%ecx
  800e5f:	31 d2                	xor    %edx,%edx
  800e61:	89 f8                	mov    %edi,%eax
  800e63:	f7 f1                	div    %ecx
  800e65:	89 c7                	mov    %eax,%edi
  800e67:	89 f0                	mov    %esi,%eax
  800e69:	f7 f1                	div    %ecx
  800e6b:	89 c6                	mov    %eax,%esi
  800e6d:	89 f0                	mov    %esi,%eax
  800e6f:	89 fa                	mov    %edi,%edx
  800e71:	83 c4 10             	add    $0x10,%esp
  800e74:	5e                   	pop    %esi
  800e75:	5f                   	pop    %edi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    
  800e78:	39 f8                	cmp    %edi,%eax
  800e7a:	77 2c                	ja     800ea8 <__udivdi3+0x7c>
  800e7c:	0f bd f0             	bsr    %eax,%esi
  800e7f:	83 f6 1f             	xor    $0x1f,%esi
  800e82:	75 4c                	jne    800ed0 <__udivdi3+0xa4>
  800e84:	39 f8                	cmp    %edi,%eax
  800e86:	bf 00 00 00 00       	mov    $0x0,%edi
  800e8b:	72 0a                	jb     800e97 <__udivdi3+0x6b>
  800e8d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e91:	0f 87 ad 00 00 00    	ja     800f44 <__udivdi3+0x118>
  800e97:	be 01 00 00 00       	mov    $0x1,%esi
  800e9c:	89 f0                	mov    %esi,%eax
  800e9e:	89 fa                	mov    %edi,%edx
  800ea0:	83 c4 10             	add    $0x10,%esp
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    
  800ea7:	90                   	nop
  800ea8:	31 ff                	xor    %edi,%edi
  800eaa:	31 f6                	xor    %esi,%esi
  800eac:	89 f0                	mov    %esi,%eax
  800eae:	89 fa                	mov    %edi,%edx
  800eb0:	83 c4 10             	add    $0x10,%esp
  800eb3:	5e                   	pop    %esi
  800eb4:	5f                   	pop    %edi
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    
  800eb7:	90                   	nop
  800eb8:	89 fa                	mov    %edi,%edx
  800eba:	89 f0                	mov    %esi,%eax
  800ebc:	f7 f1                	div    %ecx
  800ebe:	89 c6                	mov    %eax,%esi
  800ec0:	31 ff                	xor    %edi,%edi
  800ec2:	89 f0                	mov    %esi,%eax
  800ec4:	89 fa                	mov    %edi,%edx
  800ec6:	83 c4 10             	add    $0x10,%esp
  800ec9:	5e                   	pop    %esi
  800eca:	5f                   	pop    %edi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    
  800ecd:	8d 76 00             	lea    0x0(%esi),%esi
  800ed0:	89 f1                	mov    %esi,%ecx
  800ed2:	d3 e0                	shl    %cl,%eax
  800ed4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ed8:	b8 20 00 00 00       	mov    $0x20,%eax
  800edd:	29 f0                	sub    %esi,%eax
  800edf:	89 ea                	mov    %ebp,%edx
  800ee1:	88 c1                	mov    %al,%cl
  800ee3:	d3 ea                	shr    %cl,%edx
  800ee5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800ee9:	09 ca                	or     %ecx,%edx
  800eeb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800eef:	89 f1                	mov    %esi,%ecx
  800ef1:	d3 e5                	shl    %cl,%ebp
  800ef3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800ef7:	89 fd                	mov    %edi,%ebp
  800ef9:	88 c1                	mov    %al,%cl
  800efb:	d3 ed                	shr    %cl,%ebp
  800efd:	89 fa                	mov    %edi,%edx
  800eff:	89 f1                	mov    %esi,%ecx
  800f01:	d3 e2                	shl    %cl,%edx
  800f03:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f07:	88 c1                	mov    %al,%cl
  800f09:	d3 ef                	shr    %cl,%edi
  800f0b:	09 d7                	or     %edx,%edi
  800f0d:	89 f8                	mov    %edi,%eax
  800f0f:	89 ea                	mov    %ebp,%edx
  800f11:	f7 74 24 08          	divl   0x8(%esp)
  800f15:	89 d1                	mov    %edx,%ecx
  800f17:	89 c7                	mov    %eax,%edi
  800f19:	f7 64 24 0c          	mull   0xc(%esp)
  800f1d:	39 d1                	cmp    %edx,%ecx
  800f1f:	72 17                	jb     800f38 <__udivdi3+0x10c>
  800f21:	74 09                	je     800f2c <__udivdi3+0x100>
  800f23:	89 fe                	mov    %edi,%esi
  800f25:	31 ff                	xor    %edi,%edi
  800f27:	e9 41 ff ff ff       	jmp    800e6d <__udivdi3+0x41>
  800f2c:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f30:	89 f1                	mov    %esi,%ecx
  800f32:	d3 e2                	shl    %cl,%edx
  800f34:	39 c2                	cmp    %eax,%edx
  800f36:	73 eb                	jae    800f23 <__udivdi3+0xf7>
  800f38:	8d 77 ff             	lea    -0x1(%edi),%esi
  800f3b:	31 ff                	xor    %edi,%edi
  800f3d:	e9 2b ff ff ff       	jmp    800e6d <__udivdi3+0x41>
  800f42:	66 90                	xchg   %ax,%ax
  800f44:	31 f6                	xor    %esi,%esi
  800f46:	e9 22 ff ff ff       	jmp    800e6d <__udivdi3+0x41>
	...

00800f4c <__umoddi3>:
  800f4c:	55                   	push   %ebp
  800f4d:	57                   	push   %edi
  800f4e:	56                   	push   %esi
  800f4f:	83 ec 20             	sub    $0x20,%esp
  800f52:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f56:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800f5a:	89 44 24 14          	mov    %eax,0x14(%esp)
  800f5e:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f62:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f66:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f6a:	89 c7                	mov    %eax,%edi
  800f6c:	89 f2                	mov    %esi,%edx
  800f6e:	85 ed                	test   %ebp,%ebp
  800f70:	75 16                	jne    800f88 <__umoddi3+0x3c>
  800f72:	39 f1                	cmp    %esi,%ecx
  800f74:	0f 86 a6 00 00 00    	jbe    801020 <__umoddi3+0xd4>
  800f7a:	f7 f1                	div    %ecx
  800f7c:	89 d0                	mov    %edx,%eax
  800f7e:	31 d2                	xor    %edx,%edx
  800f80:	83 c4 20             	add    $0x20,%esp
  800f83:	5e                   	pop    %esi
  800f84:	5f                   	pop    %edi
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    
  800f87:	90                   	nop
  800f88:	39 f5                	cmp    %esi,%ebp
  800f8a:	0f 87 ac 00 00 00    	ja     80103c <__umoddi3+0xf0>
  800f90:	0f bd c5             	bsr    %ebp,%eax
  800f93:	83 f0 1f             	xor    $0x1f,%eax
  800f96:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f9a:	0f 84 a8 00 00 00    	je     801048 <__umoddi3+0xfc>
  800fa0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fa4:	d3 e5                	shl    %cl,%ebp
  800fa6:	bf 20 00 00 00       	mov    $0x20,%edi
  800fab:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800faf:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fb3:	89 f9                	mov    %edi,%ecx
  800fb5:	d3 e8                	shr    %cl,%eax
  800fb7:	09 e8                	or     %ebp,%eax
  800fb9:	89 44 24 18          	mov    %eax,0x18(%esp)
  800fbd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fc1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fc5:	d3 e0                	shl    %cl,%eax
  800fc7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fcb:	89 f2                	mov    %esi,%edx
  800fcd:	d3 e2                	shl    %cl,%edx
  800fcf:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fd3:	d3 e0                	shl    %cl,%eax
  800fd5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800fd9:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fdd:	89 f9                	mov    %edi,%ecx
  800fdf:	d3 e8                	shr    %cl,%eax
  800fe1:	09 d0                	or     %edx,%eax
  800fe3:	d3 ee                	shr    %cl,%esi
  800fe5:	89 f2                	mov    %esi,%edx
  800fe7:	f7 74 24 18          	divl   0x18(%esp)
  800feb:	89 d6                	mov    %edx,%esi
  800fed:	f7 64 24 0c          	mull   0xc(%esp)
  800ff1:	89 c5                	mov    %eax,%ebp
  800ff3:	89 d1                	mov    %edx,%ecx
  800ff5:	39 d6                	cmp    %edx,%esi
  800ff7:	72 67                	jb     801060 <__umoddi3+0x114>
  800ff9:	74 75                	je     801070 <__umoddi3+0x124>
  800ffb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800fff:	29 e8                	sub    %ebp,%eax
  801001:	19 ce                	sbb    %ecx,%esi
  801003:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801007:	d3 e8                	shr    %cl,%eax
  801009:	89 f2                	mov    %esi,%edx
  80100b:	89 f9                	mov    %edi,%ecx
  80100d:	d3 e2                	shl    %cl,%edx
  80100f:	09 d0                	or     %edx,%eax
  801011:	89 f2                	mov    %esi,%edx
  801013:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801017:	d3 ea                	shr    %cl,%edx
  801019:	83 c4 20             	add    $0x20,%esp
  80101c:	5e                   	pop    %esi
  80101d:	5f                   	pop    %edi
  80101e:	5d                   	pop    %ebp
  80101f:	c3                   	ret    
  801020:	85 c9                	test   %ecx,%ecx
  801022:	75 0b                	jne    80102f <__umoddi3+0xe3>
  801024:	b8 01 00 00 00       	mov    $0x1,%eax
  801029:	31 d2                	xor    %edx,%edx
  80102b:	f7 f1                	div    %ecx
  80102d:	89 c1                	mov    %eax,%ecx
  80102f:	89 f0                	mov    %esi,%eax
  801031:	31 d2                	xor    %edx,%edx
  801033:	f7 f1                	div    %ecx
  801035:	89 f8                	mov    %edi,%eax
  801037:	e9 3e ff ff ff       	jmp    800f7a <__umoddi3+0x2e>
  80103c:	89 f2                	mov    %esi,%edx
  80103e:	83 c4 20             	add    $0x20,%esp
  801041:	5e                   	pop    %esi
  801042:	5f                   	pop    %edi
  801043:	5d                   	pop    %ebp
  801044:	c3                   	ret    
  801045:	8d 76 00             	lea    0x0(%esi),%esi
  801048:	39 f5                	cmp    %esi,%ebp
  80104a:	72 04                	jb     801050 <__umoddi3+0x104>
  80104c:	39 f9                	cmp    %edi,%ecx
  80104e:	77 06                	ja     801056 <__umoddi3+0x10a>
  801050:	89 f2                	mov    %esi,%edx
  801052:	29 cf                	sub    %ecx,%edi
  801054:	19 ea                	sbb    %ebp,%edx
  801056:	89 f8                	mov    %edi,%eax
  801058:	83 c4 20             	add    $0x20,%esp
  80105b:	5e                   	pop    %esi
  80105c:	5f                   	pop    %edi
  80105d:	5d                   	pop    %ebp
  80105e:	c3                   	ret    
  80105f:	90                   	nop
  801060:	89 d1                	mov    %edx,%ecx
  801062:	89 c5                	mov    %eax,%ebp
  801064:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801068:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80106c:	eb 8d                	jmp    800ffb <__umoddi3+0xaf>
  80106e:	66 90                	xchg   %ax,%ax
  801070:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801074:	72 ea                	jb     801060 <__umoddi3+0x114>
  801076:	89 f1                	mov    %esi,%ecx
  801078:	eb 81                	jmp    800ffb <__umoddi3+0xaf>
