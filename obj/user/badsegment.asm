
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
  80005b:	8d 14 90             	lea    (%eax,%edx,4),%edx
  80005e:	8d 04 50             	lea    (%eax,%edx,2),%eax
  800061:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  800068:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006d:	85 f6                	test   %esi,%esi
  80006f:	7e 07                	jle    800078 <libmain+0x38>
		binaryname = argv[0];
  800071:	8b 03                	mov    (%ebx),%eax
  800073:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800078:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80007c:	89 34 24             	mov    %esi,(%esp)
  80007f:	e8 b0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800084:	e8 07 00 00 00       	call   800090 <exit>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

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
  80010f:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  800116:	00 
  800117:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80011e:	00 
  80011f:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  800126:	e8 5d 02 00 00       	call   800388 <_panic>

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
  8001a1:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8001a8:	00 
  8001a9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001b0:	00 
  8001b1:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  8001b8:	e8 cb 01 00 00       	call   800388 <_panic>

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
  8001f4:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8001fb:	00 
  8001fc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800203:	00 
  800204:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  80020b:	e8 78 01 00 00       	call   800388 <_panic>

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
  800247:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  80024e:	00 
  80024f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800256:	00 
  800257:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  80025e:	e8 25 01 00 00       	call   800388 <_panic>

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
  80029a:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8002a1:	00 
  8002a2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002a9:	00 
  8002aa:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  8002b1:	e8 d2 00 00 00       	call   800388 <_panic>

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
  8002ed:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8002f4:	00 
  8002f5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002fc:	00 
  8002fd:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  800304:	e8 7f 00 00 00       	call   800388 <_panic>

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
  800362:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  800369:	00 
  80036a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800371:	00 
  800372:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  800379:	e8 0a 00 00 00       	call   800388 <_panic>

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
	...

00800388 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	56                   	push   %esi
  80038c:	53                   	push   %ebx
  80038d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800390:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800393:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800399:	e8 95 fd ff ff       	call   800133 <sys_getenvid>
  80039e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b4:	c7 04 24 f8 0f 80 00 	movl   $0x800ff8,(%esp)
  8003bb:	e8 c0 00 00 00       	call   800480 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c7:	89 04 24             	mov    %eax,(%esp)
  8003ca:	e8 50 00 00 00       	call   80041f <vcprintf>
	cprintf("\n");
  8003cf:	c7 04 24 1c 10 80 00 	movl   $0x80101c,(%esp)
  8003d6:	e8 a5 00 00 00       	call   800480 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003db:	cc                   	int3   
  8003dc:	eb fd                	jmp    8003db <_panic+0x53>
	...

008003e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	53                   	push   %ebx
  8003e4:	83 ec 14             	sub    $0x14,%esp
  8003e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ea:	8b 03                	mov    (%ebx),%eax
  8003ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ef:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003f3:	40                   	inc    %eax
  8003f4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003fb:	75 19                	jne    800416 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8003fd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800404:	00 
  800405:	8d 43 08             	lea    0x8(%ebx),%eax
  800408:	89 04 24             	mov    %eax,(%esp)
  80040b:	e8 94 fc ff ff       	call   8000a4 <sys_cputs>
		b->idx = 0;
  800410:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800416:	ff 43 04             	incl   0x4(%ebx)
}
  800419:	83 c4 14             	add    $0x14,%esp
  80041c:	5b                   	pop    %ebx
  80041d:	5d                   	pop    %ebp
  80041e:	c3                   	ret    

0080041f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800428:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80042f:	00 00 00 
	b.cnt = 0;
  800432:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800439:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80043c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80043f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800443:	8b 45 08             	mov    0x8(%ebp),%eax
  800446:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800450:	89 44 24 04          	mov    %eax,0x4(%esp)
  800454:	c7 04 24 e0 03 80 00 	movl   $0x8003e0,(%esp)
  80045b:	e8 b4 01 00 00       	call   800614 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800460:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800466:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800470:	89 04 24             	mov    %eax,(%esp)
  800473:	e8 2c fc ff ff       	call   8000a4 <sys_cputs>

	return b.cnt;
}
  800478:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800486:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800489:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048d:	8b 45 08             	mov    0x8(%ebp),%eax
  800490:	89 04 24             	mov    %eax,(%esp)
  800493:	e8 87 ff ff ff       	call   80041f <vcprintf>
	va_end(ap);

	return cnt;
}
  800498:	c9                   	leave  
  800499:	c3                   	ret    
	...

0080049c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
  80049f:	57                   	push   %edi
  8004a0:	56                   	push   %esi
  8004a1:	53                   	push   %ebx
  8004a2:	83 ec 3c             	sub    $0x3c,%esp
  8004a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a8:	89 d7                	mov    %edx,%edi
  8004aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ad:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004b9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004bc:	85 c0                	test   %eax,%eax
  8004be:	75 08                	jne    8004c8 <printnum+0x2c>
  8004c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004c3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004c6:	77 57                	ja     80051f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004c8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004cc:	4b                   	dec    %ebx
  8004cd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004dc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004e7:	00 
  8004e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004eb:	89 04 24             	mov    %eax,(%esp)
  8004ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f5:	e8 5a 08 00 00       	call   800d54 <__udivdi3>
  8004fa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004fe:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800502:	89 04 24             	mov    %eax,(%esp)
  800505:	89 54 24 04          	mov    %edx,0x4(%esp)
  800509:	89 fa                	mov    %edi,%edx
  80050b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80050e:	e8 89 ff ff ff       	call   80049c <printnum>
  800513:	eb 0f                	jmp    800524 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800515:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800519:	89 34 24             	mov    %esi,(%esp)
  80051c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80051f:	4b                   	dec    %ebx
  800520:	85 db                	test   %ebx,%ebx
  800522:	7f f1                	jg     800515 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800524:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800528:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80052c:	8b 45 10             	mov    0x10(%ebp),%eax
  80052f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800533:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80053a:	00 
  80053b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80053e:	89 04 24             	mov    %eax,(%esp)
  800541:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800544:	89 44 24 04          	mov    %eax,0x4(%esp)
  800548:	e8 27 09 00 00       	call   800e74 <__umoddi3>
  80054d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800551:	0f be 80 1e 10 80 00 	movsbl 0x80101e(%eax),%eax
  800558:	89 04 24             	mov    %eax,(%esp)
  80055b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80055e:	83 c4 3c             	add    $0x3c,%esp
  800561:	5b                   	pop    %ebx
  800562:	5e                   	pop    %esi
  800563:	5f                   	pop    %edi
  800564:	5d                   	pop    %ebp
  800565:	c3                   	ret    

