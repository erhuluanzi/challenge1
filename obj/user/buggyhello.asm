
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
  800068:	8d 14 80             	lea    (%eax,%eax,4),%edx
  80006b:	8d 14 90             	lea    (%eax,%edx,4),%edx
  80006e:	8d 04 50             	lea    (%eax,%edx,2),%eax
  800071:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  800078:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 f6                	test   %esi,%esi
  80007f:	7e 07                	jle    800088 <libmain+0x38>
		binaryname = argv[0];
  800081:	8b 03                	mov    (%ebx),%eax
  800083:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800088:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008c:	89 34 24             	mov    %esi,(%esp)
  80008f:	e8 a0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800094:	e8 07 00 00 00       	call   8000a0 <exit>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	5b                   	pop    %ebx
  80009d:	5e                   	pop    %esi
  80009e:	5d                   	pop    %ebp
  80009f:	c3                   	ret    

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
  80011f:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  800126:	00 
  800127:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012e:	00 
  80012f:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  800136:	e8 5d 02 00 00       	call   800398 <_panic>

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
  8001b1:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8001b8:	00 
  8001b9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c0:	00 
  8001c1:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  8001c8:	e8 cb 01 00 00       	call   800398 <_panic>

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
  800204:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800213:	00 
  800214:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  80021b:	e8 78 01 00 00       	call   800398 <_panic>

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
  800257:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  80025e:	00 
  80025f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800266:	00 
  800267:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  80026e:	e8 25 01 00 00       	call   800398 <_panic>

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
  8002aa:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8002b1:	00 
  8002b2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b9:	00 
  8002ba:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  8002c1:	e8 d2 00 00 00       	call   800398 <_panic>

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
  8002fd:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  800304:	00 
  800305:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80030c:	00 
  80030d:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  800314:	e8 7f 00 00 00       	call   800398 <_panic>

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
  800372:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  800379:	00 
  80037a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800381:	00 
  800382:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  800389:	e8 0a 00 00 00       	call   800398 <_panic>

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
	...

00800398 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
  80039d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003a3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8003a9:	e8 95 fd ff ff       	call   800143 <sys_getenvid>
  8003ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c4:	c7 04 24 f8 0f 80 00 	movl   $0x800ff8,(%esp)
  8003cb:	e8 c0 00 00 00       	call   800490 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d7:	89 04 24             	mov    %eax,(%esp)
  8003da:	e8 50 00 00 00       	call   80042f <vcprintf>
	cprintf("\n");
  8003df:	c7 04 24 1c 10 80 00 	movl   $0x80101c,(%esp)
  8003e6:	e8 a5 00 00 00       	call   800490 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003eb:	cc                   	int3   
  8003ec:	eb fd                	jmp    8003eb <_panic+0x53>
	...

008003f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	53                   	push   %ebx
  8003f4:	83 ec 14             	sub    $0x14,%esp
  8003f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003fa:	8b 03                	mov    (%ebx),%eax
  8003fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800403:	40                   	inc    %eax
  800404:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800406:	3d ff 00 00 00       	cmp    $0xff,%eax
  80040b:	75 19                	jne    800426 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80040d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800414:	00 
  800415:	8d 43 08             	lea    0x8(%ebx),%eax
  800418:	89 04 24             	mov    %eax,(%esp)
  80041b:	e8 94 fc ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  800420:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800426:	ff 43 04             	incl   0x4(%ebx)
}
  800429:	83 c4 14             	add    $0x14,%esp
  80042c:	5b                   	pop    %ebx
  80042d:	5d                   	pop    %ebp
  80042e:	c3                   	ret    

0080042f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800438:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80043f:	00 00 00 
	b.cnt = 0;
  800442:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800449:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80044c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80044f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800453:	8b 45 08             	mov    0x8(%ebp),%eax
  800456:	89 44 24 08          	mov    %eax,0x8(%esp)
  80045a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800460:	89 44 24 04          	mov    %eax,0x4(%esp)
  800464:	c7 04 24 f0 03 80 00 	movl   $0x8003f0,(%esp)
  80046b:	e8 b4 01 00 00       	call   800624 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800470:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800476:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800480:	89 04 24             	mov    %eax,(%esp)
  800483:	e8 2c fc ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  800488:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80048e:	c9                   	leave  
  80048f:	c3                   	ret    

00800490 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800496:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800499:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049d:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	e8 87 ff ff ff       	call   80042f <vcprintf>
	va_end(ap);

	return cnt;
}
  8004a8:	c9                   	leave  
  8004a9:	c3                   	ret    
	...

008004ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	57                   	push   %edi
  8004b0:	56                   	push   %esi
  8004b1:	53                   	push   %ebx
  8004b2:	83 ec 3c             	sub    $0x3c,%esp
  8004b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b8:	89 d7                	mov    %edx,%edi
  8004ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004c9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004cc:	85 c0                	test   %eax,%eax
  8004ce:	75 08                	jne    8004d8 <printnum+0x2c>
  8004d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004d6:	77 57                	ja     80052f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004d8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004dc:	4b                   	dec    %ebx
  8004dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004ec:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004f7:	00 
  8004f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004fb:	89 04 24             	mov    %eax,(%esp)
  8004fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800501:	89 44 24 04          	mov    %eax,0x4(%esp)
  800505:	e8 5a 08 00 00       	call   800d64 <__udivdi3>
  80050a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80050e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800512:	89 04 24             	mov    %eax,(%esp)
  800515:	89 54 24 04          	mov    %edx,0x4(%esp)
  800519:	89 fa                	mov    %edi,%edx
  80051b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051e:	e8 89 ff ff ff       	call   8004ac <printnum>
  800523:	eb 0f                	jmp    800534 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800525:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800529:	89 34 24             	mov    %esi,(%esp)
  80052c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80052f:	4b                   	dec    %ebx
  800530:	85 db                	test   %ebx,%ebx
  800532:	7f f1                	jg     800525 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800534:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800538:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80053c:	8b 45 10             	mov    0x10(%ebp),%eax
  80053f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800543:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80054a:	00 
  80054b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80054e:	89 04 24             	mov    %eax,(%esp)
  800551:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800554:	89 44 24 04          	mov    %eax,0x4(%esp)
  800558:	e8 27 09 00 00       	call   800e84 <__umoddi3>
  80055d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800561:	0f be 80 1e 10 80 00 	movsbl 0x80101e(%eax),%eax
  800568:	89 04 24             	mov    %eax,(%esp)
  80056b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80056e:	83 c4 3c             	add    $0x3c,%esp
  800571:	5b                   	pop    %ebx
  800572:	5e                   	pop    %esi
  800573:	5f                   	pop    %edi
  800574:	5d                   	pop    %ebp
  800575:	c3                   	ret    

