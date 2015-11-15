
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
  80003a:	c7 05 00 20 80 00 40 	movl   $0x801540,0x802000
  800041:	15 80 00 
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
  800064:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800067:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80006a:	c1 e0 04             	shl    $0x4,%eax
  80006d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800072:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800077:	85 f6                	test   %esi,%esi
  800079:	7e 07                	jle    800082 <libmain+0x36>
		binaryname = argv[0];
  80007b:	8b 03                	mov    (%ebx),%eax
  80007d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800086:	89 34 24             	mov    %esi,(%esp)
  800089:	e8 a6 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008e:	e8 09 00 00 00       	call   80009c <exit>
}
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    
	...

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
  80011b:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  800122:	00 
  800123:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012a:	00 
  80012b:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  800132:	e8 e1 07 00 00       	call   800918 <_panic>

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
  8001ad:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  8001b4:	00 
  8001b5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001bc:	00 
  8001bd:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  8001c4:	e8 4f 07 00 00       	call   800918 <_panic>

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
  800200:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  800207:	00 
  800208:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80020f:	00 
  800210:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  800217:	e8 fc 06 00 00       	call   800918 <_panic>

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
  800253:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  80025a:	00 
  80025b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800262:	00 
  800263:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  80026a:	e8 a9 06 00 00       	call   800918 <_panic>

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
  8002a6:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  8002ad:	00 
  8002ae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b5:	00 
  8002b6:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  8002bd:	e8 56 06 00 00       	call   800918 <_panic>

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
  8002f9:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  800300:	00 
  800301:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800308:	00 
  800309:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  800310:	e8 03 06 00 00       	call   800918 <_panic>

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
  80036e:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  800375:	00 
  800376:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80037d:	00 
  80037e:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  800385:	e8 8e 05 00 00       	call   800918 <_panic>

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

00800392 <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
  800395:	57                   	push   %edi
  800396:	56                   	push   %esi
  800397:	53                   	push   %ebx
  800398:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80039b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a0:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ab:	89 df                	mov    %ebx,%edi
  8003ad:	89 de                	mov    %ebx,%esi
  8003af:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003b1:	85 c0                	test   %eax,%eax
  8003b3:	7e 28                	jle    8003dd <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003b9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003c0:	00 
  8003c1:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  8003c8:	00 
  8003c9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d0:	00 
  8003d1:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  8003d8:	e8 3b 05 00 00       	call   800918 <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8003dd:	83 c4 2c             	add    $0x2c,%esp
  8003e0:	5b                   	pop    %ebx
  8003e1:	5e                   	pop    %esi
  8003e2:	5f                   	pop    %edi
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    

008003e5 <sys_env_set_debug_upcall>:

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	57                   	push   %edi
  8003e9:	56                   	push   %esi
  8003ea:	53                   	push   %ebx
  8003eb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003f3:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8003fe:	89 df                	mov    %ebx,%edi
  800400:	89 de                	mov    %ebx,%esi
  800402:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800404:	85 c0                	test   %eax,%eax
  800406:	7e 28                	jle    800430 <sys_env_set_debug_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800408:	89 44 24 10          	mov    %eax,0x10(%esp)
  80040c:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800413:	00 
  800414:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  80041b:	00 
  80041c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800423:	00 
  800424:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  80042b:	e8 e8 04 00 00       	call   800918 <_panic>
}

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_debug_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800430:	83 c4 2c             	add    $0x2c,%esp
  800433:	5b                   	pop    %ebx
  800434:	5e                   	pop    %esi
  800435:	5f                   	pop    %edi
  800436:	5d                   	pop    %ebp
  800437:	c3                   	ret    

00800438 <sys_env_set_nmskint_upcall>:

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	57                   	push   %edi
  80043c:	56                   	push   %esi
  80043d:	53                   	push   %ebx
  80043e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800441:	bb 00 00 00 00       	mov    $0x0,%ebx
  800446:	b8 0f 00 00 00       	mov    $0xf,%eax
  80044b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80044e:	8b 55 08             	mov    0x8(%ebp),%edx
  800451:	89 df                	mov    %ebx,%edi
  800453:	89 de                	mov    %ebx,%esi
  800455:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800457:	85 c0                	test   %eax,%eax
  800459:	7e 28                	jle    800483 <sys_env_set_nmskint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80045b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80045f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800466:	00 
  800467:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  80046e:	00 
  80046f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800476:	00 
  800477:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  80047e:	e8 95 04 00 00       	call   800918 <_panic>
}

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_nmskint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800483:	83 c4 2c             	add    $0x2c,%esp
  800486:	5b                   	pop    %ebx
  800487:	5e                   	pop    %esi
  800488:	5f                   	pop    %edi
  800489:	5d                   	pop    %ebp
  80048a:	c3                   	ret    

0080048b <sys_env_set_bpoint_upcall>:

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
  80048e:	57                   	push   %edi
  80048f:	56                   	push   %esi
  800490:	53                   	push   %ebx
  800491:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800494:	bb 00 00 00 00       	mov    $0x0,%ebx
  800499:	b8 10 00 00 00       	mov    $0x10,%eax
  80049e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a4:	89 df                	mov    %ebx,%edi
  8004a6:	89 de                	mov    %ebx,%esi
  8004a8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8004aa:	85 c0                	test   %eax,%eax
  8004ac:	7e 28                	jle    8004d6 <sys_env_set_bpoint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004b2:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  8004b9:	00 
  8004ba:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  8004c1:	00 
  8004c2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004c9:	00 
  8004ca:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  8004d1:	e8 42 04 00 00       	call   800918 <_panic>
}

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bpoint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8004d6:	83 c4 2c             	add    $0x2c,%esp
  8004d9:	5b                   	pop    %ebx
  8004da:	5e                   	pop    %esi
  8004db:	5f                   	pop    %edi
  8004dc:	5d                   	pop    %ebp
  8004dd:	c3                   	ret    

008004de <sys_env_set_oflow_upcall>:

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
  8004de:	55                   	push   %ebp
  8004df:	89 e5                	mov    %esp,%ebp
  8004e1:	57                   	push   %edi
  8004e2:	56                   	push   %esi
  8004e3:	53                   	push   %ebx
  8004e4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004ec:	b8 11 00 00 00       	mov    $0x11,%eax
  8004f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004f7:	89 df                	mov    %ebx,%edi
  8004f9:	89 de                	mov    %ebx,%esi
  8004fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8004fd:	85 c0                	test   %eax,%eax
  8004ff:	7e 28                	jle    800529 <sys_env_set_oflow_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800501:	89 44 24 10          	mov    %eax,0x10(%esp)
  800505:	c7 44 24 0c 11 00 00 	movl   $0x11,0xc(%esp)
  80050c:	00 
  80050d:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  800514:	00 
  800515:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80051c:	00 
  80051d:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  800524:	e8 ef 03 00 00       	call   800918 <_panic>
}

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_oflow_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800529:	83 c4 2c             	add    $0x2c,%esp
  80052c:	5b                   	pop    %ebx
  80052d:	5e                   	pop    %esi
  80052e:	5f                   	pop    %edi
  80052f:	5d                   	pop    %ebp
  800530:	c3                   	ret    

00800531 <sys_env_set_bdschk_upcall>:

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	57                   	push   %edi
  800535:	56                   	push   %esi
  800536:	53                   	push   %ebx
  800537:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80053a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80053f:	b8 12 00 00 00       	mov    $0x12,%eax
  800544:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800547:	8b 55 08             	mov    0x8(%ebp),%edx
  80054a:	89 df                	mov    %ebx,%edi
  80054c:	89 de                	mov    %ebx,%esi
  80054e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800550:	85 c0                	test   %eax,%eax
  800552:	7e 28                	jle    80057c <sys_env_set_bdschk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800554:	89 44 24 10          	mov    %eax,0x10(%esp)
  800558:	c7 44 24 0c 12 00 00 	movl   $0x12,0xc(%esp)
  80055f:	00 
  800560:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  800567:	00 
  800568:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80056f:	00 
  800570:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  800577:	e8 9c 03 00 00       	call   800918 <_panic>
}

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bdschk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80057c:	83 c4 2c             	add    $0x2c,%esp
  80057f:	5b                   	pop    %ebx
  800580:	5e                   	pop    %esi
  800581:	5f                   	pop    %edi
  800582:	5d                   	pop    %ebp
  800583:	c3                   	ret    

00800584 <sys_env_set_illopcd_upcall>:

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
  800584:	55                   	push   %ebp
  800585:	89 e5                	mov    %esp,%ebp
  800587:	57                   	push   %edi
  800588:	56                   	push   %esi
  800589:	53                   	push   %ebx
  80058a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80058d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800592:	b8 13 00 00 00       	mov    $0x13,%eax
  800597:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80059a:	8b 55 08             	mov    0x8(%ebp),%edx
  80059d:	89 df                	mov    %ebx,%edi
  80059f:	89 de                	mov    %ebx,%esi
  8005a1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005a3:	85 c0                	test   %eax,%eax
  8005a5:	7e 28                	jle    8005cf <sys_env_set_illopcd_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005ab:	c7 44 24 0c 13 00 00 	movl   $0x13,0xc(%esp)
  8005b2:	00 
  8005b3:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  8005ba:	00 
  8005bb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005c2:	00 
  8005c3:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  8005ca:	e8 49 03 00 00       	call   800918 <_panic>
}

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_illopcd_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8005cf:	83 c4 2c             	add    $0x2c,%esp
  8005d2:	5b                   	pop    %ebx
  8005d3:	5e                   	pop    %esi
  8005d4:	5f                   	pop    %edi
  8005d5:	5d                   	pop    %ebp
  8005d6:	c3                   	ret    

