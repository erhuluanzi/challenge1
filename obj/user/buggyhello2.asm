
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 20 80 00       	mov    0x802000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 69 00 00 00       	call   8000b8 <sys_cputs>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	83 ec 10             	sub    $0x10,%esp
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800062:	e8 e0 00 00 00       	call   800147 <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80006f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800072:	c1 e0 04             	shl    $0x4,%eax
  800075:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007a:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007f:	85 f6                	test   %esi,%esi
  800081:	7e 07                	jle    80008a <libmain+0x36>
		binaryname = argv[0];
  800083:	8b 03                	mov    (%ebx),%eax
  800085:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  80008a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008e:	89 34 24             	mov    %esi,(%esp)
  800091:	e8 9e ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800096:	e8 09 00 00 00       	call   8000a4 <exit>
}
  80009b:	83 c4 10             	add    $0x10,%esp
  80009e:	5b                   	pop    %ebx
  80009f:	5e                   	pop    %esi
  8000a0:	5d                   	pop    %ebp
  8000a1:	c3                   	ret    
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b1:	e8 3f 00 00 00       	call   8000f5 <sys_env_destroy>
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c9:	89 c3                	mov    %eax,%ebx
  8000cb:	89 c7                	mov    %eax,%edi
  8000cd:	89 c6                	mov    %eax,%esi
  8000cf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e6:	89 d1                	mov    %edx,%ecx
  8000e8:	89 d3                	mov    %edx,%ebx
  8000ea:	89 d7                	mov    %edx,%edi
  8000ec:	89 d6                	mov    %edx,%esi
  8000ee:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    

008000f5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	57                   	push   %edi
  8000f9:	56                   	push   %esi
  8000fa:	53                   	push   %ebx
  8000fb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800103:	b8 03 00 00 00       	mov    $0x3,%eax
  800108:	8b 55 08             	mov    0x8(%ebp),%edx
  80010b:	89 cb                	mov    %ecx,%ebx
  80010d:	89 cf                	mov    %ecx,%edi
  80010f:	89 ce                	mov    %ecx,%esi
  800111:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800113:	85 c0                	test   %eax,%eax
  800115:	7e 28                	jle    80013f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800117:	89 44 24 10          	mov    %eax,0x10(%esp)
  80011b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800122:	00 
  800123:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  80012a:	00 
  80012b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800132:	00 
  800133:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  80013a:	e8 e1 07 00 00       	call   800920 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013f:	83 c4 2c             	add    $0x2c,%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 02 00 00 00       	mov    $0x2,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_yield>:

void
sys_yield(void)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	ba 00 00 00 00       	mov    $0x0,%edx
  800171:	b8 0a 00 00 00       	mov    $0xa,%eax
  800176:	89 d1                	mov    %edx,%ecx
  800178:	89 d3                	mov    %edx,%ebx
  80017a:	89 d7                	mov    %edx,%edi
  80017c:	89 d6                	mov    %edx,%esi
  80017e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	57                   	push   %edi
  800189:	56                   	push   %esi
  80018a:	53                   	push   %ebx
  80018b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018e:	be 00 00 00 00       	mov    $0x0,%esi
  800193:	b8 04 00 00 00       	mov    $0x4,%eax
  800198:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019e:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a1:	89 f7                	mov    %esi,%edi
  8001a3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a5:	85 c0                	test   %eax,%eax
  8001a7:	7e 28                	jle    8001d1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001ad:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001b4:	00 
  8001b5:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  8001bc:	00 
  8001bd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c4:	00 
  8001c5:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  8001cc:	e8 4f 07 00 00       	call   800920 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d1:	83 c4 2c             	add    $0x2c,%esp
  8001d4:	5b                   	pop    %ebx
  8001d5:	5e                   	pop    %esi
  8001d6:	5f                   	pop    %edi
  8001d7:	5d                   	pop    %ebp
  8001d8:	c3                   	ret    

008001d9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	57                   	push   %edi
  8001dd:	56                   	push   %esi
  8001de:	53                   	push   %ebx
  8001df:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ea:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f8:	85 c0                	test   %eax,%eax
  8001fa:	7e 28                	jle    800224 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800200:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800207:	00 
  800208:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  80020f:	00 
  800210:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800217:	00 
  800218:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  80021f:	e8 fc 06 00 00       	call   800920 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800224:	83 c4 2c             	add    $0x2c,%esp
  800227:	5b                   	pop    %ebx
  800228:	5e                   	pop    %esi
  800229:	5f                   	pop    %edi
  80022a:	5d                   	pop    %ebp
  80022b:	c3                   	ret    

0080022c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	57                   	push   %edi
  800230:	56                   	push   %esi
  800231:	53                   	push   %ebx
  800232:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800235:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023a:	b8 06 00 00 00       	mov    $0x6,%eax
  80023f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800242:	8b 55 08             	mov    0x8(%ebp),%edx
  800245:	89 df                	mov    %ebx,%edi
  800247:	89 de                	mov    %ebx,%esi
  800249:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024b:	85 c0                	test   %eax,%eax
  80024d:	7e 28                	jle    800277 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800253:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80025a:	00 
  80025b:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  800262:	00 
  800263:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026a:	00 
  80026b:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  800272:	e8 a9 06 00 00       	call   800920 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800277:	83 c4 2c             	add    $0x2c,%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5f                   	pop    %edi
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	57                   	push   %edi
  800283:	56                   	push   %esi
  800284:	53                   	push   %ebx
  800285:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800288:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028d:	b8 08 00 00 00       	mov    $0x8,%eax
  800292:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800295:	8b 55 08             	mov    0x8(%ebp),%edx
  800298:	89 df                	mov    %ebx,%edi
  80029a:	89 de                	mov    %ebx,%esi
  80029c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80029e:	85 c0                	test   %eax,%eax
  8002a0:	7e 28                	jle    8002ca <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002ad:	00 
  8002ae:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  8002b5:	00 
  8002b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002bd:	00 
  8002be:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  8002c5:	e8 56 06 00 00       	call   800920 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ca:	83 c4 2c             	add    $0x2c,%esp
  8002cd:	5b                   	pop    %ebx
  8002ce:	5e                   	pop    %esi
  8002cf:	5f                   	pop    %edi
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e0:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002eb:	89 df                	mov    %ebx,%edi
  8002ed:	89 de                	mov    %ebx,%esi
  8002ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002f1:	85 c0                	test   %eax,%eax
  8002f3:	7e 28                	jle    80031d <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800300:	00 
  800301:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  800308:	00 
  800309:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800310:	00 
  800311:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  800318:	e8 03 06 00 00       	call   800920 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80031d:	83 c4 2c             	add    $0x2c,%esp
  800320:	5b                   	pop    %ebx
  800321:	5e                   	pop    %esi
  800322:	5f                   	pop    %edi
  800323:	5d                   	pop    %ebp
  800324:	c3                   	ret    

00800325 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032b:	be 00 00 00 00       	mov    $0x0,%esi
  800330:	b8 0b 00 00 00       	mov    $0xb,%eax
  800335:	8b 7d 14             	mov    0x14(%ebp),%edi
  800338:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80033b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033e:	8b 55 08             	mov    0x8(%ebp),%edx
  800341:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800343:	5b                   	pop    %ebx
  800344:	5e                   	pop    %esi
  800345:	5f                   	pop    %edi
  800346:	5d                   	pop    %ebp
  800347:	c3                   	ret    

00800348 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
  80034b:	57                   	push   %edi
  80034c:	56                   	push   %esi
  80034d:	53                   	push   %ebx
  80034e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800351:	b9 00 00 00 00       	mov    $0x0,%ecx
  800356:	b8 0c 00 00 00       	mov    $0xc,%eax
  80035b:	8b 55 08             	mov    0x8(%ebp),%edx
  80035e:	89 cb                	mov    %ecx,%ebx
  800360:	89 cf                	mov    %ecx,%edi
  800362:	89 ce                	mov    %ecx,%esi
  800364:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800366:	85 c0                	test   %eax,%eax
  800368:	7e 28                	jle    800392 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80036a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80036e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800375:	00 
  800376:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  80037d:	00 
  80037e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800385:	00 
  800386:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  80038d:	e8 8e 05 00 00       	call   800920 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800392:	83 c4 2c             	add    $0x2c,%esp
  800395:	5b                   	pop    %ebx
  800396:	5e                   	pop    %esi
  800397:	5f                   	pop    %edi
  800398:	5d                   	pop    %ebp
  800399:	c3                   	ret    

0080039a <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	57                   	push   %edi
  80039e:	56                   	push   %esi
  80039f:	53                   	push   %ebx
  8003a0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a8:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b3:	89 df                	mov    %ebx,%edi
  8003b5:	89 de                	mov    %ebx,%esi
  8003b7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003b9:	85 c0                	test   %eax,%eax
  8003bb:	7e 28                	jle    8003e5 <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003c1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003c8:	00 
  8003c9:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  8003d0:	00 
  8003d1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d8:	00 
  8003d9:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  8003e0:	e8 3b 05 00 00       	call   800920 <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8003e5:	83 c4 2c             	add    $0x2c,%esp
  8003e8:	5b                   	pop    %ebx
  8003e9:	5e                   	pop    %esi
  8003ea:	5f                   	pop    %edi
  8003eb:	5d                   	pop    %ebp
  8003ec:	c3                   	ret    

