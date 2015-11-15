
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 13 02 00 00       	call   800244 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800049:	00 
  80004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004e:	89 34 24             	mov    %esi,(%esp)
  800051:	e8 eb 0c 00 00       	call   800d41 <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 40 17 80 	movl   $0x801740,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 53 17 80 00 	movl   $0x801753,(%esp)
  800075:	e8 2e 02 00 00       	call   8002a8 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 f7 0c 00 00       	call   800d95 <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 63 17 80 	movl   $0x801763,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 53 17 80 00 	movl   $0x801753,(%esp)
  8000bd:	e8 e6 01 00 00       	call   8002a8 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 ee 09 00 00       	call   800ac8 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 fa 0c 00 00       	call   800de8 <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 74 17 80 	movl   $0x801774,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 53 17 80 00 	movl   $0x801753,(%esp)
  80010d:	e8 96 01 00 00       	call   8002a8 <_panic>
}
  800112:	83 c4 20             	add    $0x20,%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <dumbfork>:

envid_t
dumbfork(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800121:	be 07 00 00 00       	mov    $0x7,%esi
  800126:	89 f0                	mov    %esi,%eax
  800128:	cd 30                	int    $0x30
  80012a:	89 c6                	mov    %eax,%esi
  80012c:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  80012e:	85 c0                	test   %eax,%eax
  800130:	79 20                	jns    800152 <dumbfork+0x39>
		panic("sys_exofork: %e", envid);
  800132:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800136:	c7 44 24 08 87 17 80 	movl   $0x801787,0x8(%esp)
  80013d:	00 
  80013e:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 53 17 80 00 	movl   $0x801753,(%esp)
  80014d:	e8 56 01 00 00       	call   8002a8 <_panic>
	if (envid == 0) {
  800152:	85 c0                	test   %eax,%eax
  800154:	75 1f                	jne    800175 <dumbfork+0x5c>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800156:	e8 a8 0b 00 00       	call   800d03 <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800163:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800166:	c1 e0 04             	shl    $0x4,%eax
  800169:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80016e:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800173:	eb 6e                	jmp    8001e3 <dumbfork+0xca>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800175:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  80017c:	eb 13                	jmp    800191 <dumbfork+0x78>
		duppage(envid, addr);
  80017e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800182:	89 1c 24             	mov    %ebx,(%esp)
  800185:	e8 aa fe ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80018a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800191:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800194:	3d 0c 20 80 00       	cmp    $0x80200c,%eax
  800199:	72 e3                	jb     80017e <dumbfork+0x65>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  80019b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80019e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a7:	89 34 24             	mov    %esi,(%esp)
  8001aa:	e8 85 fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001af:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001b6:	00 
  8001b7:	89 34 24             	mov    %esi,(%esp)
  8001ba:	e8 7c 0c 00 00       	call   800e3b <sys_env_set_status>
  8001bf:	85 c0                	test   %eax,%eax
  8001c1:	79 20                	jns    8001e3 <dumbfork+0xca>
		panic("sys_env_set_status: %e", r);
  8001c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c7:	c7 44 24 08 97 17 80 	movl   $0x801797,0x8(%esp)
  8001ce:	00 
  8001cf:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001d6:	00 
  8001d7:	c7 04 24 53 17 80 00 	movl   $0x801753,(%esp)
  8001de:	e8 c5 00 00 00       	call   8002a8 <_panic>

	return envid;
}
  8001e3:	89 f0                	mov    %esi,%eax
  8001e5:	83 c4 20             	add    $0x20,%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5e                   	pop    %esi
  8001ea:	5d                   	pop    %ebp
  8001eb:	c3                   	ret    

008001ec <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 10             	sub    $0x10,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001f4:	e8 20 ff ff ff       	call   800119 <dumbfork>
  8001f9:	89 c3                	mov    %eax,%ebx

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001fb:	be 00 00 00 00       	mov    $0x0,%esi
  800200:	eb 2a                	jmp    80022c <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800202:	85 db                	test   %ebx,%ebx
  800204:	74 07                	je     80020d <umain+0x21>
  800206:	b8 ae 17 80 00       	mov    $0x8017ae,%eax
  80020b:	eb 05                	jmp    800212 <umain+0x26>
  80020d:	b8 b5 17 80 00       	mov    $0x8017b5,%eax
  800212:	89 44 24 08          	mov    %eax,0x8(%esp)
  800216:	89 74 24 04          	mov    %esi,0x4(%esp)
  80021a:	c7 04 24 bb 17 80 00 	movl   $0x8017bb,(%esp)
  800221:	e8 7a 01 00 00       	call   8003a0 <cprintf>
		sys_yield();
  800226:	e8 f7 0a 00 00       	call   800d22 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  80022b:	46                   	inc    %esi
  80022c:	83 fb 01             	cmp    $0x1,%ebx
  80022f:	19 c0                	sbb    %eax,%eax
  800231:	83 e0 0a             	and    $0xa,%eax
  800234:	83 c0 0a             	add    $0xa,%eax
  800237:	39 c6                	cmp    %eax,%esi
  800239:	7c c7                	jl     800202 <umain+0x16>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  80023b:	83 c4 10             	add    $0x10,%esp
  80023e:	5b                   	pop    %ebx
  80023f:	5e                   	pop    %esi
  800240:	5d                   	pop    %ebp
  800241:	c3                   	ret    
	...

00800244 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
  800249:	83 ec 10             	sub    $0x10,%esp
  80024c:	8b 75 08             	mov    0x8(%ebp),%esi
  80024f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800252:	e8 ac 0a 00 00       	call   800d03 <sys_getenvid>
  800257:	25 ff 03 00 00       	and    $0x3ff,%eax
  80025c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80025f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800262:	c1 e0 04             	shl    $0x4,%eax
  800265:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80026a:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80026f:	85 f6                	test   %esi,%esi
  800271:	7e 07                	jle    80027a <libmain+0x36>
		binaryname = argv[0];
  800273:	8b 03                	mov    (%ebx),%eax
  800275:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80027a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80027e:	89 34 24             	mov    %esi,(%esp)
  800281:	e8 66 ff ff ff       	call   8001ec <umain>

	// exit gracefully
	exit();
  800286:	e8 09 00 00 00       	call   800294 <exit>
}
  80028b:	83 c4 10             	add    $0x10,%esp
  80028e:	5b                   	pop    %ebx
  80028f:	5e                   	pop    %esi
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    
	...

00800294 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80029a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002a1:	e8 0b 0a 00 00       	call   800cb1 <sys_env_destroy>
}
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	56                   	push   %esi
  8002ac:	53                   	push   %ebx
  8002ad:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002b3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002b9:	e8 45 0a 00 00       	call   800d03 <sys_getenvid>
  8002be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002cc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d4:	c7 04 24 d8 17 80 00 	movl   $0x8017d8,(%esp)
  8002db:	e8 c0 00 00 00       	call   8003a0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002e0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e7:	89 04 24             	mov    %eax,(%esp)
  8002ea:	e8 50 00 00 00       	call   80033f <vcprintf>
	cprintf("\n");
  8002ef:	c7 04 24 cb 17 80 00 	movl   $0x8017cb,(%esp)
  8002f6:	e8 a5 00 00 00       	call   8003a0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002fb:	cc                   	int3   
  8002fc:	eb fd                	jmp    8002fb <_panic+0x53>
	...

00800300 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	53                   	push   %ebx
  800304:	83 ec 14             	sub    $0x14,%esp
  800307:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80030a:	8b 03                	mov    (%ebx),%eax
  80030c:	8b 55 08             	mov    0x8(%ebp),%edx
  80030f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800313:	40                   	inc    %eax
  800314:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800316:	3d ff 00 00 00       	cmp    $0xff,%eax
  80031b:	75 19                	jne    800336 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80031d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800324:	00 
  800325:	8d 43 08             	lea    0x8(%ebx),%eax
  800328:	89 04 24             	mov    %eax,(%esp)
  80032b:	e8 44 09 00 00       	call   800c74 <sys_cputs>
		b->idx = 0;
  800330:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800336:	ff 43 04             	incl   0x4(%ebx)
}
  800339:	83 c4 14             	add    $0x14,%esp
  80033c:	5b                   	pop    %ebx
  80033d:	5d                   	pop    %ebp
  80033e:	c3                   	ret    

0080033f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800348:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80034f:	00 00 00 
	b.cnt = 0;
  800352:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800359:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80035c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800363:	8b 45 08             	mov    0x8(%ebp),%eax
  800366:	89 44 24 08          	mov    %eax,0x8(%esp)
  80036a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800370:	89 44 24 04          	mov    %eax,0x4(%esp)
  800374:	c7 04 24 00 03 80 00 	movl   $0x800300,(%esp)
  80037b:	e8 b4 01 00 00       	call   800534 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800380:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800386:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800390:	89 04 24             	mov    %eax,(%esp)
  800393:	e8 dc 08 00 00       	call   800c74 <sys_cputs>

	return b.cnt;
}
  800398:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80039e:	c9                   	leave  
  80039f:	c3                   	ret    

008003a0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003a6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b0:	89 04 24             	mov    %eax,(%esp)
  8003b3:	e8 87 ff ff ff       	call   80033f <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b8:	c9                   	leave  
  8003b9:	c3                   	ret    
	...

