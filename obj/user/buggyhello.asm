
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs((char*)1, 1);
  80003a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800049:	e8 66 00 00 00       	call   8000b4 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	83 ec 10             	sub    $0x10,%esp
  800058:	8b 75 08             	mov    0x8(%ebp),%esi
  80005b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80005e:	e8 e0 00 00 00       	call   800143 <sys_getenvid>
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80006b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80006e:	c1 e0 04             	shl    $0x4,%eax
  800071:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800076:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007b:	85 f6                	test   %esi,%esi
  80007d:	7e 07                	jle    800086 <libmain+0x36>
		binaryname = argv[0];
  80007f:	8b 03                	mov    (%ebx),%eax
  800081:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800086:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008a:	89 34 24             	mov    %esi,(%esp)
  80008d:	e8 a2 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800092:	e8 09 00 00 00       	call   8000a0 <exit>
}
  800097:	83 c4 10             	add    $0x10,%esp
  80009a:	5b                   	pop    %ebx
  80009b:	5e                   	pop    %esi
  80009c:	5d                   	pop    %ebp
  80009d:	c3                   	ret    
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ad:	e8 3f 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 28                	jle    80013b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	89 44 24 10          	mov    %eax,0x10(%esp)
  800117:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011e:	00 
  80011f:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800126:	00 
  800127:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012e:	00 
  80012f:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800136:	e8 e1 07 00 00       	call   80091c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	83 c4 2c             	add    $0x2c,%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800197:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019a:	8b 55 08             	mov    0x8(%ebp),%edx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 28                	jle    8001cd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001b0:	00 
  8001b1:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8001b8:	00 
  8001b9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c0:	00 
  8001c1:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8001c8:	e8 4f 07 00 00       	call   80091c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001cd:	83 c4 2c             	add    $0x2c,%esp
  8001d0:	5b                   	pop    %ebx
  8001d1:	5e                   	pop    %esi
  8001d2:	5f                   	pop    %edi
  8001d3:	5d                   	pop    %ebp
  8001d4:	c3                   	ret    

008001d5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	57                   	push   %edi
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001de:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f4:	85 c0                	test   %eax,%eax
  8001f6:	7e 28                	jle    800220 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001fc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800203:	00 
  800204:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800213:	00 
  800214:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80021b:	e8 fc 06 00 00       	call   80091c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800220:	83 c4 2c             	add    $0x2c,%esp
  800223:	5b                   	pop    %ebx
  800224:	5e                   	pop    %esi
  800225:	5f                   	pop    %edi
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    

00800228 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	57                   	push   %edi
  80022c:	56                   	push   %esi
  80022d:	53                   	push   %ebx
  80022e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800231:	bb 00 00 00 00       	mov    $0x0,%ebx
  800236:	b8 06 00 00 00       	mov    $0x6,%eax
  80023b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023e:	8b 55 08             	mov    0x8(%ebp),%edx
  800241:	89 df                	mov    %ebx,%edi
  800243:	89 de                	mov    %ebx,%esi
  800245:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800247:	85 c0                	test   %eax,%eax
  800249:	7e 28                	jle    800273 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80024f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800256:	00 
  800257:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80025e:	00 
  80025f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800266:	00 
  800267:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80026e:	e8 a9 06 00 00       	call   80091c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800273:	83 c4 2c             	add    $0x2c,%esp
  800276:	5b                   	pop    %ebx
  800277:	5e                   	pop    %esi
  800278:	5f                   	pop    %edi
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	57                   	push   %edi
  80027f:	56                   	push   %esi
  800280:	53                   	push   %ebx
  800281:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800284:	bb 00 00 00 00       	mov    $0x0,%ebx
  800289:	b8 08 00 00 00       	mov    $0x8,%eax
  80028e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800291:	8b 55 08             	mov    0x8(%ebp),%edx
  800294:	89 df                	mov    %ebx,%edi
  800296:	89 de                	mov    %ebx,%esi
  800298:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80029a:	85 c0                	test   %eax,%eax
  80029c:	7e 28                	jle    8002c6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a9:	00 
  8002aa:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8002b1:	00 
  8002b2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b9:	00 
  8002ba:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8002c1:	e8 56 06 00 00       	call   80091c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c6:	83 c4 2c             	add    $0x2c,%esp
  8002c9:	5b                   	pop    %ebx
  8002ca:	5e                   	pop    %esi
  8002cb:	5f                   	pop    %edi
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	57                   	push   %edi
  8002d2:	56                   	push   %esi
  8002d3:	53                   	push   %ebx
  8002d4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002dc:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e7:	89 df                	mov    %ebx,%edi
  8002e9:	89 de                	mov    %ebx,%esi
  8002eb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ed:	85 c0                	test   %eax,%eax
  8002ef:	7e 28                	jle    800319 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002fc:	00 
  8002fd:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800304:	00 
  800305:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80030c:	00 
  80030d:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800314:	e8 03 06 00 00       	call   80091c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800319:	83 c4 2c             	add    $0x2c,%esp
  80031c:	5b                   	pop    %ebx
  80031d:	5e                   	pop    %esi
  80031e:	5f                   	pop    %edi
  80031f:	5d                   	pop    %ebp
  800320:	c3                   	ret    

00800321 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	57                   	push   %edi
  800325:	56                   	push   %esi
  800326:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800327:	be 00 00 00 00       	mov    $0x0,%esi
  80032c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800331:	8b 7d 14             	mov    0x14(%ebp),%edi
  800334:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800337:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033a:	8b 55 08             	mov    0x8(%ebp),%edx
  80033d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80033f:	5b                   	pop    %ebx
  800340:	5e                   	pop    %esi
  800341:	5f                   	pop    %edi
  800342:	5d                   	pop    %ebp
  800343:	c3                   	ret    

00800344 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	57                   	push   %edi
  800348:	56                   	push   %esi
  800349:	53                   	push   %ebx
  80034a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800352:	b8 0c 00 00 00       	mov    $0xc,%eax
  800357:	8b 55 08             	mov    0x8(%ebp),%edx
  80035a:	89 cb                	mov    %ecx,%ebx
  80035c:	89 cf                	mov    %ecx,%edi
  80035e:	89 ce                	mov    %ecx,%esi
  800360:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800362:	85 c0                	test   %eax,%eax
  800364:	7e 28                	jle    80038e <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800366:	89 44 24 10          	mov    %eax,0x10(%esp)
  80036a:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800371:	00 
  800372:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800379:	00 
  80037a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800381:	00 
  800382:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800389:	e8 8e 05 00 00       	call   80091c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80038e:	83 c4 2c             	add    $0x2c,%esp
  800391:	5b                   	pop    %ebx
  800392:	5e                   	pop    %esi
  800393:	5f                   	pop    %edi
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    

00800396 <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
  800399:	57                   	push   %edi
  80039a:	56                   	push   %esi
  80039b:	53                   	push   %ebx
  80039c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80039f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a4:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8003af:	89 df                	mov    %ebx,%edi
  8003b1:	89 de                	mov    %ebx,%esi
  8003b3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003b5:	85 c0                	test   %eax,%eax
  8003b7:	7e 28                	jle    8003e1 <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003bd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003c4:	00 
  8003c5:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8003cc:	00 
  8003cd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d4:	00 
  8003d5:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8003dc:	e8 3b 05 00 00       	call   80091c <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8003e1:	83 c4 2c             	add    $0x2c,%esp
  8003e4:	5b                   	pop    %ebx
  8003e5:	5e                   	pop    %esi
  8003e6:	5f                   	pop    %edi
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    

008003e9 <sys_env_set_debug_upcall>:

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	57                   	push   %edi
  8003ed:	56                   	push   %esi
  8003ee:	53                   	push   %ebx
  8003ef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003f7:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800402:	89 df                	mov    %ebx,%edi
  800404:	89 de                	mov    %ebx,%esi
  800406:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800408:	85 c0                	test   %eax,%eax
  80040a:	7e 28                	jle    800434 <sys_env_set_debug_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80040c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800410:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800417:	00 
  800418:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80041f:	00 
  800420:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800427:	00 
  800428:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80042f:	e8 e8 04 00 00       	call   80091c <_panic>
}

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_debug_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800434:	83 c4 2c             	add    $0x2c,%esp
  800437:	5b                   	pop    %ebx
  800438:	5e                   	pop    %esi
  800439:	5f                   	pop    %edi
  80043a:	5d                   	pop    %ebp
  80043b:	c3                   	ret    

0080043c <sys_env_set_nmskint_upcall>:

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	57                   	push   %edi
  800440:	56                   	push   %esi
  800441:	53                   	push   %ebx
  800442:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800445:	bb 00 00 00 00       	mov    $0x0,%ebx
  80044a:	b8 0f 00 00 00       	mov    $0xf,%eax
  80044f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800452:	8b 55 08             	mov    0x8(%ebp),%edx
  800455:	89 df                	mov    %ebx,%edi
  800457:	89 de                	mov    %ebx,%esi
  800459:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80045b:	85 c0                	test   %eax,%eax
  80045d:	7e 28                	jle    800487 <sys_env_set_nmskint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80045f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800463:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  80046a:	00 
  80046b:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800472:	00 
  800473:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80047a:	00 
  80047b:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800482:	e8 95 04 00 00       	call   80091c <_panic>
}

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_nmskint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800487:	83 c4 2c             	add    $0x2c,%esp
  80048a:	5b                   	pop    %ebx
  80048b:	5e                   	pop    %esi
  80048c:	5f                   	pop    %edi
  80048d:	5d                   	pop    %ebp
  80048e:	c3                   	ret    

