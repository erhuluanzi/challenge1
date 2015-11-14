
obj/user/idle:     file format elf32-i386


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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003a:	c7 05 00 20 80 00 c0 	movl   $0x800fc0,0x802000
  800041:	0f 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 15 01 00 00       	call   80015e <sys_yield>
  800049:	eb f9                	jmp    800044 <umain+0x10>
	...

0080004c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	56                   	push   %esi
  800050:	53                   	push   %ebx
  800051:	83 ec 10             	sub    $0x10,%esp
  800054:	8b 75 08             	mov    0x8(%ebp),%esi
  800057:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80005a:	e8 e0 00 00 00       	call   80013f <sys_getenvid>
  80005f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800064:	8d 14 80             	lea    (%eax,%eax,4),%edx
  800067:	8d 14 90             	lea    (%eax,%edx,4),%edx
  80006a:	8d 04 50             	lea    (%eax,%edx,2),%eax
  80006d:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  800074:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	85 f6                	test   %esi,%esi
  80007b:	7e 07                	jle    800084 <libmain+0x38>
		binaryname = argv[0];
  80007d:	8b 03                	mov    (%ebx),%eax
  80007f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800084:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800088:	89 34 24             	mov    %esi,(%esp)
  80008b:	e8 a4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800090:	e8 07 00 00 00       	call   80009c <exit>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	5b                   	pop    %ebx
  800099:	5e                   	pop    %esi
  80009a:	5d                   	pop    %ebp
  80009b:	c3                   	ret    

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a9:	e8 3f 00 00 00       	call   8000ed <sys_env_destroy>
}
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000be:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c1:	89 c3                	mov    %eax,%ebx
  8000c3:	89 c7                	mov    %eax,%edi
  8000c5:	89 c6                	mov    %eax,%esi
  8000c7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    

008000ce <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	57                   	push   %edi
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000de:	89 d1                	mov    %edx,%ecx
  8000e0:	89 d3                	mov    %edx,%ebx
  8000e2:	89 d7                	mov    %edx,%edi
  8000e4:	89 d6                	mov    %edx,%esi
  8000e6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e8:	5b                   	pop    %ebx
  8000e9:	5e                   	pop    %esi
  8000ea:	5f                   	pop    %edi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	57                   	push   %edi
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fb:	b8 03 00 00 00       	mov    $0x3,%eax
  800100:	8b 55 08             	mov    0x8(%ebp),%edx
  800103:	89 cb                	mov    %ecx,%ebx
  800105:	89 cf                	mov    %ecx,%edi
  800107:	89 ce                	mov    %ecx,%esi
  800109:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010b:	85 c0                	test   %eax,%eax
  80010d:	7e 28                	jle    800137 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800113:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011a:	00 
  80011b:	c7 44 24 08 cf 0f 80 	movl   $0x800fcf,0x8(%esp)
  800122:	00 
  800123:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012a:	00 
  80012b:	c7 04 24 ec 0f 80 00 	movl   $0x800fec,(%esp)
  800132:	e8 5d 02 00 00       	call   800394 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800137:	83 c4 2c             	add    $0x2c,%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 02 00 00 00       	mov    $0x2,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_yield>:

void
sys_yield(void)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800164:	ba 00 00 00 00       	mov    $0x0,%edx
  800169:	b8 0a 00 00 00       	mov    $0xa,%eax
  80016e:	89 d1                	mov    %edx,%ecx
  800170:	89 d3                	mov    %edx,%ebx
  800172:	89 d7                	mov    %edx,%edi
  800174:	89 d6                	mov    %edx,%esi
  800176:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800178:	5b                   	pop    %ebx
  800179:	5e                   	pop    %esi
  80017a:	5f                   	pop    %edi
  80017b:	5d                   	pop    %ebp
  80017c:	c3                   	ret    

0080017d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	57                   	push   %edi
  800181:	56                   	push   %esi
  800182:	53                   	push   %ebx
  800183:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800186:	be 00 00 00 00       	mov    $0x0,%esi
  80018b:	b8 04 00 00 00       	mov    $0x4,%eax
  800190:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800193:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800196:	8b 55 08             	mov    0x8(%ebp),%edx
  800199:	89 f7                	mov    %esi,%edi
  80019b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80019d:	85 c0                	test   %eax,%eax
  80019f:	7e 28                	jle    8001c9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001ac:	00 
  8001ad:	c7 44 24 08 cf 0f 80 	movl   $0x800fcf,0x8(%esp)
  8001b4:	00 
  8001b5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001bc:	00 
  8001bd:	c7 04 24 ec 0f 80 00 	movl   $0x800fec,(%esp)
  8001c4:	e8 cb 01 00 00       	call   800394 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c9:	83 c4 2c             	add    $0x2c,%esp
  8001cc:	5b                   	pop    %ebx
  8001cd:	5e                   	pop    %esi
  8001ce:	5f                   	pop    %edi
  8001cf:	5d                   	pop    %ebp
  8001d0:	c3                   	ret    

008001d1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	57                   	push   %edi
  8001d5:	56                   	push   %esi
  8001d6:	53                   	push   %ebx
  8001d7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001da:	b8 05 00 00 00       	mov    $0x5,%eax
  8001df:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f0:	85 c0                	test   %eax,%eax
  8001f2:	7e 28                	jle    80021c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001ff:	00 
  800200:	c7 44 24 08 cf 0f 80 	movl   $0x800fcf,0x8(%esp)
  800207:	00 
  800208:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80020f:	00 
  800210:	c7 04 24 ec 0f 80 00 	movl   $0x800fec,(%esp)
  800217:	e8 78 01 00 00       	call   800394 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80021c:	83 c4 2c             	add    $0x2c,%esp
  80021f:	5b                   	pop    %ebx
  800220:	5e                   	pop    %esi
  800221:	5f                   	pop    %edi
  800222:	5d                   	pop    %ebp
  800223:	c3                   	ret    

