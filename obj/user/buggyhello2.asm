
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
  80006c:	8d 14 80             	lea    (%eax,%eax,4),%edx
  80006f:	8d 04 50             	lea    (%eax,%edx,2),%eax
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
  800123:	c7 44 24 08 38 10 80 	movl   $0x801038,0x8(%esp)
  80012a:	00 
  80012b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800132:	00 
  800133:	c7 04 24 55 10 80 00 	movl   $0x801055,(%esp)
  80013a:	e8 b1 02 00 00       	call   8003f0 <_panic>

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
  8001b5:	c7 44 24 08 38 10 80 	movl   $0x801038,0x8(%esp)
  8001bc:	00 
  8001bd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c4:	00 
  8001c5:	c7 04 24 55 10 80 00 	movl   $0x801055,(%esp)
  8001cc:	e8 1f 02 00 00       	call   8003f0 <_panic>

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
  800208:	c7 44 24 08 38 10 80 	movl   $0x801038,0x8(%esp)
  80020f:	00 
  800210:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800217:	00 
  800218:	c7 04 24 55 10 80 00 	movl   $0x801055,(%esp)
  80021f:	e8 cc 01 00 00       	call   8003f0 <_panic>

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
  80025b:	c7 44 24 08 38 10 80 	movl   $0x801038,0x8(%esp)
  800262:	00 
  800263:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026a:	00 
  80026b:	c7 04 24 55 10 80 00 	movl   $0x801055,(%esp)
  800272:	e8 79 01 00 00       	call   8003f0 <_panic>

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
  8002ae:	c7 44 24 08 38 10 80 	movl   $0x801038,0x8(%esp)
  8002b5:	00 
  8002b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002bd:	00 
  8002be:	c7 04 24 55 10 80 00 	movl   $0x801055,(%esp)
  8002c5:	e8 26 01 00 00       	call   8003f0 <_panic>

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
  800301:	c7 44 24 08 38 10 80 	movl   $0x801038,0x8(%esp)
  800308:	00 
  800309:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800310:	00 
  800311:	c7 04 24 55 10 80 00 	movl   $0x801055,(%esp)
  800318:	e8 d3 00 00 00       	call   8003f0 <_panic>

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
  800376:	c7 44 24 08 38 10 80 	movl   $0x801038,0x8(%esp)
  80037d:	00 
  80037e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800385:	00 
  800386:	c7 04 24 55 10 80 00 	movl   $0x801055,(%esp)
  80038d:	e8 5e 00 00 00       	call   8003f0 <_panic>

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
  8003c9:	c7 44 24 08 38 10 80 	movl   $0x801038,0x8(%esp)
  8003d0:	00 
  8003d1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d8:	00 
  8003d9:	c7 04 24 55 10 80 00 	movl   $0x801055,(%esp)
  8003e0:	e8 0b 00 00 00       	call   8003f0 <_panic>
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
  8003ed:	00 00                	add    %al,(%eax)
	...

008003f0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	56                   	push   %esi
  8003f4:	53                   	push   %ebx
  8003f5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003f8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003fb:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  800401:	e8 41 fd ff ff       	call   800147 <sys_getenvid>
  800406:	8b 55 0c             	mov    0xc(%ebp),%edx
  800409:	89 54 24 10          	mov    %edx,0x10(%esp)
  80040d:	8b 55 08             	mov    0x8(%ebp),%edx
  800410:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800414:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800418:	89 44 24 04          	mov    %eax,0x4(%esp)
  80041c:	c7 04 24 64 10 80 00 	movl   $0x801064,(%esp)
  800423:	e8 c0 00 00 00       	call   8004e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800428:	89 74 24 04          	mov    %esi,0x4(%esp)
  80042c:	8b 45 10             	mov    0x10(%ebp),%eax
  80042f:	89 04 24             	mov    %eax,(%esp)
  800432:	e8 50 00 00 00       	call   800487 <vcprintf>
	cprintf("\n");
  800437:	c7 04 24 2c 10 80 00 	movl   $0x80102c,(%esp)
  80043e:	e8 a5 00 00 00       	call   8004e8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800443:	cc                   	int3   
  800444:	eb fd                	jmp    800443 <_panic+0x53>
	...

00800448 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	53                   	push   %ebx
  80044c:	83 ec 14             	sub    $0x14,%esp
  80044f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800452:	8b 03                	mov    (%ebx),%eax
  800454:	8b 55 08             	mov    0x8(%ebp),%edx
  800457:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80045b:	40                   	inc    %eax
  80045c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80045e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800463:	75 19                	jne    80047e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800465:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80046c:	00 
  80046d:	8d 43 08             	lea    0x8(%ebx),%eax
  800470:	89 04 24             	mov    %eax,(%esp)
  800473:	e8 40 fc ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  800478:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80047e:	ff 43 04             	incl   0x4(%ebx)
}
  800481:	83 c4 14             	add    $0x14,%esp
  800484:	5b                   	pop    %ebx
  800485:	5d                   	pop    %ebp
  800486:	c3                   	ret    

00800487 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800487:	55                   	push   %ebp
  800488:	89 e5                	mov    %esp,%ebp
  80048a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800490:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800497:	00 00 00 
	b.cnt = 0;
  80049a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004b2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004bc:	c7 04 24 48 04 80 00 	movl   $0x800448,(%esp)
  8004c3:	e8 b4 01 00 00       	call   80067c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004c8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004d8:	89 04 24             	mov    %eax,(%esp)
  8004db:	e8 d8 fb ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  8004e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004e6:	c9                   	leave  
  8004e7:	c3                   	ret    

008004e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004ee:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f8:	89 04 24             	mov    %eax,(%esp)
  8004fb:	e8 87 ff ff ff       	call   800487 <vcprintf>
	va_end(ap);

	return cnt;
}
  800500:	c9                   	leave  
  800501:	c3                   	ret    
	...