008003ed <sys_env_set_debug_upcall>:

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
  8003ed:	55                   	push   %ebp
  8003ee:	89 e5                	mov    %esp,%ebp
  8003f0:	57                   	push   %edi
  8003f1:	56                   	push   %esi
  8003f2:	53                   	push   %ebx
  8003f3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003fb:	b8 0e 00 00 00       	mov    $0xe,%eax
  800400:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800403:	8b 55 08             	mov    0x8(%ebp),%edx
  800406:	89 df                	mov    %ebx,%edi
  800408:	89 de                	mov    %ebx,%esi
  80040a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80040c:	85 c0                	test   %eax,%eax
  80040e:	7e 28                	jle    800438 <sys_env_set_debug_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800410:	89 44 24 10          	mov    %eax,0x10(%esp)
  800414:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80041b:	00 
  80041c:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  800423:	00 
  800424:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80042b:	00 
  80042c:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  800433:	e8 e8 04 00 00       	call   800920 <_panic>
}

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_debug_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800438:	83 c4 2c             	add    $0x2c,%esp
  80043b:	5b                   	pop    %ebx
  80043c:	5e                   	pop    %esi
  80043d:	5f                   	pop    %edi
  80043e:	5d                   	pop    %ebp
  80043f:	c3                   	ret    

00800440 <sys_env_set_nmskint_upcall>:

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
  800440:	55                   	push   %ebp
  800441:	89 e5                	mov    %esp,%ebp
  800443:	57                   	push   %edi
  800444:	56                   	push   %esi
  800445:	53                   	push   %ebx
  800446:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800449:	bb 00 00 00 00       	mov    $0x0,%ebx
  80044e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800453:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800456:	8b 55 08             	mov    0x8(%ebp),%edx
  800459:	89 df                	mov    %ebx,%edi
  80045b:	89 de                	mov    %ebx,%esi
  80045d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80045f:	85 c0                	test   %eax,%eax
  800461:	7e 28                	jle    80048b <sys_env_set_nmskint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800463:	89 44 24 10          	mov    %eax,0x10(%esp)
  800467:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  80046e:	00 
  80046f:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  800476:	00 
  800477:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80047e:	00 
  80047f:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  800486:	e8 95 04 00 00       	call   800920 <_panic>
}

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_nmskint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80048b:	83 c4 2c             	add    $0x2c,%esp
  80048e:	5b                   	pop    %ebx
  80048f:	5e                   	pop    %esi
  800490:	5f                   	pop    %edi
  800491:	5d                   	pop    %ebp
  800492:	c3                   	ret    

00800493 <sys_env_set_bpoint_upcall>:

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
  800493:	55                   	push   %ebp
  800494:	89 e5                	mov    %esp,%ebp
  800496:	57                   	push   %edi
  800497:	56                   	push   %esi
  800498:	53                   	push   %ebx
  800499:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80049c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004a1:	b8 10 00 00 00       	mov    $0x10,%eax
  8004a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ac:	89 df                	mov    %ebx,%edi
  8004ae:	89 de                	mov    %ebx,%esi
  8004b0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8004b2:	85 c0                	test   %eax,%eax
  8004b4:	7e 28                	jle    8004de <sys_env_set_bpoint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004ba:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  8004c1:	00 
  8004c2:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  8004c9:	00 
  8004ca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004d1:	00 
  8004d2:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  8004d9:	e8 42 04 00 00       	call   800920 <_panic>
}

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bpoint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8004de:	83 c4 2c             	add    $0x2c,%esp
  8004e1:	5b                   	pop    %ebx
  8004e2:	5e                   	pop    %esi
  8004e3:	5f                   	pop    %edi
  8004e4:	5d                   	pop    %ebp
  8004e5:	c3                   	ret    

008004e6 <sys_env_set_oflow_upcall>:

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	57                   	push   %edi
  8004ea:	56                   	push   %esi
  8004eb:	53                   	push   %ebx
  8004ec:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004f4:	b8 11 00 00 00       	mov    $0x11,%eax
  8004f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ff:	89 df                	mov    %ebx,%edi
  800501:	89 de                	mov    %ebx,%esi
  800503:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800505:	85 c0                	test   %eax,%eax
  800507:	7e 28                	jle    800531 <sys_env_set_oflow_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800509:	89 44 24 10          	mov    %eax,0x10(%esp)
  80050d:	c7 44 24 0c 11 00 00 	movl   $0x11,0xc(%esp)
  800514:	00 
  800515:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  80051c:	00 
  80051d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800524:	00 
  800525:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  80052c:	e8 ef 03 00 00       	call   800920 <_panic>
}

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_oflow_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800531:	83 c4 2c             	add    $0x2c,%esp
  800534:	5b                   	pop    %ebx
  800535:	5e                   	pop    %esi
  800536:	5f                   	pop    %edi
  800537:	5d                   	pop    %ebp
  800538:	c3                   	ret    

00800539 <sys_env_set_bdschk_upcall>:

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
  800539:	55                   	push   %ebp
  80053a:	89 e5                	mov    %esp,%ebp
  80053c:	57                   	push   %edi
  80053d:	56                   	push   %esi
  80053e:	53                   	push   %ebx
  80053f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800542:	bb 00 00 00 00       	mov    $0x0,%ebx
  800547:	b8 12 00 00 00       	mov    $0x12,%eax
  80054c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80054f:	8b 55 08             	mov    0x8(%ebp),%edx
  800552:	89 df                	mov    %ebx,%edi
  800554:	89 de                	mov    %ebx,%esi
  800556:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800558:	85 c0                	test   %eax,%eax
  80055a:	7e 28                	jle    800584 <sys_env_set_bdschk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80055c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800560:	c7 44 24 0c 12 00 00 	movl   $0x12,0xc(%esp)
  800567:	00 
  800568:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  80056f:	00 
  800570:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800577:	00 
  800578:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  80057f:	e8 9c 03 00 00       	call   800920 <_panic>
}

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bdschk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800584:	83 c4 2c             	add    $0x2c,%esp
  800587:	5b                   	pop    %ebx
  800588:	5e                   	pop    %esi
  800589:	5f                   	pop    %edi
  80058a:	5d                   	pop    %ebp
  80058b:	c3                   	ret    

0080058c <sys_env_set_illopcd_upcall>:

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
  80058c:	55                   	push   %ebp
  80058d:	89 e5                	mov    %esp,%ebp
  80058f:	57                   	push   %edi
  800590:	56                   	push   %esi
  800591:	53                   	push   %ebx
  800592:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800595:	bb 00 00 00 00       	mov    $0x0,%ebx
  80059a:	b8 13 00 00 00       	mov    $0x13,%eax
  80059f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8005a5:	89 df                	mov    %ebx,%edi
  8005a7:	89 de                	mov    %ebx,%esi
  8005a9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005ab:	85 c0                	test   %eax,%eax
  8005ad:	7e 28                	jle    8005d7 <sys_env_set_illopcd_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005af:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005b3:	c7 44 24 0c 13 00 00 	movl   $0x13,0xc(%esp)
  8005ba:	00 
  8005bb:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  8005c2:	00 
  8005c3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005ca:	00 
  8005cb:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  8005d2:	e8 49 03 00 00       	call   800920 <_panic>
}

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_illopcd_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8005d7:	83 c4 2c             	add    $0x2c,%esp
  8005da:	5b                   	pop    %ebx
  8005db:	5e                   	pop    %esi
  8005dc:	5f                   	pop    %edi
  8005dd:	5d                   	pop    %ebp
  8005de:	c3                   	ret    

008005df <sys_env_set_dvcntavl_upcall>:

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
  8005df:	55                   	push   %ebp
  8005e0:	89 e5                	mov    %esp,%ebp
  8005e2:	57                   	push   %edi
  8005e3:	56                   	push   %esi
  8005e4:	53                   	push   %ebx
  8005e5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005ed:	b8 14 00 00 00       	mov    $0x14,%eax
  8005f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8005f8:	89 df                	mov    %ebx,%edi
  8005fa:	89 de                	mov    %ebx,%esi
  8005fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005fe:	85 c0                	test   %eax,%eax
  800600:	7e 28                	jle    80062a <sys_env_set_dvcntavl_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800602:	89 44 24 10          	mov    %eax,0x10(%esp)
  800606:	c7 44 24 0c 14 00 00 	movl   $0x14,0xc(%esp)
  80060d:	00 
  80060e:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  800615:	00 
  800616:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80061d:	00 
  80061e:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  800625:	e8 f6 02 00 00       	call   800920 <_panic>
}

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dvcntavl_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80062a:	83 c4 2c             	add    $0x2c,%esp
  80062d:	5b                   	pop    %ebx
  80062e:	5e                   	pop    %esi
  80062f:	5f                   	pop    %edi
  800630:	5d                   	pop    %ebp
  800631:	c3                   	ret    

00800632 <sys_env_set_dbfault_upcall>:

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
  800632:	55                   	push   %ebp
  800633:	89 e5                	mov    %esp,%ebp
  800635:	57                   	push   %edi
  800636:	56                   	push   %esi
  800637:	53                   	push   %ebx
  800638:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80063b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800640:	b8 15 00 00 00       	mov    $0x15,%eax
  800645:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800648:	8b 55 08             	mov    0x8(%ebp),%edx
  80064b:	89 df                	mov    %ebx,%edi
  80064d:	89 de                	mov    %ebx,%esi
  80064f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800651:	85 c0                	test   %eax,%eax
  800653:	7e 28                	jle    80067d <sys_env_set_dbfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800655:	89 44 24 10          	mov    %eax,0x10(%esp)
  800659:	c7 44 24 0c 15 00 00 	movl   $0x15,0xc(%esp)
  800660:	00 
  800661:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  800668:	00 
  800669:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800670:	00 
  800671:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  800678:	e8 a3 02 00 00       	call   800920 <_panic>
}

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dbfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80067d:	83 c4 2c             	add    $0x2c,%esp
  800680:	5b                   	pop    %ebx
  800681:	5e                   	pop    %esi
  800682:	5f                   	pop    %edi
  800683:	5d                   	pop    %ebp
  800684:	c3                   	ret    

