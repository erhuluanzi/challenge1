
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
  800058:	8d 14 80             	lea    (%eax,%eax,4),%edx
  80005b:	8d 04 50             	lea    (%eax,%edx,2),%eax
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
  80010f:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  800116:	00 
  800117:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80011e:	00 
  80011f:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  800126:	e8 b1 02 00 00       	call   8003dc <_panic>

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
  8001a1:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  8001a8:	00 
  8001a9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001b0:	00 
  8001b1:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  8001b8:	e8 1f 02 00 00       	call   8003dc <_panic>

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
  8001f4:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  8001fb:	00 
  8001fc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800203:	00 
  800204:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  80020b:	e8 cc 01 00 00       	call   8003dc <_panic>

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
  800247:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  80024e:	00 
  80024f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800256:	00 
  800257:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  80025e:	e8 79 01 00 00       	call   8003dc <_panic>

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
  80029a:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  8002a1:	00 
  8002a2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002a9:	00 
  8002aa:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  8002b1:	e8 26 01 00 00       	call   8003dc <_panic>

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
  8002ed:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  8002f4:	00 
  8002f5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002fc:	00 
  8002fd:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  800304:	e8 d3 00 00 00       	call   8003dc <_panic>

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
  800362:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  800369:	00 
  80036a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800371:	00 
  800372:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  800379:	e8 5e 00 00 00       	call   8003dc <_panic>

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
  8003b5:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  8003bc:	00 
  8003bd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003c4:	00 
  8003c5:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  8003cc:	e8 0b 00 00 00       	call   8003dc <_panic>
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
  8003d9:	00 00                	add    %al,(%eax)
	...

008003dc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	56                   	push   %esi
  8003e0:	53                   	push   %ebx
  8003e1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003e4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003e7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8003ed:	e8 41 fd ff ff       	call   800133 <sys_getenvid>
  8003f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003fc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800400:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800404:	89 44 24 04          	mov    %eax,0x4(%esp)
  800408:	c7 04 24 38 10 80 00 	movl   $0x801038,(%esp)
  80040f:	e8 c0 00 00 00       	call   8004d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800414:	89 74 24 04          	mov    %esi,0x4(%esp)
  800418:	8b 45 10             	mov    0x10(%ebp),%eax
  80041b:	89 04 24             	mov    %eax,(%esp)
  80041e:	e8 50 00 00 00       	call   800473 <vcprintf>
	cprintf("\n");
  800423:	c7 04 24 5c 10 80 00 	movl   $0x80105c,(%esp)
  80042a:	e8 a5 00 00 00       	call   8004d4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80042f:	cc                   	int3   
  800430:	eb fd                	jmp    80042f <_panic+0x53>
	...

00800434 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	53                   	push   %ebx
  800438:	83 ec 14             	sub    $0x14,%esp
  80043b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80043e:	8b 03                	mov    (%ebx),%eax
  800440:	8b 55 08             	mov    0x8(%ebp),%edx
  800443:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800447:	40                   	inc    %eax
  800448:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80044a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80044f:	75 19                	jne    80046a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800451:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800458:	00 
  800459:	8d 43 08             	lea    0x8(%ebx),%eax
  80045c:	89 04 24             	mov    %eax,(%esp)
  80045f:	e8 40 fc ff ff       	call   8000a4 <sys_cputs>
		b->idx = 0;
  800464:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80046a:	ff 43 04             	incl   0x4(%ebx)
}
  80046d:	83 c4 14             	add    $0x14,%esp
  800470:	5b                   	pop    %ebx
  800471:	5d                   	pop    %ebp
  800472:	c3                   	ret    

00800473 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80047c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800483:	00 00 00 
	b.cnt = 0;
  800486:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80048d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800490:	8b 45 0c             	mov    0xc(%ebp),%eax
  800493:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800497:	8b 45 08             	mov    0x8(%ebp),%eax
  80049a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80049e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a8:	c7 04 24 34 04 80 00 	movl   $0x800434,(%esp)
  8004af:	e8 b4 01 00 00       	call   800668 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004b4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004be:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004c4:	89 04 24             	mov    %eax,(%esp)
  8004c7:	e8 d8 fb ff ff       	call   8000a4 <sys_cputs>

	return b.cnt;
}
  8004cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004d2:	c9                   	leave  
  8004d3:	c3                   	ret    

008004d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e4:	89 04 24             	mov    %eax,(%esp)
  8004e7:	e8 87 ff ff ff       	call   800473 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004ec:	c9                   	leave  
  8004ed:	c3                   	ret    
	...

008004f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	57                   	push   %edi
  8004f4:	56                   	push   %esi
  8004f5:	53                   	push   %ebx
  8004f6:	83 ec 3c             	sub    $0x3c,%esp
  8004f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004fc:	89 d7                	mov    %edx,%edi
  8004fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800501:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800504:	8b 45 0c             	mov    0xc(%ebp),%eax
  800507:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80050d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800510:	85 c0                	test   %eax,%eax
  800512:	75 08                	jne    80051c <printnum+0x2c>
  800514:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800517:	39 45 10             	cmp    %eax,0x10(%ebp)
  80051a:	77 57                	ja     800573 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80051c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800520:	4b                   	dec    %ebx
  800521:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800525:	8b 45 10             	mov    0x10(%ebp),%eax
  800528:	89 44 24 08          	mov    %eax,0x8(%esp)
  80052c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800530:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800534:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80053b:	00 
  80053c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80053f:	89 04 24             	mov    %eax,(%esp)
  800542:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800545:	89 44 24 04          	mov    %eax,0x4(%esp)
  800549:	e8 5a 08 00 00       	call   800da8 <__udivdi3>
  80054e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800552:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800556:	89 04 24             	mov    %eax,(%esp)
  800559:	89 54 24 04          	mov    %edx,0x4(%esp)
  80055d:	89 fa                	mov    %edi,%edx
  80055f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800562:	e8 89 ff ff ff       	call   8004f0 <printnum>
  800567:	eb 0f                	jmp    800578 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800569:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80056d:	89 34 24             	mov    %esi,(%esp)
  800570:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800573:	4b                   	dec    %ebx
  800574:	85 db                	test   %ebx,%ebx
  800576:	7f f1                	jg     800569 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800578:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80057c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800580:	8b 45 10             	mov    0x10(%ebp),%eax
  800583:	89 44 24 08          	mov    %eax,0x8(%esp)
  800587:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80058e:	00 
  80058f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800592:	89 04 24             	mov    %eax,(%esp)
  800595:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800598:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059c:	e8 27 09 00 00       	call   800ec8 <__umoddi3>
  8005a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a5:	0f be 80 5e 10 80 00 	movsbl 0x80105e(%eax),%eax
  8005ac:	89 04 24             	mov    %eax,(%esp)
  8005af:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8005b2:	83 c4 3c             	add    $0x3c,%esp
  8005b5:	5b                   	pop    %ebx
  8005b6:	5e                   	pop    %esi
  8005b7:	5f                   	pop    %edi
  8005b8:	5d                   	pop    %ebp
  8005b9:	c3                   	ret    

