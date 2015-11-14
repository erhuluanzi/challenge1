
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0xf0100000 = 0;
  800037:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
	...

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	56                   	push   %esi
  800048:	53                   	push   %ebx
  800049:	83 ec 10             	sub    $0x10,%esp
  80004c:	8b 75 08             	mov    0x8(%ebp),%esi
  80004f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800052:	e8 e0 00 00 00       	call   800137 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	8d 14 80             	lea    (%eax,%eax,4),%edx
  80005f:	8d 14 90             	lea    (%eax,%edx,4),%edx
  800062:	8d 04 50             	lea    (%eax,%edx,2),%eax
  800065:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  80006c:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800071:	85 f6                	test   %esi,%esi
  800073:	7e 07                	jle    80007c <libmain+0x38>
		binaryname = argv[0];
  800075:	8b 03                	mov    (%ebx),%eax
  800077:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800080:	89 34 24             	mov    %esi,(%esp)
  800083:	e8 ac ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800088:	e8 07 00 00 00       	call   800094 <exit>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a1:	e8 3f 00 00 00       	call   8000e5 <sys_env_destroy>
}
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	57                   	push   %edi
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b9:	89 c3                	mov    %eax,%ebx
  8000bb:	89 c7                	mov    %eax,%edi
  8000bd:	89 c6                	mov    %eax,%esi
  8000bf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c1:	5b                   	pop    %ebx
  8000c2:	5e                   	pop    %esi
  8000c3:	5f                   	pop    %edi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	57                   	push   %edi
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d6:	89 d1                	mov    %edx,%ecx
  8000d8:	89 d3                	mov    %edx,%ebx
  8000da:	89 d7                	mov    %edx,%edi
  8000dc:	89 d6                	mov    %edx,%esi
  8000de:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e0:	5b                   	pop    %ebx
  8000e1:	5e                   	pop    %esi
  8000e2:	5f                   	pop    %edi
  8000e3:	5d                   	pop    %ebp
  8000e4:	c3                   	ret    

008000e5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	57                   	push   %edi
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f3:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fb:	89 cb                	mov    %ecx,%ebx
  8000fd:	89 cf                	mov    %ecx,%edi
  8000ff:	89 ce                	mov    %ecx,%esi
  800101:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800103:	85 c0                	test   %eax,%eax
  800105:	7e 28                	jle    80012f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800107:	89 44 24 10          	mov    %eax,0x10(%esp)
  80010b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800112:	00 
  800113:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  80011a:	00 
  80011b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800122:	00 
  800123:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  80012a:	e8 5d 02 00 00       	call   80038c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012f:	83 c4 2c             	add    $0x2c,%esp
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 02 00 00 00       	mov    $0x2,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_yield>:

void
sys_yield(void)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015c:	ba 00 00 00 00       	mov    $0x0,%edx
  800161:	b8 0a 00 00 00       	mov    $0xa,%eax
  800166:	89 d1                	mov    %edx,%ecx
  800168:	89 d3                	mov    %edx,%ebx
  80016a:	89 d7                	mov    %edx,%edi
  80016c:	89 d6                	mov    %edx,%esi
  80016e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800170:	5b                   	pop    %ebx
  800171:	5e                   	pop    %esi
  800172:	5f                   	pop    %edi
  800173:	5d                   	pop    %ebp
  800174:	c3                   	ret    

00800175 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	57                   	push   %edi
  800179:	56                   	push   %esi
  80017a:	53                   	push   %ebx
  80017b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017e:	be 00 00 00 00       	mov    $0x0,%esi
  800183:	b8 04 00 00 00       	mov    $0x4,%eax
  800188:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018e:	8b 55 08             	mov    0x8(%ebp),%edx
  800191:	89 f7                	mov    %esi,%edi
  800193:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800195:	85 c0                	test   %eax,%eax
  800197:	7e 28                	jle    8001c1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800199:	89 44 24 10          	mov    %eax,0x10(%esp)
  80019d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001a4:	00 
  8001a5:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8001ac:	00 
  8001ad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001b4:	00 
  8001b5:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  8001bc:	e8 cb 01 00 00       	call   80038c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c1:	83 c4 2c             	add    $0x2c,%esp
  8001c4:	5b                   	pop    %ebx
  8001c5:	5e                   	pop    %esi
  8001c6:	5f                   	pop    %edi
  8001c7:	5d                   	pop    %ebp
  8001c8:	c3                   	ret    

008001c9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	57                   	push   %edi
  8001cd:	56                   	push   %esi
  8001ce:	53                   	push   %ebx
  8001cf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001da:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e8:	85 c0                	test   %eax,%eax
  8001ea:	7e 28                	jle    800214 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ec:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001f7:	00 
  8001f8:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8001ff:	00 
  800200:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800207:	00 
  800208:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  80020f:	e8 78 01 00 00       	call   80038c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800214:	83 c4 2c             	add    $0x2c,%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	b8 06 00 00 00       	mov    $0x6,%eax
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7e 28                	jle    800267 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800243:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80024a:	00 
  80024b:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  800252:	00 
  800253:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80025a:	00 
  80025b:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  800262:	e8 25 01 00 00       	call   80038c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800267:	83 c4 2c             	add    $0x2c,%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	b8 08 00 00 00       	mov    $0x8,%eax
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7e 28                	jle    8002ba <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	89 44 24 10          	mov    %eax,0x10(%esp)
  800296:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80029d:	00 
  80029e:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8002a5:	00 
  8002a6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002ad:	00 
  8002ae:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  8002b5:	e8 d2 00 00 00       	call   80038c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ba:	83 c4 2c             	add    $0x2c,%esp
  8002bd:	5b                   	pop    %ebx
  8002be:	5e                   	pop    %esi
  8002bf:	5f                   	pop    %edi
  8002c0:	5d                   	pop    %ebp
  8002c1:	c3                   	ret    

008002c2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	57                   	push   %edi
  8002c6:	56                   	push   %esi
  8002c7:	53                   	push   %ebx
  8002c8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d0:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002db:	89 df                	mov    %ebx,%edi
  8002dd:	89 de                	mov    %ebx,%esi
  8002df:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	7e 28                	jle    80030d <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002e9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f0:	00 
  8002f1:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8002f8:	00 
  8002f9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800300:	00 
  800301:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  800308:	e8 7f 00 00 00       	call   80038c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80030d:	83 c4 2c             	add    $0x2c,%esp
  800310:	5b                   	pop    %ebx
  800311:	5e                   	pop    %esi
  800312:	5f                   	pop    %edi
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	57                   	push   %edi
  800319:	56                   	push   %esi
  80031a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031b:	be 00 00 00 00       	mov    $0x0,%esi
  800320:	b8 0b 00 00 00       	mov    $0xb,%eax
  800325:	8b 7d 14             	mov    0x14(%ebp),%edi
  800328:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80032b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032e:	8b 55 08             	mov    0x8(%ebp),%edx
  800331:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800333:	5b                   	pop    %ebx
  800334:	5e                   	pop    %esi
  800335:	5f                   	pop    %edi
  800336:	5d                   	pop    %ebp
  800337:	c3                   	ret    