00800504 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	57                   	push   %edi
  800508:	56                   	push   %esi
  800509:	53                   	push   %ebx
  80050a:	83 ec 3c             	sub    $0x3c,%esp
  80050d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800510:	89 d7                	mov    %edx,%edi
  800512:	8b 45 08             	mov    0x8(%ebp),%eax
  800515:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800518:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80051e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800521:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800524:	85 c0                	test   %eax,%eax
  800526:	75 08                	jne    800530 <printnum+0x2c>
  800528:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80052b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80052e:	77 57                	ja     800587 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800530:	89 74 24 10          	mov    %esi,0x10(%esp)
  800534:	4b                   	dec    %ebx
  800535:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800539:	8b 45 10             	mov    0x10(%ebp),%eax
  80053c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800540:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800544:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800548:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80054f:	00 
  800550:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800553:	89 04 24             	mov    %eax,(%esp)
  800556:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800559:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055d:	e8 5a 08 00 00       	call   800dbc <__udivdi3>
  800562:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800566:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80056a:	89 04 24             	mov    %eax,(%esp)
  80056d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800571:	89 fa                	mov    %edi,%edx
  800573:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800576:	e8 89 ff ff ff       	call   800504 <printnum>
  80057b:	eb 0f                	jmp    80058c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80057d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800581:	89 34 24             	mov    %esi,(%esp)
  800584:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800587:	4b                   	dec    %ebx
  800588:	85 db                	test   %ebx,%ebx
  80058a:	7f f1                	jg     80057d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80058c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800590:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800594:	8b 45 10             	mov    0x10(%ebp),%eax
  800597:	89 44 24 08          	mov    %eax,0x8(%esp)
  80059b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005a2:	00 
  8005a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005a6:	89 04 24             	mov    %eax,(%esp)
  8005a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b0:	e8 27 09 00 00       	call   800edc <__umoddi3>
  8005b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b9:	0f be 80 88 10 80 00 	movsbl 0x801088(%eax),%eax
  8005c0:	89 04 24             	mov    %eax,(%esp)
  8005c3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8005c6:	83 c4 3c             	add    $0x3c,%esp
  8005c9:	5b                   	pop    %ebx
  8005ca:	5e                   	pop    %esi
  8005cb:	5f                   	pop    %edi
  8005cc:	5d                   	pop    %ebp
  8005cd:	c3                   	ret    

008005ce <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005ce:	55                   	push   %ebp
  8005cf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005d1:	83 fa 01             	cmp    $0x1,%edx
  8005d4:	7e 0e                	jle    8005e4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005d6:	8b 10                	mov    (%eax),%edx
  8005d8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005db:	89 08                	mov    %ecx,(%eax)
  8005dd:	8b 02                	mov    (%edx),%eax
  8005df:	8b 52 04             	mov    0x4(%edx),%edx
  8005e2:	eb 22                	jmp    800606 <getuint+0x38>
	else if (lflag)
  8005e4:	85 d2                	test   %edx,%edx
  8005e6:	74 10                	je     8005f8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005e8:	8b 10                	mov    (%eax),%edx
  8005ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ed:	89 08                	mov    %ecx,(%eax)
  8005ef:	8b 02                	mov    (%edx),%eax
  8005f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f6:	eb 0e                	jmp    800606 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005f8:	8b 10                	mov    (%eax),%edx
  8005fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005fd:	89 08                	mov    %ecx,(%eax)
  8005ff:	8b 02                	mov    (%edx),%eax
  800601:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800606:	5d                   	pop    %ebp
  800607:	c3                   	ret    

00800608 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800608:	55                   	push   %ebp
  800609:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80060b:	83 fa 01             	cmp    $0x1,%edx
  80060e:	7e 0e                	jle    80061e <getint+0x16>
		return va_arg(*ap, long long);
  800610:	8b 10                	mov    (%eax),%edx
  800612:	8d 4a 08             	lea    0x8(%edx),%ecx
  800615:	89 08                	mov    %ecx,(%eax)
  800617:	8b 02                	mov    (%edx),%eax
  800619:	8b 52 04             	mov    0x4(%edx),%edx
  80061c:	eb 1a                	jmp    800638 <getint+0x30>
	else if (lflag)
  80061e:	85 d2                	test   %edx,%edx
  800620:	74 0c                	je     80062e <getint+0x26>
		return va_arg(*ap, long);
  800622:	8b 10                	mov    (%eax),%edx
  800624:	8d 4a 04             	lea    0x4(%edx),%ecx
  800627:	89 08                	mov    %ecx,(%eax)
  800629:	8b 02                	mov    (%edx),%eax
  80062b:	99                   	cltd   
  80062c:	eb 0a                	jmp    800638 <getint+0x30>
	else
		return va_arg(*ap, int);
  80062e:	8b 10                	mov    (%eax),%edx
  800630:	8d 4a 04             	lea    0x4(%edx),%ecx
  800633:	89 08                	mov    %ecx,(%eax)
  800635:	8b 02                	mov    (%edx),%eax
  800637:	99                   	cltd   
}
  800638:	5d                   	pop    %ebp
  800639:	c3                   	ret    

0080063a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80063a:	55                   	push   %ebp
  80063b:	89 e5                	mov    %esp,%ebp
  80063d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800640:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800643:	8b 10                	mov    (%eax),%edx
  800645:	3b 50 04             	cmp    0x4(%eax),%edx
  800648:	73 08                	jae    800652 <sprintputch+0x18>
		*b->buf++ = ch;
  80064a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80064d:	88 0a                	mov    %cl,(%edx)
  80064f:	42                   	inc    %edx
  800650:	89 10                	mov    %edx,(%eax)
}
  800652:	5d                   	pop    %ebp
  800653:	c3                   	ret    

00800654 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800654:	55                   	push   %ebp
  800655:	89 e5                	mov    %esp,%ebp
  800657:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80065a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80065d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800661:	8b 45 10             	mov    0x10(%ebp),%eax
  800664:	89 44 24 08          	mov    %eax,0x8(%esp)
  800668:	8b 45 0c             	mov    0xc(%ebp),%eax
  80066b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066f:	8b 45 08             	mov    0x8(%ebp),%eax
  800672:	89 04 24             	mov    %eax,(%esp)
  800675:	e8 02 00 00 00       	call   80067c <vprintfmt>
	va_end(ap);
}
  80067a:	c9                   	leave  
  80067b:	c3                   	ret    