00800566 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800566:	55                   	push   %ebp
  800567:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800569:	83 fa 01             	cmp    $0x1,%edx
  80056c:	7e 0e                	jle    80057c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80056e:	8b 10                	mov    (%eax),%edx
  800570:	8d 4a 08             	lea    0x8(%edx),%ecx
  800573:	89 08                	mov    %ecx,(%eax)
  800575:	8b 02                	mov    (%edx),%eax
  800577:	8b 52 04             	mov    0x4(%edx),%edx
  80057a:	eb 22                	jmp    80059e <getuint+0x38>
	else if (lflag)
  80057c:	85 d2                	test   %edx,%edx
  80057e:	74 10                	je     800590 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800580:	8b 10                	mov    (%eax),%edx
  800582:	8d 4a 04             	lea    0x4(%edx),%ecx
  800585:	89 08                	mov    %ecx,(%eax)
  800587:	8b 02                	mov    (%edx),%eax
  800589:	ba 00 00 00 00       	mov    $0x0,%edx
  80058e:	eb 0e                	jmp    80059e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800590:	8b 10                	mov    (%eax),%edx
  800592:	8d 4a 04             	lea    0x4(%edx),%ecx
  800595:	89 08                	mov    %ecx,(%eax)
  800597:	8b 02                	mov    (%edx),%eax
  800599:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80059e:	5d                   	pop    %ebp
  80059f:	c3                   	ret    

008005a0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8005a0:	55                   	push   %ebp
  8005a1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005a3:	83 fa 01             	cmp    $0x1,%edx
  8005a6:	7e 0e                	jle    8005b6 <getint+0x16>
		return va_arg(*ap, long long);
  8005a8:	8b 10                	mov    (%eax),%edx
  8005aa:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005ad:	89 08                	mov    %ecx,(%eax)
  8005af:	8b 02                	mov    (%edx),%eax
  8005b1:	8b 52 04             	mov    0x4(%edx),%edx
  8005b4:	eb 1a                	jmp    8005d0 <getint+0x30>
	else if (lflag)
  8005b6:	85 d2                	test   %edx,%edx
  8005b8:	74 0c                	je     8005c6 <getint+0x26>
		return va_arg(*ap, long);
  8005ba:	8b 10                	mov    (%eax),%edx
  8005bc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005bf:	89 08                	mov    %ecx,(%eax)
  8005c1:	8b 02                	mov    (%edx),%eax
  8005c3:	99                   	cltd   
  8005c4:	eb 0a                	jmp    8005d0 <getint+0x30>
	else
		return va_arg(*ap, int);
  8005c6:	8b 10                	mov    (%eax),%edx
  8005c8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005cb:	89 08                	mov    %ecx,(%eax)
  8005cd:	8b 02                	mov    (%edx),%eax
  8005cf:	99                   	cltd   
}
  8005d0:	5d                   	pop    %ebp
  8005d1:	c3                   	ret    

008005d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005d2:	55                   	push   %ebp
  8005d3:	89 e5                	mov    %esp,%ebp
  8005d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005d8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005db:	8b 10                	mov    (%eax),%edx
  8005dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8005e0:	73 08                	jae    8005ea <sprintputch+0x18>
		*b->buf++ = ch;
  8005e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005e5:	88 0a                	mov    %cl,(%edx)
  8005e7:	42                   	inc    %edx
  8005e8:	89 10                	mov    %edx,(%eax)
}
  8005ea:	5d                   	pop    %ebp
  8005eb:	c3                   	ret    

008005ec <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005ec:	55                   	push   %ebp
  8005ed:	89 e5                	mov    %esp,%ebp
  8005ef:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005f2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8005fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800600:	8b 45 0c             	mov    0xc(%ebp),%eax
  800603:	89 44 24 04          	mov    %eax,0x4(%esp)
  800607:	8b 45 08             	mov    0x8(%ebp),%eax
  80060a:	89 04 24             	mov    %eax,(%esp)
  80060d:	e8 02 00 00 00       	call   800614 <vprintfmt>
	va_end(ap);
}
  800612:	c9                   	leave  
  800613:	c3                   	ret    