008005ba <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005ba:	55                   	push   %ebp
  8005bb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005bd:	83 fa 01             	cmp    $0x1,%edx
  8005c0:	7e 0e                	jle    8005d0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005c2:	8b 10                	mov    (%eax),%edx
  8005c4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005c7:	89 08                	mov    %ecx,(%eax)
  8005c9:	8b 02                	mov    (%edx),%eax
  8005cb:	8b 52 04             	mov    0x4(%edx),%edx
  8005ce:	eb 22                	jmp    8005f2 <getuint+0x38>
	else if (lflag)
  8005d0:	85 d2                	test   %edx,%edx
  8005d2:	74 10                	je     8005e4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005d4:	8b 10                	mov    (%eax),%edx
  8005d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005d9:	89 08                	mov    %ecx,(%eax)
  8005db:	8b 02                	mov    (%edx),%eax
  8005dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e2:	eb 0e                	jmp    8005f2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005e4:	8b 10                	mov    (%eax),%edx
  8005e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005e9:	89 08                	mov    %ecx,(%eax)
  8005eb:	8b 02                	mov    (%edx),%eax
  8005ed:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005f2:	5d                   	pop    %ebp
  8005f3:	c3                   	ret    

008005f4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8005f4:	55                   	push   %ebp
  8005f5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005f7:	83 fa 01             	cmp    $0x1,%edx
  8005fa:	7e 0e                	jle    80060a <getint+0x16>
		return va_arg(*ap, long long);
  8005fc:	8b 10                	mov    (%eax),%edx
  8005fe:	8d 4a 08             	lea    0x8(%edx),%ecx
  800601:	89 08                	mov    %ecx,(%eax)
  800603:	8b 02                	mov    (%edx),%eax
  800605:	8b 52 04             	mov    0x4(%edx),%edx
  800608:	eb 1a                	jmp    800624 <getint+0x30>
	else if (lflag)
  80060a:	85 d2                	test   %edx,%edx
  80060c:	74 0c                	je     80061a <getint+0x26>
		return va_arg(*ap, long);
  80060e:	8b 10                	mov    (%eax),%edx
  800610:	8d 4a 04             	lea    0x4(%edx),%ecx
  800613:	89 08                	mov    %ecx,(%eax)
  800615:	8b 02                	mov    (%edx),%eax
  800617:	99                   	cltd   
  800618:	eb 0a                	jmp    800624 <getint+0x30>
	else
		return va_arg(*ap, int);
  80061a:	8b 10                	mov    (%eax),%edx
  80061c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80061f:	89 08                	mov    %ecx,(%eax)
  800621:	8b 02                	mov    (%edx),%eax
  800623:	99                   	cltd   
}
  800624:	5d                   	pop    %ebp
  800625:	c3                   	ret    

00800626 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800626:	55                   	push   %ebp
  800627:	89 e5                	mov    %esp,%ebp
  800629:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80062c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80062f:	8b 10                	mov    (%eax),%edx
  800631:	3b 50 04             	cmp    0x4(%eax),%edx
  800634:	73 08                	jae    80063e <sprintputch+0x18>
		*b->buf++ = ch;
  800636:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800639:	88 0a                	mov    %cl,(%edx)
  80063b:	42                   	inc    %edx
  80063c:	89 10                	mov    %edx,(%eax)
}
  80063e:	5d                   	pop    %ebp
  80063f:	c3                   	ret    

00800640 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800640:	55                   	push   %ebp
  800641:	89 e5                	mov    %esp,%ebp
  800643:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800646:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800649:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80064d:	8b 45 10             	mov    0x10(%ebp),%eax
  800650:	89 44 24 08          	mov    %eax,0x8(%esp)
  800654:	8b 45 0c             	mov    0xc(%ebp),%eax
  800657:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065b:	8b 45 08             	mov    0x8(%ebp),%eax
  80065e:	89 04 24             	mov    %eax,(%esp)
  800661:	e8 02 00 00 00       	call   800668 <vprintfmt>
	va_end(ap);
}
  800666:	c9                   	leave  
  800667:	c3                   	ret    