00800576 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800576:	55                   	push   %ebp
  800577:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800579:	83 fa 01             	cmp    $0x1,%edx
  80057c:	7e 0e                	jle    80058c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80057e:	8b 10                	mov    (%eax),%edx
  800580:	8d 4a 08             	lea    0x8(%edx),%ecx
  800583:	89 08                	mov    %ecx,(%eax)
  800585:	8b 02                	mov    (%edx),%eax
  800587:	8b 52 04             	mov    0x4(%edx),%edx
  80058a:	eb 22                	jmp    8005ae <getuint+0x38>
	else if (lflag)
  80058c:	85 d2                	test   %edx,%edx
  80058e:	74 10                	je     8005a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800590:	8b 10                	mov    (%eax),%edx
  800592:	8d 4a 04             	lea    0x4(%edx),%ecx
  800595:	89 08                	mov    %ecx,(%eax)
  800597:	8b 02                	mov    (%edx),%eax
  800599:	ba 00 00 00 00       	mov    $0x0,%edx
  80059e:	eb 0e                	jmp    8005ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005a0:	8b 10                	mov    (%eax),%edx
  8005a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005a5:	89 08                	mov    %ecx,(%eax)
  8005a7:	8b 02                	mov    (%edx),%eax
  8005a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005ae:	5d                   	pop    %ebp
  8005af:	c3                   	ret    

008005b0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8005b0:	55                   	push   %ebp
  8005b1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005b3:	83 fa 01             	cmp    $0x1,%edx
  8005b6:	7e 0e                	jle    8005c6 <getint+0x16>
		return va_arg(*ap, long long);
  8005b8:	8b 10                	mov    (%eax),%edx
  8005ba:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005bd:	89 08                	mov    %ecx,(%eax)
  8005bf:	8b 02                	mov    (%edx),%eax
  8005c1:	8b 52 04             	mov    0x4(%edx),%edx
  8005c4:	eb 1a                	jmp    8005e0 <getint+0x30>
	else if (lflag)
  8005c6:	85 d2                	test   %edx,%edx
  8005c8:	74 0c                	je     8005d6 <getint+0x26>
		return va_arg(*ap, long);
  8005ca:	8b 10                	mov    (%eax),%edx
  8005cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005cf:	89 08                	mov    %ecx,(%eax)
  8005d1:	8b 02                	mov    (%edx),%eax
  8005d3:	99                   	cltd   
  8005d4:	eb 0a                	jmp    8005e0 <getint+0x30>
	else
		return va_arg(*ap, int);
  8005d6:	8b 10                	mov    (%eax),%edx
  8005d8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005db:	89 08                	mov    %ecx,(%eax)
  8005dd:	8b 02                	mov    (%edx),%eax
  8005df:	99                   	cltd   
}
  8005e0:	5d                   	pop    %ebp
  8005e1:	c3                   	ret    

008005e2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005e2:	55                   	push   %ebp
  8005e3:	89 e5                	mov    %esp,%ebp
  8005e5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005e8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005eb:	8b 10                	mov    (%eax),%edx
  8005ed:	3b 50 04             	cmp    0x4(%eax),%edx
  8005f0:	73 08                	jae    8005fa <sprintputch+0x18>
		*b->buf++ = ch;
  8005f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005f5:	88 0a                	mov    %cl,(%edx)
  8005f7:	42                   	inc    %edx
  8005f8:	89 10                	mov    %edx,(%eax)
}
  8005fa:	5d                   	pop    %ebp
  8005fb:	c3                   	ret    

008005fc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005fc:	55                   	push   %ebp
  8005fd:	89 e5                	mov    %esp,%ebp
  8005ff:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800602:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800605:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800609:	8b 45 10             	mov    0x10(%ebp),%eax
  80060c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800610:	8b 45 0c             	mov    0xc(%ebp),%eax
  800613:	89 44 24 04          	mov    %eax,0x4(%esp)
  800617:	8b 45 08             	mov    0x8(%ebp),%eax
  80061a:	89 04 24             	mov    %eax,(%esp)
  80061d:	e8 02 00 00 00       	call   800624 <vprintfmt>
	va_end(ap);
}
  800622:	c9                   	leave  
  800623:	c3                   	ret    