00800338 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	57                   	push   %edi
  80033c:	56                   	push   %esi
  80033d:	53                   	push   %ebx
  80033e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800341:	b9 00 00 00 00       	mov    $0x0,%ecx
  800346:	b8 0c 00 00 00       	mov    $0xc,%eax
  80034b:	8b 55 08             	mov    0x8(%ebp),%edx
  80034e:	89 cb                	mov    %ecx,%ebx
  800350:	89 cf                	mov    %ecx,%edi
  800352:	89 ce                	mov    %ecx,%esi
  800354:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800356:	85 c0                	test   %eax,%eax
  800358:	7e 28                	jle    800382 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80035e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800365:	00 
  800366:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  80036d:	00 
  80036e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800375:	00 
  800376:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  80037d:	e8 0a 00 00 00       	call   80038c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800382:	83 c4 2c             	add    $0x2c,%esp
  800385:	5b                   	pop    %ebx
  800386:	5e                   	pop    %esi
  800387:	5f                   	pop    %edi
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    
	...

0080038c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	56                   	push   %esi
  800390:	53                   	push   %ebx
  800391:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800394:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800397:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80039d:	e8 95 fd ff ff       	call   800137 <sys_getenvid>
  8003a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b8:	c7 04 24 f8 0f 80 00 	movl   $0x800ff8,(%esp)
  8003bf:	e8 c0 00 00 00       	call   800484 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8003cb:	89 04 24             	mov    %eax,(%esp)
  8003ce:	e8 50 00 00 00       	call   800423 <vcprintf>
	cprintf("\n");
  8003d3:	c7 04 24 1c 10 80 00 	movl   $0x80101c,(%esp)
  8003da:	e8 a5 00 00 00       	call   800484 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003df:	cc                   	int3   
  8003e0:	eb fd                	jmp    8003df <_panic+0x53>
	...

008003e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	53                   	push   %ebx
  8003e8:	83 ec 14             	sub    $0x14,%esp
  8003eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ee:	8b 03                	mov    (%ebx),%eax
  8003f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003f7:	40                   	inc    %eax
  8003f8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ff:	75 19                	jne    80041a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800401:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800408:	00 
  800409:	8d 43 08             	lea    0x8(%ebx),%eax
  80040c:	89 04 24             	mov    %eax,(%esp)
  80040f:	e8 94 fc ff ff       	call   8000a8 <sys_cputs>
		b->idx = 0;
  800414:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80041a:	ff 43 04             	incl   0x4(%ebx)
}
  80041d:	83 c4 14             	add    $0x14,%esp
  800420:	5b                   	pop    %ebx
  800421:	5d                   	pop    %ebp
  800422:	c3                   	ret    

00800423 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80042c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800433:	00 00 00 
	b.cnt = 0;
  800436:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80043d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800440:	8b 45 0c             	mov    0xc(%ebp),%eax
  800443:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800447:	8b 45 08             	mov    0x8(%ebp),%eax
  80044a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800454:	89 44 24 04          	mov    %eax,0x4(%esp)
  800458:	c7 04 24 e4 03 80 00 	movl   $0x8003e4,(%esp)
  80045f:	e8 b4 01 00 00       	call   800618 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800464:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80046a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800474:	89 04 24             	mov    %eax,(%esp)
  800477:	e8 2c fc ff ff       	call   8000a8 <sys_cputs>

	return b.cnt;
}
  80047c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80048a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80048d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800491:	8b 45 08             	mov    0x8(%ebp),%eax
  800494:	89 04 24             	mov    %eax,(%esp)
  800497:	e8 87 ff ff ff       	call   800423 <vcprintf>
	va_end(ap);

	return cnt;
}
  80049c:	c9                   	leave  
  80049d:	c3                   	ret    
	...

008004a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004a0:	55                   	push   %ebp
  8004a1:	89 e5                	mov    %esp,%ebp
  8004a3:	57                   	push   %edi
  8004a4:	56                   	push   %esi
  8004a5:	53                   	push   %ebx
  8004a6:	83 ec 3c             	sub    $0x3c,%esp
  8004a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ac:	89 d7                	mov    %edx,%edi
  8004ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004bd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	75 08                	jne    8004cc <printnum+0x2c>
  8004c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004c7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004ca:	77 57                	ja     800523 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004cc:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004d0:	4b                   	dec    %ebx
  8004d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004dc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004e0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004e4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004eb:	00 
  8004ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ef:	89 04 24             	mov    %eax,(%esp)
  8004f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f9:	e8 5a 08 00 00       	call   800d58 <__udivdi3>
  8004fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800502:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800506:	89 04 24             	mov    %eax,(%esp)
  800509:	89 54 24 04          	mov    %edx,0x4(%esp)
  80050d:	89 fa                	mov    %edi,%edx
  80050f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800512:	e8 89 ff ff ff       	call   8004a0 <printnum>
  800517:	eb 0f                	jmp    800528 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800519:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051d:	89 34 24             	mov    %esi,(%esp)
  800520:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800523:	4b                   	dec    %ebx
  800524:	85 db                	test   %ebx,%ebx
  800526:	7f f1                	jg     800519 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800528:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800530:	8b 45 10             	mov    0x10(%ebp),%eax
  800533:	89 44 24 08          	mov    %eax,0x8(%esp)
  800537:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80053e:	00 
  80053f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800542:	89 04 24             	mov    %eax,(%esp)
  800545:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800548:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054c:	e8 27 09 00 00       	call   800e78 <__umoddi3>
  800551:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800555:	0f be 80 1e 10 80 00 	movsbl 0x80101e(%eax),%eax
  80055c:	89 04 24             	mov    %eax,(%esp)
  80055f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800562:	83 c4 3c             	add    $0x3c,%esp
  800565:	5b                   	pop    %ebx
  800566:	5e                   	pop    %esi
  800567:	5f                   	pop    %edi
  800568:	5d                   	pop    %ebp
  800569:	c3                   	ret    

0080056a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80056a:	55                   	push   %ebp
  80056b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80056d:	83 fa 01             	cmp    $0x1,%edx
  800570:	7e 0e                	jle    800580 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800572:	8b 10                	mov    (%eax),%edx
  800574:	8d 4a 08             	lea    0x8(%edx),%ecx
  800577:	89 08                	mov    %ecx,(%eax)
  800579:	8b 02                	mov    (%edx),%eax
  80057b:	8b 52 04             	mov    0x4(%edx),%edx
  80057e:	eb 22                	jmp    8005a2 <getuint+0x38>
	else if (lflag)
  800580:	85 d2                	test   %edx,%edx
  800582:	74 10                	je     800594 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800584:	8b 10                	mov    (%eax),%edx
  800586:	8d 4a 04             	lea    0x4(%edx),%ecx
  800589:	89 08                	mov    %ecx,(%eax)
  80058b:	8b 02                	mov    (%edx),%eax
  80058d:	ba 00 00 00 00       	mov    $0x0,%edx
  800592:	eb 0e                	jmp    8005a2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800594:	8b 10                	mov    (%eax),%edx
  800596:	8d 4a 04             	lea    0x4(%edx),%ecx
  800599:	89 08                	mov    %ecx,(%eax)
  80059b:	8b 02                	mov    (%edx),%eax
  80059d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005a2:	5d                   	pop    %ebp
  8005a3:	c3                   	ret    