00800685 <sys_env_set_ivldtss_upcall>:

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	57                   	push   %edi
  800689:	56                   	push   %esi
  80068a:	53                   	push   %ebx
  80068b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80068e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800693:	b8 16 00 00 00       	mov    $0x16,%eax
  800698:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80069b:	8b 55 08             	mov    0x8(%ebp),%edx
  80069e:	89 df                	mov    %ebx,%edi
  8006a0:	89 de                	mov    %ebx,%esi
  8006a2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006a4:	85 c0                	test   %eax,%eax
  8006a6:	7e 28                	jle    8006d0 <sys_env_set_ivldtss_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006a8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ac:	c7 44 24 0c 16 00 00 	movl   $0x16,0xc(%esp)
  8006b3:	00 
  8006b4:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  8006bb:	00 
  8006bc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006c3:	00 
  8006c4:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  8006cb:	e8 50 02 00 00       	call   800920 <_panic>
}

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_ivldtss_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8006d0:	83 c4 2c             	add    $0x2c,%esp
  8006d3:	5b                   	pop    %ebx
  8006d4:	5e                   	pop    %esi
  8006d5:	5f                   	pop    %edi
  8006d6:	5d                   	pop    %ebp
  8006d7:	c3                   	ret    

008006d8 <sys_env_set_segntprst_upcall>:

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	57                   	push   %edi
  8006dc:	56                   	push   %esi
  8006dd:	53                   	push   %ebx
  8006de:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e6:	b8 17 00 00 00       	mov    $0x17,%eax
  8006eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f1:	89 df                	mov    %ebx,%edi
  8006f3:	89 de                	mov    %ebx,%esi
  8006f5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006f7:	85 c0                	test   %eax,%eax
  8006f9:	7e 28                	jle    800723 <sys_env_set_segntprst_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006fb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ff:	c7 44 24 0c 17 00 00 	movl   $0x17,0xc(%esp)
  800706:	00 
  800707:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  80070e:	00 
  80070f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800716:	00 
  800717:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  80071e:	e8 fd 01 00 00       	call   800920 <_panic>
}

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_segntprst_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800723:	83 c4 2c             	add    $0x2c,%esp
  800726:	5b                   	pop    %ebx
  800727:	5e                   	pop    %esi
  800728:	5f                   	pop    %edi
  800729:	5d                   	pop    %ebp
  80072a:	c3                   	ret    

0080072b <sys_env_set_stkexception_upcall>:

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	57                   	push   %edi
  80072f:	56                   	push   %esi
  800730:	53                   	push   %ebx
  800731:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800734:	bb 00 00 00 00       	mov    $0x0,%ebx
  800739:	b8 18 00 00 00       	mov    $0x18,%eax
  80073e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800741:	8b 55 08             	mov    0x8(%ebp),%edx
  800744:	89 df                	mov    %ebx,%edi
  800746:	89 de                	mov    %ebx,%esi
  800748:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80074a:	85 c0                	test   %eax,%eax
  80074c:	7e 28                	jle    800776 <sys_env_set_stkexception_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80074e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800752:	c7 44 24 0c 18 00 00 	movl   $0x18,0xc(%esp)
  800759:	00 
  80075a:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  800761:	00 
  800762:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800769:	00 
  80076a:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  800771:	e8 aa 01 00 00       	call   800920 <_panic>
}

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_stkexception_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800776:	83 c4 2c             	add    $0x2c,%esp
  800779:	5b                   	pop    %ebx
  80077a:	5e                   	pop    %esi
  80077b:	5f                   	pop    %edi
  80077c:	5d                   	pop    %ebp
  80077d:	c3                   	ret    

0080077e <sys_env_set_gpfault_upcall>:

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	57                   	push   %edi
  800782:	56                   	push   %esi
  800783:	53                   	push   %ebx
  800784:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800787:	bb 00 00 00 00       	mov    $0x0,%ebx
  80078c:	b8 19 00 00 00       	mov    $0x19,%eax
  800791:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800794:	8b 55 08             	mov    0x8(%ebp),%edx
  800797:	89 df                	mov    %ebx,%edi
  800799:	89 de                	mov    %ebx,%esi
  80079b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80079d:	85 c0                	test   %eax,%eax
  80079f:	7e 28                	jle    8007c9 <sys_env_set_gpfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007a1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007a5:	c7 44 24 0c 19 00 00 	movl   $0x19,0xc(%esp)
  8007ac:	00 
  8007ad:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  8007b4:	00 
  8007b5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8007bc:	00 
  8007bd:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  8007c4:	e8 57 01 00 00       	call   800920 <_panic>
}

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_gpfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8007c9:	83 c4 2c             	add    $0x2c,%esp
  8007cc:	5b                   	pop    %ebx
  8007cd:	5e                   	pop    %esi
  8007ce:	5f                   	pop    %edi
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <sys_env_set_fperror_upcall>:

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	57                   	push   %edi
  8007d5:	56                   	push   %esi
  8007d6:	53                   	push   %ebx
  8007d7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007df:	b8 1a 00 00 00       	mov    $0x1a,%eax
  8007e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8007ea:	89 df                	mov    %ebx,%edi
  8007ec:	89 de                	mov    %ebx,%esi
  8007ee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	7e 28                	jle    80081c <sys_env_set_fperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007f8:	c7 44 24 0c 1a 00 00 	movl   $0x1a,0xc(%esp)
  8007ff:	00 
  800800:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  800807:	00 
  800808:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80080f:	00 
  800810:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  800817:	e8 04 01 00 00       	call   800920 <_panic>
}

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_fperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80081c:	83 c4 2c             	add    $0x2c,%esp
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5f                   	pop    %edi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <sys_env_set_algchk_upcall>:

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	57                   	push   %edi
  800828:	56                   	push   %esi
  800829:	53                   	push   %ebx
  80082a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80082d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800832:	b8 1b 00 00 00       	mov    $0x1b,%eax
  800837:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083a:	8b 55 08             	mov    0x8(%ebp),%edx
  80083d:	89 df                	mov    %ebx,%edi
  80083f:	89 de                	mov    %ebx,%esi
  800841:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800843:	85 c0                	test   %eax,%eax
  800845:	7e 28                	jle    80086f <sys_env_set_algchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800847:	89 44 24 10          	mov    %eax,0x10(%esp)
  80084b:	c7 44 24 0c 1b 00 00 	movl   $0x1b,0xc(%esp)
  800852:	00 
  800853:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  80085a:	00 
  80085b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800862:	00 
  800863:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  80086a:	e8 b1 00 00 00       	call   800920 <_panic>
}

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_algchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80086f:	83 c4 2c             	add    $0x2c,%esp
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5f                   	pop    %edi
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <sys_env_set_mchchk_upcall>:

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	57                   	push   %edi
  80087b:	56                   	push   %esi
  80087c:	53                   	push   %ebx
  80087d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800880:	bb 00 00 00 00       	mov    $0x0,%ebx
  800885:	b8 1c 00 00 00       	mov    $0x1c,%eax
  80088a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088d:	8b 55 08             	mov    0x8(%ebp),%edx
  800890:	89 df                	mov    %ebx,%edi
  800892:	89 de                	mov    %ebx,%esi
  800894:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800896:	85 c0                	test   %eax,%eax
  800898:	7e 28                	jle    8008c2 <sys_env_set_mchchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80089a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80089e:	c7 44 24 0c 1c 00 00 	movl   $0x1c,0xc(%esp)
  8008a5:	00 
  8008a6:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  8008ad:	00 
  8008ae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8008b5:	00 
  8008b6:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  8008bd:	e8 5e 00 00 00       	call   800920 <_panic>
}

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_mchchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8008c2:	83 c4 2c             	add    $0x2c,%esp
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5f                   	pop    %edi
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <sys_env_set_SIMDfperror_upcall>:

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	57                   	push   %edi
  8008ce:	56                   	push   %esi
  8008cf:	53                   	push   %ebx
  8008d0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8008d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008d8:	b8 1d 00 00 00       	mov    $0x1d,%eax
  8008dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008e3:	89 df                	mov    %ebx,%edi
  8008e5:	89 de                	mov    %ebx,%esi
  8008e7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8008e9:	85 c0                	test   %eax,%eax
  8008eb:	7e 28                	jle    800915 <sys_env_set_SIMDfperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8008ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8008f1:	c7 44 24 0c 1d 00 00 	movl   $0x1d,0xc(%esp)
  8008f8:	00 
  8008f9:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  800900:	00 
  800901:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800908:	00 
  800909:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  800910:	e8 0b 00 00 00       	call   800920 <_panic>
}

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_SIMDfperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800915:	83 c4 2c             	add    $0x2c,%esp
  800918:	5b                   	pop    %ebx
  800919:	5e                   	pop    %esi
  80091a:	5f                   	pop    %edi
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    
  80091d:	00 00                	add    %al,(%eax)
	...

00800920 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	56                   	push   %esi
  800924:	53                   	push   %ebx
  800925:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800928:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80092b:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  800931:	e8 11 f8 ff ff       	call   800147 <sys_getenvid>
  800936:	8b 55 0c             	mov    0xc(%ebp),%edx
  800939:	89 54 24 10          	mov    %edx,0x10(%esp)
  80093d:	8b 55 08             	mov    0x8(%ebp),%edx
  800940:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800944:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800948:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094c:	c7 04 24 84 15 80 00 	movl   $0x801584,(%esp)
  800953:	e8 c0 00 00 00       	call   800a18 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800958:	89 74 24 04          	mov    %esi,0x4(%esp)
  80095c:	8b 45 10             	mov    0x10(%ebp),%eax
  80095f:	89 04 24             	mov    %eax,(%esp)
  800962:	e8 50 00 00 00       	call   8009b7 <vcprintf>
	cprintf("\n");
  800967:	c7 04 24 4c 15 80 00 	movl   $0x80154c,(%esp)
  80096e:	e8 a5 00 00 00       	call   800a18 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800973:	cc                   	int3   
  800974:	eb fd                	jmp    800973 <_panic+0x53>
	...