0080048f <sys_env_set_bpoint_upcall>:

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
  80048f:	55                   	push   %ebp
  800490:	89 e5                	mov    %esp,%ebp
  800492:	57                   	push   %edi
  800493:	56                   	push   %esi
  800494:	53                   	push   %ebx
  800495:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800498:	bb 00 00 00 00       	mov    $0x0,%ebx
  80049d:	b8 10 00 00 00       	mov    $0x10,%eax
  8004a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a8:	89 df                	mov    %ebx,%edi
  8004aa:	89 de                	mov    %ebx,%esi
  8004ac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8004ae:	85 c0                	test   %eax,%eax
  8004b0:	7e 28                	jle    8004da <sys_env_set_bpoint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004b6:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  8004bd:	00 
  8004be:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8004c5:	00 
  8004c6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004cd:	00 
  8004ce:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8004d5:	e8 42 04 00 00       	call   80091c <_panic>
}

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bpoint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8004da:	83 c4 2c             	add    $0x2c,%esp
  8004dd:	5b                   	pop    %ebx
  8004de:	5e                   	pop    %esi
  8004df:	5f                   	pop    %edi
  8004e0:	5d                   	pop    %ebp
  8004e1:	c3                   	ret    

008004e2 <sys_env_set_oflow_upcall>:

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
  8004e2:	55                   	push   %ebp
  8004e3:	89 e5                	mov    %esp,%ebp
  8004e5:	57                   	push   %edi
  8004e6:	56                   	push   %esi
  8004e7:	53                   	push   %ebx
  8004e8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004f0:	b8 11 00 00 00       	mov    $0x11,%eax
  8004f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004fb:	89 df                	mov    %ebx,%edi
  8004fd:	89 de                	mov    %ebx,%esi
  8004ff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800501:	85 c0                	test   %eax,%eax
  800503:	7e 28                	jle    80052d <sys_env_set_oflow_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800505:	89 44 24 10          	mov    %eax,0x10(%esp)
  800509:	c7 44 24 0c 11 00 00 	movl   $0x11,0xc(%esp)
  800510:	00 
  800511:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800518:	00 
  800519:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800520:	00 
  800521:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800528:	e8 ef 03 00 00       	call   80091c <_panic>
}

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_oflow_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80052d:	83 c4 2c             	add    $0x2c,%esp
  800530:	5b                   	pop    %ebx
  800531:	5e                   	pop    %esi
  800532:	5f                   	pop    %edi
  800533:	5d                   	pop    %ebp
  800534:	c3                   	ret    

00800535 <sys_env_set_bdschk_upcall>:

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
  800535:	55                   	push   %ebp
  800536:	89 e5                	mov    %esp,%ebp
  800538:	57                   	push   %edi
  800539:	56                   	push   %esi
  80053a:	53                   	push   %ebx
  80053b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80053e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800543:	b8 12 00 00 00       	mov    $0x12,%eax
  800548:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80054b:	8b 55 08             	mov    0x8(%ebp),%edx
  80054e:	89 df                	mov    %ebx,%edi
  800550:	89 de                	mov    %ebx,%esi
  800552:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800554:	85 c0                	test   %eax,%eax
  800556:	7e 28                	jle    800580 <sys_env_set_bdschk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800558:	89 44 24 10          	mov    %eax,0x10(%esp)
  80055c:	c7 44 24 0c 12 00 00 	movl   $0x12,0xc(%esp)
  800563:	00 
  800564:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80056b:	00 
  80056c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800573:	00 
  800574:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80057b:	e8 9c 03 00 00       	call   80091c <_panic>
}

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bdschk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800580:	83 c4 2c             	add    $0x2c,%esp
  800583:	5b                   	pop    %ebx
  800584:	5e                   	pop    %esi
  800585:	5f                   	pop    %edi
  800586:	5d                   	pop    %ebp
  800587:	c3                   	ret    

00800588 <sys_env_set_illopcd_upcall>:

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
  800588:	55                   	push   %ebp
  800589:	89 e5                	mov    %esp,%ebp
  80058b:	57                   	push   %edi
  80058c:	56                   	push   %esi
  80058d:	53                   	push   %ebx
  80058e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800591:	bb 00 00 00 00       	mov    $0x0,%ebx
  800596:	b8 13 00 00 00       	mov    $0x13,%eax
  80059b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80059e:	8b 55 08             	mov    0x8(%ebp),%edx
  8005a1:	89 df                	mov    %ebx,%edi
  8005a3:	89 de                	mov    %ebx,%esi
  8005a5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	7e 28                	jle    8005d3 <sys_env_set_illopcd_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005ab:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005af:	c7 44 24 0c 13 00 00 	movl   $0x13,0xc(%esp)
  8005b6:	00 
  8005b7:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8005be:	00 
  8005bf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005c6:	00 
  8005c7:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8005ce:	e8 49 03 00 00       	call   80091c <_panic>
}

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_illopcd_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8005d3:	83 c4 2c             	add    $0x2c,%esp
  8005d6:	5b                   	pop    %ebx
  8005d7:	5e                   	pop    %esi
  8005d8:	5f                   	pop    %edi
  8005d9:	5d                   	pop    %ebp
  8005da:	c3                   	ret    

008005db <sys_env_set_dvcntavl_upcall>:

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
  8005db:	55                   	push   %ebp
  8005dc:	89 e5                	mov    %esp,%ebp
  8005de:	57                   	push   %edi
  8005df:	56                   	push   %esi
  8005e0:	53                   	push   %ebx
  8005e1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005e9:	b8 14 00 00 00       	mov    $0x14,%eax
  8005ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8005f4:	89 df                	mov    %ebx,%edi
  8005f6:	89 de                	mov    %ebx,%esi
  8005f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005fa:	85 c0                	test   %eax,%eax
  8005fc:	7e 28                	jle    800626 <sys_env_set_dvcntavl_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800602:	c7 44 24 0c 14 00 00 	movl   $0x14,0xc(%esp)
  800609:	00 
  80060a:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800611:	00 
  800612:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800619:	00 
  80061a:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800621:	e8 f6 02 00 00       	call   80091c <_panic>
}

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dvcntavl_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800626:	83 c4 2c             	add    $0x2c,%esp
  800629:	5b                   	pop    %ebx
  80062a:	5e                   	pop    %esi
  80062b:	5f                   	pop    %edi
  80062c:	5d                   	pop    %ebp
  80062d:	c3                   	ret    

0080062e <sys_env_set_dbfault_upcall>:

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
  80062e:	55                   	push   %ebp
  80062f:	89 e5                	mov    %esp,%ebp
  800631:	57                   	push   %edi
  800632:	56                   	push   %esi
  800633:	53                   	push   %ebx
  800634:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800637:	bb 00 00 00 00       	mov    $0x0,%ebx
  80063c:	b8 15 00 00 00       	mov    $0x15,%eax
  800641:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800644:	8b 55 08             	mov    0x8(%ebp),%edx
  800647:	89 df                	mov    %ebx,%edi
  800649:	89 de                	mov    %ebx,%esi
  80064b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80064d:	85 c0                	test   %eax,%eax
  80064f:	7e 28                	jle    800679 <sys_env_set_dbfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800651:	89 44 24 10          	mov    %eax,0x10(%esp)
  800655:	c7 44 24 0c 15 00 00 	movl   $0x15,0xc(%esp)
  80065c:	00 
  80065d:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800664:	00 
  800665:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80066c:	00 
  80066d:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800674:	e8 a3 02 00 00       	call   80091c <_panic>
}

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dbfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800679:	83 c4 2c             	add    $0x2c,%esp
  80067c:	5b                   	pop    %ebx
  80067d:	5e                   	pop    %esi
  80067e:	5f                   	pop    %edi
  80067f:	5d                   	pop    %ebp
  800680:	c3                   	ret    

00800681 <sys_env_set_ivldtss_upcall>:

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
  800681:	55                   	push   %ebp
  800682:	89 e5                	mov    %esp,%ebp
  800684:	57                   	push   %edi
  800685:	56                   	push   %esi
  800686:	53                   	push   %ebx
  800687:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80068a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80068f:	b8 16 00 00 00       	mov    $0x16,%eax
  800694:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800697:	8b 55 08             	mov    0x8(%ebp),%edx
  80069a:	89 df                	mov    %ebx,%edi
  80069c:	89 de                	mov    %ebx,%esi
  80069e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006a0:	85 c0                	test   %eax,%eax
  8006a2:	7e 28                	jle    8006cc <sys_env_set_ivldtss_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006a8:	c7 44 24 0c 16 00 00 	movl   $0x16,0xc(%esp)
  8006af:	00 
  8006b0:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8006b7:	00 
  8006b8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006bf:	00 
  8006c0:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8006c7:	e8 50 02 00 00       	call   80091c <_panic>
}

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_ivldtss_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8006cc:	83 c4 2c             	add    $0x2c,%esp
  8006cf:	5b                   	pop    %ebx
  8006d0:	5e                   	pop    %esi
  8006d1:	5f                   	pop    %edi
  8006d2:	5d                   	pop    %ebp
  8006d3:	c3                   	ret    

008006d4 <sys_env_set_segntprst_upcall>:

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	57                   	push   %edi
  8006d8:	56                   	push   %esi
  8006d9:	53                   	push   %ebx
  8006da:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e2:	b8 17 00 00 00       	mov    $0x17,%eax
  8006e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ed:	89 df                	mov    %ebx,%edi
  8006ef:	89 de                	mov    %ebx,%esi
  8006f1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	7e 28                	jle    80071f <sys_env_set_segntprst_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006f7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006fb:	c7 44 24 0c 17 00 00 	movl   $0x17,0xc(%esp)
  800702:	00 
  800703:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80070a:	00 
  80070b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800712:	00 
  800713:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80071a:	e8 fd 01 00 00       	call   80091c <_panic>
}

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_segntprst_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80071f:	83 c4 2c             	add    $0x2c,%esp
  800722:	5b                   	pop    %ebx
  800723:	5e                   	pop    %esi
  800724:	5f                   	pop    %edi
  800725:	5d                   	pop    %ebp
  800726:	c3                   	ret    

