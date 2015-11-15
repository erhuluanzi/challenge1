
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
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
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	5d                   	pop    %ebp
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80004e:	e8 e0 00 00 00       	call   800133 <sys_getenvid>
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80005b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80005e:	c1 e0 04             	shl    $0x4,%eax
  800061:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800066:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006b:	85 f6                	test   %esi,%esi
  80006d:	7e 07                	jle    800076 <libmain+0x36>
		binaryname = argv[0];
  80006f:	8b 03                	mov    (%ebx),%eax
  800071:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800076:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80007a:	89 34 24             	mov    %esi,(%esp)
  80007d:	e8 b2 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800082:	e8 09 00 00 00       	call   800090 <exit>
}
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	5b                   	pop    %ebx
  80008b:	5e                   	pop    %esi
  80008c:	5d                   	pop    %ebp
  80008d:	c3                   	ret    
	...

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800096:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009d:	e8 3f 00 00 00       	call   8000e1 <sys_env_destroy>
}
  8000a2:	c9                   	leave  
  8000a3:	c3                   	ret    

008000a4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	57                   	push   %edi
  8000a8:	56                   	push   %esi
  8000a9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8000af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b5:	89 c3                	mov    %eax,%ebx
  8000b7:	89 c7                	mov    %eax,%edi
  8000b9:	89 c6                	mov    %eax,%esi
  8000bb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5f                   	pop    %edi
  8000c0:	5d                   	pop    %ebp
  8000c1:	c3                   	ret    

008000c2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	57                   	push   %edi
  8000c6:	56                   	push   %esi
  8000c7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d2:	89 d1                	mov    %edx,%ecx
  8000d4:	89 d3                	mov    %edx,%ebx
  8000d6:	89 d7                	mov    %edx,%edi
  8000d8:	89 d6                	mov    %edx,%esi
  8000da:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    

008000e1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ef:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f7:	89 cb                	mov    %ecx,%ebx
  8000f9:	89 cf                	mov    %ecx,%edi
  8000fb:	89 ce                	mov    %ecx,%esi
  8000fd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ff:	85 c0                	test   %eax,%eax
  800101:	7e 28                	jle    80012b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800103:	89 44 24 10          	mov    %eax,0x10(%esp)
  800107:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80010e:	00 
  80010f:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800116:	00 
  800117:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80011e:	00 
  80011f:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800126:	e8 e1 07 00 00       	call   80090c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012b:	83 c4 2c             	add    $0x2c,%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	57                   	push   %edi
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800139:	ba 00 00 00 00       	mov    $0x0,%edx
  80013e:	b8 02 00 00 00       	mov    $0x2,%eax
  800143:	89 d1                	mov    %edx,%ecx
  800145:	89 d3                	mov    %edx,%ebx
  800147:	89 d7                	mov    %edx,%edi
  800149:	89 d6                	mov    %edx,%esi
  80014b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014d:	5b                   	pop    %ebx
  80014e:	5e                   	pop    %esi
  80014f:	5f                   	pop    %edi
  800150:	5d                   	pop    %ebp
  800151:	c3                   	ret    

00800152 <sys_yield>:

void
sys_yield(void)
{
  800152:	55                   	push   %ebp
  800153:	89 e5                	mov    %esp,%ebp
  800155:	57                   	push   %edi
  800156:	56                   	push   %esi
  800157:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800158:	ba 00 00 00 00       	mov    $0x0,%edx
  80015d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800162:	89 d1                	mov    %edx,%ecx
  800164:	89 d3                	mov    %edx,%ebx
  800166:	89 d7                	mov    %edx,%edi
  800168:	89 d6                	mov    %edx,%esi
  80016a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016c:	5b                   	pop    %ebx
  80016d:	5e                   	pop    %esi
  80016e:	5f                   	pop    %edi
  80016f:	5d                   	pop    %ebp
  800170:	c3                   	ret    

00800171 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	57                   	push   %edi
  800175:	56                   	push   %esi
  800176:	53                   	push   %ebx
  800177:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017a:	be 00 00 00 00       	mov    $0x0,%esi
  80017f:	b8 04 00 00 00       	mov    $0x4,%eax
  800184:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800187:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018a:	8b 55 08             	mov    0x8(%ebp),%edx
  80018d:	89 f7                	mov    %esi,%edi
  80018f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800191:	85 c0                	test   %eax,%eax
  800193:	7e 28                	jle    8001bd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800195:	89 44 24 10          	mov    %eax,0x10(%esp)
  800199:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001a0:	00 
  8001a1:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8001a8:	00 
  8001a9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001b0:	00 
  8001b1:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8001b8:	e8 4f 07 00 00       	call   80090c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bd:	83 c4 2c             	add    $0x2c,%esp
  8001c0:	5b                   	pop    %ebx
  8001c1:	5e                   	pop    %esi
  8001c2:	5f                   	pop    %edi
  8001c3:	5d                   	pop    %ebp
  8001c4:	c3                   	ret    

008001c5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ce:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001df:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e4:	85 c0                	test   %eax,%eax
  8001e6:	7e 28                	jle    800210 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001ec:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001f3:	00 
  8001f4:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8001fb:	00 
  8001fc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800203:	00 
  800204:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80020b:	e8 fc 06 00 00       	call   80090c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800210:	83 c4 2c             	add    $0x2c,%esp
  800213:	5b                   	pop    %ebx
  800214:	5e                   	pop    %esi
  800215:	5f                   	pop    %edi
  800216:	5d                   	pop    %ebp
  800217:	c3                   	ret    

00800218 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	57                   	push   %edi
  80021c:	56                   	push   %esi
  80021d:	53                   	push   %ebx
  80021e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800221:	bb 00 00 00 00       	mov    $0x0,%ebx
  800226:	b8 06 00 00 00       	mov    $0x6,%eax
  80022b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022e:	8b 55 08             	mov    0x8(%ebp),%edx
  800231:	89 df                	mov    %ebx,%edi
  800233:	89 de                	mov    %ebx,%esi
  800235:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800237:	85 c0                	test   %eax,%eax
  800239:	7e 28                	jle    800263 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80023f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800246:	00 
  800247:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80024e:	00 
  80024f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800256:	00 
  800257:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80025e:	e8 a9 06 00 00       	call   80090c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800263:	83 c4 2c             	add    $0x2c,%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	57                   	push   %edi
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800274:	bb 00 00 00 00       	mov    $0x0,%ebx
  800279:	b8 08 00 00 00       	mov    $0x8,%eax
  80027e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800281:	8b 55 08             	mov    0x8(%ebp),%edx
  800284:	89 df                	mov    %ebx,%edi
  800286:	89 de                	mov    %ebx,%esi
  800288:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028a:	85 c0                	test   %eax,%eax
  80028c:	7e 28                	jle    8002b6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800292:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800299:	00 
  80029a:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8002a1:	00 
  8002a2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002a9:	00 
  8002aa:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8002b1:	e8 56 06 00 00       	call   80090c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002b6:	83 c4 2c             	add    $0x2c,%esp
  8002b9:	5b                   	pop    %ebx
  8002ba:	5e                   	pop    %esi
  8002bb:	5f                   	pop    %edi
  8002bc:	5d                   	pop    %ebp
  8002bd:	c3                   	ret    

008002be <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	57                   	push   %edi
  8002c2:	56                   	push   %esi
  8002c3:	53                   	push   %ebx
  8002c4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002cc:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d7:	89 df                	mov    %ebx,%edi
  8002d9:	89 de                	mov    %ebx,%esi
  8002db:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002dd:	85 c0                	test   %eax,%eax
  8002df:	7e 28                	jle    800309 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002e5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002ec:	00 
  8002ed:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8002f4:	00 
  8002f5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002fc:	00 
  8002fd:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800304:	e8 03 06 00 00       	call   80090c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800309:	83 c4 2c             	add    $0x2c,%esp
  80030c:	5b                   	pop    %ebx
  80030d:	5e                   	pop    %esi
  80030e:	5f                   	pop    %edi
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	57                   	push   %edi
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800317:	be 00 00 00 00       	mov    $0x0,%esi
  80031c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800321:	8b 7d 14             	mov    0x14(%ebp),%edi
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032a:	8b 55 08             	mov    0x8(%ebp),%edx
  80032d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032f:	5b                   	pop    %ebx
  800330:	5e                   	pop    %esi
  800331:	5f                   	pop    %edi
  800332:	5d                   	pop    %ebp
  800333:	c3                   	ret    

00800334 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	57                   	push   %edi
  800338:	56                   	push   %esi
  800339:	53                   	push   %ebx
  80033a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800342:	b8 0c 00 00 00       	mov    $0xc,%eax
  800347:	8b 55 08             	mov    0x8(%ebp),%edx
  80034a:	89 cb                	mov    %ecx,%ebx
  80034c:	89 cf                	mov    %ecx,%edi
  80034e:	89 ce                	mov    %ecx,%esi
  800350:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800352:	85 c0                	test   %eax,%eax
  800354:	7e 28                	jle    80037e <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800356:	89 44 24 10          	mov    %eax,0x10(%esp)
  80035a:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800361:	00 
  800362:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800369:	00 
  80036a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800371:	00 
  800372:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800379:	e8 8e 05 00 00       	call   80090c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80037e:	83 c4 2c             	add    $0x2c,%esp
  800381:	5b                   	pop    %ebx
  800382:	5e                   	pop    %esi
  800383:	5f                   	pop    %edi
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	57                   	push   %edi
  80038a:	56                   	push   %esi
  80038b:	53                   	push   %ebx
  80038c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80038f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800394:	b8 0d 00 00 00       	mov    $0xd,%eax
  800399:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80039c:	8b 55 08             	mov    0x8(%ebp),%edx
  80039f:	89 df                	mov    %ebx,%edi
  8003a1:	89 de                	mov    %ebx,%esi
  8003a3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003a5:	85 c0                	test   %eax,%eax
  8003a7:	7e 28                	jle    8003d1 <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003a9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003ad:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003b4:	00 
  8003b5:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8003bc:	00 
  8003bd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003c4:	00 
  8003c5:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8003cc:	e8 3b 05 00 00       	call   80090c <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8003d1:	83 c4 2c             	add    $0x2c,%esp
  8003d4:	5b                   	pop    %ebx
  8003d5:	5e                   	pop    %esi
  8003d6:	5f                   	pop    %edi
  8003d7:	5d                   	pop    %ebp
  8003d8:	c3                   	ret    

008003d9 <sys_env_set_debug_upcall>:

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
  8003d9:	55                   	push   %ebp
  8003da:	89 e5                	mov    %esp,%ebp
  8003dc:	57                   	push   %edi
  8003dd:	56                   	push   %esi
  8003de:	53                   	push   %ebx
  8003df:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003e7:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f2:	89 df                	mov    %ebx,%edi
  8003f4:	89 de                	mov    %ebx,%esi
  8003f6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003f8:	85 c0                	test   %eax,%eax
  8003fa:	7e 28                	jle    800424 <sys_env_set_debug_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800400:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800407:	00 
  800408:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80040f:	00 
  800410:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800417:	00 
  800418:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80041f:	e8 e8 04 00 00       	call   80090c <_panic>
}

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_debug_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800424:	83 c4 2c             	add    $0x2c,%esp
  800427:	5b                   	pop    %ebx
  800428:	5e                   	pop    %esi
  800429:	5f                   	pop    %edi
  80042a:	5d                   	pop    %ebp
  80042b:	c3                   	ret    