00800624 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800624:	55                   	push   %ebp
  800625:	89 e5                	mov    %esp,%ebp
  800627:	57                   	push   %edi
  800628:	56                   	push   %esi
  800629:	53                   	push   %ebx
  80062a:	83 ec 4c             	sub    $0x4c,%esp
  80062d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800630:	8b 75 10             	mov    0x10(%ebp),%esi
  800633:	eb 12                	jmp    800647 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800635:	85 c0                	test   %eax,%eax
  800637:	0f 84 40 03 00 00    	je     80097d <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  80063d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800641:	89 04 24             	mov    %eax,(%esp)
  800644:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800647:	0f b6 06             	movzbl (%esi),%eax
  80064a:	46                   	inc    %esi
  80064b:	83 f8 25             	cmp    $0x25,%eax
  80064e:	75 e5                	jne    800635 <vprintfmt+0x11>
  800650:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800654:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80065b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800660:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800667:	ba 00 00 00 00       	mov    $0x0,%edx
  80066c:	eb 26                	jmp    800694 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066e:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800671:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800675:	eb 1d                	jmp    800694 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800677:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80067a:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80067e:	eb 14                	jmp    800694 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800680:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800683:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80068a:	eb 08                	jmp    800694 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80068c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80068f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800694:	0f b6 06             	movzbl (%esi),%eax
  800697:	8d 4e 01             	lea    0x1(%esi),%ecx
  80069a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80069d:	8a 0e                	mov    (%esi),%cl
  80069f:	83 e9 23             	sub    $0x23,%ecx
  8006a2:	80 f9 55             	cmp    $0x55,%cl
  8006a5:	0f 87 b6 02 00 00    	ja     800961 <vprintfmt+0x33d>
  8006ab:	0f b6 c9             	movzbl %cl,%ecx
  8006ae:	ff 24 8d e0 10 80 00 	jmp    *0x8010e0(,%ecx,4)
  8006b5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006b8:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006bd:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  8006c0:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  8006c4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006c7:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8006ca:	83 f9 09             	cmp    $0x9,%ecx
  8006cd:	77 2a                	ja     8006f9 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006cf:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006d0:	eb eb                	jmp    8006bd <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8d 48 04             	lea    0x4(%eax),%ecx
  8006d8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006db:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006e0:	eb 17                	jmp    8006f9 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006e6:	78 98                	js     800680 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006eb:	eb a7                	jmp    800694 <vprintfmt+0x70>
  8006ed:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006f0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006f7:	eb 9b                	jmp    800694 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006f9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006fd:	79 95                	jns    800694 <vprintfmt+0x70>
  8006ff:	eb 8b                	jmp    80068c <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800701:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800702:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800705:	eb 8d                	jmp    800694 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	8d 50 04             	lea    0x4(%eax),%edx
  80070d:	89 55 14             	mov    %edx,0x14(%ebp)
  800710:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800714:	8b 00                	mov    (%eax),%eax
  800716:	89 04 24             	mov    %eax,(%esp)
  800719:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80071f:	e9 23 ff ff ff       	jmp    800647 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8d 50 04             	lea    0x4(%eax),%edx
  80072a:	89 55 14             	mov    %edx,0x14(%ebp)
  80072d:	8b 00                	mov    (%eax),%eax
  80072f:	85 c0                	test   %eax,%eax
  800731:	79 02                	jns    800735 <vprintfmt+0x111>
  800733:	f7 d8                	neg    %eax
  800735:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800737:	83 f8 09             	cmp    $0x9,%eax
  80073a:	7f 0b                	jg     800747 <vprintfmt+0x123>
  80073c:	8b 04 85 40 12 80 00 	mov    0x801240(,%eax,4),%eax
  800743:	85 c0                	test   %eax,%eax
  800745:	75 23                	jne    80076a <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800747:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80074b:	c7 44 24 08 36 10 80 	movl   $0x801036,0x8(%esp)
  800752:	00 
  800753:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800757:	8b 45 08             	mov    0x8(%ebp),%eax
  80075a:	89 04 24             	mov    %eax,(%esp)
  80075d:	e8 9a fe ff ff       	call   8005fc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800762:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800765:	e9 dd fe ff ff       	jmp    800647 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80076a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076e:	c7 44 24 08 3f 10 80 	movl   $0x80103f,0x8(%esp)
  800775:	00 
  800776:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077a:	8b 55 08             	mov    0x8(%ebp),%edx
  80077d:	89 14 24             	mov    %edx,(%esp)
  800780:	e8 77 fe ff ff       	call   8005fc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800785:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800788:	e9 ba fe ff ff       	jmp    800647 <vprintfmt+0x23>
  80078d:	89 f9                	mov    %edi,%ecx
  80078f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800792:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	8d 50 04             	lea    0x4(%eax),%edx
  80079b:	89 55 14             	mov    %edx,0x14(%ebp)
  80079e:	8b 30                	mov    (%eax),%esi
  8007a0:	85 f6                	test   %esi,%esi
  8007a2:	75 05                	jne    8007a9 <vprintfmt+0x185>
				p = "(null)";
  8007a4:	be 2f 10 80 00       	mov    $0x80102f,%esi
			if (width > 0 && padc != '-')
  8007a9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007ad:	0f 8e 84 00 00 00    	jle    800837 <vprintfmt+0x213>
  8007b3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007b7:	74 7e                	je     800837 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007b9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007bd:	89 34 24             	mov    %esi,(%esp)
  8007c0:	e8 5d 02 00 00       	call   800a22 <strnlen>
  8007c5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007c8:	29 c2                	sub    %eax,%edx
  8007ca:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8007cd:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8007d1:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007d4:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007d7:	89 de                	mov    %ebx,%esi
  8007d9:	89 d3                	mov    %edx,%ebx
  8007db:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007dd:	eb 0b                	jmp    8007ea <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e3:	89 3c 24             	mov    %edi,(%esp)
  8007e6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007e9:	4b                   	dec    %ebx
  8007ea:	85 db                	test   %ebx,%ebx
  8007ec:	7f f1                	jg     8007df <vprintfmt+0x1bb>
  8007ee:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007f1:	89 f3                	mov    %esi,%ebx
  8007f3:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007f9:	85 c0                	test   %eax,%eax
  8007fb:	79 05                	jns    800802 <vprintfmt+0x1de>
  8007fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800802:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800805:	29 c2                	sub    %eax,%edx
  800807:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80080a:	eb 2b                	jmp    800837 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80080c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800810:	74 18                	je     80082a <vprintfmt+0x206>
  800812:	8d 50 e0             	lea    -0x20(%eax),%edx
  800815:	83 fa 5e             	cmp    $0x5e,%edx
  800818:	76 10                	jbe    80082a <vprintfmt+0x206>
					putch('?', putdat);
  80081a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80081e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800825:	ff 55 08             	call   *0x8(%ebp)
  800828:	eb 0a                	jmp    800834 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80082a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80082e:	89 04 24             	mov    %eax,(%esp)
  800831:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800834:	ff 4d e4             	decl   -0x1c(%ebp)
  800837:	0f be 06             	movsbl (%esi),%eax
  80083a:	46                   	inc    %esi
  80083b:	85 c0                	test   %eax,%eax
  80083d:	74 21                	je     800860 <vprintfmt+0x23c>
  80083f:	85 ff                	test   %edi,%edi
  800841:	78 c9                	js     80080c <vprintfmt+0x1e8>
  800843:	4f                   	dec    %edi
  800844:	79 c6                	jns    80080c <vprintfmt+0x1e8>
  800846:	8b 7d 08             	mov    0x8(%ebp),%edi
  800849:	89 de                	mov    %ebx,%esi
  80084b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80084e:	eb 18                	jmp    800868 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800850:	89 74 24 04          	mov    %esi,0x4(%esp)
  800854:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80085b:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80085d:	4b                   	dec    %ebx
  80085e:	eb 08                	jmp    800868 <vprintfmt+0x244>
  800860:	8b 7d 08             	mov    0x8(%ebp),%edi
  800863:	89 de                	mov    %ebx,%esi
  800865:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800868:	85 db                	test   %ebx,%ebx
  80086a:	7f e4                	jg     800850 <vprintfmt+0x22c>
  80086c:	89 7d 08             	mov    %edi,0x8(%ebp)
  80086f:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800871:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800874:	e9 ce fd ff ff       	jmp    800647 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800879:	8d 45 14             	lea    0x14(%ebp),%eax
  80087c:	e8 2f fd ff ff       	call   8005b0 <getint>
  800881:	89 c6                	mov    %eax,%esi
  800883:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800885:	85 d2                	test   %edx,%edx
  800887:	78 07                	js     800890 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800889:	be 0a 00 00 00       	mov    $0xa,%esi
  80088e:	eb 7e                	jmp    80090e <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800890:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800894:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80089b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80089e:	89 f0                	mov    %esi,%eax
  8008a0:	89 fa                	mov    %edi,%edx
  8008a2:	f7 d8                	neg    %eax
  8008a4:	83 d2 00             	adc    $0x0,%edx
  8008a7:	f7 da                	neg    %edx
			}
			base = 10;
  8008a9:	be 0a 00 00 00       	mov    $0xa,%esi
  8008ae:	eb 5e                	jmp    80090e <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008b0:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b3:	e8 be fc ff ff       	call   800576 <getuint>
			base = 10;
  8008b8:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8008bd:	eb 4f                	jmp    80090e <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8008bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c2:	e8 af fc ff ff       	call   800576 <getuint>
			base = 8;
  8008c7:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8008cc:	eb 40                	jmp    80090e <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  8008ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008d9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008e7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ed:	8d 50 04             	lea    0x4(%eax),%edx
  8008f0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008f3:	8b 00                	mov    (%eax),%eax
  8008f5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008fa:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8008ff:	eb 0d                	jmp    80090e <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800901:	8d 45 14             	lea    0x14(%ebp),%eax
  800904:	e8 6d fc ff ff       	call   800576 <getuint>
			base = 16;
  800909:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80090e:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800912:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800916:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800919:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80091d:	89 74 24 08          	mov    %esi,0x8(%esp)
  800921:	89 04 24             	mov    %eax,(%esp)
  800924:	89 54 24 04          	mov    %edx,0x4(%esp)
  800928:	89 da                	mov    %ebx,%edx
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	e8 7a fb ff ff       	call   8004ac <printnum>
			break;
  800932:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800935:	e9 0d fd ff ff       	jmp    800647 <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  80093a:	8d 45 14             	lea    0x14(%ebp),%eax
  80093d:	e8 6e fc ff ff       	call   8005b0 <getint>
  800942:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800947:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  80094a:	e9 f8 fc ff ff       	jmp    800647 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80094f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800953:	89 04 24             	mov    %eax,(%esp)
  800956:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800959:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80095c:	e9 e6 fc ff ff       	jmp    800647 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800961:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800965:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80096c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80096f:	eb 01                	jmp    800972 <vprintfmt+0x34e>
  800971:	4e                   	dec    %esi
  800972:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800976:	75 f9                	jne    800971 <vprintfmt+0x34d>
  800978:	e9 ca fc ff ff       	jmp    800647 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80097d:	83 c4 4c             	add    $0x4c,%esp
  800980:	5b                   	pop    %ebx
  800981:	5e                   	pop    %esi
  800982:	5f                   	pop    %edi
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	83 ec 28             	sub    $0x28,%esp
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800991:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800994:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800998:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80099b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009a2:	85 c0                	test   %eax,%eax
  8009a4:	74 30                	je     8009d6 <vsnprintf+0x51>
  8009a6:	85 d2                	test   %edx,%edx
  8009a8:	7e 33                	jle    8009dd <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bf:	c7 04 24 e2 05 80 00 	movl   $0x8005e2,(%esp)
  8009c6:	e8 59 fc ff ff       	call   800624 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009ce:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d4:	eb 0c                	jmp    8009e2 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009db:	eb 05                	jmp    8009e2 <vsnprintf+0x5d>
  8009dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009e2:	c9                   	leave  
  8009e3:	c3                   	ret    