00800727 <sys_env_set_stkexception_upcall>:

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	57                   	push   %edi
  80072b:	56                   	push   %esi
  80072c:	53                   	push   %ebx
  80072d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800730:	bb 00 00 00 00       	mov    $0x0,%ebx
  800735:	b8 18 00 00 00       	mov    $0x18,%eax
  80073a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80073d:	8b 55 08             	mov    0x8(%ebp),%edx
  800740:	89 df                	mov    %ebx,%edi
  800742:	89 de                	mov    %ebx,%esi
  800744:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800746:	85 c0                	test   %eax,%eax
  800748:	7e 28                	jle    800772 <sys_env_set_stkexception_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80074a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80074e:	c7 44 24 0c 18 00 00 	movl   $0x18,0xc(%esp)
  800755:	00 
  800756:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  80075d:	00 
  80075e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800765:	00 
  800766:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80076d:	e8 aa 01 00 00       	call   80091c <_panic>
}

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_stkexception_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800772:	83 c4 2c             	add    $0x2c,%esp
  800775:	5b                   	pop    %ebx
  800776:	5e                   	pop    %esi
  800777:	5f                   	pop    %edi
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <sys_env_set_gpfault_upcall>:

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	57                   	push   %edi
  80077e:	56                   	push   %esi
  80077f:	53                   	push   %ebx
  800780:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800783:	bb 00 00 00 00       	mov    $0x0,%ebx
  800788:	b8 19 00 00 00       	mov    $0x19,%eax
  80078d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800790:	8b 55 08             	mov    0x8(%ebp),%edx
  800793:	89 df                	mov    %ebx,%edi
  800795:	89 de                	mov    %ebx,%esi
  800797:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800799:	85 c0                	test   %eax,%eax
  80079b:	7e 28                	jle    8007c5 <sys_env_set_gpfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80079d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007a1:	c7 44 24 0c 19 00 00 	movl   $0x19,0xc(%esp)
  8007a8:	00 
  8007a9:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8007b0:	00 
  8007b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8007b8:	00 
  8007b9:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8007c0:	e8 57 01 00 00       	call   80091c <_panic>
}

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_gpfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8007c5:	83 c4 2c             	add    $0x2c,%esp
  8007c8:	5b                   	pop    %ebx
  8007c9:	5e                   	pop    %esi
  8007ca:	5f                   	pop    %edi
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <sys_env_set_fperror_upcall>:

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	57                   	push   %edi
  8007d1:	56                   	push   %esi
  8007d2:	53                   	push   %ebx
  8007d3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007db:	b8 1a 00 00 00       	mov    $0x1a,%eax
  8007e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8007e6:	89 df                	mov    %ebx,%edi
  8007e8:	89 de                	mov    %ebx,%esi
  8007ea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8007ec:	85 c0                	test   %eax,%eax
  8007ee:	7e 28                	jle    800818 <sys_env_set_fperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007f4:	c7 44 24 0c 1a 00 00 	movl   $0x1a,0xc(%esp)
  8007fb:	00 
  8007fc:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800803:	00 
  800804:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80080b:	00 
  80080c:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800813:	e8 04 01 00 00       	call   80091c <_panic>
}

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_fperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800818:	83 c4 2c             	add    $0x2c,%esp
  80081b:	5b                   	pop    %ebx
  80081c:	5e                   	pop    %esi
  80081d:	5f                   	pop    %edi
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <sys_env_set_algchk_upcall>:

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	57                   	push   %edi
  800824:	56                   	push   %esi
  800825:	53                   	push   %ebx
  800826:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800829:	bb 00 00 00 00       	mov    $0x0,%ebx
  80082e:	b8 1b 00 00 00       	mov    $0x1b,%eax
  800833:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800836:	8b 55 08             	mov    0x8(%ebp),%edx
  800839:	89 df                	mov    %ebx,%edi
  80083b:	89 de                	mov    %ebx,%esi
  80083d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80083f:	85 c0                	test   %eax,%eax
  800841:	7e 28                	jle    80086b <sys_env_set_algchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800843:	89 44 24 10          	mov    %eax,0x10(%esp)
  800847:	c7 44 24 0c 1b 00 00 	movl   $0x1b,0xc(%esp)
  80084e:	00 
  80084f:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  800856:	00 
  800857:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80085e:	00 
  80085f:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  800866:	e8 b1 00 00 00       	call   80091c <_panic>
}

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_algchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80086b:	83 c4 2c             	add    $0x2c,%esp
  80086e:	5b                   	pop    %ebx
  80086f:	5e                   	pop    %esi
  800870:	5f                   	pop    %edi
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <sys_env_set_mchchk_upcall>:

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	57                   	push   %edi
  800877:	56                   	push   %esi
  800878:	53                   	push   %ebx
  800879:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80087c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800881:	b8 1c 00 00 00       	mov    $0x1c,%eax
  800886:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800889:	8b 55 08             	mov    0x8(%ebp),%edx
  80088c:	89 df                	mov    %ebx,%edi
  80088e:	89 de                	mov    %ebx,%esi
  800890:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800892:	85 c0                	test   %eax,%eax
  800894:	7e 28                	jle    8008be <sys_env_set_mchchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800896:	89 44 24 10          	mov    %eax,0x10(%esp)
  80089a:	c7 44 24 0c 1c 00 00 	movl   $0x1c,0xc(%esp)
  8008a1:	00 
  8008a2:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8008a9:	00 
  8008aa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8008b1:	00 
  8008b2:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  8008b9:	e8 5e 00 00 00       	call   80091c <_panic>
}

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_mchchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8008be:	83 c4 2c             	add    $0x2c,%esp
  8008c1:	5b                   	pop    %ebx
  8008c2:	5e                   	pop    %esi
  8008c3:	5f                   	pop    %edi
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <sys_env_set_SIMDfperror_upcall>:

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	57                   	push   %edi
  8008ca:	56                   	push   %esi
  8008cb:	53                   	push   %ebx
  8008cc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8008cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008d4:	b8 1d 00 00 00       	mov    $0x1d,%eax
  8008d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8008df:	89 df                	mov    %ebx,%edi
  8008e1:	89 de                	mov    %ebx,%esi
  8008e3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8008e5:	85 c0                	test   %eax,%eax
  8008e7:	7e 28                	jle    800911 <sys_env_set_SIMDfperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8008e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8008ed:	c7 44 24 0c 1d 00 00 	movl   $0x1d,0xc(%esp)
  8008f4:	00 
  8008f5:	c7 44 24 08 4a 15 80 	movl   $0x80154a,0x8(%esp)
  8008fc:	00 
  8008fd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800904:	00 
  800905:	c7 04 24 67 15 80 00 	movl   $0x801567,(%esp)
  80090c:	e8 0b 00 00 00       	call   80091c <_panic>
}

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_SIMDfperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800911:	83 c4 2c             	add    $0x2c,%esp
  800914:	5b                   	pop    %ebx
  800915:	5e                   	pop    %esi
  800916:	5f                   	pop    %edi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    
  800919:	00 00                	add    %al,(%eax)
	...

0080091c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	56                   	push   %esi
  800920:	53                   	push   %ebx
  800921:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800924:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800927:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80092d:	e8 11 f8 ff ff       	call   800143 <sys_getenvid>
  800932:	8b 55 0c             	mov    0xc(%ebp),%edx
  800935:	89 54 24 10          	mov    %edx,0x10(%esp)
  800939:	8b 55 08             	mov    0x8(%ebp),%edx
  80093c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800940:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800944:	89 44 24 04          	mov    %eax,0x4(%esp)
  800948:	c7 04 24 78 15 80 00 	movl   $0x801578,(%esp)
  80094f:	e8 c0 00 00 00       	call   800a14 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800954:	89 74 24 04          	mov    %esi,0x4(%esp)
  800958:	8b 45 10             	mov    0x10(%ebp),%eax
  80095b:	89 04 24             	mov    %eax,(%esp)
  80095e:	e8 50 00 00 00       	call   8009b3 <vcprintf>
	cprintf("\n");
  800963:	c7 04 24 9c 15 80 00 	movl   $0x80159c,(%esp)
  80096a:	e8 a5 00 00 00       	call   800a14 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80096f:	cc                   	int3   
  800970:	eb fd                	jmp    80096f <_panic+0x53>
	...

00800974 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	53                   	push   %ebx
  800978:	83 ec 14             	sub    $0x14,%esp
  80097b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80097e:	8b 03                	mov    (%ebx),%eax
  800980:	8b 55 08             	mov    0x8(%ebp),%edx
  800983:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800987:	40                   	inc    %eax
  800988:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80098a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80098f:	75 19                	jne    8009aa <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800991:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800998:	00 
  800999:	8d 43 08             	lea    0x8(%ebx),%eax
  80099c:	89 04 24             	mov    %eax,(%esp)
  80099f:	e8 10 f7 ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  8009a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8009aa:	ff 43 04             	incl   0x4(%ebx)
}
  8009ad:	83 c4 14             	add    $0x14,%esp
  8009b0:	5b                   	pop    %ebx
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8009bc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8009c3:	00 00 00 
	b.cnt = 0;
  8009c6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8009cd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8009d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009de:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8009e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e8:	c7 04 24 74 09 80 00 	movl   $0x800974,(%esp)
  8009ef:	e8 b4 01 00 00       	call   800ba8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8009f4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8009fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fe:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800a04:	89 04 24             	mov    %eax,(%esp)
  800a07:	e8 a8 f6 ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  800a0c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800a12:	c9                   	leave  
  800a13:	c3                   	ret    