008003bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	57                   	push   %edi
  8003c0:	56                   	push   %esi
  8003c1:	53                   	push   %ebx
  8003c2:	83 ec 3c             	sub    $0x3c,%esp
  8003c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c8:	89 d7                	mov    %edx,%edi
  8003ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003d9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003dc:	85 c0                	test   %eax,%eax
  8003de:	75 08                	jne    8003e8 <printnum+0x2c>
  8003e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003e3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003e6:	77 57                	ja     80043f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003e8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003ec:	4b                   	dec    %ebx
  8003ed:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003fc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800400:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800407:	00 
  800408:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80040b:	89 04 24             	mov    %eax,(%esp)
  80040e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800411:	89 44 24 04          	mov    %eax,0x4(%esp)
  800415:	e8 c2 10 00 00       	call   8014dc <__udivdi3>
  80041a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80041e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800422:	89 04 24             	mov    %eax,(%esp)
  800425:	89 54 24 04          	mov    %edx,0x4(%esp)
  800429:	89 fa                	mov    %edi,%edx
  80042b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80042e:	e8 89 ff ff ff       	call   8003bc <printnum>
  800433:	eb 0f                	jmp    800444 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800435:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800439:	89 34 24             	mov    %esi,(%esp)
  80043c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80043f:	4b                   	dec    %ebx
  800440:	85 db                	test   %ebx,%ebx
  800442:	7f f1                	jg     800435 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800444:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800448:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80044c:	8b 45 10             	mov    0x10(%ebp),%eax
  80044f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800453:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80045a:	00 
  80045b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80045e:	89 04 24             	mov    %eax,(%esp)
  800461:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800464:	89 44 24 04          	mov    %eax,0x4(%esp)
  800468:	e8 8f 11 00 00       	call   8015fc <__umoddi3>
  80046d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800471:	0f be 80 fc 17 80 00 	movsbl 0x8017fc(%eax),%eax
  800478:	89 04 24             	mov    %eax,(%esp)
  80047b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80047e:	83 c4 3c             	add    $0x3c,%esp
  800481:	5b                   	pop    %ebx
  800482:	5e                   	pop    %esi
  800483:	5f                   	pop    %edi
  800484:	5d                   	pop    %ebp
  800485:	c3                   	ret    

00800486 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800489:	83 fa 01             	cmp    $0x1,%edx
  80048c:	7e 0e                	jle    80049c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80048e:	8b 10                	mov    (%eax),%edx
  800490:	8d 4a 08             	lea    0x8(%edx),%ecx
  800493:	89 08                	mov    %ecx,(%eax)
  800495:	8b 02                	mov    (%edx),%eax
  800497:	8b 52 04             	mov    0x4(%edx),%edx
  80049a:	eb 22                	jmp    8004be <getuint+0x38>
	else if (lflag)
  80049c:	85 d2                	test   %edx,%edx
  80049e:	74 10                	je     8004b0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004a0:	8b 10                	mov    (%eax),%edx
  8004a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a5:	89 08                	mov    %ecx,(%eax)
  8004a7:	8b 02                	mov    (%edx),%eax
  8004a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ae:	eb 0e                	jmp    8004be <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004b0:	8b 10                	mov    (%eax),%edx
  8004b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b5:	89 08                	mov    %ecx,(%eax)
  8004b7:	8b 02                	mov    (%edx),%eax
  8004b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004be:	5d                   	pop    %ebp
  8004bf:	c3                   	ret    

008004c0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c3:	83 fa 01             	cmp    $0x1,%edx
  8004c6:	7e 0e                	jle    8004d6 <getint+0x16>
		return va_arg(*ap, long long);
  8004c8:	8b 10                	mov    (%eax),%edx
  8004ca:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 02                	mov    (%edx),%eax
  8004d1:	8b 52 04             	mov    0x4(%edx),%edx
  8004d4:	eb 1a                	jmp    8004f0 <getint+0x30>
	else if (lflag)
  8004d6:	85 d2                	test   %edx,%edx
  8004d8:	74 0c                	je     8004e6 <getint+0x26>
		return va_arg(*ap, long);
  8004da:	8b 10                	mov    (%eax),%edx
  8004dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004df:	89 08                	mov    %ecx,(%eax)
  8004e1:	8b 02                	mov    (%edx),%eax
  8004e3:	99                   	cltd   
  8004e4:	eb 0a                	jmp    8004f0 <getint+0x30>
	else
		return va_arg(*ap, int);
  8004e6:	8b 10                	mov    (%eax),%edx
  8004e8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004eb:	89 08                	mov    %ecx,(%eax)
  8004ed:	8b 02                	mov    (%edx),%eax
  8004ef:	99                   	cltd   
}
  8004f0:	5d                   	pop    %ebp
  8004f1:	c3                   	ret    

008004f2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004fb:	8b 10                	mov    (%eax),%edx
  8004fd:	3b 50 04             	cmp    0x4(%eax),%edx
  800500:	73 08                	jae    80050a <sprintputch+0x18>
		*b->buf++ = ch;
  800502:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800505:	88 0a                	mov    %cl,(%edx)
  800507:	42                   	inc    %edx
  800508:	89 10                	mov    %edx,(%eax)
}
  80050a:	5d                   	pop    %ebp
  80050b:	c3                   	ret    

0080050c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80050c:	55                   	push   %ebp
  80050d:	89 e5                	mov    %esp,%ebp
  80050f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800512:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800515:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800519:	8b 45 10             	mov    0x10(%ebp),%eax
  80051c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800520:	8b 45 0c             	mov    0xc(%ebp),%eax
  800523:	89 44 24 04          	mov    %eax,0x4(%esp)
  800527:	8b 45 08             	mov    0x8(%ebp),%eax
  80052a:	89 04 24             	mov    %eax,(%esp)
  80052d:	e8 02 00 00 00       	call   800534 <vprintfmt>
	va_end(ap);
}
  800532:	c9                   	leave  
  800533:	c3                   	ret    