008005d7 <sys_env_set_dvcntavl_upcall>:

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
  8005d7:	55                   	push   %ebp
  8005d8:	89 e5                	mov    %esp,%ebp
  8005da:	57                   	push   %edi
  8005db:	56                   	push   %esi
  8005dc:	53                   	push   %ebx
  8005dd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005e5:	b8 14 00 00 00       	mov    $0x14,%eax
  8005ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8005f0:	89 df                	mov    %ebx,%edi
  8005f2:	89 de                	mov    %ebx,%esi
  8005f4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005f6:	85 c0                	test   %eax,%eax
  8005f8:	7e 28                	jle    800622 <sys_env_set_dvcntavl_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005fe:	c7 44 24 0c 14 00 00 	movl   $0x14,0xc(%esp)
  800605:	00 
  800606:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  80060d:	00 
  80060e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800615:	00 
  800616:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  80061d:	e8 f6 02 00 00       	call   800918 <_panic>
}

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dvcntavl_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800622:	83 c4 2c             	add    $0x2c,%esp
  800625:	5b                   	pop    %ebx
  800626:	5e                   	pop    %esi
  800627:	5f                   	pop    %edi
  800628:	5d                   	pop    %ebp
  800629:	c3                   	ret    

0080062a <sys_env_set_dbfault_upcall>:

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
  80062a:	55                   	push   %ebp
  80062b:	89 e5                	mov    %esp,%ebp
  80062d:	57                   	push   %edi
  80062e:	56                   	push   %esi
  80062f:	53                   	push   %ebx
  800630:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800633:	bb 00 00 00 00       	mov    $0x0,%ebx
  800638:	b8 15 00 00 00       	mov    $0x15,%eax
  80063d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800640:	8b 55 08             	mov    0x8(%ebp),%edx
  800643:	89 df                	mov    %ebx,%edi
  800645:	89 de                	mov    %ebx,%esi
  800647:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800649:	85 c0                	test   %eax,%eax
  80064b:	7e 28                	jle    800675 <sys_env_set_dbfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80064d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800651:	c7 44 24 0c 15 00 00 	movl   $0x15,0xc(%esp)
  800658:	00 
  800659:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  800660:	00 
  800661:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800668:	00 
  800669:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  800670:	e8 a3 02 00 00       	call   800918 <_panic>
}

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dbfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800675:	83 c4 2c             	add    $0x2c,%esp
  800678:	5b                   	pop    %ebx
  800679:	5e                   	pop    %esi
  80067a:	5f                   	pop    %edi
  80067b:	5d                   	pop    %ebp
  80067c:	c3                   	ret    

0080067d <sys_env_set_ivldtss_upcall>:

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	57                   	push   %edi
  800681:	56                   	push   %esi
  800682:	53                   	push   %ebx
  800683:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800686:	bb 00 00 00 00       	mov    $0x0,%ebx
  80068b:	b8 16 00 00 00       	mov    $0x16,%eax
  800690:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800693:	8b 55 08             	mov    0x8(%ebp),%edx
  800696:	89 df                	mov    %ebx,%edi
  800698:	89 de                	mov    %ebx,%esi
  80069a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80069c:	85 c0                	test   %eax,%eax
  80069e:	7e 28                	jle    8006c8 <sys_env_set_ivldtss_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006a4:	c7 44 24 0c 16 00 00 	movl   $0x16,0xc(%esp)
  8006ab:	00 
  8006ac:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  8006b3:	00 
  8006b4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006bb:	00 
  8006bc:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  8006c3:	e8 50 02 00 00       	call   800918 <_panic>
}

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_ivldtss_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8006c8:	83 c4 2c             	add    $0x2c,%esp
  8006cb:	5b                   	pop    %ebx
  8006cc:	5e                   	pop    %esi
  8006cd:	5f                   	pop    %edi
  8006ce:	5d                   	pop    %ebp
  8006cf:	c3                   	ret    

008006d0 <sys_env_set_segntprst_upcall>:

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	57                   	push   %edi
  8006d4:	56                   	push   %esi
  8006d5:	53                   	push   %ebx
  8006d6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006de:	b8 17 00 00 00       	mov    $0x17,%eax
  8006e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e9:	89 df                	mov    %ebx,%edi
  8006eb:	89 de                	mov    %ebx,%esi
  8006ed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	7e 28                	jle    80071b <sys_env_set_segntprst_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006f3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006f7:	c7 44 24 0c 17 00 00 	movl   $0x17,0xc(%esp)
  8006fe:	00 
  8006ff:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  800706:	00 
  800707:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80070e:	00 
  80070f:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  800716:	e8 fd 01 00 00       	call   800918 <_panic>
}

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_segntprst_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80071b:	83 c4 2c             	add    $0x2c,%esp
  80071e:	5b                   	pop    %ebx
  80071f:	5e                   	pop    %esi
  800720:	5f                   	pop    %edi
  800721:	5d                   	pop    %ebp
  800722:	c3                   	ret    

00800723 <sys_env_set_stkexception_upcall>:

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	57                   	push   %edi
  800727:	56                   	push   %esi
  800728:	53                   	push   %ebx
  800729:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80072c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800731:	b8 18 00 00 00       	mov    $0x18,%eax
  800736:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800739:	8b 55 08             	mov    0x8(%ebp),%edx
  80073c:	89 df                	mov    %ebx,%edi
  80073e:	89 de                	mov    %ebx,%esi
  800740:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800742:	85 c0                	test   %eax,%eax
  800744:	7e 28                	jle    80076e <sys_env_set_stkexception_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800746:	89 44 24 10          	mov    %eax,0x10(%esp)
  80074a:	c7 44 24 0c 18 00 00 	movl   $0x18,0xc(%esp)
  800751:	00 
  800752:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  800759:	00 
  80075a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800761:	00 
  800762:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  800769:	e8 aa 01 00 00       	call   800918 <_panic>
}

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_stkexception_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80076e:	83 c4 2c             	add    $0x2c,%esp
  800771:	5b                   	pop    %ebx
  800772:	5e                   	pop    %esi
  800773:	5f                   	pop    %edi
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <sys_env_set_gpfault_upcall>:

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	57                   	push   %edi
  80077a:	56                   	push   %esi
  80077b:	53                   	push   %ebx
  80077c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80077f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800784:	b8 19 00 00 00       	mov    $0x19,%eax
  800789:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078c:	8b 55 08             	mov    0x8(%ebp),%edx
  80078f:	89 df                	mov    %ebx,%edi
  800791:	89 de                	mov    %ebx,%esi
  800793:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800795:	85 c0                	test   %eax,%eax
  800797:	7e 28                	jle    8007c1 <sys_env_set_gpfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800799:	89 44 24 10          	mov    %eax,0x10(%esp)
  80079d:	c7 44 24 0c 19 00 00 	movl   $0x19,0xc(%esp)
  8007a4:	00 
  8007a5:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  8007ac:	00 
  8007ad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8007b4:	00 
  8007b5:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  8007bc:	e8 57 01 00 00       	call   800918 <_panic>
}

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_gpfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8007c1:	83 c4 2c             	add    $0x2c,%esp
  8007c4:	5b                   	pop    %ebx
  8007c5:	5e                   	pop    %esi
  8007c6:	5f                   	pop    %edi
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <sys_env_set_fperror_upcall>:

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	57                   	push   %edi
  8007cd:	56                   	push   %esi
  8007ce:	53                   	push   %ebx
  8007cf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007d7:	b8 1a 00 00 00       	mov    $0x1a,%eax
  8007dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007df:	8b 55 08             	mov    0x8(%ebp),%edx
  8007e2:	89 df                	mov    %ebx,%edi
  8007e4:	89 de                	mov    %ebx,%esi
  8007e6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8007e8:	85 c0                	test   %eax,%eax
  8007ea:	7e 28                	jle    800814 <sys_env_set_fperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007ec:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007f0:	c7 44 24 0c 1a 00 00 	movl   $0x1a,0xc(%esp)
  8007f7:	00 
  8007f8:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  8007ff:	00 
  800800:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800807:	00 
  800808:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  80080f:	e8 04 01 00 00       	call   800918 <_panic>
}

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_fperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800814:	83 c4 2c             	add    $0x2c,%esp
  800817:	5b                   	pop    %ebx
  800818:	5e                   	pop    %esi
  800819:	5f                   	pop    %edi
  80081a:	5d                   	pop    %ebp
  80081b:	c3                   	ret    