00800978 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	53                   	push   %ebx
  80097c:	83 ec 14             	sub    $0x14,%esp
  80097f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800982:	8b 03                	mov    (%ebx),%eax
  800984:	8b 55 08             	mov    0x8(%ebp),%edx
  800987:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80098b:	40                   	inc    %eax
  80098c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80098e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800993:	75 19                	jne    8009ae <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800995:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80099c:	00 
  80099d:	8d 43 08             	lea    0x8(%ebx),%eax
  8009a0:	89 04 24             	mov    %eax,(%esp)
  8009a3:	e8 10 f7 ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  8009a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8009ae:	ff 43 04             	incl   0x4(%ebx)
}
  8009b1:	83 c4 14             	add    $0x14,%esp
  8009b4:	5b                   	pop    %ebx
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8009c0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8009c7:	00 00 00 
	b.cnt = 0;
  8009ca:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8009d1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8009d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8009e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ec:	c7 04 24 78 09 80 00 	movl   $0x800978,(%esp)
  8009f3:	e8 b4 01 00 00       	call   800bac <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8009f8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8009fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a02:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800a08:	89 04 24             	mov    %eax,(%esp)
  800a0b:	e8 a8 f6 ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  800a10:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800a16:	c9                   	leave  
  800a17:	c3                   	ret    

00800a18 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800a1e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800a21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a25:	8b 45 08             	mov    0x8(%ebp),%eax
  800a28:	89 04 24             	mov    %eax,(%esp)
  800a2b:	e8 87 ff ff ff       	call   8009b7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800a30:	c9                   	leave  
  800a31:	c3                   	ret    
	...

00800a34 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	53                   	push   %ebx
  800a3a:	83 ec 3c             	sub    $0x3c,%esp
  800a3d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a40:	89 d7                	mov    %edx,%edi
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
  800a45:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a4e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800a51:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800a54:	85 c0                	test   %eax,%eax
  800a56:	75 08                	jne    800a60 <printnum+0x2c>
  800a58:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a5b:	39 45 10             	cmp    %eax,0x10(%ebp)
  800a5e:	77 57                	ja     800ab7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800a60:	89 74 24 10          	mov    %esi,0x10(%esp)
  800a64:	4b                   	dec    %ebx
  800a65:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800a69:	8b 45 10             	mov    0x10(%ebp),%eax
  800a6c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a70:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800a74:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800a78:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a7f:	00 
  800a80:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a83:	89 04 24             	mov    %eax,(%esp)
  800a86:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a89:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8d:	e8 5a 08 00 00       	call   8012ec <__udivdi3>
  800a92:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a96:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a9a:	89 04 24             	mov    %eax,(%esp)
  800a9d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aa1:	89 fa                	mov    %edi,%edx
  800aa3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800aa6:	e8 89 ff ff ff       	call   800a34 <printnum>
  800aab:	eb 0f                	jmp    800abc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800aad:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ab1:	89 34 24             	mov    %esi,(%esp)
  800ab4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800ab7:	4b                   	dec    %ebx
  800ab8:	85 db                	test   %ebx,%ebx
  800aba:	7f f1                	jg     800aad <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800abc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ac0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ac4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ac7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800acb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ad2:	00 
  800ad3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ad6:	89 04 24             	mov    %eax,(%esp)
  800ad9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800adc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae0:	e8 27 09 00 00       	call   80140c <__umoddi3>
  800ae5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ae9:	0f be 80 a8 15 80 00 	movsbl 0x8015a8(%eax),%eax
  800af0:	89 04 24             	mov    %eax,(%esp)
  800af3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800af6:	83 c4 3c             	add    $0x3c,%esp
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800b01:	83 fa 01             	cmp    $0x1,%edx
  800b04:	7e 0e                	jle    800b14 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800b06:	8b 10                	mov    (%eax),%edx
  800b08:	8d 4a 08             	lea    0x8(%edx),%ecx
  800b0b:	89 08                	mov    %ecx,(%eax)
  800b0d:	8b 02                	mov    (%edx),%eax
  800b0f:	8b 52 04             	mov    0x4(%edx),%edx
  800b12:	eb 22                	jmp    800b36 <getuint+0x38>
	else if (lflag)
  800b14:	85 d2                	test   %edx,%edx
  800b16:	74 10                	je     800b28 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800b18:	8b 10                	mov    (%eax),%edx
  800b1a:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b1d:	89 08                	mov    %ecx,(%eax)
  800b1f:	8b 02                	mov    (%edx),%eax
  800b21:	ba 00 00 00 00       	mov    $0x0,%edx
  800b26:	eb 0e                	jmp    800b36 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800b28:	8b 10                	mov    (%eax),%edx
  800b2a:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b2d:	89 08                	mov    %ecx,(%eax)
  800b2f:	8b 02                	mov    (%edx),%eax
  800b31:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800b3b:	83 fa 01             	cmp    $0x1,%edx
  800b3e:	7e 0e                	jle    800b4e <getint+0x16>
		return va_arg(*ap, long long);
  800b40:	8b 10                	mov    (%eax),%edx
  800b42:	8d 4a 08             	lea    0x8(%edx),%ecx
  800b45:	89 08                	mov    %ecx,(%eax)
  800b47:	8b 02                	mov    (%edx),%eax
  800b49:	8b 52 04             	mov    0x4(%edx),%edx
  800b4c:	eb 1a                	jmp    800b68 <getint+0x30>
	else if (lflag)
  800b4e:	85 d2                	test   %edx,%edx
  800b50:	74 0c                	je     800b5e <getint+0x26>
		return va_arg(*ap, long);
  800b52:	8b 10                	mov    (%eax),%edx
  800b54:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b57:	89 08                	mov    %ecx,(%eax)
  800b59:	8b 02                	mov    (%edx),%eax
  800b5b:	99                   	cltd   
  800b5c:	eb 0a                	jmp    800b68 <getint+0x30>
	else
		return va_arg(*ap, int);
  800b5e:	8b 10                	mov    (%eax),%edx
  800b60:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b63:	89 08                	mov    %ecx,(%eax)
  800b65:	8b 02                	mov    (%edx),%eax
  800b67:	99                   	cltd   
}
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800b70:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800b73:	8b 10                	mov    (%eax),%edx
  800b75:	3b 50 04             	cmp    0x4(%eax),%edx
  800b78:	73 08                	jae    800b82 <sprintputch+0x18>
		*b->buf++ = ch;
  800b7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7d:	88 0a                	mov    %cl,(%edx)
  800b7f:	42                   	inc    %edx
  800b80:	89 10                	mov    %edx,(%eax)
}
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800b8a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800b8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b91:	8b 45 10             	mov    0x10(%ebp),%eax
  800b94:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba2:	89 04 24             	mov    %eax,(%esp)
  800ba5:	e8 02 00 00 00       	call   800bac <vprintfmt>
	va_end(ap);
}
  800baa:	c9                   	leave  
  800bab:	c3                   	ret    