00800668 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800668:	55                   	push   %ebp
  800669:	89 e5                	mov    %esp,%ebp
  80066b:	57                   	push   %edi
  80066c:	56                   	push   %esi
  80066d:	53                   	push   %ebx
  80066e:	83 ec 4c             	sub    $0x4c,%esp
  800671:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800674:	8b 75 10             	mov    0x10(%ebp),%esi
  800677:	eb 12                	jmp    80068b <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800679:	85 c0                	test   %eax,%eax
  80067b:	0f 84 40 03 00 00    	je     8009c1 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800681:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800685:	89 04 24             	mov    %eax,(%esp)
  800688:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80068b:	0f b6 06             	movzbl (%esi),%eax
  80068e:	46                   	inc    %esi
  80068f:	83 f8 25             	cmp    $0x25,%eax
  800692:	75 e5                	jne    800679 <vprintfmt+0x11>
  800694:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800698:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80069f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006a4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b0:	eb 26                	jmp    8006d8 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b2:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006b5:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8006b9:	eb 1d                	jmp    8006d8 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006be:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8006c2:	eb 14                	jmp    8006d8 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8006c7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8006ce:	eb 08                	jmp    8006d8 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8006d0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006d3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d8:	0f b6 06             	movzbl (%esi),%eax
  8006db:	8d 4e 01             	lea    0x1(%esi),%ecx
  8006de:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006e1:	8a 0e                	mov    (%esi),%cl
  8006e3:	83 e9 23             	sub    $0x23,%ecx
  8006e6:	80 f9 55             	cmp    $0x55,%cl
  8006e9:	0f 87 b6 02 00 00    	ja     8009a5 <vprintfmt+0x33d>
  8006ef:	0f b6 c9             	movzbl %cl,%ecx
  8006f2:	ff 24 8d 20 11 80 00 	jmp    *0x801120(,%ecx,4)
  8006f9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006fc:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800701:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800704:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  800708:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80070b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80070e:	83 f9 09             	cmp    $0x9,%ecx
  800711:	77 2a                	ja     80073d <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800713:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800714:	eb eb                	jmp    800701 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	8d 48 04             	lea    0x4(%eax),%ecx
  80071c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80071f:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800721:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800724:	eb 17                	jmp    80073d <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800726:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80072a:	78 98                	js     8006c4 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80072f:	eb a7                	jmp    8006d8 <vprintfmt+0x70>
  800731:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800734:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80073b:	eb 9b                	jmp    8006d8 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80073d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800741:	79 95                	jns    8006d8 <vprintfmt+0x70>
  800743:	eb 8b                	jmp    8006d0 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800745:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800746:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800749:	eb 8d                	jmp    8006d8 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8d 50 04             	lea    0x4(%eax),%edx
  800751:	89 55 14             	mov    %edx,0x14(%ebp)
  800754:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800758:	8b 00                	mov    (%eax),%eax
  80075a:	89 04 24             	mov    %eax,(%esp)
  80075d:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800760:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800763:	e9 23 ff ff ff       	jmp    80068b <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8d 50 04             	lea    0x4(%eax),%edx
  80076e:	89 55 14             	mov    %edx,0x14(%ebp)
  800771:	8b 00                	mov    (%eax),%eax
  800773:	85 c0                	test   %eax,%eax
  800775:	79 02                	jns    800779 <vprintfmt+0x111>
  800777:	f7 d8                	neg    %eax
  800779:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80077b:	83 f8 09             	cmp    $0x9,%eax
  80077e:	7f 0b                	jg     80078b <vprintfmt+0x123>
  800780:	8b 04 85 80 12 80 00 	mov    0x801280(,%eax,4),%eax
  800787:	85 c0                	test   %eax,%eax
  800789:	75 23                	jne    8007ae <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80078b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80078f:	c7 44 24 08 76 10 80 	movl   $0x801076,0x8(%esp)
  800796:	00 
  800797:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	89 04 24             	mov    %eax,(%esp)
  8007a1:	e8 9a fe ff ff       	call   800640 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007a9:	e9 dd fe ff ff       	jmp    80068b <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8007ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b2:	c7 44 24 08 7f 10 80 	movl   $0x80107f,0x8(%esp)
  8007b9:	00 
  8007ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007be:	8b 55 08             	mov    0x8(%ebp),%edx
  8007c1:	89 14 24             	mov    %edx,(%esp)
  8007c4:	e8 77 fe ff ff       	call   800640 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007cc:	e9 ba fe ff ff       	jmp    80068b <vprintfmt+0x23>
  8007d1:	89 f9                	mov    %edi,%ecx
  8007d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dc:	8d 50 04             	lea    0x4(%eax),%edx
  8007df:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e2:	8b 30                	mov    (%eax),%esi
  8007e4:	85 f6                	test   %esi,%esi
  8007e6:	75 05                	jne    8007ed <vprintfmt+0x185>
				p = "(null)";
  8007e8:	be 6f 10 80 00       	mov    $0x80106f,%esi
			if (width > 0 && padc != '-')
  8007ed:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007f1:	0f 8e 84 00 00 00    	jle    80087b <vprintfmt+0x213>
  8007f7:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007fb:	74 7e                	je     80087b <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007fd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800801:	89 34 24             	mov    %esi,(%esp)
  800804:	e8 5d 02 00 00       	call   800a66 <strnlen>
  800809:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80080c:	29 c2                	sub    %eax,%edx
  80080e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800811:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800815:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800818:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80081b:	89 de                	mov    %ebx,%esi
  80081d:	89 d3                	mov    %edx,%ebx
  80081f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800821:	eb 0b                	jmp    80082e <vprintfmt+0x1c6>
					putch(padc, putdat);
  800823:	89 74 24 04          	mov    %esi,0x4(%esp)
  800827:	89 3c 24             	mov    %edi,(%esp)
  80082a:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80082d:	4b                   	dec    %ebx
  80082e:	85 db                	test   %ebx,%ebx
  800830:	7f f1                	jg     800823 <vprintfmt+0x1bb>
  800832:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800835:	89 f3                	mov    %esi,%ebx
  800837:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80083a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80083d:	85 c0                	test   %eax,%eax
  80083f:	79 05                	jns    800846 <vprintfmt+0x1de>
  800841:	b8 00 00 00 00       	mov    $0x0,%eax
  800846:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800849:	29 c2                	sub    %eax,%edx
  80084b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80084e:	eb 2b                	jmp    80087b <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800850:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800854:	74 18                	je     80086e <vprintfmt+0x206>
  800856:	8d 50 e0             	lea    -0x20(%eax),%edx
  800859:	83 fa 5e             	cmp    $0x5e,%edx
  80085c:	76 10                	jbe    80086e <vprintfmt+0x206>
					putch('?', putdat);
  80085e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800862:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800869:	ff 55 08             	call   *0x8(%ebp)
  80086c:	eb 0a                	jmp    800878 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80086e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800872:	89 04 24             	mov    %eax,(%esp)
  800875:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800878:	ff 4d e4             	decl   -0x1c(%ebp)
  80087b:	0f be 06             	movsbl (%esi),%eax
  80087e:	46                   	inc    %esi
  80087f:	85 c0                	test   %eax,%eax
  800881:	74 21                	je     8008a4 <vprintfmt+0x23c>
  800883:	85 ff                	test   %edi,%edi
  800885:	78 c9                	js     800850 <vprintfmt+0x1e8>
  800887:	4f                   	dec    %edi
  800888:	79 c6                	jns    800850 <vprintfmt+0x1e8>
  80088a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088d:	89 de                	mov    %ebx,%esi
  80088f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800892:	eb 18                	jmp    8008ac <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800894:	89 74 24 04          	mov    %esi,0x4(%esp)
  800898:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80089f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008a1:	4b                   	dec    %ebx
  8008a2:	eb 08                	jmp    8008ac <vprintfmt+0x244>
  8008a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a7:	89 de                	mov    %ebx,%esi
  8008a9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008ac:	85 db                	test   %ebx,%ebx
  8008ae:	7f e4                	jg     800894 <vprintfmt+0x22c>
  8008b0:	89 7d 08             	mov    %edi,0x8(%ebp)
  8008b3:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008b8:	e9 ce fd ff ff       	jmp    80068b <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c0:	e8 2f fd ff ff       	call   8005f4 <getint>
  8008c5:	89 c6                	mov    %eax,%esi
  8008c7:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8008c9:	85 d2                	test   %edx,%edx
  8008cb:	78 07                	js     8008d4 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008cd:	be 0a 00 00 00       	mov    $0xa,%esi
  8008d2:	eb 7e                	jmp    800952 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008df:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008e2:	89 f0                	mov    %esi,%eax
  8008e4:	89 fa                	mov    %edi,%edx
  8008e6:	f7 d8                	neg    %eax
  8008e8:	83 d2 00             	adc    $0x0,%edx
  8008eb:	f7 da                	neg    %edx
			}
			base = 10;
  8008ed:	be 0a 00 00 00       	mov    $0xa,%esi
  8008f2:	eb 5e                	jmp    800952 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8008f7:	e8 be fc ff ff       	call   8005ba <getuint>
			base = 10;
  8008fc:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800901:	eb 4f                	jmp    800952 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800903:	8d 45 14             	lea    0x14(%ebp),%eax
  800906:	e8 af fc ff ff       	call   8005ba <getuint>
			base = 8;
  80090b:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800910:	eb 40                	jmp    800952 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  800912:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800916:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80091d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800920:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800924:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80092b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80092e:	8b 45 14             	mov    0x14(%ebp),%eax
  800931:	8d 50 04             	lea    0x4(%eax),%edx
  800934:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800937:	8b 00                	mov    (%eax),%eax
  800939:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80093e:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800943:	eb 0d                	jmp    800952 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800945:	8d 45 14             	lea    0x14(%ebp),%eax
  800948:	e8 6d fc ff ff       	call   8005ba <getuint>
			base = 16;
  80094d:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800952:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800956:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80095a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80095d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800961:	89 74 24 08          	mov    %esi,0x8(%esp)
  800965:	89 04 24             	mov    %eax,(%esp)
  800968:	89 54 24 04          	mov    %edx,0x4(%esp)
  80096c:	89 da                	mov    %ebx,%edx
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	e8 7a fb ff ff       	call   8004f0 <printnum>
			break;
  800976:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800979:	e9 0d fd ff ff       	jmp    80068b <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  80097e:	8d 45 14             	lea    0x14(%ebp),%eax
  800981:	e8 6e fc ff ff       	call   8005f4 <getint>
  800986:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80098b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  80098e:	e9 f8 fc ff ff       	jmp    80068b <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800993:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800997:	89 04 24             	mov    %eax,(%esp)
  80099a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80099d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009a0:	e9 e6 fc ff ff       	jmp    80068b <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009b0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009b3:	eb 01                	jmp    8009b6 <vprintfmt+0x34e>
  8009b5:	4e                   	dec    %esi
  8009b6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009ba:	75 f9                	jne    8009b5 <vprintfmt+0x34d>
  8009bc:	e9 ca fc ff ff       	jmp    80068b <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009c1:	83 c4 4c             	add    $0x4c,%esp
  8009c4:	5b                   	pop    %ebx
  8009c5:	5e                   	pop    %esi
  8009c6:	5f                   	pop    %edi
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	83 ec 28             	sub    $0x28,%esp
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009d8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009dc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009e6:	85 c0                	test   %eax,%eax
  8009e8:	74 30                	je     800a1a <vsnprintf+0x51>
  8009ea:	85 d2                	test   %edx,%edx
  8009ec:	7e 33                	jle    800a21 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009fc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a03:	c7 04 24 26 06 80 00 	movl   $0x800626,(%esp)
  800a0a:	e8 59 fc ff ff       	call   800668 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a12:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a18:	eb 0c                	jmp    800a26 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a1a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a1f:	eb 05                	jmp    800a26 <vsnprintf+0x5d>
  800a21:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a26:	c9                   	leave  
  800a27:	c3                   	ret    