00800a14 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800a1a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	89 04 24             	mov    %eax,(%esp)
  800a27:	e8 87 ff ff ff       	call   8009b3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800a2c:	c9                   	leave  
  800a2d:	c3                   	ret    
	...

00800a30 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	57                   	push   %edi
  800a34:	56                   	push   %esi
  800a35:	53                   	push   %ebx
  800a36:	83 ec 3c             	sub    $0x3c,%esp
  800a39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a3c:	89 d7                	mov    %edx,%edi
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a44:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a47:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a4a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800a4d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800a50:	85 c0                	test   %eax,%eax
  800a52:	75 08                	jne    800a5c <printnum+0x2c>
  800a54:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a57:	39 45 10             	cmp    %eax,0x10(%ebp)
  800a5a:	77 57                	ja     800ab3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800a5c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800a60:	4b                   	dec    %ebx
  800a61:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800a65:	8b 45 10             	mov    0x10(%ebp),%eax
  800a68:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800a70:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800a74:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a7b:	00 
  800a7c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a7f:	89 04 24             	mov    %eax,(%esp)
  800a82:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a85:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a89:	e8 5a 08 00 00       	call   8012e8 <__udivdi3>
  800a8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a92:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a96:	89 04 24             	mov    %eax,(%esp)
  800a99:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a9d:	89 fa                	mov    %edi,%edx
  800a9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800aa2:	e8 89 ff ff ff       	call   800a30 <printnum>
  800aa7:	eb 0f                	jmp    800ab8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800aa9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aad:	89 34 24             	mov    %esi,(%esp)
  800ab0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800ab3:	4b                   	dec    %ebx
  800ab4:	85 db                	test   %ebx,%ebx
  800ab6:	7f f1                	jg     800aa9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800ab8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800abc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ac0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ac3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ac7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ace:	00 
  800acf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ad2:	89 04 24             	mov    %eax,(%esp)
  800ad5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ad8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800adc:	e8 27 09 00 00       	call   801408 <__umoddi3>
  800ae1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ae5:	0f be 80 9e 15 80 00 	movsbl 0x80159e(%eax),%eax
  800aec:	89 04 24             	mov    %eax,(%esp)
  800aef:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800af2:	83 c4 3c             	add    $0x3c,%esp
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800afd:	83 fa 01             	cmp    $0x1,%edx
  800b00:	7e 0e                	jle    800b10 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800b02:	8b 10                	mov    (%eax),%edx
  800b04:	8d 4a 08             	lea    0x8(%edx),%ecx
  800b07:	89 08                	mov    %ecx,(%eax)
  800b09:	8b 02                	mov    (%edx),%eax
  800b0b:	8b 52 04             	mov    0x4(%edx),%edx
  800b0e:	eb 22                	jmp    800b32 <getuint+0x38>
	else if (lflag)
  800b10:	85 d2                	test   %edx,%edx
  800b12:	74 10                	je     800b24 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800b14:	8b 10                	mov    (%eax),%edx
  800b16:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b19:	89 08                	mov    %ecx,(%eax)
  800b1b:	8b 02                	mov    (%edx),%eax
  800b1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b22:	eb 0e                	jmp    800b32 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800b24:	8b 10                	mov    (%eax),%edx
  800b26:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b29:	89 08                	mov    %ecx,(%eax)
  800b2b:	8b 02                	mov    (%edx),%eax
  800b2d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800b37:	83 fa 01             	cmp    $0x1,%edx
  800b3a:	7e 0e                	jle    800b4a <getint+0x16>
		return va_arg(*ap, long long);
  800b3c:	8b 10                	mov    (%eax),%edx
  800b3e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800b41:	89 08                	mov    %ecx,(%eax)
  800b43:	8b 02                	mov    (%edx),%eax
  800b45:	8b 52 04             	mov    0x4(%edx),%edx
  800b48:	eb 1a                	jmp    800b64 <getint+0x30>
	else if (lflag)
  800b4a:	85 d2                	test   %edx,%edx
  800b4c:	74 0c                	je     800b5a <getint+0x26>
		return va_arg(*ap, long);
  800b4e:	8b 10                	mov    (%eax),%edx
  800b50:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b53:	89 08                	mov    %ecx,(%eax)
  800b55:	8b 02                	mov    (%edx),%eax
  800b57:	99                   	cltd   
  800b58:	eb 0a                	jmp    800b64 <getint+0x30>
	else
		return va_arg(*ap, int);
  800b5a:	8b 10                	mov    (%eax),%edx
  800b5c:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b5f:	89 08                	mov    %ecx,(%eax)
  800b61:	8b 02                	mov    (%edx),%eax
  800b63:	99                   	cltd   
}
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800b6c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800b6f:	8b 10                	mov    (%eax),%edx
  800b71:	3b 50 04             	cmp    0x4(%eax),%edx
  800b74:	73 08                	jae    800b7e <sprintputch+0x18>
		*b->buf++ = ch;
  800b76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b79:	88 0a                	mov    %cl,(%edx)
  800b7b:	42                   	inc    %edx
  800b7c:	89 10                	mov    %edx,(%eax)
}
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800b86:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800b89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b8d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b90:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9e:	89 04 24             	mov    %eax,(%esp)
  800ba1:	e8 02 00 00 00       	call   800ba8 <vprintfmt>
	va_end(ap);
}
  800ba6:	c9                   	leave  
  800ba7:	c3                   	ret    