00800bac <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	83 ec 4c             	sub    $0x4c,%esp
  800bb5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bb8:	8b 75 10             	mov    0x10(%ebp),%esi
  800bbb:	eb 12                	jmp    800bcf <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	0f 84 40 03 00 00    	je     800f05 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800bc5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bc9:	89 04 24             	mov    %eax,(%esp)
  800bcc:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800bcf:	0f b6 06             	movzbl (%esi),%eax
  800bd2:	46                   	inc    %esi
  800bd3:	83 f8 25             	cmp    $0x25,%eax
  800bd6:	75 e5                	jne    800bbd <vprintfmt+0x11>
  800bd8:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800bdc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800be3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800be8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800bef:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf4:	eb 26                	jmp    800c1c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bf6:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800bf9:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800bfd:	eb 1d                	jmp    800c1c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800c02:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800c06:	eb 14                	jmp    800c1c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c08:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800c0b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800c12:	eb 08                	jmp    800c1c <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800c14:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800c17:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c1c:	0f b6 06             	movzbl (%esi),%eax
  800c1f:	8d 4e 01             	lea    0x1(%esi),%ecx
  800c22:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800c25:	8a 0e                	mov    (%esi),%cl
  800c27:	83 e9 23             	sub    $0x23,%ecx
  800c2a:	80 f9 55             	cmp    $0x55,%cl
  800c2d:	0f 87 b6 02 00 00    	ja     800ee9 <vprintfmt+0x33d>
  800c33:	0f b6 c9             	movzbl %cl,%ecx
  800c36:	ff 24 8d 60 16 80 00 	jmp    *0x801660(,%ecx,4)
  800c3d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c40:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800c45:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800c48:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  800c4c:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800c4f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800c52:	83 f9 09             	cmp    $0x9,%ecx
  800c55:	77 2a                	ja     800c81 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c57:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800c58:	eb eb                	jmp    800c45 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800c5a:	8b 45 14             	mov    0x14(%ebp),%eax
  800c5d:	8d 48 04             	lea    0x4(%eax),%ecx
  800c60:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800c63:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c65:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800c68:	eb 17                	jmp    800c81 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800c6a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c6e:	78 98                	js     800c08 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c70:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c73:	eb a7                	jmp    800c1c <vprintfmt+0x70>
  800c75:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800c78:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800c7f:	eb 9b                	jmp    800c1c <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800c81:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c85:	79 95                	jns    800c1c <vprintfmt+0x70>
  800c87:	eb 8b                	jmp    800c14 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800c89:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c8a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800c8d:	eb 8d                	jmp    800c1c <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800c8f:	8b 45 14             	mov    0x14(%ebp),%eax
  800c92:	8d 50 04             	lea    0x4(%eax),%edx
  800c95:	89 55 14             	mov    %edx,0x14(%ebp)
  800c98:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c9c:	8b 00                	mov    (%eax),%eax
  800c9e:	89 04 24             	mov    %eax,(%esp)
  800ca1:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800ca7:	e9 23 ff ff ff       	jmp    800bcf <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800cac:	8b 45 14             	mov    0x14(%ebp),%eax
  800caf:	8d 50 04             	lea    0x4(%eax),%edx
  800cb2:	89 55 14             	mov    %edx,0x14(%ebp)
  800cb5:	8b 00                	mov    (%eax),%eax
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	79 02                	jns    800cbd <vprintfmt+0x111>
  800cbb:	f7 d8                	neg    %eax
  800cbd:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800cbf:	83 f8 09             	cmp    $0x9,%eax
  800cc2:	7f 0b                	jg     800ccf <vprintfmt+0x123>
  800cc4:	8b 04 85 c0 17 80 00 	mov    0x8017c0(,%eax,4),%eax
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	75 23                	jne    800cf2 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800ccf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cd3:	c7 44 24 08 c0 15 80 	movl   $0x8015c0,0x8(%esp)
  800cda:	00 
  800cdb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce2:	89 04 24             	mov    %eax,(%esp)
  800ce5:	e8 9a fe ff ff       	call   800b84 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cea:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800ced:	e9 dd fe ff ff       	jmp    800bcf <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800cf2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cf6:	c7 44 24 08 c9 15 80 	movl   $0x8015c9,0x8(%esp)
  800cfd:	00 
  800cfe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d02:	8b 55 08             	mov    0x8(%ebp),%edx
  800d05:	89 14 24             	mov    %edx,(%esp)
  800d08:	e8 77 fe ff ff       	call   800b84 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d0d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d10:	e9 ba fe ff ff       	jmp    800bcf <vprintfmt+0x23>
  800d15:	89 f9                	mov    %edi,%ecx
  800d17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d1a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d1d:	8b 45 14             	mov    0x14(%ebp),%eax
  800d20:	8d 50 04             	lea    0x4(%eax),%edx
  800d23:	89 55 14             	mov    %edx,0x14(%ebp)
  800d26:	8b 30                	mov    (%eax),%esi
  800d28:	85 f6                	test   %esi,%esi
  800d2a:	75 05                	jne    800d31 <vprintfmt+0x185>
				p = "(null)";
  800d2c:	be b9 15 80 00       	mov    $0x8015b9,%esi
			if (width > 0 && padc != '-')
  800d31:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800d35:	0f 8e 84 00 00 00    	jle    800dbf <vprintfmt+0x213>
  800d3b:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800d3f:	74 7e                	je     800dbf <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800d41:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d45:	89 34 24             	mov    %esi,(%esp)
  800d48:	e8 5d 02 00 00       	call   800faa <strnlen>
  800d4d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800d50:	29 c2                	sub    %eax,%edx
  800d52:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800d55:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800d59:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800d5c:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800d5f:	89 de                	mov    %ebx,%esi
  800d61:	89 d3                	mov    %edx,%ebx
  800d63:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d65:	eb 0b                	jmp    800d72 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800d67:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d6b:	89 3c 24             	mov    %edi,(%esp)
  800d6e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d71:	4b                   	dec    %ebx
  800d72:	85 db                	test   %ebx,%ebx
  800d74:	7f f1                	jg     800d67 <vprintfmt+0x1bb>
  800d76:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800d79:	89 f3                	mov    %esi,%ebx
  800d7b:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800d7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d81:	85 c0                	test   %eax,%eax
  800d83:	79 05                	jns    800d8a <vprintfmt+0x1de>
  800d85:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d8d:	29 c2                	sub    %eax,%edx
  800d8f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800d92:	eb 2b                	jmp    800dbf <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800d94:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800d98:	74 18                	je     800db2 <vprintfmt+0x206>
  800d9a:	8d 50 e0             	lea    -0x20(%eax),%edx
  800d9d:	83 fa 5e             	cmp    $0x5e,%edx
  800da0:	76 10                	jbe    800db2 <vprintfmt+0x206>
					putch('?', putdat);
  800da2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800da6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800dad:	ff 55 08             	call   *0x8(%ebp)
  800db0:	eb 0a                	jmp    800dbc <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800db2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800db6:	89 04 24             	mov    %eax,(%esp)
  800db9:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800dbc:	ff 4d e4             	decl   -0x1c(%ebp)
  800dbf:	0f be 06             	movsbl (%esi),%eax
  800dc2:	46                   	inc    %esi
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	74 21                	je     800de8 <vprintfmt+0x23c>
  800dc7:	85 ff                	test   %edi,%edi
  800dc9:	78 c9                	js     800d94 <vprintfmt+0x1e8>
  800dcb:	4f                   	dec    %edi
  800dcc:	79 c6                	jns    800d94 <vprintfmt+0x1e8>
  800dce:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dd1:	89 de                	mov    %ebx,%esi
  800dd3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800dd6:	eb 18                	jmp    800df0 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800dd8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ddc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800de3:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800de5:	4b                   	dec    %ebx
  800de6:	eb 08                	jmp    800df0 <vprintfmt+0x244>
  800de8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800deb:	89 de                	mov    %ebx,%esi
  800ded:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800df0:	85 db                	test   %ebx,%ebx
  800df2:	7f e4                	jg     800dd8 <vprintfmt+0x22c>
  800df4:	89 7d 08             	mov    %edi,0x8(%ebp)
  800df7:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800df9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800dfc:	e9 ce fd ff ff       	jmp    800bcf <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800e01:	8d 45 14             	lea    0x14(%ebp),%eax
  800e04:	e8 2f fd ff ff       	call   800b38 <getint>
  800e09:	89 c6                	mov    %eax,%esi
  800e0b:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800e0d:	85 d2                	test   %edx,%edx
  800e0f:	78 07                	js     800e18 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800e11:	be 0a 00 00 00       	mov    $0xa,%esi
  800e16:	eb 7e                	jmp    800e96 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800e18:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e1c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800e23:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800e26:	89 f0                	mov    %esi,%eax
  800e28:	89 fa                	mov    %edi,%edx
  800e2a:	f7 d8                	neg    %eax
  800e2c:	83 d2 00             	adc    $0x0,%edx
  800e2f:	f7 da                	neg    %edx
			}
			base = 10;
  800e31:	be 0a 00 00 00       	mov    $0xa,%esi
  800e36:	eb 5e                	jmp    800e96 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800e38:	8d 45 14             	lea    0x14(%ebp),%eax
  800e3b:	e8 be fc ff ff       	call   800afe <getuint>
			base = 10;
  800e40:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800e45:	eb 4f                	jmp    800e96 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800e47:	8d 45 14             	lea    0x14(%ebp),%eax
  800e4a:	e8 af fc ff ff       	call   800afe <getuint>
			base = 8;
  800e4f:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800e54:	eb 40                	jmp    800e96 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  800e56:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e5a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800e61:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800e64:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e68:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800e6f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800e72:	8b 45 14             	mov    0x14(%ebp),%eax
  800e75:	8d 50 04             	lea    0x4(%eax),%edx
  800e78:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800e7b:	8b 00                	mov    (%eax),%eax
  800e7d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800e82:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800e87:	eb 0d                	jmp    800e96 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800e89:	8d 45 14             	lea    0x14(%ebp),%eax
  800e8c:	e8 6d fc ff ff       	call   800afe <getuint>
			base = 16;
  800e91:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800e96:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800e9a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800e9e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800ea1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ea5:	89 74 24 08          	mov    %esi,0x8(%esp)
  800ea9:	89 04 24             	mov    %eax,(%esp)
  800eac:	89 54 24 04          	mov    %edx,0x4(%esp)
  800eb0:	89 da                	mov    %ebx,%edx
  800eb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb5:	e8 7a fb ff ff       	call   800a34 <printnum>
			break;
  800eba:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ebd:	e9 0d fd ff ff       	jmp    800bcf <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  800ec2:	8d 45 14             	lea    0x14(%ebp),%eax
  800ec5:	e8 6e fc ff ff       	call   800b38 <getint>
  800eca:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ecf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  800ed2:	e9 f8 fc ff ff       	jmp    800bcf <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ed7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800edb:	89 04 24             	mov    %eax,(%esp)
  800ede:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ee1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ee4:	e9 e6 fc ff ff       	jmp    800bcf <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ee9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800eed:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ef4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ef7:	eb 01                	jmp    800efa <vprintfmt+0x34e>
  800ef9:	4e                   	dec    %esi
  800efa:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800efe:	75 f9                	jne    800ef9 <vprintfmt+0x34d>
  800f00:	e9 ca fc ff ff       	jmp    800bcf <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800f05:	83 c4 4c             	add    $0x4c,%esp
  800f08:	5b                   	pop    %ebx
  800f09:	5e                   	pop    %esi
  800f0a:	5f                   	pop    %edi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    

00800f0d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	83 ec 28             	sub    $0x28,%esp
  800f13:	8b 45 08             	mov    0x8(%ebp),%eax
  800f16:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800f19:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f1c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800f20:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	74 30                	je     800f5e <vsnprintf+0x51>
  800f2e:	85 d2                	test   %edx,%edx
  800f30:	7e 33                	jle    800f65 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f32:	8b 45 14             	mov    0x14(%ebp),%eax
  800f35:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f39:	8b 45 10             	mov    0x10(%ebp),%eax
  800f3c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f40:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f43:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f47:	c7 04 24 6a 0b 80 00 	movl   $0x800b6a,(%esp)
  800f4e:	e8 59 fc ff ff       	call   800bac <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f53:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f56:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f5c:	eb 0c                	jmp    800f6a <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800f5e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f63:	eb 05                	jmp    800f6a <vsnprintf+0x5d>
  800f65:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800f6a:	c9                   	leave  
  800f6b:	c3                   	ret    

00800f6c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800f72:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800f75:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f79:	8b 45 10             	mov    0x10(%ebp),%eax
  800f7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f83:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f87:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8a:	89 04 24             	mov    %eax,(%esp)
  800f8d:	e8 7b ff ff ff       	call   800f0d <vsnprintf>
	va_end(ap);

	return rc;
}
  800f92:	c9                   	leave  
  800f93:	c3                   	ret    