0080067c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80067c:	55                   	push   %ebp
  80067d:	89 e5                	mov    %esp,%ebp
  80067f:	57                   	push   %edi
  800680:	56                   	push   %esi
  800681:	53                   	push   %ebx
  800682:	83 ec 4c             	sub    $0x4c,%esp
  800685:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800688:	8b 75 10             	mov    0x10(%ebp),%esi
  80068b:	eb 12                	jmp    80069f <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80068d:	85 c0                	test   %eax,%eax
  80068f:	0f 84 40 03 00 00    	je     8009d5 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800695:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800699:	89 04 24             	mov    %eax,(%esp)
  80069c:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80069f:	0f b6 06             	movzbl (%esi),%eax
  8006a2:	46                   	inc    %esi
  8006a3:	83 f8 25             	cmp    $0x25,%eax
  8006a6:	75 e5                	jne    80068d <vprintfmt+0x11>
  8006a8:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006ac:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006b3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006b8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c4:	eb 26                	jmp    8006ec <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c6:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006c9:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8006cd:	eb 1d                	jmp    8006ec <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006d2:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8006d6:	eb 14                	jmp    8006ec <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8006db:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8006e2:	eb 08                	jmp    8006ec <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8006e4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006e7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ec:	0f b6 06             	movzbl (%esi),%eax
  8006ef:	8d 4e 01             	lea    0x1(%esi),%ecx
  8006f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006f5:	8a 0e                	mov    (%esi),%cl
  8006f7:	83 e9 23             	sub    $0x23,%ecx
  8006fa:	80 f9 55             	cmp    $0x55,%cl
  8006fd:	0f 87 b6 02 00 00    	ja     8009b9 <vprintfmt+0x33d>
  800703:	0f b6 c9             	movzbl %cl,%ecx
  800706:	ff 24 8d 40 11 80 00 	jmp    *0x801140(,%ecx,4)
  80070d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800710:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800715:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800718:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  80071c:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80071f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800722:	83 f9 09             	cmp    $0x9,%ecx
  800725:	77 2a                	ja     800751 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800727:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800728:	eb eb                	jmp    800715 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80072a:	8b 45 14             	mov    0x14(%ebp),%eax
  80072d:	8d 48 04             	lea    0x4(%eax),%ecx
  800730:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800733:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800735:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800738:	eb 17                	jmp    800751 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80073a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80073e:	78 98                	js     8006d8 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800740:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800743:	eb a7                	jmp    8006ec <vprintfmt+0x70>
  800745:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800748:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80074f:	eb 9b                	jmp    8006ec <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800751:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800755:	79 95                	jns    8006ec <vprintfmt+0x70>
  800757:	eb 8b                	jmp    8006e4 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800759:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80075d:	eb 8d                	jmp    8006ec <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8d 50 04             	lea    0x4(%eax),%edx
  800765:	89 55 14             	mov    %edx,0x14(%ebp)
  800768:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076c:	8b 00                	mov    (%eax),%eax
  80076e:	89 04 24             	mov    %eax,(%esp)
  800771:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800774:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800777:	e9 23 ff ff ff       	jmp    80069f <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80077c:	8b 45 14             	mov    0x14(%ebp),%eax
  80077f:	8d 50 04             	lea    0x4(%eax),%edx
  800782:	89 55 14             	mov    %edx,0x14(%ebp)
  800785:	8b 00                	mov    (%eax),%eax
  800787:	85 c0                	test   %eax,%eax
  800789:	79 02                	jns    80078d <vprintfmt+0x111>
  80078b:	f7 d8                	neg    %eax
  80078d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80078f:	83 f8 09             	cmp    $0x9,%eax
  800792:	7f 0b                	jg     80079f <vprintfmt+0x123>
  800794:	8b 04 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%eax
  80079b:	85 c0                	test   %eax,%eax
  80079d:	75 23                	jne    8007c2 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80079f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007a3:	c7 44 24 08 a0 10 80 	movl   $0x8010a0,0x8(%esp)
  8007aa:	00 
  8007ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	89 04 24             	mov    %eax,(%esp)
  8007b5:	e8 9a fe ff ff       	call   800654 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007bd:	e9 dd fe ff ff       	jmp    80069f <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8007c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c6:	c7 44 24 08 a9 10 80 	movl   $0x8010a9,0x8(%esp)
  8007cd:	00 
  8007ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8007d5:	89 14 24             	mov    %edx,(%esp)
  8007d8:	e8 77 fe ff ff       	call   800654 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007e0:	e9 ba fe ff ff       	jmp    80069f <vprintfmt+0x23>
  8007e5:	89 f9                	mov    %edi,%ecx
  8007e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007ea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f0:	8d 50 04             	lea    0x4(%eax),%edx
  8007f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f6:	8b 30                	mov    (%eax),%esi
  8007f8:	85 f6                	test   %esi,%esi
  8007fa:	75 05                	jne    800801 <vprintfmt+0x185>
				p = "(null)";
  8007fc:	be 99 10 80 00       	mov    $0x801099,%esi
			if (width > 0 && padc != '-')
  800801:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800805:	0f 8e 84 00 00 00    	jle    80088f <vprintfmt+0x213>
  80080b:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80080f:	74 7e                	je     80088f <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800811:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800815:	89 34 24             	mov    %esi,(%esp)
  800818:	e8 5d 02 00 00       	call   800a7a <strnlen>
  80081d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800820:	29 c2                	sub    %eax,%edx
  800822:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800825:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800829:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80082c:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80082f:	89 de                	mov    %ebx,%esi
  800831:	89 d3                	mov    %edx,%ebx
  800833:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800835:	eb 0b                	jmp    800842 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800837:	89 74 24 04          	mov    %esi,0x4(%esp)
  80083b:	89 3c 24             	mov    %edi,(%esp)
  80083e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800841:	4b                   	dec    %ebx
  800842:	85 db                	test   %ebx,%ebx
  800844:	7f f1                	jg     800837 <vprintfmt+0x1bb>
  800846:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800849:	89 f3                	mov    %esi,%ebx
  80084b:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80084e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800851:	85 c0                	test   %eax,%eax
  800853:	79 05                	jns    80085a <vprintfmt+0x1de>
  800855:	b8 00 00 00 00       	mov    $0x0,%eax
  80085a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80085d:	29 c2                	sub    %eax,%edx
  80085f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800862:	eb 2b                	jmp    80088f <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800864:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800868:	74 18                	je     800882 <vprintfmt+0x206>
  80086a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80086d:	83 fa 5e             	cmp    $0x5e,%edx
  800870:	76 10                	jbe    800882 <vprintfmt+0x206>
					putch('?', putdat);
  800872:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800876:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80087d:	ff 55 08             	call   *0x8(%ebp)
  800880:	eb 0a                	jmp    80088c <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800882:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800886:	89 04 24             	mov    %eax,(%esp)
  800889:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80088c:	ff 4d e4             	decl   -0x1c(%ebp)
  80088f:	0f be 06             	movsbl (%esi),%eax
  800892:	46                   	inc    %esi
  800893:	85 c0                	test   %eax,%eax
  800895:	74 21                	je     8008b8 <vprintfmt+0x23c>
  800897:	85 ff                	test   %edi,%edi
  800899:	78 c9                	js     800864 <vprintfmt+0x1e8>
  80089b:	4f                   	dec    %edi
  80089c:	79 c6                	jns    800864 <vprintfmt+0x1e8>
  80089e:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a1:	89 de                	mov    %ebx,%esi
  8008a3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008a6:	eb 18                	jmp    8008c0 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008a8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008ac:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008b3:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008b5:	4b                   	dec    %ebx
  8008b6:	eb 08                	jmp    8008c0 <vprintfmt+0x244>
  8008b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008bb:	89 de                	mov    %ebx,%esi
  8008bd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008c0:	85 db                	test   %ebx,%ebx
  8008c2:	7f e4                	jg     8008a8 <vprintfmt+0x22c>
  8008c4:	89 7d 08             	mov    %edi,0x8(%ebp)
  8008c7:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008cc:	e9 ce fd ff ff       	jmp    80069f <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8008d4:	e8 2f fd ff ff       	call   800608 <getint>
  8008d9:	89 c6                	mov    %eax,%esi
  8008db:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8008dd:	85 d2                	test   %edx,%edx
  8008df:	78 07                	js     8008e8 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008e1:	be 0a 00 00 00       	mov    $0xa,%esi
  8008e6:	eb 7e                	jmp    800966 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ec:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008f3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008f6:	89 f0                	mov    %esi,%eax
  8008f8:	89 fa                	mov    %edi,%edx
  8008fa:	f7 d8                	neg    %eax
  8008fc:	83 d2 00             	adc    $0x0,%edx
  8008ff:	f7 da                	neg    %edx
			}
			base = 10;
  800901:	be 0a 00 00 00       	mov    $0xa,%esi
  800906:	eb 5e                	jmp    800966 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800908:	8d 45 14             	lea    0x14(%ebp),%eax
  80090b:	e8 be fc ff ff       	call   8005ce <getuint>
			base = 10;
  800910:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800915:	eb 4f                	jmp    800966 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800917:	8d 45 14             	lea    0x14(%ebp),%eax
  80091a:	e8 af fc ff ff       	call   8005ce <getuint>
			base = 8;
  80091f:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800924:	eb 40                	jmp    800966 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  800926:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80092a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800931:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800934:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800938:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80093f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800942:	8b 45 14             	mov    0x14(%ebp),%eax
  800945:	8d 50 04             	lea    0x4(%eax),%edx
  800948:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80094b:	8b 00                	mov    (%eax),%eax
  80094d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800952:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800957:	eb 0d                	jmp    800966 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800959:	8d 45 14             	lea    0x14(%ebp),%eax
  80095c:	e8 6d fc ff ff       	call   8005ce <getuint>
			base = 16;
  800961:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800966:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  80096a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80096e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800971:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800975:	89 74 24 08          	mov    %esi,0x8(%esp)
  800979:	89 04 24             	mov    %eax,(%esp)
  80097c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800980:	89 da                	mov    %ebx,%edx
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	e8 7a fb ff ff       	call   800504 <printnum>
			break;
  80098a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80098d:	e9 0d fd ff ff       	jmp    80069f <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  800992:	8d 45 14             	lea    0x14(%ebp),%eax
  800995:	e8 6e fc ff ff       	call   800608 <getint>
  80099a:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80099f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  8009a2:	e9 f8 fc ff ff       	jmp    80069f <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ab:	89 04 24             	mov    %eax,(%esp)
  8009ae:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009b4:	e9 e6 fc ff ff       	jmp    80069f <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009bd:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009c4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009c7:	eb 01                	jmp    8009ca <vprintfmt+0x34e>
  8009c9:	4e                   	dec    %esi
  8009ca:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009ce:	75 f9                	jne    8009c9 <vprintfmt+0x34d>
  8009d0:	e9 ca fc ff ff       	jmp    80069f <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009d5:	83 c4 4c             	add    $0x4c,%esp
  8009d8:	5b                   	pop    %ebx
  8009d9:	5e                   	pop    %esi
  8009da:	5f                   	pop    %edi
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	83 ec 28             	sub    $0x28,%esp
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009ec:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009f0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009fa:	85 c0                	test   %eax,%eax
  8009fc:	74 30                	je     800a2e <vsnprintf+0x51>
  8009fe:	85 d2                	test   %edx,%edx
  800a00:	7e 33                	jle    800a35 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a02:	8b 45 14             	mov    0x14(%ebp),%eax
  800a05:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a09:	8b 45 10             	mov    0x10(%ebp),%eax
  800a0c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a10:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a13:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a17:	c7 04 24 3a 06 80 00 	movl   $0x80063a,(%esp)
  800a1e:	e8 59 fc ff ff       	call   80067c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a23:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a26:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a2c:	eb 0c                	jmp    800a3a <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a2e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a33:	eb 05                	jmp    800a3a <vsnprintf+0x5d>
  800a35:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    