0080081c <sys_env_set_algchk_upcall>:

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	57                   	push   %edi
  800820:	56                   	push   %esi
  800821:	53                   	push   %ebx
  800822:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800825:	bb 00 00 00 00       	mov    $0x0,%ebx
  80082a:	b8 1b 00 00 00       	mov    $0x1b,%eax
  80082f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800832:	8b 55 08             	mov    0x8(%ebp),%edx
  800835:	89 df                	mov    %ebx,%edi
  800837:	89 de                	mov    %ebx,%esi
  800839:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80083b:	85 c0                	test   %eax,%eax
  80083d:	7e 28                	jle    800867 <sys_env_set_algchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80083f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800843:	c7 44 24 0c 1b 00 00 	movl   $0x1b,0xc(%esp)
  80084a:	00 
  80084b:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  800852:	00 
  800853:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80085a:	00 
  80085b:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  800862:	e8 b1 00 00 00       	call   800918 <_panic>
}

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_algchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800867:	83 c4 2c             	add    $0x2c,%esp
  80086a:	5b                   	pop    %ebx
  80086b:	5e                   	pop    %esi
  80086c:	5f                   	pop    %edi
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <sys_env_set_mchchk_upcall>:

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	57                   	push   %edi
  800873:	56                   	push   %esi
  800874:	53                   	push   %ebx
  800875:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800878:	bb 00 00 00 00       	mov    $0x0,%ebx
  80087d:	b8 1c 00 00 00       	mov    $0x1c,%eax
  800882:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800885:	8b 55 08             	mov    0x8(%ebp),%edx
  800888:	89 df                	mov    %ebx,%edi
  80088a:	89 de                	mov    %ebx,%esi
  80088c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80088e:	85 c0                	test   %eax,%eax
  800890:	7e 28                	jle    8008ba <sys_env_set_mchchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800892:	89 44 24 10          	mov    %eax,0x10(%esp)
  800896:	c7 44 24 0c 1c 00 00 	movl   $0x1c,0xc(%esp)
  80089d:	00 
  80089e:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  8008a5:	00 
  8008a6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8008ad:	00 
  8008ae:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  8008b5:	e8 5e 00 00 00       	call   800918 <_panic>
}

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_mchchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8008ba:	83 c4 2c             	add    $0x2c,%esp
  8008bd:	5b                   	pop    %ebx
  8008be:	5e                   	pop    %esi
  8008bf:	5f                   	pop    %edi
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <sys_env_set_SIMDfperror_upcall>:

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	57                   	push   %edi
  8008c6:	56                   	push   %esi
  8008c7:	53                   	push   %ebx
  8008c8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8008cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008d0:	b8 1d 00 00 00       	mov    $0x1d,%eax
  8008d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8008db:	89 df                	mov    %ebx,%edi
  8008dd:	89 de                	mov    %ebx,%esi
  8008df:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8008e1:	85 c0                	test   %eax,%eax
  8008e3:	7e 28                	jle    80090d <sys_env_set_SIMDfperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8008e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8008e9:	c7 44 24 0c 1d 00 00 	movl   $0x1d,0xc(%esp)
  8008f0:	00 
  8008f1:	c7 44 24 08 4f 15 80 	movl   $0x80154f,0x8(%esp)
  8008f8:	00 
  8008f9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800900:	00 
  800901:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  800908:	e8 0b 00 00 00       	call   800918 <_panic>
}

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_SIMDfperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80090d:	83 c4 2c             	add    $0x2c,%esp
  800910:	5b                   	pop    %ebx
  800911:	5e                   	pop    %esi
  800912:	5f                   	pop    %edi
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    
  800915:	00 00                	add    %al,(%eax)
	...

00800918 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	56                   	push   %esi
  80091c:	53                   	push   %ebx
  80091d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800920:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800923:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800929:	e8 11 f8 ff ff       	call   80013f <sys_getenvid>
  80092e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800931:	89 54 24 10          	mov    %edx,0x10(%esp)
  800935:	8b 55 08             	mov    0x8(%ebp),%edx
  800938:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80093c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800940:	89 44 24 04          	mov    %eax,0x4(%esp)
  800944:	c7 04 24 7c 15 80 00 	movl   $0x80157c,(%esp)
  80094b:	e8 c0 00 00 00       	call   800a10 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800950:	89 74 24 04          	mov    %esi,0x4(%esp)
  800954:	8b 45 10             	mov    0x10(%ebp),%eax
  800957:	89 04 24             	mov    %eax,(%esp)
  80095a:	e8 50 00 00 00       	call   8009af <vcprintf>
	cprintf("\n");
  80095f:	c7 04 24 a0 15 80 00 	movl   $0x8015a0,(%esp)
  800966:	e8 a5 00 00 00       	call   800a10 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80096b:	cc                   	int3   
  80096c:	eb fd                	jmp    80096b <_panic+0x53>
	...

00800970 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	53                   	push   %ebx
  800974:	83 ec 14             	sub    $0x14,%esp
  800977:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80097a:	8b 03                	mov    (%ebx),%eax
  80097c:	8b 55 08             	mov    0x8(%ebp),%edx
  80097f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800983:	40                   	inc    %eax
  800984:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800986:	3d ff 00 00 00       	cmp    $0xff,%eax
  80098b:	75 19                	jne    8009a6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80098d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800994:	00 
  800995:	8d 43 08             	lea    0x8(%ebx),%eax
  800998:	89 04 24             	mov    %eax,(%esp)
  80099b:	e8 10 f7 ff ff       	call   8000b0 <sys_cputs>
		b->idx = 0;
  8009a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8009a6:	ff 43 04             	incl   0x4(%ebx)
}
  8009a9:	83 c4 14             	add    $0x14,%esp
  8009ac:	5b                   	pop    %ebx
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8009b8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8009bf:	00 00 00 
	b.cnt = 0;
  8009c2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8009c9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8009cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009da:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8009e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e4:	c7 04 24 70 09 80 00 	movl   $0x800970,(%esp)
  8009eb:	e8 b4 01 00 00       	call   800ba4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8009f0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8009f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800a00:	89 04 24             	mov    %eax,(%esp)
  800a03:	e8 a8 f6 ff ff       	call   8000b0 <sys_cputs>

	return b.cnt;
}
  800a08:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800a0e:	c9                   	leave  
  800a0f:	c3                   	ret    

00800a10 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800a16:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800a19:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	89 04 24             	mov    %eax,(%esp)
  800a23:	e8 87 ff ff ff       	call   8009af <vcprintf>
	va_end(ap);

	return cnt;
}
  800a28:	c9                   	leave  
  800a29:	c3                   	ret    
	...

