
obj/user/faultwrite:     file format elf32-i386


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
	*(unsigned*)0 = 0;
  800037:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
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
  80005c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80005f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800062:	c1 e0 04             	shl    $0x4,%eax
  800065:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006a:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006f:	85 f6                	test   %esi,%esi
  800071:	7e 07                	jle    80007a <libmain+0x36>
		binaryname = argv[0];
  800073:	8b 03                	mov    (%ebx),%eax
  800075:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80007e:	89 34 24             	mov    %esi,(%esp)
  800081:	e8 ae ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800086:	e8 09 00 00 00       	call   800094 <exit>
}
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	5b                   	pop    %ebx
  80008f:	5e                   	pop    %esi
  800090:	5d                   	pop    %ebp
  800091:	c3                   	ret    
	...

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
  800113:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80011a:	00 
  80011b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800122:	00 
  800123:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80012a:	e8 e1 07 00 00       	call   800910 <_panic>

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
  8001a5:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8001ac:	00 
  8001ad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001b4:	00 
  8001b5:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8001bc:	e8 4f 07 00 00       	call   800910 <_panic>

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
  8001f8:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8001ff:	00 
  800200:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800207:	00 
  800208:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80020f:	e8 fc 06 00 00       	call   800910 <_panic>

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
  80024b:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800252:	00 
  800253:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80025a:	00 
  80025b:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800262:	e8 a9 06 00 00       	call   800910 <_panic>

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
  80029e:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8002a5:	00 
  8002a6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002ad:	00 
  8002ae:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8002b5:	e8 56 06 00 00       	call   800910 <_panic>

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
  8002f1:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8002f8:	00 
  8002f9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800300:	00 
  800301:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800308:	e8 03 06 00 00       	call   800910 <_panic>

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
  800366:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80036d:	00 
  80036e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800375:	00 
  800376:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80037d:	e8 8e 05 00 00       	call   800910 <_panic>

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

0080038a <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
  80038d:	57                   	push   %edi
  80038e:	56                   	push   %esi
  80038f:	53                   	push   %ebx
  800390:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800393:	bb 00 00 00 00       	mov    $0x0,%ebx
  800398:	b8 0d 00 00 00       	mov    $0xd,%eax
  80039d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a3:	89 df                	mov    %ebx,%edi
  8003a5:	89 de                	mov    %ebx,%esi
  8003a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003a9:	85 c0                	test   %eax,%eax
  8003ab:	7e 28                	jle    8003d5 <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003b1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003b8:	00 
  8003b9:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8003c0:	00 
  8003c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003c8:	00 
  8003c9:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8003d0:	e8 3b 05 00 00       	call   800910 <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8003d5:	83 c4 2c             	add    $0x2c,%esp
  8003d8:	5b                   	pop    %ebx
  8003d9:	5e                   	pop    %esi
  8003da:	5f                   	pop    %edi
  8003db:	5d                   	pop    %ebp
  8003dc:	c3                   	ret    

008003dd <sys_env_set_debug_upcall>:

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
  8003dd:	55                   	push   %ebp
  8003de:	89 e5                	mov    %esp,%ebp
  8003e0:	57                   	push   %edi
  8003e1:	56                   	push   %esi
  8003e2:	53                   	push   %ebx
  8003e3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003eb:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f6:	89 df                	mov    %ebx,%edi
  8003f8:	89 de                	mov    %ebx,%esi
  8003fa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003fc:	85 c0                	test   %eax,%eax
  8003fe:	7e 28                	jle    800428 <sys_env_set_debug_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800400:	89 44 24 10          	mov    %eax,0x10(%esp)
  800404:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80040b:	00 
  80040c:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800413:	00 
  800414:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80041b:	00 
  80041c:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800423:	e8 e8 04 00 00       	call   800910 <_panic>
}

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_debug_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800428:	83 c4 2c             	add    $0x2c,%esp
  80042b:	5b                   	pop    %ebx
  80042c:	5e                   	pop    %esi
  80042d:	5f                   	pop    %edi
  80042e:	5d                   	pop    %ebp
  80042f:	c3                   	ret    

00800430 <sys_env_set_nmskint_upcall>:

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	57                   	push   %edi
  800434:	56                   	push   %esi
  800435:	53                   	push   %ebx
  800436:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800439:	bb 00 00 00 00       	mov    $0x0,%ebx
  80043e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800443:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800446:	8b 55 08             	mov    0x8(%ebp),%edx
  800449:	89 df                	mov    %ebx,%edi
  80044b:	89 de                	mov    %ebx,%esi
  80044d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80044f:	85 c0                	test   %eax,%eax
  800451:	7e 28                	jle    80047b <sys_env_set_nmskint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800453:	89 44 24 10          	mov    %eax,0x10(%esp)
  800457:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  80045e:	00 
  80045f:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800466:	00 
  800467:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80046e:	00 
  80046f:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800476:	e8 95 04 00 00       	call   800910 <_panic>
}

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_nmskint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80047b:	83 c4 2c             	add    $0x2c,%esp
  80047e:	5b                   	pop    %ebx
  80047f:	5e                   	pop    %esi
  800480:	5f                   	pop    %edi
  800481:	5d                   	pop    %ebp
  800482:	c3                   	ret    

00800483 <sys_env_set_bpoint_upcall>:

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
  800483:	55                   	push   %ebp
  800484:	89 e5                	mov    %esp,%ebp
  800486:	57                   	push   %edi
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80048c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800491:	b8 10 00 00 00       	mov    $0x10,%eax
  800496:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800499:	8b 55 08             	mov    0x8(%ebp),%edx
  80049c:	89 df                	mov    %ebx,%edi
  80049e:	89 de                	mov    %ebx,%esi
  8004a0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8004a2:	85 c0                	test   %eax,%eax
  8004a4:	7e 28                	jle    8004ce <sys_env_set_bpoint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004aa:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  8004b1:	00 
  8004b2:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8004b9:	00 
  8004ba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004c1:	00 
  8004c2:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8004c9:	e8 42 04 00 00       	call   800910 <_panic>
}

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bpoint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8004ce:	83 c4 2c             	add    $0x2c,%esp
  8004d1:	5b                   	pop    %ebx
  8004d2:	5e                   	pop    %esi
  8004d3:	5f                   	pop    %edi
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <sys_env_set_oflow_upcall>:

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	57                   	push   %edi
  8004da:	56                   	push   %esi
  8004db:	53                   	push   %ebx
  8004dc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004e4:	b8 11 00 00 00       	mov    $0x11,%eax
  8004e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ef:	89 df                	mov    %ebx,%edi
  8004f1:	89 de                	mov    %ebx,%esi
  8004f3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8004f5:	85 c0                	test   %eax,%eax
  8004f7:	7e 28                	jle    800521 <sys_env_set_oflow_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004fd:	c7 44 24 0c 11 00 00 	movl   $0x11,0xc(%esp)
  800504:	00 
  800505:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80050c:	00 
  80050d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800514:	00 
  800515:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80051c:	e8 ef 03 00 00       	call   800910 <_panic>
}

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_oflow_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800521:	83 c4 2c             	add    $0x2c,%esp
  800524:	5b                   	pop    %ebx
  800525:	5e                   	pop    %esi
  800526:	5f                   	pop    %edi
  800527:	5d                   	pop    %ebp
  800528:	c3                   	ret    

00800529 <sys_env_set_bdschk_upcall>:

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
  800529:	55                   	push   %ebp
  80052a:	89 e5                	mov    %esp,%ebp
  80052c:	57                   	push   %edi
  80052d:	56                   	push   %esi
  80052e:	53                   	push   %ebx
  80052f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800532:	bb 00 00 00 00       	mov    $0x0,%ebx
  800537:	b8 12 00 00 00       	mov    $0x12,%eax
  80053c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80053f:	8b 55 08             	mov    0x8(%ebp),%edx
  800542:	89 df                	mov    %ebx,%edi
  800544:	89 de                	mov    %ebx,%esi
  800546:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800548:	85 c0                	test   %eax,%eax
  80054a:	7e 28                	jle    800574 <sys_env_set_bdschk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80054c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800550:	c7 44 24 0c 12 00 00 	movl   $0x12,0xc(%esp)
  800557:	00 
  800558:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80055f:	00 
  800560:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800567:	00 
  800568:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80056f:	e8 9c 03 00 00       	call   800910 <_panic>
}

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bdschk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800574:	83 c4 2c             	add    $0x2c,%esp
  800577:	5b                   	pop    %ebx
  800578:	5e                   	pop    %esi
  800579:	5f                   	pop    %edi
  80057a:	5d                   	pop    %ebp
  80057b:	c3                   	ret    