008005a4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8005a4:	55                   	push   %ebp
  8005a5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005a7:	83 fa 01             	cmp    $0x1,%edx
  8005aa:	7e 0e                	jle    8005ba <getint+0x16>
		return va_arg(*ap, long long);
  8005ac:	8b 10                	mov    (%eax),%edx
  8005ae:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005b1:	89 08                	mov    %ecx,(%eax)
  8005b3:	8b 02                	mov    (%edx),%eax
  8005b5:	8b 52 04             	mov    0x4(%edx),%edx
  8005b8:	eb 1a                	jmp    8005d4 <getint+0x30>
	else if (lflag)
  8005ba:	85 d2                	test   %edx,%edx
  8005bc:	74 0c                	je     8005ca <getint+0x26>
		return va_arg(*ap, long);
  8005be:	8b 10                	mov    (%eax),%edx
  8005c0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005c3:	89 08                	mov    %ecx,(%eax)
  8005c5:	8b 02                	mov    (%edx),%eax
  8005c7:	99                   	cltd   
  8005c8:	eb 0a                	jmp    8005d4 <getint+0x30>
	else
		return va_arg(*ap, int);
  8005ca:	8b 10                	mov    (%eax),%edx
  8005cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005cf:	89 08                	mov    %ecx,(%eax)
  8005d1:	8b 02                	mov    (%edx),%eax
  8005d3:	99                   	cltd   
}
  8005d4:	5d                   	pop    %ebp
  8005d5:	c3                   	ret    

008005d6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005d6:	55                   	push   %ebp
  8005d7:	89 e5                	mov    %esp,%ebp
  8005d9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005dc:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005df:	8b 10                	mov    (%eax),%edx
  8005e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8005e4:	73 08                	jae    8005ee <sprintputch+0x18>
		*b->buf++ = ch;
  8005e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005e9:	88 0a                	mov    %cl,(%edx)
  8005eb:	42                   	inc    %edx
  8005ec:	89 10                	mov    %edx,(%eax)
}
  8005ee:	5d                   	pop    %ebp
  8005ef:	c3                   	ret    

008005f0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005f0:	55                   	push   %ebp
  8005f1:	89 e5                	mov    %esp,%ebp
  8005f3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005f6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005fd:	8b 45 10             	mov    0x10(%ebp),%eax
  800600:	89 44 24 08          	mov    %eax,0x8(%esp)
  800604:	8b 45 0c             	mov    0xc(%ebp),%eax
  800607:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060b:	8b 45 08             	mov    0x8(%ebp),%eax
  80060e:	89 04 24             	mov    %eax,(%esp)
  800611:	e8 02 00 00 00       	call   800618 <vprintfmt>
	va_end(ap);
}
  800616:	c9                   	leave  
  800617:	c3                   	ret    