00800a2c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	57                   	push   %edi
  800a30:	56                   	push   %esi
  800a31:	53                   	push   %ebx
  800a32:	83 ec 3c             	sub    $0x3c,%esp
  800a35:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a38:	89 d7                	mov    %edx,%edi
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a43:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a46:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800a49:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800a4c:	85 c0                	test   %eax,%eax
  800a4e:	75 08                	jne    800a58 <printnum+0x2c>
  800a50:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a53:	39 45 10             	cmp    %eax,0x10(%ebp)
  800a56:	77 57                	ja     800aaf <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800a58:	89 74 24 10          	mov    %esi,0x10(%esp)
  800a5c:	4b                   	dec    %ebx
  800a5d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800a61:	8b 45 10             	mov    0x10(%ebp),%eax
  800a64:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a68:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800a6c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800a70:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a77:	00 
  800a78:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a7b:	89 04 24             	mov    %eax,(%esp)
  800a7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a85:	e8 5a 08 00 00       	call   8012e4 <__udivdi3>
  800a8a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a8e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a92:	89 04 24             	mov    %eax,(%esp)
  800a95:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a99:	89 fa                	mov    %edi,%edx
  800a9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a9e:	e8 89 ff ff ff       	call   800a2c <printnum>
  800aa3:	eb 0f                	jmp    800ab4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800aa5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aa9:	89 34 24             	mov    %esi,(%esp)
  800aac:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800aaf:	4b                   	dec    %ebx
  800ab0:	85 db                	test   %ebx,%ebx
  800ab2:	7f f1                	jg     800aa5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800ab4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ab8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800abc:	8b 45 10             	mov    0x10(%ebp),%eax
  800abf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ac3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800aca:	00 
  800acb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ace:	89 04 24             	mov    %eax,(%esp)
  800ad1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ad4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad8:	e8 27 09 00 00       	call   801404 <__umoddi3>
  800add:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ae1:	0f be 80 a2 15 80 00 	movsbl 0x8015a2(%eax),%eax
  800ae8:	89 04 24             	mov    %eax,(%esp)
  800aeb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800aee:	83 c4 3c             	add    $0x3c,%esp
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800af9:	83 fa 01             	cmp    $0x1,%edx
  800afc:	7e 0e                	jle    800b0c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800afe:	8b 10                	mov    (%eax),%edx
  800b00:	8d 4a 08             	lea    0x8(%edx),%ecx
  800b03:	89 08                	mov    %ecx,(%eax)
  800b05:	8b 02                	mov    (%edx),%eax
  800b07:	8b 52 04             	mov    0x4(%edx),%edx
  800b0a:	eb 22                	jmp    800b2e <getuint+0x38>
	else if (lflag)
  800b0c:	85 d2                	test   %edx,%edx
  800b0e:	74 10                	je     800b20 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800b10:	8b 10                	mov    (%eax),%edx
  800b12:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b15:	89 08                	mov    %ecx,(%eax)
  800b17:	8b 02                	mov    (%edx),%eax
  800b19:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1e:	eb 0e                	jmp    800b2e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800b20:	8b 10                	mov    (%eax),%edx
  800b22:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b25:	89 08                	mov    %ecx,(%eax)
  800b27:	8b 02                	mov    (%edx),%eax
  800b29:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800b33:	83 fa 01             	cmp    $0x1,%edx
  800b36:	7e 0e                	jle    800b46 <getint+0x16>
		return va_arg(*ap, long long);
  800b38:	8b 10                	mov    (%eax),%edx
  800b3a:	8d 4a 08             	lea    0x8(%edx),%ecx
  800b3d:	89 08                	mov    %ecx,(%eax)
  800b3f:	8b 02                	mov    (%edx),%eax
  800b41:	8b 52 04             	mov    0x4(%edx),%edx
  800b44:	eb 1a                	jmp    800b60 <getint+0x30>
	else if (lflag)
  800b46:	85 d2                	test   %edx,%edx
  800b48:	74 0c                	je     800b56 <getint+0x26>
		return va_arg(*ap, long);
  800b4a:	8b 10                	mov    (%eax),%edx
  800b4c:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b4f:	89 08                	mov    %ecx,(%eax)
  800b51:	8b 02                	mov    (%edx),%eax
  800b53:	99                   	cltd   
  800b54:	eb 0a                	jmp    800b60 <getint+0x30>
	else
		return va_arg(*ap, int);
  800b56:	8b 10                	mov    (%eax),%edx
  800b58:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b5b:	89 08                	mov    %ecx,(%eax)
  800b5d:	8b 02                	mov    (%edx),%eax
  800b5f:	99                   	cltd   
}
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800b68:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800b6b:	8b 10                	mov    (%eax),%edx
  800b6d:	3b 50 04             	cmp    0x4(%eax),%edx
  800b70:	73 08                	jae    800b7a <sprintputch+0x18>
		*b->buf++ = ch;
  800b72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b75:	88 0a                	mov    %cl,(%edx)
  800b77:	42                   	inc    %edx
  800b78:	89 10                	mov    %edx,(%eax)
}
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800b82:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800b85:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b89:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b93:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b97:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9a:	89 04 24             	mov    %eax,(%esp)
  800b9d:	e8 02 00 00 00       	call   800ba4 <vprintfmt>
	va_end(ap);
}
  800ba2:	c9                   	leave  
  800ba3:	c3                   	ret    