00800ba8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	83 ec 4c             	sub    $0x4c,%esp
  800bb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bb4:	8b 75 10             	mov    0x10(%ebp),%esi
  800bb7:	eb 12                	jmp    800bcb <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	0f 84 40 03 00 00    	je     800f01 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800bc1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bc5:	89 04 24             	mov    %eax,(%esp)
  800bc8:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800bcb:	0f b6 06             	movzbl (%esi),%eax
  800bce:	46                   	inc    %esi
  800bcf:	83 f8 25             	cmp    $0x25,%eax
  800bd2:	75 e5                	jne    800bb9 <vprintfmt+0x11>
  800bd4:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800bd8:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800bdf:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800be4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800beb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf0:	eb 26                	jmp    800c18 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bf2:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800bf5:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800bf9:	eb 1d                	jmp    800c18 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bfb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800bfe:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800c02:	eb 14                	jmp    800c18 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c04:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800c07:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800c0e:	eb 08                	jmp    800c18 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800c10:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800c13:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c18:	0f b6 06             	movzbl (%esi),%eax
  800c1b:	8d 4e 01             	lea    0x1(%esi),%ecx
  800c1e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800c21:	8a 0e                	mov    (%esi),%cl
  800c23:	83 e9 23             	sub    $0x23,%ecx
  800c26:	80 f9 55             	cmp    $0x55,%cl
  800c29:	0f 87 b6 02 00 00    	ja     800ee5 <vprintfmt+0x33d>
  800c2f:	0f b6 c9             	movzbl %cl,%ecx
  800c32:	ff 24 8d 60 16 80 00 	jmp    *0x801660(,%ecx,4)
  800c39:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c3c:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800c41:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800c44:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  800c48:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800c4b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800c4e:	83 f9 09             	cmp    $0x9,%ecx
  800c51:	77 2a                	ja     800c7d <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c53:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800c54:	eb eb                	jmp    800c41 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800c56:	8b 45 14             	mov    0x14(%ebp),%eax
  800c59:	8d 48 04             	lea    0x4(%eax),%ecx
  800c5c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800c5f:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c61:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800c64:	eb 17                	jmp    800c7d <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800c66:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c6a:	78 98                	js     800c04 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c6c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c6f:	eb a7                	jmp    800c18 <vprintfmt+0x70>
  800c71:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800c74:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800c7b:	eb 9b                	jmp    800c18 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800c7d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c81:	79 95                	jns    800c18 <vprintfmt+0x70>
  800c83:	eb 8b                	jmp    800c10 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800c85:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c86:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800c89:	eb 8d                	jmp    800c18 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800c8b:	8b 45 14             	mov    0x14(%ebp),%eax
  800c8e:	8d 50 04             	lea    0x4(%eax),%edx
  800c91:	89 55 14             	mov    %edx,0x14(%ebp)
  800c94:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c98:	8b 00                	mov    (%eax),%eax
  800c9a:	89 04 24             	mov    %eax,(%esp)
  800c9d:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800ca3:	e9 23 ff ff ff       	jmp    800bcb <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800ca8:	8b 45 14             	mov    0x14(%ebp),%eax
  800cab:	8d 50 04             	lea    0x4(%eax),%edx
  800cae:	89 55 14             	mov    %edx,0x14(%ebp)
  800cb1:	8b 00                	mov    (%eax),%eax
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	79 02                	jns    800cb9 <vprintfmt+0x111>
  800cb7:	f7 d8                	neg    %eax
  800cb9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800cbb:	83 f8 09             	cmp    $0x9,%eax
  800cbe:	7f 0b                	jg     800ccb <vprintfmt+0x123>
  800cc0:	8b 04 85 c0 17 80 00 	mov    0x8017c0(,%eax,4),%eax
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	75 23                	jne    800cee <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800ccb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ccf:	c7 44 24 08 b6 15 80 	movl   $0x8015b6,0x8(%esp)
  800cd6:	00 
  800cd7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cde:	89 04 24             	mov    %eax,(%esp)
  800ce1:	e8 9a fe ff ff       	call   800b80 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ce6:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800ce9:	e9 dd fe ff ff       	jmp    800bcb <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800cee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cf2:	c7 44 24 08 bf 15 80 	movl   $0x8015bf,0x8(%esp)
  800cf9:	00 
  800cfa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	89 14 24             	mov    %edx,(%esp)
  800d04:	e8 77 fe ff ff       	call   800b80 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d09:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d0c:	e9 ba fe ff ff       	jmp    800bcb <vprintfmt+0x23>
  800d11:	89 f9                	mov    %edi,%ecx
  800d13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d19:	8b 45 14             	mov    0x14(%ebp),%eax
  800d1c:	8d 50 04             	lea    0x4(%eax),%edx
  800d1f:	89 55 14             	mov    %edx,0x14(%ebp)
  800d22:	8b 30                	mov    (%eax),%esi
  800d24:	85 f6                	test   %esi,%esi
  800d26:	75 05                	jne    800d2d <vprintfmt+0x185>
				p = "(null)";
  800d28:	be af 15 80 00       	mov    $0x8015af,%esi
			if (width > 0 && padc != '-')
  800d2d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800d31:	0f 8e 84 00 00 00    	jle    800dbb <vprintfmt+0x213>
  800d37:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800d3b:	74 7e                	je     800dbb <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800d3d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d41:	89 34 24             	mov    %esi,(%esp)
  800d44:	e8 5d 02 00 00       	call   800fa6 <strnlen>
  800d49:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800d4c:	29 c2                	sub    %eax,%edx
  800d4e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800d51:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800d55:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800d58:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800d5b:	89 de                	mov    %ebx,%esi
  800d5d:	89 d3                	mov    %edx,%ebx
  800d5f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d61:	eb 0b                	jmp    800d6e <vprintfmt+0x1c6>
					putch(padc, putdat);
  800d63:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d67:	89 3c 24             	mov    %edi,(%esp)
  800d6a:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d6d:	4b                   	dec    %ebx
  800d6e:	85 db                	test   %ebx,%ebx
  800d70:	7f f1                	jg     800d63 <vprintfmt+0x1bb>
  800d72:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800d75:	89 f3                	mov    %esi,%ebx
  800d77:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800d7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	79 05                	jns    800d86 <vprintfmt+0x1de>
  800d81:	b8 00 00 00 00       	mov    $0x0,%eax
  800d86:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d89:	29 c2                	sub    %eax,%edx
  800d8b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800d8e:	eb 2b                	jmp    800dbb <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800d90:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800d94:	74 18                	je     800dae <vprintfmt+0x206>
  800d96:	8d 50 e0             	lea    -0x20(%eax),%edx
  800d99:	83 fa 5e             	cmp    $0x5e,%edx
  800d9c:	76 10                	jbe    800dae <vprintfmt+0x206>
					putch('?', putdat);
  800d9e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800da2:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800da9:	ff 55 08             	call   *0x8(%ebp)
  800dac:	eb 0a                	jmp    800db8 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800dae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800db2:	89 04 24             	mov    %eax,(%esp)
  800db5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800db8:	ff 4d e4             	decl   -0x1c(%ebp)
  800dbb:	0f be 06             	movsbl (%esi),%eax
  800dbe:	46                   	inc    %esi
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	74 21                	je     800de4 <vprintfmt+0x23c>
  800dc3:	85 ff                	test   %edi,%edi
  800dc5:	78 c9                	js     800d90 <vprintfmt+0x1e8>
  800dc7:	4f                   	dec    %edi
  800dc8:	79 c6                	jns    800d90 <vprintfmt+0x1e8>
  800dca:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dcd:	89 de                	mov    %ebx,%esi
  800dcf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800dd2:	eb 18                	jmp    800dec <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800dd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dd8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800ddf:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800de1:	4b                   	dec    %ebx
  800de2:	eb 08                	jmp    800dec <vprintfmt+0x244>
  800de4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800de7:	89 de                	mov    %ebx,%esi
  800de9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800dec:	85 db                	test   %ebx,%ebx
  800dee:	7f e4                	jg     800dd4 <vprintfmt+0x22c>
  800df0:	89 7d 08             	mov    %edi,0x8(%ebp)
  800df3:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800df5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800df8:	e9 ce fd ff ff       	jmp    800bcb <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800dfd:	8d 45 14             	lea    0x14(%ebp),%eax
  800e00:	e8 2f fd ff ff       	call   800b34 <getint>
  800e05:	89 c6                	mov    %eax,%esi
  800e07:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800e09:	85 d2                	test   %edx,%edx
  800e0b:	78 07                	js     800e14 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800e0d:	be 0a 00 00 00       	mov    $0xa,%esi
  800e12:	eb 7e                	jmp    800e92 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800e14:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e18:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800e1f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800e22:	89 f0                	mov    %esi,%eax
  800e24:	89 fa                	mov    %edi,%edx
  800e26:	f7 d8                	neg    %eax
  800e28:	83 d2 00             	adc    $0x0,%edx
  800e2b:	f7 da                	neg    %edx
			}
			base = 10;
  800e2d:	be 0a 00 00 00       	mov    $0xa,%esi
  800e32:	eb 5e                	jmp    800e92 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800e34:	8d 45 14             	lea    0x14(%ebp),%eax
  800e37:	e8 be fc ff ff       	call   800afa <getuint>
			base = 10;
  800e3c:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800e41:	eb 4f                	jmp    800e92 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800e43:	8d 45 14             	lea    0x14(%ebp),%eax
  800e46:	e8 af fc ff ff       	call   800afa <getuint>
			base = 8;
  800e4b:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800e50:	eb 40                	jmp    800e92 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  800e52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e56:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800e5d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800e60:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e64:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800e6b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800e6e:	8b 45 14             	mov    0x14(%ebp),%eax
  800e71:	8d 50 04             	lea    0x4(%eax),%edx
  800e74:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800e77:	8b 00                	mov    (%eax),%eax
  800e79:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800e7e:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800e83:	eb 0d                	jmp    800e92 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800e85:	8d 45 14             	lea    0x14(%ebp),%eax
  800e88:	e8 6d fc ff ff       	call   800afa <getuint>
			base = 16;
  800e8d:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800e92:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800e96:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800e9a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800e9d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ea1:	89 74 24 08          	mov    %esi,0x8(%esp)
  800ea5:	89 04 24             	mov    %eax,(%esp)
  800ea8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800eac:	89 da                	mov    %ebx,%edx
  800eae:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb1:	e8 7a fb ff ff       	call   800a30 <printnum>
			break;
  800eb6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800eb9:	e9 0d fd ff ff       	jmp    800bcb <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  800ebe:	8d 45 14             	lea    0x14(%ebp),%eax
  800ec1:	e8 6e fc ff ff       	call   800b34 <getint>
  800ec6:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ecb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  800ece:	e9 f8 fc ff ff       	jmp    800bcb <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ed3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ed7:	89 04 24             	mov    %eax,(%esp)
  800eda:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800edd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ee0:	e9 e6 fc ff ff       	jmp    800bcb <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ee5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ee9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ef0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ef3:	eb 01                	jmp    800ef6 <vprintfmt+0x34e>
  800ef5:	4e                   	dec    %esi
  800ef6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800efa:	75 f9                	jne    800ef5 <vprintfmt+0x34d>
  800efc:	e9 ca fc ff ff       	jmp    800bcb <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800f01:	83 c4 4c             	add    $0x4c,%esp
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	83 ec 28             	sub    $0x28,%esp
  800f0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f12:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800f15:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f18:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800f1c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800f26:	85 c0                	test   %eax,%eax
  800f28:	74 30                	je     800f5a <vsnprintf+0x51>
  800f2a:	85 d2                	test   %edx,%edx
  800f2c:	7e 33                	jle    800f61 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f31:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f35:	8b 45 10             	mov    0x10(%ebp),%eax
  800f38:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f3c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f43:	c7 04 24 66 0b 80 00 	movl   $0x800b66,(%esp)
  800f4a:	e8 59 fc ff ff       	call   800ba8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f52:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f58:	eb 0c                	jmp    800f66 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800f5a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f5f:	eb 05                	jmp    800f66 <vsnprintf+0x5d>
  800f61:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800f66:	c9                   	leave  
  800f67:	c3                   	ret    

00800f68 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800f6e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800f71:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f75:	8b 45 10             	mov    0x10(%ebp),%eax
  800f78:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f83:	8b 45 08             	mov    0x8(%ebp),%eax
  800f86:	89 04 24             	mov    %eax,(%esp)
  800f89:	e8 7b ff ff ff       	call   800f09 <vsnprintf>
	va_end(ap);

	return rc;
}
  800f8e:	c9                   	leave  
  800f8f:	c3                   	ret    

00800f90 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800f96:	b8 00 00 00 00       	mov    $0x0,%eax
  800f9b:	eb 01                	jmp    800f9e <strlen+0xe>
		n++;
  800f9d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800f9e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800fa2:	75 f9                	jne    800f9d <strlen+0xd>
		n++;
	return n;
}
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    

00800fa6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800fac:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800faf:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb4:	eb 01                	jmp    800fb7 <strnlen+0x11>
		n++;
  800fb6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fb7:	39 d0                	cmp    %edx,%eax
  800fb9:	74 06                	je     800fc1 <strnlen+0x1b>
  800fbb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800fbf:	75 f5                	jne    800fb6 <strnlen+0x10>
		n++;
	return n;
}
  800fc1:	5d                   	pop    %ebp
  800fc2:	c3                   	ret    