0080057c <sys_env_set_illopcd_upcall>:

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
  80057c:	55                   	push   %ebp
  80057d:	89 e5                	mov    %esp,%ebp
  80057f:	57                   	push   %edi
  800580:	56                   	push   %esi
  800581:	53                   	push   %ebx
  800582:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800585:	bb 00 00 00 00       	mov    $0x0,%ebx
  80058a:	b8 13 00 00 00       	mov    $0x13,%eax
  80058f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800592:	8b 55 08             	mov    0x8(%ebp),%edx
  800595:	89 df                	mov    %ebx,%edi
  800597:	89 de                	mov    %ebx,%esi
  800599:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80059b:	85 c0                	test   %eax,%eax
  80059d:	7e 28                	jle    8005c7 <sys_env_set_illopcd_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80059f:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005a3:	c7 44 24 0c 13 00 00 	movl   $0x13,0xc(%esp)
  8005aa:	00 
  8005ab:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8005b2:	00 
  8005b3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005ba:	00 
  8005bb:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8005c2:	e8 49 03 00 00       	call   800910 <_panic>
}

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_illopcd_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8005c7:	83 c4 2c             	add    $0x2c,%esp
  8005ca:	5b                   	pop    %ebx
  8005cb:	5e                   	pop    %esi
  8005cc:	5f                   	pop    %edi
  8005cd:	5d                   	pop    %ebp
  8005ce:	c3                   	ret    

008005cf <sys_env_set_dvcntavl_upcall>:

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
  8005cf:	55                   	push   %ebp
  8005d0:	89 e5                	mov    %esp,%ebp
  8005d2:	57                   	push   %edi
  8005d3:	56                   	push   %esi
  8005d4:	53                   	push   %ebx
  8005d5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005dd:	b8 14 00 00 00       	mov    $0x14,%eax
  8005e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8005e8:	89 df                	mov    %ebx,%edi
  8005ea:	89 de                	mov    %ebx,%esi
  8005ec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005ee:	85 c0                	test   %eax,%eax
  8005f0:	7e 28                	jle    80061a <sys_env_set_dvcntavl_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005f2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005f6:	c7 44 24 0c 14 00 00 	movl   $0x14,0xc(%esp)
  8005fd:	00 
  8005fe:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800605:	00 
  800606:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80060d:	00 
  80060e:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800615:	e8 f6 02 00 00       	call   800910 <_panic>
}

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dvcntavl_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80061a:	83 c4 2c             	add    $0x2c,%esp
  80061d:	5b                   	pop    %ebx
  80061e:	5e                   	pop    %esi
  80061f:	5f                   	pop    %edi
  800620:	5d                   	pop    %ebp
  800621:	c3                   	ret    

00800622 <sys_env_set_dbfault_upcall>:

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
  800622:	55                   	push   %ebp
  800623:	89 e5                	mov    %esp,%ebp
  800625:	57                   	push   %edi
  800626:	56                   	push   %esi
  800627:	53                   	push   %ebx
  800628:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80062b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800630:	b8 15 00 00 00       	mov    $0x15,%eax
  800635:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800638:	8b 55 08             	mov    0x8(%ebp),%edx
  80063b:	89 df                	mov    %ebx,%edi
  80063d:	89 de                	mov    %ebx,%esi
  80063f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800641:	85 c0                	test   %eax,%eax
  800643:	7e 28                	jle    80066d <sys_env_set_dbfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800645:	89 44 24 10          	mov    %eax,0x10(%esp)
  800649:	c7 44 24 0c 15 00 00 	movl   $0x15,0xc(%esp)
  800650:	00 
  800651:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800658:	00 
  800659:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800660:	00 
  800661:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800668:	e8 a3 02 00 00       	call   800910 <_panic>
}

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dbfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80066d:	83 c4 2c             	add    $0x2c,%esp
  800670:	5b                   	pop    %ebx
  800671:	5e                   	pop    %esi
  800672:	5f                   	pop    %edi
  800673:	5d                   	pop    %ebp
  800674:	c3                   	ret    

00800675 <sys_env_set_ivldtss_upcall>:

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
  800675:	55                   	push   %ebp
  800676:	89 e5                	mov    %esp,%ebp
  800678:	57                   	push   %edi
  800679:	56                   	push   %esi
  80067a:	53                   	push   %ebx
  80067b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80067e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800683:	b8 16 00 00 00       	mov    $0x16,%eax
  800688:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80068b:	8b 55 08             	mov    0x8(%ebp),%edx
  80068e:	89 df                	mov    %ebx,%edi
  800690:	89 de                	mov    %ebx,%esi
  800692:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800694:	85 c0                	test   %eax,%eax
  800696:	7e 28                	jle    8006c0 <sys_env_set_ivldtss_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800698:	89 44 24 10          	mov    %eax,0x10(%esp)
  80069c:	c7 44 24 0c 16 00 00 	movl   $0x16,0xc(%esp)
  8006a3:	00 
  8006a4:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8006ab:	00 
  8006ac:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006b3:	00 
  8006b4:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8006bb:	e8 50 02 00 00       	call   800910 <_panic>
}

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_ivldtss_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8006c0:	83 c4 2c             	add    $0x2c,%esp
  8006c3:	5b                   	pop    %ebx
  8006c4:	5e                   	pop    %esi
  8006c5:	5f                   	pop    %edi
  8006c6:	5d                   	pop    %ebp
  8006c7:	c3                   	ret    

008006c8 <sys_env_set_segntprst_upcall>:

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	57                   	push   %edi
  8006cc:	56                   	push   %esi
  8006cd:	53                   	push   %ebx
  8006ce:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d6:	b8 17 00 00 00       	mov    $0x17,%eax
  8006db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006de:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e1:	89 df                	mov    %ebx,%edi
  8006e3:	89 de                	mov    %ebx,%esi
  8006e5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	7e 28                	jle    800713 <sys_env_set_segntprst_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ef:	c7 44 24 0c 17 00 00 	movl   $0x17,0xc(%esp)
  8006f6:	00 
  8006f7:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8006fe:	00 
  8006ff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800706:	00 
  800707:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80070e:	e8 fd 01 00 00       	call   800910 <_panic>
}

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_segntprst_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800713:	83 c4 2c             	add    $0x2c,%esp
  800716:	5b                   	pop    %ebx
  800717:	5e                   	pop    %esi
  800718:	5f                   	pop    %edi
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <sys_env_set_stkexception_upcall>:

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	57                   	push   %edi
  80071f:	56                   	push   %esi
  800720:	53                   	push   %ebx
  800721:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800724:	bb 00 00 00 00       	mov    $0x0,%ebx
  800729:	b8 18 00 00 00       	mov    $0x18,%eax
  80072e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800731:	8b 55 08             	mov    0x8(%ebp),%edx
  800734:	89 df                	mov    %ebx,%edi
  800736:	89 de                	mov    %ebx,%esi
  800738:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80073a:	85 c0                	test   %eax,%eax
  80073c:	7e 28                	jle    800766 <sys_env_set_stkexception_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80073e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800742:	c7 44 24 0c 18 00 00 	movl   $0x18,0xc(%esp)
  800749:	00 
  80074a:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800751:	00 
  800752:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800759:	00 
  80075a:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800761:	e8 aa 01 00 00       	call   800910 <_panic>
}

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_stkexception_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800766:	83 c4 2c             	add    $0x2c,%esp
  800769:	5b                   	pop    %ebx
  80076a:	5e                   	pop    %esi
  80076b:	5f                   	pop    %edi
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <sys_env_set_gpfault_upcall>:

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	57                   	push   %edi
  800772:	56                   	push   %esi
  800773:	53                   	push   %ebx
  800774:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800777:	bb 00 00 00 00       	mov    $0x0,%ebx
  80077c:	b8 19 00 00 00       	mov    $0x19,%eax
  800781:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800784:	8b 55 08             	mov    0x8(%ebp),%edx
  800787:	89 df                	mov    %ebx,%edi
  800789:	89 de                	mov    %ebx,%esi
  80078b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80078d:	85 c0                	test   %eax,%eax
  80078f:	7e 28                	jle    8007b9 <sys_env_set_gpfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800791:	89 44 24 10          	mov    %eax,0x10(%esp)
  800795:	c7 44 24 0c 19 00 00 	movl   $0x19,0xc(%esp)
  80079c:	00 
  80079d:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8007a4:	00 
  8007a5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8007ac:	00 
  8007ad:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8007b4:	e8 57 01 00 00       	call   800910 <_panic>
}

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_gpfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8007b9:	83 c4 2c             	add    $0x2c,%esp
  8007bc:	5b                   	pop    %ebx
  8007bd:	5e                   	pop    %esi
  8007be:	5f                   	pop    %edi
  8007bf:	5d                   	pop    %ebp
  8007c0:	c3                   	ret    