00800614 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800614:	55                   	push   %ebp
  800615:	89 e5                	mov    %esp,%ebp
  800617:	57                   	push   %edi
  800618:	56                   	push   %esi
  800619:	53                   	push   %ebx
  80061a:	83 ec 4c             	sub    $0x4c,%esp
  80061d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800620:	8b 75 10             	mov    0x10(%ebp),%esi
  800623:	eb 12                	jmp    800637 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800625:	85 c0                	test   %eax,%eax
  800627:	0f 84 40 03 00 00    	je     80096d <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  80062d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800631:	89 04 24             	mov    %eax,(%esp)
  800634:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800637:	0f b6 06             	movzbl (%esi),%eax
  80063a:	46                   	inc    %esi
  80063b:	83 f8 25             	cmp    $0x25,%eax
  80063e:	75 e5                	jne    800625 <vprintfmt+0x11>
  800640:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800644:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80064b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800650:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800657:	ba 00 00 00 00       	mov    $0x0,%edx
  80065c:	eb 26                	jmp    800684 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065e:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800661:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800665:	eb 1d                	jmp    800684 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800667:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80066a:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80066e:	eb 14                	jmp    800684 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800670:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800673:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80067a:	eb 08                	jmp    800684 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80067c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80067f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800684:	0f b6 06             	movzbl (%esi),%eax
  800687:	8d 4e 01             	lea    0x1(%esi),%ecx
  80068a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80068d:	8a 0e                	mov    (%esi),%cl
  80068f:	83 e9 23             	sub    $0x23,%ecx
  800692:	80 f9 55             	cmp    $0x55,%cl
  800695:	0f 87 b6 02 00 00    	ja     800951 <vprintfmt+0x33d>
  80069b:	0f b6 c9             	movzbl %cl,%ecx
  80069e:	ff 24 8d e0 10 80 00 	jmp    *0x8010e0(,%ecx,4)
  8006a5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006a8:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006ad:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  8006b0:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  8006b4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006b7:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8006ba:	83 f9 09             	cmp    $0x9,%ecx
  8006bd:	77 2a                	ja     8006e9 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006bf:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006c0:	eb eb                	jmp    8006ad <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8d 48 04             	lea    0x4(%eax),%ecx
  8006c8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006cb:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006d0:	eb 17                	jmp    8006e9 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006d6:	78 98                	js     800670 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006db:	eb a7                	jmp    800684 <vprintfmt+0x70>
  8006dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006e0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006e7:	eb 9b                	jmp    800684 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006e9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006ed:	79 95                	jns    800684 <vprintfmt+0x70>
  8006ef:	eb 8b                	jmp    80067c <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006f1:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006f5:	eb 8d                	jmp    800684 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 50 04             	lea    0x4(%eax),%edx
  8006fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800700:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800704:	8b 00                	mov    (%eax),%eax
  800706:	89 04 24             	mov    %eax,(%esp)
  800709:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80070f:	e9 23 ff ff ff       	jmp    800637 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8d 50 04             	lea    0x4(%eax),%edx
  80071a:	89 55 14             	mov    %edx,0x14(%ebp)
  80071d:	8b 00                	mov    (%eax),%eax
  80071f:	85 c0                	test   %eax,%eax
  800721:	79 02                	jns    800725 <vprintfmt+0x111>
  800723:	f7 d8                	neg    %eax
  800725:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800727:	83 f8 09             	cmp    $0x9,%eax
  80072a:	7f 0b                	jg     800737 <vprintfmt+0x123>
  80072c:	8b 04 85 40 12 80 00 	mov    0x801240(,%eax,4),%eax
  800733:	85 c0                	test   %eax,%eax
  800735:	75 23                	jne    80075a <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800737:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80073b:	c7 44 24 08 36 10 80 	movl   $0x801036,0x8(%esp)
  800742:	00 
  800743:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800747:	8b 45 08             	mov    0x8(%ebp),%eax
  80074a:	89 04 24             	mov    %eax,(%esp)
  80074d:	e8 9a fe ff ff       	call   8005ec <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800752:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800755:	e9 dd fe ff ff       	jmp    800637 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80075a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075e:	c7 44 24 08 3f 10 80 	movl   $0x80103f,0x8(%esp)
  800765:	00 
  800766:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076a:	8b 55 08             	mov    0x8(%ebp),%edx
  80076d:	89 14 24             	mov    %edx,(%esp)
  800770:	e8 77 fe ff ff       	call   8005ec <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800775:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800778:	e9 ba fe ff ff       	jmp    800637 <vprintfmt+0x23>
  80077d:	89 f9                	mov    %edi,%ecx
  80077f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800782:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8d 50 04             	lea    0x4(%eax),%edx
  80078b:	89 55 14             	mov    %edx,0x14(%ebp)
  80078e:	8b 30                	mov    (%eax),%esi
  800790:	85 f6                	test   %esi,%esi
  800792:	75 05                	jne    800799 <vprintfmt+0x185>
				p = "(null)";
  800794:	be 2f 10 80 00       	mov    $0x80102f,%esi
			if (width > 0 && padc != '-')
  800799:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80079d:	0f 8e 84 00 00 00    	jle    800827 <vprintfmt+0x213>
  8007a3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007a7:	74 7e                	je     800827 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007ad:	89 34 24             	mov    %esi,(%esp)
  8007b0:	e8 5d 02 00 00       	call   800a12 <strnlen>
  8007b5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007b8:	29 c2                	sub    %eax,%edx
  8007ba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8007bd:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8007c1:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007c4:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007c7:	89 de                	mov    %ebx,%esi
  8007c9:	89 d3                	mov    %edx,%ebx
  8007cb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007cd:	eb 0b                	jmp    8007da <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d3:	89 3c 24             	mov    %edi,(%esp)
  8007d6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d9:	4b                   	dec    %ebx
  8007da:	85 db                	test   %ebx,%ebx
  8007dc:	7f f1                	jg     8007cf <vprintfmt+0x1bb>
  8007de:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007e1:	89 f3                	mov    %esi,%ebx
  8007e3:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007e9:	85 c0                	test   %eax,%eax
  8007eb:	79 05                	jns    8007f2 <vprintfmt+0x1de>
  8007ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007f5:	29 c2                	sub    %eax,%edx
  8007f7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007fa:	eb 2b                	jmp    800827 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007fc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800800:	74 18                	je     80081a <vprintfmt+0x206>
  800802:	8d 50 e0             	lea    -0x20(%eax),%edx
  800805:	83 fa 5e             	cmp    $0x5e,%edx
  800808:	76 10                	jbe    80081a <vprintfmt+0x206>
					putch('?', putdat);
  80080a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80080e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800815:	ff 55 08             	call   *0x8(%ebp)
  800818:	eb 0a                	jmp    800824 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80081a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80081e:	89 04 24             	mov    %eax,(%esp)
  800821:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800824:	ff 4d e4             	decl   -0x1c(%ebp)
  800827:	0f be 06             	movsbl (%esi),%eax
  80082a:	46                   	inc    %esi
  80082b:	85 c0                	test   %eax,%eax
  80082d:	74 21                	je     800850 <vprintfmt+0x23c>
  80082f:	85 ff                	test   %edi,%edi
  800831:	78 c9                	js     8007fc <vprintfmt+0x1e8>
  800833:	4f                   	dec    %edi
  800834:	79 c6                	jns    8007fc <vprintfmt+0x1e8>
  800836:	8b 7d 08             	mov    0x8(%ebp),%edi
  800839:	89 de                	mov    %ebx,%esi
  80083b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80083e:	eb 18                	jmp    800858 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800840:	89 74 24 04          	mov    %esi,0x4(%esp)
  800844:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80084b:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80084d:	4b                   	dec    %ebx
  80084e:	eb 08                	jmp    800858 <vprintfmt+0x244>
  800850:	8b 7d 08             	mov    0x8(%ebp),%edi
  800853:	89 de                	mov    %ebx,%esi
  800855:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800858:	85 db                	test   %ebx,%ebx
  80085a:	7f e4                	jg     800840 <vprintfmt+0x22c>
  80085c:	89 7d 08             	mov    %edi,0x8(%ebp)
  80085f:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800861:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800864:	e9 ce fd ff ff       	jmp    800637 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800869:	8d 45 14             	lea    0x14(%ebp),%eax
  80086c:	e8 2f fd ff ff       	call   8005a0 <getint>
  800871:	89 c6                	mov    %eax,%esi
  800873:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800875:	85 d2                	test   %edx,%edx
  800877:	78 07                	js     800880 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800879:	be 0a 00 00 00       	mov    $0xa,%esi
  80087e:	eb 7e                	jmp    8008fe <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800880:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800884:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80088b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80088e:	89 f0                	mov    %esi,%eax
  800890:	89 fa                	mov    %edi,%edx
  800892:	f7 d8                	neg    %eax
  800894:	83 d2 00             	adc    $0x0,%edx
  800897:	f7 da                	neg    %edx
			}
			base = 10;
  800899:	be 0a 00 00 00       	mov    $0xa,%esi
  80089e:	eb 5e                	jmp    8008fe <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a3:	e8 be fc ff ff       	call   800566 <getuint>
			base = 10;
  8008a8:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8008ad:	eb 4f                	jmp    8008fe <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8008af:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b2:	e8 af fc ff ff       	call   800566 <getuint>
			base = 8;
  8008b7:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8008bc:	eb 40                	jmp    8008fe <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  8008be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008c9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008d7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008da:	8b 45 14             	mov    0x14(%ebp),%eax
  8008dd:	8d 50 04             	lea    0x4(%eax),%edx
  8008e0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008e3:	8b 00                	mov    (%eax),%eax
  8008e5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008ea:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8008ef:	eb 0d                	jmp    8008fe <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8008f4:	e8 6d fc ff ff       	call   800566 <getuint>
			base = 16;
  8008f9:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008fe:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800902:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800906:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800909:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80090d:	89 74 24 08          	mov    %esi,0x8(%esp)
  800911:	89 04 24             	mov    %eax,(%esp)
  800914:	89 54 24 04          	mov    %edx,0x4(%esp)
  800918:	89 da                	mov    %ebx,%edx
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	e8 7a fb ff ff       	call   80049c <printnum>
			break;
  800922:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800925:	e9 0d fd ff ff       	jmp    800637 <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  80092a:	8d 45 14             	lea    0x14(%ebp),%eax
  80092d:	e8 6e fc ff ff       	call   8005a0 <getint>
  800932:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800937:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  80093a:	e9 f8 fc ff ff       	jmp    800637 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80093f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800943:	89 04 24             	mov    %eax,(%esp)
  800946:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800949:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80094c:	e9 e6 fc ff ff       	jmp    800637 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800951:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800955:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80095c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80095f:	eb 01                	jmp    800962 <vprintfmt+0x34e>
  800961:	4e                   	dec    %esi
  800962:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800966:	75 f9                	jne    800961 <vprintfmt+0x34d>
  800968:	e9 ca fc ff ff       	jmp    800637 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80096d:	83 c4 4c             	add    $0x4c,%esp
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5f                   	pop    %edi
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	83 ec 28             	sub    $0x28,%esp
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800981:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800984:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800988:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80098b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800992:	85 c0                	test   %eax,%eax
  800994:	74 30                	je     8009c6 <vsnprintf+0x51>
  800996:	85 d2                	test   %edx,%edx
  800998:	7e 33                	jle    8009cd <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80099a:	8b 45 14             	mov    0x14(%ebp),%eax
  80099d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009af:	c7 04 24 d2 05 80 00 	movl   $0x8005d2,(%esp)
  8009b6:	e8 59 fc ff ff       	call   800614 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009be:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c4:	eb 0c                	jmp    8009d2 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009cb:	eb 05                	jmp    8009d2 <vsnprintf+0x5d>
  8009cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009d2:	c9                   	leave  
  8009d3:	c3                   	ret    