0080042c <sys_env_set_nmskint_upcall>:

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	57                   	push   %edi
  800430:	56                   	push   %esi
  800431:	53                   	push   %ebx
  800432:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800435:	bb 00 00 00 00       	mov    $0x0,%ebx
  80043a:	b8 0f 00 00 00       	mov    $0xf,%eax
  80043f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800442:	8b 55 08             	mov    0x8(%ebp),%edx
  800445:	89 df                	mov    %ebx,%edi
  800447:	89 de                	mov    %ebx,%esi
  800449:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80044b:	85 c0                	test   %eax,%eax
  80044d:	7e 28                	jle    800477 <sys_env_set_nmskint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80044f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800453:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  80045a:	00 
  80045b:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800462:	00 
  800463:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80046a:	00 
  80046b:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800472:	e8 95 04 00 00       	call   80090c <_panic>
}

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_nmskint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800477:	83 c4 2c             	add    $0x2c,%esp
  80047a:	5b                   	pop    %ebx
  80047b:	5e                   	pop    %esi
  80047c:	5f                   	pop    %edi
  80047d:	5d                   	pop    %ebp
  80047e:	c3                   	ret    

0080047f <sys_env_set_bpoint_upcall>:

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
  80047f:	55                   	push   %ebp
  800480:	89 e5                	mov    %esp,%ebp
  800482:	57                   	push   %edi
  800483:	56                   	push   %esi
  800484:	53                   	push   %ebx
  800485:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800488:	bb 00 00 00 00       	mov    $0x0,%ebx
  80048d:	b8 10 00 00 00       	mov    $0x10,%eax
  800492:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800495:	8b 55 08             	mov    0x8(%ebp),%edx
  800498:	89 df                	mov    %ebx,%edi
  80049a:	89 de                	mov    %ebx,%esi
  80049c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80049e:	85 c0                	test   %eax,%eax
  8004a0:	7e 28                	jle    8004ca <sys_env_set_bpoint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004a6:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  8004ad:	00 
  8004ae:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8004b5:	00 
  8004b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004bd:	00 
  8004be:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8004c5:	e8 42 04 00 00       	call   80090c <_panic>
}

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bpoint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8004ca:	83 c4 2c             	add    $0x2c,%esp
  8004cd:	5b                   	pop    %ebx
  8004ce:	5e                   	pop    %esi
  8004cf:	5f                   	pop    %edi
  8004d0:	5d                   	pop    %ebp
  8004d1:	c3                   	ret    

008004d2 <sys_env_set_oflow_upcall>:

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	57                   	push   %edi
  8004d6:	56                   	push   %esi
  8004d7:	53                   	push   %ebx
  8004d8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004e0:	b8 11 00 00 00       	mov    $0x11,%eax
  8004e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004eb:	89 df                	mov    %ebx,%edi
  8004ed:	89 de                	mov    %ebx,%esi
  8004ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8004f1:	85 c0                	test   %eax,%eax
  8004f3:	7e 28                	jle    80051d <sys_env_set_oflow_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004f9:	c7 44 24 0c 11 00 00 	movl   $0x11,0xc(%esp)
  800500:	00 
  800501:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800508:	00 
  800509:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800510:	00 
  800511:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800518:	e8 ef 03 00 00       	call   80090c <_panic>
}

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_oflow_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80051d:	83 c4 2c             	add    $0x2c,%esp
  800520:	5b                   	pop    %ebx
  800521:	5e                   	pop    %esi
  800522:	5f                   	pop    %edi
  800523:	5d                   	pop    %ebp
  800524:	c3                   	ret    

00800525 <sys_env_set_bdschk_upcall>:

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	57                   	push   %edi
  800529:	56                   	push   %esi
  80052a:	53                   	push   %ebx
  80052b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80052e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800533:	b8 12 00 00 00       	mov    $0x12,%eax
  800538:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80053b:	8b 55 08             	mov    0x8(%ebp),%edx
  80053e:	89 df                	mov    %ebx,%edi
  800540:	89 de                	mov    %ebx,%esi
  800542:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800544:	85 c0                	test   %eax,%eax
  800546:	7e 28                	jle    800570 <sys_env_set_bdschk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800548:	89 44 24 10          	mov    %eax,0x10(%esp)
  80054c:	c7 44 24 0c 12 00 00 	movl   $0x12,0xc(%esp)
  800553:	00 
  800554:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80055b:	00 
  80055c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800563:	00 
  800564:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80056b:	e8 9c 03 00 00       	call   80090c <_panic>
}

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bdschk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800570:	83 c4 2c             	add    $0x2c,%esp
  800573:	5b                   	pop    %ebx
  800574:	5e                   	pop    %esi
  800575:	5f                   	pop    %edi
  800576:	5d                   	pop    %ebp
  800577:	c3                   	ret    

00800578 <sys_env_set_illopcd_upcall>:

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
  800578:	55                   	push   %ebp
  800579:	89 e5                	mov    %esp,%ebp
  80057b:	57                   	push   %edi
  80057c:	56                   	push   %esi
  80057d:	53                   	push   %ebx
  80057e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800581:	bb 00 00 00 00       	mov    $0x0,%ebx
  800586:	b8 13 00 00 00       	mov    $0x13,%eax
  80058b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80058e:	8b 55 08             	mov    0x8(%ebp),%edx
  800591:	89 df                	mov    %ebx,%edi
  800593:	89 de                	mov    %ebx,%esi
  800595:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800597:	85 c0                	test   %eax,%eax
  800599:	7e 28                	jle    8005c3 <sys_env_set_illopcd_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80059b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80059f:	c7 44 24 0c 13 00 00 	movl   $0x13,0xc(%esp)
  8005a6:	00 
  8005a7:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8005ae:	00 
  8005af:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005b6:	00 
  8005b7:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8005be:	e8 49 03 00 00       	call   80090c <_panic>
}

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_illopcd_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8005c3:	83 c4 2c             	add    $0x2c,%esp
  8005c6:	5b                   	pop    %ebx
  8005c7:	5e                   	pop    %esi
  8005c8:	5f                   	pop    %edi
  8005c9:	5d                   	pop    %ebp
  8005ca:	c3                   	ret    

008005cb <sys_env_set_dvcntavl_upcall>:

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
  8005cb:	55                   	push   %ebp
  8005cc:	89 e5                	mov    %esp,%ebp
  8005ce:	57                   	push   %edi
  8005cf:	56                   	push   %esi
  8005d0:	53                   	push   %ebx
  8005d1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005d9:	b8 14 00 00 00       	mov    $0x14,%eax
  8005de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8005e4:	89 df                	mov    %ebx,%edi
  8005e6:	89 de                	mov    %ebx,%esi
  8005e8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005ea:	85 c0                	test   %eax,%eax
  8005ec:	7e 28                	jle    800616 <sys_env_set_dvcntavl_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005ee:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005f2:	c7 44 24 0c 14 00 00 	movl   $0x14,0xc(%esp)
  8005f9:	00 
  8005fa:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800601:	00 
  800602:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800609:	00 
  80060a:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800611:	e8 f6 02 00 00       	call   80090c <_panic>
}

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dvcntavl_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800616:	83 c4 2c             	add    $0x2c,%esp
  800619:	5b                   	pop    %ebx
  80061a:	5e                   	pop    %esi
  80061b:	5f                   	pop    %edi
  80061c:	5d                   	pop    %ebp
  80061d:	c3                   	ret    

0080061e <sys_env_set_dbfault_upcall>:

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
  80061e:	55                   	push   %ebp
  80061f:	89 e5                	mov    %esp,%ebp
  800621:	57                   	push   %edi
  800622:	56                   	push   %esi
  800623:	53                   	push   %ebx
  800624:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800627:	bb 00 00 00 00       	mov    $0x0,%ebx
  80062c:	b8 15 00 00 00       	mov    $0x15,%eax
  800631:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800634:	8b 55 08             	mov    0x8(%ebp),%edx
  800637:	89 df                	mov    %ebx,%edi
  800639:	89 de                	mov    %ebx,%esi
  80063b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80063d:	85 c0                	test   %eax,%eax
  80063f:	7e 28                	jle    800669 <sys_env_set_dbfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800641:	89 44 24 10          	mov    %eax,0x10(%esp)
  800645:	c7 44 24 0c 15 00 00 	movl   $0x15,0xc(%esp)
  80064c:	00 
  80064d:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800654:	00 
  800655:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80065c:	00 
  80065d:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800664:	e8 a3 02 00 00       	call   80090c <_panic>
}

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dbfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800669:	83 c4 2c             	add    $0x2c,%esp
  80066c:	5b                   	pop    %ebx
  80066d:	5e                   	pop    %esi
  80066e:	5f                   	pop    %edi
  80066f:	5d                   	pop    %ebp
  800670:	c3                   	ret    