008007c1 <sys_env_set_fperror_upcall>:

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	57                   	push   %edi
  8007c5:	56                   	push   %esi
  8007c6:	53                   	push   %ebx
  8007c7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007cf:	b8 1a 00 00 00       	mov    $0x1a,%eax
  8007d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8007da:	89 df                	mov    %ebx,%edi
  8007dc:	89 de                	mov    %ebx,%esi
  8007de:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8007e0:	85 c0                	test   %eax,%eax
  8007e2:	7e 28                	jle    80080c <sys_env_set_fperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007e8:	c7 44 24 0c 1a 00 00 	movl   $0x1a,0xc(%esp)
  8007ef:	00 
  8007f0:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8007f7:	00 
  8007f8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8007ff:	00 
  800800:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800807:	e8 04 01 00 00       	call   800910 <_panic>
}

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_fperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80080c:	83 c4 2c             	add    $0x2c,%esp
  80080f:	5b                   	pop    %ebx
  800810:	5e                   	pop    %esi
  800811:	5f                   	pop    %edi
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <sys_env_set_algchk_upcall>:

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	57                   	push   %edi
  800818:	56                   	push   %esi
  800819:	53                   	push   %ebx
  80081a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80081d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800822:	b8 1b 00 00 00       	mov    $0x1b,%eax
  800827:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082a:	8b 55 08             	mov    0x8(%ebp),%edx
  80082d:	89 df                	mov    %ebx,%edi
  80082f:	89 de                	mov    %ebx,%esi
  800831:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800833:	85 c0                	test   %eax,%eax
  800835:	7e 28                	jle    80085f <sys_env_set_algchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800837:	89 44 24 10          	mov    %eax,0x10(%esp)
  80083b:	c7 44 24 0c 1b 00 00 	movl   $0x1b,0xc(%esp)
  800842:	00 
  800843:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80084a:	00 
  80084b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800852:	00 
  800853:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80085a:	e8 b1 00 00 00       	call   800910 <_panic>
}

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_algchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80085f:	83 c4 2c             	add    $0x2c,%esp
  800862:	5b                   	pop    %ebx
  800863:	5e                   	pop    %esi
  800864:	5f                   	pop    %edi
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <sys_env_set_mchchk_upcall>:

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	57                   	push   %edi
  80086b:	56                   	push   %esi
  80086c:	53                   	push   %ebx
  80086d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800870:	bb 00 00 00 00       	mov    $0x0,%ebx
  800875:	b8 1c 00 00 00       	mov    $0x1c,%eax
  80087a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087d:	8b 55 08             	mov    0x8(%ebp),%edx
  800880:	89 df                	mov    %ebx,%edi
  800882:	89 de                	mov    %ebx,%esi
  800884:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800886:	85 c0                	test   %eax,%eax
  800888:	7e 28                	jle    8008b2 <sys_env_set_mchchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80088a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80088e:	c7 44 24 0c 1c 00 00 	movl   $0x1c,0xc(%esp)
  800895:	00 
  800896:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80089d:	00 
  80089e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8008a5:	00 
  8008a6:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8008ad:	e8 5e 00 00 00       	call   800910 <_panic>
}

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_mchchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8008b2:	83 c4 2c             	add    $0x2c,%esp
  8008b5:	5b                   	pop    %ebx
  8008b6:	5e                   	pop    %esi
  8008b7:	5f                   	pop    %edi
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <sys_env_set_SIMDfperror_upcall>:

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	57                   	push   %edi
  8008be:	56                   	push   %esi
  8008bf:	53                   	push   %ebx
  8008c0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8008c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008c8:	b8 1d 00 00 00       	mov    $0x1d,%eax
  8008cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008d3:	89 df                	mov    %ebx,%edi
  8008d5:	89 de                	mov    %ebx,%esi
  8008d7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8008d9:	85 c0                	test   %eax,%eax
  8008db:	7e 28                	jle    800905 <sys_env_set_SIMDfperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8008dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8008e1:	c7 44 24 0c 1d 00 00 	movl   $0x1d,0xc(%esp)
  8008e8:	00 
  8008e9:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8008f0:	00 
  8008f1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8008f8:	00 
  8008f9:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800900:	e8 0b 00 00 00       	call   800910 <_panic>
}

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_SIMDfperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800905:	83 c4 2c             	add    $0x2c,%esp
  800908:	5b                   	pop    %ebx
  800909:	5e                   	pop    %esi
  80090a:	5f                   	pop    %edi
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    
  80090d:	00 00                	add    %al,(%eax)
	...

00800910 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	56                   	push   %esi
  800914:	53                   	push   %ebx
  800915:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800918:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80091b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800921:	e8 11 f8 ff ff       	call   800137 <sys_getenvid>
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
  800929:	89 54 24 10          	mov    %edx,0x10(%esp)
  80092d:	8b 55 08             	mov    0x8(%ebp),%edx
  800930:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800934:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800938:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093c:	c7 04 24 78 15 80 00 	movl   $0x801578,(%esp)
  800943:	e8 c0 00 00 00       	call   800a08 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800948:	89 74 24 04          	mov    %esi,0x4(%esp)
  80094c:	8b 45 10             	mov    0x10(%ebp),%eax
  80094f:	89 04 24             	mov    %eax,(%esp)
  800952:	e8 50 00 00 00       	call   8009a7 <vcprintf>
	cprintf("\n");
  800957:	c7 04 24 9c 15 80 00 	movl   $0x80159c,(%esp)
  80095e:	e8 a5 00 00 00       	call   800a08 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800963:	cc                   	int3   
  800964:	eb fd                	jmp    800963 <_panic+0x53>
	...

00800968 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	53                   	push   %ebx
  80096c:	83 ec 14             	sub    $0x14,%esp
  80096f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800972:	8b 03                	mov    (%ebx),%eax
  800974:	8b 55 08             	mov    0x8(%ebp),%edx
  800977:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80097b:	40                   	inc    %eax
  80097c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80097e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800983:	75 19                	jne    80099e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800985:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80098c:	00 
  80098d:	8d 43 08             	lea    0x8(%ebx),%eax
  800990:	89 04 24             	mov    %eax,(%esp)
  800993:	e8 10 f7 ff ff       	call   8000a8 <sys_cputs>
		b->idx = 0;
  800998:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80099e:	ff 43 04             	incl   0x4(%ebx)
}
  8009a1:	83 c4 14             	add    $0x14,%esp
  8009a4:	5b                   	pop    %ebx
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8009b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8009b7:	00 00 00 
	b.cnt = 0;
  8009ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8009c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8009c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8009d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009dc:	c7 04 24 68 09 80 00 	movl   $0x800968,(%esp)
  8009e3:	e8 b4 01 00 00       	call   800b9c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8009e8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8009ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8009f8:	89 04 24             	mov    %eax,(%esp)
  8009fb:	e8 a8 f6 ff ff       	call   8000a8 <sys_cputs>

	return b.cnt;
}
  800a00:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800a06:	c9                   	leave  
  800a07:	c3                   	ret    

00800a08 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800a0e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800a11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a15:	8b 45 08             	mov    0x8(%ebp),%eax
  800a18:	89 04 24             	mov    %eax,(%esp)
  800a1b:	e8 87 ff ff ff       	call   8009a7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800a20:	c9                   	leave  
  800a21:	c3                   	ret    
	...

