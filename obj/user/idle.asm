
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
  80003a:	c7 05 00 20 80 00 20 	movl   $0x801020,0x802000
  800041:	10 80 00 
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
  800067:	8d 04 50             	lea    (%eax,%edx,2),%eax
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
  80011b:	c7 44 24 08 2f 10 80 	movl   $0x80102f,0x8(%esp)
  800122:	00 
  800123:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012a:	00 
  80012b:	c7 04 24 4c 10 80 00 	movl   $0x80104c,(%esp)
  800132:	e8 b1 02 00 00       	call   8003e8 <_panic>

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
  8001ad:	c7 44 24 08 2f 10 80 	movl   $0x80102f,0x8(%esp)
  8001b4:	00 
  8001b5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001bc:	00 
  8001bd:	c7 04 24 4c 10 80 00 	movl   $0x80104c,(%esp)
  8001c4:	e8 1f 02 00 00       	call   8003e8 <_panic>

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
  800200:	c7 44 24 08 2f 10 80 	movl   $0x80102f,0x8(%esp)
  800207:	00 
  800208:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80020f:	00 
  800210:	c7 04 24 4c 10 80 00 	movl   $0x80104c,(%esp)
  800217:	e8 cc 01 00 00       	call   8003e8 <_panic>

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
  800253:	c7 44 24 08 2f 10 80 	movl   $0x80102f,0x8(%esp)
  80025a:	00 
  80025b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800262:	00 
  800263:	c7 04 24 4c 10 80 00 	movl   $0x80104c,(%esp)
  80026a:	e8 79 01 00 00       	call   8003e8 <_panic>

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
  8002a6:	c7 44 24 08 2f 10 80 	movl   $0x80102f,0x8(%esp)
  8002ad:	00 
  8002ae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b5:	00 
  8002b6:	c7 04 24 4c 10 80 00 	movl   $0x80104c,(%esp)
  8002bd:	e8 26 01 00 00       	call   8003e8 <_panic>

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
  8002f9:	c7 44 24 08 2f 10 80 	movl   $0x80102f,0x8(%esp)
  800300:	00 
  800301:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800308:	00 
  800309:	c7 04 24 4c 10 80 00 	movl   $0x80104c,(%esp)
  800310:	e8 d3 00 00 00       	call   8003e8 <_panic>

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
  80036e:	c7 44 24 08 2f 10 80 	movl   $0x80102f,0x8(%esp)
  800375:	00 
  800376:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80037d:	00 
  80037e:	c7 04 24 4c 10 80 00 	movl   $0x80104c,(%esp)
  800385:	e8 5e 00 00 00       	call   8003e8 <_panic>

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
  8003c1:	c7 44 24 08 2f 10 80 	movl   $0x80102f,0x8(%esp)
  8003c8:	00 
  8003c9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d0:	00 
  8003d1:	c7 04 24 4c 10 80 00 	movl   $0x80104c,(%esp)
  8003d8:	e8 0b 00 00 00       	call   8003e8 <_panic>
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
  8003e5:	00 00                	add    %al,(%eax)
	...

008003e8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	56                   	push   %esi
  8003ec:	53                   	push   %ebx
  8003ed:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003f0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003f3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8003f9:	e8 41 fd ff ff       	call   80013f <sys_getenvid>
  8003fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800401:	89 54 24 10          	mov    %edx,0x10(%esp)
  800405:	8b 55 08             	mov    0x8(%ebp),%edx
  800408:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80040c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800410:	89 44 24 04          	mov    %eax,0x4(%esp)
  800414:	c7 04 24 5c 10 80 00 	movl   $0x80105c,(%esp)
  80041b:	e8 c0 00 00 00       	call   8004e0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800420:	89 74 24 04          	mov    %esi,0x4(%esp)
  800424:	8b 45 10             	mov    0x10(%ebp),%eax
  800427:	89 04 24             	mov    %eax,(%esp)
  80042a:	e8 50 00 00 00       	call   80047f <vcprintf>
	cprintf("\n");
  80042f:	c7 04 24 80 10 80 00 	movl   $0x801080,(%esp)
  800436:	e8 a5 00 00 00       	call   8004e0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80043b:	cc                   	int3   
  80043c:	eb fd                	jmp    80043b <_panic+0x53>
	...

00800440 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800440:	55                   	push   %ebp
  800441:	89 e5                	mov    %esp,%ebp
  800443:	53                   	push   %ebx
  800444:	83 ec 14             	sub    $0x14,%esp
  800447:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80044a:	8b 03                	mov    (%ebx),%eax
  80044c:	8b 55 08             	mov    0x8(%ebp),%edx
  80044f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800453:	40                   	inc    %eax
  800454:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800456:	3d ff 00 00 00       	cmp    $0xff,%eax
  80045b:	75 19                	jne    800476 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80045d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800464:	00 
  800465:	8d 43 08             	lea    0x8(%ebx),%eax
  800468:	89 04 24             	mov    %eax,(%esp)
  80046b:	e8 40 fc ff ff       	call   8000b0 <sys_cputs>
		b->idx = 0;
  800470:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800476:	ff 43 04             	incl   0x4(%ebx)
}
  800479:	83 c4 14             	add    $0x14,%esp
  80047c:	5b                   	pop    %ebx
  80047d:	5d                   	pop    %ebp
  80047e:	c3                   	ret    

0080047f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80047f:	55                   	push   %ebp
  800480:	89 e5                	mov    %esp,%ebp
  800482:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800488:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80048f:	00 00 00 
	b.cnt = 0;
  800492:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800499:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80049c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b4:	c7 04 24 40 04 80 00 	movl   $0x800440,(%esp)
  8004bb:	e8 b4 01 00 00       	call   800674 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004c0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ca:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004d0:	89 04 24             	mov    %eax,(%esp)
  8004d3:	e8 d8 fb ff ff       	call   8000b0 <sys_cputs>

	return b.cnt;
}
  8004d8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004de:	c9                   	leave  
  8004df:	c3                   	ret    

008004e0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004e6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f0:	89 04 24             	mov    %eax,(%esp)
  8004f3:	e8 87 ff ff ff       	call   80047f <vcprintf>
	va_end(ap);

	return cnt;
}
  8004f8:	c9                   	leave  
  8004f9:	c3                   	ret    
	...