00800671 <sys_env_set_ivldtss_upcall>:

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
  800671:	55                   	push   %ebp
  800672:	89 e5                	mov    %esp,%ebp
  800674:	57                   	push   %edi
  800675:	56                   	push   %esi
  800676:	53                   	push   %ebx
  800677:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80067a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80067f:	b8 16 00 00 00       	mov    $0x16,%eax
  800684:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800687:	8b 55 08             	mov    0x8(%ebp),%edx
  80068a:	89 df                	mov    %ebx,%edi
  80068c:	89 de                	mov    %ebx,%esi
  80068e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800690:	85 c0                	test   %eax,%eax
  800692:	7e 28                	jle    8006bc <sys_env_set_ivldtss_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800694:	89 44 24 10          	mov    %eax,0x10(%esp)
  800698:	c7 44 24 0c 16 00 00 	movl   $0x16,0xc(%esp)
  80069f:	00 
  8006a0:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8006a7:	00 
  8006a8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006af:	00 
  8006b0:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8006b7:	e8 50 02 00 00       	call   80090c <_panic>
}

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_ivldtss_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8006bc:	83 c4 2c             	add    $0x2c,%esp
  8006bf:	5b                   	pop    %ebx
  8006c0:	5e                   	pop    %esi
  8006c1:	5f                   	pop    %edi
  8006c2:	5d                   	pop    %ebp
  8006c3:	c3                   	ret    

008006c4 <sys_env_set_segntprst_upcall>:

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	57                   	push   %edi
  8006c8:	56                   	push   %esi
  8006c9:	53                   	push   %ebx
  8006ca:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d2:	b8 17 00 00 00       	mov    $0x17,%eax
  8006d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006da:	8b 55 08             	mov    0x8(%ebp),%edx
  8006dd:	89 df                	mov    %ebx,%edi
  8006df:	89 de                	mov    %ebx,%esi
  8006e1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	7e 28                	jle    80070f <sys_env_set_segntprst_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006eb:	c7 44 24 0c 17 00 00 	movl   $0x17,0xc(%esp)
  8006f2:	00 
  8006f3:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8006fa:	00 
  8006fb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800702:	00 
  800703:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80070a:	e8 fd 01 00 00       	call   80090c <_panic>
}

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_segntprst_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80070f:	83 c4 2c             	add    $0x2c,%esp
  800712:	5b                   	pop    %ebx
  800713:	5e                   	pop    %esi
  800714:	5f                   	pop    %edi
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <sys_env_set_stkexception_upcall>:

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	57                   	push   %edi
  80071b:	56                   	push   %esi
  80071c:	53                   	push   %ebx
  80071d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800720:	bb 00 00 00 00       	mov    $0x0,%ebx
  800725:	b8 18 00 00 00       	mov    $0x18,%eax
  80072a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80072d:	8b 55 08             	mov    0x8(%ebp),%edx
  800730:	89 df                	mov    %ebx,%edi
  800732:	89 de                	mov    %ebx,%esi
  800734:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800736:	85 c0                	test   %eax,%eax
  800738:	7e 28                	jle    800762 <sys_env_set_stkexception_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80073a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80073e:	c7 44 24 0c 18 00 00 	movl   $0x18,0xc(%esp)
  800745:	00 
  800746:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80074d:	00 
  80074e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800755:	00 
  800756:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80075d:	e8 aa 01 00 00       	call   80090c <_panic>
}

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_stkexception_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800762:	83 c4 2c             	add    $0x2c,%esp
  800765:	5b                   	pop    %ebx
  800766:	5e                   	pop    %esi
  800767:	5f                   	pop    %edi
  800768:	5d                   	pop    %ebp
  800769:	c3                   	ret    

0080076a <sys_env_set_gpfault_upcall>:

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	57                   	push   %edi
  80076e:	56                   	push   %esi
  80076f:	53                   	push   %ebx
  800770:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800773:	bb 00 00 00 00       	mov    $0x0,%ebx
  800778:	b8 19 00 00 00       	mov    $0x19,%eax
  80077d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800780:	8b 55 08             	mov    0x8(%ebp),%edx
  800783:	89 df                	mov    %ebx,%edi
  800785:	89 de                	mov    %ebx,%esi
  800787:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800789:	85 c0                	test   %eax,%eax
  80078b:	7e 28                	jle    8007b5 <sys_env_set_gpfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80078d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800791:	c7 44 24 0c 19 00 00 	movl   $0x19,0xc(%esp)
  800798:	00 
  800799:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8007a0:	00 
  8007a1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8007a8:	00 
  8007a9:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8007b0:	e8 57 01 00 00       	call   80090c <_panic>
}

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_gpfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8007b5:	83 c4 2c             	add    $0x2c,%esp
  8007b8:	5b                   	pop    %ebx
  8007b9:	5e                   	pop    %esi
  8007ba:	5f                   	pop    %edi
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <sys_env_set_fperror_upcall>:

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	57                   	push   %edi
  8007c1:	56                   	push   %esi
  8007c2:	53                   	push   %ebx
  8007c3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007cb:	b8 1a 00 00 00       	mov    $0x1a,%eax
  8007d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8007d6:	89 df                	mov    %ebx,%edi
  8007d8:	89 de                	mov    %ebx,%esi
  8007da:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8007dc:	85 c0                	test   %eax,%eax
  8007de:	7e 28                	jle    800808 <sys_env_set_fperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007e0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007e4:	c7 44 24 0c 1a 00 00 	movl   $0x1a,0xc(%esp)
  8007eb:	00 
  8007ec:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8007f3:	00 
  8007f4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8007fb:	00 
  8007fc:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800803:	e8 04 01 00 00       	call   80090c <_panic>
}

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_fperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800808:	83 c4 2c             	add    $0x2c,%esp
  80080b:	5b                   	pop    %ebx
  80080c:	5e                   	pop    %esi
  80080d:	5f                   	pop    %edi
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <sys_env_set_algchk_upcall>:

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	57                   	push   %edi
  800814:	56                   	push   %esi
  800815:	53                   	push   %ebx
  800816:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800819:	bb 00 00 00 00       	mov    $0x0,%ebx
  80081e:	b8 1b 00 00 00       	mov    $0x1b,%eax
  800823:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800826:	8b 55 08             	mov    0x8(%ebp),%edx
  800829:	89 df                	mov    %ebx,%edi
  80082b:	89 de                	mov    %ebx,%esi
  80082d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80082f:	85 c0                	test   %eax,%eax
  800831:	7e 28                	jle    80085b <sys_env_set_algchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800833:	89 44 24 10          	mov    %eax,0x10(%esp)
  800837:	c7 44 24 0c 1b 00 00 	movl   $0x1b,0xc(%esp)
  80083e:	00 
  80083f:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800846:	00 
  800847:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80084e:	00 
  80084f:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800856:	e8 b1 00 00 00       	call   80090c <_panic>
}

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_algchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80085b:	83 c4 2c             	add    $0x2c,%esp
  80085e:	5b                   	pop    %ebx
  80085f:	5e                   	pop    %esi
  800860:	5f                   	pop    %edi
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <sys_env_set_mchchk_upcall>:

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	57                   	push   %edi
  800867:	56                   	push   %esi
  800868:	53                   	push   %ebx
  800869:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80086c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800871:	b8 1c 00 00 00       	mov    $0x1c,%eax
  800876:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800879:	8b 55 08             	mov    0x8(%ebp),%edx
  80087c:	89 df                	mov    %ebx,%edi
  80087e:	89 de                	mov    %ebx,%esi
  800880:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800882:	85 c0                	test   %eax,%eax
  800884:	7e 28                	jle    8008ae <sys_env_set_mchchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800886:	89 44 24 10          	mov    %eax,0x10(%esp)
  80088a:	c7 44 24 0c 1c 00 00 	movl   $0x1c,0xc(%esp)
  800891:	00 
  800892:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800899:	00 
  80089a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8008a1:	00 
  8008a2:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8008a9:	e8 5e 00 00 00       	call   80090c <_panic>
}

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_mchchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8008ae:	83 c4 2c             	add    $0x2c,%esp
  8008b1:	5b                   	pop    %ebx
  8008b2:	5e                   	pop    %esi
  8008b3:	5f                   	pop    %edi
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <sys_env_set_SIMDfperror_upcall>:

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	57                   	push   %edi
  8008ba:	56                   	push   %esi
  8008bb:	53                   	push   %ebx
  8008bc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8008bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008c4:	b8 1d 00 00 00       	mov    $0x1d,%eax
  8008c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8008cf:	89 df                	mov    %ebx,%edi
  8008d1:	89 de                	mov    %ebx,%esi
  8008d3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8008d5:	85 c0                	test   %eax,%eax
  8008d7:	7e 28                	jle    800901 <sys_env_set_SIMDfperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8008d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8008dd:	c7 44 24 0c 1d 00 00 	movl   $0x1d,0xc(%esp)
  8008e4:	00 
  8008e5:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8008ec:	00 
  8008ed:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8008f4:	00 
  8008f5:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8008fc:	e8 0b 00 00 00       	call   80090c <_panic>
}

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_SIMDfperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800901:	83 c4 2c             	add    $0x2c,%esp
  800904:	5b                   	pop    %ebx
  800905:	5e                   	pop    %esi
  800906:	5f                   	pop    %edi
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    
  800909:	00 00                	add    %al,(%eax)
	...