00800a24 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	57                   	push   %edi
  800a28:	56                   	push   %esi
  800a29:	53                   	push   %ebx
  800a2a:	83 ec 3c             	sub    $0x3c,%esp
  800a2d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a30:	89 d7                	mov    %edx,%edi
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a3e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800a41:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800a44:	85 c0                	test   %eax,%eax
  800a46:	75 08                	jne    800a50 <printnum+0x2c>
  800a48:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a4b:	39 45 10             	cmp    %eax,0x10(%ebp)
  800a4e:	77 57                	ja     800aa7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800a50:	89 74 24 10          	mov    %esi,0x10(%esp)
  800a54:	4b                   	dec    %ebx
  800a55:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800a59:	8b 45 10             	mov    0x10(%ebp),%eax
  800a5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a60:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800a64:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800a68:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a6f:	00 
  800a70:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a73:	89 04 24             	mov    %eax,(%esp)
  800a76:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a79:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7d:	e8 5a 08 00 00       	call   8012dc <__udivdi3>
  800a82:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a86:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a8a:	89 04 24             	mov    %eax,(%esp)
  800a8d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a91:	89 fa                	mov    %edi,%edx
  800a93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a96:	e8 89 ff ff ff       	call   800a24 <printnum>
  800a9b:	eb 0f                	jmp    800aac <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800a9d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aa1:	89 34 24             	mov    %esi,(%esp)
  800aa4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800aa7:	4b                   	dec    %ebx
  800aa8:	85 db                	test   %ebx,%ebx
  800aaa:	7f f1                	jg     800a9d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800aac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ab0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ab4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800abb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ac2:	00 
  800ac3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ac6:	89 04 24             	mov    %eax,(%esp)
  800ac9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800acc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad0:	e8 27 09 00 00       	call   8013fc <__umoddi3>
  800ad5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ad9:	0f be 80 9e 15 80 00 	movsbl 0x80159e(%eax),%eax
  800ae0:	89 04 24             	mov    %eax,(%esp)
  800ae3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800ae6:	83 c4 3c             	add    $0x3c,%esp
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800af1:	83 fa 01             	cmp    $0x1,%edx
  800af4:	7e 0e                	jle    800b04 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800af6:	8b 10                	mov    (%eax),%edx
  800af8:	8d 4a 08             	lea    0x8(%edx),%ecx
  800afb:	89 08                	mov    %ecx,(%eax)
  800afd:	8b 02                	mov    (%edx),%eax
  800aff:	8b 52 04             	mov    0x4(%edx),%edx
  800b02:	eb 22                	jmp    800b26 <getuint+0x38>
	else if (lflag)
  800b04:	85 d2                	test   %edx,%edx
  800b06:	74 10                	je     800b18 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800b08:	8b 10                	mov    (%eax),%edx
  800b0a:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b0d:	89 08                	mov    %ecx,(%eax)
  800b0f:	8b 02                	mov    (%edx),%eax
  800b11:	ba 00 00 00 00       	mov    $0x0,%edx
  800b16:	eb 0e                	jmp    800b26 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800b18:	8b 10                	mov    (%eax),%edx
  800b1a:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b1d:	89 08                	mov    %ecx,(%eax)
  800b1f:	8b 02                	mov    (%edx),%eax
  800b21:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800b2b:	83 fa 01             	cmp    $0x1,%edx
  800b2e:	7e 0e                	jle    800b3e <getint+0x16>
		return va_arg(*ap, long long);
  800b30:	8b 10                	mov    (%eax),%edx
  800b32:	8d 4a 08             	lea    0x8(%edx),%ecx
  800b35:	89 08                	mov    %ecx,(%eax)
  800b37:	8b 02                	mov    (%edx),%eax
  800b39:	8b 52 04             	mov    0x4(%edx),%edx
  800b3c:	eb 1a                	jmp    800b58 <getint+0x30>
	else if (lflag)
  800b3e:	85 d2                	test   %edx,%edx
  800b40:	74 0c                	je     800b4e <getint+0x26>
		return va_arg(*ap, long);
  800b42:	8b 10                	mov    (%eax),%edx
  800b44:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b47:	89 08                	mov    %ecx,(%eax)
  800b49:	8b 02                	mov    (%edx),%eax
  800b4b:	99                   	cltd   
  800b4c:	eb 0a                	jmp    800b58 <getint+0x30>
	else
		return va_arg(*ap, int);
  800b4e:	8b 10                	mov    (%eax),%edx
  800b50:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b53:	89 08                	mov    %ecx,(%eax)
  800b55:	8b 02                	mov    (%edx),%eax
  800b57:	99                   	cltd   
}
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800b60:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800b63:	8b 10                	mov    (%eax),%edx
  800b65:	3b 50 04             	cmp    0x4(%eax),%edx
  800b68:	73 08                	jae    800b72 <sprintputch+0x18>
		*b->buf++ = ch;
  800b6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6d:	88 0a                	mov    %cl,(%edx)
  800b6f:	42                   	inc    %edx
  800b70:	89 10                	mov    %edx,(%eax)
}
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800b7a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800b7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b81:	8b 45 10             	mov    0x10(%ebp),%eax
  800b84:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b88:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b92:	89 04 24             	mov    %eax,(%esp)
  800b95:	e8 02 00 00 00       	call   800b9c <vprintfmt>
	va_end(ap);
}
  800b9a:	c9                   	leave  
  800b9b:	c3                   	ret    

00800b9c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
  800ba2:	83 ec 4c             	sub    $0x4c,%esp
  800ba5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ba8:	8b 75 10             	mov    0x10(%ebp),%esi
  800bab:	eb 12                	jmp    800bbf <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800bad:	85 c0                	test   %eax,%eax
  800baf:	0f 84 40 03 00 00    	je     800ef5 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800bb5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bb9:	89 04 24             	mov    %eax,(%esp)
  800bbc:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800bbf:	0f b6 06             	movzbl (%esi),%eax
  800bc2:	46                   	inc    %esi
  800bc3:	83 f8 25             	cmp    $0x25,%eax
  800bc6:	75 e5                	jne    800bad <vprintfmt+0x11>
  800bc8:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800bcc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800bd3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800bd8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800bdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800be4:	eb 26                	jmp    800c0c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800be6:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800be9:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800bed:	eb 1d                	jmp    800c0c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bef:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800bf2:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800bf6:	eb 14                	jmp    800c0c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bf8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800bfb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800c02:	eb 08                	jmp    800c0c <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800c04:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800c07:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c0c:	0f b6 06             	movzbl (%esi),%eax
  800c0f:	8d 4e 01             	lea    0x1(%esi),%ecx
  800c12:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800c15:	8a 0e                	mov    (%esi),%cl
  800c17:	83 e9 23             	sub    $0x23,%ecx
  800c1a:	80 f9 55             	cmp    $0x55,%cl
  800c1d:	0f 87 b6 02 00 00    	ja     800ed9 <vprintfmt+0x33d>
  800c23:	0f b6 c9             	movzbl %cl,%ecx
  800c26:	ff 24 8d 60 16 80 00 	jmp    *0x801660(,%ecx,4)
  800c2d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c30:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800c35:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800c38:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  800c3c:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800c3f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800c42:	83 f9 09             	cmp    $0x9,%ecx
  800c45:	77 2a                	ja     800c71 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c47:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800c48:	eb eb                	jmp    800c35 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800c4a:	8b 45 14             	mov    0x14(%ebp),%eax
  800c4d:	8d 48 04             	lea    0x4(%eax),%ecx
  800c50:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800c53:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c55:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800c58:	eb 17                	jmp    800c71 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800c5a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c5e:	78 98                	js     800bf8 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c60:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c63:	eb a7                	jmp    800c0c <vprintfmt+0x70>
  800c65:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800c68:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800c6f:	eb 9b                	jmp    800c0c <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800c71:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c75:	79 95                	jns    800c0c <vprintfmt+0x70>
  800c77:	eb 8b                	jmp    800c04 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800c79:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c7a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800c7d:	eb 8d                	jmp    800c0c <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800c7f:	8b 45 14             	mov    0x14(%ebp),%eax
  800c82:	8d 50 04             	lea    0x4(%eax),%edx
  800c85:	89 55 14             	mov    %edx,0x14(%ebp)
  800c88:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c8c:	8b 00                	mov    (%eax),%eax
  800c8e:	89 04 24             	mov    %eax,(%esp)
  800c91:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c94:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800c97:	e9 23 ff ff ff       	jmp    800bbf <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800c9c:	8b 45 14             	mov    0x14(%ebp),%eax
  800c9f:	8d 50 04             	lea    0x4(%eax),%edx
  800ca2:	89 55 14             	mov    %edx,0x14(%ebp)
  800ca5:	8b 00                	mov    (%eax),%eax
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	79 02                	jns    800cad <vprintfmt+0x111>
  800cab:	f7 d8                	neg    %eax
  800cad:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800caf:	83 f8 09             	cmp    $0x9,%eax
  800cb2:	7f 0b                	jg     800cbf <vprintfmt+0x123>
  800cb4:	8b 04 85 c0 17 80 00 	mov    0x8017c0(,%eax,4),%eax
  800cbb:	85 c0                	test   %eax,%eax
  800cbd:	75 23                	jne    800ce2 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800cbf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cc3:	c7 44 24 08 b6 15 80 	movl   $0x8015b6,0x8(%esp)
  800cca:	00 
  800ccb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd2:	89 04 24             	mov    %eax,(%esp)
  800cd5:	e8 9a fe ff ff       	call   800b74 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cda:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800cdd:	e9 dd fe ff ff       	jmp    800bbf <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800ce2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ce6:	c7 44 24 08 bf 15 80 	movl   $0x8015bf,0x8(%esp)
  800ced:	00 
  800cee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf5:	89 14 24             	mov    %edx,(%esp)
  800cf8:	e8 77 fe ff ff       	call   800b74 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cfd:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d00:	e9 ba fe ff ff       	jmp    800bbf <vprintfmt+0x23>
  800d05:	89 f9                	mov    %edi,%ecx
  800d07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d0a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d0d:	8b 45 14             	mov    0x14(%ebp),%eax
  800d10:	8d 50 04             	lea    0x4(%eax),%edx
  800d13:	89 55 14             	mov    %edx,0x14(%ebp)
  800d16:	8b 30                	mov    (%eax),%esi
  800d18:	85 f6                	test   %esi,%esi
  800d1a:	75 05                	jne    800d21 <vprintfmt+0x185>
				p = "(null)";
  800d1c:	be af 15 80 00       	mov    $0x8015af,%esi
			if (width > 0 && padc != '-')
  800d21:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800d25:	0f 8e 84 00 00 00    	jle    800daf <vprintfmt+0x213>
  800d2b:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800d2f:	74 7e                	je     800daf <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800d31:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d35:	89 34 24             	mov    %esi,(%esp)
  800d38:	e8 5d 02 00 00       	call   800f9a <strnlen>
  800d3d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800d40:	29 c2                	sub    %eax,%edx
  800d42:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800d45:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800d49:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800d4c:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800d4f:	89 de                	mov    %ebx,%esi
  800d51:	89 d3                	mov    %edx,%ebx
  800d53:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d55:	eb 0b                	jmp    800d62 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800d57:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d5b:	89 3c 24             	mov    %edi,(%esp)
  800d5e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d61:	4b                   	dec    %ebx
  800d62:	85 db                	test   %ebx,%ebx
  800d64:	7f f1                	jg     800d57 <vprintfmt+0x1bb>
  800d66:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800d69:	89 f3                	mov    %esi,%ebx
  800d6b:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800d6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d71:	85 c0                	test   %eax,%eax
  800d73:	79 05                	jns    800d7a <vprintfmt+0x1de>
  800d75:	b8 00 00 00 00       	mov    $0x0,%eax
  800d7a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d7d:	29 c2                	sub    %eax,%edx
  800d7f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800d82:	eb 2b                	jmp    800daf <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800d84:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800d88:	74 18                	je     800da2 <vprintfmt+0x206>
  800d8a:	8d 50 e0             	lea    -0x20(%eax),%edx
  800d8d:	83 fa 5e             	cmp    $0x5e,%edx
  800d90:	76 10                	jbe    800da2 <vprintfmt+0x206>
					putch('?', putdat);
  800d92:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d96:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800d9d:	ff 55 08             	call   *0x8(%ebp)
  800da0:	eb 0a                	jmp    800dac <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800da2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800da6:	89 04 24             	mov    %eax,(%esp)
  800da9:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800dac:	ff 4d e4             	decl   -0x1c(%ebp)
  800daf:	0f be 06             	movsbl (%esi),%eax
  800db2:	46                   	inc    %esi
  800db3:	85 c0                	test   %eax,%eax
  800db5:	74 21                	je     800dd8 <vprintfmt+0x23c>
  800db7:	85 ff                	test   %edi,%edi
  800db9:	78 c9                	js     800d84 <vprintfmt+0x1e8>
  800dbb:	4f                   	dec    %edi
  800dbc:	79 c6                	jns    800d84 <vprintfmt+0x1e8>
  800dbe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dc1:	89 de                	mov    %ebx,%esi
  800dc3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800dc6:	eb 18                	jmp    800de0 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800dc8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dcc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800dd3:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800dd5:	4b                   	dec    %ebx
  800dd6:	eb 08                	jmp    800de0 <vprintfmt+0x244>
  800dd8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ddb:	89 de                	mov    %ebx,%esi
  800ddd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800de0:	85 db                	test   %ebx,%ebx
  800de2:	7f e4                	jg     800dc8 <vprintfmt+0x22c>
  800de4:	89 7d 08             	mov    %edi,0x8(%ebp)
  800de7:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800de9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800dec:	e9 ce fd ff ff       	jmp    800bbf <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800df1:	8d 45 14             	lea    0x14(%ebp),%eax
  800df4:	e8 2f fd ff ff       	call   800b28 <getint>
  800df9:	89 c6                	mov    %eax,%esi
  800dfb:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800dfd:	85 d2                	test   %edx,%edx
  800dff:	78 07                	js     800e08 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800e01:	be 0a 00 00 00       	mov    $0xa,%esi
  800e06:	eb 7e                	jmp    800e86 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800e08:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e0c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800e13:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800e16:	89 f0                	mov    %esi,%eax
  800e18:	89 fa                	mov    %edi,%edx
  800e1a:	f7 d8                	neg    %eax
  800e1c:	83 d2 00             	adc    $0x0,%edx
  800e1f:	f7 da                	neg    %edx
			}
			base = 10;
  800e21:	be 0a 00 00 00       	mov    $0xa,%esi
  800e26:	eb 5e                	jmp    800e86 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800e28:	8d 45 14             	lea    0x14(%ebp),%eax
  800e2b:	e8 be fc ff ff       	call   800aee <getuint>
			base = 10;
  800e30:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800e35:	eb 4f                	jmp    800e86 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800e37:	8d 45 14             	lea    0x14(%ebp),%eax
  800e3a:	e8 af fc ff ff       	call   800aee <getuint>
			base = 8;
  800e3f:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800e44:	eb 40                	jmp    800e86 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  800e46:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e4a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800e51:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800e54:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e58:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800e5f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800e62:	8b 45 14             	mov    0x14(%ebp),%eax
  800e65:	8d 50 04             	lea    0x4(%eax),%edx
  800e68:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800e6b:	8b 00                	mov    (%eax),%eax
  800e6d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800e72:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800e77:	eb 0d                	jmp    800e86 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800e79:	8d 45 14             	lea    0x14(%ebp),%eax
  800e7c:	e8 6d fc ff ff       	call   800aee <getuint>
			base = 16;
  800e81:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800e86:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800e8a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800e8e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800e91:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e95:	89 74 24 08          	mov    %esi,0x8(%esp)
  800e99:	89 04 24             	mov    %eax,(%esp)
  800e9c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ea0:	89 da                	mov    %ebx,%edx
  800ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea5:	e8 7a fb ff ff       	call   800a24 <printnum>
			break;
  800eaa:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ead:	e9 0d fd ff ff       	jmp    800bbf <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  800eb2:	8d 45 14             	lea    0x14(%ebp),%eax
  800eb5:	e8 6e fc ff ff       	call   800b28 <getint>
  800eba:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ebf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  800ec2:	e9 f8 fc ff ff       	jmp    800bbf <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ec7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ecb:	89 04 24             	mov    %eax,(%esp)
  800ece:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ed1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ed4:	e9 e6 fc ff ff       	jmp    800bbf <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ed9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800edd:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ee4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ee7:	eb 01                	jmp    800eea <vprintfmt+0x34e>
  800ee9:	4e                   	dec    %esi
  800eea:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800eee:	75 f9                	jne    800ee9 <vprintfmt+0x34d>
  800ef0:	e9 ca fc ff ff       	jmp    800bbf <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800ef5:	83 c4 4c             	add    $0x4c,%esp
  800ef8:	5b                   	pop    %ebx
  800ef9:	5e                   	pop    %esi
  800efa:	5f                   	pop    %edi
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    