00800a3c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a42:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a45:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a49:	8b 45 10             	mov    0x10(%ebp),%eax
  800a4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a53:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a57:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5a:	89 04 24             	mov    %eax,(%esp)
  800a5d:	e8 7b ff ff ff       	call   8009dd <vsnprintf>
	va_end(ap);

	return rc;
}
  800a62:	c9                   	leave  
  800a63:	c3                   	ret    

00800a64 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6f:	eb 01                	jmp    800a72 <strlen+0xe>
		n++;
  800a71:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a72:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a76:	75 f9                	jne    800a71 <strlen+0xd>
		n++;
	return n;
}
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a80:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
  800a88:	eb 01                	jmp    800a8b <strnlen+0x11>
		n++;
  800a8a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a8b:	39 d0                	cmp    %edx,%eax
  800a8d:	74 06                	je     800a95 <strnlen+0x1b>
  800a8f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a93:	75 f5                	jne    800a8a <strnlen+0x10>
		n++;
	return n;
}
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	53                   	push   %ebx
  800a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800aa1:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800aa9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800aac:	42                   	inc    %edx
  800aad:	84 c9                	test   %cl,%cl
  800aaf:	75 f5                	jne    800aa6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ab1:	5b                   	pop    %ebx
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	53                   	push   %ebx
  800ab8:	83 ec 08             	sub    $0x8,%esp
  800abb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800abe:	89 1c 24             	mov    %ebx,(%esp)
  800ac1:	e8 9e ff ff ff       	call   800a64 <strlen>
	strcpy(dst + len, src);
  800ac6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800acd:	01 d8                	add    %ebx,%eax
  800acf:	89 04 24             	mov    %eax,(%esp)
  800ad2:	e8 c0 ff ff ff       	call   800a97 <strcpy>
	return dst;
}
  800ad7:	89 d8                	mov    %ebx,%eax
  800ad9:	83 c4 08             	add    $0x8,%esp
  800adc:	5b                   	pop    %ebx
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
  800ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aea:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aed:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af2:	eb 0c                	jmp    800b00 <strncpy+0x21>
		*dst++ = *src;
  800af4:	8a 1a                	mov    (%edx),%bl
  800af6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800af9:	80 3a 01             	cmpb   $0x1,(%edx)
  800afc:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aff:	41                   	inc    %ecx
  800b00:	39 f1                	cmp    %esi,%ecx
  800b02:	75 f0                	jne    800af4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
  800b0d:	8b 75 08             	mov    0x8(%ebp),%esi
  800b10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b13:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b16:	85 d2                	test   %edx,%edx
  800b18:	75 0a                	jne    800b24 <strlcpy+0x1c>
  800b1a:	89 f0                	mov    %esi,%eax
  800b1c:	eb 1a                	jmp    800b38 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b1e:	88 18                	mov    %bl,(%eax)
  800b20:	40                   	inc    %eax
  800b21:	41                   	inc    %ecx
  800b22:	eb 02                	jmp    800b26 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b24:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b26:	4a                   	dec    %edx
  800b27:	74 0a                	je     800b33 <strlcpy+0x2b>
  800b29:	8a 19                	mov    (%ecx),%bl
  800b2b:	84 db                	test   %bl,%bl
  800b2d:	75 ef                	jne    800b1e <strlcpy+0x16>
  800b2f:	89 c2                	mov    %eax,%edx
  800b31:	eb 02                	jmp    800b35 <strlcpy+0x2d>
  800b33:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b35:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b38:	29 f0                	sub    %esi,%eax
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b44:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b47:	eb 02                	jmp    800b4b <strcmp+0xd>
		p++, q++;
  800b49:	41                   	inc    %ecx
  800b4a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b4b:	8a 01                	mov    (%ecx),%al
  800b4d:	84 c0                	test   %al,%al
  800b4f:	74 04                	je     800b55 <strcmp+0x17>
  800b51:	3a 02                	cmp    (%edx),%al
  800b53:	74 f4                	je     800b49 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b55:	0f b6 c0             	movzbl %al,%eax
  800b58:	0f b6 12             	movzbl (%edx),%edx
  800b5b:	29 d0                	sub    %edx,%eax
}
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	53                   	push   %ebx
  800b63:	8b 45 08             	mov    0x8(%ebp),%eax
  800b66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b69:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b6c:	eb 03                	jmp    800b71 <strncmp+0x12>
		n--, p++, q++;
  800b6e:	4a                   	dec    %edx
  800b6f:	40                   	inc    %eax
  800b70:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b71:	85 d2                	test   %edx,%edx
  800b73:	74 14                	je     800b89 <strncmp+0x2a>
  800b75:	8a 18                	mov    (%eax),%bl
  800b77:	84 db                	test   %bl,%bl
  800b79:	74 04                	je     800b7f <strncmp+0x20>
  800b7b:	3a 19                	cmp    (%ecx),%bl
  800b7d:	74 ef                	je     800b6e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b7f:	0f b6 00             	movzbl (%eax),%eax
  800b82:	0f b6 11             	movzbl (%ecx),%edx
  800b85:	29 d0                	sub    %edx,%eax
  800b87:	eb 05                	jmp    800b8e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b89:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b8e:	5b                   	pop    %ebx
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	8b 45 08             	mov    0x8(%ebp),%eax
  800b97:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b9a:	eb 05                	jmp    800ba1 <strchr+0x10>
		if (*s == c)
  800b9c:	38 ca                	cmp    %cl,%dl
  800b9e:	74 0c                	je     800bac <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ba0:	40                   	inc    %eax
  800ba1:	8a 10                	mov    (%eax),%dl
  800ba3:	84 d2                	test   %dl,%dl
  800ba5:	75 f5                	jne    800b9c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800ba7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bb7:	eb 05                	jmp    800bbe <strfind+0x10>
		if (*s == c)
  800bb9:	38 ca                	cmp    %cl,%dl
  800bbb:	74 07                	je     800bc4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bbd:	40                   	inc    %eax
  800bbe:	8a 10                	mov    (%eax),%dl
  800bc0:	84 d2                	test   %dl,%dl
  800bc2:	75 f5                	jne    800bb9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bd5:	85 c9                	test   %ecx,%ecx
  800bd7:	74 30                	je     800c09 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bd9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bdf:	75 25                	jne    800c06 <memset+0x40>
  800be1:	f6 c1 03             	test   $0x3,%cl
  800be4:	75 20                	jne    800c06 <memset+0x40>
		c &= 0xFF;
  800be6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800be9:	89 d3                	mov    %edx,%ebx
  800beb:	c1 e3 08             	shl    $0x8,%ebx
  800bee:	89 d6                	mov    %edx,%esi
  800bf0:	c1 e6 18             	shl    $0x18,%esi
  800bf3:	89 d0                	mov    %edx,%eax
  800bf5:	c1 e0 10             	shl    $0x10,%eax
  800bf8:	09 f0                	or     %esi,%eax
  800bfa:	09 d0                	or     %edx,%eax
  800bfc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bfe:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c01:	fc                   	cld    
  800c02:	f3 ab                	rep stos %eax,%es:(%edi)
  800c04:	eb 03                	jmp    800c09 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c06:	fc                   	cld    
  800c07:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c09:	89 f8                	mov    %edi,%eax
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	8b 45 08             	mov    0x8(%ebp),%eax
  800c18:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c1e:	39 c6                	cmp    %eax,%esi
  800c20:	73 34                	jae    800c56 <memmove+0x46>
  800c22:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c25:	39 d0                	cmp    %edx,%eax
  800c27:	73 2d                	jae    800c56 <memmove+0x46>
		s += n;
		d += n;
  800c29:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2c:	f6 c2 03             	test   $0x3,%dl
  800c2f:	75 1b                	jne    800c4c <memmove+0x3c>
  800c31:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c37:	75 13                	jne    800c4c <memmove+0x3c>
  800c39:	f6 c1 03             	test   $0x3,%cl
  800c3c:	75 0e                	jne    800c4c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c3e:	83 ef 04             	sub    $0x4,%edi
  800c41:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c44:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c47:	fd                   	std    
  800c48:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4a:	eb 07                	jmp    800c53 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c4c:	4f                   	dec    %edi
  800c4d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c50:	fd                   	std    
  800c51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c53:	fc                   	cld    
  800c54:	eb 20                	jmp    800c76 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c56:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c5c:	75 13                	jne    800c71 <memmove+0x61>
  800c5e:	a8 03                	test   $0x3,%al
  800c60:	75 0f                	jne    800c71 <memmove+0x61>
  800c62:	f6 c1 03             	test   $0x3,%cl
  800c65:	75 0a                	jne    800c71 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c67:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c6a:	89 c7                	mov    %eax,%edi
  800c6c:	fc                   	cld    
  800c6d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c6f:	eb 05                	jmp    800c76 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c71:	89 c7                	mov    %eax,%edi
  800c73:	fc                   	cld    
  800c74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c80:	8b 45 10             	mov    0x10(%ebp),%eax
  800c83:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c91:	89 04 24             	mov    %eax,(%esp)
  800c94:	e8 77 ff ff ff       	call   800c10 <memmove>
}
  800c99:	c9                   	leave  
  800c9a:	c3                   	ret    