0080090c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	56                   	push   %esi
  800910:	53                   	push   %ebx
  800911:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800914:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800917:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80091d:	e8 11 f8 ff ff       	call   800133 <sys_getenvid>
  800922:	8b 55 0c             	mov    0xc(%ebp),%edx
  800925:	89 54 24 10          	mov    %edx,0x10(%esp)
  800929:	8b 55 08             	mov    0x8(%ebp),%edx
  80092c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800930:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800934:	89 44 24 04          	mov    %eax,0x4(%esp)
  800938:	c7 04 24 78 15 80 00 	movl   $0x801578,(%esp)
  80093f:	e8 c0 00 00 00       	call   800a04 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800944:	89 74 24 04          	mov    %esi,0x4(%esp)
  800948:	8b 45 10             	mov    0x10(%ebp),%eax
  80094b:	89 04 24             	mov    %eax,(%esp)
  80094e:	e8 50 00 00 00       	call   8009a3 <vcprintf>
	cprintf("\n");
  800953:	c7 04 24 9c 15 80 00 	movl   $0x80159c,(%esp)
  80095a:	e8 a5 00 00 00       	call   800a04 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80095f:	cc                   	int3   
  800960:	eb fd                	jmp    80095f <_panic+0x53>
	...

00800964 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	53                   	push   %ebx
  800968:	83 ec 14             	sub    $0x14,%esp
  80096b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80096e:	8b 03                	mov    (%ebx),%eax
  800970:	8b 55 08             	mov    0x8(%ebp),%edx
  800973:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800977:	40                   	inc    %eax
  800978:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80097a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80097f:	75 19                	jne    80099a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800981:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800988:	00 
  800989:	8d 43 08             	lea    0x8(%ebx),%eax
  80098c:	89 04 24             	mov    %eax,(%esp)
  80098f:	e8 10 f7 ff ff       	call   8000a4 <sys_cputs>
		b->idx = 0;
  800994:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80099a:	ff 43 04             	incl   0x4(%ebx)
}
  80099d:	83 c4 14             	add    $0x14,%esp
  8009a0:	5b                   	pop    %ebx
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8009ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8009b3:	00 00 00 
	b.cnt = 0;
  8009b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8009bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8009c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ce:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8009d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d8:	c7 04 24 64 09 80 00 	movl   $0x800964,(%esp)
  8009df:	e8 b4 01 00 00       	call   800b98 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8009e4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8009ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ee:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8009f4:	89 04 24             	mov    %eax,(%esp)
  8009f7:	e8 a8 f6 ff ff       	call   8000a4 <sys_cputs>

	return b.cnt;
}
  8009fc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800a02:	c9                   	leave  
  800a03:	c3                   	ret    

00800a04 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800a0a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	89 04 24             	mov    %eax,(%esp)
  800a17:	e8 87 ff ff ff       	call   8009a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    
	...

00800a20 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	57                   	push   %edi
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
  800a26:	83 ec 3c             	sub    $0x3c,%esp
  800a29:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a2c:	89 d7                	mov    %edx,%edi
  800a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a31:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a37:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a3a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800a3d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800a40:	85 c0                	test   %eax,%eax
  800a42:	75 08                	jne    800a4c <printnum+0x2c>
  800a44:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a47:	39 45 10             	cmp    %eax,0x10(%ebp)
  800a4a:	77 57                	ja     800aa3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800a4c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800a50:	4b                   	dec    %ebx
  800a51:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800a55:	8b 45 10             	mov    0x10(%ebp),%eax
  800a58:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a5c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800a60:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800a64:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a6b:	00 
  800a6c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a6f:	89 04 24             	mov    %eax,(%esp)
  800a72:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a75:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a79:	e8 5a 08 00 00       	call   8012d8 <__udivdi3>
  800a7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a82:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a86:	89 04 24             	mov    %eax,(%esp)
  800a89:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a8d:	89 fa                	mov    %edi,%edx
  800a8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a92:	e8 89 ff ff ff       	call   800a20 <printnum>
  800a97:	eb 0f                	jmp    800aa8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800a99:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a9d:	89 34 24             	mov    %esi,(%esp)
  800aa0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800aa3:	4b                   	dec    %ebx
  800aa4:	85 db                	test   %ebx,%ebx
  800aa6:	7f f1                	jg     800a99 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800aa8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aac:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ab0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800abe:	00 
  800abf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ac2:	89 04 24             	mov    %eax,(%esp)
  800ac5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ac8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800acc:	e8 27 09 00 00       	call   8013f8 <__umoddi3>
  800ad1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ad5:	0f be 80 9e 15 80 00 	movsbl 0x80159e(%eax),%eax
  800adc:	89 04 24             	mov    %eax,(%esp)
  800adf:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800ae2:	83 c4 3c             	add    $0x3c,%esp
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800aed:	83 fa 01             	cmp    $0x1,%edx
  800af0:	7e 0e                	jle    800b00 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800af2:	8b 10                	mov    (%eax),%edx
  800af4:	8d 4a 08             	lea    0x8(%edx),%ecx
  800af7:	89 08                	mov    %ecx,(%eax)
  800af9:	8b 02                	mov    (%edx),%eax
  800afb:	8b 52 04             	mov    0x4(%edx),%edx
  800afe:	eb 22                	jmp    800b22 <getuint+0x38>
	else if (lflag)
  800b00:	85 d2                	test   %edx,%edx
  800b02:	74 10                	je     800b14 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800b04:	8b 10                	mov    (%eax),%edx
  800b06:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b09:	89 08                	mov    %ecx,(%eax)
  800b0b:	8b 02                	mov    (%edx),%eax
  800b0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b12:	eb 0e                	jmp    800b22 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800b14:	8b 10                	mov    (%eax),%edx
  800b16:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b19:	89 08                	mov    %ecx,(%eax)
  800b1b:	8b 02                	mov    (%edx),%eax
  800b1d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800b27:	83 fa 01             	cmp    $0x1,%edx
  800b2a:	7e 0e                	jle    800b3a <getint+0x16>
		return va_arg(*ap, long long);
  800b2c:	8b 10                	mov    (%eax),%edx
  800b2e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800b31:	89 08                	mov    %ecx,(%eax)
  800b33:	8b 02                	mov    (%edx),%eax
  800b35:	8b 52 04             	mov    0x4(%edx),%edx
  800b38:	eb 1a                	jmp    800b54 <getint+0x30>
	else if (lflag)
  800b3a:	85 d2                	test   %edx,%edx
  800b3c:	74 0c                	je     800b4a <getint+0x26>
		return va_arg(*ap, long);
  800b3e:	8b 10                	mov    (%eax),%edx
  800b40:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b43:	89 08                	mov    %ecx,(%eax)
  800b45:	8b 02                	mov    (%edx),%eax
  800b47:	99                   	cltd   
  800b48:	eb 0a                	jmp    800b54 <getint+0x30>
	else
		return va_arg(*ap, int);
  800b4a:	8b 10                	mov    (%eax),%edx
  800b4c:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b4f:	89 08                	mov    %ecx,(%eax)
  800b51:	8b 02                	mov    (%edx),%eax
  800b53:	99                   	cltd   
}
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800b5c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800b5f:	8b 10                	mov    (%eax),%edx
  800b61:	3b 50 04             	cmp    0x4(%eax),%edx
  800b64:	73 08                	jae    800b6e <sprintputch+0x18>
		*b->buf++ = ch;
  800b66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b69:	88 0a                	mov    %cl,(%edx)
  800b6b:	42                   	inc    %edx
  800b6c:	89 10                	mov    %edx,(%eax)
}
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800b76:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800b79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b7d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b80:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b87:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8e:	89 04 24             	mov    %eax,(%esp)
  800b91:	e8 02 00 00 00       	call   800b98 <vprintfmt>
	va_end(ap);
}
  800b96:	c9                   	leave  
  800b97:	c3                   	ret    