008004fc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004fc:	55                   	push   %ebp
  8004fd:	89 e5                	mov    %esp,%ebp
  8004ff:	57                   	push   %edi
  800500:	56                   	push   %esi
  800501:	53                   	push   %ebx
  800502:	83 ec 3c             	sub    $0x3c,%esp
  800505:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800508:	89 d7                	mov    %edx,%edi
  80050a:	8b 45 08             	mov    0x8(%ebp),%eax
  80050d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800510:	8b 45 0c             	mov    0xc(%ebp),%eax
  800513:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800516:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800519:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80051c:	85 c0                	test   %eax,%eax
  80051e:	75 08                	jne    800528 <printnum+0x2c>
  800520:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800523:	39 45 10             	cmp    %eax,0x10(%ebp)
  800526:	77 57                	ja     80057f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800528:	89 74 24 10          	mov    %esi,0x10(%esp)
  80052c:	4b                   	dec    %ebx
  80052d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800531:	8b 45 10             	mov    0x10(%ebp),%eax
  800534:	89 44 24 08          	mov    %eax,0x8(%esp)
  800538:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80053c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800540:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800547:	00 
  800548:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80054b:	89 04 24             	mov    %eax,(%esp)
  80054e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800551:	89 44 24 04          	mov    %eax,0x4(%esp)
  800555:	e8 5a 08 00 00       	call   800db4 <__udivdi3>
  80055a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80055e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800562:	89 04 24             	mov    %eax,(%esp)
  800565:	89 54 24 04          	mov    %edx,0x4(%esp)
  800569:	89 fa                	mov    %edi,%edx
  80056b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80056e:	e8 89 ff ff ff       	call   8004fc <printnum>
  800573:	eb 0f                	jmp    800584 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800575:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800579:	89 34 24             	mov    %esi,(%esp)
  80057c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80057f:	4b                   	dec    %ebx
  800580:	85 db                	test   %ebx,%ebx
  800582:	7f f1                	jg     800575 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800584:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800588:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80058c:	8b 45 10             	mov    0x10(%ebp),%eax
  80058f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800593:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80059a:	00 
  80059b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80059e:	89 04 24             	mov    %eax,(%esp)
  8005a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a8:	e8 27 09 00 00       	call   800ed4 <__umoddi3>
  8005ad:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b1:	0f be 80 82 10 80 00 	movsbl 0x801082(%eax),%eax
  8005b8:	89 04 24             	mov    %eax,(%esp)
  8005bb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8005be:	83 c4 3c             	add    $0x3c,%esp
  8005c1:	5b                   	pop    %ebx
  8005c2:	5e                   	pop    %esi
  8005c3:	5f                   	pop    %edi
  8005c4:	5d                   	pop    %ebp
  8005c5:	c3                   	ret    

008005c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005c6:	55                   	push   %ebp
  8005c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005c9:	83 fa 01             	cmp    $0x1,%edx
  8005cc:	7e 0e                	jle    8005dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005ce:	8b 10                	mov    (%eax),%edx
  8005d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005d3:	89 08                	mov    %ecx,(%eax)
  8005d5:	8b 02                	mov    (%edx),%eax
  8005d7:	8b 52 04             	mov    0x4(%edx),%edx
  8005da:	eb 22                	jmp    8005fe <getuint+0x38>
	else if (lflag)
  8005dc:	85 d2                	test   %edx,%edx
  8005de:	74 10                	je     8005f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005e0:	8b 10                	mov    (%eax),%edx
  8005e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005e5:	89 08                	mov    %ecx,(%eax)
  8005e7:	8b 02                	mov    (%edx),%eax
  8005e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ee:	eb 0e                	jmp    8005fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005f0:	8b 10                	mov    (%eax),%edx
  8005f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005f5:	89 08                	mov    %ecx,(%eax)
  8005f7:	8b 02                	mov    (%edx),%eax
  8005f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005fe:	5d                   	pop    %ebp
  8005ff:	c3                   	ret    

00800600 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800600:	55                   	push   %ebp
  800601:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800603:	83 fa 01             	cmp    $0x1,%edx
  800606:	7e 0e                	jle    800616 <getint+0x16>
		return va_arg(*ap, long long);
  800608:	8b 10                	mov    (%eax),%edx
  80060a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80060d:	89 08                	mov    %ecx,(%eax)
  80060f:	8b 02                	mov    (%edx),%eax
  800611:	8b 52 04             	mov    0x4(%edx),%edx
  800614:	eb 1a                	jmp    800630 <getint+0x30>
	else if (lflag)
  800616:	85 d2                	test   %edx,%edx
  800618:	74 0c                	je     800626 <getint+0x26>
		return va_arg(*ap, long);
  80061a:	8b 10                	mov    (%eax),%edx
  80061c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80061f:	89 08                	mov    %ecx,(%eax)
  800621:	8b 02                	mov    (%edx),%eax
  800623:	99                   	cltd   
  800624:	eb 0a                	jmp    800630 <getint+0x30>
	else
		return va_arg(*ap, int);
  800626:	8b 10                	mov    (%eax),%edx
  800628:	8d 4a 04             	lea    0x4(%edx),%ecx
  80062b:	89 08                	mov    %ecx,(%eax)
  80062d:	8b 02                	mov    (%edx),%eax
  80062f:	99                   	cltd   
}
  800630:	5d                   	pop    %ebp
  800631:	c3                   	ret    

00800632 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800632:	55                   	push   %ebp
  800633:	89 e5                	mov    %esp,%ebp
  800635:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800638:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80063b:	8b 10                	mov    (%eax),%edx
  80063d:	3b 50 04             	cmp    0x4(%eax),%edx
  800640:	73 08                	jae    80064a <sprintputch+0x18>
		*b->buf++ = ch;
  800642:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800645:	88 0a                	mov    %cl,(%edx)
  800647:	42                   	inc    %edx
  800648:	89 10                	mov    %edx,(%eax)
}
  80064a:	5d                   	pop    %ebp
  80064b:	c3                   	ret    

0080064c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800652:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800655:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800659:	8b 45 10             	mov    0x10(%ebp),%eax
  80065c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800660:	8b 45 0c             	mov    0xc(%ebp),%eax
  800663:	89 44 24 04          	mov    %eax,0x4(%esp)
  800667:	8b 45 08             	mov    0x8(%ebp),%eax
  80066a:	89 04 24             	mov    %eax,(%esp)
  80066d:	e8 02 00 00 00       	call   800674 <vprintfmt>
	va_end(ap);
}
  800672:	c9                   	leave  
  800673:	c3                   	ret    