00800618 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800618:	55                   	push   %ebp
  800619:	89 e5                	mov    %esp,%ebp
  80061b:	57                   	push   %edi
  80061c:	56                   	push   %esi
  80061d:	53                   	push   %ebx
  80061e:	83 ec 4c             	sub    $0x4c,%esp
  800621:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800624:	8b 75 10             	mov    0x10(%ebp),%esi
  800627:	eb 12                	jmp    80063b <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800629:	85 c0                	test   %eax,%eax
  80062b:	0f 84 40 03 00 00    	je     800971 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800631:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800635:	89 04 24             	mov    %eax,(%esp)
  800638:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80063b:	0f b6 06             	movzbl (%esi),%eax
  80063e:	46                   	inc    %esi
  80063f:	83 f8 25             	cmp    $0x25,%eax
  800642:	75 e5                	jne    800629 <vprintfmt+0x11>
  800644:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800648:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80064f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800654:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80065b:	ba 00 00 00 00       	mov    $0x0,%edx
  800660:	eb 26                	jmp    800688 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800662:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800665:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800669:	eb 1d                	jmp    800688 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80066e:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800672:	eb 14                	jmp    800688 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800674:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800677:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80067e:	eb 08                	jmp    800688 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800680:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800683:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800688:	0f b6 06             	movzbl (%esi),%eax
  80068b:	8d 4e 01             	lea    0x1(%esi),%ecx
  80068e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800691:	8a 0e                	mov    (%esi),%cl
  800693:	83 e9 23             	sub    $0x23,%ecx
  800696:	80 f9 55             	cmp    $0x55,%cl
  800699:	0f 87 b6 02 00 00    	ja     800955 <vprintfmt+0x33d>
  80069f:	0f b6 c9             	movzbl %cl,%ecx
  8006a2:	ff 24 8d e0 10 80 00 	jmp    *0x8010e0(,%ecx,4)
  8006a9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ac:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006b1:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  8006b4:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  8006b8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006bb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8006be:	83 f9 09             	cmp    $0x9,%ecx
  8006c1:	77 2a                	ja     8006ed <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006c3:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006c4:	eb eb                	jmp    8006b1 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 48 04             	lea    0x4(%eax),%ecx
  8006cc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006cf:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006d4:	eb 17                	jmp    8006ed <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006d6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006da:	78 98                	js     800674 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006df:	eb a7                	jmp    800688 <vprintfmt+0x70>
  8006e1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006e4:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006eb:	eb 9b                	jmp    800688 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006ed:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006f1:	79 95                	jns    800688 <vprintfmt+0x70>
  8006f3:	eb 8b                	jmp    800680 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006f5:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006f9:	eb 8d                	jmp    800688 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fe:	8d 50 04             	lea    0x4(%eax),%edx
  800701:	89 55 14             	mov    %edx,0x14(%ebp)
  800704:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800708:	8b 00                	mov    (%eax),%eax
  80070a:	89 04 24             	mov    %eax,(%esp)
  80070d:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800710:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800713:	e9 23 ff ff ff       	jmp    80063b <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8d 50 04             	lea    0x4(%eax),%edx
  80071e:	89 55 14             	mov    %edx,0x14(%ebp)
  800721:	8b 00                	mov    (%eax),%eax
  800723:	85 c0                	test   %eax,%eax
  800725:	79 02                	jns    800729 <vprintfmt+0x111>
  800727:	f7 d8                	neg    %eax
  800729:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80072b:	83 f8 09             	cmp    $0x9,%eax
  80072e:	7f 0b                	jg     80073b <vprintfmt+0x123>
  800730:	8b 04 85 40 12 80 00 	mov    0x801240(,%eax,4),%eax
  800737:	85 c0                	test   %eax,%eax
  800739:	75 23                	jne    80075e <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80073b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80073f:	c7 44 24 08 36 10 80 	movl   $0x801036,0x8(%esp)
  800746:	00 
  800747:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074b:	8b 45 08             	mov    0x8(%ebp),%eax
  80074e:	89 04 24             	mov    %eax,(%esp)
  800751:	e8 9a fe ff ff       	call   8005f0 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800756:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800759:	e9 dd fe ff ff       	jmp    80063b <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80075e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800762:	c7 44 24 08 3f 10 80 	movl   $0x80103f,0x8(%esp)
  800769:	00 
  80076a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076e:	8b 55 08             	mov    0x8(%ebp),%edx
  800771:	89 14 24             	mov    %edx,(%esp)
  800774:	e8 77 fe ff ff       	call   8005f0 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800779:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80077c:	e9 ba fe ff ff       	jmp    80063b <vprintfmt+0x23>
  800781:	89 f9                	mov    %edi,%ecx
  800783:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800786:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800789:	8b 45 14             	mov    0x14(%ebp),%eax
  80078c:	8d 50 04             	lea    0x4(%eax),%edx
  80078f:	89 55 14             	mov    %edx,0x14(%ebp)
  800792:	8b 30                	mov    (%eax),%esi
  800794:	85 f6                	test   %esi,%esi
  800796:	75 05                	jne    80079d <vprintfmt+0x185>
				p = "(null)";
  800798:	be 2f 10 80 00       	mov    $0x80102f,%esi
			if (width > 0 && padc != '-')
  80079d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a1:	0f 8e 84 00 00 00    	jle    80082b <vprintfmt+0x213>
  8007a7:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007ab:	74 7e                	je     80082b <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ad:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007b1:	89 34 24             	mov    %esi,(%esp)
  8007b4:	e8 5d 02 00 00       	call   800a16 <strnlen>
  8007b9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007bc:	29 c2                	sub    %eax,%edx
  8007be:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8007c1:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8007c5:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007c8:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007cb:	89 de                	mov    %ebx,%esi
  8007cd:	89 d3                	mov    %edx,%ebx
  8007cf:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d1:	eb 0b                	jmp    8007de <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d7:	89 3c 24             	mov    %edi,(%esp)
  8007da:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007dd:	4b                   	dec    %ebx
  8007de:	85 db                	test   %ebx,%ebx
  8007e0:	7f f1                	jg     8007d3 <vprintfmt+0x1bb>
  8007e2:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007e5:	89 f3                	mov    %esi,%ebx
  8007e7:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007ed:	85 c0                	test   %eax,%eax
  8007ef:	79 05                	jns    8007f6 <vprintfmt+0x1de>
  8007f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007f9:	29 c2                	sub    %eax,%edx
  8007fb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007fe:	eb 2b                	jmp    80082b <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800800:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800804:	74 18                	je     80081e <vprintfmt+0x206>
  800806:	8d 50 e0             	lea    -0x20(%eax),%edx
  800809:	83 fa 5e             	cmp    $0x5e,%edx
  80080c:	76 10                	jbe    80081e <vprintfmt+0x206>
					putch('?', putdat);
  80080e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800812:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800819:	ff 55 08             	call   *0x8(%ebp)
  80081c:	eb 0a                	jmp    800828 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80081e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800822:	89 04 24             	mov    %eax,(%esp)
  800825:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800828:	ff 4d e4             	decl   -0x1c(%ebp)
  80082b:	0f be 06             	movsbl (%esi),%eax
  80082e:	46                   	inc    %esi
  80082f:	85 c0                	test   %eax,%eax
  800831:	74 21                	je     800854 <vprintfmt+0x23c>
  800833:	85 ff                	test   %edi,%edi
  800835:	78 c9                	js     800800 <vprintfmt+0x1e8>
  800837:	4f                   	dec    %edi
  800838:	79 c6                	jns    800800 <vprintfmt+0x1e8>
  80083a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80083d:	89 de                	mov    %ebx,%esi
  80083f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800842:	eb 18                	jmp    80085c <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800844:	89 74 24 04          	mov    %esi,0x4(%esp)
  800848:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80084f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800851:	4b                   	dec    %ebx
  800852:	eb 08                	jmp    80085c <vprintfmt+0x244>
  800854:	8b 7d 08             	mov    0x8(%ebp),%edi
  800857:	89 de                	mov    %ebx,%esi
  800859:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80085c:	85 db                	test   %ebx,%ebx
  80085e:	7f e4                	jg     800844 <vprintfmt+0x22c>
  800860:	89 7d 08             	mov    %edi,0x8(%ebp)
  800863:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800865:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800868:	e9 ce fd ff ff       	jmp    80063b <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80086d:	8d 45 14             	lea    0x14(%ebp),%eax
  800870:	e8 2f fd ff ff       	call   8005a4 <getint>
  800875:	89 c6                	mov    %eax,%esi
  800877:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800879:	85 d2                	test   %edx,%edx
  80087b:	78 07                	js     800884 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80087d:	be 0a 00 00 00       	mov    $0xa,%esi
  800882:	eb 7e                	jmp    800902 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800884:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800888:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80088f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800892:	89 f0                	mov    %esi,%eax
  800894:	89 fa                	mov    %edi,%edx
  800896:	f7 d8                	neg    %eax
  800898:	83 d2 00             	adc    $0x0,%edx
  80089b:	f7 da                	neg    %edx
			}
			base = 10;
  80089d:	be 0a 00 00 00       	mov    $0xa,%esi
  8008a2:	eb 5e                	jmp    800902 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a7:	e8 be fc ff ff       	call   80056a <getuint>
			base = 10;
  8008ac:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8008b1:	eb 4f                	jmp    800902 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8008b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b6:	e8 af fc ff ff       	call   80056a <getuint>
			base = 8;
  8008bb:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8008c0:	eb 40                	jmp    800902 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  8008c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008cd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008db:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008de:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e1:	8d 50 04             	lea    0x4(%eax),%edx
  8008e4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008e7:	8b 00                	mov    (%eax),%eax
  8008e9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008ee:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8008f3:	eb 0d                	jmp    800902 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8008f8:	e8 6d fc ff ff       	call   80056a <getuint>
			base = 16;
  8008fd:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800902:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800906:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80090a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80090d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800911:	89 74 24 08          	mov    %esi,0x8(%esp)
  800915:	89 04 24             	mov    %eax,(%esp)
  800918:	89 54 24 04          	mov    %edx,0x4(%esp)
  80091c:	89 da                	mov    %ebx,%edx
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	e8 7a fb ff ff       	call   8004a0 <printnum>
			break;
  800926:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800929:	e9 0d fd ff ff       	jmp    80063b <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  80092e:	8d 45 14             	lea    0x14(%ebp),%eax
  800931:	e8 6e fc ff ff       	call   8005a4 <getint>
  800936:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  80093e:	e9 f8 fc ff ff       	jmp    80063b <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800943:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800947:	89 04 24             	mov    %eax,(%esp)
  80094a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800950:	e9 e6 fc ff ff       	jmp    80063b <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800955:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800959:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800960:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800963:	eb 01                	jmp    800966 <vprintfmt+0x34e>
  800965:	4e                   	dec    %esi
  800966:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80096a:	75 f9                	jne    800965 <vprintfmt+0x34d>
  80096c:	e9 ca fc ff ff       	jmp    80063b <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800971:	83 c4 4c             	add    $0x4c,%esp
  800974:	5b                   	pop    %ebx
  800975:	5e                   	pop    %esi
  800976:	5f                   	pop    %edi
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	83 ec 28             	sub    $0x28,%esp
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800985:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800988:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80098c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80098f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800996:	85 c0                	test   %eax,%eax
  800998:	74 30                	je     8009ca <vsnprintf+0x51>
  80099a:	85 d2                	test   %edx,%edx
  80099c:	7e 33                	jle    8009d1 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80099e:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ac:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b3:	c7 04 24 d6 05 80 00 	movl   $0x8005d6,(%esp)
  8009ba:	e8 59 fc ff ff       	call   800618 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009c2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c8:	eb 0c                	jmp    8009d6 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009cf:	eb 05                	jmp    8009d6 <vsnprintf+0x5d>
  8009d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    