008009d4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009da:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	89 04 24             	mov    %eax,(%esp)
  8009f5:	e8 7b ff ff ff       	call   800975 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009fa:	c9                   	leave  
  8009fb:	c3                   	ret    

008009fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a02:	b8 00 00 00 00       	mov    $0x0,%eax
  800a07:	eb 01                	jmp    800a0a <strlen+0xe>
		n++;
  800a09:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a0a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a0e:	75 f9                	jne    800a09 <strlen+0xd>
		n++;
	return n;
}
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a18:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a20:	eb 01                	jmp    800a23 <strnlen+0x11>
		n++;
  800a22:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a23:	39 d0                	cmp    %edx,%eax
  800a25:	74 06                	je     800a2d <strnlen+0x1b>
  800a27:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a2b:	75 f5                	jne    800a22 <strnlen+0x10>
		n++;
	return n;
}
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	53                   	push   %ebx
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a39:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a41:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a44:	42                   	inc    %edx
  800a45:	84 c9                	test   %cl,%cl
  800a47:	75 f5                	jne    800a3e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a49:	5b                   	pop    %ebx
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	53                   	push   %ebx
  800a50:	83 ec 08             	sub    $0x8,%esp
  800a53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a56:	89 1c 24             	mov    %ebx,(%esp)
  800a59:	e8 9e ff ff ff       	call   8009fc <strlen>
	strcpy(dst + len, src);
  800a5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a61:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a65:	01 d8                	add    %ebx,%eax
  800a67:	89 04 24             	mov    %eax,(%esp)
  800a6a:	e8 c0 ff ff ff       	call   800a2f <strcpy>
	return dst;
}
  800a6f:	89 d8                	mov    %ebx,%eax
  800a71:	83 c4 08             	add    $0x8,%esp
  800a74:	5b                   	pop    %ebx
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	56                   	push   %esi
  800a7b:	53                   	push   %ebx
  800a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a82:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8a:	eb 0c                	jmp    800a98 <strncpy+0x21>
		*dst++ = *src;
  800a8c:	8a 1a                	mov    (%edx),%bl
  800a8e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a91:	80 3a 01             	cmpb   $0x1,(%edx)
  800a94:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a97:	41                   	inc    %ecx
  800a98:	39 f1                	cmp    %esi,%ecx
  800a9a:	75 f0                	jne    800a8c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aab:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aae:	85 d2                	test   %edx,%edx
  800ab0:	75 0a                	jne    800abc <strlcpy+0x1c>
  800ab2:	89 f0                	mov    %esi,%eax
  800ab4:	eb 1a                	jmp    800ad0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ab6:	88 18                	mov    %bl,(%eax)
  800ab8:	40                   	inc    %eax
  800ab9:	41                   	inc    %ecx
  800aba:	eb 02                	jmp    800abe <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800abc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800abe:	4a                   	dec    %edx
  800abf:	74 0a                	je     800acb <strlcpy+0x2b>
  800ac1:	8a 19                	mov    (%ecx),%bl
  800ac3:	84 db                	test   %bl,%bl
  800ac5:	75 ef                	jne    800ab6 <strlcpy+0x16>
  800ac7:	89 c2                	mov    %eax,%edx
  800ac9:	eb 02                	jmp    800acd <strlcpy+0x2d>
  800acb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800acd:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ad0:	29 f0                	sub    %esi,%eax
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800adc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800adf:	eb 02                	jmp    800ae3 <strcmp+0xd>
		p++, q++;
  800ae1:	41                   	inc    %ecx
  800ae2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ae3:	8a 01                	mov    (%ecx),%al
  800ae5:	84 c0                	test   %al,%al
  800ae7:	74 04                	je     800aed <strcmp+0x17>
  800ae9:	3a 02                	cmp    (%edx),%al
  800aeb:	74 f4                	je     800ae1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aed:	0f b6 c0             	movzbl %al,%eax
  800af0:	0f b6 12             	movzbl (%edx),%edx
  800af3:	29 d0                	sub    %edx,%eax
}
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	53                   	push   %ebx
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
  800afe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b01:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b04:	eb 03                	jmp    800b09 <strncmp+0x12>
		n--, p++, q++;
  800b06:	4a                   	dec    %edx
  800b07:	40                   	inc    %eax
  800b08:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b09:	85 d2                	test   %edx,%edx
  800b0b:	74 14                	je     800b21 <strncmp+0x2a>
  800b0d:	8a 18                	mov    (%eax),%bl
  800b0f:	84 db                	test   %bl,%bl
  800b11:	74 04                	je     800b17 <strncmp+0x20>
  800b13:	3a 19                	cmp    (%ecx),%bl
  800b15:	74 ef                	je     800b06 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b17:	0f b6 00             	movzbl (%eax),%eax
  800b1a:	0f b6 11             	movzbl (%ecx),%edx
  800b1d:	29 d0                	sub    %edx,%eax
  800b1f:	eb 05                	jmp    800b26 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b21:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b26:	5b                   	pop    %ebx
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b32:	eb 05                	jmp    800b39 <strchr+0x10>
		if (*s == c)
  800b34:	38 ca                	cmp    %cl,%dl
  800b36:	74 0c                	je     800b44 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b38:	40                   	inc    %eax
  800b39:	8a 10                	mov    (%eax),%dl
  800b3b:	84 d2                	test   %dl,%dl
  800b3d:	75 f5                	jne    800b34 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b4f:	eb 05                	jmp    800b56 <strfind+0x10>
		if (*s == c)
  800b51:	38 ca                	cmp    %cl,%dl
  800b53:	74 07                	je     800b5c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b55:	40                   	inc    %eax
  800b56:	8a 10                	mov    (%eax),%dl
  800b58:	84 d2                	test   %dl,%dl
  800b5a:	75 f5                	jne    800b51 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b6d:	85 c9                	test   %ecx,%ecx
  800b6f:	74 30                	je     800ba1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b71:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b77:	75 25                	jne    800b9e <memset+0x40>
  800b79:	f6 c1 03             	test   $0x3,%cl
  800b7c:	75 20                	jne    800b9e <memset+0x40>
		c &= 0xFF;
  800b7e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b81:	89 d3                	mov    %edx,%ebx
  800b83:	c1 e3 08             	shl    $0x8,%ebx
  800b86:	89 d6                	mov    %edx,%esi
  800b88:	c1 e6 18             	shl    $0x18,%esi
  800b8b:	89 d0                	mov    %edx,%eax
  800b8d:	c1 e0 10             	shl    $0x10,%eax
  800b90:	09 f0                	or     %esi,%eax
  800b92:	09 d0                	or     %edx,%eax
  800b94:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b96:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b99:	fc                   	cld    
  800b9a:	f3 ab                	rep stos %eax,%es:(%edi)
  800b9c:	eb 03                	jmp    800ba1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b9e:	fc                   	cld    
  800b9f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ba1:	89 f8                	mov    %edi,%eax
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bb6:	39 c6                	cmp    %eax,%esi
  800bb8:	73 34                	jae    800bee <memmove+0x46>
  800bba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bbd:	39 d0                	cmp    %edx,%eax
  800bbf:	73 2d                	jae    800bee <memmove+0x46>
		s += n;
		d += n;
  800bc1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc4:	f6 c2 03             	test   $0x3,%dl
  800bc7:	75 1b                	jne    800be4 <memmove+0x3c>
  800bc9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bcf:	75 13                	jne    800be4 <memmove+0x3c>
  800bd1:	f6 c1 03             	test   $0x3,%cl
  800bd4:	75 0e                	jne    800be4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bd6:	83 ef 04             	sub    $0x4,%edi
  800bd9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bdc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bdf:	fd                   	std    
  800be0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800be2:	eb 07                	jmp    800beb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800be4:	4f                   	dec    %edi
  800be5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800be8:	fd                   	std    
  800be9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800beb:	fc                   	cld    
  800bec:	eb 20                	jmp    800c0e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bee:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bf4:	75 13                	jne    800c09 <memmove+0x61>
  800bf6:	a8 03                	test   $0x3,%al
  800bf8:	75 0f                	jne    800c09 <memmove+0x61>
  800bfa:	f6 c1 03             	test   $0x3,%cl
  800bfd:	75 0a                	jne    800c09 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bff:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c02:	89 c7                	mov    %eax,%edi
  800c04:	fc                   	cld    
  800c05:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c07:	eb 05                	jmp    800c0e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c09:	89 c7                	mov    %eax,%edi
  800c0b:	fc                   	cld    
  800c0c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c18:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c22:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c26:	8b 45 08             	mov    0x8(%ebp),%eax
  800c29:	89 04 24             	mov    %eax,(%esp)
  800c2c:	e8 77 ff ff ff       	call   800ba8 <memmove>
}
  800c31:	c9                   	leave  
  800c32:	c3                   	ret    