008009e4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009ea:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800a02:	89 04 24             	mov    %eax,(%esp)
  800a05:	e8 7b ff ff ff       	call   800985 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a0a:	c9                   	leave  
  800a0b:	c3                   	ret    

00800a0c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a12:	b8 00 00 00 00       	mov    $0x0,%eax
  800a17:	eb 01                	jmp    800a1a <strlen+0xe>
		n++;
  800a19:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a1a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a1e:	75 f9                	jne    800a19 <strlen+0xd>
		n++;
	return n;
}
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a28:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a30:	eb 01                	jmp    800a33 <strnlen+0x11>
		n++;
  800a32:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a33:	39 d0                	cmp    %edx,%eax
  800a35:	74 06                	je     800a3d <strnlen+0x1b>
  800a37:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a3b:	75 f5                	jne    800a32 <strnlen+0x10>
		n++;
	return n;
}
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	53                   	push   %ebx
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a49:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a51:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a54:	42                   	inc    %edx
  800a55:	84 c9                	test   %cl,%cl
  800a57:	75 f5                	jne    800a4e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a59:	5b                   	pop    %ebx
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	53                   	push   %ebx
  800a60:	83 ec 08             	sub    $0x8,%esp
  800a63:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a66:	89 1c 24             	mov    %ebx,(%esp)
  800a69:	e8 9e ff ff ff       	call   800a0c <strlen>
	strcpy(dst + len, src);
  800a6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a71:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a75:	01 d8                	add    %ebx,%eax
  800a77:	89 04 24             	mov    %eax,(%esp)
  800a7a:	e8 c0 ff ff ff       	call   800a3f <strcpy>
	return dst;
}
  800a7f:	89 d8                	mov    %ebx,%eax
  800a81:	83 c4 08             	add    $0x8,%esp
  800a84:	5b                   	pop    %ebx
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
  800a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a92:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a9a:	eb 0c                	jmp    800aa8 <strncpy+0x21>
		*dst++ = *src;
  800a9c:	8a 1a                	mov    (%edx),%bl
  800a9e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aa1:	80 3a 01             	cmpb   $0x1,(%edx)
  800aa4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa7:	41                   	inc    %ecx
  800aa8:	39 f1                	cmp    %esi,%ecx
  800aaa:	75 f0                	jne    800a9c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
  800ab5:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800abb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800abe:	85 d2                	test   %edx,%edx
  800ac0:	75 0a                	jne    800acc <strlcpy+0x1c>
  800ac2:	89 f0                	mov    %esi,%eax
  800ac4:	eb 1a                	jmp    800ae0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ac6:	88 18                	mov    %bl,(%eax)
  800ac8:	40                   	inc    %eax
  800ac9:	41                   	inc    %ecx
  800aca:	eb 02                	jmp    800ace <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800acc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800ace:	4a                   	dec    %edx
  800acf:	74 0a                	je     800adb <strlcpy+0x2b>
  800ad1:	8a 19                	mov    (%ecx),%bl
  800ad3:	84 db                	test   %bl,%bl
  800ad5:	75 ef                	jne    800ac6 <strlcpy+0x16>
  800ad7:	89 c2                	mov    %eax,%edx
  800ad9:	eb 02                	jmp    800add <strlcpy+0x2d>
  800adb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800add:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ae0:	29 f0                	sub    %esi,%eax
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aec:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aef:	eb 02                	jmp    800af3 <strcmp+0xd>
		p++, q++;
  800af1:	41                   	inc    %ecx
  800af2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800af3:	8a 01                	mov    (%ecx),%al
  800af5:	84 c0                	test   %al,%al
  800af7:	74 04                	je     800afd <strcmp+0x17>
  800af9:	3a 02                	cmp    (%edx),%al
  800afb:	74 f4                	je     800af1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800afd:	0f b6 c0             	movzbl %al,%eax
  800b00:	0f b6 12             	movzbl (%edx),%edx
  800b03:	29 d0                	sub    %edx,%eax
}
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	53                   	push   %ebx
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b11:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b14:	eb 03                	jmp    800b19 <strncmp+0x12>
		n--, p++, q++;
  800b16:	4a                   	dec    %edx
  800b17:	40                   	inc    %eax
  800b18:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b19:	85 d2                	test   %edx,%edx
  800b1b:	74 14                	je     800b31 <strncmp+0x2a>
  800b1d:	8a 18                	mov    (%eax),%bl
  800b1f:	84 db                	test   %bl,%bl
  800b21:	74 04                	je     800b27 <strncmp+0x20>
  800b23:	3a 19                	cmp    (%ecx),%bl
  800b25:	74 ef                	je     800b16 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b27:	0f b6 00             	movzbl (%eax),%eax
  800b2a:	0f b6 11             	movzbl (%ecx),%edx
  800b2d:	29 d0                	sub    %edx,%eax
  800b2f:	eb 05                	jmp    800b36 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b31:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b36:	5b                   	pop    %ebx
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b42:	eb 05                	jmp    800b49 <strchr+0x10>
		if (*s == c)
  800b44:	38 ca                	cmp    %cl,%dl
  800b46:	74 0c                	je     800b54 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b48:	40                   	inc    %eax
  800b49:	8a 10                	mov    (%eax),%dl
  800b4b:	84 d2                	test   %dl,%dl
  800b4d:	75 f5                	jne    800b44 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b5f:	eb 05                	jmp    800b66 <strfind+0x10>
		if (*s == c)
  800b61:	38 ca                	cmp    %cl,%dl
  800b63:	74 07                	je     800b6c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b65:	40                   	inc    %eax
  800b66:	8a 10                	mov    (%eax),%dl
  800b68:	84 d2                	test   %dl,%dl
  800b6a:	75 f5                	jne    800b61 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b7d:	85 c9                	test   %ecx,%ecx
  800b7f:	74 30                	je     800bb1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b81:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b87:	75 25                	jne    800bae <memset+0x40>
  800b89:	f6 c1 03             	test   $0x3,%cl
  800b8c:	75 20                	jne    800bae <memset+0x40>
		c &= 0xFF;
  800b8e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b91:	89 d3                	mov    %edx,%ebx
  800b93:	c1 e3 08             	shl    $0x8,%ebx
  800b96:	89 d6                	mov    %edx,%esi
  800b98:	c1 e6 18             	shl    $0x18,%esi
  800b9b:	89 d0                	mov    %edx,%eax
  800b9d:	c1 e0 10             	shl    $0x10,%eax
  800ba0:	09 f0                	or     %esi,%eax
  800ba2:	09 d0                	or     %edx,%eax
  800ba4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ba6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ba9:	fc                   	cld    
  800baa:	f3 ab                	rep stos %eax,%es:(%edi)
  800bac:	eb 03                	jmp    800bb1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bae:	fc                   	cld    
  800baf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bb1:	89 f8                	mov    %edi,%eax
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bc6:	39 c6                	cmp    %eax,%esi
  800bc8:	73 34                	jae    800bfe <memmove+0x46>
  800bca:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bcd:	39 d0                	cmp    %edx,%eax
  800bcf:	73 2d                	jae    800bfe <memmove+0x46>
		s += n;
		d += n;
  800bd1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd4:	f6 c2 03             	test   $0x3,%dl
  800bd7:	75 1b                	jne    800bf4 <memmove+0x3c>
  800bd9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bdf:	75 13                	jne    800bf4 <memmove+0x3c>
  800be1:	f6 c1 03             	test   $0x3,%cl
  800be4:	75 0e                	jne    800bf4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800be6:	83 ef 04             	sub    $0x4,%edi
  800be9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bec:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bef:	fd                   	std    
  800bf0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf2:	eb 07                	jmp    800bfb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bf4:	4f                   	dec    %edi
  800bf5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bf8:	fd                   	std    
  800bf9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bfb:	fc                   	cld    
  800bfc:	eb 20                	jmp    800c1e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bfe:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c04:	75 13                	jne    800c19 <memmove+0x61>
  800c06:	a8 03                	test   $0x3,%al
  800c08:	75 0f                	jne    800c19 <memmove+0x61>
  800c0a:	f6 c1 03             	test   $0x3,%cl
  800c0d:	75 0a                	jne    800c19 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c0f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c12:	89 c7                	mov    %eax,%edi
  800c14:	fc                   	cld    
  800c15:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c17:	eb 05                	jmp    800c1e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c19:	89 c7                	mov    %eax,%edi
  800c1b:	fc                   	cld    
  800c1c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c28:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c32:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c36:	8b 45 08             	mov    0x8(%ebp),%eax
  800c39:	89 04 24             	mov    %eax,(%esp)
  800c3c:	e8 77 ff ff ff       	call   800bb8 <memmove>
}
  800c41:	c9                   	leave  
  800c42:	c3                   	ret    