008009d8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009de:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	89 04 24             	mov    %eax,(%esp)
  8009f9:	e8 7b ff ff ff       	call   800979 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0b:	eb 01                	jmp    800a0e <strlen+0xe>
		n++;
  800a0d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a0e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a12:	75 f9                	jne    800a0d <strlen+0xd>
		n++;
	return n;
}
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a1c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a24:	eb 01                	jmp    800a27 <strnlen+0x11>
		n++;
  800a26:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a27:	39 d0                	cmp    %edx,%eax
  800a29:	74 06                	je     800a31 <strnlen+0x1b>
  800a2b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a2f:	75 f5                	jne    800a26 <strnlen+0x10>
		n++;
	return n;
}
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	53                   	push   %ebx
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a42:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a45:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a48:	42                   	inc    %edx
  800a49:	84 c9                	test   %cl,%cl
  800a4b:	75 f5                	jne    800a42 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	53                   	push   %ebx
  800a54:	83 ec 08             	sub    $0x8,%esp
  800a57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a5a:	89 1c 24             	mov    %ebx,(%esp)
  800a5d:	e8 9e ff ff ff       	call   800a00 <strlen>
	strcpy(dst + len, src);
  800a62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a65:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a69:	01 d8                	add    %ebx,%eax
  800a6b:	89 04 24             	mov    %eax,(%esp)
  800a6e:	e8 c0 ff ff ff       	call   800a33 <strcpy>
	return dst;
}
  800a73:	89 d8                	mov    %ebx,%eax
  800a75:	83 c4 08             	add    $0x8,%esp
  800a78:	5b                   	pop    %ebx
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a86:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a89:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8e:	eb 0c                	jmp    800a9c <strncpy+0x21>
		*dst++ = *src;
  800a90:	8a 1a                	mov    (%edx),%bl
  800a92:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a95:	80 3a 01             	cmpb   $0x1,(%edx)
  800a98:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a9b:	41                   	inc    %ecx
  800a9c:	39 f1                	cmp    %esi,%ecx
  800a9e:	75 f0                	jne    800a90 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aa0:	5b                   	pop    %ebx
  800aa1:	5e                   	pop    %esi
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
  800aa9:	8b 75 08             	mov    0x8(%ebp),%esi
  800aac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aaf:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ab2:	85 d2                	test   %edx,%edx
  800ab4:	75 0a                	jne    800ac0 <strlcpy+0x1c>
  800ab6:	89 f0                	mov    %esi,%eax
  800ab8:	eb 1a                	jmp    800ad4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aba:	88 18                	mov    %bl,(%eax)
  800abc:	40                   	inc    %eax
  800abd:	41                   	inc    %ecx
  800abe:	eb 02                	jmp    800ac2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ac0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800ac2:	4a                   	dec    %edx
  800ac3:	74 0a                	je     800acf <strlcpy+0x2b>
  800ac5:	8a 19                	mov    (%ecx),%bl
  800ac7:	84 db                	test   %bl,%bl
  800ac9:	75 ef                	jne    800aba <strlcpy+0x16>
  800acb:	89 c2                	mov    %eax,%edx
  800acd:	eb 02                	jmp    800ad1 <strlcpy+0x2d>
  800acf:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ad1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ad4:	29 f0                	sub    %esi,%eax
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ae3:	eb 02                	jmp    800ae7 <strcmp+0xd>
		p++, q++;
  800ae5:	41                   	inc    %ecx
  800ae6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ae7:	8a 01                	mov    (%ecx),%al
  800ae9:	84 c0                	test   %al,%al
  800aeb:	74 04                	je     800af1 <strcmp+0x17>
  800aed:	3a 02                	cmp    (%edx),%al
  800aef:	74 f4                	je     800ae5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800af1:	0f b6 c0             	movzbl %al,%eax
  800af4:	0f b6 12             	movzbl (%edx),%edx
  800af7:	29 d0                	sub    %edx,%eax
}
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	53                   	push   %ebx
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
  800b02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b05:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b08:	eb 03                	jmp    800b0d <strncmp+0x12>
		n--, p++, q++;
  800b0a:	4a                   	dec    %edx
  800b0b:	40                   	inc    %eax
  800b0c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b0d:	85 d2                	test   %edx,%edx
  800b0f:	74 14                	je     800b25 <strncmp+0x2a>
  800b11:	8a 18                	mov    (%eax),%bl
  800b13:	84 db                	test   %bl,%bl
  800b15:	74 04                	je     800b1b <strncmp+0x20>
  800b17:	3a 19                	cmp    (%ecx),%bl
  800b19:	74 ef                	je     800b0a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b1b:	0f b6 00             	movzbl (%eax),%eax
  800b1e:	0f b6 11             	movzbl (%ecx),%edx
  800b21:	29 d0                	sub    %edx,%eax
  800b23:	eb 05                	jmp    800b2a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b25:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	8b 45 08             	mov    0x8(%ebp),%eax
  800b33:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b36:	eb 05                	jmp    800b3d <strchr+0x10>
		if (*s == c)
  800b38:	38 ca                	cmp    %cl,%dl
  800b3a:	74 0c                	je     800b48 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b3c:	40                   	inc    %eax
  800b3d:	8a 10                	mov    (%eax),%dl
  800b3f:	84 d2                	test   %dl,%dl
  800b41:	75 f5                	jne    800b38 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b50:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b53:	eb 05                	jmp    800b5a <strfind+0x10>
		if (*s == c)
  800b55:	38 ca                	cmp    %cl,%dl
  800b57:	74 07                	je     800b60 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b59:	40                   	inc    %eax
  800b5a:	8a 10                	mov    (%eax),%dl
  800b5c:	84 d2                	test   %dl,%dl
  800b5e:	75 f5                	jne    800b55 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b71:	85 c9                	test   %ecx,%ecx
  800b73:	74 30                	je     800ba5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b75:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b7b:	75 25                	jne    800ba2 <memset+0x40>
  800b7d:	f6 c1 03             	test   $0x3,%cl
  800b80:	75 20                	jne    800ba2 <memset+0x40>
		c &= 0xFF;
  800b82:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b85:	89 d3                	mov    %edx,%ebx
  800b87:	c1 e3 08             	shl    $0x8,%ebx
  800b8a:	89 d6                	mov    %edx,%esi
  800b8c:	c1 e6 18             	shl    $0x18,%esi
  800b8f:	89 d0                	mov    %edx,%eax
  800b91:	c1 e0 10             	shl    $0x10,%eax
  800b94:	09 f0                	or     %esi,%eax
  800b96:	09 d0                	or     %edx,%eax
  800b98:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b9a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b9d:	fc                   	cld    
  800b9e:	f3 ab                	rep stos %eax,%es:(%edi)
  800ba0:	eb 03                	jmp    800ba5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ba2:	fc                   	cld    
  800ba3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ba5:	89 f8                	mov    %edi,%eax
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bba:	39 c6                	cmp    %eax,%esi
  800bbc:	73 34                	jae    800bf2 <memmove+0x46>
  800bbe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bc1:	39 d0                	cmp    %edx,%eax
  800bc3:	73 2d                	jae    800bf2 <memmove+0x46>
		s += n;
		d += n;
  800bc5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc8:	f6 c2 03             	test   $0x3,%dl
  800bcb:	75 1b                	jne    800be8 <memmove+0x3c>
  800bcd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bd3:	75 13                	jne    800be8 <memmove+0x3c>
  800bd5:	f6 c1 03             	test   $0x3,%cl
  800bd8:	75 0e                	jne    800be8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bda:	83 ef 04             	sub    $0x4,%edi
  800bdd:	8d 72 fc             	lea    -0x4(%edx),%esi
  800be0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800be3:	fd                   	std    
  800be4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800be6:	eb 07                	jmp    800bef <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800be8:	4f                   	dec    %edi
  800be9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bec:	fd                   	std    
  800bed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bef:	fc                   	cld    
  800bf0:	eb 20                	jmp    800c12 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bf8:	75 13                	jne    800c0d <memmove+0x61>
  800bfa:	a8 03                	test   $0x3,%al
  800bfc:	75 0f                	jne    800c0d <memmove+0x61>
  800bfe:	f6 c1 03             	test   $0x3,%cl
  800c01:	75 0a                	jne    800c0d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c03:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c06:	89 c7                	mov    %eax,%edi
  800c08:	fc                   	cld    
  800c09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0b:	eb 05                	jmp    800c12 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c0d:	89 c7                	mov    %eax,%edi
  800c0f:	fc                   	cld    
  800c10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c26:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2d:	89 04 24             	mov    %eax,(%esp)
  800c30:	e8 77 ff ff ff       	call   800bac <memmove>
}
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c40:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c46:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4b:	eb 16                	jmp    800c63 <memcmp+0x2c>
		if (*s1 != *s2)
  800c4d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c50:	42                   	inc    %edx
  800c51:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c55:	38 c8                	cmp    %cl,%al
  800c57:	74 0a                	je     800c63 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c59:	0f b6 c0             	movzbl %al,%eax
  800c5c:	0f b6 c9             	movzbl %cl,%ecx
  800c5f:	29 c8                	sub    %ecx,%eax
  800c61:	eb 09                	jmp    800c6c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c63:	39 da                	cmp    %ebx,%edx
  800c65:	75 e6                	jne    800c4d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	8b 45 08             	mov    0x8(%ebp),%eax
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c7a:	89 c2                	mov    %eax,%edx
  800c7c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c7f:	eb 05                	jmp    800c86 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c81:	38 08                	cmp    %cl,(%eax)
  800c83:	74 05                	je     800c8a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c85:	40                   	inc    %eax
  800c86:	39 d0                	cmp    %edx,%eax
  800c88:	72 f7                	jb     800c81 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	8b 55 08             	mov    0x8(%ebp),%edx
  800c95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c98:	eb 01                	jmp    800c9b <strtol+0xf>
		s++;
  800c9a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c9b:	8a 02                	mov    (%edx),%al
  800c9d:	3c 20                	cmp    $0x20,%al
  800c9f:	74 f9                	je     800c9a <strtol+0xe>
  800ca1:	3c 09                	cmp    $0x9,%al
  800ca3:	74 f5                	je     800c9a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ca5:	3c 2b                	cmp    $0x2b,%al
  800ca7:	75 08                	jne    800cb1 <strtol+0x25>
		s++;
  800ca9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800caa:	bf 00 00 00 00       	mov    $0x0,%edi
  800caf:	eb 13                	jmp    800cc4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cb1:	3c 2d                	cmp    $0x2d,%al
  800cb3:	75 0a                	jne    800cbf <strtol+0x33>
		s++, neg = 1;
  800cb5:	8d 52 01             	lea    0x1(%edx),%edx
  800cb8:	bf 01 00 00 00       	mov    $0x1,%edi
  800cbd:	eb 05                	jmp    800cc4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cbf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc4:	85 db                	test   %ebx,%ebx
  800cc6:	74 05                	je     800ccd <strtol+0x41>
  800cc8:	83 fb 10             	cmp    $0x10,%ebx
  800ccb:	75 28                	jne    800cf5 <strtol+0x69>
  800ccd:	8a 02                	mov    (%edx),%al
  800ccf:	3c 30                	cmp    $0x30,%al
  800cd1:	75 10                	jne    800ce3 <strtol+0x57>
  800cd3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cd7:	75 0a                	jne    800ce3 <strtol+0x57>
		s += 2, base = 16;
  800cd9:	83 c2 02             	add    $0x2,%edx
  800cdc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ce1:	eb 12                	jmp    800cf5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ce3:	85 db                	test   %ebx,%ebx
  800ce5:	75 0e                	jne    800cf5 <strtol+0x69>
  800ce7:	3c 30                	cmp    $0x30,%al
  800ce9:	75 05                	jne    800cf0 <strtol+0x64>
		s++, base = 8;
  800ceb:	42                   	inc    %edx
  800cec:	b3 08                	mov    $0x8,%bl
  800cee:	eb 05                	jmp    800cf5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800cf0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cf5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfa:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cfc:	8a 0a                	mov    (%edx),%cl
  800cfe:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d01:	80 fb 09             	cmp    $0x9,%bl
  800d04:	77 08                	ja     800d0e <strtol+0x82>
			dig = *s - '0';
  800d06:	0f be c9             	movsbl %cl,%ecx
  800d09:	83 e9 30             	sub    $0x30,%ecx
  800d0c:	eb 1e                	jmp    800d2c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d0e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d11:	80 fb 19             	cmp    $0x19,%bl
  800d14:	77 08                	ja     800d1e <strtol+0x92>
			dig = *s - 'a' + 10;
  800d16:	0f be c9             	movsbl %cl,%ecx
  800d19:	83 e9 57             	sub    $0x57,%ecx
  800d1c:	eb 0e                	jmp    800d2c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d1e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d21:	80 fb 19             	cmp    $0x19,%bl
  800d24:	77 12                	ja     800d38 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d26:	0f be c9             	movsbl %cl,%ecx
  800d29:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d2c:	39 f1                	cmp    %esi,%ecx
  800d2e:	7d 0c                	jge    800d3c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d30:	42                   	inc    %edx
  800d31:	0f af c6             	imul   %esi,%eax
  800d34:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d36:	eb c4                	jmp    800cfc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d38:	89 c1                	mov    %eax,%ecx
  800d3a:	eb 02                	jmp    800d3e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d3c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d3e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d42:	74 05                	je     800d49 <strtol+0xbd>
		*endptr = (char *) s;
  800d44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d47:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d49:	85 ff                	test   %edi,%edi
  800d4b:	74 04                	je     800d51 <strtol+0xc5>
  800d4d:	89 c8                	mov    %ecx,%eax
  800d4f:	f7 d8                	neg    %eax
}
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    
	...