00800a28 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a2e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a31:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a35:	8b 45 10             	mov    0x10(%ebp),%eax
  800a38:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	89 04 24             	mov    %eax,(%esp)
  800a49:	e8 7b ff ff ff       	call   8009c9 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a4e:	c9                   	leave  
  800a4f:	c3                   	ret    

00800a50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a56:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5b:	eb 01                	jmp    800a5e <strlen+0xe>
		n++;
  800a5d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a5e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a62:	75 f9                	jne    800a5d <strlen+0xd>
		n++;
	return n;
}
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a6c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a74:	eb 01                	jmp    800a77 <strnlen+0x11>
		n++;
  800a76:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a77:	39 d0                	cmp    %edx,%eax
  800a79:	74 06                	je     800a81 <strnlen+0x1b>
  800a7b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a7f:	75 f5                	jne    800a76 <strnlen+0x10>
		n++;
	return n;
}
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	53                   	push   %ebx
  800a87:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a92:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a95:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a98:	42                   	inc    %edx
  800a99:	84 c9                	test   %cl,%cl
  800a9b:	75 f5                	jne    800a92 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	53                   	push   %ebx
  800aa4:	83 ec 08             	sub    $0x8,%esp
  800aa7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aaa:	89 1c 24             	mov    %ebx,(%esp)
  800aad:	e8 9e ff ff ff       	call   800a50 <strlen>
	strcpy(dst + len, src);
  800ab2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ab9:	01 d8                	add    %ebx,%eax
  800abb:	89 04 24             	mov    %eax,(%esp)
  800abe:	e8 c0 ff ff ff       	call   800a83 <strcpy>
	return dst;
}
  800ac3:	89 d8                	mov    %ebx,%eax
  800ac5:	83 c4 08             	add    $0x8,%esp
  800ac8:	5b                   	pop    %ebx
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	56                   	push   %esi
  800acf:	53                   	push   %ebx
  800ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ad9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ade:	eb 0c                	jmp    800aec <strncpy+0x21>
		*dst++ = *src;
  800ae0:	8a 1a                	mov    (%edx),%bl
  800ae2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ae5:	80 3a 01             	cmpb   $0x1,(%edx)
  800ae8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aeb:	41                   	inc    %ecx
  800aec:	39 f1                	cmp    %esi,%ecx
  800aee:	75 f0                	jne    800ae0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	8b 75 08             	mov    0x8(%ebp),%esi
  800afc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aff:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b02:	85 d2                	test   %edx,%edx
  800b04:	75 0a                	jne    800b10 <strlcpy+0x1c>
  800b06:	89 f0                	mov    %esi,%eax
  800b08:	eb 1a                	jmp    800b24 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b0a:	88 18                	mov    %bl,(%eax)
  800b0c:	40                   	inc    %eax
  800b0d:	41                   	inc    %ecx
  800b0e:	eb 02                	jmp    800b12 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b10:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b12:	4a                   	dec    %edx
  800b13:	74 0a                	je     800b1f <strlcpy+0x2b>
  800b15:	8a 19                	mov    (%ecx),%bl
  800b17:	84 db                	test   %bl,%bl
  800b19:	75 ef                	jne    800b0a <strlcpy+0x16>
  800b1b:	89 c2                	mov    %eax,%edx
  800b1d:	eb 02                	jmp    800b21 <strlcpy+0x2d>
  800b1f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b21:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b24:	29 f0                	sub    %esi,%eax
}
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b30:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b33:	eb 02                	jmp    800b37 <strcmp+0xd>
		p++, q++;
  800b35:	41                   	inc    %ecx
  800b36:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b37:	8a 01                	mov    (%ecx),%al
  800b39:	84 c0                	test   %al,%al
  800b3b:	74 04                	je     800b41 <strcmp+0x17>
  800b3d:	3a 02                	cmp    (%edx),%al
  800b3f:	74 f4                	je     800b35 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b41:	0f b6 c0             	movzbl %al,%eax
  800b44:	0f b6 12             	movzbl (%edx),%edx
  800b47:	29 d0                	sub    %edx,%eax
}
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	53                   	push   %ebx
  800b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b55:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b58:	eb 03                	jmp    800b5d <strncmp+0x12>
		n--, p++, q++;
  800b5a:	4a                   	dec    %edx
  800b5b:	40                   	inc    %eax
  800b5c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b5d:	85 d2                	test   %edx,%edx
  800b5f:	74 14                	je     800b75 <strncmp+0x2a>
  800b61:	8a 18                	mov    (%eax),%bl
  800b63:	84 db                	test   %bl,%bl
  800b65:	74 04                	je     800b6b <strncmp+0x20>
  800b67:	3a 19                	cmp    (%ecx),%bl
  800b69:	74 ef                	je     800b5a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b6b:	0f b6 00             	movzbl (%eax),%eax
  800b6e:	0f b6 11             	movzbl (%ecx),%edx
  800b71:	29 d0                	sub    %edx,%eax
  800b73:	eb 05                	jmp    800b7a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b75:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b7a:	5b                   	pop    %ebx
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	8b 45 08             	mov    0x8(%ebp),%eax
  800b83:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b86:	eb 05                	jmp    800b8d <strchr+0x10>
		if (*s == c)
  800b88:	38 ca                	cmp    %cl,%dl
  800b8a:	74 0c                	je     800b98 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b8c:	40                   	inc    %eax
  800b8d:	8a 10                	mov    (%eax),%dl
  800b8f:	84 d2                	test   %dl,%dl
  800b91:	75 f5                	jne    800b88 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800ba3:	eb 05                	jmp    800baa <strfind+0x10>
		if (*s == c)
  800ba5:	38 ca                	cmp    %cl,%dl
  800ba7:	74 07                	je     800bb0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ba9:	40                   	inc    %eax
  800baa:	8a 10                	mov    (%eax),%dl
  800bac:	84 d2                	test   %dl,%dl
  800bae:	75 f5                	jne    800ba5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bc1:	85 c9                	test   %ecx,%ecx
  800bc3:	74 30                	je     800bf5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bc5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bcb:	75 25                	jne    800bf2 <memset+0x40>
  800bcd:	f6 c1 03             	test   $0x3,%cl
  800bd0:	75 20                	jne    800bf2 <memset+0x40>
		c &= 0xFF;
  800bd2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bd5:	89 d3                	mov    %edx,%ebx
  800bd7:	c1 e3 08             	shl    $0x8,%ebx
  800bda:	89 d6                	mov    %edx,%esi
  800bdc:	c1 e6 18             	shl    $0x18,%esi
  800bdf:	89 d0                	mov    %edx,%eax
  800be1:	c1 e0 10             	shl    $0x10,%eax
  800be4:	09 f0                	or     %esi,%eax
  800be6:	09 d0                	or     %edx,%eax
  800be8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bea:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bed:	fc                   	cld    
  800bee:	f3 ab                	rep stos %eax,%es:(%edi)
  800bf0:	eb 03                	jmp    800bf5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bf2:	fc                   	cld    
  800bf3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bf5:	89 f8                	mov    %edi,%eax
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
  800c04:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c07:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c0a:	39 c6                	cmp    %eax,%esi
  800c0c:	73 34                	jae    800c42 <memmove+0x46>
  800c0e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c11:	39 d0                	cmp    %edx,%eax
  800c13:	73 2d                	jae    800c42 <memmove+0x46>
		s += n;
		d += n;
  800c15:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c18:	f6 c2 03             	test   $0x3,%dl
  800c1b:	75 1b                	jne    800c38 <memmove+0x3c>
  800c1d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c23:	75 13                	jne    800c38 <memmove+0x3c>
  800c25:	f6 c1 03             	test   $0x3,%cl
  800c28:	75 0e                	jne    800c38 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c2a:	83 ef 04             	sub    $0x4,%edi
  800c2d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c30:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c33:	fd                   	std    
  800c34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c36:	eb 07                	jmp    800c3f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c38:	4f                   	dec    %edi
  800c39:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c3c:	fd                   	std    
  800c3d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c3f:	fc                   	cld    
  800c40:	eb 20                	jmp    800c62 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c42:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c48:	75 13                	jne    800c5d <memmove+0x61>
  800c4a:	a8 03                	test   $0x3,%al
  800c4c:	75 0f                	jne    800c5d <memmove+0x61>
  800c4e:	f6 c1 03             	test   $0x3,%cl
  800c51:	75 0a                	jne    800c5d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c53:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c56:	89 c7                	mov    %eax,%edi
  800c58:	fc                   	cld    
  800c59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c5b:	eb 05                	jmp    800c62 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c5d:	89 c7                	mov    %eax,%edi
  800c5f:	fc                   	cld    
  800c60:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c6f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c76:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7d:	89 04 24             	mov    %eax,(%esp)
  800c80:	e8 77 ff ff ff       	call   800bfc <memmove>
}
  800c85:	c9                   	leave  
  800c86:	c3                   	ret    