00800534 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	57                   	push   %edi
  800538:	56                   	push   %esi
  800539:	53                   	push   %ebx
  80053a:	83 ec 4c             	sub    $0x4c,%esp
  80053d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800540:	8b 75 10             	mov    0x10(%ebp),%esi
  800543:	eb 12                	jmp    800557 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800545:	85 c0                	test   %eax,%eax
  800547:	0f 84 40 03 00 00    	je     80088d <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  80054d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800551:	89 04 24             	mov    %eax,(%esp)
  800554:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800557:	0f b6 06             	movzbl (%esi),%eax
  80055a:	46                   	inc    %esi
  80055b:	83 f8 25             	cmp    $0x25,%eax
  80055e:	75 e5                	jne    800545 <vprintfmt+0x11>
  800560:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800564:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80056b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800570:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800577:	ba 00 00 00 00       	mov    $0x0,%edx
  80057c:	eb 26                	jmp    8005a4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057e:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800581:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800585:	eb 1d                	jmp    8005a4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800587:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80058a:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80058e:	eb 14                	jmp    8005a4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800590:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800593:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80059a:	eb 08                	jmp    8005a4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80059c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80059f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	0f b6 06             	movzbl (%esi),%eax
  8005a7:	8d 4e 01             	lea    0x1(%esi),%ecx
  8005aa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005ad:	8a 0e                	mov    (%esi),%cl
  8005af:	83 e9 23             	sub    $0x23,%ecx
  8005b2:	80 f9 55             	cmp    $0x55,%cl
  8005b5:	0f 87 b6 02 00 00    	ja     800871 <vprintfmt+0x33d>
  8005bb:	0f b6 c9             	movzbl %cl,%ecx
  8005be:	ff 24 8d c0 18 80 00 	jmp    *0x8018c0(,%ecx,4)
  8005c5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005c8:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005cd:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  8005d0:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  8005d4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005d7:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8005da:	83 f9 09             	cmp    $0x9,%ecx
  8005dd:	77 2a                	ja     800609 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005df:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005e0:	eb eb                	jmp    8005cd <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 48 04             	lea    0x4(%eax),%ecx
  8005e8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005eb:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ed:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005f0:	eb 17                	jmp    800609 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8005f2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005f6:	78 98                	js     800590 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005fb:	eb a7                	jmp    8005a4 <vprintfmt+0x70>
  8005fd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800600:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800607:	eb 9b                	jmp    8005a4 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800609:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80060d:	79 95                	jns    8005a4 <vprintfmt+0x70>
  80060f:	eb 8b                	jmp    80059c <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800611:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800612:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800615:	eb 8d                	jmp    8005a4 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 04             	lea    0x4(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)
  800620:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800624:	8b 00                	mov    (%eax),%eax
  800626:	89 04 24             	mov    %eax,(%esp)
  800629:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80062f:	e9 23 ff ff ff       	jmp    800557 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 50 04             	lea    0x4(%eax),%edx
  80063a:	89 55 14             	mov    %edx,0x14(%ebp)
  80063d:	8b 00                	mov    (%eax),%eax
  80063f:	85 c0                	test   %eax,%eax
  800641:	79 02                	jns    800645 <vprintfmt+0x111>
  800643:	f7 d8                	neg    %eax
  800645:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800647:	83 f8 09             	cmp    $0x9,%eax
  80064a:	7f 0b                	jg     800657 <vprintfmt+0x123>
  80064c:	8b 04 85 20 1a 80 00 	mov    0x801a20(,%eax,4),%eax
  800653:	85 c0                	test   %eax,%eax
  800655:	75 23                	jne    80067a <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800657:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80065b:	c7 44 24 08 14 18 80 	movl   $0x801814,0x8(%esp)
  800662:	00 
  800663:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800667:	8b 45 08             	mov    0x8(%ebp),%eax
  80066a:	89 04 24             	mov    %eax,(%esp)
  80066d:	e8 9a fe ff ff       	call   80050c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800672:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800675:	e9 dd fe ff ff       	jmp    800557 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80067a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80067e:	c7 44 24 08 1d 18 80 	movl   $0x80181d,0x8(%esp)
  800685:	00 
  800686:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068a:	8b 55 08             	mov    0x8(%ebp),%edx
  80068d:	89 14 24             	mov    %edx,(%esp)
  800690:	e8 77 fe ff ff       	call   80050c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800695:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800698:	e9 ba fe ff ff       	jmp    800557 <vprintfmt+0x23>
  80069d:	89 f9                	mov    %edi,%ecx
  80069f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8d 50 04             	lea    0x4(%eax),%edx
  8006ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ae:	8b 30                	mov    (%eax),%esi
  8006b0:	85 f6                	test   %esi,%esi
  8006b2:	75 05                	jne    8006b9 <vprintfmt+0x185>
				p = "(null)";
  8006b4:	be 0d 18 80 00       	mov    $0x80180d,%esi
			if (width > 0 && padc != '-')
  8006b9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006bd:	0f 8e 84 00 00 00    	jle    800747 <vprintfmt+0x213>
  8006c3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8006c7:	74 7e                	je     800747 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006cd:	89 34 24             	mov    %esi,(%esp)
  8006d0:	e8 5d 02 00 00       	call   800932 <strnlen>
  8006d5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006d8:	29 c2                	sub    %eax,%edx
  8006da:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8006dd:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8006e1:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006e4:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8006e7:	89 de                	mov    %ebx,%esi
  8006e9:	89 d3                	mov    %edx,%ebx
  8006eb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ed:	eb 0b                	jmp    8006fa <vprintfmt+0x1c6>
					putch(padc, putdat);
  8006ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006f3:	89 3c 24             	mov    %edi,(%esp)
  8006f6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f9:	4b                   	dec    %ebx
  8006fa:	85 db                	test   %ebx,%ebx
  8006fc:	7f f1                	jg     8006ef <vprintfmt+0x1bb>
  8006fe:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800701:	89 f3                	mov    %esi,%ebx
  800703:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800706:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800709:	85 c0                	test   %eax,%eax
  80070b:	79 05                	jns    800712 <vprintfmt+0x1de>
  80070d:	b8 00 00 00 00       	mov    $0x0,%eax
  800712:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800715:	29 c2                	sub    %eax,%edx
  800717:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80071a:	eb 2b                	jmp    800747 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80071c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800720:	74 18                	je     80073a <vprintfmt+0x206>
  800722:	8d 50 e0             	lea    -0x20(%eax),%edx
  800725:	83 fa 5e             	cmp    $0x5e,%edx
  800728:	76 10                	jbe    80073a <vprintfmt+0x206>
					putch('?', putdat);
  80072a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800735:	ff 55 08             	call   *0x8(%ebp)
  800738:	eb 0a                	jmp    800744 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80073a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073e:	89 04 24             	mov    %eax,(%esp)
  800741:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800744:	ff 4d e4             	decl   -0x1c(%ebp)
  800747:	0f be 06             	movsbl (%esi),%eax
  80074a:	46                   	inc    %esi
  80074b:	85 c0                	test   %eax,%eax
  80074d:	74 21                	je     800770 <vprintfmt+0x23c>
  80074f:	85 ff                	test   %edi,%edi
  800751:	78 c9                	js     80071c <vprintfmt+0x1e8>
  800753:	4f                   	dec    %edi
  800754:	79 c6                	jns    80071c <vprintfmt+0x1e8>
  800756:	8b 7d 08             	mov    0x8(%ebp),%edi
  800759:	89 de                	mov    %ebx,%esi
  80075b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80075e:	eb 18                	jmp    800778 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800760:	89 74 24 04          	mov    %esi,0x4(%esp)
  800764:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80076b:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80076d:	4b                   	dec    %ebx
  80076e:	eb 08                	jmp    800778 <vprintfmt+0x244>
  800770:	8b 7d 08             	mov    0x8(%ebp),%edi
  800773:	89 de                	mov    %ebx,%esi
  800775:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800778:	85 db                	test   %ebx,%ebx
  80077a:	7f e4                	jg     800760 <vprintfmt+0x22c>
  80077c:	89 7d 08             	mov    %edi,0x8(%ebp)
  80077f:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800781:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800784:	e9 ce fd ff ff       	jmp    800557 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800789:	8d 45 14             	lea    0x14(%ebp),%eax
  80078c:	e8 2f fd ff ff       	call   8004c0 <getint>
  800791:	89 c6                	mov    %eax,%esi
  800793:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800795:	85 d2                	test   %edx,%edx
  800797:	78 07                	js     8007a0 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800799:	be 0a 00 00 00       	mov    $0xa,%esi
  80079e:	eb 7e                	jmp    80081e <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007ab:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007ae:	89 f0                	mov    %esi,%eax
  8007b0:	89 fa                	mov    %edi,%edx
  8007b2:	f7 d8                	neg    %eax
  8007b4:	83 d2 00             	adc    $0x0,%edx
  8007b7:	f7 da                	neg    %edx
			}
			base = 10;
  8007b9:	be 0a 00 00 00       	mov    $0xa,%esi
  8007be:	eb 5e                	jmp    80081e <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c3:	e8 be fc ff ff       	call   800486 <getuint>
			base = 10;
  8007c8:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8007cd:	eb 4f                	jmp    80081e <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8007cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d2:	e8 af fc ff ff       	call   800486 <getuint>
			base = 8;
  8007d7:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8007dc:	eb 40                	jmp    80081e <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  8007de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007e9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007f7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8d 50 04             	lea    0x4(%eax),%edx
  800800:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800803:	8b 00                	mov    (%eax),%eax
  800805:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80080a:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80080f:	eb 0d                	jmp    80081e <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800811:	8d 45 14             	lea    0x14(%ebp),%eax
  800814:	e8 6d fc ff ff       	call   800486 <getuint>
			base = 16;
  800819:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80081e:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800822:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800826:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800829:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80082d:	89 74 24 08          	mov    %esi,0x8(%esp)
  800831:	89 04 24             	mov    %eax,(%esp)
  800834:	89 54 24 04          	mov    %edx,0x4(%esp)
  800838:	89 da                	mov    %ebx,%edx
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	e8 7a fb ff ff       	call   8003bc <printnum>
			break;
  800842:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800845:	e9 0d fd ff ff       	jmp    800557 <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  80084a:	8d 45 14             	lea    0x14(%ebp),%eax
  80084d:	e8 6e fc ff ff       	call   8004c0 <getint>
  800852:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800857:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  80085a:	e9 f8 fc ff ff       	jmp    800557 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80085f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800863:	89 04 24             	mov    %eax,(%esp)
  800866:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800869:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80086c:	e9 e6 fc ff ff       	jmp    800557 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800871:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800875:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80087c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80087f:	eb 01                	jmp    800882 <vprintfmt+0x34e>
  800881:	4e                   	dec    %esi
  800882:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800886:	75 f9                	jne    800881 <vprintfmt+0x34d>
  800888:	e9 ca fc ff ff       	jmp    800557 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80088d:	83 c4 4c             	add    $0x4c,%esp
  800890:	5b                   	pop    %ebx
  800891:	5e                   	pop    %esi
  800892:	5f                   	pop    %edi
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	83 ec 28             	sub    $0x28,%esp
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008a4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008a8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008b2:	85 c0                	test   %eax,%eax
  8008b4:	74 30                	je     8008e6 <vsnprintf+0x51>
  8008b6:	85 d2                	test   %edx,%edx
  8008b8:	7e 33                	jle    8008ed <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8008c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008cf:	c7 04 24 f2 04 80 00 	movl   $0x8004f2,(%esp)
  8008d6:	e8 59 fc ff ff       	call   800534 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008db:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008de:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e4:	eb 0c                	jmp    8008f2 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008eb:	eb 05                	jmp    8008f2 <vsnprintf+0x5d>
  8008ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008f2:	c9                   	leave  
  8008f3:	c3                   	ret    

008008f4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008fa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800901:	8b 45 10             	mov    0x10(%ebp),%eax
  800904:	89 44 24 08          	mov    %eax,0x8(%esp)
  800908:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090f:	8b 45 08             	mov    0x8(%ebp),%eax
  800912:	89 04 24             	mov    %eax,(%esp)
  800915:	e8 7b ff ff ff       	call   800895 <vsnprintf>
	va_end(ap);

	return rc;
}
  80091a:	c9                   	leave  
  80091b:	c3                   	ret    