00800224 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	57                   	push   %edi
  800228:	56                   	push   %esi
  800229:	53                   	push   %ebx
  80022a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800232:	b8 06 00 00 00       	mov    $0x6,%eax
  800237:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023a:	8b 55 08             	mov    0x8(%ebp),%edx
  80023d:	89 df                	mov    %ebx,%edi
  80023f:	89 de                	mov    %ebx,%esi
  800241:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800243:	85 c0                	test   %eax,%eax
  800245:	7e 28                	jle    80026f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800247:	89 44 24 10          	mov    %eax,0x10(%esp)
  80024b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800252:	00 
  800253:	c7 44 24 08 cf 0f 80 	movl   $0x800fcf,0x8(%esp)
  80025a:	00 
  80025b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800262:	00 
  800263:	c7 04 24 ec 0f 80 00 	movl   $0x800fec,(%esp)
  80026a:	e8 25 01 00 00       	call   800394 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80026f:	83 c4 2c             	add    $0x2c,%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	57                   	push   %edi
  80027b:	56                   	push   %esi
  80027c:	53                   	push   %ebx
  80027d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800280:	bb 00 00 00 00       	mov    $0x0,%ebx
  800285:	b8 08 00 00 00       	mov    $0x8,%eax
  80028a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028d:	8b 55 08             	mov    0x8(%ebp),%edx
  800290:	89 df                	mov    %ebx,%edi
  800292:	89 de                	mov    %ebx,%esi
  800294:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800296:	85 c0                	test   %eax,%eax
  800298:	7e 28                	jle    8002c2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80029e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a5:	00 
  8002a6:	c7 44 24 08 cf 0f 80 	movl   $0x800fcf,0x8(%esp)
  8002ad:	00 
  8002ae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b5:	00 
  8002b6:	c7 04 24 ec 0f 80 00 	movl   $0x800fec,(%esp)
  8002bd:	e8 d2 00 00 00       	call   800394 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c2:	83 c4 2c             	add    $0x2c,%esp
  8002c5:	5b                   	pop    %ebx
  8002c6:	5e                   	pop    %esi
  8002c7:	5f                   	pop    %edi
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	57                   	push   %edi
  8002ce:	56                   	push   %esi
  8002cf:	53                   	push   %ebx
  8002d0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d8:	b8 09 00 00 00       	mov    $0x9,%eax
  8002dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e3:	89 df                	mov    %ebx,%edi
  8002e5:	89 de                	mov    %ebx,%esi
  8002e7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e9:	85 c0                	test   %eax,%eax
  8002eb:	7e 28                	jle    800315 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f8:	00 
  8002f9:	c7 44 24 08 cf 0f 80 	movl   $0x800fcf,0x8(%esp)
  800300:	00 
  800301:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800308:	00 
  800309:	c7 04 24 ec 0f 80 00 	movl   $0x800fec,(%esp)
  800310:	e8 7f 00 00 00       	call   800394 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800315:	83 c4 2c             	add    $0x2c,%esp
  800318:	5b                   	pop    %ebx
  800319:	5e                   	pop    %esi
  80031a:	5f                   	pop    %edi
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	57                   	push   %edi
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800323:	be 00 00 00 00       	mov    $0x0,%esi
  800328:	b8 0b 00 00 00       	mov    $0xb,%eax
  80032d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800330:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800333:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800336:	8b 55 08             	mov    0x8(%ebp),%edx
  800339:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80033b:	5b                   	pop    %ebx
  80033c:	5e                   	pop    %esi
  80033d:	5f                   	pop    %edi
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    

00800340 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	57                   	push   %edi
  800344:	56                   	push   %esi
  800345:	53                   	push   %ebx
  800346:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800349:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800353:	8b 55 08             	mov    0x8(%ebp),%edx
  800356:	89 cb                	mov    %ecx,%ebx
  800358:	89 cf                	mov    %ecx,%edi
  80035a:	89 ce                	mov    %ecx,%esi
  80035c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80035e:	85 c0                	test   %eax,%eax
  800360:	7e 28                	jle    80038a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800362:	89 44 24 10          	mov    %eax,0x10(%esp)
  800366:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80036d:	00 
  80036e:	c7 44 24 08 cf 0f 80 	movl   $0x800fcf,0x8(%esp)
  800375:	00 
  800376:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80037d:	00 
  80037e:	c7 04 24 ec 0f 80 00 	movl   $0x800fec,(%esp)
  800385:	e8 0a 00 00 00       	call   800394 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80038a:	83 c4 2c             	add    $0x2c,%esp
  80038d:	5b                   	pop    %ebx
  80038e:	5e                   	pop    %esi
  80038f:	5f                   	pop    %edi
  800390:	5d                   	pop    %ebp
  800391:	c3                   	ret    
	...

00800394 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	56                   	push   %esi
  800398:	53                   	push   %ebx
  800399:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80039c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80039f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8003a5:	e8 95 fd ff ff       	call   80013f <sys_getenvid>
  8003aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ad:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c0:	c7 04 24 fc 0f 80 00 	movl   $0x800ffc,(%esp)
  8003c7:	e8 c0 00 00 00       	call   80048c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d3:	89 04 24             	mov    %eax,(%esp)
  8003d6:	e8 50 00 00 00       	call   80042b <vcprintf>
	cprintf("\n");
  8003db:	c7 04 24 20 10 80 00 	movl   $0x801020,(%esp)
  8003e2:	e8 a5 00 00 00       	call   80048c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003e7:	cc                   	int3   
  8003e8:	eb fd                	jmp    8003e7 <_panic+0x53>
	...

008003ec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	53                   	push   %ebx
  8003f0:	83 ec 14             	sub    $0x14,%esp
  8003f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003f6:	8b 03                	mov    (%ebx),%eax
  8003f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003fb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003ff:	40                   	inc    %eax
  800400:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800402:	3d ff 00 00 00       	cmp    $0xff,%eax
  800407:	75 19                	jne    800422 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800409:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800410:	00 
  800411:	8d 43 08             	lea    0x8(%ebx),%eax
  800414:	89 04 24             	mov    %eax,(%esp)
  800417:	e8 94 fc ff ff       	call   8000b0 <sys_cputs>
		b->idx = 0;
  80041c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800422:	ff 43 04             	incl   0x4(%ebx)
}
  800425:	83 c4 14             	add    $0x14,%esp
  800428:	5b                   	pop    %ebx
  800429:	5d                   	pop    %ebp
  80042a:	c3                   	ret    

0080042b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80042b:	55                   	push   %ebp
  80042c:	89 e5                	mov    %esp,%ebp
  80042e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800434:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80043b:	00 00 00 
	b.cnt = 0;
  80043e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800445:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800448:	8b 45 0c             	mov    0xc(%ebp),%eax
  80044b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80044f:	8b 45 08             	mov    0x8(%ebp),%eax
  800452:	89 44 24 08          	mov    %eax,0x8(%esp)
  800456:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80045c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800460:	c7 04 24 ec 03 80 00 	movl   $0x8003ec,(%esp)
  800467:	e8 b4 01 00 00       	call   800620 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80046c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800472:	89 44 24 04          	mov    %eax,0x4(%esp)
  800476:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80047c:	89 04 24             	mov    %eax,(%esp)
  80047f:	e8 2c fc ff ff       	call   8000b0 <sys_cputs>

	return b.cnt;
}
  800484:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80048a:	c9                   	leave  
  80048b:	c3                   	ret    

0080048c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80048c:	55                   	push   %ebp
  80048d:	89 e5                	mov    %esp,%ebp
  80048f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800492:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800495:	89 44 24 04          	mov    %eax,0x4(%esp)
  800499:	8b 45 08             	mov    0x8(%ebp),%eax
  80049c:	89 04 24             	mov    %eax,(%esp)
  80049f:	e8 87 ff ff ff       	call   80042b <vcprintf>
	va_end(ap);

	return cnt;
}
  8004a4:	c9                   	leave  
  8004a5:	c3                   	ret    
	...