00800c87 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c90:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c96:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9b:	eb 16                	jmp    800cb3 <memcmp+0x2c>
		if (*s1 != *s2)
  800c9d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ca0:	42                   	inc    %edx
  800ca1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800ca5:	38 c8                	cmp    %cl,%al
  800ca7:	74 0a                	je     800cb3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ca9:	0f b6 c0             	movzbl %al,%eax
  800cac:	0f b6 c9             	movzbl %cl,%ecx
  800caf:	29 c8                	sub    %ecx,%eax
  800cb1:	eb 09                	jmp    800cbc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb3:	39 da                	cmp    %ebx,%edx
  800cb5:	75 e6                	jne    800c9d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cca:	89 c2                	mov    %eax,%edx
  800ccc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ccf:	eb 05                	jmp    800cd6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cd1:	38 08                	cmp    %cl,(%eax)
  800cd3:	74 05                	je     800cda <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cd5:	40                   	inc    %eax
  800cd6:	39 d0                	cmp    %edx,%eax
  800cd8:	72 f7                	jb     800cd1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
  800ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ce8:	eb 01                	jmp    800ceb <strtol+0xf>
		s++;
  800cea:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ceb:	8a 02                	mov    (%edx),%al
  800ced:	3c 20                	cmp    $0x20,%al
  800cef:	74 f9                	je     800cea <strtol+0xe>
  800cf1:	3c 09                	cmp    $0x9,%al
  800cf3:	74 f5                	je     800cea <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cf5:	3c 2b                	cmp    $0x2b,%al
  800cf7:	75 08                	jne    800d01 <strtol+0x25>
		s++;
  800cf9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cfa:	bf 00 00 00 00       	mov    $0x0,%edi
  800cff:	eb 13                	jmp    800d14 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d01:	3c 2d                	cmp    $0x2d,%al
  800d03:	75 0a                	jne    800d0f <strtol+0x33>
		s++, neg = 1;
  800d05:	8d 52 01             	lea    0x1(%edx),%edx
  800d08:	bf 01 00 00 00       	mov    $0x1,%edi
  800d0d:	eb 05                	jmp    800d14 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d0f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d14:	85 db                	test   %ebx,%ebx
  800d16:	74 05                	je     800d1d <strtol+0x41>
  800d18:	83 fb 10             	cmp    $0x10,%ebx
  800d1b:	75 28                	jne    800d45 <strtol+0x69>
  800d1d:	8a 02                	mov    (%edx),%al
  800d1f:	3c 30                	cmp    $0x30,%al
  800d21:	75 10                	jne    800d33 <strtol+0x57>
  800d23:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d27:	75 0a                	jne    800d33 <strtol+0x57>
		s += 2, base = 16;
  800d29:	83 c2 02             	add    $0x2,%edx
  800d2c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d31:	eb 12                	jmp    800d45 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d33:	85 db                	test   %ebx,%ebx
  800d35:	75 0e                	jne    800d45 <strtol+0x69>
  800d37:	3c 30                	cmp    $0x30,%al
  800d39:	75 05                	jne    800d40 <strtol+0x64>
		s++, base = 8;
  800d3b:	42                   	inc    %edx
  800d3c:	b3 08                	mov    $0x8,%bl
  800d3e:	eb 05                	jmp    800d45 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d40:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d45:	b8 00 00 00 00       	mov    $0x0,%eax
  800d4a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d4c:	8a 0a                	mov    (%edx),%cl
  800d4e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d51:	80 fb 09             	cmp    $0x9,%bl
  800d54:	77 08                	ja     800d5e <strtol+0x82>
			dig = *s - '0';
  800d56:	0f be c9             	movsbl %cl,%ecx
  800d59:	83 e9 30             	sub    $0x30,%ecx
  800d5c:	eb 1e                	jmp    800d7c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d5e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d61:	80 fb 19             	cmp    $0x19,%bl
  800d64:	77 08                	ja     800d6e <strtol+0x92>
			dig = *s - 'a' + 10;
  800d66:	0f be c9             	movsbl %cl,%ecx
  800d69:	83 e9 57             	sub    $0x57,%ecx
  800d6c:	eb 0e                	jmp    800d7c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d6e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d71:	80 fb 19             	cmp    $0x19,%bl
  800d74:	77 12                	ja     800d88 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d76:	0f be c9             	movsbl %cl,%ecx
  800d79:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d7c:	39 f1                	cmp    %esi,%ecx
  800d7e:	7d 0c                	jge    800d8c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d80:	42                   	inc    %edx
  800d81:	0f af c6             	imul   %esi,%eax
  800d84:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d86:	eb c4                	jmp    800d4c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d88:	89 c1                	mov    %eax,%ecx
  800d8a:	eb 02                	jmp    800d8e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d8c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d8e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d92:	74 05                	je     800d99 <strtol+0xbd>
		*endptr = (char *) s;
  800d94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d97:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d99:	85 ff                	test   %edi,%edi
  800d9b:	74 04                	je     800da1 <strtol+0xc5>
  800d9d:	89 c8                	mov    %ecx,%eax
  800d9f:	f7 d8                	neg    %eax
}
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    
	...