0080091c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
  800927:	eb 01                	jmp    80092a <strlen+0xe>
		n++;
  800929:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80092a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80092e:	75 f9                	jne    800929 <strlen+0xd>
		n++;
	return n;
}
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800938:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093b:	b8 00 00 00 00       	mov    $0x0,%eax
  800940:	eb 01                	jmp    800943 <strnlen+0x11>
		n++;
  800942:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800943:	39 d0                	cmp    %edx,%eax
  800945:	74 06                	je     80094d <strnlen+0x1b>
  800947:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80094b:	75 f5                	jne    800942 <strnlen+0x10>
		n++;
	return n;
}
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	53                   	push   %ebx
  800953:	8b 45 08             	mov    0x8(%ebp),%eax
  800956:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800959:	ba 00 00 00 00       	mov    $0x0,%edx
  80095e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800961:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800964:	42                   	inc    %edx
  800965:	84 c9                	test   %cl,%cl
  800967:	75 f5                	jne    80095e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800969:	5b                   	pop    %ebx
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	53                   	push   %ebx
  800970:	83 ec 08             	sub    $0x8,%esp
  800973:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800976:	89 1c 24             	mov    %ebx,(%esp)
  800979:	e8 9e ff ff ff       	call   80091c <strlen>
	strcpy(dst + len, src);
  80097e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800981:	89 54 24 04          	mov    %edx,0x4(%esp)
  800985:	01 d8                	add    %ebx,%eax
  800987:	89 04 24             	mov    %eax,(%esp)
  80098a:	e8 c0 ff ff ff       	call   80094f <strcpy>
	return dst;
}
  80098f:	89 d8                	mov    %ebx,%eax
  800991:	83 c4 08             	add    $0x8,%esp
  800994:	5b                   	pop    %ebx
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	56                   	push   %esi
  80099b:	53                   	push   %ebx
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009aa:	eb 0c                	jmp    8009b8 <strncpy+0x21>
		*dst++ = *src;
  8009ac:	8a 1a                	mov    (%edx),%bl
  8009ae:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009b1:	80 3a 01             	cmpb   $0x1,(%edx)
  8009b4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b7:	41                   	inc    %ecx
  8009b8:	39 f1                	cmp    %esi,%ecx
  8009ba:	75 f0                	jne    8009ac <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009bc:	5b                   	pop    %ebx
  8009bd:	5e                   	pop    %esi
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	56                   	push   %esi
  8009c4:	53                   	push   %ebx
  8009c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009cb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ce:	85 d2                	test   %edx,%edx
  8009d0:	75 0a                	jne    8009dc <strlcpy+0x1c>
  8009d2:	89 f0                	mov    %esi,%eax
  8009d4:	eb 1a                	jmp    8009f0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009d6:	88 18                	mov    %bl,(%eax)
  8009d8:	40                   	inc    %eax
  8009d9:	41                   	inc    %ecx
  8009da:	eb 02                	jmp    8009de <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009dc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8009de:	4a                   	dec    %edx
  8009df:	74 0a                	je     8009eb <strlcpy+0x2b>
  8009e1:	8a 19                	mov    (%ecx),%bl
  8009e3:	84 db                	test   %bl,%bl
  8009e5:	75 ef                	jne    8009d6 <strlcpy+0x16>
  8009e7:	89 c2                	mov    %eax,%edx
  8009e9:	eb 02                	jmp    8009ed <strlcpy+0x2d>
  8009eb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009ed:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009f0:	29 f0                	sub    %esi,%eax
}
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ff:	eb 02                	jmp    800a03 <strcmp+0xd>
		p++, q++;
  800a01:	41                   	inc    %ecx
  800a02:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a03:	8a 01                	mov    (%ecx),%al
  800a05:	84 c0                	test   %al,%al
  800a07:	74 04                	je     800a0d <strcmp+0x17>
  800a09:	3a 02                	cmp    (%edx),%al
  800a0b:	74 f4                	je     800a01 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0d:	0f b6 c0             	movzbl %al,%eax
  800a10:	0f b6 12             	movzbl (%edx),%edx
  800a13:	29 d0                	sub    %edx,%eax
}
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	53                   	push   %ebx
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a21:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a24:	eb 03                	jmp    800a29 <strncmp+0x12>
		n--, p++, q++;
  800a26:	4a                   	dec    %edx
  800a27:	40                   	inc    %eax
  800a28:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a29:	85 d2                	test   %edx,%edx
  800a2b:	74 14                	je     800a41 <strncmp+0x2a>
  800a2d:	8a 18                	mov    (%eax),%bl
  800a2f:	84 db                	test   %bl,%bl
  800a31:	74 04                	je     800a37 <strncmp+0x20>
  800a33:	3a 19                	cmp    (%ecx),%bl
  800a35:	74 ef                	je     800a26 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a37:	0f b6 00             	movzbl (%eax),%eax
  800a3a:	0f b6 11             	movzbl (%ecx),%edx
  800a3d:	29 d0                	sub    %edx,%eax
  800a3f:	eb 05                	jmp    800a46 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a41:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a46:	5b                   	pop    %ebx
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a52:	eb 05                	jmp    800a59 <strchr+0x10>
		if (*s == c)
  800a54:	38 ca                	cmp    %cl,%dl
  800a56:	74 0c                	je     800a64 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a58:	40                   	inc    %eax
  800a59:	8a 10                	mov    (%eax),%dl
  800a5b:	84 d2                	test   %dl,%dl
  800a5d:	75 f5                	jne    800a54 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a6f:	eb 05                	jmp    800a76 <strfind+0x10>
		if (*s == c)
  800a71:	38 ca                	cmp    %cl,%dl
  800a73:	74 07                	je     800a7c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a75:	40                   	inc    %eax
  800a76:	8a 10                	mov    (%eax),%dl
  800a78:	84 d2                	test   %dl,%dl
  800a7a:	75 f5                	jne    800a71 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
  800a84:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a8d:	85 c9                	test   %ecx,%ecx
  800a8f:	74 30                	je     800ac1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a91:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a97:	75 25                	jne    800abe <memset+0x40>
  800a99:	f6 c1 03             	test   $0x3,%cl
  800a9c:	75 20                	jne    800abe <memset+0x40>
		c &= 0xFF;
  800a9e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa1:	89 d3                	mov    %edx,%ebx
  800aa3:	c1 e3 08             	shl    $0x8,%ebx
  800aa6:	89 d6                	mov    %edx,%esi
  800aa8:	c1 e6 18             	shl    $0x18,%esi
  800aab:	89 d0                	mov    %edx,%eax
  800aad:	c1 e0 10             	shl    $0x10,%eax
  800ab0:	09 f0                	or     %esi,%eax
  800ab2:	09 d0                	or     %edx,%eax
  800ab4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ab6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ab9:	fc                   	cld    
  800aba:	f3 ab                	rep stos %eax,%es:(%edi)
  800abc:	eb 03                	jmp    800ac1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800abe:	fc                   	cld    
  800abf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ac1:	89 f8                	mov    %edi,%eax
  800ac3:	5b                   	pop    %ebx
  800ac4:	5e                   	pop    %esi
  800ac5:	5f                   	pop    %edi
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	57                   	push   %edi
  800acc:	56                   	push   %esi
  800acd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ad6:	39 c6                	cmp    %eax,%esi
  800ad8:	73 34                	jae    800b0e <memmove+0x46>
  800ada:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800add:	39 d0                	cmp    %edx,%eax
  800adf:	73 2d                	jae    800b0e <memmove+0x46>
		s += n;
		d += n;
  800ae1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae4:	f6 c2 03             	test   $0x3,%dl
  800ae7:	75 1b                	jne    800b04 <memmove+0x3c>
  800ae9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aef:	75 13                	jne    800b04 <memmove+0x3c>
  800af1:	f6 c1 03             	test   $0x3,%cl
  800af4:	75 0e                	jne    800b04 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800af6:	83 ef 04             	sub    $0x4,%edi
  800af9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800afc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aff:	fd                   	std    
  800b00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b02:	eb 07                	jmp    800b0b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b04:	4f                   	dec    %edi
  800b05:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b08:	fd                   	std    
  800b09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b0b:	fc                   	cld    
  800b0c:	eb 20                	jmp    800b2e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b14:	75 13                	jne    800b29 <memmove+0x61>
  800b16:	a8 03                	test   $0x3,%al
  800b18:	75 0f                	jne    800b29 <memmove+0x61>
  800b1a:	f6 c1 03             	test   $0x3,%cl
  800b1d:	75 0a                	jne    800b29 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b1f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b22:	89 c7                	mov    %eax,%edi
  800b24:	fc                   	cld    
  800b25:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b27:	eb 05                	jmp    800b2e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b29:	89 c7                	mov    %eax,%edi
  800b2b:	fc                   	cld    
  800b2c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b38:	8b 45 10             	mov    0x10(%ebp),%eax
  800b3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b42:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b46:	8b 45 08             	mov    0x8(%ebp),%eax
  800b49:	89 04 24             	mov    %eax,(%esp)
  800b4c:	e8 77 ff ff ff       	call   800ac8 <memmove>
}
  800b51:	c9                   	leave  
  800b52:	c3                   	ret    

00800b53 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
  800b59:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b62:	ba 00 00 00 00       	mov    $0x0,%edx
  800b67:	eb 16                	jmp    800b7f <memcmp+0x2c>
		if (*s1 != *s2)
  800b69:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b6c:	42                   	inc    %edx
  800b6d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b71:	38 c8                	cmp    %cl,%al
  800b73:	74 0a                	je     800b7f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b75:	0f b6 c0             	movzbl %al,%eax
  800b78:	0f b6 c9             	movzbl %cl,%ecx
  800b7b:	29 c8                	sub    %ecx,%eax
  800b7d:	eb 09                	jmp    800b88 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7f:	39 da                	cmp    %ebx,%edx
  800b81:	75 e6                	jne    800b69 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	8b 45 08             	mov    0x8(%ebp),%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b96:	89 c2                	mov    %eax,%edx
  800b98:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b9b:	eb 05                	jmp    800ba2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b9d:	38 08                	cmp    %cl,(%eax)
  800b9f:	74 05                	je     800ba6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ba1:	40                   	inc    %eax
  800ba2:	39 d0                	cmp    %edx,%eax
  800ba4:	72 f7                	jb     800b9d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb4:	eb 01                	jmp    800bb7 <strtol+0xf>
		s++;
  800bb6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb7:	8a 02                	mov    (%edx),%al
  800bb9:	3c 20                	cmp    $0x20,%al
  800bbb:	74 f9                	je     800bb6 <strtol+0xe>
  800bbd:	3c 09                	cmp    $0x9,%al
  800bbf:	74 f5                	je     800bb6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bc1:	3c 2b                	cmp    $0x2b,%al
  800bc3:	75 08                	jne    800bcd <strtol+0x25>
		s++;
  800bc5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bc6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bcb:	eb 13                	jmp    800be0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bcd:	3c 2d                	cmp    $0x2d,%al
  800bcf:	75 0a                	jne    800bdb <strtol+0x33>
		s++, neg = 1;
  800bd1:	8d 52 01             	lea    0x1(%edx),%edx
  800bd4:	bf 01 00 00 00       	mov    $0x1,%edi
  800bd9:	eb 05                	jmp    800be0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bdb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be0:	85 db                	test   %ebx,%ebx
  800be2:	74 05                	je     800be9 <strtol+0x41>
  800be4:	83 fb 10             	cmp    $0x10,%ebx
  800be7:	75 28                	jne    800c11 <strtol+0x69>
  800be9:	8a 02                	mov    (%edx),%al
  800beb:	3c 30                	cmp    $0x30,%al
  800bed:	75 10                	jne    800bff <strtol+0x57>
  800bef:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bf3:	75 0a                	jne    800bff <strtol+0x57>
		s += 2, base = 16;
  800bf5:	83 c2 02             	add    $0x2,%edx
  800bf8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bfd:	eb 12                	jmp    800c11 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800bff:	85 db                	test   %ebx,%ebx
  800c01:	75 0e                	jne    800c11 <strtol+0x69>
  800c03:	3c 30                	cmp    $0x30,%al
  800c05:	75 05                	jne    800c0c <strtol+0x64>
		s++, base = 8;
  800c07:	42                   	inc    %edx
  800c08:	b3 08                	mov    $0x8,%bl
  800c0a:	eb 05                	jmp    800c11 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c0c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c11:	b8 00 00 00 00       	mov    $0x0,%eax
  800c16:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c18:	8a 0a                	mov    (%edx),%cl
  800c1a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c1d:	80 fb 09             	cmp    $0x9,%bl
  800c20:	77 08                	ja     800c2a <strtol+0x82>
			dig = *s - '0';
  800c22:	0f be c9             	movsbl %cl,%ecx
  800c25:	83 e9 30             	sub    $0x30,%ecx
  800c28:	eb 1e                	jmp    800c48 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c2a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c2d:	80 fb 19             	cmp    $0x19,%bl
  800c30:	77 08                	ja     800c3a <strtol+0x92>
			dig = *s - 'a' + 10;
  800c32:	0f be c9             	movsbl %cl,%ecx
  800c35:	83 e9 57             	sub    $0x57,%ecx
  800c38:	eb 0e                	jmp    800c48 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c3a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c3d:	80 fb 19             	cmp    $0x19,%bl
  800c40:	77 12                	ja     800c54 <strtol+0xac>
			dig = *s - 'A' + 10;
  800c42:	0f be c9             	movsbl %cl,%ecx
  800c45:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c48:	39 f1                	cmp    %esi,%ecx
  800c4a:	7d 0c                	jge    800c58 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c4c:	42                   	inc    %edx
  800c4d:	0f af c6             	imul   %esi,%eax
  800c50:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c52:	eb c4                	jmp    800c18 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c54:	89 c1                	mov    %eax,%ecx
  800c56:	eb 02                	jmp    800c5a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c58:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c5a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c5e:	74 05                	je     800c65 <strtol+0xbd>
		*endptr = (char *) s;
  800c60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c63:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c65:	85 ff                	test   %edi,%edi
  800c67:	74 04                	je     800c6d <strtol+0xc5>
  800c69:	89 c8                	mov    %ecx,%eax
  800c6b:	f7 d8                	neg    %eax
}
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    
	...