008004a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	57                   	push   %edi
  8004ac:	56                   	push   %esi
  8004ad:	53                   	push   %ebx
  8004ae:	83 ec 3c             	sub    $0x3c,%esp
  8004b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b4:	89 d7                	mov    %edx,%edi
  8004b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004c5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	75 08                	jne    8004d4 <printnum+0x2c>
  8004cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004cf:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004d2:	77 57                	ja     80052b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004d4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004d8:	4b                   	dec    %ebx
  8004d9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004e8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004ec:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004f3:	00 
  8004f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004f7:	89 04 24             	mov    %eax,(%esp)
  8004fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800501:	e8 5a 08 00 00       	call   800d60 <__udivdi3>
  800506:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80050a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80050e:	89 04 24             	mov    %eax,(%esp)
  800511:	89 54 24 04          	mov    %edx,0x4(%esp)
  800515:	89 fa                	mov    %edi,%edx
  800517:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051a:	e8 89 ff ff ff       	call   8004a8 <printnum>
  80051f:	eb 0f                	jmp    800530 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800521:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800525:	89 34 24             	mov    %esi,(%esp)
  800528:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80052b:	4b                   	dec    %ebx
  80052c:	85 db                	test   %ebx,%ebx
  80052e:	7f f1                	jg     800521 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800530:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800534:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800538:	8b 45 10             	mov    0x10(%ebp),%eax
  80053b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80053f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800546:	00 
  800547:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80054a:	89 04 24             	mov    %eax,(%esp)
  80054d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800550:	89 44 24 04          	mov    %eax,0x4(%esp)
  800554:	e8 27 09 00 00       	call   800e80 <__umoddi3>
  800559:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80055d:	0f be 80 22 10 80 00 	movsbl 0x801022(%eax),%eax
  800564:	89 04 24             	mov    %eax,(%esp)
  800567:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80056a:	83 c4 3c             	add    $0x3c,%esp
  80056d:	5b                   	pop    %ebx
  80056e:	5e                   	pop    %esi
  80056f:	5f                   	pop    %edi
  800570:	5d                   	pop    %ebp
  800571:	c3                   	ret    

00800572 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800572:	55                   	push   %ebp
  800573:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800575:	83 fa 01             	cmp    $0x1,%edx
  800578:	7e 0e                	jle    800588 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80057a:	8b 10                	mov    (%eax),%edx
  80057c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80057f:	89 08                	mov    %ecx,(%eax)
  800581:	8b 02                	mov    (%edx),%eax
  800583:	8b 52 04             	mov    0x4(%edx),%edx
  800586:	eb 22                	jmp    8005aa <getuint+0x38>
	else if (lflag)
  800588:	85 d2                	test   %edx,%edx
  80058a:	74 10                	je     80059c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80058c:	8b 10                	mov    (%eax),%edx
  80058e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800591:	89 08                	mov    %ecx,(%eax)
  800593:	8b 02                	mov    (%edx),%eax
  800595:	ba 00 00 00 00       	mov    $0x0,%edx
  80059a:	eb 0e                	jmp    8005aa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80059c:	8b 10                	mov    (%eax),%edx
  80059e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005a1:	89 08                	mov    %ecx,(%eax)
  8005a3:	8b 02                	mov    (%edx),%eax
  8005a5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005aa:	5d                   	pop    %ebp
  8005ab:	c3                   	ret    

008005ac <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8005ac:	55                   	push   %ebp
  8005ad:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005af:	83 fa 01             	cmp    $0x1,%edx
  8005b2:	7e 0e                	jle    8005c2 <getint+0x16>
		return va_arg(*ap, long long);
  8005b4:	8b 10                	mov    (%eax),%edx
  8005b6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005b9:	89 08                	mov    %ecx,(%eax)
  8005bb:	8b 02                	mov    (%edx),%eax
  8005bd:	8b 52 04             	mov    0x4(%edx),%edx
  8005c0:	eb 1a                	jmp    8005dc <getint+0x30>
	else if (lflag)
  8005c2:	85 d2                	test   %edx,%edx
  8005c4:	74 0c                	je     8005d2 <getint+0x26>
		return va_arg(*ap, long);
  8005c6:	8b 10                	mov    (%eax),%edx
  8005c8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005cb:	89 08                	mov    %ecx,(%eax)
  8005cd:	8b 02                	mov    (%edx),%eax
  8005cf:	99                   	cltd   
  8005d0:	eb 0a                	jmp    8005dc <getint+0x30>
	else
		return va_arg(*ap, int);
  8005d2:	8b 10                	mov    (%eax),%edx
  8005d4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005d7:	89 08                	mov    %ecx,(%eax)
  8005d9:	8b 02                	mov    (%edx),%eax
  8005db:	99                   	cltd   
}
  8005dc:	5d                   	pop    %ebp
  8005dd:	c3                   	ret    

008005de <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005de:	55                   	push   %ebp
  8005df:	89 e5                	mov    %esp,%ebp
  8005e1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005e4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005e7:	8b 10                	mov    (%eax),%edx
  8005e9:	3b 50 04             	cmp    0x4(%eax),%edx
  8005ec:	73 08                	jae    8005f6 <sprintputch+0x18>
		*b->buf++ = ch;
  8005ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005f1:	88 0a                	mov    %cl,(%edx)
  8005f3:	42                   	inc    %edx
  8005f4:	89 10                	mov    %edx,(%eax)
}
  8005f6:	5d                   	pop    %ebp
  8005f7:	c3                   	ret    

008005f8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005f8:	55                   	push   %ebp
  8005f9:	89 e5                	mov    %esp,%ebp
  8005fb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005fe:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800601:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800605:	8b 45 10             	mov    0x10(%ebp),%eax
  800608:	89 44 24 08          	mov    %eax,0x8(%esp)
  80060c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80060f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800613:	8b 45 08             	mov    0x8(%ebp),%eax
  800616:	89 04 24             	mov    %eax,(%esp)
  800619:	e8 02 00 00 00       	call   800620 <vprintfmt>
	va_end(ap);
}
  80061e:	c9                   	leave  
  80061f:	c3                   	ret    