00800b98 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
  800b9e:	83 ec 4c             	sub    $0x4c,%esp
  800ba1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ba4:	8b 75 10             	mov    0x10(%ebp),%esi
  800ba7:	eb 12                	jmp    800bbb <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800ba9:	85 c0                	test   %eax,%eax
  800bab:	0f 84 40 03 00 00    	je     800ef1 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800bb1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bb5:	89 04 24             	mov    %eax,(%esp)
  800bb8:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800bbb:	0f b6 06             	movzbl (%esi),%eax
  800bbe:	46                   	inc    %esi
  800bbf:	83 f8 25             	cmp    $0x25,%eax
  800bc2:	75 e5                	jne    800ba9 <vprintfmt+0x11>
  800bc4:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800bc8:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800bcf:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800bd4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800bdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800be0:	eb 26                	jmp    800c08 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800be2:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800be5:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800be9:	eb 1d                	jmp    800c08 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800beb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800bee:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800bf2:	eb 14                	jmp    800c08 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bf4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800bf7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800bfe:	eb 08                	jmp    800c08 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800c00:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800c03:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c08:	0f b6 06             	movzbl (%esi),%eax
  800c0b:	8d 4e 01             	lea    0x1(%esi),%ecx
  800c0e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800c11:	8a 0e                	mov    (%esi),%cl
  800c13:	83 e9 23             	sub    $0x23,%ecx
  800c16:	80 f9 55             	cmp    $0x55,%cl
  800c19:	0f 87 b6 02 00 00    	ja     800ed5 <vprintfmt+0x33d>
  800c1f:	0f b6 c9             	movzbl %cl,%ecx
  800c22:	ff 24 8d 60 16 80 00 	jmp    *0x801660(,%ecx,4)
  800c29:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c2c:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800c31:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800c34:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  800c38:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800c3b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800c3e:	83 f9 09             	cmp    $0x9,%ecx
  800c41:	77 2a                	ja     800c6d <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c43:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800c44:	eb eb                	jmp    800c31 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800c46:	8b 45 14             	mov    0x14(%ebp),%eax
  800c49:	8d 48 04             	lea    0x4(%eax),%ecx
  800c4c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800c4f:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c51:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800c54:	eb 17                	jmp    800c6d <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800c56:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c5a:	78 98                	js     800bf4 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c5c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c5f:	eb a7                	jmp    800c08 <vprintfmt+0x70>
  800c61:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800c64:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800c6b:	eb 9b                	jmp    800c08 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800c6d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c71:	79 95                	jns    800c08 <vprintfmt+0x70>
  800c73:	eb 8b                	jmp    800c00 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800c75:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c76:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800c79:	eb 8d                	jmp    800c08 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800c7b:	8b 45 14             	mov    0x14(%ebp),%eax
  800c7e:	8d 50 04             	lea    0x4(%eax),%edx
  800c81:	89 55 14             	mov    %edx,0x14(%ebp)
  800c84:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c88:	8b 00                	mov    (%eax),%eax
  800c8a:	89 04 24             	mov    %eax,(%esp)
  800c8d:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c90:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800c93:	e9 23 ff ff ff       	jmp    800bbb <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800c98:	8b 45 14             	mov    0x14(%ebp),%eax
  800c9b:	8d 50 04             	lea    0x4(%eax),%edx
  800c9e:	89 55 14             	mov    %edx,0x14(%ebp)
  800ca1:	8b 00                	mov    (%eax),%eax
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	79 02                	jns    800ca9 <vprintfmt+0x111>
  800ca7:	f7 d8                	neg    %eax
  800ca9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800cab:	83 f8 09             	cmp    $0x9,%eax
  800cae:	7f 0b                	jg     800cbb <vprintfmt+0x123>
  800cb0:	8b 04 85 c0 17 80 00 	mov    0x8017c0(,%eax,4),%eax
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	75 23                	jne    800cde <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800cbb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cbf:	c7 44 24 08 b6 15 80 	movl   $0x8015b6,0x8(%esp)
  800cc6:	00 
  800cc7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cce:	89 04 24             	mov    %eax,(%esp)
  800cd1:	e8 9a fe ff ff       	call   800b70 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cd6:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800cd9:	e9 dd fe ff ff       	jmp    800bbb <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800cde:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ce2:	c7 44 24 08 bf 15 80 	movl   $0x8015bf,0x8(%esp)
  800ce9:	00 
  800cea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cee:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf1:	89 14 24             	mov    %edx,(%esp)
  800cf4:	e8 77 fe ff ff       	call   800b70 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cf9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800cfc:	e9 ba fe ff ff       	jmp    800bbb <vprintfmt+0x23>
  800d01:	89 f9                	mov    %edi,%ecx
  800d03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d06:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d09:	8b 45 14             	mov    0x14(%ebp),%eax
  800d0c:	8d 50 04             	lea    0x4(%eax),%edx
  800d0f:	89 55 14             	mov    %edx,0x14(%ebp)
  800d12:	8b 30                	mov    (%eax),%esi
  800d14:	85 f6                	test   %esi,%esi
  800d16:	75 05                	jne    800d1d <vprintfmt+0x185>
				p = "(null)";
  800d18:	be af 15 80 00       	mov    $0x8015af,%esi
			if (width > 0 && padc != '-')
  800d1d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800d21:	0f 8e 84 00 00 00    	jle    800dab <vprintfmt+0x213>
  800d27:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800d2b:	74 7e                	je     800dab <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800d2d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d31:	89 34 24             	mov    %esi,(%esp)
  800d34:	e8 5d 02 00 00       	call   800f96 <strnlen>
  800d39:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800d3c:	29 c2                	sub    %eax,%edx
  800d3e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800d41:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800d45:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800d48:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800d4b:	89 de                	mov    %ebx,%esi
  800d4d:	89 d3                	mov    %edx,%ebx
  800d4f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d51:	eb 0b                	jmp    800d5e <vprintfmt+0x1c6>
					putch(padc, putdat);
  800d53:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d57:	89 3c 24             	mov    %edi,(%esp)
  800d5a:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d5d:	4b                   	dec    %ebx
  800d5e:	85 db                	test   %ebx,%ebx
  800d60:	7f f1                	jg     800d53 <vprintfmt+0x1bb>
  800d62:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800d65:	89 f3                	mov    %esi,%ebx
  800d67:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800d6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	79 05                	jns    800d76 <vprintfmt+0x1de>
  800d71:	b8 00 00 00 00       	mov    $0x0,%eax
  800d76:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d79:	29 c2                	sub    %eax,%edx
  800d7b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800d7e:	eb 2b                	jmp    800dab <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800d80:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800d84:	74 18                	je     800d9e <vprintfmt+0x206>
  800d86:	8d 50 e0             	lea    -0x20(%eax),%edx
  800d89:	83 fa 5e             	cmp    $0x5e,%edx
  800d8c:	76 10                	jbe    800d9e <vprintfmt+0x206>
					putch('?', putdat);
  800d8e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d92:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800d99:	ff 55 08             	call   *0x8(%ebp)
  800d9c:	eb 0a                	jmp    800da8 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800d9e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800da2:	89 04 24             	mov    %eax,(%esp)
  800da5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800da8:	ff 4d e4             	decl   -0x1c(%ebp)
  800dab:	0f be 06             	movsbl (%esi),%eax
  800dae:	46                   	inc    %esi
  800daf:	85 c0                	test   %eax,%eax
  800db1:	74 21                	je     800dd4 <vprintfmt+0x23c>
  800db3:	85 ff                	test   %edi,%edi
  800db5:	78 c9                	js     800d80 <vprintfmt+0x1e8>
  800db7:	4f                   	dec    %edi
  800db8:	79 c6                	jns    800d80 <vprintfmt+0x1e8>
  800dba:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dbd:	89 de                	mov    %ebx,%esi
  800dbf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800dc2:	eb 18                	jmp    800ddc <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800dc4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dc8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800dcf:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800dd1:	4b                   	dec    %ebx
  800dd2:	eb 08                	jmp    800ddc <vprintfmt+0x244>
  800dd4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dd7:	89 de                	mov    %ebx,%esi
  800dd9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ddc:	85 db                	test   %ebx,%ebx
  800dde:	7f e4                	jg     800dc4 <vprintfmt+0x22c>
  800de0:	89 7d 08             	mov    %edi,0x8(%ebp)
  800de3:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800de5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800de8:	e9 ce fd ff ff       	jmp    800bbb <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ded:	8d 45 14             	lea    0x14(%ebp),%eax
  800df0:	e8 2f fd ff ff       	call   800b24 <getint>
  800df5:	89 c6                	mov    %eax,%esi
  800df7:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800df9:	85 d2                	test   %edx,%edx
  800dfb:	78 07                	js     800e04 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800dfd:	be 0a 00 00 00       	mov    $0xa,%esi
  800e02:	eb 7e                	jmp    800e82 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800e04:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e08:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800e0f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800e12:	89 f0                	mov    %esi,%eax
  800e14:	89 fa                	mov    %edi,%edx
  800e16:	f7 d8                	neg    %eax
  800e18:	83 d2 00             	adc    $0x0,%edx
  800e1b:	f7 da                	neg    %edx
			}
			base = 10;
  800e1d:	be 0a 00 00 00       	mov    $0xa,%esi
  800e22:	eb 5e                	jmp    800e82 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800e24:	8d 45 14             	lea    0x14(%ebp),%eax
  800e27:	e8 be fc ff ff       	call   800aea <getuint>
			base = 10;
  800e2c:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800e31:	eb 4f                	jmp    800e82 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800e33:	8d 45 14             	lea    0x14(%ebp),%eax
  800e36:	e8 af fc ff ff       	call   800aea <getuint>
			base = 8;
  800e3b:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800e40:	eb 40                	jmp    800e82 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  800e42:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e46:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800e4d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800e50:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e54:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800e5b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800e5e:	8b 45 14             	mov    0x14(%ebp),%eax
  800e61:	8d 50 04             	lea    0x4(%eax),%edx
  800e64:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800e67:	8b 00                	mov    (%eax),%eax
  800e69:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800e6e:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800e73:	eb 0d                	jmp    800e82 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800e75:	8d 45 14             	lea    0x14(%ebp),%eax
  800e78:	e8 6d fc ff ff       	call   800aea <getuint>
			base = 16;
  800e7d:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800e82:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800e86:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800e8a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800e8d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e91:	89 74 24 08          	mov    %esi,0x8(%esp)
  800e95:	89 04 24             	mov    %eax,(%esp)
  800e98:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e9c:	89 da                	mov    %ebx,%edx
  800e9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea1:	e8 7a fb ff ff       	call   800a20 <printnum>
			break;
  800ea6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ea9:	e9 0d fd ff ff       	jmp    800bbb <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  800eae:	8d 45 14             	lea    0x14(%ebp),%eax
  800eb1:	e8 6e fc ff ff       	call   800b24 <getint>
  800eb6:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ebb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  800ebe:	e9 f8 fc ff ff       	jmp    800bbb <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ec3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ec7:	89 04 24             	mov    %eax,(%esp)
  800eca:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ecd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ed0:	e9 e6 fc ff ff       	jmp    800bbb <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ed5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ed9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ee0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ee3:	eb 01                	jmp    800ee6 <vprintfmt+0x34e>
  800ee5:	4e                   	dec    %esi
  800ee6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800eea:	75 f9                	jne    800ee5 <vprintfmt+0x34d>
  800eec:	e9 ca fc ff ff       	jmp    800bbb <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800ef1:	83 c4 4c             	add    $0x4c,%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	83 ec 28             	sub    $0x28,%esp
  800eff:	8b 45 08             	mov    0x8(%ebp),%eax
  800f02:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800f05:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f08:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800f0c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f0f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800f16:	85 c0                	test   %eax,%eax
  800f18:	74 30                	je     800f4a <vsnprintf+0x51>
  800f1a:	85 d2                	test   %edx,%edx
  800f1c:	7e 33                	jle    800f51 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f1e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f21:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f25:	8b 45 10             	mov    0x10(%ebp),%eax
  800f28:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f2c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f33:	c7 04 24 56 0b 80 00 	movl   $0x800b56,(%esp)
  800f3a:	e8 59 fc ff ff       	call   800b98 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f42:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f48:	eb 0c                	jmp    800f56 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800f4a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f4f:	eb 05                	jmp    800f56 <vsnprintf+0x5d>
  800f51:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800f56:	c9                   	leave  
  800f57:	c3                   	ret    