00800c74 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c82:	8b 55 08             	mov    0x8(%ebp),%edx
  800c85:	89 c3                	mov    %eax,%ebx
  800c87:	89 c7                	mov    %eax,%edi
  800c89:	89 c6                	mov    %eax,%esi
  800c8b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c98:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9d:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca2:	89 d1                	mov    %edx,%ecx
  800ca4:	89 d3                	mov    %edx,%ebx
  800ca6:	89 d7                	mov    %edx,%edi
  800ca8:	89 d6                	mov    %edx,%esi
  800caa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cbf:	b8 03 00 00 00       	mov    $0x3,%eax
  800cc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc7:	89 cb                	mov    %ecx,%ebx
  800cc9:	89 cf                	mov    %ecx,%edi
  800ccb:	89 ce                	mov    %ecx,%esi
  800ccd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	7e 28                	jle    800cfb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cde:	00 
  800cdf:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  800ce6:	00 
  800ce7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cee:	00 
  800cef:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  800cf6:	e8 ad f5 ff ff       	call   8002a8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cfb:	83 c4 2c             	add    $0x2c,%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0e:	b8 02 00 00 00       	mov    $0x2,%eax
  800d13:	89 d1                	mov    %edx,%ecx
  800d15:	89 d3                	mov    %edx,%ebx
  800d17:	89 d7                	mov    %edx,%edi
  800d19:	89 d6                	mov    %edx,%esi
  800d1b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <sys_yield>:

void
sys_yield(void)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d28:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d32:	89 d1                	mov    %edx,%ecx
  800d34:	89 d3                	mov    %edx,%ebx
  800d36:	89 d7                	mov    %edx,%edi
  800d38:	89 d6                	mov    %edx,%esi
  800d3a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	57                   	push   %edi
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
  800d47:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4a:	be 00 00 00 00       	mov    $0x0,%esi
  800d4f:	b8 04 00 00 00       	mov    $0x4,%eax
  800d54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5d:	89 f7                	mov    %esi,%edi
  800d5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7e 28                	jle    800d8d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d65:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d69:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d70:	00 
  800d71:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  800d78:	00 
  800d79:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d80:	00 
  800d81:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  800d88:	e8 1b f5 ff ff       	call   8002a8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d8d:	83 c4 2c             	add    $0x2c,%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
  800d9b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9e:	b8 05 00 00 00       	mov    $0x5,%eax
  800da3:	8b 75 18             	mov    0x18(%ebp),%esi
  800da6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daf:	8b 55 08             	mov    0x8(%ebp),%edx
  800db2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db4:	85 c0                	test   %eax,%eax
  800db6:	7e 28                	jle    800de0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dbc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dc3:	00 
  800dc4:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  800dcb:	00 
  800dcc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd3:	00 
  800dd4:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  800ddb:	e8 c8 f4 ff ff       	call   8002a8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800de0:	83 c4 2c             	add    $0x2c,%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	57                   	push   %edi
  800dec:	56                   	push   %esi
  800ded:	53                   	push   %ebx
  800dee:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df6:	b8 06 00 00 00       	mov    $0x6,%eax
  800dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	89 df                	mov    %ebx,%edi
  800e03:	89 de                	mov    %ebx,%esi
  800e05:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e07:	85 c0                	test   %eax,%eax
  800e09:	7e 28                	jle    800e33 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e16:	00 
  800e17:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  800e1e:	00 
  800e1f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e26:	00 
  800e27:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  800e2e:	e8 75 f4 ff ff       	call   8002a8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e33:	83 c4 2c             	add    $0x2c,%esp
  800e36:	5b                   	pop    %ebx
  800e37:	5e                   	pop    %esi
  800e38:	5f                   	pop    %edi
  800e39:	5d                   	pop    %ebp
  800e3a:	c3                   	ret    

00800e3b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	57                   	push   %edi
  800e3f:	56                   	push   %esi
  800e40:	53                   	push   %ebx
  800e41:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e49:	b8 08 00 00 00       	mov    $0x8,%eax
  800e4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e51:	8b 55 08             	mov    0x8(%ebp),%edx
  800e54:	89 df                	mov    %ebx,%edi
  800e56:	89 de                	mov    %ebx,%esi
  800e58:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	7e 28                	jle    800e86 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e62:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e69:	00 
  800e6a:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  800e71:	00 
  800e72:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e79:	00 
  800e7a:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  800e81:	e8 22 f4 ff ff       	call   8002a8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e86:	83 c4 2c             	add    $0x2c,%esp
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9c:	b8 09 00 00 00       	mov    $0x9,%eax
  800ea1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea7:	89 df                	mov    %ebx,%edi
  800ea9:	89 de                	mov    %ebx,%esi
  800eab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	7e 28                	jle    800ed9 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ebc:	00 
  800ebd:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  800ec4:	00 
  800ec5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ecc:	00 
  800ecd:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  800ed4:	e8 cf f3 ff ff       	call   8002a8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ed9:	83 c4 2c             	add    $0x2c,%esp
  800edc:	5b                   	pop    %ebx
  800edd:	5e                   	pop    %esi
  800ede:	5f                   	pop    %edi
  800edf:	5d                   	pop    %ebp
  800ee0:	c3                   	ret    

00800ee1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	57                   	push   %edi
  800ee5:	56                   	push   %esi
  800ee6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee7:	be 00 00 00 00       	mov    $0x0,%esi
  800eec:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ef1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ef4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efa:	8b 55 08             	mov    0x8(%ebp),%edx
  800efd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eff:	5b                   	pop    %ebx
  800f00:	5e                   	pop    %esi
  800f01:	5f                   	pop    %edi
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    

00800f04 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	57                   	push   %edi
  800f08:	56                   	push   %esi
  800f09:	53                   	push   %ebx
  800f0a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f12:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f17:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1a:	89 cb                	mov    %ecx,%ebx
  800f1c:	89 cf                	mov    %ecx,%edi
  800f1e:	89 ce                	mov    %ecx,%esi
  800f20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f22:	85 c0                	test   %eax,%eax
  800f24:	7e 28                	jle    800f4e <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f26:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2a:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f31:	00 
  800f32:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  800f39:	00 
  800f3a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f41:	00 
  800f42:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  800f49:	e8 5a f3 ff ff       	call   8002a8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f4e:	83 c4 2c             	add    $0x2c,%esp
  800f51:	5b                   	pop    %ebx
  800f52:	5e                   	pop    %esi
  800f53:	5f                   	pop    %edi
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    

00800f56 <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	57                   	push   %edi
  800f5a:	56                   	push   %esi
  800f5b:	53                   	push   %ebx
  800f5c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f64:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6f:	89 df                	mov    %ebx,%edi
  800f71:	89 de                	mov    %ebx,%esi
  800f73:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f75:	85 c0                	test   %eax,%eax
  800f77:	7e 28                	jle    800fa1 <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f7d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f84:	00 
  800f85:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  800f8c:	00 
  800f8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f94:	00 
  800f95:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  800f9c:	e8 07 f3 ff ff       	call   8002a8 <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800fa1:	83 c4 2c             	add    $0x2c,%esp
  800fa4:	5b                   	pop    %ebx
  800fa5:	5e                   	pop    %esi
  800fa6:	5f                   	pop    %edi
  800fa7:	5d                   	pop    %ebp
  800fa8:	c3                   	ret    