00800620 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800620:	55                   	push   %ebp
  800621:	89 e5                	mov    %esp,%ebp
  800623:	57                   	push   %edi
  800624:	56                   	push   %esi
  800625:	53                   	push   %ebx
  800626:	83 ec 4c             	sub    $0x4c,%esp
  800629:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80062c:	8b 75 10             	mov    0x10(%ebp),%esi
  80062f:	eb 12                	jmp    800643 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800631:	85 c0                	test   %eax,%eax
  800633:	0f 84 40 03 00 00    	je     800979 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800639:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063d:	89 04 24             	mov    %eax,(%esp)
  800640:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800643:	0f b6 06             	movzbl (%esi),%eax
  800646:	46                   	inc    %esi
  800647:	83 f8 25             	cmp    $0x25,%eax
  80064a:	75 e5                	jne    800631 <vprintfmt+0x11>
  80064c:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800650:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800657:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80065c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800663:	ba 00 00 00 00       	mov    $0x0,%edx
  800668:	eb 26                	jmp    800690 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066a:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80066d:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800671:	eb 1d                	jmp    800690 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800673:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800676:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80067a:	eb 14                	jmp    800690 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80067f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800686:	eb 08                	jmp    800690 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800688:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80068b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800690:	0f b6 06             	movzbl (%esi),%eax
  800693:	8d 4e 01             	lea    0x1(%esi),%ecx
  800696:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800699:	8a 0e                	mov    (%esi),%cl
  80069b:	83 e9 23             	sub    $0x23,%ecx
  80069e:	80 f9 55             	cmp    $0x55,%cl
  8006a1:	0f 87 b6 02 00 00    	ja     80095d <vprintfmt+0x33d>
  8006a7:	0f b6 c9             	movzbl %cl,%ecx
  8006aa:	ff 24 8d e0 10 80 00 	jmp    *0x8010e0(,%ecx,4)
  8006b1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006b4:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006b9:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  8006bc:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  8006c0:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006c3:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8006c6:	83 f9 09             	cmp    $0x9,%ecx
  8006c9:	77 2a                	ja     8006f5 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006cb:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006cc:	eb eb                	jmp    8006b9 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8d 48 04             	lea    0x4(%eax),%ecx
  8006d4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006d7:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006dc:	eb 17                	jmp    8006f5 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006de:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006e2:	78 98                	js     80067c <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006e7:	eb a7                	jmp    800690 <vprintfmt+0x70>
  8006e9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006ec:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006f3:	eb 9b                	jmp    800690 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006f5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006f9:	79 95                	jns    800690 <vprintfmt+0x70>
  8006fb:	eb 8b                	jmp    800688 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006fd:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fe:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800701:	eb 8d                	jmp    800690 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800703:	8b 45 14             	mov    0x14(%ebp),%eax
  800706:	8d 50 04             	lea    0x4(%eax),%edx
  800709:	89 55 14             	mov    %edx,0x14(%ebp)
  80070c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800710:	8b 00                	mov    (%eax),%eax
  800712:	89 04 24             	mov    %eax,(%esp)
  800715:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800718:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80071b:	e9 23 ff ff ff       	jmp    800643 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800720:	8b 45 14             	mov    0x14(%ebp),%eax
  800723:	8d 50 04             	lea    0x4(%eax),%edx
  800726:	89 55 14             	mov    %edx,0x14(%ebp)
  800729:	8b 00                	mov    (%eax),%eax
  80072b:	85 c0                	test   %eax,%eax
  80072d:	79 02                	jns    800731 <vprintfmt+0x111>
  80072f:	f7 d8                	neg    %eax
  800731:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800733:	83 f8 09             	cmp    $0x9,%eax
  800736:	7f 0b                	jg     800743 <vprintfmt+0x123>
  800738:	8b 04 85 40 12 80 00 	mov    0x801240(,%eax,4),%eax
  80073f:	85 c0                	test   %eax,%eax
  800741:	75 23                	jne    800766 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800743:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800747:	c7 44 24 08 3a 10 80 	movl   $0x80103a,0x8(%esp)
  80074e:	00 
  80074f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800753:	8b 45 08             	mov    0x8(%ebp),%eax
  800756:	89 04 24             	mov    %eax,(%esp)
  800759:	e8 9a fe ff ff       	call   8005f8 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800761:	e9 dd fe ff ff       	jmp    800643 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800766:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076a:	c7 44 24 08 43 10 80 	movl   $0x801043,0x8(%esp)
  800771:	00 
  800772:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800776:	8b 55 08             	mov    0x8(%ebp),%edx
  800779:	89 14 24             	mov    %edx,(%esp)
  80077c:	e8 77 fe ff ff       	call   8005f8 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800781:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800784:	e9 ba fe ff ff       	jmp    800643 <vprintfmt+0x23>
  800789:	89 f9                	mov    %edi,%ecx
  80078b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80078e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 50 04             	lea    0x4(%eax),%edx
  800797:	89 55 14             	mov    %edx,0x14(%ebp)
  80079a:	8b 30                	mov    (%eax),%esi
  80079c:	85 f6                	test   %esi,%esi
  80079e:	75 05                	jne    8007a5 <vprintfmt+0x185>
				p = "(null)";
  8007a0:	be 33 10 80 00       	mov    $0x801033,%esi
			if (width > 0 && padc != '-')
  8007a5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a9:	0f 8e 84 00 00 00    	jle    800833 <vprintfmt+0x213>
  8007af:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007b3:	74 7e                	je     800833 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007b5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007b9:	89 34 24             	mov    %esi,(%esp)
  8007bc:	e8 5d 02 00 00       	call   800a1e <strnlen>
  8007c1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007c4:	29 c2                	sub    %eax,%edx
  8007c6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8007c9:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8007cd:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007d0:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007d3:	89 de                	mov    %ebx,%esi
  8007d5:	89 d3                	mov    %edx,%ebx
  8007d7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d9:	eb 0b                	jmp    8007e6 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007df:	89 3c 24             	mov    %edi,(%esp)
  8007e2:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007e5:	4b                   	dec    %ebx
  8007e6:	85 db                	test   %ebx,%ebx
  8007e8:	7f f1                	jg     8007db <vprintfmt+0x1bb>
  8007ea:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007ed:	89 f3                	mov    %esi,%ebx
  8007ef:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007f5:	85 c0                	test   %eax,%eax
  8007f7:	79 05                	jns    8007fe <vprintfmt+0x1de>
  8007f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800801:	29 c2                	sub    %eax,%edx
  800803:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800806:	eb 2b                	jmp    800833 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800808:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80080c:	74 18                	je     800826 <vprintfmt+0x206>
  80080e:	8d 50 e0             	lea    -0x20(%eax),%edx
  800811:	83 fa 5e             	cmp    $0x5e,%edx
  800814:	76 10                	jbe    800826 <vprintfmt+0x206>
					putch('?', putdat);
  800816:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80081a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800821:	ff 55 08             	call   *0x8(%ebp)
  800824:	eb 0a                	jmp    800830 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800826:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80082a:	89 04 24             	mov    %eax,(%esp)
  80082d:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800830:	ff 4d e4             	decl   -0x1c(%ebp)
  800833:	0f be 06             	movsbl (%esi),%eax
  800836:	46                   	inc    %esi
  800837:	85 c0                	test   %eax,%eax
  800839:	74 21                	je     80085c <vprintfmt+0x23c>
  80083b:	85 ff                	test   %edi,%edi
  80083d:	78 c9                	js     800808 <vprintfmt+0x1e8>
  80083f:	4f                   	dec    %edi
  800840:	79 c6                	jns    800808 <vprintfmt+0x1e8>
  800842:	8b 7d 08             	mov    0x8(%ebp),%edi
  800845:	89 de                	mov    %ebx,%esi
  800847:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80084a:	eb 18                	jmp    800864 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80084c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800850:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800857:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800859:	4b                   	dec    %ebx
  80085a:	eb 08                	jmp    800864 <vprintfmt+0x244>
  80085c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80085f:	89 de                	mov    %ebx,%esi
  800861:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800864:	85 db                	test   %ebx,%ebx
  800866:	7f e4                	jg     80084c <vprintfmt+0x22c>
  800868:	89 7d 08             	mov    %edi,0x8(%ebp)
  80086b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800870:	e9 ce fd ff ff       	jmp    800643 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800875:	8d 45 14             	lea    0x14(%ebp),%eax
  800878:	e8 2f fd ff ff       	call   8005ac <getint>
  80087d:	89 c6                	mov    %eax,%esi
  80087f:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800881:	85 d2                	test   %edx,%edx
  800883:	78 07                	js     80088c <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800885:	be 0a 00 00 00       	mov    $0xa,%esi
  80088a:	eb 7e                	jmp    80090a <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80088c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800890:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800897:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80089a:	89 f0                	mov    %esi,%eax
  80089c:	89 fa                	mov    %edi,%edx
  80089e:	f7 d8                	neg    %eax
  8008a0:	83 d2 00             	adc    $0x0,%edx
  8008a3:	f7 da                	neg    %edx
			}
			base = 10;
  8008a5:	be 0a 00 00 00       	mov    $0xa,%esi
  8008aa:	eb 5e                	jmp    80090a <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8008af:	e8 be fc ff ff       	call   800572 <getuint>
			base = 10;
  8008b4:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8008b9:	eb 4f                	jmp    80090a <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8008bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008be:	e8 af fc ff ff       	call   800572 <getuint>
			base = 8;
  8008c3:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8008c8:	eb 40                	jmp    80090a <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  8008ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ce:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008d5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008dc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008e3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e9:	8d 50 04             	lea    0x4(%eax),%edx
  8008ec:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008ef:	8b 00                	mov    (%eax),%eax
  8008f1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008f6:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8008fb:	eb 0d                	jmp    80090a <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008fd:	8d 45 14             	lea    0x14(%ebp),%eax
  800900:	e8 6d fc ff ff       	call   800572 <getuint>
			base = 16;
  800905:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80090a:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  80090e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800912:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800915:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800919:	89 74 24 08          	mov    %esi,0x8(%esp)
  80091d:	89 04 24             	mov    %eax,(%esp)
  800920:	89 54 24 04          	mov    %edx,0x4(%esp)
  800924:	89 da                	mov    %ebx,%edx
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	e8 7a fb ff ff       	call   8004a8 <printnum>
			break;
  80092e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800931:	e9 0d fd ff ff       	jmp    800643 <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  800936:	8d 45 14             	lea    0x14(%ebp),%eax
  800939:	e8 6e fc ff ff       	call   8005ac <getint>
  80093e:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800943:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  800946:	e9 f8 fc ff ff       	jmp    800643 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80094b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80094f:	89 04 24             	mov    %eax,(%esp)
  800952:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800955:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800958:	e9 e6 fc ff ff       	jmp    800643 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80095d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800961:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800968:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80096b:	eb 01                	jmp    80096e <vprintfmt+0x34e>
  80096d:	4e                   	dec    %esi
  80096e:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800972:	75 f9                	jne    80096d <vprintfmt+0x34d>
  800974:	e9 ca fc ff ff       	jmp    800643 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800979:	83 c4 4c             	add    $0x4c,%esp
  80097c:	5b                   	pop    %ebx
  80097d:	5e                   	pop    %esi
  80097e:	5f                   	pop    %edi
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	83 ec 28             	sub    $0x28,%esp
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80098d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800990:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800994:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800997:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80099e:	85 c0                	test   %eax,%eax
  8009a0:	74 30                	je     8009d2 <vsnprintf+0x51>
  8009a2:	85 d2                	test   %edx,%edx
  8009a4:	7e 33                	jle    8009d9 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bb:	c7 04 24 de 05 80 00 	movl   $0x8005de,(%esp)
  8009c2:	e8 59 fc ff ff       	call   800620 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009ca:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d0:	eb 0c                	jmp    8009de <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009d7:	eb 05                	jmp    8009de <vsnprintf+0x5d>
  8009d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009de:	c9                   	leave  
  8009df:	c3                   	ret    