00800c9b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ca4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800caa:	ba 00 00 00 00       	mov    $0x0,%edx
  800caf:	eb 16                	jmp    800cc7 <memcmp+0x2c>
		if (*s1 != *s2)
  800cb1:	8a 04 17             	mov    (%edi,%edx,1),%al
  800cb4:	42                   	inc    %edx
  800cb5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800cb9:	38 c8                	cmp    %cl,%al
  800cbb:	74 0a                	je     800cc7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800cbd:	0f b6 c0             	movzbl %al,%eax
  800cc0:	0f b6 c9             	movzbl %cl,%ecx
  800cc3:	29 c8                	sub    %ecx,%eax
  800cc5:	eb 09                	jmp    800cd0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc7:	39 da                	cmp    %ebx,%edx
  800cc9:	75 e6                	jne    800cb1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ccb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cde:	89 c2                	mov    %eax,%edx
  800ce0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ce3:	eb 05                	jmp    800cea <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ce5:	38 08                	cmp    %cl,(%eax)
  800ce7:	74 05                	je     800cee <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ce9:	40                   	inc    %eax
  800cea:	39 d0                	cmp    %edx,%eax
  800cec:	72 f7                	jb     800ce5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cfc:	eb 01                	jmp    800cff <strtol+0xf>
		s++;
  800cfe:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cff:	8a 02                	mov    (%edx),%al
  800d01:	3c 20                	cmp    $0x20,%al
  800d03:	74 f9                	je     800cfe <strtol+0xe>
  800d05:	3c 09                	cmp    $0x9,%al
  800d07:	74 f5                	je     800cfe <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d09:	3c 2b                	cmp    $0x2b,%al
  800d0b:	75 08                	jne    800d15 <strtol+0x25>
		s++;
  800d0d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d13:	eb 13                	jmp    800d28 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d15:	3c 2d                	cmp    $0x2d,%al
  800d17:	75 0a                	jne    800d23 <strtol+0x33>
		s++, neg = 1;
  800d19:	8d 52 01             	lea    0x1(%edx),%edx
  800d1c:	bf 01 00 00 00       	mov    $0x1,%edi
  800d21:	eb 05                	jmp    800d28 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d23:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d28:	85 db                	test   %ebx,%ebx
  800d2a:	74 05                	je     800d31 <strtol+0x41>
  800d2c:	83 fb 10             	cmp    $0x10,%ebx
  800d2f:	75 28                	jne    800d59 <strtol+0x69>
  800d31:	8a 02                	mov    (%edx),%al
  800d33:	3c 30                	cmp    $0x30,%al
  800d35:	75 10                	jne    800d47 <strtol+0x57>
  800d37:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d3b:	75 0a                	jne    800d47 <strtol+0x57>
		s += 2, base = 16;
  800d3d:	83 c2 02             	add    $0x2,%edx
  800d40:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d45:	eb 12                	jmp    800d59 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d47:	85 db                	test   %ebx,%ebx
  800d49:	75 0e                	jne    800d59 <strtol+0x69>
  800d4b:	3c 30                	cmp    $0x30,%al
  800d4d:	75 05                	jne    800d54 <strtol+0x64>
		s++, base = 8;
  800d4f:	42                   	inc    %edx
  800d50:	b3 08                	mov    $0x8,%bl
  800d52:	eb 05                	jmp    800d59 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d54:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d59:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d60:	8a 0a                	mov    (%edx),%cl
  800d62:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d65:	80 fb 09             	cmp    $0x9,%bl
  800d68:	77 08                	ja     800d72 <strtol+0x82>
			dig = *s - '0';
  800d6a:	0f be c9             	movsbl %cl,%ecx
  800d6d:	83 e9 30             	sub    $0x30,%ecx
  800d70:	eb 1e                	jmp    800d90 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d72:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d75:	80 fb 19             	cmp    $0x19,%bl
  800d78:	77 08                	ja     800d82 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d7a:	0f be c9             	movsbl %cl,%ecx
  800d7d:	83 e9 57             	sub    $0x57,%ecx
  800d80:	eb 0e                	jmp    800d90 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d82:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d85:	80 fb 19             	cmp    $0x19,%bl
  800d88:	77 12                	ja     800d9c <strtol+0xac>
			dig = *s - 'A' + 10;
  800d8a:	0f be c9             	movsbl %cl,%ecx
  800d8d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d90:	39 f1                	cmp    %esi,%ecx
  800d92:	7d 0c                	jge    800da0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d94:	42                   	inc    %edx
  800d95:	0f af c6             	imul   %esi,%eax
  800d98:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d9a:	eb c4                	jmp    800d60 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d9c:	89 c1                	mov    %eax,%ecx
  800d9e:	eb 02                	jmp    800da2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800da0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800da2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800da6:	74 05                	je     800dad <strtol+0xbd>
		*endptr = (char *) s;
  800da8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dab:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800dad:	85 ff                	test   %edi,%edi
  800daf:	74 04                	je     800db5 <strtol+0xc5>
  800db1:	89 c8                	mov    %ecx,%eax
  800db3:	f7 d8                	neg    %eax
}
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    
	...