00800fa9 <sys_env_set_debug_upcall>:

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	57                   	push   %edi
  800fad:	56                   	push   %esi
  800fae:	53                   	push   %ebx
  800faf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb7:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc2:	89 df                	mov    %ebx,%edi
  800fc4:	89 de                	mov    %ebx,%esi
  800fc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	7e 28                	jle    800ff4 <sys_env_set_debug_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fcc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd0:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800fd7:	00 
  800fd8:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  800fdf:	00 
  800fe0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe7:	00 
  800fe8:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  800fef:	e8 b4 f2 ff ff       	call   8002a8 <_panic>
}

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_debug_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800ff4:	83 c4 2c             	add    $0x2c,%esp
  800ff7:	5b                   	pop    %ebx
  800ff8:	5e                   	pop    %esi
  800ff9:	5f                   	pop    %edi
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <sys_env_set_nmskint_upcall>:

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	57                   	push   %edi
  801000:	56                   	push   %esi
  801001:	53                   	push   %ebx
  801002:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801005:	bb 00 00 00 00       	mov    $0x0,%ebx
  80100a:	b8 0f 00 00 00       	mov    $0xf,%eax
  80100f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801012:	8b 55 08             	mov    0x8(%ebp),%edx
  801015:	89 df                	mov    %ebx,%edi
  801017:	89 de                	mov    %ebx,%esi
  801019:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80101b:	85 c0                	test   %eax,%eax
  80101d:	7e 28                	jle    801047 <sys_env_set_nmskint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80101f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801023:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  80102a:	00 
  80102b:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  801032:	00 
  801033:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80103a:	00 
  80103b:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  801042:	e8 61 f2 ff ff       	call   8002a8 <_panic>
}

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_nmskint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801047:	83 c4 2c             	add    $0x2c,%esp
  80104a:	5b                   	pop    %ebx
  80104b:	5e                   	pop    %esi
  80104c:	5f                   	pop    %edi
  80104d:	5d                   	pop    %ebp
  80104e:	c3                   	ret    

0080104f <sys_env_set_bpoint_upcall>:

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	57                   	push   %edi
  801053:	56                   	push   %esi
  801054:	53                   	push   %ebx
  801055:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801058:	bb 00 00 00 00       	mov    $0x0,%ebx
  80105d:	b8 10 00 00 00       	mov    $0x10,%eax
  801062:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801065:	8b 55 08             	mov    0x8(%ebp),%edx
  801068:	89 df                	mov    %ebx,%edi
  80106a:	89 de                	mov    %ebx,%esi
  80106c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80106e:	85 c0                	test   %eax,%eax
  801070:	7e 28                	jle    80109a <sys_env_set_bpoint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801072:	89 44 24 10          	mov    %eax,0x10(%esp)
  801076:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  80107d:	00 
  80107e:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  801085:	00 
  801086:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80108d:	00 
  80108e:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  801095:	e8 0e f2 ff ff       	call   8002a8 <_panic>
}

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bpoint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80109a:	83 c4 2c             	add    $0x2c,%esp
  80109d:	5b                   	pop    %ebx
  80109e:	5e                   	pop    %esi
  80109f:	5f                   	pop    %edi
  8010a0:	5d                   	pop    %ebp
  8010a1:	c3                   	ret    

008010a2 <sys_env_set_oflow_upcall>:

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	57                   	push   %edi
  8010a6:	56                   	push   %esi
  8010a7:	53                   	push   %ebx
  8010a8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b0:	b8 11 00 00 00       	mov    $0x11,%eax
  8010b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bb:	89 df                	mov    %ebx,%edi
  8010bd:	89 de                	mov    %ebx,%esi
  8010bf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	7e 28                	jle    8010ed <sys_env_set_oflow_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c9:	c7 44 24 0c 11 00 00 	movl   $0x11,0xc(%esp)
  8010d0:	00 
  8010d1:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  8010d8:	00 
  8010d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010e0:	00 
  8010e1:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  8010e8:	e8 bb f1 ff ff       	call   8002a8 <_panic>
}

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_oflow_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8010ed:	83 c4 2c             	add    $0x2c,%esp
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <sys_env_set_bdschk_upcall>:

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
  8010fb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801103:	b8 12 00 00 00       	mov    $0x12,%eax
  801108:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80110b:	8b 55 08             	mov    0x8(%ebp),%edx
  80110e:	89 df                	mov    %ebx,%edi
  801110:	89 de                	mov    %ebx,%esi
  801112:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801114:	85 c0                	test   %eax,%eax
  801116:	7e 28                	jle    801140 <sys_env_set_bdschk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801118:	89 44 24 10          	mov    %eax,0x10(%esp)
  80111c:	c7 44 24 0c 12 00 00 	movl   $0x12,0xc(%esp)
  801123:	00 
  801124:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  80112b:	00 
  80112c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801133:	00 
  801134:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  80113b:	e8 68 f1 ff ff       	call   8002a8 <_panic>
}

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bdschk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801140:	83 c4 2c             	add    $0x2c,%esp
  801143:	5b                   	pop    %ebx
  801144:	5e                   	pop    %esi
  801145:	5f                   	pop    %edi
  801146:	5d                   	pop    %ebp
  801147:	c3                   	ret    

00801148 <sys_env_set_illopcd_upcall>:

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	57                   	push   %edi
  80114c:	56                   	push   %esi
  80114d:	53                   	push   %ebx
  80114e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801151:	bb 00 00 00 00       	mov    $0x0,%ebx
  801156:	b8 13 00 00 00       	mov    $0x13,%eax
  80115b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115e:	8b 55 08             	mov    0x8(%ebp),%edx
  801161:	89 df                	mov    %ebx,%edi
  801163:	89 de                	mov    %ebx,%esi
  801165:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801167:	85 c0                	test   %eax,%eax
  801169:	7e 28                	jle    801193 <sys_env_set_illopcd_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80116b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80116f:	c7 44 24 0c 13 00 00 	movl   $0x13,0xc(%esp)
  801176:	00 
  801177:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  80117e:	00 
  80117f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801186:	00 
  801187:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  80118e:	e8 15 f1 ff ff       	call   8002a8 <_panic>
}

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_illopcd_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801193:	83 c4 2c             	add    $0x2c,%esp
  801196:	5b                   	pop    %ebx
  801197:	5e                   	pop    %esi
  801198:	5f                   	pop    %edi
  801199:	5d                   	pop    %ebp
  80119a:	c3                   	ret    

0080119b <sys_env_set_dvcntavl_upcall>:

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	57                   	push   %edi
  80119f:	56                   	push   %esi
  8011a0:	53                   	push   %ebx
  8011a1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a9:	b8 14 00 00 00       	mov    $0x14,%eax
  8011ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b4:	89 df                	mov    %ebx,%edi
  8011b6:	89 de                	mov    %ebx,%esi
  8011b8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	7e 28                	jle    8011e6 <sys_env_set_dvcntavl_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c2:	c7 44 24 0c 14 00 00 	movl   $0x14,0xc(%esp)
  8011c9:	00 
  8011ca:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  8011d1:	00 
  8011d2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011d9:	00 
  8011da:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  8011e1:	e8 c2 f0 ff ff       	call   8002a8 <_panic>
}

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dvcntavl_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8011e6:	83 c4 2c             	add    $0x2c,%esp
  8011e9:	5b                   	pop    %ebx
  8011ea:	5e                   	pop    %esi
  8011eb:	5f                   	pop    %edi
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <sys_env_set_dbfault_upcall>:

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	57                   	push   %edi
  8011f2:	56                   	push   %esi
  8011f3:	53                   	push   %ebx
  8011f4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011fc:	b8 15 00 00 00       	mov    $0x15,%eax
  801201:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801204:	8b 55 08             	mov    0x8(%ebp),%edx
  801207:	89 df                	mov    %ebx,%edi
  801209:	89 de                	mov    %ebx,%esi
  80120b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80120d:	85 c0                	test   %eax,%eax
  80120f:	7e 28                	jle    801239 <sys_env_set_dbfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801211:	89 44 24 10          	mov    %eax,0x10(%esp)
  801215:	c7 44 24 0c 15 00 00 	movl   $0x15,0xc(%esp)
  80121c:	00 
  80121d:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  801224:	00 
  801225:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80122c:	00 
  80122d:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  801234:	e8 6f f0 ff ff       	call   8002a8 <_panic>
}

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dbfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801239:	83 c4 2c             	add    $0x2c,%esp
  80123c:	5b                   	pop    %ebx
  80123d:	5e                   	pop    %esi
  80123e:	5f                   	pop    %edi
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <sys_env_set_ivldtss_upcall>:

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	57                   	push   %edi
  801245:	56                   	push   %esi
  801246:	53                   	push   %ebx
  801247:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80124a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124f:	b8 16 00 00 00       	mov    $0x16,%eax
  801254:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801257:	8b 55 08             	mov    0x8(%ebp),%edx
  80125a:	89 df                	mov    %ebx,%edi
  80125c:	89 de                	mov    %ebx,%esi
  80125e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801260:	85 c0                	test   %eax,%eax
  801262:	7e 28                	jle    80128c <sys_env_set_ivldtss_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801264:	89 44 24 10          	mov    %eax,0x10(%esp)
  801268:	c7 44 24 0c 16 00 00 	movl   $0x16,0xc(%esp)
  80126f:	00 
  801270:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  801277:	00 
  801278:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80127f:	00 
  801280:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  801287:	e8 1c f0 ff ff       	call   8002a8 <_panic>
}

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_ivldtss_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80128c:	83 c4 2c             	add    $0x2c,%esp
  80128f:	5b                   	pop    %ebx
  801290:	5e                   	pop    %esi
  801291:	5f                   	pop    %edi
  801292:	5d                   	pop    %ebp
  801293:	c3                   	ret    

00801294 <sys_env_set_segntprst_upcall>:

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	57                   	push   %edi
  801298:	56                   	push   %esi
  801299:	53                   	push   %ebx
  80129a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80129d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012a2:	b8 17 00 00 00       	mov    $0x17,%eax
  8012a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ad:	89 df                	mov    %ebx,%edi
  8012af:	89 de                	mov    %ebx,%esi
  8012b1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	7e 28                	jle    8012df <sys_env_set_segntprst_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012bb:	c7 44 24 0c 17 00 00 	movl   $0x17,0xc(%esp)
  8012c2:	00 
  8012c3:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  8012ca:	00 
  8012cb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012d2:	00 
  8012d3:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  8012da:	e8 c9 ef ff ff       	call   8002a8 <_panic>
}

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_segntprst_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8012df:	83 c4 2c             	add    $0x2c,%esp
  8012e2:	5b                   	pop    %ebx
  8012e3:	5e                   	pop    %esi
  8012e4:	5f                   	pop    %edi
  8012e5:	5d                   	pop    %ebp
  8012e6:	c3                   	ret    