00800efd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	83 ec 28             	sub    $0x28,%esp
  800f03:	8b 45 08             	mov    0x8(%ebp),%eax
  800f06:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800f09:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f0c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800f10:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800f1a:	85 c0                	test   %eax,%eax
  800f1c:	74 30                	je     800f4e <vsnprintf+0x51>
  800f1e:	85 d2                	test   %edx,%edx
  800f20:	7e 33                	jle    800f55 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f22:	8b 45 14             	mov    0x14(%ebp),%eax
  800f25:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f29:	8b 45 10             	mov    0x10(%ebp),%eax
  800f2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f30:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f33:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f37:	c7 04 24 5a 0b 80 00 	movl   $0x800b5a,(%esp)
  800f3e:	e8 59 fc ff ff       	call   800b9c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f43:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f46:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f4c:	eb 0c                	jmp    800f5a <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800f4e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f53:	eb 05                	jmp    800f5a <vsnprintf+0x5d>
  800f55:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800f5a:	c9                   	leave  
  800f5b:	c3                   	ret    

00800f5c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800f62:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800f65:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f69:	8b 45 10             	mov    0x10(%ebp),%eax
  800f6c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f73:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f77:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7a:	89 04 24             	mov    %eax,(%esp)
  800f7d:	e8 7b ff ff ff       	call   800efd <vsnprintf>
	va_end(ap);

	return rc;
}
  800f82:	c9                   	leave  
  800f83:	c3                   	ret    

00800f84 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800f8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8f:	eb 01                	jmp    800f92 <strlen+0xe>
		n++;
  800f91:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800f92:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800f96:	75 f9                	jne    800f91 <strlen+0xd>
		n++;
	return n;
}
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    

00800f9a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800fa0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fa3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa8:	eb 01                	jmp    800fab <strnlen+0x11>
		n++;
  800faa:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fab:	39 d0                	cmp    %edx,%eax
  800fad:	74 06                	je     800fb5 <strnlen+0x1b>
  800faf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800fb3:	75 f5                	jne    800faa <strnlen+0x10>
		n++;
	return n;
}
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    

00800fb7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	53                   	push   %ebx
  800fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800fc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800fc9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800fcc:	42                   	inc    %edx
  800fcd:	84 c9                	test   %cl,%cl
  800fcf:	75 f5                	jne    800fc6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800fd1:	5b                   	pop    %ebx
  800fd2:	5d                   	pop    %ebp
  800fd3:	c3                   	ret    

00800fd4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	53                   	push   %ebx
  800fd8:	83 ec 08             	sub    $0x8,%esp
  800fdb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800fde:	89 1c 24             	mov    %ebx,(%esp)
  800fe1:	e8 9e ff ff ff       	call   800f84 <strlen>
	strcpy(dst + len, src);
  800fe6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fe9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fed:	01 d8                	add    %ebx,%eax
  800fef:	89 04 24             	mov    %eax,(%esp)
  800ff2:	e8 c0 ff ff ff       	call   800fb7 <strcpy>
	return dst;
}
  800ff7:	89 d8                	mov    %ebx,%eax
  800ff9:	83 c4 08             	add    $0x8,%esp
  800ffc:	5b                   	pop    %ebx
  800ffd:	5d                   	pop    %ebp
  800ffe:	c3                   	ret    

00800fff <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	56                   	push   %esi
  801003:	53                   	push   %ebx
  801004:	8b 45 08             	mov    0x8(%ebp),%eax
  801007:	8b 55 0c             	mov    0xc(%ebp),%edx
  80100a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80100d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801012:	eb 0c                	jmp    801020 <strncpy+0x21>
		*dst++ = *src;
  801014:	8a 1a                	mov    (%edx),%bl
  801016:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801019:	80 3a 01             	cmpb   $0x1,(%edx)
  80101c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80101f:	41                   	inc    %ecx
  801020:	39 f1                	cmp    %esi,%ecx
  801022:	75 f0                	jne    801014 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801024:	5b                   	pop    %ebx
  801025:	5e                   	pop    %esi
  801026:	5d                   	pop    %ebp
  801027:	c3                   	ret    