00800c33 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c42:	ba 00 00 00 00       	mov    $0x0,%edx
  800c47:	eb 16                	jmp    800c5f <memcmp+0x2c>
		if (*s1 != *s2)
  800c49:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c4c:	42                   	inc    %edx
  800c4d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c51:	38 c8                	cmp    %cl,%al
  800c53:	74 0a                	je     800c5f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c55:	0f b6 c0             	movzbl %al,%eax
  800c58:	0f b6 c9             	movzbl %cl,%ecx
  800c5b:	29 c8                	sub    %ecx,%eax
  800c5d:	eb 09                	jmp    800c68 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c5f:	39 da                	cmp    %ebx,%edx
  800c61:	75 e6                	jne    800c49 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	8b 45 08             	mov    0x8(%ebp),%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c76:	89 c2                	mov    %eax,%edx
  800c78:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c7b:	eb 05                	jmp    800c82 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c7d:	38 08                	cmp    %cl,(%eax)
  800c7f:	74 05                	je     800c86 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c81:	40                   	inc    %eax
  800c82:	39 d0                	cmp    %edx,%eax
  800c84:	72 f7                	jb     800c7d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
  800c8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c91:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c94:	eb 01                	jmp    800c97 <strtol+0xf>
		s++;
  800c96:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c97:	8a 02                	mov    (%edx),%al
  800c99:	3c 20                	cmp    $0x20,%al
  800c9b:	74 f9                	je     800c96 <strtol+0xe>
  800c9d:	3c 09                	cmp    $0x9,%al
  800c9f:	74 f5                	je     800c96 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ca1:	3c 2b                	cmp    $0x2b,%al
  800ca3:	75 08                	jne    800cad <strtol+0x25>
		s++;
  800ca5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ca6:	bf 00 00 00 00       	mov    $0x0,%edi
  800cab:	eb 13                	jmp    800cc0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cad:	3c 2d                	cmp    $0x2d,%al
  800caf:	75 0a                	jne    800cbb <strtol+0x33>
		s++, neg = 1;
  800cb1:	8d 52 01             	lea    0x1(%edx),%edx
  800cb4:	bf 01 00 00 00       	mov    $0x1,%edi
  800cb9:	eb 05                	jmp    800cc0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cbb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc0:	85 db                	test   %ebx,%ebx
  800cc2:	74 05                	je     800cc9 <strtol+0x41>
  800cc4:	83 fb 10             	cmp    $0x10,%ebx
  800cc7:	75 28                	jne    800cf1 <strtol+0x69>
  800cc9:	8a 02                	mov    (%edx),%al
  800ccb:	3c 30                	cmp    $0x30,%al
  800ccd:	75 10                	jne    800cdf <strtol+0x57>
  800ccf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cd3:	75 0a                	jne    800cdf <strtol+0x57>
		s += 2, base = 16;
  800cd5:	83 c2 02             	add    $0x2,%edx
  800cd8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cdd:	eb 12                	jmp    800cf1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800cdf:	85 db                	test   %ebx,%ebx
  800ce1:	75 0e                	jne    800cf1 <strtol+0x69>
  800ce3:	3c 30                	cmp    $0x30,%al
  800ce5:	75 05                	jne    800cec <strtol+0x64>
		s++, base = 8;
  800ce7:	42                   	inc    %edx
  800ce8:	b3 08                	mov    $0x8,%bl
  800cea:	eb 05                	jmp    800cf1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800cec:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cf8:	8a 0a                	mov    (%edx),%cl
  800cfa:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cfd:	80 fb 09             	cmp    $0x9,%bl
  800d00:	77 08                	ja     800d0a <strtol+0x82>
			dig = *s - '0';
  800d02:	0f be c9             	movsbl %cl,%ecx
  800d05:	83 e9 30             	sub    $0x30,%ecx
  800d08:	eb 1e                	jmp    800d28 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d0a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d0d:	80 fb 19             	cmp    $0x19,%bl
  800d10:	77 08                	ja     800d1a <strtol+0x92>
			dig = *s - 'a' + 10;
  800d12:	0f be c9             	movsbl %cl,%ecx
  800d15:	83 e9 57             	sub    $0x57,%ecx
  800d18:	eb 0e                	jmp    800d28 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d1a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d1d:	80 fb 19             	cmp    $0x19,%bl
  800d20:	77 12                	ja     800d34 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d22:	0f be c9             	movsbl %cl,%ecx
  800d25:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d28:	39 f1                	cmp    %esi,%ecx
  800d2a:	7d 0c                	jge    800d38 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d2c:	42                   	inc    %edx
  800d2d:	0f af c6             	imul   %esi,%eax
  800d30:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d32:	eb c4                	jmp    800cf8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d34:	89 c1                	mov    %eax,%ecx
  800d36:	eb 02                	jmp    800d3a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d38:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d3a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d3e:	74 05                	je     800d45 <strtol+0xbd>
		*endptr = (char *) s;
  800d40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d43:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d45:	85 ff                	test   %edi,%edi
  800d47:	74 04                	je     800d4d <strtol+0xc5>
  800d49:	89 c8                	mov    %ecx,%eax
  800d4b:	f7 d8                	neg    %eax
}
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    
	...