00800d58 <__udivdi3>:
  800d58:	55                   	push   %ebp
  800d59:	57                   	push   %edi
  800d5a:	56                   	push   %esi
  800d5b:	83 ec 10             	sub    $0x10,%esp
  800d5e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d62:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800d66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d6a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800d6e:	89 cd                	mov    %ecx,%ebp
  800d70:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800d74:	85 c0                	test   %eax,%eax
  800d76:	75 2c                	jne    800da4 <__udivdi3+0x4c>
  800d78:	39 f9                	cmp    %edi,%ecx
  800d7a:	77 68                	ja     800de4 <__udivdi3+0x8c>
  800d7c:	85 c9                	test   %ecx,%ecx
  800d7e:	75 0b                	jne    800d8b <__udivdi3+0x33>
  800d80:	b8 01 00 00 00       	mov    $0x1,%eax
  800d85:	31 d2                	xor    %edx,%edx
  800d87:	f7 f1                	div    %ecx
  800d89:	89 c1                	mov    %eax,%ecx
  800d8b:	31 d2                	xor    %edx,%edx
  800d8d:	89 f8                	mov    %edi,%eax
  800d8f:	f7 f1                	div    %ecx
  800d91:	89 c7                	mov    %eax,%edi
  800d93:	89 f0                	mov    %esi,%eax
  800d95:	f7 f1                	div    %ecx
  800d97:	89 c6                	mov    %eax,%esi
  800d99:	89 f0                	mov    %esi,%eax
  800d9b:	89 fa                	mov    %edi,%edx
  800d9d:	83 c4 10             	add    $0x10,%esp
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    
  800da4:	39 f8                	cmp    %edi,%eax
  800da6:	77 2c                	ja     800dd4 <__udivdi3+0x7c>
  800da8:	0f bd f0             	bsr    %eax,%esi
  800dab:	83 f6 1f             	xor    $0x1f,%esi
  800dae:	75 4c                	jne    800dfc <__udivdi3+0xa4>
  800db0:	39 f8                	cmp    %edi,%eax
  800db2:	bf 00 00 00 00       	mov    $0x0,%edi
  800db7:	72 0a                	jb     800dc3 <__udivdi3+0x6b>
  800db9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800dbd:	0f 87 ad 00 00 00    	ja     800e70 <__udivdi3+0x118>
  800dc3:	be 01 00 00 00       	mov    $0x1,%esi
  800dc8:	89 f0                	mov    %esi,%eax
  800dca:	89 fa                	mov    %edi,%edx
  800dcc:	83 c4 10             	add    $0x10,%esp
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    
  800dd3:	90                   	nop
  800dd4:	31 ff                	xor    %edi,%edi
  800dd6:	31 f6                	xor    %esi,%esi
  800dd8:	89 f0                	mov    %esi,%eax
  800dda:	89 fa                	mov    %edi,%edx
  800ddc:	83 c4 10             	add    $0x10,%esp
  800ddf:	5e                   	pop    %esi
  800de0:	5f                   	pop    %edi
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    
  800de3:	90                   	nop
  800de4:	89 fa                	mov    %edi,%edx
  800de6:	89 f0                	mov    %esi,%eax
  800de8:	f7 f1                	div    %ecx
  800dea:	89 c6                	mov    %eax,%esi
  800dec:	31 ff                	xor    %edi,%edi
  800dee:	89 f0                	mov    %esi,%eax
  800df0:	89 fa                	mov    %edi,%edx
  800df2:	83 c4 10             	add    $0x10,%esp
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    
  800df9:	8d 76 00             	lea    0x0(%esi),%esi
  800dfc:	89 f1                	mov    %esi,%ecx
  800dfe:	d3 e0                	shl    %cl,%eax
  800e00:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e04:	b8 20 00 00 00       	mov    $0x20,%eax
  800e09:	29 f0                	sub    %esi,%eax
  800e0b:	89 ea                	mov    %ebp,%edx
  800e0d:	88 c1                	mov    %al,%cl
  800e0f:	d3 ea                	shr    %cl,%edx
  800e11:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e15:	09 ca                	or     %ecx,%edx
  800e17:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e1b:	89 f1                	mov    %esi,%ecx
  800e1d:	d3 e5                	shl    %cl,%ebp
  800e1f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800e23:	89 fd                	mov    %edi,%ebp
  800e25:	88 c1                	mov    %al,%cl
  800e27:	d3 ed                	shr    %cl,%ebp
  800e29:	89 fa                	mov    %edi,%edx
  800e2b:	89 f1                	mov    %esi,%ecx
  800e2d:	d3 e2                	shl    %cl,%edx
  800e2f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e33:	88 c1                	mov    %al,%cl
  800e35:	d3 ef                	shr    %cl,%edi
  800e37:	09 d7                	or     %edx,%edi
  800e39:	89 f8                	mov    %edi,%eax
  800e3b:	89 ea                	mov    %ebp,%edx
  800e3d:	f7 74 24 08          	divl   0x8(%esp)
  800e41:	89 d1                	mov    %edx,%ecx
  800e43:	89 c7                	mov    %eax,%edi
  800e45:	f7 64 24 0c          	mull   0xc(%esp)
  800e49:	39 d1                	cmp    %edx,%ecx
  800e4b:	72 17                	jb     800e64 <__udivdi3+0x10c>
  800e4d:	74 09                	je     800e58 <__udivdi3+0x100>
  800e4f:	89 fe                	mov    %edi,%esi
  800e51:	31 ff                	xor    %edi,%edi
  800e53:	e9 41 ff ff ff       	jmp    800d99 <__udivdi3+0x41>
  800e58:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e5c:	89 f1                	mov    %esi,%ecx
  800e5e:	d3 e2                	shl    %cl,%edx
  800e60:	39 c2                	cmp    %eax,%edx
  800e62:	73 eb                	jae    800e4f <__udivdi3+0xf7>
  800e64:	8d 77 ff             	lea    -0x1(%edi),%esi
  800e67:	31 ff                	xor    %edi,%edi
  800e69:	e9 2b ff ff ff       	jmp    800d99 <__udivdi3+0x41>
  800e6e:	66 90                	xchg   %ax,%ax
  800e70:	31 f6                	xor    %esi,%esi
  800e72:	e9 22 ff ff ff       	jmp    800d99 <__udivdi3+0x41>
	...