00800674 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800674:	55                   	push   %ebp
  800675:	89 e5                	mov    %esp,%ebp
  800677:	57                   	push   %edi
  800678:	56                   	push   %esi
  800679:	53                   	push   %ebx
  80067a:	83 ec 4c             	sub    $0x4c,%esp
  80067d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800680:	8b 75 10             	mov    0x10(%ebp),%esi
  800683:	eb 12                	jmp    800697 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800685:	85 c0                	test   %eax,%eax
  800687:	0f 84 40 03 00 00    	je     8009cd <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  80068d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800691:	89 04 24             	mov    %eax,(%esp)
  800694:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800697:	0f b6 06             	movzbl (%esi),%eax
  80069a:	46                   	inc    %esi
  80069b:	83 f8 25             	cmp    $0x25,%eax
  80069e:	75 e5                	jne    800685 <vprintfmt+0x11>
  8006a0:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006a4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006ab:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006b0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8006bc:	eb 26                	jmp    8006e4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006be:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006c1:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8006c5:	eb 1d                	jmp    8006e4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006ca:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8006ce:	eb 14                	jmp    8006e4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8006d3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8006da:	eb 08                	jmp    8006e4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8006dc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006df:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e4:	0f b6 06             	movzbl (%esi),%eax
  8006e7:	8d 4e 01             	lea    0x1(%esi),%ecx
  8006ea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006ed:	8a 0e                	mov    (%esi),%cl
  8006ef:	83 e9 23             	sub    $0x23,%ecx
  8006f2:	80 f9 55             	cmp    $0x55,%cl
  8006f5:	0f 87 b6 02 00 00    	ja     8009b1 <vprintfmt+0x33d>
  8006fb:	0f b6 c9             	movzbl %cl,%ecx
  8006fe:	ff 24 8d 40 11 80 00 	jmp    *0x801140(,%ecx,4)
  800705:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800708:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80070d:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800710:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  800714:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800717:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80071a:	83 f9 09             	cmp    $0x9,%ecx
  80071d:	77 2a                	ja     800749 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80071f:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800720:	eb eb                	jmp    80070d <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800722:	8b 45 14             	mov    0x14(%ebp),%eax
  800725:	8d 48 04             	lea    0x4(%eax),%ecx
  800728:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80072b:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800730:	eb 17                	jmp    800749 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800732:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800736:	78 98                	js     8006d0 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800738:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80073b:	eb a7                	jmp    8006e4 <vprintfmt+0x70>
  80073d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800740:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800747:	eb 9b                	jmp    8006e4 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800749:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80074d:	79 95                	jns    8006e4 <vprintfmt+0x70>
  80074f:	eb 8b                	jmp    8006dc <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800751:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800752:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800755:	eb 8d                	jmp    8006e4 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8d 50 04             	lea    0x4(%eax),%edx
  80075d:	89 55 14             	mov    %edx,0x14(%ebp)
  800760:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800764:	8b 00                	mov    (%eax),%eax
  800766:	89 04 24             	mov    %eax,(%esp)
  800769:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80076f:	e9 23 ff ff ff       	jmp    800697 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8d 50 04             	lea    0x4(%eax),%edx
  80077a:	89 55 14             	mov    %edx,0x14(%ebp)
  80077d:	8b 00                	mov    (%eax),%eax
  80077f:	85 c0                	test   %eax,%eax
  800781:	79 02                	jns    800785 <vprintfmt+0x111>
  800783:	f7 d8                	neg    %eax
  800785:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800787:	83 f8 09             	cmp    $0x9,%eax
  80078a:	7f 0b                	jg     800797 <vprintfmt+0x123>
  80078c:	8b 04 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%eax
  800793:	85 c0                	test   %eax,%eax
  800795:	75 23                	jne    8007ba <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800797:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80079b:	c7 44 24 08 9a 10 80 	movl   $0x80109a,0x8(%esp)
  8007a2:	00 
  8007a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007aa:	89 04 24             	mov    %eax,(%esp)
  8007ad:	e8 9a fe ff ff       	call   80064c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007b5:	e9 dd fe ff ff       	jmp    800697 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8007ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007be:	c7 44 24 08 a3 10 80 	movl   $0x8010a3,0x8(%esp)
  8007c5:	00 
  8007c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8007cd:	89 14 24             	mov    %edx,(%esp)
  8007d0:	e8 77 fe ff ff       	call   80064c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007d8:	e9 ba fe ff ff       	jmp    800697 <vprintfmt+0x23>
  8007dd:	89 f9                	mov    %edi,%ecx
  8007df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007e2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e8:	8d 50 04             	lea    0x4(%eax),%edx
  8007eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ee:	8b 30                	mov    (%eax),%esi
  8007f0:	85 f6                	test   %esi,%esi
  8007f2:	75 05                	jne    8007f9 <vprintfmt+0x185>
				p = "(null)";
  8007f4:	be 93 10 80 00       	mov    $0x801093,%esi
			if (width > 0 && padc != '-')
  8007f9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007fd:	0f 8e 84 00 00 00    	jle    800887 <vprintfmt+0x213>
  800803:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800807:	74 7e                	je     800887 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800809:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80080d:	89 34 24             	mov    %esi,(%esp)
  800810:	e8 5d 02 00 00       	call   800a72 <strnlen>
  800815:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800818:	29 c2                	sub    %eax,%edx
  80081a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80081d:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800821:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800824:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800827:	89 de                	mov    %ebx,%esi
  800829:	89 d3                	mov    %edx,%ebx
  80082b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80082d:	eb 0b                	jmp    80083a <vprintfmt+0x1c6>
					putch(padc, putdat);
  80082f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800833:	89 3c 24             	mov    %edi,(%esp)
  800836:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800839:	4b                   	dec    %ebx
  80083a:	85 db                	test   %ebx,%ebx
  80083c:	7f f1                	jg     80082f <vprintfmt+0x1bb>
  80083e:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800841:	89 f3                	mov    %esi,%ebx
  800843:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800846:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800849:	85 c0                	test   %eax,%eax
  80084b:	79 05                	jns    800852 <vprintfmt+0x1de>
  80084d:	b8 00 00 00 00       	mov    $0x0,%eax
  800852:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800855:	29 c2                	sub    %eax,%edx
  800857:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80085a:	eb 2b                	jmp    800887 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80085c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800860:	74 18                	je     80087a <vprintfmt+0x206>
  800862:	8d 50 e0             	lea    -0x20(%eax),%edx
  800865:	83 fa 5e             	cmp    $0x5e,%edx
  800868:	76 10                	jbe    80087a <vprintfmt+0x206>
					putch('?', putdat);
  80086a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800875:	ff 55 08             	call   *0x8(%ebp)
  800878:	eb 0a                	jmp    800884 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80087a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087e:	89 04 24             	mov    %eax,(%esp)
  800881:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800884:	ff 4d e4             	decl   -0x1c(%ebp)
  800887:	0f be 06             	movsbl (%esi),%eax
  80088a:	46                   	inc    %esi
  80088b:	85 c0                	test   %eax,%eax
  80088d:	74 21                	je     8008b0 <vprintfmt+0x23c>
  80088f:	85 ff                	test   %edi,%edi
  800891:	78 c9                	js     80085c <vprintfmt+0x1e8>
  800893:	4f                   	dec    %edi
  800894:	79 c6                	jns    80085c <vprintfmt+0x1e8>
  800896:	8b 7d 08             	mov    0x8(%ebp),%edi
  800899:	89 de                	mov    %ebx,%esi
  80089b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80089e:	eb 18                	jmp    8008b8 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008a4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008ab:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008ad:	4b                   	dec    %ebx
  8008ae:	eb 08                	jmp    8008b8 <vprintfmt+0x244>
  8008b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b3:	89 de                	mov    %ebx,%esi
  8008b5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008b8:	85 db                	test   %ebx,%ebx
  8008ba:	7f e4                	jg     8008a0 <vprintfmt+0x22c>
  8008bc:	89 7d 08             	mov    %edi,0x8(%ebp)
  8008bf:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008c4:	e9 ce fd ff ff       	jmp    800697 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008c9:	8d 45 14             	lea    0x14(%ebp),%eax
  8008cc:	e8 2f fd ff ff       	call   800600 <getint>
  8008d1:	89 c6                	mov    %eax,%esi
  8008d3:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8008d5:	85 d2                	test   %edx,%edx
  8008d7:	78 07                	js     8008e0 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008d9:	be 0a 00 00 00       	mov    $0xa,%esi
  8008de:	eb 7e                	jmp    80095e <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008eb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008ee:	89 f0                	mov    %esi,%eax
  8008f0:	89 fa                	mov    %edi,%edx
  8008f2:	f7 d8                	neg    %eax
  8008f4:	83 d2 00             	adc    $0x0,%edx
  8008f7:	f7 da                	neg    %edx
			}
			base = 10;
  8008f9:	be 0a 00 00 00       	mov    $0xa,%esi
  8008fe:	eb 5e                	jmp    80095e <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800900:	8d 45 14             	lea    0x14(%ebp),%eax
  800903:	e8 be fc ff ff       	call   8005c6 <getuint>
			base = 10;
  800908:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80090d:	eb 4f                	jmp    80095e <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80090f:	8d 45 14             	lea    0x14(%ebp),%eax
  800912:	e8 af fc ff ff       	call   8005c6 <getuint>
			base = 8;
  800917:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80091c:	eb 40                	jmp    80095e <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  80091e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800922:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800929:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80092c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800930:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800937:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80093a:	8b 45 14             	mov    0x14(%ebp),%eax
  80093d:	8d 50 04             	lea    0x4(%eax),%edx
  800940:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800943:	8b 00                	mov    (%eax),%eax
  800945:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80094a:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80094f:	eb 0d                	jmp    80095e <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800951:	8d 45 14             	lea    0x14(%ebp),%eax
  800954:	e8 6d fc ff ff       	call   8005c6 <getuint>
			base = 16;
  800959:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80095e:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800962:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800966:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800969:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80096d:	89 74 24 08          	mov    %esi,0x8(%esp)
  800971:	89 04 24             	mov    %eax,(%esp)
  800974:	89 54 24 04          	mov    %edx,0x4(%esp)
  800978:	89 da                	mov    %ebx,%edx
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	e8 7a fb ff ff       	call   8004fc <printnum>
			break;
  800982:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800985:	e9 0d fd ff ff       	jmp    800697 <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  80098a:	8d 45 14             	lea    0x14(%ebp),%eax
  80098d:	e8 6e fc ff ff       	call   800600 <getint>
  800992:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800997:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  80099a:	e9 f8 fc ff ff       	jmp    800697 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80099f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a3:	89 04 24             	mov    %eax,(%esp)
  8009a6:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009a9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009ac:	e9 e6 fc ff ff       	jmp    800697 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009bc:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009bf:	eb 01                	jmp    8009c2 <vprintfmt+0x34e>
  8009c1:	4e                   	dec    %esi
  8009c2:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009c6:	75 f9                	jne    8009c1 <vprintfmt+0x34d>
  8009c8:	e9 ca fc ff ff       	jmp    800697 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009cd:	83 c4 4c             	add    $0x4c,%esp
  8009d0:	5b                   	pop    %ebx
  8009d1:	5e                   	pop    %esi
  8009d2:	5f                   	pop    %edi
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	83 ec 28             	sub    $0x28,%esp
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009e4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009e8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009f2:	85 c0                	test   %eax,%eax
  8009f4:	74 30                	je     800a26 <vsnprintf+0x51>
  8009f6:	85 d2                	test   %edx,%edx
  8009f8:	7e 33                	jle    800a2d <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8009fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a01:	8b 45 10             	mov    0x10(%ebp),%eax
  800a04:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a08:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0f:	c7 04 24 32 06 80 00 	movl   $0x800632,(%esp)
  800a16:	e8 59 fc ff ff       	call   800674 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a1e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a24:	eb 0c                	jmp    800a32 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a26:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a2b:	eb 05                	jmp    800a32 <vsnprintf+0x5d>
  800a2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a32:	c9                   	leave  
  800a33:	c3                   	ret    