00800c43 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c52:	ba 00 00 00 00       	mov    $0x0,%edx
  800c57:	eb 16                	jmp    800c6f <memcmp+0x2c>
		if (*s1 != *s2)
  800c59:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c5c:	42                   	inc    %edx
  800c5d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c61:	38 c8                	cmp    %cl,%al
  800c63:	74 0a                	je     800c6f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c65:	0f b6 c0             	movzbl %al,%eax
  800c68:	0f b6 c9             	movzbl %cl,%ecx
  800c6b:	29 c8                	sub    %ecx,%eax
  800c6d:	eb 09                	jmp    800c78 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c6f:	39 da                	cmp    %ebx,%edx
  800c71:	75 e6                	jne    800c59 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	8b 45 08             	mov    0x8(%ebp),%eax
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c86:	89 c2                	mov    %eax,%edx
  800c88:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c8b:	eb 05                	jmp    800c92 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c8d:	38 08                	cmp    %cl,(%eax)
  800c8f:	74 05                	je     800c96 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c91:	40                   	inc    %eax
  800c92:	39 d0                	cmp    %edx,%eax
  800c94:	72 f7                	jb     800c8d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca4:	eb 01                	jmp    800ca7 <strtol+0xf>
		s++;
  800ca6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca7:	8a 02                	mov    (%edx),%al
  800ca9:	3c 20                	cmp    $0x20,%al
  800cab:	74 f9                	je     800ca6 <strtol+0xe>
  800cad:	3c 09                	cmp    $0x9,%al
  800caf:	74 f5                	je     800ca6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cb1:	3c 2b                	cmp    $0x2b,%al
  800cb3:	75 08                	jne    800cbd <strtol+0x25>
		s++;
  800cb5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cb6:	bf 00 00 00 00       	mov    $0x0,%edi
  800cbb:	eb 13                	jmp    800cd0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cbd:	3c 2d                	cmp    $0x2d,%al
  800cbf:	75 0a                	jne    800ccb <strtol+0x33>
		s++, neg = 1;
  800cc1:	8d 52 01             	lea    0x1(%edx),%edx
  800cc4:	bf 01 00 00 00       	mov    $0x1,%edi
  800cc9:	eb 05                	jmp    800cd0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ccb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cd0:	85 db                	test   %ebx,%ebx
  800cd2:	74 05                	je     800cd9 <strtol+0x41>
  800cd4:	83 fb 10             	cmp    $0x10,%ebx
  800cd7:	75 28                	jne    800d01 <strtol+0x69>
  800cd9:	8a 02                	mov    (%edx),%al
  800cdb:	3c 30                	cmp    $0x30,%al
  800cdd:	75 10                	jne    800cef <strtol+0x57>
  800cdf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ce3:	75 0a                	jne    800cef <strtol+0x57>
		s += 2, base = 16;
  800ce5:	83 c2 02             	add    $0x2,%edx
  800ce8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ced:	eb 12                	jmp    800d01 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800cef:	85 db                	test   %ebx,%ebx
  800cf1:	75 0e                	jne    800d01 <strtol+0x69>
  800cf3:	3c 30                	cmp    $0x30,%al
  800cf5:	75 05                	jne    800cfc <strtol+0x64>
		s++, base = 8;
  800cf7:	42                   	inc    %edx
  800cf8:	b3 08                	mov    $0x8,%bl
  800cfa:	eb 05                	jmp    800d01 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800cfc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
  800d06:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d08:	8a 0a                	mov    (%edx),%cl
  800d0a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d0d:	80 fb 09             	cmp    $0x9,%bl
  800d10:	77 08                	ja     800d1a <strtol+0x82>
			dig = *s - '0';
  800d12:	0f be c9             	movsbl %cl,%ecx
  800d15:	83 e9 30             	sub    $0x30,%ecx
  800d18:	eb 1e                	jmp    800d38 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d1a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d1d:	80 fb 19             	cmp    $0x19,%bl
  800d20:	77 08                	ja     800d2a <strtol+0x92>
			dig = *s - 'a' + 10;
  800d22:	0f be c9             	movsbl %cl,%ecx
  800d25:	83 e9 57             	sub    $0x57,%ecx
  800d28:	eb 0e                	jmp    800d38 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d2a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d2d:	80 fb 19             	cmp    $0x19,%bl
  800d30:	77 12                	ja     800d44 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d32:	0f be c9             	movsbl %cl,%ecx
  800d35:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d38:	39 f1                	cmp    %esi,%ecx
  800d3a:	7d 0c                	jge    800d48 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d3c:	42                   	inc    %edx
  800d3d:	0f af c6             	imul   %esi,%eax
  800d40:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d42:	eb c4                	jmp    800d08 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d44:	89 c1                	mov    %eax,%ecx
  800d46:	eb 02                	jmp    800d4a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d48:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d4a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d4e:	74 05                	je     800d55 <strtol+0xbd>
		*endptr = (char *) s;
  800d50:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d53:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d55:	85 ff                	test   %edi,%edi
  800d57:	74 04                	je     800d5d <strtol+0xc5>
  800d59:	89 c8                	mov    %ecx,%eax
  800d5b:	f7 d8                	neg    %eax
}
  800d5d:	5b                   	pop    %ebx
  800d5e:	5e                   	pop    %esi
  800d5f:	5f                   	pop    %edi
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    
	...