00800e78 <__umoddi3>:
  800e78:	55                   	push   %ebp
  800e79:	57                   	push   %edi
  800e7a:	56                   	push   %esi
  800e7b:	83 ec 20             	sub    $0x20,%esp
  800e7e:	8b 44 24 30          	mov    0x30(%esp),%eax
  800e82:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800e86:	89 44 24 14          	mov    %eax,0x14(%esp)
  800e8a:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e8e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e92:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e96:	89 c7                	mov    %eax,%edi
  800e98:	89 f2                	mov    %esi,%edx
  800e9a:	85 ed                	test   %ebp,%ebp
  800e9c:	75 16                	jne    800eb4 <__umoddi3+0x3c>
  800e9e:	39 f1                	cmp    %esi,%ecx
  800ea0:	0f 86 a6 00 00 00    	jbe    800f4c <__umoddi3+0xd4>
  800ea6:	f7 f1                	div    %ecx
  800ea8:	89 d0                	mov    %edx,%eax
  800eaa:	31 d2                	xor    %edx,%edx
  800eac:	83 c4 20             	add    $0x20,%esp
  800eaf:	5e                   	pop    %esi
  800eb0:	5f                   	pop    %edi
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    
  800eb3:	90                   	nop
  800eb4:	39 f5                	cmp    %esi,%ebp
  800eb6:	0f 87 ac 00 00 00    	ja     800f68 <__umoddi3+0xf0>
  800ebc:	0f bd c5             	bsr    %ebp,%eax
  800ebf:	83 f0 1f             	xor    $0x1f,%eax
  800ec2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec6:	0f 84 a8 00 00 00    	je     800f74 <__umoddi3+0xfc>
  800ecc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ed0:	d3 e5                	shl    %cl,%ebp
  800ed2:	bf 20 00 00 00       	mov    $0x20,%edi
  800ed7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800edb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800edf:	89 f9                	mov    %edi,%ecx
  800ee1:	d3 e8                	shr    %cl,%eax
  800ee3:	09 e8                	or     %ebp,%eax
  800ee5:	89 44 24 18          	mov    %eax,0x18(%esp)
  800ee9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800eed:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ef1:	d3 e0                	shl    %cl,%eax
  800ef3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ef7:	89 f2                	mov    %esi,%edx
  800ef9:	d3 e2                	shl    %cl,%edx
  800efb:	8b 44 24 14          	mov    0x14(%esp),%eax
  800eff:	d3 e0                	shl    %cl,%eax
  800f01:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800f05:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f09:	89 f9                	mov    %edi,%ecx
  800f0b:	d3 e8                	shr    %cl,%eax
  800f0d:	09 d0                	or     %edx,%eax
  800f0f:	d3 ee                	shr    %cl,%esi
  800f11:	89 f2                	mov    %esi,%edx
  800f13:	f7 74 24 18          	divl   0x18(%esp)
  800f17:	89 d6                	mov    %edx,%esi
  800f19:	f7 64 24 0c          	mull   0xc(%esp)
  800f1d:	89 c5                	mov    %eax,%ebp
  800f1f:	89 d1                	mov    %edx,%ecx
  800f21:	39 d6                	cmp    %edx,%esi
  800f23:	72 67                	jb     800f8c <__umoddi3+0x114>
  800f25:	74 75                	je     800f9c <__umoddi3+0x124>
  800f27:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f2b:	29 e8                	sub    %ebp,%eax
  800f2d:	19 ce                	sbb    %ecx,%esi
  800f2f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f33:	d3 e8                	shr    %cl,%eax
  800f35:	89 f2                	mov    %esi,%edx
  800f37:	89 f9                	mov    %edi,%ecx
  800f39:	d3 e2                	shl    %cl,%edx
  800f3b:	09 d0                	or     %edx,%eax
  800f3d:	89 f2                	mov    %esi,%edx
  800f3f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f43:	d3 ea                	shr    %cl,%edx
  800f45:	83 c4 20             	add    $0x20,%esp
  800f48:	5e                   	pop    %esi
  800f49:	5f                   	pop    %edi
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    
  800f4c:	85 c9                	test   %ecx,%ecx
  800f4e:	75 0b                	jne    800f5b <__umoddi3+0xe3>
  800f50:	b8 01 00 00 00       	mov    $0x1,%eax
  800f55:	31 d2                	xor    %edx,%edx
  800f57:	f7 f1                	div    %ecx
  800f59:	89 c1                	mov    %eax,%ecx
  800f5b:	89 f0                	mov    %esi,%eax
  800f5d:	31 d2                	xor    %edx,%edx
  800f5f:	f7 f1                	div    %ecx
  800f61:	89 f8                	mov    %edi,%eax
  800f63:	e9 3e ff ff ff       	jmp    800ea6 <__umoddi3+0x2e>
  800f68:	89 f2                	mov    %esi,%edx
  800f6a:	83 c4 20             	add    $0x20,%esp
  800f6d:	5e                   	pop    %esi
  800f6e:	5f                   	pop    %edi
  800f6f:	5d                   	pop    %ebp
  800f70:	c3                   	ret    
  800f71:	8d 76 00             	lea    0x0(%esi),%esi
  800f74:	39 f5                	cmp    %esi,%ebp
  800f76:	72 04                	jb     800f7c <__umoddi3+0x104>
  800f78:	39 f9                	cmp    %edi,%ecx
  800f7a:	77 06                	ja     800f82 <__umoddi3+0x10a>
  800f7c:	89 f2                	mov    %esi,%edx
  800f7e:	29 cf                	sub    %ecx,%edi
  800f80:	19 ea                	sbb    %ebp,%edx
  800f82:	89 f8                	mov    %edi,%eax
  800f84:	83 c4 20             	add    $0x20,%esp
  800f87:	5e                   	pop    %esi
  800f88:	5f                   	pop    %edi
  800f89:	5d                   	pop    %ebp
  800f8a:	c3                   	ret    
  800f8b:	90                   	nop
  800f8c:	89 d1                	mov    %edx,%ecx
  800f8e:	89 c5                	mov    %eax,%ebp
  800f90:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800f94:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800f98:	eb 8d                	jmp    800f27 <__umoddi3+0xaf>
  800f9a:	66 90                	xchg   %ax,%ax
  800f9c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fa0:	72 ea                	jb     800f8c <__umoddi3+0x114>
  800fa2:	89 f1                	mov    %esi,%ecx
  800fa4:	eb 81                	jmp    800f27 <__umoddi3+0xaf>