00800ba4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
  800baa:	83 ec 4c             	sub    $0x4c,%esp
  800bad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bb0:	8b 75 10             	mov    0x10(%ebp),%esi
  800bb3:	eb 12                	jmp    800bc7 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800bb5:	85 c0                	test   %eax,%eax
  800bb7:	0f 84 40 03 00 00    	je     800efd <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800bbd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bc1:	89 04 24             	mov    %eax,(%esp)
  800bc4:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800bc7:	0f b6 06             	movzbl (%esi),%eax
  800bca:	46                   	inc    %esi
  800bcb:	83 f8 25             	cmp    $0x25,%eax
  800bce:	75 e5                	jne    800bb5 <vprintfmt+0x11>
  800bd0:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800bd4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800bdb:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800be0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800be7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bec:	eb 26                	jmp    800c14 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bee:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800bf1:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800bf5:	eb 1d                	jmp    800c14 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bf7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800bfa:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800bfe:	eb 14                	jmp    800c14 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c00:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800c03:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800c0a:	eb 08                	jmp    800c14 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800c0c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800c0f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c14:	0f b6 06             	movzbl (%esi),%eax
  800c17:	8d 4e 01             	lea    0x1(%esi),%ecx
  800c1a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800c1d:	8a 0e                	mov    (%esi),%cl
  800c1f:	83 e9 23             	sub    $0x23,%ecx
  800c22:	80 f9 55             	cmp    $0x55,%cl
  800c25:	0f 87 b6 02 00 00    	ja     800ee1 <vprintfmt+0x33d>
  800c2b:	0f b6 c9             	movzbl %cl,%ecx
  800c2e:	ff 24 8d 60 16 80 00 	jmp    *0x801660(,%ecx,4)
  800c35:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c38:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800c3d:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800c40:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  800c44:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800c47:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800c4a:	83 f9 09             	cmp    $0x9,%ecx
  800c4d:	77 2a                	ja     800c79 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c4f:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800c50:	eb eb                	jmp    800c3d <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800c52:	8b 45 14             	mov    0x14(%ebp),%eax
  800c55:	8d 48 04             	lea    0x4(%eax),%ecx
  800c58:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800c5b:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c5d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800c60:	eb 17                	jmp    800c79 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800c62:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c66:	78 98                	js     800c00 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c68:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c6b:	eb a7                	jmp    800c14 <vprintfmt+0x70>
  800c6d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800c70:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800c77:	eb 9b                	jmp    800c14 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800c79:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c7d:	79 95                	jns    800c14 <vprintfmt+0x70>
  800c7f:	eb 8b                	jmp    800c0c <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800c81:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c82:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800c85:	eb 8d                	jmp    800c14 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800c87:	8b 45 14             	mov    0x14(%ebp),%eax
  800c8a:	8d 50 04             	lea    0x4(%eax),%edx
  800c8d:	89 55 14             	mov    %edx,0x14(%ebp)
  800c90:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c94:	8b 00                	mov    (%eax),%eax
  800c96:	89 04 24             	mov    %eax,(%esp)
  800c99:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c9c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800c9f:	e9 23 ff ff ff       	jmp    800bc7 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800ca4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ca7:	8d 50 04             	lea    0x4(%eax),%edx
  800caa:	89 55 14             	mov    %edx,0x14(%ebp)
  800cad:	8b 00                	mov    (%eax),%eax
  800caf:	85 c0                	test   %eax,%eax
  800cb1:	79 02                	jns    800cb5 <vprintfmt+0x111>
  800cb3:	f7 d8                	neg    %eax
  800cb5:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800cb7:	83 f8 09             	cmp    $0x9,%eax
  800cba:	7f 0b                	jg     800cc7 <vprintfmt+0x123>
  800cbc:	8b 04 85 c0 17 80 00 	mov    0x8017c0(,%eax,4),%eax
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	75 23                	jne    800cea <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800cc7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ccb:	c7 44 24 08 ba 15 80 	movl   $0x8015ba,0x8(%esp)
  800cd2:	00 
  800cd3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cda:	89 04 24             	mov    %eax,(%esp)
  800cdd:	e8 9a fe ff ff       	call   800b7c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ce2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800ce5:	e9 dd fe ff ff       	jmp    800bc7 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800cea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cee:	c7 44 24 08 c3 15 80 	movl   $0x8015c3,0x8(%esp)
  800cf5:	00 
  800cf6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	89 14 24             	mov    %edx,(%esp)
  800d00:	e8 77 fe ff ff       	call   800b7c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d05:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d08:	e9 ba fe ff ff       	jmp    800bc7 <vprintfmt+0x23>
  800d0d:	89 f9                	mov    %edi,%ecx
  800d0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d12:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d15:	8b 45 14             	mov    0x14(%ebp),%eax
  800d18:	8d 50 04             	lea    0x4(%eax),%edx
  800d1b:	89 55 14             	mov    %edx,0x14(%ebp)
  800d1e:	8b 30                	mov    (%eax),%esi
  800d20:	85 f6                	test   %esi,%esi
  800d22:	75 05                	jne    800d29 <vprintfmt+0x185>
				p = "(null)";
  800d24:	be b3 15 80 00       	mov    $0x8015b3,%esi
			if (width > 0 && padc != '-')
  800d29:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800d2d:	0f 8e 84 00 00 00    	jle    800db7 <vprintfmt+0x213>
  800d33:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800d37:	74 7e                	je     800db7 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800d39:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d3d:	89 34 24             	mov    %esi,(%esp)
  800d40:	e8 5d 02 00 00       	call   800fa2 <strnlen>
  800d45:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800d48:	29 c2                	sub    %eax,%edx
  800d4a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800d4d:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800d51:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800d54:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800d57:	89 de                	mov    %ebx,%esi
  800d59:	89 d3                	mov    %edx,%ebx
  800d5b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d5d:	eb 0b                	jmp    800d6a <vprintfmt+0x1c6>
					putch(padc, putdat);
  800d5f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d63:	89 3c 24             	mov    %edi,(%esp)
  800d66:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d69:	4b                   	dec    %ebx
  800d6a:	85 db                	test   %ebx,%ebx
  800d6c:	7f f1                	jg     800d5f <vprintfmt+0x1bb>
  800d6e:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800d71:	89 f3                	mov    %esi,%ebx
  800d73:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800d76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	79 05                	jns    800d82 <vprintfmt+0x1de>
  800d7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d82:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d85:	29 c2                	sub    %eax,%edx
  800d87:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800d8a:	eb 2b                	jmp    800db7 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800d8c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800d90:	74 18                	je     800daa <vprintfmt+0x206>
  800d92:	8d 50 e0             	lea    -0x20(%eax),%edx
  800d95:	83 fa 5e             	cmp    $0x5e,%edx
  800d98:	76 10                	jbe    800daa <vprintfmt+0x206>
					putch('?', putdat);
  800d9a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d9e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800da5:	ff 55 08             	call   *0x8(%ebp)
  800da8:	eb 0a                	jmp    800db4 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800daa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dae:	89 04 24             	mov    %eax,(%esp)
  800db1:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800db4:	ff 4d e4             	decl   -0x1c(%ebp)
  800db7:	0f be 06             	movsbl (%esi),%eax
  800dba:	46                   	inc    %esi
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	74 21                	je     800de0 <vprintfmt+0x23c>
  800dbf:	85 ff                	test   %edi,%edi
  800dc1:	78 c9                	js     800d8c <vprintfmt+0x1e8>
  800dc3:	4f                   	dec    %edi
  800dc4:	79 c6                	jns    800d8c <vprintfmt+0x1e8>
  800dc6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dc9:	89 de                	mov    %ebx,%esi
  800dcb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800dce:	eb 18                	jmp    800de8 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800dd0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dd4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800ddb:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ddd:	4b                   	dec    %ebx
  800dde:	eb 08                	jmp    800de8 <vprintfmt+0x244>
  800de0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800de3:	89 de                	mov    %ebx,%esi
  800de5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800de8:	85 db                	test   %ebx,%ebx
  800dea:	7f e4                	jg     800dd0 <vprintfmt+0x22c>
  800dec:	89 7d 08             	mov    %edi,0x8(%ebp)
  800def:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800df1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800df4:	e9 ce fd ff ff       	jmp    800bc7 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800df9:	8d 45 14             	lea    0x14(%ebp),%eax
  800dfc:	e8 2f fd ff ff       	call   800b30 <getint>
  800e01:	89 c6                	mov    %eax,%esi
  800e03:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800e05:	85 d2                	test   %edx,%edx
  800e07:	78 07                	js     800e10 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800e09:	be 0a 00 00 00       	mov    $0xa,%esi
  800e0e:	eb 7e                	jmp    800e8e <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800e10:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e14:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800e1b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800e1e:	89 f0                	mov    %esi,%eax
  800e20:	89 fa                	mov    %edi,%edx
  800e22:	f7 d8                	neg    %eax
  800e24:	83 d2 00             	adc    $0x0,%edx
  800e27:	f7 da                	neg    %edx
			}
			base = 10;
  800e29:	be 0a 00 00 00       	mov    $0xa,%esi
  800e2e:	eb 5e                	jmp    800e8e <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800e30:	8d 45 14             	lea    0x14(%ebp),%eax
  800e33:	e8 be fc ff ff       	call   800af6 <getuint>
			base = 10;
  800e38:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800e3d:	eb 4f                	jmp    800e8e <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800e3f:	8d 45 14             	lea    0x14(%ebp),%eax
  800e42:	e8 af fc ff ff       	call   800af6 <getuint>
			base = 8;
  800e47:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800e4c:	eb 40                	jmp    800e8e <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  800e4e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e52:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800e59:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800e5c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e60:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800e67:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800e6a:	8b 45 14             	mov    0x14(%ebp),%eax
  800e6d:	8d 50 04             	lea    0x4(%eax),%edx
  800e70:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800e73:	8b 00                	mov    (%eax),%eax
  800e75:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800e7a:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800e7f:	eb 0d                	jmp    800e8e <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800e81:	8d 45 14             	lea    0x14(%ebp),%eax
  800e84:	e8 6d fc ff ff       	call   800af6 <getuint>
			base = 16;
  800e89:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800e8e:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800e92:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800e96:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800e99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e9d:	89 74 24 08          	mov    %esi,0x8(%esp)
  800ea1:	89 04 24             	mov    %eax,(%esp)
  800ea4:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ea8:	89 da                	mov    %ebx,%edx
  800eaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800ead:	e8 7a fb ff ff       	call   800a2c <printnum>
			break;
  800eb2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800eb5:	e9 0d fd ff ff       	jmp    800bc7 <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  800eba:	8d 45 14             	lea    0x14(%ebp),%eax
  800ebd:	e8 6e fc ff ff       	call   800b30 <getint>
  800ec2:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ec7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  800eca:	e9 f8 fc ff ff       	jmp    800bc7 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ecf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ed3:	89 04 24             	mov    %eax,(%esp)
  800ed6:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ed9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800edc:	e9 e6 fc ff ff       	jmp    800bc7 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ee1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ee5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800eec:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800eef:	eb 01                	jmp    800ef2 <vprintfmt+0x34e>
  800ef1:	4e                   	dec    %esi
  800ef2:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800ef6:	75 f9                	jne    800ef1 <vprintfmt+0x34d>
  800ef8:	e9 ca fc ff ff       	jmp    800bc7 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800efd:	83 c4 4c             	add    $0x4c,%esp
  800f00:	5b                   	pop    %ebx
  800f01:	5e                   	pop    %esi
  800f02:	5f                   	pop    %edi
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	83 ec 28             	sub    $0x28,%esp
  800f0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800f11:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f14:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800f18:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800f22:	85 c0                	test   %eax,%eax
  800f24:	74 30                	je     800f56 <vsnprintf+0x51>
  800f26:	85 d2                	test   %edx,%edx
  800f28:	7e 33                	jle    800f5d <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f2a:	8b 45 14             	mov    0x14(%ebp),%eax
  800f2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f31:	8b 45 10             	mov    0x10(%ebp),%eax
  800f34:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f38:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f3f:	c7 04 24 62 0b 80 00 	movl   $0x800b62,(%esp)
  800f46:	e8 59 fc ff ff       	call   800ba4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f4e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f54:	eb 0c                	jmp    800f62 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800f56:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f5b:	eb 05                	jmp    800f62 <vsnprintf+0x5d>
  800f5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800f62:	c9                   	leave  
  800f63:	c3                   	ret    

00800f64 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800f6a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800f6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f71:	8b 45 10             	mov    0x10(%ebp),%eax
  800f74:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f82:	89 04 24             	mov    %eax,(%esp)
  800f85:	e8 7b ff ff ff       	call   800f05 <vsnprintf>
	va_end(ap);

	return rc;
}
  800f8a:	c9                   	leave  
  800f8b:	c3                   	ret    

00800f8c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800f92:	b8 00 00 00 00       	mov    $0x0,%eax
  800f97:	eb 01                	jmp    800f9a <strlen+0xe>
		n++;
  800f99:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800f9a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800f9e:	75 f9                	jne    800f99 <strlen+0xd>
		n++;
	return n;
}
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    

00800fa2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800fa8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fab:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb0:	eb 01                	jmp    800fb3 <strnlen+0x11>
		n++;
  800fb2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fb3:	39 d0                	cmp    %edx,%eax
  800fb5:	74 06                	je     800fbd <strnlen+0x1b>
  800fb7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800fbb:	75 f5                	jne    800fb2 <strnlen+0x10>
		n++;
	return n;
}
  800fbd:	5d                   	pop    %ebp
  800fbe:	c3                   	ret    

00800fbf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	53                   	push   %ebx
  800fc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800fc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800fce:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800fd1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800fd4:	42                   	inc    %edx
  800fd5:	84 c9                	test   %cl,%cl
  800fd7:	75 f5                	jne    800fce <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800fd9:	5b                   	pop    %ebx
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <strcat>:

char *
strcat(char *dst, const char *src)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	53                   	push   %ebx
  800fe0:	83 ec 08             	sub    $0x8,%esp
  800fe3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800fe6:	89 1c 24             	mov    %ebx,(%esp)
  800fe9:	e8 9e ff ff ff       	call   800f8c <strlen>
	strcpy(dst + len, src);
  800fee:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ff1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ff5:	01 d8                	add    %ebx,%eax
  800ff7:	89 04 24             	mov    %eax,(%esp)
  800ffa:	e8 c0 ff ff ff       	call   800fbf <strcpy>
	return dst;
}
  800fff:	89 d8                	mov    %ebx,%eax
  801001:	83 c4 08             	add    $0x8,%esp
  801004:	5b                   	pop    %ebx
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    

00801007 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	56                   	push   %esi
  80100b:	53                   	push   %ebx
  80100c:	8b 45 08             	mov    0x8(%ebp),%eax
  80100f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801012:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801015:	b9 00 00 00 00       	mov    $0x0,%ecx
  80101a:	eb 0c                	jmp    801028 <strncpy+0x21>
		*dst++ = *src;
  80101c:	8a 1a                	mov    (%edx),%bl
  80101e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801021:	80 3a 01             	cmpb   $0x1,(%edx)
  801024:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801027:	41                   	inc    %ecx
  801028:	39 f1                	cmp    %esi,%ecx
  80102a:	75 f0                	jne    80101c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80102c:	5b                   	pop    %ebx
  80102d:	5e                   	pop    %esi
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    