00800fc3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	53                   	push   %ebx
  800fc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800fcd:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800fd5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800fd8:	42                   	inc    %edx
  800fd9:	84 c9                	test   %cl,%cl
  800fdb:	75 f5                	jne    800fd2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800fdd:	5b                   	pop    %ebx
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    

00800fe0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	53                   	push   %ebx
  800fe4:	83 ec 08             	sub    $0x8,%esp
  800fe7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800fea:	89 1c 24             	mov    %ebx,(%esp)
  800fed:	e8 9e ff ff ff       	call   800f90 <strlen>
	strcpy(dst + len, src);
  800ff2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ff5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ff9:	01 d8                	add    %ebx,%eax
  800ffb:	89 04 24             	mov    %eax,(%esp)
  800ffe:	e8 c0 ff ff ff       	call   800fc3 <strcpy>
	return dst;
}
  801003:	89 d8                	mov    %ebx,%eax
  801005:	83 c4 08             	add    $0x8,%esp
  801008:	5b                   	pop    %ebx
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    

0080100b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	56                   	push   %esi
  80100f:	53                   	push   %ebx
  801010:	8b 45 08             	mov    0x8(%ebp),%eax
  801013:	8b 55 0c             	mov    0xc(%ebp),%edx
  801016:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801019:	b9 00 00 00 00       	mov    $0x0,%ecx
  80101e:	eb 0c                	jmp    80102c <strncpy+0x21>
		*dst++ = *src;
  801020:	8a 1a                	mov    (%edx),%bl
  801022:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801025:	80 3a 01             	cmpb   $0x1,(%edx)
  801028:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80102b:	41                   	inc    %ecx
  80102c:	39 f1                	cmp    %esi,%ecx
  80102e:	75 f0                	jne    801020 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801030:	5b                   	pop    %ebx
  801031:	5e                   	pop    %esi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    

00801034 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	56                   	push   %esi
  801038:	53                   	push   %ebx
  801039:	8b 75 08             	mov    0x8(%ebp),%esi
  80103c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801042:	85 d2                	test   %edx,%edx
  801044:	75 0a                	jne    801050 <strlcpy+0x1c>
  801046:	89 f0                	mov    %esi,%eax
  801048:	eb 1a                	jmp    801064 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80104a:	88 18                	mov    %bl,(%eax)
  80104c:	40                   	inc    %eax
  80104d:	41                   	inc    %ecx
  80104e:	eb 02                	jmp    801052 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801050:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801052:	4a                   	dec    %edx
  801053:	74 0a                	je     80105f <strlcpy+0x2b>
  801055:	8a 19                	mov    (%ecx),%bl
  801057:	84 db                	test   %bl,%bl
  801059:	75 ef                	jne    80104a <strlcpy+0x16>
  80105b:	89 c2                	mov    %eax,%edx
  80105d:	eb 02                	jmp    801061 <strlcpy+0x2d>
  80105f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801061:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801064:	29 f0                	sub    %esi,%eax
}
  801066:	5b                   	pop    %ebx
  801067:	5e                   	pop    %esi
  801068:	5d                   	pop    %ebp
  801069:	c3                   	ret    

0080106a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801070:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801073:	eb 02                	jmp    801077 <strcmp+0xd>
		p++, q++;
  801075:	41                   	inc    %ecx
  801076:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801077:	8a 01                	mov    (%ecx),%al
  801079:	84 c0                	test   %al,%al
  80107b:	74 04                	je     801081 <strcmp+0x17>
  80107d:	3a 02                	cmp    (%edx),%al
  80107f:	74 f4                	je     801075 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801081:	0f b6 c0             	movzbl %al,%eax
  801084:	0f b6 12             	movzbl (%edx),%edx
  801087:	29 d0                	sub    %edx,%eax
}
  801089:	5d                   	pop    %ebp
  80108a:	c3                   	ret    

0080108b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	53                   	push   %ebx
  80108f:	8b 45 08             	mov    0x8(%ebp),%eax
  801092:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801095:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801098:	eb 03                	jmp    80109d <strncmp+0x12>
		n--, p++, q++;
  80109a:	4a                   	dec    %edx
  80109b:	40                   	inc    %eax
  80109c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80109d:	85 d2                	test   %edx,%edx
  80109f:	74 14                	je     8010b5 <strncmp+0x2a>
  8010a1:	8a 18                	mov    (%eax),%bl
  8010a3:	84 db                	test   %bl,%bl
  8010a5:	74 04                	je     8010ab <strncmp+0x20>
  8010a7:	3a 19                	cmp    (%ecx),%bl
  8010a9:	74 ef                	je     80109a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8010ab:	0f b6 00             	movzbl (%eax),%eax
  8010ae:	0f b6 11             	movzbl (%ecx),%edx
  8010b1:	29 d0                	sub    %edx,%eax
  8010b3:	eb 05                	jmp    8010ba <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8010b5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010ba:	5b                   	pop    %ebx
  8010bb:	5d                   	pop    %ebp
  8010bc:	c3                   	ret    

008010bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8010c6:	eb 05                	jmp    8010cd <strchr+0x10>
		if (*s == c)
  8010c8:	38 ca                	cmp    %cl,%dl
  8010ca:	74 0c                	je     8010d8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8010cc:	40                   	inc    %eax
  8010cd:	8a 10                	mov    (%eax),%dl
  8010cf:	84 d2                	test   %dl,%dl
  8010d1:	75 f5                	jne    8010c8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8010d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010d8:	5d                   	pop    %ebp
  8010d9:	c3                   	ret    

008010da <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8010e3:	eb 05                	jmp    8010ea <strfind+0x10>
		if (*s == c)
  8010e5:	38 ca                	cmp    %cl,%dl
  8010e7:	74 07                	je     8010f0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8010e9:	40                   	inc    %eax
  8010ea:	8a 10                	mov    (%eax),%dl
  8010ec:	84 d2                	test   %dl,%dl
  8010ee:	75 f5                	jne    8010e5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8010f0:	5d                   	pop    %ebp
  8010f1:	c3                   	ret    

008010f2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	57                   	push   %edi
  8010f6:	56                   	push   %esi
  8010f7:	53                   	push   %ebx
  8010f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801101:	85 c9                	test   %ecx,%ecx
  801103:	74 30                	je     801135 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801105:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80110b:	75 25                	jne    801132 <memset+0x40>
  80110d:	f6 c1 03             	test   $0x3,%cl
  801110:	75 20                	jne    801132 <memset+0x40>
		c &= 0xFF;
  801112:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801115:	89 d3                	mov    %edx,%ebx
  801117:	c1 e3 08             	shl    $0x8,%ebx
  80111a:	89 d6                	mov    %edx,%esi
  80111c:	c1 e6 18             	shl    $0x18,%esi
  80111f:	89 d0                	mov    %edx,%eax
  801121:	c1 e0 10             	shl    $0x10,%eax
  801124:	09 f0                	or     %esi,%eax
  801126:	09 d0                	or     %edx,%eax
  801128:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80112a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80112d:	fc                   	cld    
  80112e:	f3 ab                	rep stos %eax,%es:(%edi)
  801130:	eb 03                	jmp    801135 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801132:	fc                   	cld    
  801133:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801135:	89 f8                	mov    %edi,%eax
  801137:	5b                   	pop    %ebx
  801138:	5e                   	pop    %esi
  801139:	5f                   	pop    %edi
  80113a:	5d                   	pop    %ebp
  80113b:	c3                   	ret    

0080113c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	57                   	push   %edi
  801140:	56                   	push   %esi
  801141:	8b 45 08             	mov    0x8(%ebp),%eax
  801144:	8b 75 0c             	mov    0xc(%ebp),%esi
  801147:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80114a:	39 c6                	cmp    %eax,%esi
  80114c:	73 34                	jae    801182 <memmove+0x46>
  80114e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801151:	39 d0                	cmp    %edx,%eax
  801153:	73 2d                	jae    801182 <memmove+0x46>
		s += n;
		d += n;
  801155:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801158:	f6 c2 03             	test   $0x3,%dl
  80115b:	75 1b                	jne    801178 <memmove+0x3c>
  80115d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801163:	75 13                	jne    801178 <memmove+0x3c>
  801165:	f6 c1 03             	test   $0x3,%cl
  801168:	75 0e                	jne    801178 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80116a:	83 ef 04             	sub    $0x4,%edi
  80116d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801170:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801173:	fd                   	std    
  801174:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801176:	eb 07                	jmp    80117f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801178:	4f                   	dec    %edi
  801179:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80117c:	fd                   	std    
  80117d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80117f:	fc                   	cld    
  801180:	eb 20                	jmp    8011a2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801182:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801188:	75 13                	jne    80119d <memmove+0x61>
  80118a:	a8 03                	test   $0x3,%al
  80118c:	75 0f                	jne    80119d <memmove+0x61>
  80118e:	f6 c1 03             	test   $0x3,%cl
  801191:	75 0a                	jne    80119d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801193:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801196:	89 c7                	mov    %eax,%edi
  801198:	fc                   	cld    
  801199:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80119b:	eb 05                	jmp    8011a2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80119d:	89 c7                	mov    %eax,%edi
  80119f:	fc                   	cld    
  8011a0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8011a2:	5e                   	pop    %esi
  8011a3:	5f                   	pop    %edi
  8011a4:	5d                   	pop    %ebp
  8011a5:	c3                   	ret    

008011a6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8011ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8011af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8011bd:	89 04 24             	mov    %eax,(%esp)
  8011c0:	e8 77 ff ff ff       	call   80113c <memmove>
}
  8011c5:	c9                   	leave  
  8011c6:	c3                   	ret    