00800da8 <__udivdi3>:
  800da8:	55                   	push   %ebp
  800da9:	57                   	push   %edi
  800daa:	56                   	push   %esi
  800dab:	83 ec 10             	sub    $0x10,%esp
  800dae:	8b 74 24 20          	mov    0x20(%esp),%esi
  800db2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800db6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dba:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800dbe:	89 cd                	mov    %ecx,%ebp
  800dc0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	75 2c                	jne    800df4 <__udivdi3+0x4c>
  800dc8:	39 f9                	cmp    %edi,%ecx
  800dca:	77 68                	ja     800e34 <__udivdi3+0x8c>
  800dcc:	85 c9                	test   %ecx,%ecx
  800dce:	75 0b                	jne    800ddb <__udivdi3+0x33>
  800dd0:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd5:	31 d2                	xor    %edx,%edx
  800dd7:	f7 f1                	div    %ecx
  800dd9:	89 c1                	mov    %eax,%ecx
  800ddb:	31 d2                	xor    %edx,%edx
  800ddd:	89 f8                	mov    %edi,%eax
  800ddf:	f7 f1                	div    %ecx
  800de1:	89 c7                	mov    %eax,%edi
  800de3:	89 f0                	mov    %esi,%eax
  800de5:	f7 f1                	div    %ecx
  800de7:	89 c6                	mov    %eax,%esi
  800de9:	89 f0                	mov    %esi,%eax
  800deb:	89 fa                	mov    %edi,%edx
  800ded:	83 c4 10             	add    $0x10,%esp
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    
  800df4:	39 f8                	cmp    %edi,%eax
  800df6:	77 2c                	ja     800e24 <__udivdi3+0x7c>
  800df8:	0f bd f0             	bsr    %eax,%esi
  800dfb:	83 f6 1f             	xor    $0x1f,%esi
  800dfe:	75 4c                	jne    800e4c <__udivdi3+0xa4>
  800e00:	39 f8                	cmp    %edi,%eax
  800e02:	bf 00 00 00 00       	mov    $0x0,%edi
  800e07:	72 0a                	jb     800e13 <__udivdi3+0x6b>
  800e09:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e0d:	0f 87 ad 00 00 00    	ja     800ec0 <__udivdi3+0x118>
  800e13:	be 01 00 00 00       	mov    $0x1,%esi
  800e18:	89 f0                	mov    %esi,%eax
  800e1a:	89 fa                	mov    %edi,%edx
  800e1c:	83 c4 10             	add    $0x10,%esp
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    
  800e23:	90                   	nop
  800e24:	31 ff                	xor    %edi,%edi
  800e26:	31 f6                	xor    %esi,%esi
  800e28:	89 f0                	mov    %esi,%eax
  800e2a:	89 fa                	mov    %edi,%edx
  800e2c:	83 c4 10             	add    $0x10,%esp
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    
  800e33:	90                   	nop
  800e34:	89 fa                	mov    %edi,%edx
  800e36:	89 f0                	mov    %esi,%eax
  800e38:	f7 f1                	div    %ecx
  800e3a:	89 c6                	mov    %eax,%esi
  800e3c:	31 ff                	xor    %edi,%edi
  800e3e:	89 f0                	mov    %esi,%eax
  800e40:	89 fa                	mov    %edi,%edx
  800e42:	83 c4 10             	add    $0x10,%esp
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    
  800e49:	8d 76 00             	lea    0x0(%esi),%esi
  800e4c:	89 f1                	mov    %esi,%ecx
  800e4e:	d3 e0                	shl    %cl,%eax
  800e50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e54:	b8 20 00 00 00       	mov    $0x20,%eax
  800e59:	29 f0                	sub    %esi,%eax
  800e5b:	89 ea                	mov    %ebp,%edx
  800e5d:	88 c1                	mov    %al,%cl
  800e5f:	d3 ea                	shr    %cl,%edx
  800e61:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e65:	09 ca                	or     %ecx,%edx
  800e67:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e6b:	89 f1                	mov    %esi,%ecx
  800e6d:	d3 e5                	shl    %cl,%ebp
  800e6f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800e73:	89 fd                	mov    %edi,%ebp
  800e75:	88 c1                	mov    %al,%cl
  800e77:	d3 ed                	shr    %cl,%ebp
  800e79:	89 fa                	mov    %edi,%edx
  800e7b:	89 f1                	mov    %esi,%ecx
  800e7d:	d3 e2                	shl    %cl,%edx
  800e7f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e83:	88 c1                	mov    %al,%cl
  800e85:	d3 ef                	shr    %cl,%edi
  800e87:	09 d7                	or     %edx,%edi
  800e89:	89 f8                	mov    %edi,%eax
  800e8b:	89 ea                	mov    %ebp,%edx
  800e8d:	f7 74 24 08          	divl   0x8(%esp)
  800e91:	89 d1                	mov    %edx,%ecx
  800e93:	89 c7                	mov    %eax,%edi
  800e95:	f7 64 24 0c          	mull   0xc(%esp)
  800e99:	39 d1                	cmp    %edx,%ecx
  800e9b:	72 17                	jb     800eb4 <__udivdi3+0x10c>
  800e9d:	74 09                	je     800ea8 <__udivdi3+0x100>
  800e9f:	89 fe                	mov    %edi,%esi
  800ea1:	31 ff                	xor    %edi,%edi
  800ea3:	e9 41 ff ff ff       	jmp    800de9 <__udivdi3+0x41>
  800ea8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800eac:	89 f1                	mov    %esi,%ecx
  800eae:	d3 e2                	shl    %cl,%edx
  800eb0:	39 c2                	cmp    %eax,%edx
  800eb2:	73 eb                	jae    800e9f <__udivdi3+0xf7>
  800eb4:	8d 77 ff             	lea    -0x1(%edi),%esi
  800eb7:	31 ff                	xor    %edi,%edi
  800eb9:	e9 2b ff ff ff       	jmp    800de9 <__udivdi3+0x41>
  800ebe:	66 90                	xchg   %ax,%ax
  800ec0:	31 f6                	xor    %esi,%esi
  800ec2:	e9 22 ff ff ff       	jmp    800de9 <__udivdi3+0x41>
	...