008009e0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009e6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	89 04 24             	mov    %eax,(%esp)
  800a01:	e8 7b ff ff ff       	call   800981 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a06:	c9                   	leave  
  800a07:	c3                   	ret    

00800a08 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a13:	eb 01                	jmp    800a16 <strlen+0xe>
		n++;
  800a15:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a16:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a1a:	75 f9                	jne    800a15 <strlen+0xd>
		n++;
	return n;
}
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a24:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2c:	eb 01                	jmp    800a2f <strnlen+0x11>
		n++;
  800a2e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a2f:	39 d0                	cmp    %edx,%eax
  800a31:	74 06                	je     800a39 <strnlen+0x1b>
  800a33:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a37:	75 f5                	jne    800a2e <strnlen+0x10>
		n++;
	return n;
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	53                   	push   %ebx
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a45:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a4d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a50:	42                   	inc    %edx
  800a51:	84 c9                	test   %cl,%cl
  800a53:	75 f5                	jne    800a4a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a55:	5b                   	pop    %ebx
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	53                   	push   %ebx
  800a5c:	83 ec 08             	sub    $0x8,%esp
  800a5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a62:	89 1c 24             	mov    %ebx,(%esp)
  800a65:	e8 9e ff ff ff       	call   800a08 <strlen>
	strcpy(dst + len, src);
  800a6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a71:	01 d8                	add    %ebx,%eax
  800a73:	89 04 24             	mov    %eax,(%esp)
  800a76:	e8 c0 ff ff ff       	call   800a3b <strcpy>
	return dst;
}
  800a7b:	89 d8                	mov    %ebx,%eax
  800a7d:	83 c4 08             	add    $0x8,%esp
  800a80:	5b                   	pop    %ebx
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a91:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a96:	eb 0c                	jmp    800aa4 <strncpy+0x21>
		*dst++ = *src;
  800a98:	8a 1a                	mov    (%edx),%bl
  800a9a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a9d:	80 3a 01             	cmpb   $0x1,(%edx)
  800aa0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa3:	41                   	inc    %ecx
  800aa4:	39 f1                	cmp    %esi,%ecx
  800aa6:	75 f0                	jne    800a98 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aa8:	5b                   	pop    %ebx
  800aa9:	5e                   	pop    %esi
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
  800ab1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aba:	85 d2                	test   %edx,%edx
  800abc:	75 0a                	jne    800ac8 <strlcpy+0x1c>
  800abe:	89 f0                	mov    %esi,%eax
  800ac0:	eb 1a                	jmp    800adc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ac2:	88 18                	mov    %bl,(%eax)
  800ac4:	40                   	inc    %eax
  800ac5:	41                   	inc    %ecx
  800ac6:	eb 02                	jmp    800aca <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ac8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800aca:	4a                   	dec    %edx
  800acb:	74 0a                	je     800ad7 <strlcpy+0x2b>
  800acd:	8a 19                	mov    (%ecx),%bl
  800acf:	84 db                	test   %bl,%bl
  800ad1:	75 ef                	jne    800ac2 <strlcpy+0x16>
  800ad3:	89 c2                	mov    %eax,%edx
  800ad5:	eb 02                	jmp    800ad9 <strlcpy+0x2d>
  800ad7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ad9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800adc:	29 f0                	sub    %esi,%eax
}
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aeb:	eb 02                	jmp    800aef <strcmp+0xd>
		p++, q++;
  800aed:	41                   	inc    %ecx
  800aee:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aef:	8a 01                	mov    (%ecx),%al
  800af1:	84 c0                	test   %al,%al
  800af3:	74 04                	je     800af9 <strcmp+0x17>
  800af5:	3a 02                	cmp    (%edx),%al
  800af7:	74 f4                	je     800aed <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800af9:	0f b6 c0             	movzbl %al,%eax
  800afc:	0f b6 12             	movzbl (%edx),%edx
  800aff:	29 d0                	sub    %edx,%eax
}
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	53                   	push   %ebx
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b10:	eb 03                	jmp    800b15 <strncmp+0x12>
		n--, p++, q++;
  800b12:	4a                   	dec    %edx
  800b13:	40                   	inc    %eax
  800b14:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b15:	85 d2                	test   %edx,%edx
  800b17:	74 14                	je     800b2d <strncmp+0x2a>
  800b19:	8a 18                	mov    (%eax),%bl
  800b1b:	84 db                	test   %bl,%bl
  800b1d:	74 04                	je     800b23 <strncmp+0x20>
  800b1f:	3a 19                	cmp    (%ecx),%bl
  800b21:	74 ef                	je     800b12 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b23:	0f b6 00             	movzbl (%eax),%eax
  800b26:	0f b6 11             	movzbl (%ecx),%edx
  800b29:	29 d0                	sub    %edx,%eax
  800b2b:	eb 05                	jmp    800b32 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b32:	5b                   	pop    %ebx
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b3e:	eb 05                	jmp    800b45 <strchr+0x10>
		if (*s == c)
  800b40:	38 ca                	cmp    %cl,%dl
  800b42:	74 0c                	je     800b50 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b44:	40                   	inc    %eax
  800b45:	8a 10                	mov    (%eax),%dl
  800b47:	84 d2                	test   %dl,%dl
  800b49:	75 f5                	jne    800b40 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
  800b58:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b5b:	eb 05                	jmp    800b62 <strfind+0x10>
		if (*s == c)
  800b5d:	38 ca                	cmp    %cl,%dl
  800b5f:	74 07                	je     800b68 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b61:	40                   	inc    %eax
  800b62:	8a 10                	mov    (%eax),%dl
  800b64:	84 d2                	test   %dl,%dl
  800b66:	75 f5                	jne    800b5d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	57                   	push   %edi
  800b6e:	56                   	push   %esi
  800b6f:	53                   	push   %ebx
  800b70:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b76:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b79:	85 c9                	test   %ecx,%ecx
  800b7b:	74 30                	je     800bad <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b7d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b83:	75 25                	jne    800baa <memset+0x40>
  800b85:	f6 c1 03             	test   $0x3,%cl
  800b88:	75 20                	jne    800baa <memset+0x40>
		c &= 0xFF;
  800b8a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b8d:	89 d3                	mov    %edx,%ebx
  800b8f:	c1 e3 08             	shl    $0x8,%ebx
  800b92:	89 d6                	mov    %edx,%esi
  800b94:	c1 e6 18             	shl    $0x18,%esi
  800b97:	89 d0                	mov    %edx,%eax
  800b99:	c1 e0 10             	shl    $0x10,%eax
  800b9c:	09 f0                	or     %esi,%eax
  800b9e:	09 d0                	or     %edx,%eax
  800ba0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ba2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ba5:	fc                   	cld    
  800ba6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ba8:	eb 03                	jmp    800bad <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800baa:	fc                   	cld    
  800bab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bad:	89 f8                	mov    %edi,%eax
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bc2:	39 c6                	cmp    %eax,%esi
  800bc4:	73 34                	jae    800bfa <memmove+0x46>
  800bc6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bc9:	39 d0                	cmp    %edx,%eax
  800bcb:	73 2d                	jae    800bfa <memmove+0x46>
		s += n;
		d += n;
  800bcd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd0:	f6 c2 03             	test   $0x3,%dl
  800bd3:	75 1b                	jne    800bf0 <memmove+0x3c>
  800bd5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bdb:	75 13                	jne    800bf0 <memmove+0x3c>
  800bdd:	f6 c1 03             	test   $0x3,%cl
  800be0:	75 0e                	jne    800bf0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800be2:	83 ef 04             	sub    $0x4,%edi
  800be5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800be8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800beb:	fd                   	std    
  800bec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bee:	eb 07                	jmp    800bf7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bf0:	4f                   	dec    %edi
  800bf1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bf4:	fd                   	std    
  800bf5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bf7:	fc                   	cld    
  800bf8:	eb 20                	jmp    800c1a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bfa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c00:	75 13                	jne    800c15 <memmove+0x61>
  800c02:	a8 03                	test   $0x3,%al
  800c04:	75 0f                	jne    800c15 <memmove+0x61>
  800c06:	f6 c1 03             	test   $0x3,%cl
  800c09:	75 0a                	jne    800c15 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c0b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c0e:	89 c7                	mov    %eax,%edi
  800c10:	fc                   	cld    
  800c11:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c13:	eb 05                	jmp    800c1a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c15:	89 c7                	mov    %eax,%edi
  800c17:	fc                   	cld    
  800c18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c24:	8b 45 10             	mov    0x10(%ebp),%eax
  800c27:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c32:	8b 45 08             	mov    0x8(%ebp),%eax
  800c35:	89 04 24             	mov    %eax,(%esp)
  800c38:	e8 77 ff ff ff       	call   800bb4 <memmove>
}
  800c3d:	c9                   	leave  
  800c3e:	c3                   	ret    