00800a34 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a3a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a41:	8b 45 10             	mov    0x10(%ebp),%eax
  800a44:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	89 04 24             	mov    %eax,(%esp)
  800a55:	e8 7b ff ff ff       	call   8009d5 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a5a:	c9                   	leave  
  800a5b:	c3                   	ret    

00800a5c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a62:	b8 00 00 00 00       	mov    $0x0,%eax
  800a67:	eb 01                	jmp    800a6a <strlen+0xe>
		n++;
  800a69:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a6a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a6e:	75 f9                	jne    800a69 <strlen+0xd>
		n++;
	return n;
}
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a78:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a80:	eb 01                	jmp    800a83 <strnlen+0x11>
		n++;
  800a82:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a83:	39 d0                	cmp    %edx,%eax
  800a85:	74 06                	je     800a8d <strnlen+0x1b>
  800a87:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a8b:	75 f5                	jne    800a82 <strnlen+0x10>
		n++;
	return n;
}
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	53                   	push   %ebx
  800a93:	8b 45 08             	mov    0x8(%ebp),%eax
  800a96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a99:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800aa1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800aa4:	42                   	inc    %edx
  800aa5:	84 c9                	test   %cl,%cl
  800aa7:	75 f5                	jne    800a9e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800aa9:	5b                   	pop    %ebx
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	53                   	push   %ebx
  800ab0:	83 ec 08             	sub    $0x8,%esp
  800ab3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ab6:	89 1c 24             	mov    %ebx,(%esp)
  800ab9:	e8 9e ff ff ff       	call   800a5c <strlen>
	strcpy(dst + len, src);
  800abe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ac5:	01 d8                	add    %ebx,%eax
  800ac7:	89 04 24             	mov    %eax,(%esp)
  800aca:	e8 c0 ff ff ff       	call   800a8f <strcpy>
	return dst;
}
  800acf:	89 d8                	mov    %ebx,%eax
  800ad1:	83 c4 08             	add    $0x8,%esp
  800ad4:	5b                   	pop    %ebx
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aea:	eb 0c                	jmp    800af8 <strncpy+0x21>
		*dst++ = *src;
  800aec:	8a 1a                	mov    (%edx),%bl
  800aee:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800af1:	80 3a 01             	cmpb   $0x1,(%edx)
  800af4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800af7:	41                   	inc    %ecx
  800af8:	39 f1                	cmp    %esi,%ecx
  800afa:	75 f0                	jne    800aec <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
  800b05:	8b 75 08             	mov    0x8(%ebp),%esi
  800b08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b0e:	85 d2                	test   %edx,%edx
  800b10:	75 0a                	jne    800b1c <strlcpy+0x1c>
  800b12:	89 f0                	mov    %esi,%eax
  800b14:	eb 1a                	jmp    800b30 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b16:	88 18                	mov    %bl,(%eax)
  800b18:	40                   	inc    %eax
  800b19:	41                   	inc    %ecx
  800b1a:	eb 02                	jmp    800b1e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b1c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b1e:	4a                   	dec    %edx
  800b1f:	74 0a                	je     800b2b <strlcpy+0x2b>
  800b21:	8a 19                	mov    (%ecx),%bl
  800b23:	84 db                	test   %bl,%bl
  800b25:	75 ef                	jne    800b16 <strlcpy+0x16>
  800b27:	89 c2                	mov    %eax,%edx
  800b29:	eb 02                	jmp    800b2d <strlcpy+0x2d>
  800b2b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b2d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b30:	29 f0                	sub    %esi,%eax
}
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b3c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b3f:	eb 02                	jmp    800b43 <strcmp+0xd>
		p++, q++;
  800b41:	41                   	inc    %ecx
  800b42:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b43:	8a 01                	mov    (%ecx),%al
  800b45:	84 c0                	test   %al,%al
  800b47:	74 04                	je     800b4d <strcmp+0x17>
  800b49:	3a 02                	cmp    (%edx),%al
  800b4b:	74 f4                	je     800b41 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b4d:	0f b6 c0             	movzbl %al,%eax
  800b50:	0f b6 12             	movzbl (%edx),%edx
  800b53:	29 d0                	sub    %edx,%eax
}
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	53                   	push   %ebx
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b61:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b64:	eb 03                	jmp    800b69 <strncmp+0x12>
		n--, p++, q++;
  800b66:	4a                   	dec    %edx
  800b67:	40                   	inc    %eax
  800b68:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b69:	85 d2                	test   %edx,%edx
  800b6b:	74 14                	je     800b81 <strncmp+0x2a>
  800b6d:	8a 18                	mov    (%eax),%bl
  800b6f:	84 db                	test   %bl,%bl
  800b71:	74 04                	je     800b77 <strncmp+0x20>
  800b73:	3a 19                	cmp    (%ecx),%bl
  800b75:	74 ef                	je     800b66 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b77:	0f b6 00             	movzbl (%eax),%eax
  800b7a:	0f b6 11             	movzbl (%ecx),%edx
  800b7d:	29 d0                	sub    %edx,%eax
  800b7f:	eb 05                	jmp    800b86 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b81:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b86:	5b                   	pop    %ebx
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b92:	eb 05                	jmp    800b99 <strchr+0x10>
		if (*s == c)
  800b94:	38 ca                	cmp    %cl,%dl
  800b96:	74 0c                	je     800ba4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b98:	40                   	inc    %eax
  800b99:	8a 10                	mov    (%eax),%dl
  800b9b:	84 d2                	test   %dl,%dl
  800b9d:	75 f5                	jne    800b94 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800baf:	eb 05                	jmp    800bb6 <strfind+0x10>
		if (*s == c)
  800bb1:	38 ca                	cmp    %cl,%dl
  800bb3:	74 07                	je     800bbc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bb5:	40                   	inc    %eax
  800bb6:	8a 10                	mov    (%eax),%dl
  800bb8:	84 d2                	test   %dl,%dl
  800bba:	75 f5                	jne    800bb1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bcd:	85 c9                	test   %ecx,%ecx
  800bcf:	74 30                	je     800c01 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bd1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bd7:	75 25                	jne    800bfe <memset+0x40>
  800bd9:	f6 c1 03             	test   $0x3,%cl
  800bdc:	75 20                	jne    800bfe <memset+0x40>
		c &= 0xFF;
  800bde:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800be1:	89 d3                	mov    %edx,%ebx
  800be3:	c1 e3 08             	shl    $0x8,%ebx
  800be6:	89 d6                	mov    %edx,%esi
  800be8:	c1 e6 18             	shl    $0x18,%esi
  800beb:	89 d0                	mov    %edx,%eax
  800bed:	c1 e0 10             	shl    $0x10,%eax
  800bf0:	09 f0                	or     %esi,%eax
  800bf2:	09 d0                	or     %edx,%eax
  800bf4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bf6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bf9:	fc                   	cld    
  800bfa:	f3 ab                	rep stos %eax,%es:(%edi)
  800bfc:	eb 03                	jmp    800c01 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bfe:	fc                   	cld    
  800bff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c01:	89 f8                	mov    %edi,%eax
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c13:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c16:	39 c6                	cmp    %eax,%esi
  800c18:	73 34                	jae    800c4e <memmove+0x46>
  800c1a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c1d:	39 d0                	cmp    %edx,%eax
  800c1f:	73 2d                	jae    800c4e <memmove+0x46>
		s += n;
		d += n;
  800c21:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c24:	f6 c2 03             	test   $0x3,%dl
  800c27:	75 1b                	jne    800c44 <memmove+0x3c>
  800c29:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c2f:	75 13                	jne    800c44 <memmove+0x3c>
  800c31:	f6 c1 03             	test   $0x3,%cl
  800c34:	75 0e                	jne    800c44 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c36:	83 ef 04             	sub    $0x4,%edi
  800c39:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c3c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c3f:	fd                   	std    
  800c40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c42:	eb 07                	jmp    800c4b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c44:	4f                   	dec    %edi
  800c45:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c48:	fd                   	std    
  800c49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c4b:	fc                   	cld    
  800c4c:	eb 20                	jmp    800c6e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c4e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c54:	75 13                	jne    800c69 <memmove+0x61>
  800c56:	a8 03                	test   $0x3,%al
  800c58:	75 0f                	jne    800c69 <memmove+0x61>
  800c5a:	f6 c1 03             	test   $0x3,%cl
  800c5d:	75 0a                	jne    800c69 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c5f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c62:	89 c7                	mov    %eax,%edi
  800c64:	fc                   	cld    
  800c65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c67:	eb 05                	jmp    800c6e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c69:	89 c7                	mov    %eax,%edi
  800c6b:	fc                   	cld    
  800c6c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c78:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c82:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c86:	8b 45 08             	mov    0x8(%ebp),%eax
  800c89:	89 04 24             	mov    %eax,(%esp)
  800c8c:	e8 77 ff ff ff       	call   800c08 <memmove>
}
  800c91:	c9                   	leave  
  800c92:	c3                   	ret    