008011c7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	57                   	push   %edi
  8011cb:	56                   	push   %esi
  8011cc:	53                   	push   %ebx
  8011cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8011db:	eb 16                	jmp    8011f3 <memcmp+0x2c>
		if (*s1 != *s2)
  8011dd:	8a 04 17             	mov    (%edi,%edx,1),%al
  8011e0:	42                   	inc    %edx
  8011e1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8011e5:	38 c8                	cmp    %cl,%al
  8011e7:	74 0a                	je     8011f3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8011e9:	0f b6 c0             	movzbl %al,%eax
  8011ec:	0f b6 c9             	movzbl %cl,%ecx
  8011ef:	29 c8                	sub    %ecx,%eax
  8011f1:	eb 09                	jmp    8011fc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011f3:	39 da                	cmp    %ebx,%edx
  8011f5:	75 e6                	jne    8011dd <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8011f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011fc:	5b                   	pop    %ebx
  8011fd:	5e                   	pop    %esi
  8011fe:	5f                   	pop    %edi
  8011ff:	5d                   	pop    %ebp
  801200:	c3                   	ret    

00801201 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	8b 45 08             	mov    0x8(%ebp),%eax
  801207:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80120a:	89 c2                	mov    %eax,%edx
  80120c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80120f:	eb 05                	jmp    801216 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801211:	38 08                	cmp    %cl,(%eax)
  801213:	74 05                	je     80121a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801215:	40                   	inc    %eax
  801216:	39 d0                	cmp    %edx,%eax
  801218:	72 f7                	jb     801211 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80121a:	5d                   	pop    %ebp
  80121b:	c3                   	ret    

0080121c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	57                   	push   %edi
  801220:	56                   	push   %esi
  801221:	53                   	push   %ebx
  801222:	8b 55 08             	mov    0x8(%ebp),%edx
  801225:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801228:	eb 01                	jmp    80122b <strtol+0xf>
		s++;
  80122a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80122b:	8a 02                	mov    (%edx),%al
  80122d:	3c 20                	cmp    $0x20,%al
  80122f:	74 f9                	je     80122a <strtol+0xe>
  801231:	3c 09                	cmp    $0x9,%al
  801233:	74 f5                	je     80122a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801235:	3c 2b                	cmp    $0x2b,%al
  801237:	75 08                	jne    801241 <strtol+0x25>
		s++;
  801239:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80123a:	bf 00 00 00 00       	mov    $0x0,%edi
  80123f:	eb 13                	jmp    801254 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801241:	3c 2d                	cmp    $0x2d,%al
  801243:	75 0a                	jne    80124f <strtol+0x33>
		s++, neg = 1;
  801245:	8d 52 01             	lea    0x1(%edx),%edx
  801248:	bf 01 00 00 00       	mov    $0x1,%edi
  80124d:	eb 05                	jmp    801254 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80124f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801254:	85 db                	test   %ebx,%ebx
  801256:	74 05                	je     80125d <strtol+0x41>
  801258:	83 fb 10             	cmp    $0x10,%ebx
  80125b:	75 28                	jne    801285 <strtol+0x69>
  80125d:	8a 02                	mov    (%edx),%al
  80125f:	3c 30                	cmp    $0x30,%al
  801261:	75 10                	jne    801273 <strtol+0x57>
  801263:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801267:	75 0a                	jne    801273 <strtol+0x57>
		s += 2, base = 16;
  801269:	83 c2 02             	add    $0x2,%edx
  80126c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801271:	eb 12                	jmp    801285 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801273:	85 db                	test   %ebx,%ebx
  801275:	75 0e                	jne    801285 <strtol+0x69>
  801277:	3c 30                	cmp    $0x30,%al
  801279:	75 05                	jne    801280 <strtol+0x64>
		s++, base = 8;
  80127b:	42                   	inc    %edx
  80127c:	b3 08                	mov    $0x8,%bl
  80127e:	eb 05                	jmp    801285 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801280:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801285:	b8 00 00 00 00       	mov    $0x0,%eax
  80128a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80128c:	8a 0a                	mov    (%edx),%cl
  80128e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801291:	80 fb 09             	cmp    $0x9,%bl
  801294:	77 08                	ja     80129e <strtol+0x82>
			dig = *s - '0';
  801296:	0f be c9             	movsbl %cl,%ecx
  801299:	83 e9 30             	sub    $0x30,%ecx
  80129c:	eb 1e                	jmp    8012bc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80129e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8012a1:	80 fb 19             	cmp    $0x19,%bl
  8012a4:	77 08                	ja     8012ae <strtol+0x92>
			dig = *s - 'a' + 10;
  8012a6:	0f be c9             	movsbl %cl,%ecx
  8012a9:	83 e9 57             	sub    $0x57,%ecx
  8012ac:	eb 0e                	jmp    8012bc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8012ae:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8012b1:	80 fb 19             	cmp    $0x19,%bl
  8012b4:	77 12                	ja     8012c8 <strtol+0xac>
			dig = *s - 'A' + 10;
  8012b6:	0f be c9             	movsbl %cl,%ecx
  8012b9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8012bc:	39 f1                	cmp    %esi,%ecx
  8012be:	7d 0c                	jge    8012cc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8012c0:	42                   	inc    %edx
  8012c1:	0f af c6             	imul   %esi,%eax
  8012c4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8012c6:	eb c4                	jmp    80128c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8012c8:	89 c1                	mov    %eax,%ecx
  8012ca:	eb 02                	jmp    8012ce <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8012cc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8012ce:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8012d2:	74 05                	je     8012d9 <strtol+0xbd>
		*endptr = (char *) s;
  8012d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012d7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8012d9:	85 ff                	test   %edi,%edi
  8012db:	74 04                	je     8012e1 <strtol+0xc5>
  8012dd:	89 c8                	mov    %ecx,%eax
  8012df:	f7 d8                	neg    %eax
}
  8012e1:	5b                   	pop    %ebx
  8012e2:	5e                   	pop    %esi
  8012e3:	5f                   	pop    %edi
  8012e4:	5d                   	pop    %ebp
  8012e5:	c3                   	ret    
	...

008012e8 <__udivdi3>:
  8012e8:	55                   	push   %ebp
  8012e9:	57                   	push   %edi
  8012ea:	56                   	push   %esi
  8012eb:	83 ec 10             	sub    $0x10,%esp
  8012ee:	8b 74 24 20          	mov    0x20(%esp),%esi
  8012f2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8012f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012fa:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8012fe:	89 cd                	mov    %ecx,%ebp
  801300:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801304:	85 c0                	test   %eax,%eax
  801306:	75 2c                	jne    801334 <__udivdi3+0x4c>
  801308:	39 f9                	cmp    %edi,%ecx
  80130a:	77 68                	ja     801374 <__udivdi3+0x8c>
  80130c:	85 c9                	test   %ecx,%ecx
  80130e:	75 0b                	jne    80131b <__udivdi3+0x33>
  801310:	b8 01 00 00 00       	mov    $0x1,%eax
  801315:	31 d2                	xor    %edx,%edx
  801317:	f7 f1                	div    %ecx
  801319:	89 c1                	mov    %eax,%ecx
  80131b:	31 d2                	xor    %edx,%edx
  80131d:	89 f8                	mov    %edi,%eax
  80131f:	f7 f1                	div    %ecx
  801321:	89 c7                	mov    %eax,%edi
  801323:	89 f0                	mov    %esi,%eax
  801325:	f7 f1                	div    %ecx
  801327:	89 c6                	mov    %eax,%esi
  801329:	89 f0                	mov    %esi,%eax
  80132b:	89 fa                	mov    %edi,%edx
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	5e                   	pop    %esi
  801331:	5f                   	pop    %edi
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    
  801334:	39 f8                	cmp    %edi,%eax
  801336:	77 2c                	ja     801364 <__udivdi3+0x7c>
  801338:	0f bd f0             	bsr    %eax,%esi
  80133b:	83 f6 1f             	xor    $0x1f,%esi
  80133e:	75 4c                	jne    80138c <__udivdi3+0xa4>
  801340:	39 f8                	cmp    %edi,%eax
  801342:	bf 00 00 00 00       	mov    $0x0,%edi
  801347:	72 0a                	jb     801353 <__udivdi3+0x6b>
  801349:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80134d:	0f 87 ad 00 00 00    	ja     801400 <__udivdi3+0x118>
  801353:	be 01 00 00 00       	mov    $0x1,%esi
  801358:	89 f0                	mov    %esi,%eax
  80135a:	89 fa                	mov    %edi,%edx
  80135c:	83 c4 10             	add    $0x10,%esp
  80135f:	5e                   	pop    %esi
  801360:	5f                   	pop    %edi
  801361:	5d                   	pop    %ebp
  801362:	c3                   	ret    
  801363:	90                   	nop
  801364:	31 ff                	xor    %edi,%edi
  801366:	31 f6                	xor    %esi,%esi
  801368:	89 f0                	mov    %esi,%eax
  80136a:	89 fa                	mov    %edi,%edx
  80136c:	83 c4 10             	add    $0x10,%esp
  80136f:	5e                   	pop    %esi
  801370:	5f                   	pop    %edi
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    
  801373:	90                   	nop
  801374:	89 fa                	mov    %edi,%edx
  801376:	89 f0                	mov    %esi,%eax
  801378:	f7 f1                	div    %ecx
  80137a:	89 c6                	mov    %eax,%esi
  80137c:	31 ff                	xor    %edi,%edi
  80137e:	89 f0                	mov    %esi,%eax
  801380:	89 fa                	mov    %edi,%edx
  801382:	83 c4 10             	add    $0x10,%esp
  801385:	5e                   	pop    %esi
  801386:	5f                   	pop    %edi
  801387:	5d                   	pop    %ebp
  801388:	c3                   	ret    
  801389:	8d 76 00             	lea    0x0(%esi),%esi
  80138c:	89 f1                	mov    %esi,%ecx
  80138e:	d3 e0                	shl    %cl,%eax
  801390:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801394:	b8 20 00 00 00       	mov    $0x20,%eax
  801399:	29 f0                	sub    %esi,%eax
  80139b:	89 ea                	mov    %ebp,%edx
  80139d:	88 c1                	mov    %al,%cl
  80139f:	d3 ea                	shr    %cl,%edx
  8013a1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8013a5:	09 ca                	or     %ecx,%edx
  8013a7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013ab:	89 f1                	mov    %esi,%ecx
  8013ad:	d3 e5                	shl    %cl,%ebp
  8013af:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8013b3:	89 fd                	mov    %edi,%ebp
  8013b5:	88 c1                	mov    %al,%cl
  8013b7:	d3 ed                	shr    %cl,%ebp
  8013b9:	89 fa                	mov    %edi,%edx
  8013bb:	89 f1                	mov    %esi,%ecx
  8013bd:	d3 e2                	shl    %cl,%edx
  8013bf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013c3:	88 c1                	mov    %al,%cl
  8013c5:	d3 ef                	shr    %cl,%edi
  8013c7:	09 d7                	or     %edx,%edi
  8013c9:	89 f8                	mov    %edi,%eax
  8013cb:	89 ea                	mov    %ebp,%edx
  8013cd:	f7 74 24 08          	divl   0x8(%esp)
  8013d1:	89 d1                	mov    %edx,%ecx
  8013d3:	89 c7                	mov    %eax,%edi
  8013d5:	f7 64 24 0c          	mull   0xc(%esp)
  8013d9:	39 d1                	cmp    %edx,%ecx
  8013db:	72 17                	jb     8013f4 <__udivdi3+0x10c>
  8013dd:	74 09                	je     8013e8 <__udivdi3+0x100>
  8013df:	89 fe                	mov    %edi,%esi
  8013e1:	31 ff                	xor    %edi,%edi
  8013e3:	e9 41 ff ff ff       	jmp    801329 <__udivdi3+0x41>
  8013e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013ec:	89 f1                	mov    %esi,%ecx
  8013ee:	d3 e2                	shl    %cl,%edx
  8013f0:	39 c2                	cmp    %eax,%edx
  8013f2:	73 eb                	jae    8013df <__udivdi3+0xf7>
  8013f4:	8d 77 ff             	lea    -0x1(%edi),%esi
  8013f7:	31 ff                	xor    %edi,%edi
  8013f9:	e9 2b ff ff ff       	jmp    801329 <__udivdi3+0x41>
  8013fe:	66 90                	xchg   %ax,%ax
  801400:	31 f6                	xor    %esi,%esi
  801402:	e9 22 ff ff ff       	jmp    801329 <__udivdi3+0x41>
	...