00800c3f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c48:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c53:	eb 16                	jmp    800c6b <memcmp+0x2c>
		if (*s1 != *s2)
  800c55:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c58:	42                   	inc    %edx
  800c59:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c5d:	38 c8                	cmp    %cl,%al
  800c5f:	74 0a                	je     800c6b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c61:	0f b6 c0             	movzbl %al,%eax
  800c64:	0f b6 c9             	movzbl %cl,%ecx
  800c67:	29 c8                	sub    %ecx,%eax
  800c69:	eb 09                	jmp    800c74 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c6b:	39 da                	cmp    %ebx,%edx
  800c6d:	75 e6                	jne    800c55 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c82:	89 c2                	mov    %eax,%edx
  800c84:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c87:	eb 05                	jmp    800c8e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c89:	38 08                	cmp    %cl,(%eax)
  800c8b:	74 05                	je     800c92 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c8d:	40                   	inc    %eax
  800c8e:	39 d0                	cmp    %edx,%eax
  800c90:	72 f7                	jb     800c89 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca0:	eb 01                	jmp    800ca3 <strtol+0xf>
		s++;
  800ca2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca3:	8a 02                	mov    (%edx),%al
  800ca5:	3c 20                	cmp    $0x20,%al
  800ca7:	74 f9                	je     800ca2 <strtol+0xe>
  800ca9:	3c 09                	cmp    $0x9,%al
  800cab:	74 f5                	je     800ca2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cad:	3c 2b                	cmp    $0x2b,%al
  800caf:	75 08                	jne    800cb9 <strtol+0x25>
		s++;
  800cb1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cb2:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb7:	eb 13                	jmp    800ccc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cb9:	3c 2d                	cmp    $0x2d,%al
  800cbb:	75 0a                	jne    800cc7 <strtol+0x33>
		s++, neg = 1;
  800cbd:	8d 52 01             	lea    0x1(%edx),%edx
  800cc0:	bf 01 00 00 00       	mov    $0x1,%edi
  800cc5:	eb 05                	jmp    800ccc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cc7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ccc:	85 db                	test   %ebx,%ebx
  800cce:	74 05                	je     800cd5 <strtol+0x41>
  800cd0:	83 fb 10             	cmp    $0x10,%ebx
  800cd3:	75 28                	jne    800cfd <strtol+0x69>
  800cd5:	8a 02                	mov    (%edx),%al
  800cd7:	3c 30                	cmp    $0x30,%al
  800cd9:	75 10                	jne    800ceb <strtol+0x57>
  800cdb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cdf:	75 0a                	jne    800ceb <strtol+0x57>
		s += 2, base = 16;
  800ce1:	83 c2 02             	add    $0x2,%edx
  800ce4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ce9:	eb 12                	jmp    800cfd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ceb:	85 db                	test   %ebx,%ebx
  800ced:	75 0e                	jne    800cfd <strtol+0x69>
  800cef:	3c 30                	cmp    $0x30,%al
  800cf1:	75 05                	jne    800cf8 <strtol+0x64>
		s++, base = 8;
  800cf3:	42                   	inc    %edx
  800cf4:	b3 08                	mov    $0x8,%bl
  800cf6:	eb 05                	jmp    800cfd <strtol+0x69>
	else if (base == 0)
		base = 10;
  800cf8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cfd:	b8 00 00 00 00       	mov    $0x0,%eax
  800d02:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d04:	8a 0a                	mov    (%edx),%cl
  800d06:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d09:	80 fb 09             	cmp    $0x9,%bl
  800d0c:	77 08                	ja     800d16 <strtol+0x82>
			dig = *s - '0';
  800d0e:	0f be c9             	movsbl %cl,%ecx
  800d11:	83 e9 30             	sub    $0x30,%ecx
  800d14:	eb 1e                	jmp    800d34 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d16:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d19:	80 fb 19             	cmp    $0x19,%bl
  800d1c:	77 08                	ja     800d26 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d1e:	0f be c9             	movsbl %cl,%ecx
  800d21:	83 e9 57             	sub    $0x57,%ecx
  800d24:	eb 0e                	jmp    800d34 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d26:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d29:	80 fb 19             	cmp    $0x19,%bl
  800d2c:	77 12                	ja     800d40 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d2e:	0f be c9             	movsbl %cl,%ecx
  800d31:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d34:	39 f1                	cmp    %esi,%ecx
  800d36:	7d 0c                	jge    800d44 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d38:	42                   	inc    %edx
  800d39:	0f af c6             	imul   %esi,%eax
  800d3c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d3e:	eb c4                	jmp    800d04 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d40:	89 c1                	mov    %eax,%ecx
  800d42:	eb 02                	jmp    800d46 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d44:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d4a:	74 05                	je     800d51 <strtol+0xbd>
		*endptr = (char *) s;
  800d4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d4f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d51:	85 ff                	test   %edi,%edi
  800d53:	74 04                	je     800d59 <strtol+0xc5>
  800d55:	89 c8                	mov    %ecx,%eax
  800d57:	f7 d8                	neg    %eax
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    
	...