00800d54 <__udivdi3>:
  800d54:	55                   	push   %ebp
  800d55:	57                   	push   %edi
  800d56:	56                   	push   %esi
  800d57:	83 ec 10             	sub    $0x10,%esp
  800d5a:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d5e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800d62:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d66:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800d6a:	89 cd                	mov    %ecx,%ebp
  800d6c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800d70:	85 c0                	test   %eax,%eax
  800d72:	75 2c                	jne    800da0 <__udivdi3+0x4c>
  800d74:	39 f9                	cmp    %edi,%ecx
  800d76:	77 68                	ja     800de0 <__udivdi3+0x8c>
  800d78:	85 c9                	test   %ecx,%ecx
  800d7a:	75 0b                	jne    800d87 <__udivdi3+0x33>
  800d7c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d81:	31 d2                	xor    %edx,%edx
  800d83:	f7 f1                	div    %ecx
  800d85:	89 c1                	mov    %eax,%ecx
  800d87:	31 d2                	xor    %edx,%edx
  800d89:	89 f8                	mov    %edi,%eax
  800d8b:	f7 f1                	div    %ecx
  800d8d:	89 c7                	mov    %eax,%edi
  800d8f:	89 f0                	mov    %esi,%eax
  800d91:	f7 f1                	div    %ecx
  800d93:	89 c6                	mov    %eax,%esi
  800d95:	89 f0                	mov    %esi,%eax
  800d97:	89 fa                	mov    %edi,%edx
  800d99:	83 c4 10             	add    $0x10,%esp
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    
  800da0:	39 f8                	cmp    %edi,%eax
  800da2:	77 2c                	ja     800dd0 <__udivdi3+0x7c>
  800da4:	0f bd f0             	bsr    %eax,%esi
  800da7:	83 f6 1f             	xor    $0x1f,%esi
  800daa:	75 4c                	jne    800df8 <__udivdi3+0xa4>
  800dac:	39 f8                	cmp    %edi,%eax
  800dae:	bf 00 00 00 00       	mov    $0x0,%edi
  800db3:	72 0a                	jb     800dbf <__udivdi3+0x6b>
  800db5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800db9:	0f 87 ad 00 00 00    	ja     800e6c <__udivdi3+0x118>
  800dbf:	be 01 00 00 00       	mov    $0x1,%esi
  800dc4:	89 f0                	mov    %esi,%eax
  800dc6:	89 fa                	mov    %edi,%edx
  800dc8:	83 c4 10             	add    $0x10,%esp
  800dcb:	5e                   	pop    %esi
  800dcc:	5f                   	pop    %edi
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    
  800dcf:	90                   	nop
  800dd0:	31 ff                	xor    %edi,%edi
  800dd2:	31 f6                	xor    %esi,%esi
  800dd4:	89 f0                	mov    %esi,%eax
  800dd6:	89 fa                	mov    %edi,%edx
  800dd8:	83 c4 10             	add    $0x10,%esp
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    
  800ddf:	90                   	nop
  800de0:	89 fa                	mov    %edi,%edx
  800de2:	89 f0                	mov    %esi,%eax
  800de4:	f7 f1                	div    %ecx
  800de6:	89 c6                	mov    %eax,%esi
  800de8:	31 ff                	xor    %edi,%edi
  800dea:	89 f0                	mov    %esi,%eax
  800dec:	89 fa                	mov    %edi,%edx
  800dee:	83 c4 10             	add    $0x10,%esp
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    
  800df5:	8d 76 00             	lea    0x0(%esi),%esi
  800df8:	89 f1                	mov    %esi,%ecx
  800dfa:	d3 e0                	shl    %cl,%eax
  800dfc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e00:	b8 20 00 00 00       	mov    $0x20,%eax
  800e05:	29 f0                	sub    %esi,%eax
  800e07:	89 ea                	mov    %ebp,%edx
  800e09:	88 c1                	mov    %al,%cl
  800e0b:	d3 ea                	shr    %cl,%edx
  800e0d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e11:	09 ca                	or     %ecx,%edx
  800e13:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e17:	89 f1                	mov    %esi,%ecx
  800e19:	d3 e5                	shl    %cl,%ebp
  800e1b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800e1f:	89 fd                	mov    %edi,%ebp
  800e21:	88 c1                	mov    %al,%cl
  800e23:	d3 ed                	shr    %cl,%ebp
  800e25:	89 fa                	mov    %edi,%edx
  800e27:	89 f1                	mov    %esi,%ecx
  800e29:	d3 e2                	shl    %cl,%edx
  800e2b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e2f:	88 c1                	mov    %al,%cl
  800e31:	d3 ef                	shr    %cl,%edi
  800e33:	09 d7                	or     %edx,%edi
  800e35:	89 f8                	mov    %edi,%eax
  800e37:	89 ea                	mov    %ebp,%edx
  800e39:	f7 74 24 08          	divl   0x8(%esp)
  800e3d:	89 d1                	mov    %edx,%ecx
  800e3f:	89 c7                	mov    %eax,%edi
  800e41:	f7 64 24 0c          	mull   0xc(%esp)
  800e45:	39 d1                	cmp    %edx,%ecx
  800e47:	72 17                	jb     800e60 <__udivdi3+0x10c>
  800e49:	74 09                	je     800e54 <__udivdi3+0x100>
  800e4b:	89 fe                	mov    %edi,%esi
  800e4d:	31 ff                	xor    %edi,%edi
  800e4f:	e9 41 ff ff ff       	jmp    800d95 <__udivdi3+0x41>
  800e54:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e58:	89 f1                	mov    %esi,%ecx
  800e5a:	d3 e2                	shl    %cl,%edx
  800e5c:	39 c2                	cmp    %eax,%edx
  800e5e:	73 eb                	jae    800e4b <__udivdi3+0xf7>
  800e60:	8d 77 ff             	lea    -0x1(%edi),%esi
  800e63:	31 ff                	xor    %edi,%edi
  800e65:	e9 2b ff ff ff       	jmp    800d95 <__udivdi3+0x41>
  800e6a:	66 90                	xchg   %ax,%ax
  800e6c:	31 f6                	xor    %esi,%esi
  800e6e:	e9 22 ff ff ff       	jmp    800d95 <__udivdi3+0x41>
	...