00801030 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	56                   	push   %esi
  801034:	53                   	push   %ebx
  801035:	8b 75 08             	mov    0x8(%ebp),%esi
  801038:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80103e:	85 d2                	test   %edx,%edx
  801040:	75 0a                	jne    80104c <strlcpy+0x1c>
  801042:	89 f0                	mov    %esi,%eax
  801044:	eb 1a                	jmp    801060 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801046:	88 18                	mov    %bl,(%eax)
  801048:	40                   	inc    %eax
  801049:	41                   	inc    %ecx
  80104a:	eb 02                	jmp    80104e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80104c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80104e:	4a                   	dec    %edx
  80104f:	74 0a                	je     80105b <strlcpy+0x2b>
  801051:	8a 19                	mov    (%ecx),%bl
  801053:	84 db                	test   %bl,%bl
  801055:	75 ef                	jne    801046 <strlcpy+0x16>
  801057:	89 c2                	mov    %eax,%edx
  801059:	eb 02                	jmp    80105d <strlcpy+0x2d>
  80105b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80105d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801060:	29 f0                	sub    %esi,%eax
}
  801062:	5b                   	pop    %ebx
  801063:	5e                   	pop    %esi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80106c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80106f:	eb 02                	jmp    801073 <strcmp+0xd>
		p++, q++;
  801071:	41                   	inc    %ecx
  801072:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801073:	8a 01                	mov    (%ecx),%al
  801075:	84 c0                	test   %al,%al
  801077:	74 04                	je     80107d <strcmp+0x17>
  801079:	3a 02                	cmp    (%edx),%al
  80107b:	74 f4                	je     801071 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80107d:	0f b6 c0             	movzbl %al,%eax
  801080:	0f b6 12             	movzbl (%edx),%edx
  801083:	29 d0                	sub    %edx,%eax
}
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    

00801087 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	53                   	push   %ebx
  80108b:	8b 45 08             	mov    0x8(%ebp),%eax
  80108e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801091:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801094:	eb 03                	jmp    801099 <strncmp+0x12>
		n--, p++, q++;
  801096:	4a                   	dec    %edx
  801097:	40                   	inc    %eax
  801098:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801099:	85 d2                	test   %edx,%edx
  80109b:	74 14                	je     8010b1 <strncmp+0x2a>
  80109d:	8a 18                	mov    (%eax),%bl
  80109f:	84 db                	test   %bl,%bl
  8010a1:	74 04                	je     8010a7 <strncmp+0x20>
  8010a3:	3a 19                	cmp    (%ecx),%bl
  8010a5:	74 ef                	je     801096 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8010a7:	0f b6 00             	movzbl (%eax),%eax
  8010aa:	0f b6 11             	movzbl (%ecx),%edx
  8010ad:	29 d0                	sub    %edx,%eax
  8010af:	eb 05                	jmp    8010b6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8010b1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010b6:	5b                   	pop    %ebx
  8010b7:	5d                   	pop    %ebp
  8010b8:	c3                   	ret    

008010b9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8010c2:	eb 05                	jmp    8010c9 <strchr+0x10>
		if (*s == c)
  8010c4:	38 ca                	cmp    %cl,%dl
  8010c6:	74 0c                	je     8010d4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8010c8:	40                   	inc    %eax
  8010c9:	8a 10                	mov    (%eax),%dl
  8010cb:	84 d2                	test   %dl,%dl
  8010cd:	75 f5                	jne    8010c4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8010cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    

008010d6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010dc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8010df:	eb 05                	jmp    8010e6 <strfind+0x10>
		if (*s == c)
  8010e1:	38 ca                	cmp    %cl,%dl
  8010e3:	74 07                	je     8010ec <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8010e5:	40                   	inc    %eax
  8010e6:	8a 10                	mov    (%eax),%dl
  8010e8:	84 d2                	test   %dl,%dl
  8010ea:	75 f5                	jne    8010e1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8010ec:	5d                   	pop    %ebp
  8010ed:	c3                   	ret    

008010ee <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	57                   	push   %edi
  8010f2:	56                   	push   %esi
  8010f3:	53                   	push   %ebx
  8010f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8010fd:	85 c9                	test   %ecx,%ecx
  8010ff:	74 30                	je     801131 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801101:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801107:	75 25                	jne    80112e <memset+0x40>
  801109:	f6 c1 03             	test   $0x3,%cl
  80110c:	75 20                	jne    80112e <memset+0x40>
		c &= 0xFF;
  80110e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801111:	89 d3                	mov    %edx,%ebx
  801113:	c1 e3 08             	shl    $0x8,%ebx
  801116:	89 d6                	mov    %edx,%esi
  801118:	c1 e6 18             	shl    $0x18,%esi
  80111b:	89 d0                	mov    %edx,%eax
  80111d:	c1 e0 10             	shl    $0x10,%eax
  801120:	09 f0                	or     %esi,%eax
  801122:	09 d0                	or     %edx,%eax
  801124:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801126:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801129:	fc                   	cld    
  80112a:	f3 ab                	rep stos %eax,%es:(%edi)
  80112c:	eb 03                	jmp    801131 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80112e:	fc                   	cld    
  80112f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801131:	89 f8                	mov    %edi,%eax
  801133:	5b                   	pop    %ebx
  801134:	5e                   	pop    %esi
  801135:	5f                   	pop    %edi
  801136:	5d                   	pop    %ebp
  801137:	c3                   	ret    

00801138 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	57                   	push   %edi
  80113c:	56                   	push   %esi
  80113d:	8b 45 08             	mov    0x8(%ebp),%eax
  801140:	8b 75 0c             	mov    0xc(%ebp),%esi
  801143:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801146:	39 c6                	cmp    %eax,%esi
  801148:	73 34                	jae    80117e <memmove+0x46>
  80114a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80114d:	39 d0                	cmp    %edx,%eax
  80114f:	73 2d                	jae    80117e <memmove+0x46>
		s += n;
		d += n;
  801151:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801154:	f6 c2 03             	test   $0x3,%dl
  801157:	75 1b                	jne    801174 <memmove+0x3c>
  801159:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80115f:	75 13                	jne    801174 <memmove+0x3c>
  801161:	f6 c1 03             	test   $0x3,%cl
  801164:	75 0e                	jne    801174 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801166:	83 ef 04             	sub    $0x4,%edi
  801169:	8d 72 fc             	lea    -0x4(%edx),%esi
  80116c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80116f:	fd                   	std    
  801170:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801172:	eb 07                	jmp    80117b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801174:	4f                   	dec    %edi
  801175:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801178:	fd                   	std    
  801179:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80117b:	fc                   	cld    
  80117c:	eb 20                	jmp    80119e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80117e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801184:	75 13                	jne    801199 <memmove+0x61>
  801186:	a8 03                	test   $0x3,%al
  801188:	75 0f                	jne    801199 <memmove+0x61>
  80118a:	f6 c1 03             	test   $0x3,%cl
  80118d:	75 0a                	jne    801199 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80118f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801192:	89 c7                	mov    %eax,%edi
  801194:	fc                   	cld    
  801195:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801197:	eb 05                	jmp    80119e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801199:	89 c7                	mov    %eax,%edi
  80119b:	fc                   	cld    
  80119c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80119e:	5e                   	pop    %esi
  80119f:	5f                   	pop    %edi
  8011a0:	5d                   	pop    %ebp
  8011a1:	c3                   	ret    

008011a2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8011a2:	55                   	push   %ebp
  8011a3:	89 e5                	mov    %esp,%ebp
  8011a5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8011a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8011ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b9:	89 04 24             	mov    %eax,(%esp)
  8011bc:	e8 77 ff ff ff       	call   801138 <memmove>
}
  8011c1:	c9                   	leave  
  8011c2:	c3                   	ret    

008011c3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	57                   	push   %edi
  8011c7:	56                   	push   %esi
  8011c8:	53                   	push   %ebx
  8011c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011cc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d7:	eb 16                	jmp    8011ef <memcmp+0x2c>
		if (*s1 != *s2)
  8011d9:	8a 04 17             	mov    (%edi,%edx,1),%al
  8011dc:	42                   	inc    %edx
  8011dd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8011e1:	38 c8                	cmp    %cl,%al
  8011e3:	74 0a                	je     8011ef <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8011e5:	0f b6 c0             	movzbl %al,%eax
  8011e8:	0f b6 c9             	movzbl %cl,%ecx
  8011eb:	29 c8                	sub    %ecx,%eax
  8011ed:	eb 09                	jmp    8011f8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011ef:	39 da                	cmp    %ebx,%edx
  8011f1:	75 e6                	jne    8011d9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8011f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011f8:	5b                   	pop    %ebx
  8011f9:	5e                   	pop    %esi
  8011fa:	5f                   	pop    %edi
  8011fb:	5d                   	pop    %ebp
  8011fc:	c3                   	ret    