00800f94 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800f9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f9f:	eb 01                	jmp    800fa2 <strlen+0xe>
		n++;
  800fa1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800fa2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800fa6:	75 f9                	jne    800fa1 <strlen+0xd>
		n++;
	return n;
}
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800fb0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb8:	eb 01                	jmp    800fbb <strnlen+0x11>
		n++;
  800fba:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fbb:	39 d0                	cmp    %edx,%eax
  800fbd:	74 06                	je     800fc5 <strnlen+0x1b>
  800fbf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800fc3:	75 f5                	jne    800fba <strnlen+0x10>
		n++;
	return n;
}
  800fc5:	5d                   	pop    %ebp
  800fc6:	c3                   	ret    

00800fc7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	53                   	push   %ebx
  800fcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800fd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800fd9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800fdc:	42                   	inc    %edx
  800fdd:	84 c9                	test   %cl,%cl
  800fdf:	75 f5                	jne    800fd6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800fe1:	5b                   	pop    %ebx
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    

00800fe4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	53                   	push   %ebx
  800fe8:	83 ec 08             	sub    $0x8,%esp
  800feb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800fee:	89 1c 24             	mov    %ebx,(%esp)
  800ff1:	e8 9e ff ff ff       	call   800f94 <strlen>
	strcpy(dst + len, src);
  800ff6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ff9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ffd:	01 d8                	add    %ebx,%eax
  800fff:	89 04 24             	mov    %eax,(%esp)
  801002:	e8 c0 ff ff ff       	call   800fc7 <strcpy>
	return dst;
}
  801007:	89 d8                	mov    %ebx,%eax
  801009:	83 c4 08             	add    $0x8,%esp
  80100c:	5b                   	pop    %ebx
  80100d:	5d                   	pop    %ebp
  80100e:	c3                   	ret    

0080100f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
  801012:	56                   	push   %esi
  801013:	53                   	push   %ebx
  801014:	8b 45 08             	mov    0x8(%ebp),%eax
  801017:	8b 55 0c             	mov    0xc(%ebp),%edx
  80101a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80101d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801022:	eb 0c                	jmp    801030 <strncpy+0x21>
		*dst++ = *src;
  801024:	8a 1a                	mov    (%edx),%bl
  801026:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801029:	80 3a 01             	cmpb   $0x1,(%edx)
  80102c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80102f:	41                   	inc    %ecx
  801030:	39 f1                	cmp    %esi,%ecx
  801032:	75 f0                	jne    801024 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    

00801038 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	56                   	push   %esi
  80103c:	53                   	push   %ebx
  80103d:	8b 75 08             	mov    0x8(%ebp),%esi
  801040:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801043:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801046:	85 d2                	test   %edx,%edx
  801048:	75 0a                	jne    801054 <strlcpy+0x1c>
  80104a:	89 f0                	mov    %esi,%eax
  80104c:	eb 1a                	jmp    801068 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80104e:	88 18                	mov    %bl,(%eax)
  801050:	40                   	inc    %eax
  801051:	41                   	inc    %ecx
  801052:	eb 02                	jmp    801056 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801054:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801056:	4a                   	dec    %edx
  801057:	74 0a                	je     801063 <strlcpy+0x2b>
  801059:	8a 19                	mov    (%ecx),%bl
  80105b:	84 db                	test   %bl,%bl
  80105d:	75 ef                	jne    80104e <strlcpy+0x16>
  80105f:	89 c2                	mov    %eax,%edx
  801061:	eb 02                	jmp    801065 <strlcpy+0x2d>
  801063:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801065:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801068:	29 f0                	sub    %esi,%eax
}
  80106a:	5b                   	pop    %ebx
  80106b:	5e                   	pop    %esi
  80106c:	5d                   	pop    %ebp
  80106d:	c3                   	ret    

0080106e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801074:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801077:	eb 02                	jmp    80107b <strcmp+0xd>
		p++, q++;
  801079:	41                   	inc    %ecx
  80107a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80107b:	8a 01                	mov    (%ecx),%al
  80107d:	84 c0                	test   %al,%al
  80107f:	74 04                	je     801085 <strcmp+0x17>
  801081:	3a 02                	cmp    (%edx),%al
  801083:	74 f4                	je     801079 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801085:	0f b6 c0             	movzbl %al,%eax
  801088:	0f b6 12             	movzbl (%edx),%edx
  80108b:	29 d0                	sub    %edx,%eax
}
  80108d:	5d                   	pop    %ebp
  80108e:	c3                   	ret    

0080108f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	53                   	push   %ebx
  801093:	8b 45 08             	mov    0x8(%ebp),%eax
  801096:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801099:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80109c:	eb 03                	jmp    8010a1 <strncmp+0x12>
		n--, p++, q++;
  80109e:	4a                   	dec    %edx
  80109f:	40                   	inc    %eax
  8010a0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8010a1:	85 d2                	test   %edx,%edx
  8010a3:	74 14                	je     8010b9 <strncmp+0x2a>
  8010a5:	8a 18                	mov    (%eax),%bl
  8010a7:	84 db                	test   %bl,%bl
  8010a9:	74 04                	je     8010af <strncmp+0x20>
  8010ab:	3a 19                	cmp    (%ecx),%bl
  8010ad:	74 ef                	je     80109e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8010af:	0f b6 00             	movzbl (%eax),%eax
  8010b2:	0f b6 11             	movzbl (%ecx),%edx
  8010b5:	29 d0                	sub    %edx,%eax
  8010b7:	eb 05                	jmp    8010be <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8010b9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010be:	5b                   	pop    %ebx
  8010bf:	5d                   	pop    %ebp
  8010c0:	c3                   	ret    

008010c1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8010ca:	eb 05                	jmp    8010d1 <strchr+0x10>
		if (*s == c)
  8010cc:	38 ca                	cmp    %cl,%dl
  8010ce:	74 0c                	je     8010dc <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8010d0:	40                   	inc    %eax
  8010d1:	8a 10                	mov    (%eax),%dl
  8010d3:	84 d2                	test   %dl,%dl
  8010d5:	75 f5                	jne    8010cc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8010d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010dc:	5d                   	pop    %ebp
  8010dd:	c3                   	ret    

008010de <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8010e7:	eb 05                	jmp    8010ee <strfind+0x10>
		if (*s == c)
  8010e9:	38 ca                	cmp    %cl,%dl
  8010eb:	74 07                	je     8010f4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8010ed:	40                   	inc    %eax
  8010ee:	8a 10                	mov    (%eax),%dl
  8010f0:	84 d2                	test   %dl,%dl
  8010f2:	75 f5                	jne    8010e9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8010f4:	5d                   	pop    %ebp
  8010f5:	c3                   	ret    

008010f6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	57                   	push   %edi
  8010fa:	56                   	push   %esi
  8010fb:	53                   	push   %ebx
  8010fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801102:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801105:	85 c9                	test   %ecx,%ecx
  801107:	74 30                	je     801139 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801109:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80110f:	75 25                	jne    801136 <memset+0x40>
  801111:	f6 c1 03             	test   $0x3,%cl
  801114:	75 20                	jne    801136 <memset+0x40>
		c &= 0xFF;
  801116:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801119:	89 d3                	mov    %edx,%ebx
  80111b:	c1 e3 08             	shl    $0x8,%ebx
  80111e:	89 d6                	mov    %edx,%esi
  801120:	c1 e6 18             	shl    $0x18,%esi
  801123:	89 d0                	mov    %edx,%eax
  801125:	c1 e0 10             	shl    $0x10,%eax
  801128:	09 f0                	or     %esi,%eax
  80112a:	09 d0                	or     %edx,%eax
  80112c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80112e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801131:	fc                   	cld    
  801132:	f3 ab                	rep stos %eax,%es:(%edi)
  801134:	eb 03                	jmp    801139 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801136:	fc                   	cld    
  801137:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801139:	89 f8                	mov    %edi,%eax
  80113b:	5b                   	pop    %ebx
  80113c:	5e                   	pop    %esi
  80113d:	5f                   	pop    %edi
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    

00801140 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	57                   	push   %edi
  801144:	56                   	push   %esi
  801145:	8b 45 08             	mov    0x8(%ebp),%eax
  801148:	8b 75 0c             	mov    0xc(%ebp),%esi
  80114b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80114e:	39 c6                	cmp    %eax,%esi
  801150:	73 34                	jae    801186 <memmove+0x46>
  801152:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801155:	39 d0                	cmp    %edx,%eax
  801157:	73 2d                	jae    801186 <memmove+0x46>
		s += n;
		d += n;
  801159:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80115c:	f6 c2 03             	test   $0x3,%dl
  80115f:	75 1b                	jne    80117c <memmove+0x3c>
  801161:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801167:	75 13                	jne    80117c <memmove+0x3c>
  801169:	f6 c1 03             	test   $0x3,%cl
  80116c:	75 0e                	jne    80117c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80116e:	83 ef 04             	sub    $0x4,%edi
  801171:	8d 72 fc             	lea    -0x4(%edx),%esi
  801174:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801177:	fd                   	std    
  801178:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80117a:	eb 07                	jmp    801183 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80117c:	4f                   	dec    %edi
  80117d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801180:	fd                   	std    
  801181:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801183:	fc                   	cld    
  801184:	eb 20                	jmp    8011a6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801186:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80118c:	75 13                	jne    8011a1 <memmove+0x61>
  80118e:	a8 03                	test   $0x3,%al
  801190:	75 0f                	jne    8011a1 <memmove+0x61>
  801192:	f6 c1 03             	test   $0x3,%cl
  801195:	75 0a                	jne    8011a1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801197:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80119a:	89 c7                	mov    %eax,%edi
  80119c:	fc                   	cld    
  80119d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80119f:	eb 05                	jmp    8011a6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8011a1:	89 c7                	mov    %eax,%edi
  8011a3:	fc                   	cld    
  8011a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8011a6:	5e                   	pop    %esi
  8011a7:	5f                   	pop    %edi
  8011a8:	5d                   	pop    %ebp
  8011a9:	c3                   	ret    