00800d64 <__udivdi3>:
  800d64:	55                   	push   %ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	83 ec 10             	sub    $0x10,%esp
  800d6a:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d6e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800d72:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d76:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800d7a:	89 cd                	mov    %ecx,%ebp
  800d7c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800d80:	85 c0                	test   %eax,%eax
  800d82:	75 2c                	jne    800db0 <__udivdi3+0x4c>
  800d84:	39 f9                	cmp    %edi,%ecx
  800d86:	77 68                	ja     800df0 <__udivdi3+0x8c>
  800d88:	85 c9                	test   %ecx,%ecx
  800d8a:	75 0b                	jne    800d97 <__udivdi3+0x33>
  800d8c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d91:	31 d2                	xor    %edx,%edx
  800d93:	f7 f1                	div    %ecx
  800d95:	89 c1                	mov    %eax,%ecx
  800d97:	31 d2                	xor    %edx,%edx
  800d99:	89 f8                	mov    %edi,%eax
  800d9b:	f7 f1                	div    %ecx
  800d9d:	89 c7                	mov    %eax,%edi
  800d9f:	89 f0                	mov    %esi,%eax
  800da1:	f7 f1                	div    %ecx
  800da3:	89 c6                	mov    %eax,%esi
  800da5:	89 f0                	mov    %esi,%eax
  800da7:	89 fa                	mov    %edi,%edx
  800da9:	83 c4 10             	add    $0x10,%esp
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    
  800db0:	39 f8                	cmp    %edi,%eax
  800db2:	77 2c                	ja     800de0 <__udivdi3+0x7c>
  800db4:	0f bd f0             	bsr    %eax,%esi
  800db7:	83 f6 1f             	xor    $0x1f,%esi
  800dba:	75 4c                	jne    800e08 <__udivdi3+0xa4>
  800dbc:	39 f8                	cmp    %edi,%eax
  800dbe:	bf 00 00 00 00       	mov    $0x0,%edi
  800dc3:	72 0a                	jb     800dcf <__udivdi3+0x6b>
  800dc5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800dc9:	0f 87 ad 00 00 00    	ja     800e7c <__udivdi3+0x118>
  800dcf:	be 01 00 00 00       	mov    $0x1,%esi
  800dd4:	89 f0                	mov    %esi,%eax
  800dd6:	89 fa                	mov    %edi,%edx
  800dd8:	83 c4 10             	add    $0x10,%esp
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    
  800ddf:	90                   	nop
  800de0:	31 ff                	xor    %edi,%edi
  800de2:	31 f6                	xor    %esi,%esi
  800de4:	89 f0                	mov    %esi,%eax
  800de6:	89 fa                	mov    %edi,%edx
  800de8:	83 c4 10             	add    $0x10,%esp
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    
  800def:	90                   	nop
  800df0:	89 fa                	mov    %edi,%edx
  800df2:	89 f0                	mov    %esi,%eax
  800df4:	f7 f1                	div    %ecx
  800df6:	89 c6                	mov    %eax,%esi
  800df8:	31 ff                	xor    %edi,%edi
  800dfa:	89 f0                	mov    %esi,%eax
  800dfc:	89 fa                	mov    %edi,%edx
  800dfe:	83 c4 10             	add    $0x10,%esp
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    
  800e05:	8d 76 00             	lea    0x0(%esi),%esi
  800e08:	89 f1                	mov    %esi,%ecx
  800e0a:	d3 e0                	shl    %cl,%eax
  800e0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e10:	b8 20 00 00 00       	mov    $0x20,%eax
  800e15:	29 f0                	sub    %esi,%eax
  800e17:	89 ea                	mov    %ebp,%edx
  800e19:	88 c1                	mov    %al,%cl
  800e1b:	d3 ea                	shr    %cl,%edx
  800e1d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e21:	09 ca                	or     %ecx,%edx
  800e23:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e27:	89 f1                	mov    %esi,%ecx
  800e29:	d3 e5                	shl    %cl,%ebp
  800e2b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800e2f:	89 fd                	mov    %edi,%ebp
  800e31:	88 c1                	mov    %al,%cl
  800e33:	d3 ed                	shr    %cl,%ebp
  800e35:	89 fa                	mov    %edi,%edx
  800e37:	89 f1                	mov    %esi,%ecx
  800e39:	d3 e2                	shl    %cl,%edx
  800e3b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e3f:	88 c1                	mov    %al,%cl
  800e41:	d3 ef                	shr    %cl,%edi
  800e43:	09 d7                	or     %edx,%edi
  800e45:	89 f8                	mov    %edi,%eax
  800e47:	89 ea                	mov    %ebp,%edx
  800e49:	f7 74 24 08          	divl   0x8(%esp)
  800e4d:	89 d1                	mov    %edx,%ecx
  800e4f:	89 c7                	mov    %eax,%edi
  800e51:	f7 64 24 0c          	mull   0xc(%esp)
  800e55:	39 d1                	cmp    %edx,%ecx
  800e57:	72 17                	jb     800e70 <__udivdi3+0x10c>
  800e59:	74 09                	je     800e64 <__udivdi3+0x100>
  800e5b:	89 fe                	mov    %edi,%esi
  800e5d:	31 ff                	xor    %edi,%edi
  800e5f:	e9 41 ff ff ff       	jmp    800da5 <__udivdi3+0x41>
  800e64:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e68:	89 f1                	mov    %esi,%ecx
  800e6a:	d3 e2                	shl    %cl,%edx
  800e6c:	39 c2                	cmp    %eax,%edx
  800e6e:	73 eb                	jae    800e5b <__udivdi3+0xf7>
  800e70:	8d 77 ff             	lea    -0x1(%edi),%esi
  800e73:	31 ff                	xor    %edi,%edi
  800e75:	e9 2b ff ff ff       	jmp    800da5 <__udivdi3+0x41>
  800e7a:	66 90                	xchg   %ax,%ax
  800e7c:	31 f6                	xor    %esi,%esi
  800e7e:	e9 22 ff ff ff       	jmp    800da5 <__udivdi3+0x41>
	...