008011fd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	8b 45 08             	mov    0x8(%ebp),%eax
  801203:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801206:	89 c2                	mov    %eax,%edx
  801208:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80120b:	eb 05                	jmp    801212 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  80120d:	38 08                	cmp    %cl,(%eax)
  80120f:	74 05                	je     801216 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801211:	40                   	inc    %eax
  801212:	39 d0                	cmp    %edx,%eax
  801214:	72 f7                	jb     80120d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801216:	5d                   	pop    %ebp
  801217:	c3                   	ret    

00801218 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	57                   	push   %edi
  80121c:	56                   	push   %esi
  80121d:	53                   	push   %ebx
  80121e:	8b 55 08             	mov    0x8(%ebp),%edx
  801221:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801224:	eb 01                	jmp    801227 <strtol+0xf>
		s++;
  801226:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801227:	8a 02                	mov    (%edx),%al
  801229:	3c 20                	cmp    $0x20,%al
  80122b:	74 f9                	je     801226 <strtol+0xe>
  80122d:	3c 09                	cmp    $0x9,%al
  80122f:	74 f5                	je     801226 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801231:	3c 2b                	cmp    $0x2b,%al
  801233:	75 08                	jne    80123d <strtol+0x25>
		s++;
  801235:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801236:	bf 00 00 00 00       	mov    $0x0,%edi
  80123b:	eb 13                	jmp    801250 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80123d:	3c 2d                	cmp    $0x2d,%al
  80123f:	75 0a                	jne    80124b <strtol+0x33>
		s++, neg = 1;
  801241:	8d 52 01             	lea    0x1(%edx),%edx
  801244:	bf 01 00 00 00       	mov    $0x1,%edi
  801249:	eb 05                	jmp    801250 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80124b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801250:	85 db                	test   %ebx,%ebx
  801252:	74 05                	je     801259 <strtol+0x41>
  801254:	83 fb 10             	cmp    $0x10,%ebx
  801257:	75 28                	jne    801281 <strtol+0x69>
  801259:	8a 02                	mov    (%edx),%al
  80125b:	3c 30                	cmp    $0x30,%al
  80125d:	75 10                	jne    80126f <strtol+0x57>
  80125f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801263:	75 0a                	jne    80126f <strtol+0x57>
		s += 2, base = 16;
  801265:	83 c2 02             	add    $0x2,%edx
  801268:	bb 10 00 00 00       	mov    $0x10,%ebx
  80126d:	eb 12                	jmp    801281 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80126f:	85 db                	test   %ebx,%ebx
  801271:	75 0e                	jne    801281 <strtol+0x69>
  801273:	3c 30                	cmp    $0x30,%al
  801275:	75 05                	jne    80127c <strtol+0x64>
		s++, base = 8;
  801277:	42                   	inc    %edx
  801278:	b3 08                	mov    $0x8,%bl
  80127a:	eb 05                	jmp    801281 <strtol+0x69>
	else if (base == 0)
		base = 10;
  80127c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801281:	b8 00 00 00 00       	mov    $0x0,%eax
  801286:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801288:	8a 0a                	mov    (%edx),%cl
  80128a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80128d:	80 fb 09             	cmp    $0x9,%bl
  801290:	77 08                	ja     80129a <strtol+0x82>
			dig = *s - '0';
  801292:	0f be c9             	movsbl %cl,%ecx
  801295:	83 e9 30             	sub    $0x30,%ecx
  801298:	eb 1e                	jmp    8012b8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80129a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80129d:	80 fb 19             	cmp    $0x19,%bl
  8012a0:	77 08                	ja     8012aa <strtol+0x92>
			dig = *s - 'a' + 10;
  8012a2:	0f be c9             	movsbl %cl,%ecx
  8012a5:	83 e9 57             	sub    $0x57,%ecx
  8012a8:	eb 0e                	jmp    8012b8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8012aa:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8012ad:	80 fb 19             	cmp    $0x19,%bl
  8012b0:	77 12                	ja     8012c4 <strtol+0xac>
			dig = *s - 'A' + 10;
  8012b2:	0f be c9             	movsbl %cl,%ecx
  8012b5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8012b8:	39 f1                	cmp    %esi,%ecx
  8012ba:	7d 0c                	jge    8012c8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8012bc:	42                   	inc    %edx
  8012bd:	0f af c6             	imul   %esi,%eax
  8012c0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8012c2:	eb c4                	jmp    801288 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8012c4:	89 c1                	mov    %eax,%ecx
  8012c6:	eb 02                	jmp    8012ca <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8012c8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8012ca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8012ce:	74 05                	je     8012d5 <strtol+0xbd>
		*endptr = (char *) s;
  8012d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012d3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8012d5:	85 ff                	test   %edi,%edi
  8012d7:	74 04                	je     8012dd <strtol+0xc5>
  8012d9:	89 c8                	mov    %ecx,%eax
  8012db:	f7 d8                	neg    %eax
}
  8012dd:	5b                   	pop    %ebx
  8012de:	5e                   	pop    %esi
  8012df:	5f                   	pop    %edi
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    
	...

008012e4 <__udivdi3>:
  8012e4:	55                   	push   %ebp
  8012e5:	57                   	push   %edi
  8012e6:	56                   	push   %esi
  8012e7:	83 ec 10             	sub    $0x10,%esp
  8012ea:	8b 74 24 20          	mov    0x20(%esp),%esi
  8012ee:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8012f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012f6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8012fa:	89 cd                	mov    %ecx,%ebp
  8012fc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801300:	85 c0                	test   %eax,%eax
  801302:	75 2c                	jne    801330 <__udivdi3+0x4c>
  801304:	39 f9                	cmp    %edi,%ecx
  801306:	77 68                	ja     801370 <__udivdi3+0x8c>
  801308:	85 c9                	test   %ecx,%ecx
  80130a:	75 0b                	jne    801317 <__udivdi3+0x33>
  80130c:	b8 01 00 00 00       	mov    $0x1,%eax
  801311:	31 d2                	xor    %edx,%edx
  801313:	f7 f1                	div    %ecx
  801315:	89 c1                	mov    %eax,%ecx
  801317:	31 d2                	xor    %edx,%edx
  801319:	89 f8                	mov    %edi,%eax
  80131b:	f7 f1                	div    %ecx
  80131d:	89 c7                	mov    %eax,%edi
  80131f:	89 f0                	mov    %esi,%eax
  801321:	f7 f1                	div    %ecx
  801323:	89 c6                	mov    %eax,%esi
  801325:	89 f0                	mov    %esi,%eax
  801327:	89 fa                	mov    %edi,%edx
  801329:	83 c4 10             	add    $0x10,%esp
  80132c:	5e                   	pop    %esi
  80132d:	5f                   	pop    %edi
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    
  801330:	39 f8                	cmp    %edi,%eax
  801332:	77 2c                	ja     801360 <__udivdi3+0x7c>
  801334:	0f bd f0             	bsr    %eax,%esi
  801337:	83 f6 1f             	xor    $0x1f,%esi
  80133a:	75 4c                	jne    801388 <__udivdi3+0xa4>
  80133c:	39 f8                	cmp    %edi,%eax
  80133e:	bf 00 00 00 00       	mov    $0x0,%edi
  801343:	72 0a                	jb     80134f <__udivdi3+0x6b>
  801345:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801349:	0f 87 ad 00 00 00    	ja     8013fc <__udivdi3+0x118>
  80134f:	be 01 00 00 00       	mov    $0x1,%esi
  801354:	89 f0                	mov    %esi,%eax
  801356:	89 fa                	mov    %edi,%edx
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	5e                   	pop    %esi
  80135c:	5f                   	pop    %edi
  80135d:	5d                   	pop    %ebp
  80135e:	c3                   	ret    
  80135f:	90                   	nop
  801360:	31 ff                	xor    %edi,%edi
  801362:	31 f6                	xor    %esi,%esi
  801364:	89 f0                	mov    %esi,%eax
  801366:	89 fa                	mov    %edi,%edx
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	5e                   	pop    %esi
  80136c:	5f                   	pop    %edi
  80136d:	5d                   	pop    %ebp
  80136e:	c3                   	ret    
  80136f:	90                   	nop
  801370:	89 fa                	mov    %edi,%edx
  801372:	89 f0                	mov    %esi,%eax
  801374:	f7 f1                	div    %ecx
  801376:	89 c6                	mov    %eax,%esi
  801378:	31 ff                	xor    %edi,%edi
  80137a:	89 f0                	mov    %esi,%eax
  80137c:	89 fa                	mov    %edi,%edx
  80137e:	83 c4 10             	add    $0x10,%esp
  801381:	5e                   	pop    %esi
  801382:	5f                   	pop    %edi
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    
  801385:	8d 76 00             	lea    0x0(%esi),%esi
  801388:	89 f1                	mov    %esi,%ecx
  80138a:	d3 e0                	shl    %cl,%eax
  80138c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801390:	b8 20 00 00 00       	mov    $0x20,%eax
  801395:	29 f0                	sub    %esi,%eax
  801397:	89 ea                	mov    %ebp,%edx
  801399:	88 c1                	mov    %al,%cl
  80139b:	d3 ea                	shr    %cl,%edx
  80139d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8013a1:	09 ca                	or     %ecx,%edx
  8013a3:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013a7:	89 f1                	mov    %esi,%ecx
  8013a9:	d3 e5                	shl    %cl,%ebp
  8013ab:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8013af:	89 fd                	mov    %edi,%ebp
  8013b1:	88 c1                	mov    %al,%cl
  8013b3:	d3 ed                	shr    %cl,%ebp
  8013b5:	89 fa                	mov    %edi,%edx
  8013b7:	89 f1                	mov    %esi,%ecx
  8013b9:	d3 e2                	shl    %cl,%edx
  8013bb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013bf:	88 c1                	mov    %al,%cl
  8013c1:	d3 ef                	shr    %cl,%edi
  8013c3:	09 d7                	or     %edx,%edi
  8013c5:	89 f8                	mov    %edi,%eax
  8013c7:	89 ea                	mov    %ebp,%edx
  8013c9:	f7 74 24 08          	divl   0x8(%esp)
  8013cd:	89 d1                	mov    %edx,%ecx
  8013cf:	89 c7                	mov    %eax,%edi
  8013d1:	f7 64 24 0c          	mull   0xc(%esp)
  8013d5:	39 d1                	cmp    %edx,%ecx
  8013d7:	72 17                	jb     8013f0 <__udivdi3+0x10c>
  8013d9:	74 09                	je     8013e4 <__udivdi3+0x100>
  8013db:	89 fe                	mov    %edi,%esi
  8013dd:	31 ff                	xor    %edi,%edi
  8013df:	e9 41 ff ff ff       	jmp    801325 <__udivdi3+0x41>
  8013e4:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013e8:	89 f1                	mov    %esi,%ecx
  8013ea:	d3 e2                	shl    %cl,%edx
  8013ec:	39 c2                	cmp    %eax,%edx
  8013ee:	73 eb                	jae    8013db <__udivdi3+0xf7>
  8013f0:	8d 77 ff             	lea    -0x1(%edi),%esi
  8013f3:	31 ff                	xor    %edi,%edi
  8013f5:	e9 2b ff ff ff       	jmp    801325 <__udivdi3+0x41>
  8013fa:	66 90                	xchg   %ax,%ax
  8013fc:	31 f6                	xor    %esi,%esi
  8013fe:	e9 22 ff ff ff       	jmp    801325 <__udivdi3+0x41>
	...