00801028 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	56                   	push   %esi
  80102c:	53                   	push   %ebx
  80102d:	8b 75 08             	mov    0x8(%ebp),%esi
  801030:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801033:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801036:	85 d2                	test   %edx,%edx
  801038:	75 0a                	jne    801044 <strlcpy+0x1c>
  80103a:	89 f0                	mov    %esi,%eax
  80103c:	eb 1a                	jmp    801058 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80103e:	88 18                	mov    %bl,(%eax)
  801040:	40                   	inc    %eax
  801041:	41                   	inc    %ecx
  801042:	eb 02                	jmp    801046 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801044:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801046:	4a                   	dec    %edx
  801047:	74 0a                	je     801053 <strlcpy+0x2b>
  801049:	8a 19                	mov    (%ecx),%bl
  80104b:	84 db                	test   %bl,%bl
  80104d:	75 ef                	jne    80103e <strlcpy+0x16>
  80104f:	89 c2                	mov    %eax,%edx
  801051:	eb 02                	jmp    801055 <strlcpy+0x2d>
  801053:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801055:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801058:	29 f0                	sub    %esi,%eax
}
  80105a:	5b                   	pop    %ebx
  80105b:	5e                   	pop    %esi
  80105c:	5d                   	pop    %ebp
  80105d:	c3                   	ret    

0080105e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80105e:	55                   	push   %ebp
  80105f:	89 e5                	mov    %esp,%ebp
  801061:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801064:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801067:	eb 02                	jmp    80106b <strcmp+0xd>
		p++, q++;
  801069:	41                   	inc    %ecx
  80106a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80106b:	8a 01                	mov    (%ecx),%al
  80106d:	84 c0                	test   %al,%al
  80106f:	74 04                	je     801075 <strcmp+0x17>
  801071:	3a 02                	cmp    (%edx),%al
  801073:	74 f4                	je     801069 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801075:	0f b6 c0             	movzbl %al,%eax
  801078:	0f b6 12             	movzbl (%edx),%edx
  80107b:	29 d0                	sub    %edx,%eax
}
  80107d:	5d                   	pop    %ebp
  80107e:	c3                   	ret    

0080107f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	53                   	push   %ebx
  801083:	8b 45 08             	mov    0x8(%ebp),%eax
  801086:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801089:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80108c:	eb 03                	jmp    801091 <strncmp+0x12>
		n--, p++, q++;
  80108e:	4a                   	dec    %edx
  80108f:	40                   	inc    %eax
  801090:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801091:	85 d2                	test   %edx,%edx
  801093:	74 14                	je     8010a9 <strncmp+0x2a>
  801095:	8a 18                	mov    (%eax),%bl
  801097:	84 db                	test   %bl,%bl
  801099:	74 04                	je     80109f <strncmp+0x20>
  80109b:	3a 19                	cmp    (%ecx),%bl
  80109d:	74 ef                	je     80108e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80109f:	0f b6 00             	movzbl (%eax),%eax
  8010a2:	0f b6 11             	movzbl (%ecx),%edx
  8010a5:	29 d0                	sub    %edx,%eax
  8010a7:	eb 05                	jmp    8010ae <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8010a9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010ae:	5b                   	pop    %ebx
  8010af:	5d                   	pop    %ebp
  8010b0:	c3                   	ret    

008010b1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8010b1:	55                   	push   %ebp
  8010b2:	89 e5                	mov    %esp,%ebp
  8010b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8010ba:	eb 05                	jmp    8010c1 <strchr+0x10>
		if (*s == c)
  8010bc:	38 ca                	cmp    %cl,%dl
  8010be:	74 0c                	je     8010cc <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8010c0:	40                   	inc    %eax
  8010c1:	8a 10                	mov    (%eax),%dl
  8010c3:	84 d2                	test   %dl,%dl
  8010c5:	75 f5                	jne    8010bc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8010c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010cc:	5d                   	pop    %ebp
  8010cd:	c3                   	ret    

008010ce <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8010d7:	eb 05                	jmp    8010de <strfind+0x10>
		if (*s == c)
  8010d9:	38 ca                	cmp    %cl,%dl
  8010db:	74 07                	je     8010e4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8010dd:	40                   	inc    %eax
  8010de:	8a 10                	mov    (%eax),%dl
  8010e0:	84 d2                	test   %dl,%dl
  8010e2:	75 f5                	jne    8010d9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    

008010e6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	57                   	push   %edi
  8010ea:	56                   	push   %esi
  8010eb:	53                   	push   %ebx
  8010ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8010f5:	85 c9                	test   %ecx,%ecx
  8010f7:	74 30                	je     801129 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8010f9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8010ff:	75 25                	jne    801126 <memset+0x40>
  801101:	f6 c1 03             	test   $0x3,%cl
  801104:	75 20                	jne    801126 <memset+0x40>
		c &= 0xFF;
  801106:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801109:	89 d3                	mov    %edx,%ebx
  80110b:	c1 e3 08             	shl    $0x8,%ebx
  80110e:	89 d6                	mov    %edx,%esi
  801110:	c1 e6 18             	shl    $0x18,%esi
  801113:	89 d0                	mov    %edx,%eax
  801115:	c1 e0 10             	shl    $0x10,%eax
  801118:	09 f0                	or     %esi,%eax
  80111a:	09 d0                	or     %edx,%eax
  80111c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80111e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801121:	fc                   	cld    
  801122:	f3 ab                	rep stos %eax,%es:(%edi)
  801124:	eb 03                	jmp    801129 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801126:	fc                   	cld    
  801127:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801129:	89 f8                	mov    %edi,%eax
  80112b:	5b                   	pop    %ebx
  80112c:	5e                   	pop    %esi
  80112d:	5f                   	pop    %edi
  80112e:	5d                   	pop    %ebp
  80112f:	c3                   	ret    

00801130 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	57                   	push   %edi
  801134:	56                   	push   %esi
  801135:	8b 45 08             	mov    0x8(%ebp),%eax
  801138:	8b 75 0c             	mov    0xc(%ebp),%esi
  80113b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80113e:	39 c6                	cmp    %eax,%esi
  801140:	73 34                	jae    801176 <memmove+0x46>
  801142:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801145:	39 d0                	cmp    %edx,%eax
  801147:	73 2d                	jae    801176 <memmove+0x46>
		s += n;
		d += n;
  801149:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80114c:	f6 c2 03             	test   $0x3,%dl
  80114f:	75 1b                	jne    80116c <memmove+0x3c>
  801151:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801157:	75 13                	jne    80116c <memmove+0x3c>
  801159:	f6 c1 03             	test   $0x3,%cl
  80115c:	75 0e                	jne    80116c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80115e:	83 ef 04             	sub    $0x4,%edi
  801161:	8d 72 fc             	lea    -0x4(%edx),%esi
  801164:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801167:	fd                   	std    
  801168:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80116a:	eb 07                	jmp    801173 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80116c:	4f                   	dec    %edi
  80116d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801170:	fd                   	std    
  801171:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801173:	fc                   	cld    
  801174:	eb 20                	jmp    801196 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801176:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80117c:	75 13                	jne    801191 <memmove+0x61>
  80117e:	a8 03                	test   $0x3,%al
  801180:	75 0f                	jne    801191 <memmove+0x61>
  801182:	f6 c1 03             	test   $0x3,%cl
  801185:	75 0a                	jne    801191 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801187:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80118a:	89 c7                	mov    %eax,%edi
  80118c:	fc                   	cld    
  80118d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80118f:	eb 05                	jmp    801196 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801191:	89 c7                	mov    %eax,%edi
  801193:	fc                   	cld    
  801194:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801196:	5e                   	pop    %esi
  801197:	5f                   	pop    %edi
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    

0080119a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8011a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8011a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b1:	89 04 24             	mov    %eax,(%esp)
  8011b4:	e8 77 ff ff ff       	call   801130 <memmove>
}
  8011b9:	c9                   	leave  
  8011ba:	c3                   	ret    

008011bb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	57                   	push   %edi
  8011bf:	56                   	push   %esi
  8011c0:	53                   	push   %ebx
  8011c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8011cf:	eb 16                	jmp    8011e7 <memcmp+0x2c>
		if (*s1 != *s2)
  8011d1:	8a 04 17             	mov    (%edi,%edx,1),%al
  8011d4:	42                   	inc    %edx
  8011d5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8011d9:	38 c8                	cmp    %cl,%al
  8011db:	74 0a                	je     8011e7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8011dd:	0f b6 c0             	movzbl %al,%eax
  8011e0:	0f b6 c9             	movzbl %cl,%ecx
  8011e3:	29 c8                	sub    %ecx,%eax
  8011e5:	eb 09                	jmp    8011f0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011e7:	39 da                	cmp    %ebx,%edx
  8011e9:	75 e6                	jne    8011d1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8011eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011f0:	5b                   	pop    %ebx
  8011f1:	5e                   	pop    %esi
  8011f2:	5f                   	pop    %edi
  8011f3:	5d                   	pop    %ebp
  8011f4:	c3                   	ret    