008011aa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8011b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8011b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011be:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c1:	89 04 24             	mov    %eax,(%esp)
  8011c4:	e8 77 ff ff ff       	call   801140 <memmove>
}
  8011c9:	c9                   	leave  
  8011ca:	c3                   	ret    

008011cb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	57                   	push   %edi
  8011cf:	56                   	push   %esi
  8011d0:	53                   	push   %ebx
  8011d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011da:	ba 00 00 00 00       	mov    $0x0,%edx
  8011df:	eb 16                	jmp    8011f7 <memcmp+0x2c>
		if (*s1 != *s2)
  8011e1:	8a 04 17             	mov    (%edi,%edx,1),%al
  8011e4:	42                   	inc    %edx
  8011e5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8011e9:	38 c8                	cmp    %cl,%al
  8011eb:	74 0a                	je     8011f7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8011ed:	0f b6 c0             	movzbl %al,%eax
  8011f0:	0f b6 c9             	movzbl %cl,%ecx
  8011f3:	29 c8                	sub    %ecx,%eax
  8011f5:	eb 09                	jmp    801200 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011f7:	39 da                	cmp    %ebx,%edx
  8011f9:	75 e6                	jne    8011e1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8011fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801200:	5b                   	pop    %ebx
  801201:	5e                   	pop    %esi
  801202:	5f                   	pop    %edi
  801203:	5d                   	pop    %ebp
  801204:	c3                   	ret    

00801205 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	8b 45 08             	mov    0x8(%ebp),%eax
  80120b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80120e:	89 c2                	mov    %eax,%edx
  801210:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801213:	eb 05                	jmp    80121a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801215:	38 08                	cmp    %cl,(%eax)
  801217:	74 05                	je     80121e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801219:	40                   	inc    %eax
  80121a:	39 d0                	cmp    %edx,%eax
  80121c:	72 f7                	jb     801215 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	57                   	push   %edi
  801224:	56                   	push   %esi
  801225:	53                   	push   %ebx
  801226:	8b 55 08             	mov    0x8(%ebp),%edx
  801229:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80122c:	eb 01                	jmp    80122f <strtol+0xf>
		s++;
  80122e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80122f:	8a 02                	mov    (%edx),%al
  801231:	3c 20                	cmp    $0x20,%al
  801233:	74 f9                	je     80122e <strtol+0xe>
  801235:	3c 09                	cmp    $0x9,%al
  801237:	74 f5                	je     80122e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801239:	3c 2b                	cmp    $0x2b,%al
  80123b:	75 08                	jne    801245 <strtol+0x25>
		s++;
  80123d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80123e:	bf 00 00 00 00       	mov    $0x0,%edi
  801243:	eb 13                	jmp    801258 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801245:	3c 2d                	cmp    $0x2d,%al
  801247:	75 0a                	jne    801253 <strtol+0x33>
		s++, neg = 1;
  801249:	8d 52 01             	lea    0x1(%edx),%edx
  80124c:	bf 01 00 00 00       	mov    $0x1,%edi
  801251:	eb 05                	jmp    801258 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801253:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801258:	85 db                	test   %ebx,%ebx
  80125a:	74 05                	je     801261 <strtol+0x41>
  80125c:	83 fb 10             	cmp    $0x10,%ebx
  80125f:	75 28                	jne    801289 <strtol+0x69>
  801261:	8a 02                	mov    (%edx),%al
  801263:	3c 30                	cmp    $0x30,%al
  801265:	75 10                	jne    801277 <strtol+0x57>
  801267:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80126b:	75 0a                	jne    801277 <strtol+0x57>
		s += 2, base = 16;
  80126d:	83 c2 02             	add    $0x2,%edx
  801270:	bb 10 00 00 00       	mov    $0x10,%ebx
  801275:	eb 12                	jmp    801289 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801277:	85 db                	test   %ebx,%ebx
  801279:	75 0e                	jne    801289 <strtol+0x69>
  80127b:	3c 30                	cmp    $0x30,%al
  80127d:	75 05                	jne    801284 <strtol+0x64>
		s++, base = 8;
  80127f:	42                   	inc    %edx
  801280:	b3 08                	mov    $0x8,%bl
  801282:	eb 05                	jmp    801289 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801284:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801289:	b8 00 00 00 00       	mov    $0x0,%eax
  80128e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801290:	8a 0a                	mov    (%edx),%cl
  801292:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801295:	80 fb 09             	cmp    $0x9,%bl
  801298:	77 08                	ja     8012a2 <strtol+0x82>
			dig = *s - '0';
  80129a:	0f be c9             	movsbl %cl,%ecx
  80129d:	83 e9 30             	sub    $0x30,%ecx
  8012a0:	eb 1e                	jmp    8012c0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8012a2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8012a5:	80 fb 19             	cmp    $0x19,%bl
  8012a8:	77 08                	ja     8012b2 <strtol+0x92>
			dig = *s - 'a' + 10;
  8012aa:	0f be c9             	movsbl %cl,%ecx
  8012ad:	83 e9 57             	sub    $0x57,%ecx
  8012b0:	eb 0e                	jmp    8012c0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8012b2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8012b5:	80 fb 19             	cmp    $0x19,%bl
  8012b8:	77 12                	ja     8012cc <strtol+0xac>
			dig = *s - 'A' + 10;
  8012ba:	0f be c9             	movsbl %cl,%ecx
  8012bd:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8012c0:	39 f1                	cmp    %esi,%ecx
  8012c2:	7d 0c                	jge    8012d0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8012c4:	42                   	inc    %edx
  8012c5:	0f af c6             	imul   %esi,%eax
  8012c8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8012ca:	eb c4                	jmp    801290 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8012cc:	89 c1                	mov    %eax,%ecx
  8012ce:	eb 02                	jmp    8012d2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8012d0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8012d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8012d6:	74 05                	je     8012dd <strtol+0xbd>
		*endptr = (char *) s;
  8012d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012db:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8012dd:	85 ff                	test   %edi,%edi
  8012df:	74 04                	je     8012e5 <strtol+0xc5>
  8012e1:	89 c8                	mov    %ecx,%eax
  8012e3:	f7 d8                	neg    %eax
}
  8012e5:	5b                   	pop    %ebx
  8012e6:	5e                   	pop    %esi
  8012e7:	5f                   	pop    %edi
  8012e8:	5d                   	pop    %ebp
  8012e9:	c3                   	ret    
	...