00801404 <__umoddi3>:
  801404:	55                   	push   %ebp
  801405:	57                   	push   %edi
  801406:	56                   	push   %esi
  801407:	83 ec 20             	sub    $0x20,%esp
  80140a:	8b 44 24 30          	mov    0x30(%esp),%eax
  80140e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801412:	89 44 24 14          	mov    %eax,0x14(%esp)
  801416:	8b 74 24 34          	mov    0x34(%esp),%esi
  80141a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80141e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801422:	89 c7                	mov    %eax,%edi
  801424:	89 f2                	mov    %esi,%edx
  801426:	85 ed                	test   %ebp,%ebp
  801428:	75 16                	jne    801440 <__umoddi3+0x3c>
  80142a:	39 f1                	cmp    %esi,%ecx
  80142c:	0f 86 a6 00 00 00    	jbe    8014d8 <__umoddi3+0xd4>
  801432:	f7 f1                	div    %ecx
  801434:	89 d0                	mov    %edx,%eax
  801436:	31 d2                	xor    %edx,%edx
  801438:	83 c4 20             	add    $0x20,%esp
  80143b:	5e                   	pop    %esi
  80143c:	5f                   	pop    %edi
  80143d:	5d                   	pop    %ebp
  80143e:	c3                   	ret    
  80143f:	90                   	nop
  801440:	39 f5                	cmp    %esi,%ebp
  801442:	0f 87 ac 00 00 00    	ja     8014f4 <__umoddi3+0xf0>
  801448:	0f bd c5             	bsr    %ebp,%eax
  80144b:	83 f0 1f             	xor    $0x1f,%eax
  80144e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801452:	0f 84 a8 00 00 00    	je     801500 <__umoddi3+0xfc>
  801458:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80145c:	d3 e5                	shl    %cl,%ebp
  80145e:	bf 20 00 00 00       	mov    $0x20,%edi
  801463:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801467:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80146b:	89 f9                	mov    %edi,%ecx
  80146d:	d3 e8                	shr    %cl,%eax
  80146f:	09 e8                	or     %ebp,%eax
  801471:	89 44 24 18          	mov    %eax,0x18(%esp)
  801475:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801479:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80147d:	d3 e0                	shl    %cl,%eax
  80147f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801483:	89 f2                	mov    %esi,%edx
  801485:	d3 e2                	shl    %cl,%edx
  801487:	8b 44 24 14          	mov    0x14(%esp),%eax
  80148b:	d3 e0                	shl    %cl,%eax
  80148d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801491:	8b 44 24 14          	mov    0x14(%esp),%eax
  801495:	89 f9                	mov    %edi,%ecx
  801497:	d3 e8                	shr    %cl,%eax
  801499:	09 d0                	or     %edx,%eax
  80149b:	d3 ee                	shr    %cl,%esi
  80149d:	89 f2                	mov    %esi,%edx
  80149f:	f7 74 24 18          	divl   0x18(%esp)
  8014a3:	89 d6                	mov    %edx,%esi
  8014a5:	f7 64 24 0c          	mull   0xc(%esp)
  8014a9:	89 c5                	mov    %eax,%ebp
  8014ab:	89 d1                	mov    %edx,%ecx
  8014ad:	39 d6                	cmp    %edx,%esi
  8014af:	72 67                	jb     801518 <__umoddi3+0x114>
  8014b1:	74 75                	je     801528 <__umoddi3+0x124>
  8014b3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8014b7:	29 e8                	sub    %ebp,%eax
  8014b9:	19 ce                	sbb    %ecx,%esi
  8014bb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014bf:	d3 e8                	shr    %cl,%eax
  8014c1:	89 f2                	mov    %esi,%edx
  8014c3:	89 f9                	mov    %edi,%ecx
  8014c5:	d3 e2                	shl    %cl,%edx
  8014c7:	09 d0                	or     %edx,%eax
  8014c9:	89 f2                	mov    %esi,%edx
  8014cb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014cf:	d3 ea                	shr    %cl,%edx
  8014d1:	83 c4 20             	add    $0x20,%esp
  8014d4:	5e                   	pop    %esi
  8014d5:	5f                   	pop    %edi
  8014d6:	5d                   	pop    %ebp
  8014d7:	c3                   	ret    
  8014d8:	85 c9                	test   %ecx,%ecx
  8014da:	75 0b                	jne    8014e7 <__umoddi3+0xe3>
  8014dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e1:	31 d2                	xor    %edx,%edx
  8014e3:	f7 f1                	div    %ecx
  8014e5:	89 c1                	mov    %eax,%ecx
  8014e7:	89 f0                	mov    %esi,%eax
  8014e9:	31 d2                	xor    %edx,%edx
  8014eb:	f7 f1                	div    %ecx
  8014ed:	89 f8                	mov    %edi,%eax
  8014ef:	e9 3e ff ff ff       	jmp    801432 <__umoddi3+0x2e>
  8014f4:	89 f2                	mov    %esi,%edx
  8014f6:	83 c4 20             	add    $0x20,%esp
  8014f9:	5e                   	pop    %esi
  8014fa:	5f                   	pop    %edi
  8014fb:	5d                   	pop    %ebp
  8014fc:	c3                   	ret    
  8014fd:	8d 76 00             	lea    0x0(%esi),%esi
  801500:	39 f5                	cmp    %esi,%ebp
  801502:	72 04                	jb     801508 <__umoddi3+0x104>
  801504:	39 f9                	cmp    %edi,%ecx
  801506:	77 06                	ja     80150e <__umoddi3+0x10a>
  801508:	89 f2                	mov    %esi,%edx
  80150a:	29 cf                	sub    %ecx,%edi
  80150c:	19 ea                	sbb    %ebp,%edx
  80150e:	89 f8                	mov    %edi,%eax
  801510:	83 c4 20             	add    $0x20,%esp
  801513:	5e                   	pop    %esi
  801514:	5f                   	pop    %edi
  801515:	5d                   	pop    %ebp
  801516:	c3                   	ret    
  801517:	90                   	nop
  801518:	89 d1                	mov    %edx,%ecx
  80151a:	89 c5                	mov    %eax,%ebp
  80151c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801520:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801524:	eb 8d                	jmp    8014b3 <__umoddi3+0xaf>
  801526:	66 90                	xchg   %ax,%ax
  801528:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80152c:	72 ea                	jb     801518 <__umoddi3+0x114>
  80152e:	89 f1                	mov    %esi,%ecx
  801530:	eb 81                	jmp    8014b3 <__umoddi3+0xaf>