008011f5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8011f5:	55                   	push   %ebp
  8011f6:	89 e5                	mov    %esp,%ebp
  8011f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8011fe:	89 c2                	mov    %eax,%edx
  801200:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801203:	eb 05                	jmp    80120a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801205:	38 08                	cmp    %cl,(%eax)
  801207:	74 05                	je     80120e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801209:	40                   	inc    %eax
  80120a:	39 d0                	cmp    %edx,%eax
  80120c:	72 f7                	jb     801205 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	57                   	push   %edi
  801214:	56                   	push   %esi
  801215:	53                   	push   %ebx
  801216:	8b 55 08             	mov    0x8(%ebp),%edx
  801219:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80121c:	eb 01                	jmp    80121f <strtol+0xf>
		s++;
  80121e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80121f:	8a 02                	mov    (%edx),%al
  801221:	3c 20                	cmp    $0x20,%al
  801223:	74 f9                	je     80121e <strtol+0xe>
  801225:	3c 09                	cmp    $0x9,%al
  801227:	74 f5                	je     80121e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801229:	3c 2b                	cmp    $0x2b,%al
  80122b:	75 08                	jne    801235 <strtol+0x25>
		s++;
  80122d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80122e:	bf 00 00 00 00       	mov    $0x0,%edi
  801233:	eb 13                	jmp    801248 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801235:	3c 2d                	cmp    $0x2d,%al
  801237:	75 0a                	jne    801243 <strtol+0x33>
		s++, neg = 1;
  801239:	8d 52 01             	lea    0x1(%edx),%edx
  80123c:	bf 01 00 00 00       	mov    $0x1,%edi
  801241:	eb 05                	jmp    801248 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801243:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801248:	85 db                	test   %ebx,%ebx
  80124a:	74 05                	je     801251 <strtol+0x41>
  80124c:	83 fb 10             	cmp    $0x10,%ebx
  80124f:	75 28                	jne    801279 <strtol+0x69>
  801251:	8a 02                	mov    (%edx),%al
  801253:	3c 30                	cmp    $0x30,%al
  801255:	75 10                	jne    801267 <strtol+0x57>
  801257:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80125b:	75 0a                	jne    801267 <strtol+0x57>
		s += 2, base = 16;
  80125d:	83 c2 02             	add    $0x2,%edx
  801260:	bb 10 00 00 00       	mov    $0x10,%ebx
  801265:	eb 12                	jmp    801279 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801267:	85 db                	test   %ebx,%ebx
  801269:	75 0e                	jne    801279 <strtol+0x69>
  80126b:	3c 30                	cmp    $0x30,%al
  80126d:	75 05                	jne    801274 <strtol+0x64>
		s++, base = 8;
  80126f:	42                   	inc    %edx
  801270:	b3 08                	mov    $0x8,%bl
  801272:	eb 05                	jmp    801279 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801274:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801279:	b8 00 00 00 00       	mov    $0x0,%eax
  80127e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801280:	8a 0a                	mov    (%edx),%cl
  801282:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801285:	80 fb 09             	cmp    $0x9,%bl
  801288:	77 08                	ja     801292 <strtol+0x82>
			dig = *s - '0';
  80128a:	0f be c9             	movsbl %cl,%ecx
  80128d:	83 e9 30             	sub    $0x30,%ecx
  801290:	eb 1e                	jmp    8012b0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801292:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801295:	80 fb 19             	cmp    $0x19,%bl
  801298:	77 08                	ja     8012a2 <strtol+0x92>
			dig = *s - 'a' + 10;
  80129a:	0f be c9             	movsbl %cl,%ecx
  80129d:	83 e9 57             	sub    $0x57,%ecx
  8012a0:	eb 0e                	jmp    8012b0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8012a2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8012a5:	80 fb 19             	cmp    $0x19,%bl
  8012a8:	77 12                	ja     8012bc <strtol+0xac>
			dig = *s - 'A' + 10;
  8012aa:	0f be c9             	movsbl %cl,%ecx
  8012ad:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8012b0:	39 f1                	cmp    %esi,%ecx
  8012b2:	7d 0c                	jge    8012c0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8012b4:	42                   	inc    %edx
  8012b5:	0f af c6             	imul   %esi,%eax
  8012b8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8012ba:	eb c4                	jmp    801280 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8012bc:	89 c1                	mov    %eax,%ecx
  8012be:	eb 02                	jmp    8012c2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8012c0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8012c2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8012c6:	74 05                	je     8012cd <strtol+0xbd>
		*endptr = (char *) s;
  8012c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012cb:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8012cd:	85 ff                	test   %edi,%edi
  8012cf:	74 04                	je     8012d5 <strtol+0xc5>
  8012d1:	89 c8                	mov    %ecx,%eax
  8012d3:	f7 d8                	neg    %eax
}
  8012d5:	5b                   	pop    %ebx
  8012d6:	5e                   	pop    %esi
  8012d7:	5f                   	pop    %edi
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    
	...

008012dc <__udivdi3>:
  8012dc:	55                   	push   %ebp
  8012dd:	57                   	push   %edi
  8012de:	56                   	push   %esi
  8012df:	83 ec 10             	sub    $0x10,%esp
  8012e2:	8b 74 24 20          	mov    0x20(%esp),%esi
  8012e6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8012ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ee:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8012f2:	89 cd                	mov    %ecx,%ebp
  8012f4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8012f8:	85 c0                	test   %eax,%eax
  8012fa:	75 2c                	jne    801328 <__udivdi3+0x4c>
  8012fc:	39 f9                	cmp    %edi,%ecx
  8012fe:	77 68                	ja     801368 <__udivdi3+0x8c>
  801300:	85 c9                	test   %ecx,%ecx
  801302:	75 0b                	jne    80130f <__udivdi3+0x33>
  801304:	b8 01 00 00 00       	mov    $0x1,%eax
  801309:	31 d2                	xor    %edx,%edx
  80130b:	f7 f1                	div    %ecx
  80130d:	89 c1                	mov    %eax,%ecx
  80130f:	31 d2                	xor    %edx,%edx
  801311:	89 f8                	mov    %edi,%eax
  801313:	f7 f1                	div    %ecx
  801315:	89 c7                	mov    %eax,%edi
  801317:	89 f0                	mov    %esi,%eax
  801319:	f7 f1                	div    %ecx
  80131b:	89 c6                	mov    %eax,%esi
  80131d:	89 f0                	mov    %esi,%eax
  80131f:	89 fa                	mov    %edi,%edx
  801321:	83 c4 10             	add    $0x10,%esp
  801324:	5e                   	pop    %esi
  801325:	5f                   	pop    %edi
  801326:	5d                   	pop    %ebp
  801327:	c3                   	ret    
  801328:	39 f8                	cmp    %edi,%eax
  80132a:	77 2c                	ja     801358 <__udivdi3+0x7c>
  80132c:	0f bd f0             	bsr    %eax,%esi
  80132f:	83 f6 1f             	xor    $0x1f,%esi
  801332:	75 4c                	jne    801380 <__udivdi3+0xa4>
  801334:	39 f8                	cmp    %edi,%eax
  801336:	bf 00 00 00 00       	mov    $0x0,%edi
  80133b:	72 0a                	jb     801347 <__udivdi3+0x6b>
  80133d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801341:	0f 87 ad 00 00 00    	ja     8013f4 <__udivdi3+0x118>
  801347:	be 01 00 00 00       	mov    $0x1,%esi
  80134c:	89 f0                	mov    %esi,%eax
  80134e:	89 fa                	mov    %edi,%edx
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	5e                   	pop    %esi
  801354:	5f                   	pop    %edi
  801355:	5d                   	pop    %ebp
  801356:	c3                   	ret    
  801357:	90                   	nop
  801358:	31 ff                	xor    %edi,%edi
  80135a:	31 f6                	xor    %esi,%esi
  80135c:	89 f0                	mov    %esi,%eax
  80135e:	89 fa                	mov    %edi,%edx
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	5e                   	pop    %esi
  801364:	5f                   	pop    %edi
  801365:	5d                   	pop    %ebp
  801366:	c3                   	ret    
  801367:	90                   	nop
  801368:	89 fa                	mov    %edi,%edx
  80136a:	89 f0                	mov    %esi,%eax
  80136c:	f7 f1                	div    %ecx
  80136e:	89 c6                	mov    %eax,%esi
  801370:	31 ff                	xor    %edi,%edi
  801372:	89 f0                	mov    %esi,%eax
  801374:	89 fa                	mov    %edi,%edx
  801376:	83 c4 10             	add    $0x10,%esp
  801379:	5e                   	pop    %esi
  80137a:	5f                   	pop    %edi
  80137b:	5d                   	pop    %ebp
  80137c:	c3                   	ret    
  80137d:	8d 76 00             	lea    0x0(%esi),%esi
  801380:	89 f1                	mov    %esi,%ecx
  801382:	d3 e0                	shl    %cl,%eax
  801384:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801388:	b8 20 00 00 00       	mov    $0x20,%eax
  80138d:	29 f0                	sub    %esi,%eax
  80138f:	89 ea                	mov    %ebp,%edx
  801391:	88 c1                	mov    %al,%cl
  801393:	d3 ea                	shr    %cl,%edx
  801395:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801399:	09 ca                	or     %ecx,%edx
  80139b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80139f:	89 f1                	mov    %esi,%ecx
  8013a1:	d3 e5                	shl    %cl,%ebp
  8013a3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8013a7:	89 fd                	mov    %edi,%ebp
  8013a9:	88 c1                	mov    %al,%cl
  8013ab:	d3 ed                	shr    %cl,%ebp
  8013ad:	89 fa                	mov    %edi,%edx
  8013af:	89 f1                	mov    %esi,%ecx
  8013b1:	d3 e2                	shl    %cl,%edx
  8013b3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013b7:	88 c1                	mov    %al,%cl
  8013b9:	d3 ef                	shr    %cl,%edi
  8013bb:	09 d7                	or     %edx,%edi
  8013bd:	89 f8                	mov    %edi,%eax
  8013bf:	89 ea                	mov    %ebp,%edx
  8013c1:	f7 74 24 08          	divl   0x8(%esp)
  8013c5:	89 d1                	mov    %edx,%ecx
  8013c7:	89 c7                	mov    %eax,%edi
  8013c9:	f7 64 24 0c          	mull   0xc(%esp)
  8013cd:	39 d1                	cmp    %edx,%ecx
  8013cf:	72 17                	jb     8013e8 <__udivdi3+0x10c>
  8013d1:	74 09                	je     8013dc <__udivdi3+0x100>
  8013d3:	89 fe                	mov    %edi,%esi
  8013d5:	31 ff                	xor    %edi,%edi
  8013d7:	e9 41 ff ff ff       	jmp    80131d <__udivdi3+0x41>
  8013dc:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013e0:	89 f1                	mov    %esi,%ecx
  8013e2:	d3 e2                	shl    %cl,%edx
  8013e4:	39 c2                	cmp    %eax,%edx
  8013e6:	73 eb                	jae    8013d3 <__udivdi3+0xf7>
  8013e8:	8d 77 ff             	lea    -0x1(%edi),%esi
  8013eb:	31 ff                	xor    %edi,%edi
  8013ed:	e9 2b ff ff ff       	jmp    80131d <__udivdi3+0x41>
  8013f2:	66 90                	xchg   %ax,%ax
  8013f4:	31 f6                	xor    %esi,%esi
  8013f6:	e9 22 ff ff ff       	jmp    80131d <__udivdi3+0x41>
	...