008012e7 <sys_env_set_stkexception_upcall>:

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	57                   	push   %edi
  8012eb:	56                   	push   %esi
  8012ec:	53                   	push   %ebx
  8012ed:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012f5:	b8 18 00 00 00       	mov    $0x18,%eax
  8012fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801300:	89 df                	mov    %ebx,%edi
  801302:	89 de                	mov    %ebx,%esi
  801304:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801306:	85 c0                	test   %eax,%eax
  801308:	7e 28                	jle    801332 <sys_env_set_stkexception_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80130a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80130e:	c7 44 24 0c 18 00 00 	movl   $0x18,0xc(%esp)
  801315:	00 
  801316:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  80131d:	00 
  80131e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801325:	00 
  801326:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  80132d:	e8 76 ef ff ff       	call   8002a8 <_panic>
}

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_stkexception_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801332:	83 c4 2c             	add    $0x2c,%esp
  801335:	5b                   	pop    %ebx
  801336:	5e                   	pop    %esi
  801337:	5f                   	pop    %edi
  801338:	5d                   	pop    %ebp
  801339:	c3                   	ret    

0080133a <sys_env_set_gpfault_upcall>:

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	57                   	push   %edi
  80133e:	56                   	push   %esi
  80133f:	53                   	push   %ebx
  801340:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801343:	bb 00 00 00 00       	mov    $0x0,%ebx
  801348:	b8 19 00 00 00       	mov    $0x19,%eax
  80134d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801350:	8b 55 08             	mov    0x8(%ebp),%edx
  801353:	89 df                	mov    %ebx,%edi
  801355:	89 de                	mov    %ebx,%esi
  801357:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801359:	85 c0                	test   %eax,%eax
  80135b:	7e 28                	jle    801385 <sys_env_set_gpfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80135d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801361:	c7 44 24 0c 19 00 00 	movl   $0x19,0xc(%esp)
  801368:	00 
  801369:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  801370:	00 
  801371:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801378:	00 
  801379:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  801380:	e8 23 ef ff ff       	call   8002a8 <_panic>
}

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_gpfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801385:	83 c4 2c             	add    $0x2c,%esp
  801388:	5b                   	pop    %ebx
  801389:	5e                   	pop    %esi
  80138a:	5f                   	pop    %edi
  80138b:	5d                   	pop    %ebp
  80138c:	c3                   	ret    

0080138d <sys_env_set_fperror_upcall>:

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	57                   	push   %edi
  801391:	56                   	push   %esi
  801392:	53                   	push   %ebx
  801393:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801396:	bb 00 00 00 00       	mov    $0x0,%ebx
  80139b:	b8 1a 00 00 00       	mov    $0x1a,%eax
  8013a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8013a6:	89 df                	mov    %ebx,%edi
  8013a8:	89 de                	mov    %ebx,%esi
  8013aa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013ac:	85 c0                	test   %eax,%eax
  8013ae:	7e 28                	jle    8013d8 <sys_env_set_fperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013b4:	c7 44 24 0c 1a 00 00 	movl   $0x1a,0xc(%esp)
  8013bb:	00 
  8013bc:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  8013c3:	00 
  8013c4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013cb:	00 
  8013cc:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  8013d3:	e8 d0 ee ff ff       	call   8002a8 <_panic>
}

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_fperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8013d8:	83 c4 2c             	add    $0x2c,%esp
  8013db:	5b                   	pop    %ebx
  8013dc:	5e                   	pop    %esi
  8013dd:	5f                   	pop    %edi
  8013de:	5d                   	pop    %ebp
  8013df:	c3                   	ret    

008013e0 <sys_env_set_algchk_upcall>:

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	57                   	push   %edi
  8013e4:	56                   	push   %esi
  8013e5:	53                   	push   %ebx
  8013e6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013ee:	b8 1b 00 00 00       	mov    $0x1b,%eax
  8013f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f9:	89 df                	mov    %ebx,%edi
  8013fb:	89 de                	mov    %ebx,%esi
  8013fd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013ff:	85 c0                	test   %eax,%eax
  801401:	7e 28                	jle    80142b <sys_env_set_algchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801403:	89 44 24 10          	mov    %eax,0x10(%esp)
  801407:	c7 44 24 0c 1b 00 00 	movl   $0x1b,0xc(%esp)
  80140e:	00 
  80140f:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  801416:	00 
  801417:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80141e:	00 
  80141f:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  801426:	e8 7d ee ff ff       	call   8002a8 <_panic>
}

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_algchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80142b:	83 c4 2c             	add    $0x2c,%esp
  80142e:	5b                   	pop    %ebx
  80142f:	5e                   	pop    %esi
  801430:	5f                   	pop    %edi
  801431:	5d                   	pop    %ebp
  801432:	c3                   	ret    

00801433 <sys_env_set_mchchk_upcall>:

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	57                   	push   %edi
  801437:	56                   	push   %esi
  801438:	53                   	push   %ebx
  801439:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80143c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801441:	b8 1c 00 00 00       	mov    $0x1c,%eax
  801446:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801449:	8b 55 08             	mov    0x8(%ebp),%edx
  80144c:	89 df                	mov    %ebx,%edi
  80144e:	89 de                	mov    %ebx,%esi
  801450:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801452:	85 c0                	test   %eax,%eax
  801454:	7e 28                	jle    80147e <sys_env_set_mchchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801456:	89 44 24 10          	mov    %eax,0x10(%esp)
  80145a:	c7 44 24 0c 1c 00 00 	movl   $0x1c,0xc(%esp)
  801461:	00 
  801462:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  801469:	00 
  80146a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801471:	00 
  801472:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  801479:	e8 2a ee ff ff       	call   8002a8 <_panic>
}

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_mchchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80147e:	83 c4 2c             	add    $0x2c,%esp
  801481:	5b                   	pop    %ebx
  801482:	5e                   	pop    %esi
  801483:	5f                   	pop    %edi
  801484:	5d                   	pop    %ebp
  801485:	c3                   	ret    

00801486 <sys_env_set_SIMDfperror_upcall>:

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	57                   	push   %edi
  80148a:	56                   	push   %esi
  80148b:	53                   	push   %ebx
  80148c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80148f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801494:	b8 1d 00 00 00       	mov    $0x1d,%eax
  801499:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80149c:	8b 55 08             	mov    0x8(%ebp),%edx
  80149f:	89 df                	mov    %ebx,%edi
  8014a1:	89 de                	mov    %ebx,%esi
  8014a3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	7e 28                	jle    8014d1 <sys_env_set_SIMDfperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014a9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014ad:	c7 44 24 0c 1d 00 00 	movl   $0x1d,0xc(%esp)
  8014b4:	00 
  8014b5:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  8014bc:	00 
  8014bd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014c4:	00 
  8014c5:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  8014cc:	e8 d7 ed ff ff       	call   8002a8 <_panic>
}

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_SIMDfperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8014d1:	83 c4 2c             	add    $0x2c,%esp
  8014d4:	5b                   	pop    %ebx
  8014d5:	5e                   	pop    %esi
  8014d6:	5f                   	pop    %edi
  8014d7:	5d                   	pop    %ebp
  8014d8:	c3                   	ret    
  8014d9:	00 00                	add    %al,(%eax)
	...