00800ec8 <__umoddi3>:
  800ec8:	55                   	push   %ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	83 ec 20             	sub    $0x20,%esp
  800ece:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ed2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800ed6:	89 44 24 14          	mov    %eax,0x14(%esp)
  800eda:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ede:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ee2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800ee6:	89 c7                	mov    %eax,%edi
  800ee8:	89 f2                	mov    %esi,%edx
  800eea:	85 ed                	test   %ebp,%ebp
  800eec:	75 16                	jne    800f04 <__umoddi3+0x3c>
  800eee:	39 f1                	cmp    %esi,%ecx
  800ef0:	0f 86 a6 00 00 00    	jbe    800f9c <__umoddi3+0xd4>
  800ef6:	f7 f1                	div    %ecx
  800ef8:	89 d0                	mov    %edx,%eax
  800efa:	31 d2                	xor    %edx,%edx
  800efc:	83 c4 20             	add    $0x20,%esp
  800eff:	5e                   	pop    %esi
  800f00:	5f                   	pop    %edi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    
  800f03:	90                   	nop
  800f04:	39 f5                	cmp    %esi,%ebp
  800f06:	0f 87 ac 00 00 00    	ja     800fb8 <__umoddi3+0xf0>
  800f0c:	0f bd c5             	bsr    %ebp,%eax
  800f0f:	83 f0 1f             	xor    $0x1f,%eax
  800f12:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f16:	0f 84 a8 00 00 00    	je     800fc4 <__umoddi3+0xfc>
  800f1c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f20:	d3 e5                	shl    %cl,%ebp
  800f22:	bf 20 00 00 00       	mov    $0x20,%edi
  800f27:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800f2b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f2f:	89 f9                	mov    %edi,%ecx
  800f31:	d3 e8                	shr    %cl,%eax
  800f33:	09 e8                	or     %ebp,%eax
  800f35:	89 44 24 18          	mov    %eax,0x18(%esp)
  800f39:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f3d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f41:	d3 e0                	shl    %cl,%eax
  800f43:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f47:	89 f2                	mov    %esi,%edx
  800f49:	d3 e2                	shl    %cl,%edx
  800f4b:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f4f:	d3 e0                	shl    %cl,%eax
  800f51:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800f55:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f59:	89 f9                	mov    %edi,%ecx
  800f5b:	d3 e8                	shr    %cl,%eax
  800f5d:	09 d0                	or     %edx,%eax
  800f5f:	d3 ee                	shr    %cl,%esi
  800f61:	89 f2                	mov    %esi,%edx
  800f63:	f7 74 24 18          	divl   0x18(%esp)
  800f67:	89 d6                	mov    %edx,%esi
  800f69:	f7 64 24 0c          	mull   0xc(%esp)
  800f6d:	89 c5                	mov    %eax,%ebp
  800f6f:	89 d1                	mov    %edx,%ecx
  800f71:	39 d6                	cmp    %edx,%esi
  800f73:	72 67                	jb     800fdc <__umoddi3+0x114>
  800f75:	74 75                	je     800fec <__umoddi3+0x124>
  800f77:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f7b:	29 e8                	sub    %ebp,%eax
  800f7d:	19 ce                	sbb    %ecx,%esi
  800f7f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f83:	d3 e8                	shr    %cl,%eax
  800f85:	89 f2                	mov    %esi,%edx
  800f87:	89 f9                	mov    %edi,%ecx
  800f89:	d3 e2                	shl    %cl,%edx
  800f8b:	09 d0                	or     %edx,%eax
  800f8d:	89 f2                	mov    %esi,%edx
  800f8f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f93:	d3 ea                	shr    %cl,%edx
  800f95:	83 c4 20             	add    $0x20,%esp
  800f98:	5e                   	pop    %esi
  800f99:	5f                   	pop    %edi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    
  800f9c:	85 c9                	test   %ecx,%ecx
  800f9e:	75 0b                	jne    800fab <__umoddi3+0xe3>
  800fa0:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa5:	31 d2                	xor    %edx,%edx
  800fa7:	f7 f1                	div    %ecx
  800fa9:	89 c1                	mov    %eax,%ecx
  800fab:	89 f0                	mov    %esi,%eax
  800fad:	31 d2                	xor    %edx,%edx
  800faf:	f7 f1                	div    %ecx
  800fb1:	89 f8                	mov    %edi,%eax
  800fb3:	e9 3e ff ff ff       	jmp    800ef6 <__umoddi3+0x2e>
  800fb8:	89 f2                	mov    %esi,%edx
  800fba:	83 c4 20             	add    $0x20,%esp
  800fbd:	5e                   	pop    %esi
  800fbe:	5f                   	pop    %edi
  800fbf:	5d                   	pop    %ebp
  800fc0:	c3                   	ret    
  800fc1:	8d 76 00             	lea    0x0(%esi),%esi
  800fc4:	39 f5                	cmp    %esi,%ebp
  800fc6:	72 04                	jb     800fcc <__umoddi3+0x104>
  800fc8:	39 f9                	cmp    %edi,%ecx
  800fca:	77 06                	ja     800fd2 <__umoddi3+0x10a>
  800fcc:	89 f2                	mov    %esi,%edx
  800fce:	29 cf                	sub    %ecx,%edi
  800fd0:	19 ea                	sbb    %ebp,%edx
  800fd2:	89 f8                	mov    %edi,%eax
  800fd4:	83 c4 20             	add    $0x20,%esp
  800fd7:	5e                   	pop    %esi
  800fd8:	5f                   	pop    %edi
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    
  800fdb:	90                   	nop
  800fdc:	89 d1                	mov    %edx,%ecx
  800fde:	89 c5                	mov    %eax,%ebp
  800fe0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fe4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fe8:	eb 8d                	jmp    800f77 <__umoddi3+0xaf>
  800fea:	66 90                	xchg   %ax,%ax
  800fec:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800ff0:	72 ea                	jb     800fdc <__umoddi3+0x114>
  800ff2:	89 f1                	mov    %esi,%ecx
  800ff4:	eb 81                	jmp    800f77 <__umoddi3+0xaf>