00800e84 <__umoddi3>:
  800e84:	55                   	push   %ebp
  800e85:	57                   	push   %edi
  800e86:	56                   	push   %esi
  800e87:	83 ec 20             	sub    $0x20,%esp
  800e8a:	8b 44 24 30          	mov    0x30(%esp),%eax
  800e8e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800e92:	89 44 24 14          	mov    %eax,0x14(%esp)
  800e96:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e9a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e9e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800ea2:	89 c7                	mov    %eax,%edi
  800ea4:	89 f2                	mov    %esi,%edx
  800ea6:	85 ed                	test   %ebp,%ebp
  800ea8:	75 16                	jne    800ec0 <__umoddi3+0x3c>
  800eaa:	39 f1                	cmp    %esi,%ecx
  800eac:	0f 86 a6 00 00 00    	jbe    800f58 <__umoddi3+0xd4>
  800eb2:	f7 f1                	div    %ecx
  800eb4:	89 d0                	mov    %edx,%eax
  800eb6:	31 d2                	xor    %edx,%edx
  800eb8:	83 c4 20             	add    $0x20,%esp
  800ebb:	5e                   	pop    %esi
  800ebc:	5f                   	pop    %edi
  800ebd:	5d                   	pop    %ebp
  800ebe:	c3                   	ret    
  800ebf:	90                   	nop
  800ec0:	39 f5                	cmp    %esi,%ebp
  800ec2:	0f 87 ac 00 00 00    	ja     800f74 <__umoddi3+0xf0>
  800ec8:	0f bd c5             	bsr    %ebp,%eax
  800ecb:	83 f0 1f             	xor    $0x1f,%eax
  800ece:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed2:	0f 84 a8 00 00 00    	je     800f80 <__umoddi3+0xfc>
  800ed8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800edc:	d3 e5                	shl    %cl,%ebp
  800ede:	bf 20 00 00 00       	mov    $0x20,%edi
  800ee3:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800ee7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800eeb:	89 f9                	mov    %edi,%ecx
  800eed:	d3 e8                	shr    %cl,%eax
  800eef:	09 e8                	or     %ebp,%eax
  800ef1:	89 44 24 18          	mov    %eax,0x18(%esp)
  800ef5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ef9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800efd:	d3 e0                	shl    %cl,%eax
  800eff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f03:	89 f2                	mov    %esi,%edx
  800f05:	d3 e2                	shl    %cl,%edx
  800f07:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f0b:	d3 e0                	shl    %cl,%eax
  800f0d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800f11:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f15:	89 f9                	mov    %edi,%ecx
  800f17:	d3 e8                	shr    %cl,%eax
  800f19:	09 d0                	or     %edx,%eax
  800f1b:	d3 ee                	shr    %cl,%esi
  800f1d:	89 f2                	mov    %esi,%edx
  800f1f:	f7 74 24 18          	divl   0x18(%esp)
  800f23:	89 d6                	mov    %edx,%esi
  800f25:	f7 64 24 0c          	mull   0xc(%esp)
  800f29:	89 c5                	mov    %eax,%ebp
  800f2b:	89 d1                	mov    %edx,%ecx
  800f2d:	39 d6                	cmp    %edx,%esi
  800f2f:	72 67                	jb     800f98 <__umoddi3+0x114>
  800f31:	74 75                	je     800fa8 <__umoddi3+0x124>
  800f33:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f37:	29 e8                	sub    %ebp,%eax
  800f39:	19 ce                	sbb    %ecx,%esi
  800f3b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f3f:	d3 e8                	shr    %cl,%eax
  800f41:	89 f2                	mov    %esi,%edx
  800f43:	89 f9                	mov    %edi,%ecx
  800f45:	d3 e2                	shl    %cl,%edx
  800f47:	09 d0                	or     %edx,%eax
  800f49:	89 f2                	mov    %esi,%edx
  800f4b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f4f:	d3 ea                	shr    %cl,%edx
  800f51:	83 c4 20             	add    $0x20,%esp
  800f54:	5e                   	pop    %esi
  800f55:	5f                   	pop    %edi
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    
  800f58:	85 c9                	test   %ecx,%ecx
  800f5a:	75 0b                	jne    800f67 <__umoddi3+0xe3>
  800f5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f61:	31 d2                	xor    %edx,%edx
  800f63:	f7 f1                	div    %ecx
  800f65:	89 c1                	mov    %eax,%ecx
  800f67:	89 f0                	mov    %esi,%eax
  800f69:	31 d2                	xor    %edx,%edx
  800f6b:	f7 f1                	div    %ecx
  800f6d:	89 f8                	mov    %edi,%eax
  800f6f:	e9 3e ff ff ff       	jmp    800eb2 <__umoddi3+0x2e>
  800f74:	89 f2                	mov    %esi,%edx
  800f76:	83 c4 20             	add    $0x20,%esp
  800f79:	5e                   	pop    %esi
  800f7a:	5f                   	pop    %edi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    
  800f7d:	8d 76 00             	lea    0x0(%esi),%esi
  800f80:	39 f5                	cmp    %esi,%ebp
  800f82:	72 04                	jb     800f88 <__umoddi3+0x104>
  800f84:	39 f9                	cmp    %edi,%ecx
  800f86:	77 06                	ja     800f8e <__umoddi3+0x10a>
  800f88:	89 f2                	mov    %esi,%edx
  800f8a:	29 cf                	sub    %ecx,%edi
  800f8c:	19 ea                	sbb    %ebp,%edx
  800f8e:	89 f8                	mov    %edi,%eax
  800f90:	83 c4 20             	add    $0x20,%esp
  800f93:	5e                   	pop    %esi
  800f94:	5f                   	pop    %edi
  800f95:	5d                   	pop    %ebp
  800f96:	c3                   	ret    
  800f97:	90                   	nop
  800f98:	89 d1                	mov    %edx,%ecx
  800f9a:	89 c5                	mov    %eax,%ebp
  800f9c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fa0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fa4:	eb 8d                	jmp    800f33 <__umoddi3+0xaf>
  800fa6:	66 90                	xchg   %ax,%ax
  800fa8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fac:	72 ea                	jb     800f98 <__umoddi3+0x114>
  800fae:	89 f1                	mov    %esi,%ecx
  800fb0:	eb 81                	jmp    800f33 <__umoddi3+0xaf>