00800f58 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800f5e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800f61:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f65:	8b 45 10             	mov    0x10(%ebp),%eax
  800f68:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f73:	8b 45 08             	mov    0x8(%ebp),%eax
  800f76:	89 04 24             	mov    %eax,(%esp)
  800f79:	e8 7b ff ff ff       	call   800ef9 <vsnprintf>
	va_end(ap);

	return rc;
}
  800f7e:	c9                   	leave  
  800f7f:	c3                   	ret    

00800f80 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800f86:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8b:	eb 01                	jmp    800f8e <strlen+0xe>
		n++;
  800f8d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800f8e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800f92:	75 f9                	jne    800f8d <strlen+0xd>
		n++;
	return n;
}
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    

00800f96 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800f9c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa4:	eb 01                	jmp    800fa7 <strnlen+0x11>
		n++;
  800fa6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fa7:	39 d0                	cmp    %edx,%eax
  800fa9:	74 06                	je     800fb1 <strnlen+0x1b>
  800fab:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800faf:	75 f5                	jne    800fa6 <strnlen+0x10>
		n++;
	return n;
}
  800fb1:	5d                   	pop    %ebp
  800fb2:	c3                   	ret    

00800fb3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	53                   	push   %ebx
  800fb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800fbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800fc5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800fc8:	42                   	inc    %edx
  800fc9:	84 c9                	test   %cl,%cl
  800fcb:	75 f5                	jne    800fc2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800fcd:	5b                   	pop    %ebx
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    

00800fd0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	53                   	push   %ebx
  800fd4:	83 ec 08             	sub    $0x8,%esp
  800fd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800fda:	89 1c 24             	mov    %ebx,(%esp)
  800fdd:	e8 9e ff ff ff       	call   800f80 <strlen>
	strcpy(dst + len, src);
  800fe2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fe5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fe9:	01 d8                	add    %ebx,%eax
  800feb:	89 04 24             	mov    %eax,(%esp)
  800fee:	e8 c0 ff ff ff       	call   800fb3 <strcpy>
	return dst;
}
  800ff3:	89 d8                	mov    %ebx,%eax
  800ff5:	83 c4 08             	add    $0x8,%esp
  800ff8:	5b                   	pop    %ebx
  800ff9:	5d                   	pop    %ebp
  800ffa:	c3                   	ret    

00800ffb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	56                   	push   %esi
  800fff:	53                   	push   %ebx
  801000:	8b 45 08             	mov    0x8(%ebp),%eax
  801003:	8b 55 0c             	mov    0xc(%ebp),%edx
  801006:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801009:	b9 00 00 00 00       	mov    $0x0,%ecx
  80100e:	eb 0c                	jmp    80101c <strncpy+0x21>
		*dst++ = *src;
  801010:	8a 1a                	mov    (%edx),%bl
  801012:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801015:	80 3a 01             	cmpb   $0x1,(%edx)
  801018:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80101b:	41                   	inc    %ecx
  80101c:	39 f1                	cmp    %esi,%ecx
  80101e:	75 f0                	jne    801010 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801020:	5b                   	pop    %ebx
  801021:	5e                   	pop    %esi
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    

00801024 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	56                   	push   %esi
  801028:	53                   	push   %ebx
  801029:	8b 75 08             	mov    0x8(%ebp),%esi
  80102c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80102f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801032:	85 d2                	test   %edx,%edx
  801034:	75 0a                	jne    801040 <strlcpy+0x1c>
  801036:	89 f0                	mov    %esi,%eax
  801038:	eb 1a                	jmp    801054 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80103a:	88 18                	mov    %bl,(%eax)
  80103c:	40                   	inc    %eax
  80103d:	41                   	inc    %ecx
  80103e:	eb 02                	jmp    801042 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801040:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801042:	4a                   	dec    %edx
  801043:	74 0a                	je     80104f <strlcpy+0x2b>
  801045:	8a 19                	mov    (%ecx),%bl
  801047:	84 db                	test   %bl,%bl
  801049:	75 ef                	jne    80103a <strlcpy+0x16>
  80104b:	89 c2                	mov    %eax,%edx
  80104d:	eb 02                	jmp    801051 <strlcpy+0x2d>
  80104f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801051:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801054:	29 f0                	sub    %esi,%eax
}
  801056:	5b                   	pop    %ebx
  801057:	5e                   	pop    %esi
  801058:	5d                   	pop    %ebp
  801059:	c3                   	ret    

0080105a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801060:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801063:	eb 02                	jmp    801067 <strcmp+0xd>
		p++, q++;
  801065:	41                   	inc    %ecx
  801066:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801067:	8a 01                	mov    (%ecx),%al
  801069:	84 c0                	test   %al,%al
  80106b:	74 04                	je     801071 <strcmp+0x17>
  80106d:	3a 02                	cmp    (%edx),%al
  80106f:	74 f4                	je     801065 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801071:	0f b6 c0             	movzbl %al,%eax
  801074:	0f b6 12             	movzbl (%edx),%edx
  801077:	29 d0                	sub    %edx,%eax
}
  801079:	5d                   	pop    %ebp
  80107a:	c3                   	ret    

0080107b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	53                   	push   %ebx
  80107f:	8b 45 08             	mov    0x8(%ebp),%eax
  801082:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801085:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801088:	eb 03                	jmp    80108d <strncmp+0x12>
		n--, p++, q++;
  80108a:	4a                   	dec    %edx
  80108b:	40                   	inc    %eax
  80108c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80108d:	85 d2                	test   %edx,%edx
  80108f:	74 14                	je     8010a5 <strncmp+0x2a>
  801091:	8a 18                	mov    (%eax),%bl
  801093:	84 db                	test   %bl,%bl
  801095:	74 04                	je     80109b <strncmp+0x20>
  801097:	3a 19                	cmp    (%ecx),%bl
  801099:	74 ef                	je     80108a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80109b:	0f b6 00             	movzbl (%eax),%eax
  80109e:	0f b6 11             	movzbl (%ecx),%edx
  8010a1:	29 d0                	sub    %edx,%eax
  8010a3:	eb 05                	jmp    8010aa <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8010a5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010aa:	5b                   	pop    %ebx
  8010ab:	5d                   	pop    %ebp
  8010ac:	c3                   	ret    

008010ad <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8010ad:	55                   	push   %ebp
  8010ae:	89 e5                	mov    %esp,%ebp
  8010b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8010b6:	eb 05                	jmp    8010bd <strchr+0x10>
		if (*s == c)
  8010b8:	38 ca                	cmp    %cl,%dl
  8010ba:	74 0c                	je     8010c8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8010bc:	40                   	inc    %eax
  8010bd:	8a 10                	mov    (%eax),%dl
  8010bf:	84 d2                	test   %dl,%dl
  8010c1:	75 f5                	jne    8010b8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8010c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8010d3:	eb 05                	jmp    8010da <strfind+0x10>
		if (*s == c)
  8010d5:	38 ca                	cmp    %cl,%dl
  8010d7:	74 07                	je     8010e0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8010d9:	40                   	inc    %eax
  8010da:	8a 10                	mov    (%eax),%dl
  8010dc:	84 d2                	test   %dl,%dl
  8010de:	75 f5                	jne    8010d5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8010e0:	5d                   	pop    %ebp
  8010e1:	c3                   	ret    

008010e2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	57                   	push   %edi
  8010e6:	56                   	push   %esi
  8010e7:	53                   	push   %ebx
  8010e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8010f1:	85 c9                	test   %ecx,%ecx
  8010f3:	74 30                	je     801125 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8010f5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8010fb:	75 25                	jne    801122 <memset+0x40>
  8010fd:	f6 c1 03             	test   $0x3,%cl
  801100:	75 20                	jne    801122 <memset+0x40>
		c &= 0xFF;
  801102:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801105:	89 d3                	mov    %edx,%ebx
  801107:	c1 e3 08             	shl    $0x8,%ebx
  80110a:	89 d6                	mov    %edx,%esi
  80110c:	c1 e6 18             	shl    $0x18,%esi
  80110f:	89 d0                	mov    %edx,%eax
  801111:	c1 e0 10             	shl    $0x10,%eax
  801114:	09 f0                	or     %esi,%eax
  801116:	09 d0                	or     %edx,%eax
  801118:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80111a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80111d:	fc                   	cld    
  80111e:	f3 ab                	rep stos %eax,%es:(%edi)
  801120:	eb 03                	jmp    801125 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801122:	fc                   	cld    
  801123:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801125:	89 f8                	mov    %edi,%eax
  801127:	5b                   	pop    %ebx
  801128:	5e                   	pop    %esi
  801129:	5f                   	pop    %edi
  80112a:	5d                   	pop    %ebp
  80112b:	c3                   	ret    

0080112c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	57                   	push   %edi
  801130:	56                   	push   %esi
  801131:	8b 45 08             	mov    0x8(%ebp),%eax
  801134:	8b 75 0c             	mov    0xc(%ebp),%esi
  801137:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80113a:	39 c6                	cmp    %eax,%esi
  80113c:	73 34                	jae    801172 <memmove+0x46>
  80113e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801141:	39 d0                	cmp    %edx,%eax
  801143:	73 2d                	jae    801172 <memmove+0x46>
		s += n;
		d += n;
  801145:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801148:	f6 c2 03             	test   $0x3,%dl
  80114b:	75 1b                	jne    801168 <memmove+0x3c>
  80114d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801153:	75 13                	jne    801168 <memmove+0x3c>
  801155:	f6 c1 03             	test   $0x3,%cl
  801158:	75 0e                	jne    801168 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80115a:	83 ef 04             	sub    $0x4,%edi
  80115d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801160:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801163:	fd                   	std    
  801164:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801166:	eb 07                	jmp    80116f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801168:	4f                   	dec    %edi
  801169:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80116c:	fd                   	std    
  80116d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80116f:	fc                   	cld    
  801170:	eb 20                	jmp    801192 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801172:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801178:	75 13                	jne    80118d <memmove+0x61>
  80117a:	a8 03                	test   $0x3,%al
  80117c:	75 0f                	jne    80118d <memmove+0x61>
  80117e:	f6 c1 03             	test   $0x3,%cl
  801181:	75 0a                	jne    80118d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801183:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801186:	89 c7                	mov    %eax,%edi
  801188:	fc                   	cld    
  801189:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80118b:	eb 05                	jmp    801192 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80118d:	89 c7                	mov    %eax,%edi
  80118f:	fc                   	cld    
  801190:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801192:	5e                   	pop    %esi
  801193:	5f                   	pop    %edi
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    