00800c93 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca7:	eb 16                	jmp    800cbf <memcmp+0x2c>
		if (*s1 != *s2)
  800ca9:	8a 04 17             	mov    (%edi,%edx,1),%al
  800cac:	42                   	inc    %edx
  800cad:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800cb1:	38 c8                	cmp    %cl,%al
  800cb3:	74 0a                	je     800cbf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800cb5:	0f b6 c0             	movzbl %al,%eax
  800cb8:	0f b6 c9             	movzbl %cl,%ecx
  800cbb:	29 c8                	sub    %ecx,%eax
  800cbd:	eb 09                	jmp    800cc8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cbf:	39 da                	cmp    %ebx,%edx
  800cc1:	75 e6                	jne    800ca9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cd6:	89 c2                	mov    %eax,%edx
  800cd8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cdb:	eb 05                	jmp    800ce2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cdd:	38 08                	cmp    %cl,(%eax)
  800cdf:	74 05                	je     800ce6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ce1:	40                   	inc    %eax
  800ce2:	39 d0                	cmp    %edx,%eax
  800ce4:	72 f7                	jb     800cdd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
  800cee:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf4:	eb 01                	jmp    800cf7 <strtol+0xf>
		s++;
  800cf6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf7:	8a 02                	mov    (%edx),%al
  800cf9:	3c 20                	cmp    $0x20,%al
  800cfb:	74 f9                	je     800cf6 <strtol+0xe>
  800cfd:	3c 09                	cmp    $0x9,%al
  800cff:	74 f5                	je     800cf6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d01:	3c 2b                	cmp    $0x2b,%al
  800d03:	75 08                	jne    800d0d <strtol+0x25>
		s++;
  800d05:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d06:	bf 00 00 00 00       	mov    $0x0,%edi
  800d0b:	eb 13                	jmp    800d20 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d0d:	3c 2d                	cmp    $0x2d,%al
  800d0f:	75 0a                	jne    800d1b <strtol+0x33>
		s++, neg = 1;
  800d11:	8d 52 01             	lea    0x1(%edx),%edx
  800d14:	bf 01 00 00 00       	mov    $0x1,%edi
  800d19:	eb 05                	jmp    800d20 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d1b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d20:	85 db                	test   %ebx,%ebx
  800d22:	74 05                	je     800d29 <strtol+0x41>
  800d24:	83 fb 10             	cmp    $0x10,%ebx
  800d27:	75 28                	jne    800d51 <strtol+0x69>
  800d29:	8a 02                	mov    (%edx),%al
  800d2b:	3c 30                	cmp    $0x30,%al
  800d2d:	75 10                	jne    800d3f <strtol+0x57>
  800d2f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d33:	75 0a                	jne    800d3f <strtol+0x57>
		s += 2, base = 16;
  800d35:	83 c2 02             	add    $0x2,%edx
  800d38:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d3d:	eb 12                	jmp    800d51 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d3f:	85 db                	test   %ebx,%ebx
  800d41:	75 0e                	jne    800d51 <strtol+0x69>
  800d43:	3c 30                	cmp    $0x30,%al
  800d45:	75 05                	jne    800d4c <strtol+0x64>
		s++, base = 8;
  800d47:	42                   	inc    %edx
  800d48:	b3 08                	mov    $0x8,%bl
  800d4a:	eb 05                	jmp    800d51 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d4c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d51:	b8 00 00 00 00       	mov    $0x0,%eax
  800d56:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d58:	8a 0a                	mov    (%edx),%cl
  800d5a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d5d:	80 fb 09             	cmp    $0x9,%bl
  800d60:	77 08                	ja     800d6a <strtol+0x82>
			dig = *s - '0';
  800d62:	0f be c9             	movsbl %cl,%ecx
  800d65:	83 e9 30             	sub    $0x30,%ecx
  800d68:	eb 1e                	jmp    800d88 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d6a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d6d:	80 fb 19             	cmp    $0x19,%bl
  800d70:	77 08                	ja     800d7a <strtol+0x92>
			dig = *s - 'a' + 10;
  800d72:	0f be c9             	movsbl %cl,%ecx
  800d75:	83 e9 57             	sub    $0x57,%ecx
  800d78:	eb 0e                	jmp    800d88 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d7a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d7d:	80 fb 19             	cmp    $0x19,%bl
  800d80:	77 12                	ja     800d94 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d82:	0f be c9             	movsbl %cl,%ecx
  800d85:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d88:	39 f1                	cmp    %esi,%ecx
  800d8a:	7d 0c                	jge    800d98 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d8c:	42                   	inc    %edx
  800d8d:	0f af c6             	imul   %esi,%eax
  800d90:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d92:	eb c4                	jmp    800d58 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d94:	89 c1                	mov    %eax,%ecx
  800d96:	eb 02                	jmp    800d9a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d98:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d9a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d9e:	74 05                	je     800da5 <strtol+0xbd>
		*endptr = (char *) s;
  800da0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800da3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800da5:	85 ff                	test   %edi,%edi
  800da7:	74 04                	je     800dad <strtol+0xc5>
  800da9:	89 c8                	mov    %ecx,%eax
  800dab:	f7 d8                	neg    %eax
}
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    
	...