00800dbc <__udivdi3>:
  800dbc:	55                   	push   %ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	83 ec 10             	sub    $0x10,%esp
  800dc2:	8b 74 24 20          	mov    0x20(%esp),%esi
  800dc6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800dca:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dce:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800dd2:	89 cd                	mov    %ecx,%ebp
  800dd4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800dd8:	85 c0                	test   %eax,%eax
  800dda:	75 2c                	jne    800e08 <__udivdi3+0x4c>
  800ddc:	39 f9                	cmp    %edi,%ecx
  800dde:	77 68                	ja     800e48 <__udivdi3+0x8c>
  800de0:	85 c9                	test   %ecx,%ecx
  800de2:	75 0b                	jne    800def <__udivdi3+0x33>
  800de4:	b8 01 00 00 00       	mov    $0x1,%eax
  800de9:	31 d2                	xor    %edx,%edx
  800deb:	f7 f1                	div    %ecx
  800ded:	89 c1                	mov    %eax,%ecx
  800def:	31 d2                	xor    %edx,%edx
  800df1:	89 f8                	mov    %edi,%eax
  800df3:	f7 f1                	div    %ecx
  800df5:	89 c7                	mov    %eax,%edi
  800df7:	89 f0                	mov    %esi,%eax
  800df9:	f7 f1                	div    %ecx
  800dfb:	89 c6                	mov    %eax,%esi
  800dfd:	89 f0                	mov    %esi,%eax
  800dff:	89 fa                	mov    %edi,%edx
  800e01:	83 c4 10             	add    $0x10,%esp
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    
  800e08:	39 f8                	cmp    %edi,%eax
  800e0a:	77 2c                	ja     800e38 <__udivdi3+0x7c>
  800e0c:	0f bd f0             	bsr    %eax,%esi
  800e0f:	83 f6 1f             	xor    $0x1f,%esi
  800e12:	75 4c                	jne    800e60 <__udivdi3+0xa4>
  800e14:	39 f8                	cmp    %edi,%eax
  800e16:	bf 00 00 00 00       	mov    $0x0,%edi
  800e1b:	72 0a                	jb     800e27 <__udivdi3+0x6b>
  800e1d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e21:	0f 87 ad 00 00 00    	ja     800ed4 <__udivdi3+0x118>
  800e27:	be 01 00 00 00       	mov    $0x1,%esi
  800e2c:	89 f0                	mov    %esi,%eax
  800e2e:	89 fa                	mov    %edi,%edx
  800e30:	83 c4 10             	add    $0x10,%esp
  800e33:	5e                   	pop    %esi
  800e34:	5f                   	pop    %edi
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    
  800e37:	90                   	nop
  800e38:	31 ff                	xor    %edi,%edi
  800e3a:	31 f6                	xor    %esi,%esi
  800e3c:	89 f0                	mov    %esi,%eax
  800e3e:	89 fa                	mov    %edi,%edx
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    
  800e47:	90                   	nop
  800e48:	89 fa                	mov    %edi,%edx
  800e4a:	89 f0                	mov    %esi,%eax
  800e4c:	f7 f1                	div    %ecx
  800e4e:	89 c6                	mov    %eax,%esi
  800e50:	31 ff                	xor    %edi,%edi
  800e52:	89 f0                	mov    %esi,%eax
  800e54:	89 fa                	mov    %edi,%edx
  800e56:	83 c4 10             	add    $0x10,%esp
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    
  800e5d:	8d 76 00             	lea    0x0(%esi),%esi
  800e60:	89 f1                	mov    %esi,%ecx
  800e62:	d3 e0                	shl    %cl,%eax
  800e64:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e68:	b8 20 00 00 00       	mov    $0x20,%eax
  800e6d:	29 f0                	sub    %esi,%eax
  800e6f:	89 ea                	mov    %ebp,%edx
  800e71:	88 c1                	mov    %al,%cl
  800e73:	d3 ea                	shr    %cl,%edx
  800e75:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e79:	09 ca                	or     %ecx,%edx
  800e7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e7f:	89 f1                	mov    %esi,%ecx
  800e81:	d3 e5                	shl    %cl,%ebp
  800e83:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800e87:	89 fd                	mov    %edi,%ebp
  800e89:	88 c1                	mov    %al,%cl
  800e8b:	d3 ed                	shr    %cl,%ebp
  800e8d:	89 fa                	mov    %edi,%edx
  800e8f:	89 f1                	mov    %esi,%ecx
  800e91:	d3 e2                	shl    %cl,%edx
  800e93:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e97:	88 c1                	mov    %al,%cl
  800e99:	d3 ef                	shr    %cl,%edi
  800e9b:	09 d7                	or     %edx,%edi
  800e9d:	89 f8                	mov    %edi,%eax
  800e9f:	89 ea                	mov    %ebp,%edx
  800ea1:	f7 74 24 08          	divl   0x8(%esp)
  800ea5:	89 d1                	mov    %edx,%ecx
  800ea7:	89 c7                	mov    %eax,%edi
  800ea9:	f7 64 24 0c          	mull   0xc(%esp)
  800ead:	39 d1                	cmp    %edx,%ecx
  800eaf:	72 17                	jb     800ec8 <__udivdi3+0x10c>
  800eb1:	74 09                	je     800ebc <__udivdi3+0x100>
  800eb3:	89 fe                	mov    %edi,%esi
  800eb5:	31 ff                	xor    %edi,%edi
  800eb7:	e9 41 ff ff ff       	jmp    800dfd <__udivdi3+0x41>
  800ebc:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ec0:	89 f1                	mov    %esi,%ecx
  800ec2:	d3 e2                	shl    %cl,%edx
  800ec4:	39 c2                	cmp    %eax,%edx
  800ec6:	73 eb                	jae    800eb3 <__udivdi3+0xf7>
  800ec8:	8d 77 ff             	lea    -0x1(%edi),%esi
  800ecb:	31 ff                	xor    %edi,%edi
  800ecd:	e9 2b ff ff ff       	jmp    800dfd <__udivdi3+0x41>
  800ed2:	66 90                	xchg   %ax,%ax
  800ed4:	31 f6                	xor    %esi,%esi
  800ed6:	e9 22 ff ff ff       	jmp    800dfd <__udivdi3+0x41>
	...