008013fc <__umoddi3>:
  8013fc:	55                   	push   %ebp
  8013fd:	57                   	push   %edi
  8013fe:	56                   	push   %esi
  8013ff:	83 ec 20             	sub    $0x20,%esp
  801402:	8b 44 24 30          	mov    0x30(%esp),%eax
  801406:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80140a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80140e:	8b 74 24 34          	mov    0x34(%esp),%esi
  801412:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801416:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80141a:	89 c7                	mov    %eax,%edi
  80141c:	89 f2                	mov    %esi,%edx
  80141e:	85 ed                	test   %ebp,%ebp
  801420:	75 16                	jne    801438 <__umoddi3+0x3c>
  801422:	39 f1                	cmp    %esi,%ecx
  801424:	0f 86 a6 00 00 00    	jbe    8014d0 <__umoddi3+0xd4>
  80142a:	f7 f1                	div    %ecx
  80142c:	89 d0                	mov    %edx,%eax
  80142e:	31 d2                	xor    %edx,%edx
  801430:	83 c4 20             	add    $0x20,%esp
  801433:	5e                   	pop    %esi
  801434:	5f                   	pop    %edi
  801435:	5d                   	pop    %ebp
  801436:	c3                   	ret    
  801437:	90                   	nop
  801438:	39 f5                	cmp    %esi,%ebp
  80143a:	0f 87 ac 00 00 00    	ja     8014ec <__umoddi3+0xf0>
  801440:	0f bd c5             	bsr    %ebp,%eax
  801443:	83 f0 1f             	xor    $0x1f,%eax
  801446:	89 44 24 10          	mov    %eax,0x10(%esp)
  80144a:	0f 84 a8 00 00 00    	je     8014f8 <__umoddi3+0xfc>
  801450:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801454:	d3 e5                	shl    %cl,%ebp
  801456:	bf 20 00 00 00       	mov    $0x20,%edi
  80145b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80145f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801463:	89 f9                	mov    %edi,%ecx
  801465:	d3 e8                	shr    %cl,%eax
  801467:	09 e8                	or     %ebp,%eax
  801469:	89 44 24 18          	mov    %eax,0x18(%esp)
  80146d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801471:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801475:	d3 e0                	shl    %cl,%eax
  801477:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80147b:	89 f2                	mov    %esi,%edx
  80147d:	d3 e2                	shl    %cl,%edx
  80147f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801483:	d3 e0                	shl    %cl,%eax
  801485:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801489:	8b 44 24 14          	mov    0x14(%esp),%eax
  80148d:	89 f9                	mov    %edi,%ecx
  80148f:	d3 e8                	shr    %cl,%eax
  801491:	09 d0                	or     %edx,%eax
  801493:	d3 ee                	shr    %cl,%esi
  801495:	89 f2                	mov    %esi,%edx
  801497:	f7 74 24 18          	divl   0x18(%esp)
  80149b:	89 d6                	mov    %edx,%esi
  80149d:	f7 64 24 0c          	mull   0xc(%esp)
  8014a1:	89 c5                	mov    %eax,%ebp
  8014a3:	89 d1                	mov    %edx,%ecx
  8014a5:	39 d6                	cmp    %edx,%esi
  8014a7:	72 67                	jb     801510 <__umoddi3+0x114>
  8014a9:	74 75                	je     801520 <__umoddi3+0x124>
  8014ab:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8014af:	29 e8                	sub    %ebp,%eax
  8014b1:	19 ce                	sbb    %ecx,%esi
  8014b3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014b7:	d3 e8                	shr    %cl,%eax
  8014b9:	89 f2                	mov    %esi,%edx
  8014bb:	89 f9                	mov    %edi,%ecx
  8014bd:	d3 e2                	shl    %cl,%edx
  8014bf:	09 d0                	or     %edx,%eax
  8014c1:	89 f2                	mov    %esi,%edx
  8014c3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014c7:	d3 ea                	shr    %cl,%edx
  8014c9:	83 c4 20             	add    $0x20,%esp
  8014cc:	5e                   	pop    %esi
  8014cd:	5f                   	pop    %edi
  8014ce:	5d                   	pop    %ebp
  8014cf:	c3                   	ret    
  8014d0:	85 c9                	test   %ecx,%ecx
  8014d2:	75 0b                	jne    8014df <__umoddi3+0xe3>
  8014d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014d9:	31 d2                	xor    %edx,%edx
  8014db:	f7 f1                	div    %ecx
  8014dd:	89 c1                	mov    %eax,%ecx
  8014df:	89 f0                	mov    %esi,%eax
  8014e1:	31 d2                	xor    %edx,%edx
  8014e3:	f7 f1                	div    %ecx
  8014e5:	89 f8                	mov    %edi,%eax
  8014e7:	e9 3e ff ff ff       	jmp    80142a <__umoddi3+0x2e>
  8014ec:	89 f2                	mov    %esi,%edx
  8014ee:	83 c4 20             	add    $0x20,%esp
  8014f1:	5e                   	pop    %esi
  8014f2:	5f                   	pop    %edi
  8014f3:	5d                   	pop    %ebp
  8014f4:	c3                   	ret    
  8014f5:	8d 76 00             	lea    0x0(%esi),%esi
  8014f8:	39 f5                	cmp    %esi,%ebp
  8014fa:	72 04                	jb     801500 <__umoddi3+0x104>
  8014fc:	39 f9                	cmp    %edi,%ecx
  8014fe:	77 06                	ja     801506 <__umoddi3+0x10a>
  801500:	89 f2                	mov    %esi,%edx
  801502:	29 cf                	sub    %ecx,%edi
  801504:	19 ea                	sbb    %ebp,%edx
  801506:	89 f8                	mov    %edi,%eax
  801508:	83 c4 20             	add    $0x20,%esp
  80150b:	5e                   	pop    %esi
  80150c:	5f                   	pop    %edi
  80150d:	5d                   	pop    %ebp
  80150e:	c3                   	ret    
  80150f:	90                   	nop
  801510:	89 d1                	mov    %edx,%ecx
  801512:	89 c5                	mov    %eax,%ebp
  801514:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801518:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80151c:	eb 8d                	jmp    8014ab <__umoddi3+0xaf>
  80151e:	66 90                	xchg   %ax,%ax
  801520:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801524:	72 ea                	jb     801510 <__umoddi3+0x114>
  801526:	89 f1                	mov    %esi,%ecx
  801528:	eb 81                	jmp    8014ab <__umoddi3+0xaf>