00801196 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80119c:	8b 45 10             	mov    0x10(%ebp),%eax
  80119f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ad:	89 04 24             	mov    %eax,(%esp)
  8011b0:	e8 77 ff ff ff       	call   80112c <memmove>
}
  8011b5:	c9                   	leave  
  8011b6:	c3                   	ret    

008011b7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	57                   	push   %edi
  8011bb:	56                   	push   %esi
  8011bc:	53                   	push   %ebx
  8011bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011c0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8011cb:	eb 16                	jmp    8011e3 <memcmp+0x2c>
		if (*s1 != *s2)
  8011cd:	8a 04 17             	mov    (%edi,%edx,1),%al
  8011d0:	42                   	inc    %edx
  8011d1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8011d5:	38 c8                	cmp    %cl,%al
  8011d7:	74 0a                	je     8011e3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8011d9:	0f b6 c0             	movzbl %al,%eax
  8011dc:	0f b6 c9             	movzbl %cl,%ecx
  8011df:	29 c8                	sub    %ecx,%eax
  8011e1:	eb 09                	jmp    8011ec <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011e3:	39 da                	cmp    %ebx,%edx
  8011e5:	75 e6                	jne    8011cd <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8011e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ec:	5b                   	pop    %ebx
  8011ed:	5e                   	pop    %esi
  8011ee:	5f                   	pop    %edi
  8011ef:	5d                   	pop    %ebp
  8011f0:	c3                   	ret    

008011f1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8011ff:	eb 05                	jmp    801206 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801201:	38 08                	cmp    %cl,(%eax)
  801203:	74 05                	je     80120a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801205:	40                   	inc    %eax
  801206:	39 d0                	cmp    %edx,%eax
  801208:	72 f7                	jb     801201 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80120a:	5d                   	pop    %ebp
  80120b:	c3                   	ret    

0080120c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	57                   	push   %edi
  801210:	56                   	push   %esi
  801211:	53                   	push   %ebx
  801212:	8b 55 08             	mov    0x8(%ebp),%edx
  801215:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801218:	eb 01                	jmp    80121b <strtol+0xf>
		s++;
  80121a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80121b:	8a 02                	mov    (%edx),%al
  80121d:	3c 20                	cmp    $0x20,%al
  80121f:	74 f9                	je     80121a <strtol+0xe>
  801221:	3c 09                	cmp    $0x9,%al
  801223:	74 f5                	je     80121a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801225:	3c 2b                	cmp    $0x2b,%al
  801227:	75 08                	jne    801231 <strtol+0x25>
		s++;
  801229:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80122a:	bf 00 00 00 00       	mov    $0x0,%edi
  80122f:	eb 13                	jmp    801244 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801231:	3c 2d                	cmp    $0x2d,%al
  801233:	75 0a                	jne    80123f <strtol+0x33>
		s++, neg = 1;
  801235:	8d 52 01             	lea    0x1(%edx),%edx
  801238:	bf 01 00 00 00       	mov    $0x1,%edi
  80123d:	eb 05                	jmp    801244 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80123f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801244:	85 db                	test   %ebx,%ebx
  801246:	74 05                	je     80124d <strtol+0x41>
  801248:	83 fb 10             	cmp    $0x10,%ebx
  80124b:	75 28                	jne    801275 <strtol+0x69>
  80124d:	8a 02                	mov    (%edx),%al
  80124f:	3c 30                	cmp    $0x30,%al
  801251:	75 10                	jne    801263 <strtol+0x57>
  801253:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801257:	75 0a                	jne    801263 <strtol+0x57>
		s += 2, base = 16;
  801259:	83 c2 02             	add    $0x2,%edx
  80125c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801261:	eb 12                	jmp    801275 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801263:	85 db                	test   %ebx,%ebx
  801265:	75 0e                	jne    801275 <strtol+0x69>
  801267:	3c 30                	cmp    $0x30,%al
  801269:	75 05                	jne    801270 <strtol+0x64>
		s++, base = 8;
  80126b:	42                   	inc    %edx
  80126c:	b3 08                	mov    $0x8,%bl
  80126e:	eb 05                	jmp    801275 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801270:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801275:	b8 00 00 00 00       	mov    $0x0,%eax
  80127a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80127c:	8a 0a                	mov    (%edx),%cl
  80127e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801281:	80 fb 09             	cmp    $0x9,%bl
  801284:	77 08                	ja     80128e <strtol+0x82>
			dig = *s - '0';
  801286:	0f be c9             	movsbl %cl,%ecx
  801289:	83 e9 30             	sub    $0x30,%ecx
  80128c:	eb 1e                	jmp    8012ac <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80128e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801291:	80 fb 19             	cmp    $0x19,%bl
  801294:	77 08                	ja     80129e <strtol+0x92>
			dig = *s - 'a' + 10;
  801296:	0f be c9             	movsbl %cl,%ecx
  801299:	83 e9 57             	sub    $0x57,%ecx
  80129c:	eb 0e                	jmp    8012ac <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80129e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8012a1:	80 fb 19             	cmp    $0x19,%bl
  8012a4:	77 12                	ja     8012b8 <strtol+0xac>
			dig = *s - 'A' + 10;
  8012a6:	0f be c9             	movsbl %cl,%ecx
  8012a9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8012ac:	39 f1                	cmp    %esi,%ecx
  8012ae:	7d 0c                	jge    8012bc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8012b0:	42                   	inc    %edx
  8012b1:	0f af c6             	imul   %esi,%eax
  8012b4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8012b6:	eb c4                	jmp    80127c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8012b8:	89 c1                	mov    %eax,%ecx
  8012ba:	eb 02                	jmp    8012be <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8012bc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8012be:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8012c2:	74 05                	je     8012c9 <strtol+0xbd>
		*endptr = (char *) s;
  8012c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012c7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8012c9:	85 ff                	test   %edi,%edi
  8012cb:	74 04                	je     8012d1 <strtol+0xc5>
  8012cd:	89 c8                	mov    %ecx,%eax
  8012cf:	f7 d8                	neg    %eax
}
  8012d1:	5b                   	pop    %ebx
  8012d2:	5e                   	pop    %esi
  8012d3:	5f                   	pop    %edi
  8012d4:	5d                   	pop    %ebp
  8012d5:	c3                   	ret    
	...