00800e74 <__umoddi3>:
  800e74:	55                   	push   %ebp
  800e75:	57                   	push   %edi
  800e76:	56                   	push   %esi
  800e77:	83 ec 20             	sub    $0x20,%esp
  800e7a:	8b 44 24 30          	mov    0x30(%esp),%eax
  800e7e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800e82:	89 44 24 14          	mov    %eax,0x14(%esp)
  800e86:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e8a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e8e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e92:	89 c7                	mov    %eax,%edi
  800e94:	89 f2                	mov    %esi,%edx
  800e96:	85 ed                	test   %ebp,%ebp
  800e98:	75 16                	jne    800eb0 <__umoddi3+0x3c>
  800e9a:	39 f1                	cmp    %esi,%ecx
  800e9c:	0f 86 a6 00 00 00    	jbe    800f48 <__umoddi3+0xd4>
  800ea2:	f7 f1                	div    %ecx
  800ea4:	89 d0                	mov    %edx,%eax
  800ea6:	31 d2                	xor    %edx,%edx
  800ea8:	83 c4 20             	add    $0x20,%esp
  800eab:	5e                   	pop    %esi
  800eac:	5f                   	pop    %edi
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    
  800eaf:	90                   	nop
  800eb0:	39 f5                	cmp    %esi,%ebp
  800eb2:	0f 87 ac 00 00 00    	ja     800f64 <__umoddi3+0xf0>
  800eb8:	0f bd c5             	bsr    %ebp,%eax
  800ebb:	83 f0 1f             	xor    $0x1f,%eax
  800ebe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec2:	0f 84 a8 00 00 00    	je     800f70 <__umoddi3+0xfc>
  800ec8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ecc:	d3 e5                	shl    %cl,%ebp
  800ece:	bf 20 00 00 00       	mov    $0x20,%edi
  800ed3:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800ed7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800edb:	89 f9                	mov    %edi,%ecx
  800edd:	d3 e8                	shr    %cl,%eax
  800edf:	09 e8                	or     %ebp,%eax
  800ee1:	89 44 24 18          	mov    %eax,0x18(%esp)
  800ee5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ee9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800eed:	d3 e0                	shl    %cl,%eax
  800eef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ef3:	89 f2                	mov    %esi,%edx
  800ef5:	d3 e2                	shl    %cl,%edx
  800ef7:	8b 44 24 14          	mov    0x14(%esp),%eax
  800efb:	d3 e0                	shl    %cl,%eax
  800efd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800f01:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f05:	89 f9                	mov    %edi,%ecx
  800f07:	d3 e8                	shr    %cl,%eax
  800f09:	09 d0                	or     %edx,%eax
  800f0b:	d3 ee                	shr    %cl,%esi
  800f0d:	89 f2                	mov    %esi,%edx
  800f0f:	f7 74 24 18          	divl   0x18(%esp)
  800f13:	89 d6                	mov    %edx,%esi
  800f15:	f7 64 24 0c          	mull   0xc(%esp)
  800f19:	89 c5                	mov    %eax,%ebp
  800f1b:	89 d1                	mov    %edx,%ecx
  800f1d:	39 d6                	cmp    %edx,%esi
  800f1f:	72 67                	jb     800f88 <__umoddi3+0x114>
  800f21:	74 75                	je     800f98 <__umoddi3+0x124>
  800f23:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f27:	29 e8                	sub    %ebp,%eax
  800f29:	19 ce                	sbb    %ecx,%esi
  800f2b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f2f:	d3 e8                	shr    %cl,%eax
  800f31:	89 f2                	mov    %esi,%edx
  800f33:	89 f9                	mov    %edi,%ecx
  800f35:	d3 e2                	shl    %cl,%edx
  800f37:	09 d0                	or     %edx,%eax
  800f39:	89 f2                	mov    %esi,%edx
  800f3b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f3f:	d3 ea                	shr    %cl,%edx
  800f41:	83 c4 20             	add    $0x20,%esp
  800f44:	5e                   	pop    %esi
  800f45:	5f                   	pop    %edi
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    
  800f48:	85 c9                	test   %ecx,%ecx
  800f4a:	75 0b                	jne    800f57 <__umoddi3+0xe3>
  800f4c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f51:	31 d2                	xor    %edx,%edx
  800f53:	f7 f1                	div    %ecx
  800f55:	89 c1                	mov    %eax,%ecx
  800f57:	89 f0                	mov    %esi,%eax
  800f59:	31 d2                	xor    %edx,%edx
  800f5b:	f7 f1                	div    %ecx
  800f5d:	89 f8                	mov    %edi,%eax
  800f5f:	e9 3e ff ff ff       	jmp    800ea2 <__umoddi3+0x2e>
  800f64:	89 f2                	mov    %esi,%edx
  800f66:	83 c4 20             	add    $0x20,%esp
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    
  800f6d:	8d 76 00             	lea    0x0(%esi),%esi
  800f70:	39 f5                	cmp    %esi,%ebp
  800f72:	72 04                	jb     800f78 <__umoddi3+0x104>
  800f74:	39 f9                	cmp    %edi,%ecx
  800f76:	77 06                	ja     800f7e <__umoddi3+0x10a>
  800f78:	89 f2                	mov    %esi,%edx
  800f7a:	29 cf                	sub    %ecx,%edi
  800f7c:	19 ea                	sbb    %ebp,%edx
  800f7e:	89 f8                	mov    %edi,%eax
  800f80:	83 c4 20             	add    $0x20,%esp
  800f83:	5e                   	pop    %esi
  800f84:	5f                   	pop    %edi
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    
  800f87:	90                   	nop
  800f88:	89 d1                	mov    %edx,%ecx
  800f8a:	89 c5                	mov    %eax,%ebp
  800f8c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800f90:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800f94:	eb 8d                	jmp    800f23 <__umoddi3+0xaf>
  800f96:	66 90                	xchg   %ax,%ax
  800f98:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800f9c:	72 ea                	jb     800f88 <__umoddi3+0x114>
  800f9e:	89 f1                	mov    %esi,%ecx
  800fa0:	eb 81                	jmp    800f23 <__umoddi3+0xaf>