00800db4 <__udivdi3>:
  800db4:	55                   	push   %ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	83 ec 10             	sub    $0x10,%esp
  800dba:	8b 74 24 20          	mov    0x20(%esp),%esi
  800dbe:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800dc2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dc6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800dca:	89 cd                	mov    %ecx,%ebp
  800dcc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	75 2c                	jne    800e00 <__udivdi3+0x4c>
  800dd4:	39 f9                	cmp    %edi,%ecx
  800dd6:	77 68                	ja     800e40 <__udivdi3+0x8c>
  800dd8:	85 c9                	test   %ecx,%ecx
  800dda:	75 0b                	jne    800de7 <__udivdi3+0x33>
  800ddc:	b8 01 00 00 00       	mov    $0x1,%eax
  800de1:	31 d2                	xor    %edx,%edx
  800de3:	f7 f1                	div    %ecx
  800de5:	89 c1                	mov    %eax,%ecx
  800de7:	31 d2                	xor    %edx,%edx
  800de9:	89 f8                	mov    %edi,%eax
  800deb:	f7 f1                	div    %ecx
  800ded:	89 c7                	mov    %eax,%edi
  800def:	89 f0                	mov    %esi,%eax
  800df1:	f7 f1                	div    %ecx
  800df3:	89 c6                	mov    %eax,%esi
  800df5:	89 f0                	mov    %esi,%eax
  800df7:	89 fa                	mov    %edi,%edx
  800df9:	83 c4 10             	add    $0x10,%esp
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    
  800e00:	39 f8                	cmp    %edi,%eax
  800e02:	77 2c                	ja     800e30 <__udivdi3+0x7c>
  800e04:	0f bd f0             	bsr    %eax,%esi
  800e07:	83 f6 1f             	xor    $0x1f,%esi
  800e0a:	75 4c                	jne    800e58 <__udivdi3+0xa4>
  800e0c:	39 f8                	cmp    %edi,%eax
  800e0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800e13:	72 0a                	jb     800e1f <__udivdi3+0x6b>
  800e15:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e19:	0f 87 ad 00 00 00    	ja     800ecc <__udivdi3+0x118>
  800e1f:	be 01 00 00 00       	mov    $0x1,%esi
  800e24:	89 f0                	mov    %esi,%eax
  800e26:	89 fa                	mov    %edi,%edx
  800e28:	83 c4 10             	add    $0x10,%esp
  800e2b:	5e                   	pop    %esi
  800e2c:	5f                   	pop    %edi
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    
  800e2f:	90                   	nop
  800e30:	31 ff                	xor    %edi,%edi
  800e32:	31 f6                	xor    %esi,%esi
  800e34:	89 f0                	mov    %esi,%eax
  800e36:	89 fa                	mov    %edi,%edx
  800e38:	83 c4 10             	add    $0x10,%esp
  800e3b:	5e                   	pop    %esi
  800e3c:	5f                   	pop    %edi
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    
  800e3f:	90                   	nop
  800e40:	89 fa                	mov    %edi,%edx
  800e42:	89 f0                	mov    %esi,%eax
  800e44:	f7 f1                	div    %ecx
  800e46:	89 c6                	mov    %eax,%esi
  800e48:	31 ff                	xor    %edi,%edi
  800e4a:	89 f0                	mov    %esi,%eax
  800e4c:	89 fa                	mov    %edi,%edx
  800e4e:	83 c4 10             	add    $0x10,%esp
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    
  800e55:	8d 76 00             	lea    0x0(%esi),%esi
  800e58:	89 f1                	mov    %esi,%ecx
  800e5a:	d3 e0                	shl    %cl,%eax
  800e5c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e60:	b8 20 00 00 00       	mov    $0x20,%eax
  800e65:	29 f0                	sub    %esi,%eax
  800e67:	89 ea                	mov    %ebp,%edx
  800e69:	88 c1                	mov    %al,%cl
  800e6b:	d3 ea                	shr    %cl,%edx
  800e6d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e71:	09 ca                	or     %ecx,%edx
  800e73:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e77:	89 f1                	mov    %esi,%ecx
  800e79:	d3 e5                	shl    %cl,%ebp
  800e7b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800e7f:	89 fd                	mov    %edi,%ebp
  800e81:	88 c1                	mov    %al,%cl
  800e83:	d3 ed                	shr    %cl,%ebp
  800e85:	89 fa                	mov    %edi,%edx
  800e87:	89 f1                	mov    %esi,%ecx
  800e89:	d3 e2                	shl    %cl,%edx
  800e8b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e8f:	88 c1                	mov    %al,%cl
  800e91:	d3 ef                	shr    %cl,%edi
  800e93:	09 d7                	or     %edx,%edi
  800e95:	89 f8                	mov    %edi,%eax
  800e97:	89 ea                	mov    %ebp,%edx
  800e99:	f7 74 24 08          	divl   0x8(%esp)
  800e9d:	89 d1                	mov    %edx,%ecx
  800e9f:	89 c7                	mov    %eax,%edi
  800ea1:	f7 64 24 0c          	mull   0xc(%esp)
  800ea5:	39 d1                	cmp    %edx,%ecx
  800ea7:	72 17                	jb     800ec0 <__udivdi3+0x10c>
  800ea9:	74 09                	je     800eb4 <__udivdi3+0x100>
  800eab:	89 fe                	mov    %edi,%esi
  800ead:	31 ff                	xor    %edi,%edi
  800eaf:	e9 41 ff ff ff       	jmp    800df5 <__udivdi3+0x41>
  800eb4:	8b 54 24 04          	mov    0x4(%esp),%edx
  800eb8:	89 f1                	mov    %esi,%ecx
  800eba:	d3 e2                	shl    %cl,%edx
  800ebc:	39 c2                	cmp    %eax,%edx
  800ebe:	73 eb                	jae    800eab <__udivdi3+0xf7>
  800ec0:	8d 77 ff             	lea    -0x1(%edi),%esi
  800ec3:	31 ff                	xor    %edi,%edi
  800ec5:	e9 2b ff ff ff       	jmp    800df5 <__udivdi3+0x41>
  800eca:	66 90                	xchg   %ax,%ax
  800ecc:	31 f6                	xor    %esi,%esi
  800ece:	e9 22 ff ff ff       	jmp    800df5 <__udivdi3+0x41>
	...