00800d60 <__udivdi3>:
  800d60:	55                   	push   %ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	83 ec 10             	sub    $0x10,%esp
  800d66:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d6a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800d6e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d72:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800d76:	89 cd                	mov    %ecx,%ebp
  800d78:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	75 2c                	jne    800dac <__udivdi3+0x4c>
  800d80:	39 f9                	cmp    %edi,%ecx
  800d82:	77 68                	ja     800dec <__udivdi3+0x8c>
  800d84:	85 c9                	test   %ecx,%ecx
  800d86:	75 0b                	jne    800d93 <__udivdi3+0x33>
  800d88:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8d:	31 d2                	xor    %edx,%edx
  800d8f:	f7 f1                	div    %ecx
  800d91:	89 c1                	mov    %eax,%ecx
  800d93:	31 d2                	xor    %edx,%edx
  800d95:	89 f8                	mov    %edi,%eax
  800d97:	f7 f1                	div    %ecx
  800d99:	89 c7                	mov    %eax,%edi
  800d9b:	89 f0                	mov    %esi,%eax
  800d9d:	f7 f1                	div    %ecx
  800d9f:	89 c6                	mov    %eax,%esi
  800da1:	89 f0                	mov    %esi,%eax
  800da3:	89 fa                	mov    %edi,%edx
  800da5:	83 c4 10             	add    $0x10,%esp
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    
  800dac:	39 f8                	cmp    %edi,%eax
  800dae:	77 2c                	ja     800ddc <__udivdi3+0x7c>
  800db0:	0f bd f0             	bsr    %eax,%esi
  800db3:	83 f6 1f             	xor    $0x1f,%esi
  800db6:	75 4c                	jne    800e04 <__udivdi3+0xa4>
  800db8:	39 f8                	cmp    %edi,%eax
  800dba:	bf 00 00 00 00       	mov    $0x0,%edi
  800dbf:	72 0a                	jb     800dcb <__udivdi3+0x6b>
  800dc1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800dc5:	0f 87 ad 00 00 00    	ja     800e78 <__udivdi3+0x118>
  800dcb:	be 01 00 00 00       	mov    $0x1,%esi
  800dd0:	89 f0                	mov    %esi,%eax
  800dd2:	89 fa                	mov    %edi,%edx
  800dd4:	83 c4 10             	add    $0x10,%esp
  800dd7:	5e                   	pop    %esi
  800dd8:	5f                   	pop    %edi
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    
  800ddb:	90                   	nop
  800ddc:	31 ff                	xor    %edi,%edi
  800dde:	31 f6                	xor    %esi,%esi
  800de0:	89 f0                	mov    %esi,%eax
  800de2:	89 fa                	mov    %edi,%edx
  800de4:	83 c4 10             	add    $0x10,%esp
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    
  800deb:	90                   	nop
  800dec:	89 fa                	mov    %edi,%edx
  800dee:	89 f0                	mov    %esi,%eax
  800df0:	f7 f1                	div    %ecx
  800df2:	89 c6                	mov    %eax,%esi
  800df4:	31 ff                	xor    %edi,%edi
  800df6:	89 f0                	mov    %esi,%eax
  800df8:	89 fa                	mov    %edi,%edx
  800dfa:	83 c4 10             	add    $0x10,%esp
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    
  800e01:	8d 76 00             	lea    0x0(%esi),%esi
  800e04:	89 f1                	mov    %esi,%ecx
  800e06:	d3 e0                	shl    %cl,%eax
  800e08:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e0c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e11:	29 f0                	sub    %esi,%eax
  800e13:	89 ea                	mov    %ebp,%edx
  800e15:	88 c1                	mov    %al,%cl
  800e17:	d3 ea                	shr    %cl,%edx
  800e19:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e1d:	09 ca                	or     %ecx,%edx
  800e1f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e23:	89 f1                	mov    %esi,%ecx
  800e25:	d3 e5                	shl    %cl,%ebp
  800e27:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800e2b:	89 fd                	mov    %edi,%ebp
  800e2d:	88 c1                	mov    %al,%cl
  800e2f:	d3 ed                	shr    %cl,%ebp
  800e31:	89 fa                	mov    %edi,%edx
  800e33:	89 f1                	mov    %esi,%ecx
  800e35:	d3 e2                	shl    %cl,%edx
  800e37:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e3b:	88 c1                	mov    %al,%cl
  800e3d:	d3 ef                	shr    %cl,%edi
  800e3f:	09 d7                	or     %edx,%edi
  800e41:	89 f8                	mov    %edi,%eax
  800e43:	89 ea                	mov    %ebp,%edx
  800e45:	f7 74 24 08          	divl   0x8(%esp)
  800e49:	89 d1                	mov    %edx,%ecx
  800e4b:	89 c7                	mov    %eax,%edi
  800e4d:	f7 64 24 0c          	mull   0xc(%esp)
  800e51:	39 d1                	cmp    %edx,%ecx
  800e53:	72 17                	jb     800e6c <__udivdi3+0x10c>
  800e55:	74 09                	je     800e60 <__udivdi3+0x100>
  800e57:	89 fe                	mov    %edi,%esi
  800e59:	31 ff                	xor    %edi,%edi
  800e5b:	e9 41 ff ff ff       	jmp    800da1 <__udivdi3+0x41>
  800e60:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e64:	89 f1                	mov    %esi,%ecx
  800e66:	d3 e2                	shl    %cl,%edx
  800e68:	39 c2                	cmp    %eax,%edx
  800e6a:	73 eb                	jae    800e57 <__udivdi3+0xf7>
  800e6c:	8d 77 ff             	lea    -0x1(%edi),%esi
  800e6f:	31 ff                	xor    %edi,%edi
  800e71:	e9 2b ff ff ff       	jmp    800da1 <__udivdi3+0x41>
  800e76:	66 90                	xchg   %ax,%ax
  800e78:	31 f6                	xor    %esi,%esi
  800e7a:	e9 22 ff ff ff       	jmp    800da1 <__udivdi3+0x41>
	...