008014dc <__udivdi3>:
  8014dc:	55                   	push   %ebp
  8014dd:	57                   	push   %edi
  8014de:	56                   	push   %esi
  8014df:	83 ec 10             	sub    $0x10,%esp
  8014e2:	8b 74 24 20          	mov    0x20(%esp),%esi
  8014e6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8014ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014ee:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8014f2:	89 cd                	mov    %ecx,%ebp
  8014f4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	75 2c                	jne    801528 <__udivdi3+0x4c>
  8014fc:	39 f9                	cmp    %edi,%ecx
  8014fe:	77 68                	ja     801568 <__udivdi3+0x8c>
  801500:	85 c9                	test   %ecx,%ecx
  801502:	75 0b                	jne    80150f <__udivdi3+0x33>
  801504:	b8 01 00 00 00       	mov    $0x1,%eax
  801509:	31 d2                	xor    %edx,%edx
  80150b:	f7 f1                	div    %ecx
  80150d:	89 c1                	mov    %eax,%ecx
  80150f:	31 d2                	xor    %edx,%edx
  801511:	89 f8                	mov    %edi,%eax
  801513:	f7 f1                	div    %ecx
  801515:	89 c7                	mov    %eax,%edi
  801517:	89 f0                	mov    %esi,%eax
  801519:	f7 f1                	div    %ecx
  80151b:	89 c6                	mov    %eax,%esi
  80151d:	89 f0                	mov    %esi,%eax
  80151f:	89 fa                	mov    %edi,%edx
  801521:	83 c4 10             	add    $0x10,%esp
  801524:	5e                   	pop    %esi
  801525:	5f                   	pop    %edi
  801526:	5d                   	pop    %ebp
  801527:	c3                   	ret    
  801528:	39 f8                	cmp    %edi,%eax
  80152a:	77 2c                	ja     801558 <__udivdi3+0x7c>
  80152c:	0f bd f0             	bsr    %eax,%esi
  80152f:	83 f6 1f             	xor    $0x1f,%esi
  801532:	75 4c                	jne    801580 <__udivdi3+0xa4>
  801534:	39 f8                	cmp    %edi,%eax
  801536:	bf 00 00 00 00       	mov    $0x0,%edi
  80153b:	72 0a                	jb     801547 <__udivdi3+0x6b>
  80153d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801541:	0f 87 ad 00 00 00    	ja     8015f4 <__udivdi3+0x118>
  801547:	be 01 00 00 00       	mov    $0x1,%esi
  80154c:	89 f0                	mov    %esi,%eax
  80154e:	89 fa                	mov    %edi,%edx
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	5e                   	pop    %esi
  801554:	5f                   	pop    %edi
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    
  801557:	90                   	nop
  801558:	31 ff                	xor    %edi,%edi
  80155a:	31 f6                	xor    %esi,%esi
  80155c:	89 f0                	mov    %esi,%eax
  80155e:	89 fa                	mov    %edi,%edx
  801560:	83 c4 10             	add    $0x10,%esp
  801563:	5e                   	pop    %esi
  801564:	5f                   	pop    %edi
  801565:	5d                   	pop    %ebp
  801566:	c3                   	ret    
  801567:	90                   	nop
  801568:	89 fa                	mov    %edi,%edx
  80156a:	89 f0                	mov    %esi,%eax
  80156c:	f7 f1                	div    %ecx
  80156e:	89 c6                	mov    %eax,%esi
  801570:	31 ff                	xor    %edi,%edi
  801572:	89 f0                	mov    %esi,%eax
  801574:	89 fa                	mov    %edi,%edx
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	5e                   	pop    %esi
  80157a:	5f                   	pop    %edi
  80157b:	5d                   	pop    %ebp
  80157c:	c3                   	ret    
  80157d:	8d 76 00             	lea    0x0(%esi),%esi
  801580:	89 f1                	mov    %esi,%ecx
  801582:	d3 e0                	shl    %cl,%eax
  801584:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801588:	b8 20 00 00 00       	mov    $0x20,%eax
  80158d:	29 f0                	sub    %esi,%eax
  80158f:	89 ea                	mov    %ebp,%edx
  801591:	88 c1                	mov    %al,%cl
  801593:	d3 ea                	shr    %cl,%edx
  801595:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801599:	09 ca                	or     %ecx,%edx
  80159b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80159f:	89 f1                	mov    %esi,%ecx
  8015a1:	d3 e5                	shl    %cl,%ebp
  8015a3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8015a7:	89 fd                	mov    %edi,%ebp
  8015a9:	88 c1                	mov    %al,%cl
  8015ab:	d3 ed                	shr    %cl,%ebp
  8015ad:	89 fa                	mov    %edi,%edx
  8015af:	89 f1                	mov    %esi,%ecx
  8015b1:	d3 e2                	shl    %cl,%edx
  8015b3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015b7:	88 c1                	mov    %al,%cl
  8015b9:	d3 ef                	shr    %cl,%edi
  8015bb:	09 d7                	or     %edx,%edi
  8015bd:	89 f8                	mov    %edi,%eax
  8015bf:	89 ea                	mov    %ebp,%edx
  8015c1:	f7 74 24 08          	divl   0x8(%esp)
  8015c5:	89 d1                	mov    %edx,%ecx
  8015c7:	89 c7                	mov    %eax,%edi
  8015c9:	f7 64 24 0c          	mull   0xc(%esp)
  8015cd:	39 d1                	cmp    %edx,%ecx
  8015cf:	72 17                	jb     8015e8 <__udivdi3+0x10c>
  8015d1:	74 09                	je     8015dc <__udivdi3+0x100>
  8015d3:	89 fe                	mov    %edi,%esi
  8015d5:	31 ff                	xor    %edi,%edi
  8015d7:	e9 41 ff ff ff       	jmp    80151d <__udivdi3+0x41>
  8015dc:	8b 54 24 04          	mov    0x4(%esp),%edx
  8015e0:	89 f1                	mov    %esi,%ecx
  8015e2:	d3 e2                	shl    %cl,%edx
  8015e4:	39 c2                	cmp    %eax,%edx
  8015e6:	73 eb                	jae    8015d3 <__udivdi3+0xf7>
  8015e8:	8d 77 ff             	lea    -0x1(%edi),%esi
  8015eb:	31 ff                	xor    %edi,%edi
  8015ed:	e9 2b ff ff ff       	jmp    80151d <__udivdi3+0x41>
  8015f2:	66 90                	xchg   %ax,%ax
  8015f4:	31 f6                	xor    %esi,%esi
  8015f6:	e9 22 ff ff ff       	jmp    80151d <__udivdi3+0x41>
	...

008015fc <__umoddi3>:
  8015fc:	55                   	push   %ebp
  8015fd:	57                   	push   %edi
  8015fe:	56                   	push   %esi
  8015ff:	83 ec 20             	sub    $0x20,%esp
  801602:	8b 44 24 30          	mov    0x30(%esp),%eax
  801606:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80160a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80160e:	8b 74 24 34          	mov    0x34(%esp),%esi
  801612:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801616:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80161a:	89 c7                	mov    %eax,%edi
  80161c:	89 f2                	mov    %esi,%edx
  80161e:	85 ed                	test   %ebp,%ebp
  801620:	75 16                	jne    801638 <__umoddi3+0x3c>
  801622:	39 f1                	cmp    %esi,%ecx
  801624:	0f 86 a6 00 00 00    	jbe    8016d0 <__umoddi3+0xd4>
  80162a:	f7 f1                	div    %ecx
  80162c:	89 d0                	mov    %edx,%eax
  80162e:	31 d2                	xor    %edx,%edx
  801630:	83 c4 20             	add    $0x20,%esp
  801633:	5e                   	pop    %esi
  801634:	5f                   	pop    %edi
  801635:	5d                   	pop    %ebp
  801636:	c3                   	ret    
  801637:	90                   	nop
  801638:	39 f5                	cmp    %esi,%ebp
  80163a:	0f 87 ac 00 00 00    	ja     8016ec <__umoddi3+0xf0>
  801640:	0f bd c5             	bsr    %ebp,%eax
  801643:	83 f0 1f             	xor    $0x1f,%eax
  801646:	89 44 24 10          	mov    %eax,0x10(%esp)
  80164a:	0f 84 a8 00 00 00    	je     8016f8 <__umoddi3+0xfc>
  801650:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801654:	d3 e5                	shl    %cl,%ebp
  801656:	bf 20 00 00 00       	mov    $0x20,%edi
  80165b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80165f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801663:	89 f9                	mov    %edi,%ecx
  801665:	d3 e8                	shr    %cl,%eax
  801667:	09 e8                	or     %ebp,%eax
  801669:	89 44 24 18          	mov    %eax,0x18(%esp)
  80166d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801671:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801675:	d3 e0                	shl    %cl,%eax
  801677:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80167b:	89 f2                	mov    %esi,%edx
  80167d:	d3 e2                	shl    %cl,%edx
  80167f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801683:	d3 e0                	shl    %cl,%eax
  801685:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801689:	8b 44 24 14          	mov    0x14(%esp),%eax
  80168d:	89 f9                	mov    %edi,%ecx
  80168f:	d3 e8                	shr    %cl,%eax
  801691:	09 d0                	or     %edx,%eax
  801693:	d3 ee                	shr    %cl,%esi
  801695:	89 f2                	mov    %esi,%edx
  801697:	f7 74 24 18          	divl   0x18(%esp)
  80169b:	89 d6                	mov    %edx,%esi
  80169d:	f7 64 24 0c          	mull   0xc(%esp)
  8016a1:	89 c5                	mov    %eax,%ebp
  8016a3:	89 d1                	mov    %edx,%ecx
  8016a5:	39 d6                	cmp    %edx,%esi
  8016a7:	72 67                	jb     801710 <__umoddi3+0x114>
  8016a9:	74 75                	je     801720 <__umoddi3+0x124>
  8016ab:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8016af:	29 e8                	sub    %ebp,%eax
  8016b1:	19 ce                	sbb    %ecx,%esi
  8016b3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8016b7:	d3 e8                	shr    %cl,%eax
  8016b9:	89 f2                	mov    %esi,%edx
  8016bb:	89 f9                	mov    %edi,%ecx
  8016bd:	d3 e2                	shl    %cl,%edx
  8016bf:	09 d0                	or     %edx,%eax
  8016c1:	89 f2                	mov    %esi,%edx
  8016c3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8016c7:	d3 ea                	shr    %cl,%edx
  8016c9:	83 c4 20             	add    $0x20,%esp
  8016cc:	5e                   	pop    %esi
  8016cd:	5f                   	pop    %edi
  8016ce:	5d                   	pop    %ebp
  8016cf:	c3                   	ret    
  8016d0:	85 c9                	test   %ecx,%ecx
  8016d2:	75 0b                	jne    8016df <__umoddi3+0xe3>
  8016d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8016d9:	31 d2                	xor    %edx,%edx
  8016db:	f7 f1                	div    %ecx
  8016dd:	89 c1                	mov    %eax,%ecx
  8016df:	89 f0                	mov    %esi,%eax
  8016e1:	31 d2                	xor    %edx,%edx
  8016e3:	f7 f1                	div    %ecx
  8016e5:	89 f8                	mov    %edi,%eax
  8016e7:	e9 3e ff ff ff       	jmp    80162a <__umoddi3+0x2e>
  8016ec:	89 f2                	mov    %esi,%edx
  8016ee:	83 c4 20             	add    $0x20,%esp
  8016f1:	5e                   	pop    %esi
  8016f2:	5f                   	pop    %edi
  8016f3:	5d                   	pop    %ebp
  8016f4:	c3                   	ret    
  8016f5:	8d 76 00             	lea    0x0(%esi),%esi
  8016f8:	39 f5                	cmp    %esi,%ebp
  8016fa:	72 04                	jb     801700 <__umoddi3+0x104>
  8016fc:	39 f9                	cmp    %edi,%ecx
  8016fe:	77 06                	ja     801706 <__umoddi3+0x10a>
  801700:	89 f2                	mov    %esi,%edx
  801702:	29 cf                	sub    %ecx,%edi
  801704:	19 ea                	sbb    %ebp,%edx
  801706:	89 f8                	mov    %edi,%eax
  801708:	83 c4 20             	add    $0x20,%esp
  80170b:	5e                   	pop    %esi
  80170c:	5f                   	pop    %edi
  80170d:	5d                   	pop    %ebp
  80170e:	c3                   	ret    
  80170f:	90                   	nop
  801710:	89 d1                	mov    %edx,%ecx
  801712:	89 c5                	mov    %eax,%ebp
  801714:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801718:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80171c:	eb 8d                	jmp    8016ab <__umoddi3+0xaf>
  80171e:	66 90                	xchg   %ax,%ax
  801720:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801724:	72 ea                	jb     801710 <__umoddi3+0x114>
  801726:	89 f1                	mov    %esi,%ecx
  801728:	eb 81                	jmp    8016ab <__umoddi3+0xaf>