008012d8 <__udivdi3>:
  8012d8:	55                   	push   %ebp
  8012d9:	57                   	push   %edi
  8012da:	56                   	push   %esi
  8012db:	83 ec 10             	sub    $0x10,%esp
  8012de:	8b 74 24 20          	mov    0x20(%esp),%esi
  8012e2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8012e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ea:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8012ee:	89 cd                	mov    %ecx,%ebp
  8012f0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	75 2c                	jne    801324 <__udivdi3+0x4c>
  8012f8:	39 f9                	cmp    %edi,%ecx
  8012fa:	77 68                	ja     801364 <__udivdi3+0x8c>
  8012fc:	85 c9                	test   %ecx,%ecx
  8012fe:	75 0b                	jne    80130b <__udivdi3+0x33>
  801300:	b8 01 00 00 00       	mov    $0x1,%eax
  801305:	31 d2                	xor    %edx,%edx
  801307:	f7 f1                	div    %ecx
  801309:	89 c1                	mov    %eax,%ecx
  80130b:	31 d2                	xor    %edx,%edx
  80130d:	89 f8                	mov    %edi,%eax
  80130f:	f7 f1                	div    %ecx
  801311:	89 c7                	mov    %eax,%edi
  801313:	89 f0                	mov    %esi,%eax
  801315:	f7 f1                	div    %ecx
  801317:	89 c6                	mov    %eax,%esi
  801319:	89 f0                	mov    %esi,%eax
  80131b:	89 fa                	mov    %edi,%edx
  80131d:	83 c4 10             	add    $0x10,%esp
  801320:	5e                   	pop    %esi
  801321:	5f                   	pop    %edi
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    
  801324:	39 f8                	cmp    %edi,%eax
  801326:	77 2c                	ja     801354 <__udivdi3+0x7c>
  801328:	0f bd f0             	bsr    %eax,%esi
  80132b:	83 f6 1f             	xor    $0x1f,%esi
  80132e:	75 4c                	jne    80137c <__udivdi3+0xa4>
  801330:	39 f8                	cmp    %edi,%eax
  801332:	bf 00 00 00 00       	mov    $0x0,%edi
  801337:	72 0a                	jb     801343 <__udivdi3+0x6b>
  801339:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80133d:	0f 87 ad 00 00 00    	ja     8013f0 <__udivdi3+0x118>
  801343:	be 01 00 00 00       	mov    $0x1,%esi
  801348:	89 f0                	mov    %esi,%eax
  80134a:	89 fa                	mov    %edi,%edx
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	5e                   	pop    %esi
  801350:	5f                   	pop    %edi
  801351:	5d                   	pop    %ebp
  801352:	c3                   	ret    
  801353:	90                   	nop
  801354:	31 ff                	xor    %edi,%edi
  801356:	31 f6                	xor    %esi,%esi
  801358:	89 f0                	mov    %esi,%eax
  80135a:	89 fa                	mov    %edi,%edx
  80135c:	83 c4 10             	add    $0x10,%esp
  80135f:	5e                   	pop    %esi
  801360:	5f                   	pop    %edi
  801361:	5d                   	pop    %ebp
  801362:	c3                   	ret    
  801363:	90                   	nop
  801364:	89 fa                	mov    %edi,%edx
  801366:	89 f0                	mov    %esi,%eax
  801368:	f7 f1                	div    %ecx
  80136a:	89 c6                	mov    %eax,%esi
  80136c:	31 ff                	xor    %edi,%edi
  80136e:	89 f0                	mov    %esi,%eax
  801370:	89 fa                	mov    %edi,%edx
  801372:	83 c4 10             	add    $0x10,%esp
  801375:	5e                   	pop    %esi
  801376:	5f                   	pop    %edi
  801377:	5d                   	pop    %ebp
  801378:	c3                   	ret    
  801379:	8d 76 00             	lea    0x0(%esi),%esi
  80137c:	89 f1                	mov    %esi,%ecx
  80137e:	d3 e0                	shl    %cl,%eax
  801380:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801384:	b8 20 00 00 00       	mov    $0x20,%eax
  801389:	29 f0                	sub    %esi,%eax
  80138b:	89 ea                	mov    %ebp,%edx
  80138d:	88 c1                	mov    %al,%cl
  80138f:	d3 ea                	shr    %cl,%edx
  801391:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801395:	09 ca                	or     %ecx,%edx
  801397:	89 54 24 08          	mov    %edx,0x8(%esp)
  80139b:	89 f1                	mov    %esi,%ecx
  80139d:	d3 e5                	shl    %cl,%ebp
  80139f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8013a3:	89 fd                	mov    %edi,%ebp
  8013a5:	88 c1                	mov    %al,%cl
  8013a7:	d3 ed                	shr    %cl,%ebp
  8013a9:	89 fa                	mov    %edi,%edx
  8013ab:	89 f1                	mov    %esi,%ecx
  8013ad:	d3 e2                	shl    %cl,%edx
  8013af:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013b3:	88 c1                	mov    %al,%cl
  8013b5:	d3 ef                	shr    %cl,%edi
  8013b7:	09 d7                	or     %edx,%edi
  8013b9:	89 f8                	mov    %edi,%eax
  8013bb:	89 ea                	mov    %ebp,%edx
  8013bd:	f7 74 24 08          	divl   0x8(%esp)
  8013c1:	89 d1                	mov    %edx,%ecx
  8013c3:	89 c7                	mov    %eax,%edi
  8013c5:	f7 64 24 0c          	mull   0xc(%esp)
  8013c9:	39 d1                	cmp    %edx,%ecx
  8013cb:	72 17                	jb     8013e4 <__udivdi3+0x10c>
  8013cd:	74 09                	je     8013d8 <__udivdi3+0x100>
  8013cf:	89 fe                	mov    %edi,%esi
  8013d1:	31 ff                	xor    %edi,%edi
  8013d3:	e9 41 ff ff ff       	jmp    801319 <__udivdi3+0x41>
  8013d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013dc:	89 f1                	mov    %esi,%ecx
  8013de:	d3 e2                	shl    %cl,%edx
  8013e0:	39 c2                	cmp    %eax,%edx
  8013e2:	73 eb                	jae    8013cf <__udivdi3+0xf7>
  8013e4:	8d 77 ff             	lea    -0x1(%edi),%esi
  8013e7:	31 ff                	xor    %edi,%edi
  8013e9:	e9 2b ff ff ff       	jmp    801319 <__udivdi3+0x41>
  8013ee:	66 90                	xchg   %ax,%ax
  8013f0:	31 f6                	xor    %esi,%esi
  8013f2:	e9 22 ff ff ff       	jmp    801319 <__udivdi3+0x41>
	...

008013f8 <__umoddi3>:
  8013f8:	55                   	push   %ebp
  8013f9:	57                   	push   %edi
  8013fa:	56                   	push   %esi
  8013fb:	83 ec 20             	sub    $0x20,%esp
  8013fe:	8b 44 24 30          	mov    0x30(%esp),%eax
  801402:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801406:	89 44 24 14          	mov    %eax,0x14(%esp)
  80140a:	8b 74 24 34          	mov    0x34(%esp),%esi
  80140e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801412:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801416:	89 c7                	mov    %eax,%edi
  801418:	89 f2                	mov    %esi,%edx
  80141a:	85 ed                	test   %ebp,%ebp
  80141c:	75 16                	jne    801434 <__umoddi3+0x3c>
  80141e:	39 f1                	cmp    %esi,%ecx
  801420:	0f 86 a6 00 00 00    	jbe    8014cc <__umoddi3+0xd4>
  801426:	f7 f1                	div    %ecx
  801428:	89 d0                	mov    %edx,%eax
  80142a:	31 d2                	xor    %edx,%edx
  80142c:	83 c4 20             	add    $0x20,%esp
  80142f:	5e                   	pop    %esi
  801430:	5f                   	pop    %edi
  801431:	5d                   	pop    %ebp
  801432:	c3                   	ret    
  801433:	90                   	nop
  801434:	39 f5                	cmp    %esi,%ebp
  801436:	0f 87 ac 00 00 00    	ja     8014e8 <__umoddi3+0xf0>
  80143c:	0f bd c5             	bsr    %ebp,%eax
  80143f:	83 f0 1f             	xor    $0x1f,%eax
  801442:	89 44 24 10          	mov    %eax,0x10(%esp)
  801446:	0f 84 a8 00 00 00    	je     8014f4 <__umoddi3+0xfc>
  80144c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801450:	d3 e5                	shl    %cl,%ebp
  801452:	bf 20 00 00 00       	mov    $0x20,%edi
  801457:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80145b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80145f:	89 f9                	mov    %edi,%ecx
  801461:	d3 e8                	shr    %cl,%eax
  801463:	09 e8                	or     %ebp,%eax
  801465:	89 44 24 18          	mov    %eax,0x18(%esp)
  801469:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80146d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801471:	d3 e0                	shl    %cl,%eax
  801473:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801477:	89 f2                	mov    %esi,%edx
  801479:	d3 e2                	shl    %cl,%edx
  80147b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80147f:	d3 e0                	shl    %cl,%eax
  801481:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801485:	8b 44 24 14          	mov    0x14(%esp),%eax
  801489:	89 f9                	mov    %edi,%ecx
  80148b:	d3 e8                	shr    %cl,%eax
  80148d:	09 d0                	or     %edx,%eax
  80148f:	d3 ee                	shr    %cl,%esi
  801491:	89 f2                	mov    %esi,%edx
  801493:	f7 74 24 18          	divl   0x18(%esp)
  801497:	89 d6                	mov    %edx,%esi
  801499:	f7 64 24 0c          	mull   0xc(%esp)
  80149d:	89 c5                	mov    %eax,%ebp
  80149f:	89 d1                	mov    %edx,%ecx
  8014a1:	39 d6                	cmp    %edx,%esi
  8014a3:	72 67                	jb     80150c <__umoddi3+0x114>
  8014a5:	74 75                	je     80151c <__umoddi3+0x124>
  8014a7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8014ab:	29 e8                	sub    %ebp,%eax
  8014ad:	19 ce                	sbb    %ecx,%esi
  8014af:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014b3:	d3 e8                	shr    %cl,%eax
  8014b5:	89 f2                	mov    %esi,%edx
  8014b7:	89 f9                	mov    %edi,%ecx
  8014b9:	d3 e2                	shl    %cl,%edx
  8014bb:	09 d0                	or     %edx,%eax
  8014bd:	89 f2                	mov    %esi,%edx
  8014bf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014c3:	d3 ea                	shr    %cl,%edx
  8014c5:	83 c4 20             	add    $0x20,%esp
  8014c8:	5e                   	pop    %esi
  8014c9:	5f                   	pop    %edi
  8014ca:	5d                   	pop    %ebp
  8014cb:	c3                   	ret    
  8014cc:	85 c9                	test   %ecx,%ecx
  8014ce:	75 0b                	jne    8014db <__umoddi3+0xe3>
  8014d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8014d5:	31 d2                	xor    %edx,%edx
  8014d7:	f7 f1                	div    %ecx
  8014d9:	89 c1                	mov    %eax,%ecx
  8014db:	89 f0                	mov    %esi,%eax
  8014dd:	31 d2                	xor    %edx,%edx
  8014df:	f7 f1                	div    %ecx
  8014e1:	89 f8                	mov    %edi,%eax
  8014e3:	e9 3e ff ff ff       	jmp    801426 <__umoddi3+0x2e>
  8014e8:	89 f2                	mov    %esi,%edx
  8014ea:	83 c4 20             	add    $0x20,%esp
  8014ed:	5e                   	pop    %esi
  8014ee:	5f                   	pop    %edi
  8014ef:	5d                   	pop    %ebp
  8014f0:	c3                   	ret    
  8014f1:	8d 76 00             	lea    0x0(%esi),%esi
  8014f4:	39 f5                	cmp    %esi,%ebp
  8014f6:	72 04                	jb     8014fc <__umoddi3+0x104>
  8014f8:	39 f9                	cmp    %edi,%ecx
  8014fa:	77 06                	ja     801502 <__umoddi3+0x10a>
  8014fc:	89 f2                	mov    %esi,%edx
  8014fe:	29 cf                	sub    %ecx,%edi
  801500:	19 ea                	sbb    %ebp,%edx
  801502:	89 f8                	mov    %edi,%eax
  801504:	83 c4 20             	add    $0x20,%esp
  801507:	5e                   	pop    %esi
  801508:	5f                   	pop    %edi
  801509:	5d                   	pop    %ebp
  80150a:	c3                   	ret    
  80150b:	90                   	nop
  80150c:	89 d1                	mov    %edx,%ecx
  80150e:	89 c5                	mov    %eax,%ebp
  801510:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801514:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801518:	eb 8d                	jmp    8014a7 <__umoddi3+0xaf>
  80151a:	66 90                	xchg   %ax,%ax
  80151c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801520:	72 ea                	jb     80150c <__umoddi3+0x114>
  801522:	89 f1                	mov    %esi,%ecx
  801524:	eb 81                	jmp    8014a7 <__umoddi3+0xaf>