00800edc <__umoddi3>:
  800edc:	55                   	push   %ebp
  800edd:	57                   	push   %edi
  800ede:	56                   	push   %esi
  800edf:	83 ec 20             	sub    $0x20,%esp
  800ee2:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ee6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800eea:	89 44 24 14          	mov    %eax,0x14(%esp)
  800eee:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ef2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ef6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800efa:	89 c7                	mov    %eax,%edi
  800efc:	89 f2                	mov    %esi,%edx
  800efe:	85 ed                	test   %ebp,%ebp
  800f00:	75 16                	jne    800f18 <__umoddi3+0x3c>
  800f02:	39 f1                	cmp    %esi,%ecx
  800f04:	0f 86 a6 00 00 00    	jbe    800fb0 <__umoddi3+0xd4>
  800f0a:	f7 f1                	div    %ecx
  800f0c:	89 d0                	mov    %edx,%eax
  800f0e:	31 d2                	xor    %edx,%edx
  800f10:	83 c4 20             	add    $0x20,%esp
  800f13:	5e                   	pop    %esi
  800f14:	5f                   	pop    %edi
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    
  800f17:	90                   	nop
  800f18:	39 f5                	cmp    %esi,%ebp
  800f1a:	0f 87 ac 00 00 00    	ja     800fcc <__umoddi3+0xf0>
  800f20:	0f bd c5             	bsr    %ebp,%eax
  800f23:	83 f0 1f             	xor    $0x1f,%eax
  800f26:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2a:	0f 84 a8 00 00 00    	je     800fd8 <__umoddi3+0xfc>
  800f30:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f34:	d3 e5                	shl    %cl,%ebp
  800f36:	bf 20 00 00 00       	mov    $0x20,%edi
  800f3b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800f3f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f43:	89 f9                	mov    %edi,%ecx
  800f45:	d3 e8                	shr    %cl,%eax
  800f47:	09 e8                	or     %ebp,%eax
  800f49:	89 44 24 18          	mov    %eax,0x18(%esp)
  800f4d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f51:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f55:	d3 e0                	shl    %cl,%eax
  800f57:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f5b:	89 f2                	mov    %esi,%edx
  800f5d:	d3 e2                	shl    %cl,%edx
  800f5f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f63:	d3 e0                	shl    %cl,%eax
  800f65:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800f69:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f6d:	89 f9                	mov    %edi,%ecx
  800f6f:	d3 e8                	shr    %cl,%eax
  800f71:	09 d0                	or     %edx,%eax
  800f73:	d3 ee                	shr    %cl,%esi
  800f75:	89 f2                	mov    %esi,%edx
  800f77:	f7 74 24 18          	divl   0x18(%esp)
  800f7b:	89 d6                	mov    %edx,%esi
  800f7d:	f7 64 24 0c          	mull   0xc(%esp)
  800f81:	89 c5                	mov    %eax,%ebp
  800f83:	89 d1                	mov    %edx,%ecx
  800f85:	39 d6                	cmp    %edx,%esi
  800f87:	72 67                	jb     800ff0 <__umoddi3+0x114>
  800f89:	74 75                	je     801000 <__umoddi3+0x124>
  800f8b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f8f:	29 e8                	sub    %ebp,%eax
  800f91:	19 ce                	sbb    %ecx,%esi
  800f93:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f97:	d3 e8                	shr    %cl,%eax
  800f99:	89 f2                	mov    %esi,%edx
  800f9b:	89 f9                	mov    %edi,%ecx
  800f9d:	d3 e2                	shl    %cl,%edx
  800f9f:	09 d0                	or     %edx,%eax
  800fa1:	89 f2                	mov    %esi,%edx
  800fa3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fa7:	d3 ea                	shr    %cl,%edx
  800fa9:	83 c4 20             	add    $0x20,%esp
  800fac:	5e                   	pop    %esi
  800fad:	5f                   	pop    %edi
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    
  800fb0:	85 c9                	test   %ecx,%ecx
  800fb2:	75 0b                	jne    800fbf <__umoddi3+0xe3>
  800fb4:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb9:	31 d2                	xor    %edx,%edx
  800fbb:	f7 f1                	div    %ecx
  800fbd:	89 c1                	mov    %eax,%ecx
  800fbf:	89 f0                	mov    %esi,%eax
  800fc1:	31 d2                	xor    %edx,%edx
  800fc3:	f7 f1                	div    %ecx
  800fc5:	89 f8                	mov    %edi,%eax
  800fc7:	e9 3e ff ff ff       	jmp    800f0a <__umoddi3+0x2e>
  800fcc:	89 f2                	mov    %esi,%edx
  800fce:	83 c4 20             	add    $0x20,%esp
  800fd1:	5e                   	pop    %esi
  800fd2:	5f                   	pop    %edi
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    
  800fd5:	8d 76 00             	lea    0x0(%esi),%esi
  800fd8:	39 f5                	cmp    %esi,%ebp
  800fda:	72 04                	jb     800fe0 <__umoddi3+0x104>
  800fdc:	39 f9                	cmp    %edi,%ecx
  800fde:	77 06                	ja     800fe6 <__umoddi3+0x10a>
  800fe0:	89 f2                	mov    %esi,%edx
  800fe2:	29 cf                	sub    %ecx,%edi
  800fe4:	19 ea                	sbb    %ebp,%edx
  800fe6:	89 f8                	mov    %edi,%eax
  800fe8:	83 c4 20             	add    $0x20,%esp
  800feb:	5e                   	pop    %esi
  800fec:	5f                   	pop    %edi
  800fed:	5d                   	pop    %ebp
  800fee:	c3                   	ret    
  800fef:	90                   	nop
  800ff0:	89 d1                	mov    %edx,%ecx
  800ff2:	89 c5                	mov    %eax,%ebp
  800ff4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800ff8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800ffc:	eb 8d                	jmp    800f8b <__umoddi3+0xaf>
  800ffe:	66 90                	xchg   %ax,%ax
  801000:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801004:	72 ea                	jb     800ff0 <__umoddi3+0x114>
  801006:	89 f1                	mov    %esi,%ecx
  801008:	eb 81                	jmp    800f8b <__umoddi3+0xaf>