00801408 <__umoddi3>:
  801408:	55                   	push   %ebp
  801409:	57                   	push   %edi
  80140a:	56                   	push   %esi
  80140b:	83 ec 20             	sub    $0x20,%esp
  80140e:	8b 44 24 30          	mov    0x30(%esp),%eax
  801412:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801416:	89 44 24 14          	mov    %eax,0x14(%esp)
  80141a:	8b 74 24 34          	mov    0x34(%esp),%esi
  80141e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801422:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801426:	89 c7                	mov    %eax,%edi
  801428:	89 f2                	mov    %esi,%edx
  80142a:	85 ed                	test   %ebp,%ebp
  80142c:	75 16                	jne    801444 <__umoddi3+0x3c>
  80142e:	39 f1                	cmp    %esi,%ecx
  801430:	0f 86 a6 00 00 00    	jbe    8014dc <__umoddi3+0xd4>
  801436:	f7 f1                	div    %ecx
  801438:	89 d0                	mov    %edx,%eax
  80143a:	31 d2                	xor    %edx,%edx
  80143c:	83 c4 20             	add    $0x20,%esp
  80143f:	5e                   	pop    %esi
  801440:	5f                   	pop    %edi
  801441:	5d                   	pop    %ebp
  801442:	c3                   	ret    
  801443:	90                   	nop
  801444:	39 f5                	cmp    %esi,%ebp
  801446:	0f 87 ac 00 00 00    	ja     8014f8 <__umoddi3+0xf0>
  80144c:	0f bd c5             	bsr    %ebp,%eax
  80144f:	83 f0 1f             	xor    $0x1f,%eax
  801452:	89 44 24 10          	mov    %eax,0x10(%esp)
  801456:	0f 84 a8 00 00 00    	je     801504 <__umoddi3+0xfc>
  80145c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801460:	d3 e5                	shl    %cl,%ebp
  801462:	bf 20 00 00 00       	mov    $0x20,%edi
  801467:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80146b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80146f:	89 f9                	mov    %edi,%ecx
  801471:	d3 e8                	shr    %cl,%eax
  801473:	09 e8                	or     %ebp,%eax
  801475:	89 44 24 18          	mov    %eax,0x18(%esp)
  801479:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80147d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801481:	d3 e0                	shl    %cl,%eax
  801483:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801487:	89 f2                	mov    %esi,%edx
  801489:	d3 e2                	shl    %cl,%edx
  80148b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80148f:	d3 e0                	shl    %cl,%eax
  801491:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801495:	8b 44 24 14          	mov    0x14(%esp),%eax
  801499:	89 f9                	mov    %edi,%ecx
  80149b:	d3 e8                	shr    %cl,%eax
  80149d:	09 d0                	or     %edx,%eax
  80149f:	d3 ee                	shr    %cl,%esi
  8014a1:	89 f2                	mov    %esi,%edx
  8014a3:	f7 74 24 18          	divl   0x18(%esp)
  8014a7:	89 d6                	mov    %edx,%esi
  8014a9:	f7 64 24 0c          	mull   0xc(%esp)
  8014ad:	89 c5                	mov    %eax,%ebp
  8014af:	89 d1                	mov    %edx,%ecx
  8014b1:	39 d6                	cmp    %edx,%esi
  8014b3:	72 67                	jb     80151c <__umoddi3+0x114>
  8014b5:	74 75                	je     80152c <__umoddi3+0x124>
  8014b7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8014bb:	29 e8                	sub    %ebp,%eax
  8014bd:	19 ce                	sbb    %ecx,%esi
  8014bf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014c3:	d3 e8                	shr    %cl,%eax
  8014c5:	89 f2                	mov    %esi,%edx
  8014c7:	89 f9                	mov    %edi,%ecx
  8014c9:	d3 e2                	shl    %cl,%edx
  8014cb:	09 d0                	or     %edx,%eax
  8014cd:	89 f2                	mov    %esi,%edx
  8014cf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014d3:	d3 ea                	shr    %cl,%edx
  8014d5:	83 c4 20             	add    $0x20,%esp
  8014d8:	5e                   	pop    %esi
  8014d9:	5f                   	pop    %edi
  8014da:	5d                   	pop    %ebp
  8014db:	c3                   	ret    
  8014dc:	85 c9                	test   %ecx,%ecx
  8014de:	75 0b                	jne    8014eb <__umoddi3+0xe3>
  8014e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e5:	31 d2                	xor    %edx,%edx
  8014e7:	f7 f1                	div    %ecx
  8014e9:	89 c1                	mov    %eax,%ecx
  8014eb:	89 f0                	mov    %esi,%eax
  8014ed:	31 d2                	xor    %edx,%edx
  8014ef:	f7 f1                	div    %ecx
  8014f1:	89 f8                	mov    %edi,%eax
  8014f3:	e9 3e ff ff ff       	jmp    801436 <__umoddi3+0x2e>
  8014f8:	89 f2                	mov    %esi,%edx
  8014fa:	83 c4 20             	add    $0x20,%esp
  8014fd:	5e                   	pop    %esi
  8014fe:	5f                   	pop    %edi
  8014ff:	5d                   	pop    %ebp
  801500:	c3                   	ret    
  801501:	8d 76 00             	lea    0x0(%esi),%esi
  801504:	39 f5                	cmp    %esi,%ebp
  801506:	72 04                	jb     80150c <__umoddi3+0x104>
  801508:	39 f9                	cmp    %edi,%ecx
  80150a:	77 06                	ja     801512 <__umoddi3+0x10a>
  80150c:	89 f2                	mov    %esi,%edx
  80150e:	29 cf                	sub    %ecx,%edi
  801510:	19 ea                	sbb    %ebp,%edx
  801512:	89 f8                	mov    %edi,%eax
  801514:	83 c4 20             	add    $0x20,%esp
  801517:	5e                   	pop    %esi
  801518:	5f                   	pop    %edi
  801519:	5d                   	pop    %ebp
  80151a:	c3                   	ret    
  80151b:	90                   	nop
  80151c:	89 d1                	mov    %edx,%ecx
  80151e:	89 c5                	mov    %eax,%ebp
  801520:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801524:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801528:	eb 8d                	jmp    8014b7 <__umoddi3+0xaf>
  80152a:	66 90                	xchg   %ax,%ax
  80152c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801530:	72 ea                	jb     80151c <__umoddi3+0x114>
  801532:	89 f1                	mov    %esi,%ecx
  801534:	eb 81                	jmp    8014b7 <__umoddi3+0xaf>