008012ec <__udivdi3>:
  8012ec:	55                   	push   %ebp
  8012ed:	57                   	push   %edi
  8012ee:	56                   	push   %esi
  8012ef:	83 ec 10             	sub    $0x10,%esp
  8012f2:	8b 74 24 20          	mov    0x20(%esp),%esi
  8012f6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8012fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012fe:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801302:	89 cd                	mov    %ecx,%ebp
  801304:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801308:	85 c0                	test   %eax,%eax
  80130a:	75 2c                	jne    801338 <__udivdi3+0x4c>
  80130c:	39 f9                	cmp    %edi,%ecx
  80130e:	77 68                	ja     801378 <__udivdi3+0x8c>
  801310:	85 c9                	test   %ecx,%ecx
  801312:	75 0b                	jne    80131f <__udivdi3+0x33>
  801314:	b8 01 00 00 00       	mov    $0x1,%eax
  801319:	31 d2                	xor    %edx,%edx
  80131b:	f7 f1                	div    %ecx
  80131d:	89 c1                	mov    %eax,%ecx
  80131f:	31 d2                	xor    %edx,%edx
  801321:	89 f8                	mov    %edi,%eax
  801323:	f7 f1                	div    %ecx
  801325:	89 c7                	mov    %eax,%edi
  801327:	89 f0                	mov    %esi,%eax
  801329:	f7 f1                	div    %ecx
  80132b:	89 c6                	mov    %eax,%esi
  80132d:	89 f0                	mov    %esi,%eax
  80132f:	89 fa                	mov    %edi,%edx
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	5e                   	pop    %esi
  801335:	5f                   	pop    %edi
  801336:	5d                   	pop    %ebp
  801337:	c3                   	ret    
  801338:	39 f8                	cmp    %edi,%eax
  80133a:	77 2c                	ja     801368 <__udivdi3+0x7c>
  80133c:	0f bd f0             	bsr    %eax,%esi
  80133f:	83 f6 1f             	xor    $0x1f,%esi
  801342:	75 4c                	jne    801390 <__udivdi3+0xa4>
  801344:	39 f8                	cmp    %edi,%eax
  801346:	bf 00 00 00 00       	mov    $0x0,%edi
  80134b:	72 0a                	jb     801357 <__udivdi3+0x6b>
  80134d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801351:	0f 87 ad 00 00 00    	ja     801404 <__udivdi3+0x118>
  801357:	be 01 00 00 00       	mov    $0x1,%esi
  80135c:	89 f0                	mov    %esi,%eax
  80135e:	89 fa                	mov    %edi,%edx
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	5e                   	pop    %esi
  801364:	5f                   	pop    %edi
  801365:	5d                   	pop    %ebp
  801366:	c3                   	ret    
  801367:	90                   	nop
  801368:	31 ff                	xor    %edi,%edi
  80136a:	31 f6                	xor    %esi,%esi
  80136c:	89 f0                	mov    %esi,%eax
  80136e:	89 fa                	mov    %edi,%edx
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	5e                   	pop    %esi
  801374:	5f                   	pop    %edi
  801375:	5d                   	pop    %ebp
  801376:	c3                   	ret    
  801377:	90                   	nop
  801378:	89 fa                	mov    %edi,%edx
  80137a:	89 f0                	mov    %esi,%eax
  80137c:	f7 f1                	div    %ecx
  80137e:	89 c6                	mov    %eax,%esi
  801380:	31 ff                	xor    %edi,%edi
  801382:	89 f0                	mov    %esi,%eax
  801384:	89 fa                	mov    %edi,%edx
  801386:	83 c4 10             	add    $0x10,%esp
  801389:	5e                   	pop    %esi
  80138a:	5f                   	pop    %edi
  80138b:	5d                   	pop    %ebp
  80138c:	c3                   	ret    
  80138d:	8d 76 00             	lea    0x0(%esi),%esi
  801390:	89 f1                	mov    %esi,%ecx
  801392:	d3 e0                	shl    %cl,%eax
  801394:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801398:	b8 20 00 00 00       	mov    $0x20,%eax
  80139d:	29 f0                	sub    %esi,%eax
  80139f:	89 ea                	mov    %ebp,%edx
  8013a1:	88 c1                	mov    %al,%cl
  8013a3:	d3 ea                	shr    %cl,%edx
  8013a5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8013a9:	09 ca                	or     %ecx,%edx
  8013ab:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013af:	89 f1                	mov    %esi,%ecx
  8013b1:	d3 e5                	shl    %cl,%ebp
  8013b3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8013b7:	89 fd                	mov    %edi,%ebp
  8013b9:	88 c1                	mov    %al,%cl
  8013bb:	d3 ed                	shr    %cl,%ebp
  8013bd:	89 fa                	mov    %edi,%edx
  8013bf:	89 f1                	mov    %esi,%ecx
  8013c1:	d3 e2                	shl    %cl,%edx
  8013c3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013c7:	88 c1                	mov    %al,%cl
  8013c9:	d3 ef                	shr    %cl,%edi
  8013cb:	09 d7                	or     %edx,%edi
  8013cd:	89 f8                	mov    %edi,%eax
  8013cf:	89 ea                	mov    %ebp,%edx
  8013d1:	f7 74 24 08          	divl   0x8(%esp)
  8013d5:	89 d1                	mov    %edx,%ecx
  8013d7:	89 c7                	mov    %eax,%edi
  8013d9:	f7 64 24 0c          	mull   0xc(%esp)
  8013dd:	39 d1                	cmp    %edx,%ecx
  8013df:	72 17                	jb     8013f8 <__udivdi3+0x10c>
  8013e1:	74 09                	je     8013ec <__udivdi3+0x100>
  8013e3:	89 fe                	mov    %edi,%esi
  8013e5:	31 ff                	xor    %edi,%edi
  8013e7:	e9 41 ff ff ff       	jmp    80132d <__udivdi3+0x41>
  8013ec:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013f0:	89 f1                	mov    %esi,%ecx
  8013f2:	d3 e2                	shl    %cl,%edx
  8013f4:	39 c2                	cmp    %eax,%edx
  8013f6:	73 eb                	jae    8013e3 <__udivdi3+0xf7>
  8013f8:	8d 77 ff             	lea    -0x1(%edi),%esi
  8013fb:	31 ff                	xor    %edi,%edi
  8013fd:	e9 2b ff ff ff       	jmp    80132d <__udivdi3+0x41>
  801402:	66 90                	xchg   %ax,%ax
  801404:	31 f6                	xor    %esi,%esi
  801406:	e9 22 ff ff ff       	jmp    80132d <__udivdi3+0x41>
	...

0080140c <__umoddi3>:
  80140c:	55                   	push   %ebp
  80140d:	57                   	push   %edi
  80140e:	56                   	push   %esi
  80140f:	83 ec 20             	sub    $0x20,%esp
  801412:	8b 44 24 30          	mov    0x30(%esp),%eax
  801416:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80141a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80141e:	8b 74 24 34          	mov    0x34(%esp),%esi
  801422:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801426:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80142a:	89 c7                	mov    %eax,%edi
  80142c:	89 f2                	mov    %esi,%edx
  80142e:	85 ed                	test   %ebp,%ebp
  801430:	75 16                	jne    801448 <__umoddi3+0x3c>
  801432:	39 f1                	cmp    %esi,%ecx
  801434:	0f 86 a6 00 00 00    	jbe    8014e0 <__umoddi3+0xd4>
  80143a:	f7 f1                	div    %ecx
  80143c:	89 d0                	mov    %edx,%eax
  80143e:	31 d2                	xor    %edx,%edx
  801440:	83 c4 20             	add    $0x20,%esp
  801443:	5e                   	pop    %esi
  801444:	5f                   	pop    %edi
  801445:	5d                   	pop    %ebp
  801446:	c3                   	ret    
  801447:	90                   	nop
  801448:	39 f5                	cmp    %esi,%ebp
  80144a:	0f 87 ac 00 00 00    	ja     8014fc <__umoddi3+0xf0>
  801450:	0f bd c5             	bsr    %ebp,%eax
  801453:	83 f0 1f             	xor    $0x1f,%eax
  801456:	89 44 24 10          	mov    %eax,0x10(%esp)
  80145a:	0f 84 a8 00 00 00    	je     801508 <__umoddi3+0xfc>
  801460:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801464:	d3 e5                	shl    %cl,%ebp
  801466:	bf 20 00 00 00       	mov    $0x20,%edi
  80146b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80146f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801473:	89 f9                	mov    %edi,%ecx
  801475:	d3 e8                	shr    %cl,%eax
  801477:	09 e8                	or     %ebp,%eax
  801479:	89 44 24 18          	mov    %eax,0x18(%esp)
  80147d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801481:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801485:	d3 e0                	shl    %cl,%eax
  801487:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80148b:	89 f2                	mov    %esi,%edx
  80148d:	d3 e2                	shl    %cl,%edx
  80148f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801493:	d3 e0                	shl    %cl,%eax
  801495:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801499:	8b 44 24 14          	mov    0x14(%esp),%eax
  80149d:	89 f9                	mov    %edi,%ecx
  80149f:	d3 e8                	shr    %cl,%eax
  8014a1:	09 d0                	or     %edx,%eax
  8014a3:	d3 ee                	shr    %cl,%esi
  8014a5:	89 f2                	mov    %esi,%edx
  8014a7:	f7 74 24 18          	divl   0x18(%esp)
  8014ab:	89 d6                	mov    %edx,%esi
  8014ad:	f7 64 24 0c          	mull   0xc(%esp)
  8014b1:	89 c5                	mov    %eax,%ebp
  8014b3:	89 d1                	mov    %edx,%ecx
  8014b5:	39 d6                	cmp    %edx,%esi
  8014b7:	72 67                	jb     801520 <__umoddi3+0x114>
  8014b9:	74 75                	je     801530 <__umoddi3+0x124>
  8014bb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8014bf:	29 e8                	sub    %ebp,%eax
  8014c1:	19 ce                	sbb    %ecx,%esi
  8014c3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014c7:	d3 e8                	shr    %cl,%eax
  8014c9:	89 f2                	mov    %esi,%edx
  8014cb:	89 f9                	mov    %edi,%ecx
  8014cd:	d3 e2                	shl    %cl,%edx
  8014cf:	09 d0                	or     %edx,%eax
  8014d1:	89 f2                	mov    %esi,%edx
  8014d3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014d7:	d3 ea                	shr    %cl,%edx
  8014d9:	83 c4 20             	add    $0x20,%esp
  8014dc:	5e                   	pop    %esi
  8014dd:	5f                   	pop    %edi
  8014de:	5d                   	pop    %ebp
  8014df:	c3                   	ret    
  8014e0:	85 c9                	test   %ecx,%ecx
  8014e2:	75 0b                	jne    8014ef <__umoddi3+0xe3>
  8014e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e9:	31 d2                	xor    %edx,%edx
  8014eb:	f7 f1                	div    %ecx
  8014ed:	89 c1                	mov    %eax,%ecx
  8014ef:	89 f0                	mov    %esi,%eax
  8014f1:	31 d2                	xor    %edx,%edx
  8014f3:	f7 f1                	div    %ecx
  8014f5:	89 f8                	mov    %edi,%eax
  8014f7:	e9 3e ff ff ff       	jmp    80143a <__umoddi3+0x2e>
  8014fc:	89 f2                	mov    %esi,%edx
  8014fe:	83 c4 20             	add    $0x20,%esp
  801501:	5e                   	pop    %esi
  801502:	5f                   	pop    %edi
  801503:	5d                   	pop    %ebp
  801504:	c3                   	ret    
  801505:	8d 76 00             	lea    0x0(%esi),%esi
  801508:	39 f5                	cmp    %esi,%ebp
  80150a:	72 04                	jb     801510 <__umoddi3+0x104>
  80150c:	39 f9                	cmp    %edi,%ecx
  80150e:	77 06                	ja     801516 <__umoddi3+0x10a>
  801510:	89 f2                	mov    %esi,%edx
  801512:	29 cf                	sub    %ecx,%edi
  801514:	19 ea                	sbb    %ebp,%edx
  801516:	89 f8                	mov    %edi,%eax
  801518:	83 c4 20             	add    $0x20,%esp
  80151b:	5e                   	pop    %esi
  80151c:	5f                   	pop    %edi
  80151d:	5d                   	pop    %ebp
  80151e:	c3                   	ret    
  80151f:	90                   	nop
  801520:	89 d1                	mov    %edx,%ecx
  801522:	89 c5                	mov    %eax,%ebp
  801524:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801528:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80152c:	eb 8d                	jmp    8014bb <__umoddi3+0xaf>
  80152e:	66 90                	xchg   %ax,%ax
  801530:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801534:	72 ea                	jb     801520 <__umoddi3+0x114>
  801536:	89 f1                	mov    %esi,%ecx
  801538:	eb 81                	jmp    8014bb <__umoddi3+0xaf>