00800e80 <__umoddi3>:
  800e80:	55                   	push   %ebp
  800e81:	57                   	push   %edi
  800e82:	56                   	push   %esi
  800e83:	83 ec 20             	sub    $0x20,%esp
  800e86:	8b 44 24 30          	mov    0x30(%esp),%eax
  800e8a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800e8e:	89 44 24 14          	mov    %eax,0x14(%esp)
  800e92:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e96:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e9a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e9e:	89 c7                	mov    %eax,%edi
  800ea0:	89 f2                	mov    %esi,%edx
  800ea2:	85 ed                	test   %ebp,%ebp
  800ea4:	75 16                	jne    800ebc <__umoddi3+0x3c>
  800ea6:	39 f1                	cmp    %esi,%ecx
  800ea8:	0f 86 a6 00 00 00    	jbe    800f54 <__umoddi3+0xd4>
  800eae:	f7 f1                	div    %ecx
  800eb0:	89 d0                	mov    %edx,%eax
  800eb2:	31 d2                	xor    %edx,%edx
  800eb4:	83 c4 20             	add    $0x20,%esp
  800eb7:	5e                   	pop    %esi
  800eb8:	5f                   	pop    %edi
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    
  800ebb:	90                   	nop
  800ebc:	39 f5                	cmp    %esi,%ebp
  800ebe:	0f 87 ac 00 00 00    	ja     800f70 <__umoddi3+0xf0>
  800ec4:	0f bd c5             	bsr    %ebp,%eax
  800ec7:	83 f0 1f             	xor    $0x1f,%eax
  800eca:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ece:	0f 84 a8 00 00 00    	je     800f7c <__umoddi3+0xfc>
  800ed4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ed8:	d3 e5                	shl    %cl,%ebp
  800eda:	bf 20 00 00 00       	mov    $0x20,%edi
  800edf:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800ee3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ee7:	89 f9                	mov    %edi,%ecx
  800ee9:	d3 e8                	shr    %cl,%eax
  800eeb:	09 e8                	or     %ebp,%eax
  800eed:	89 44 24 18          	mov    %eax,0x18(%esp)
  800ef1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ef5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ef9:	d3 e0                	shl    %cl,%eax
  800efb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eff:	89 f2                	mov    %esi,%edx
  800f01:	d3 e2                	shl    %cl,%edx
  800f03:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f07:	d3 e0                	shl    %cl,%eax
  800f09:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800f0d:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f11:	89 f9                	mov    %edi,%ecx
  800f13:	d3 e8                	shr    %cl,%eax
  800f15:	09 d0                	or     %edx,%eax
  800f17:	d3 ee                	shr    %cl,%esi
  800f19:	89 f2                	mov    %esi,%edx
  800f1b:	f7 74 24 18          	divl   0x18(%esp)
  800f1f:	89 d6                	mov    %edx,%esi
  800f21:	f7 64 24 0c          	mull   0xc(%esp)
  800f25:	89 c5                	mov    %eax,%ebp
  800f27:	89 d1                	mov    %edx,%ecx
  800f29:	39 d6                	cmp    %edx,%esi
  800f2b:	72 67                	jb     800f94 <__umoddi3+0x114>
  800f2d:	74 75                	je     800fa4 <__umoddi3+0x124>
  800f2f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f33:	29 e8                	sub    %ebp,%eax
  800f35:	19 ce                	sbb    %ecx,%esi
  800f37:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f3b:	d3 e8                	shr    %cl,%eax
  800f3d:	89 f2                	mov    %esi,%edx
  800f3f:	89 f9                	mov    %edi,%ecx
  800f41:	d3 e2                	shl    %cl,%edx
  800f43:	09 d0                	or     %edx,%eax
  800f45:	89 f2                	mov    %esi,%edx
  800f47:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f4b:	d3 ea                	shr    %cl,%edx
  800f4d:	83 c4 20             	add    $0x20,%esp
  800f50:	5e                   	pop    %esi
  800f51:	5f                   	pop    %edi
  800f52:	5d                   	pop    %ebp
  800f53:	c3                   	ret    
  800f54:	85 c9                	test   %ecx,%ecx
  800f56:	75 0b                	jne    800f63 <__umoddi3+0xe3>
  800f58:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5d:	31 d2                	xor    %edx,%edx
  800f5f:	f7 f1                	div    %ecx
  800f61:	89 c1                	mov    %eax,%ecx
  800f63:	89 f0                	mov    %esi,%eax
  800f65:	31 d2                	xor    %edx,%edx
  800f67:	f7 f1                	div    %ecx
  800f69:	89 f8                	mov    %edi,%eax
  800f6b:	e9 3e ff ff ff       	jmp    800eae <__umoddi3+0x2e>
  800f70:	89 f2                	mov    %esi,%edx
  800f72:	83 c4 20             	add    $0x20,%esp
  800f75:	5e                   	pop    %esi
  800f76:	5f                   	pop    %edi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    
  800f79:	8d 76 00             	lea    0x0(%esi),%esi
  800f7c:	39 f5                	cmp    %esi,%ebp
  800f7e:	72 04                	jb     800f84 <__umoddi3+0x104>
  800f80:	39 f9                	cmp    %edi,%ecx
  800f82:	77 06                	ja     800f8a <__umoddi3+0x10a>
  800f84:	89 f2                	mov    %esi,%edx
  800f86:	29 cf                	sub    %ecx,%edi
  800f88:	19 ea                	sbb    %ebp,%edx
  800f8a:	89 f8                	mov    %edi,%eax
  800f8c:	83 c4 20             	add    $0x20,%esp
  800f8f:	5e                   	pop    %esi
  800f90:	5f                   	pop    %edi
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    
  800f93:	90                   	nop
  800f94:	89 d1                	mov    %edx,%ecx
  800f96:	89 c5                	mov    %eax,%ebp
  800f98:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800f9c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fa0:	eb 8d                	jmp    800f2f <__umoddi3+0xaf>
  800fa2:	66 90                	xchg   %ax,%ax
  800fa4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fa8:	72 ea                	jb     800f94 <__umoddi3+0x114>
  800faa:	89 f1                	mov    %esi,%ecx
  800fac:	eb 81                	jmp    800f2f <__umoddi3+0xaf>