00800ed4 <__umoddi3>:
  800ed4:	55                   	push   %ebp
  800ed5:	57                   	push   %edi
  800ed6:	56                   	push   %esi
  800ed7:	83 ec 20             	sub    $0x20,%esp
  800eda:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ede:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800ee2:	89 44 24 14          	mov    %eax,0x14(%esp)
  800ee6:	8b 74 24 34          	mov    0x34(%esp),%esi
  800eea:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800eee:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800ef2:	89 c7                	mov    %eax,%edi
  800ef4:	89 f2                	mov    %esi,%edx
  800ef6:	85 ed                	test   %ebp,%ebp
  800ef8:	75 16                	jne    800f10 <__umoddi3+0x3c>
  800efa:	39 f1                	cmp    %esi,%ecx
  800efc:	0f 86 a6 00 00 00    	jbe    800fa8 <__umoddi3+0xd4>
  800f02:	f7 f1                	div    %ecx
  800f04:	89 d0                	mov    %edx,%eax
  800f06:	31 d2                	xor    %edx,%edx
  800f08:	83 c4 20             	add    $0x20,%esp
  800f0b:	5e                   	pop    %esi
  800f0c:	5f                   	pop    %edi
  800f0d:	5d                   	pop    %ebp
  800f0e:	c3                   	ret    
  800f0f:	90                   	nop
  800f10:	39 f5                	cmp    %esi,%ebp
  800f12:	0f 87 ac 00 00 00    	ja     800fc4 <__umoddi3+0xf0>
  800f18:	0f bd c5             	bsr    %ebp,%eax
  800f1b:	83 f0 1f             	xor    $0x1f,%eax
  800f1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f22:	0f 84 a8 00 00 00    	je     800fd0 <__umoddi3+0xfc>
  800f28:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f2c:	d3 e5                	shl    %cl,%ebp
  800f2e:	bf 20 00 00 00       	mov    $0x20,%edi
  800f33:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800f37:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f3b:	89 f9                	mov    %edi,%ecx
  800f3d:	d3 e8                	shr    %cl,%eax
  800f3f:	09 e8                	or     %ebp,%eax
  800f41:	89 44 24 18          	mov    %eax,0x18(%esp)
  800f45:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f49:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f4d:	d3 e0                	shl    %cl,%eax
  800f4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f53:	89 f2                	mov    %esi,%edx
  800f55:	d3 e2                	shl    %cl,%edx
  800f57:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f5b:	d3 e0                	shl    %cl,%eax
  800f5d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800f61:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f65:	89 f9                	mov    %edi,%ecx
  800f67:	d3 e8                	shr    %cl,%eax
  800f69:	09 d0                	or     %edx,%eax
  800f6b:	d3 ee                	shr    %cl,%esi
  800f6d:	89 f2                	mov    %esi,%edx
  800f6f:	f7 74 24 18          	divl   0x18(%esp)
  800f73:	89 d6                	mov    %edx,%esi
  800f75:	f7 64 24 0c          	mull   0xc(%esp)
  800f79:	89 c5                	mov    %eax,%ebp
  800f7b:	89 d1                	mov    %edx,%ecx
  800f7d:	39 d6                	cmp    %edx,%esi
  800f7f:	72 67                	jb     800fe8 <__umoddi3+0x114>
  800f81:	74 75                	je     800ff8 <__umoddi3+0x124>
  800f83:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f87:	29 e8                	sub    %ebp,%eax
  800f89:	19 ce                	sbb    %ecx,%esi
  800f8b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f8f:	d3 e8                	shr    %cl,%eax
  800f91:	89 f2                	mov    %esi,%edx
  800f93:	89 f9                	mov    %edi,%ecx
  800f95:	d3 e2                	shl    %cl,%edx
  800f97:	09 d0                	or     %edx,%eax
  800f99:	89 f2                	mov    %esi,%edx
  800f9b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f9f:	d3 ea                	shr    %cl,%edx
  800fa1:	83 c4 20             	add    $0x20,%esp
  800fa4:	5e                   	pop    %esi
  800fa5:	5f                   	pop    %edi
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    
  800fa8:	85 c9                	test   %ecx,%ecx
  800faa:	75 0b                	jne    800fb7 <__umoddi3+0xe3>
  800fac:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb1:	31 d2                	xor    %edx,%edx
  800fb3:	f7 f1                	div    %ecx
  800fb5:	89 c1                	mov    %eax,%ecx
  800fb7:	89 f0                	mov    %esi,%eax
  800fb9:	31 d2                	xor    %edx,%edx
  800fbb:	f7 f1                	div    %ecx
  800fbd:	89 f8                	mov    %edi,%eax
  800fbf:	e9 3e ff ff ff       	jmp    800f02 <__umoddi3+0x2e>
  800fc4:	89 f2                	mov    %esi,%edx
  800fc6:	83 c4 20             	add    $0x20,%esp
  800fc9:	5e                   	pop    %esi
  800fca:	5f                   	pop    %edi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    
  800fcd:	8d 76 00             	lea    0x0(%esi),%esi
  800fd0:	39 f5                	cmp    %esi,%ebp
  800fd2:	72 04                	jb     800fd8 <__umoddi3+0x104>
  800fd4:	39 f9                	cmp    %edi,%ecx
  800fd6:	77 06                	ja     800fde <__umoddi3+0x10a>
  800fd8:	89 f2                	mov    %esi,%edx
  800fda:	29 cf                	sub    %ecx,%edi
  800fdc:	19 ea                	sbb    %ebp,%edx
  800fde:	89 f8                	mov    %edi,%eax
  800fe0:	83 c4 20             	add    $0x20,%esp
  800fe3:	5e                   	pop    %esi
  800fe4:	5f                   	pop    %edi
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    
  800fe7:	90                   	nop
  800fe8:	89 d1                	mov    %edx,%ecx
  800fea:	89 c5                	mov    %eax,%ebp
  800fec:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800ff0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800ff4:	eb 8d                	jmp    800f83 <__umoddi3+0xaf>
  800ff6:	66 90                	xchg   %ax,%ax
  800ff8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800ffc:	72 ea                	jb     800fe8 <__umoddi3+0x114>
  800ffe:	89 f1                	mov    %esi,%ecx
  801000:	eb 81                	jmp    800f83 <__umoddi3+0xaf>
