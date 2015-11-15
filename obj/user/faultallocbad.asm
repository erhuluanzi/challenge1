
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800040:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800044:	c7 04 24 a0 16 80 00 	movl   $0x8016a0,(%esp)
  80004b:	e8 f0 01 00 00       	call   800240 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 72 0b 00 00       	call   800be1 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 c0 16 80 	movl   $0x8016c0,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 aa 16 80 00 	movl   $0x8016aa,(%esp)
  800092:	e8 b1 00 00 00       	call   800148 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 ec 16 80 	movl   $0x8016ec,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 e1 06 00 00       	call   800794 <snprintf>
}
  8000b3:	83 c4 24             	add    $0x24,%esp
  8000b6:	5b                   	pop    %ebx
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <umain>:

void
umain(int argc, char **argv)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000bf:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  8000c6:	e8 b1 12 00 00       	call   80137c <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000cb:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000da:	e8 35 0a 00 00       	call   800b14 <sys_cputs>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 10             	sub    $0x10,%esp
  8000ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000f2:	e8 ac 0a 00 00       	call   800ba3 <sys_getenvid>
  8000f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fc:	8d 04 40             	lea    (%eax,%eax,2),%eax
  8000ff:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800102:	c1 e0 04             	shl    $0x4,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 f6                	test   %esi,%esi
  800111:	7e 07                	jle    80011a <libmain+0x36>
		binaryname = argv[0];
  800113:	8b 03                	mov    (%ebx),%eax
  800115:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80011a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80011e:	89 34 24             	mov    %esi,(%esp)
  800121:	e8 93 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800126:	e8 09 00 00 00       	call   800134 <exit>
}
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    
	...

00800134 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80013a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800141:	e8 0b 0a 00 00       	call   800b51 <sys_env_destroy>
}
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800150:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800153:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800159:	e8 45 0a 00 00       	call   800ba3 <sys_getenvid>
  80015e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800161:	89 54 24 10          	mov    %edx,0x10(%esp)
  800165:	8b 55 08             	mov    0x8(%ebp),%edx
  800168:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80016c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800170:	89 44 24 04          	mov    %eax,0x4(%esp)
  800174:	c7 04 24 18 17 80 00 	movl   $0x801718,(%esp)
  80017b:	e8 c0 00 00 00       	call   800240 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	89 74 24 04          	mov    %esi,0x4(%esp)
  800184:	8b 45 10             	mov    0x10(%ebp),%eax
  800187:	89 04 24             	mov    %eax,(%esp)
  80018a:	e8 50 00 00 00       	call   8001df <vcprintf>
	cprintf("\n");
  80018f:	c7 04 24 a8 16 80 00 	movl   $0x8016a8,(%esp)
  800196:	e8 a5 00 00 00       	call   800240 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x53>
	...

008001a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 14             	sub    $0x14,%esp
  8001a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001aa:	8b 03                	mov    (%ebx),%eax
  8001ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8001af:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001b3:	40                   	inc    %eax
  8001b4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	75 19                	jne    8001d6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001bd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001c4:	00 
  8001c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c8:	89 04 24             	mov    %eax,(%esp)
  8001cb:	e8 44 09 00 00       	call   800b14 <sys_cputs>
		b->idx = 0;
  8001d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001d6:	ff 43 04             	incl   0x4(%ebx)
}
  8001d9:	83 c4 14             	add    $0x14,%esp
  8001dc:	5b                   	pop    %ebx
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001e8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ef:	00 00 00 
	b.cnt = 0;
  8001f2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800203:	8b 45 08             	mov    0x8(%ebp),%eax
  800206:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800210:	89 44 24 04          	mov    %eax,0x4(%esp)
  800214:	c7 04 24 a0 01 80 00 	movl   $0x8001a0,(%esp)
  80021b:	e8 b4 01 00 00       	call   8003d4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800220:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800230:	89 04 24             	mov    %eax,(%esp)
  800233:	e8 dc 08 00 00       	call   800b14 <sys_cputs>

	return b.cnt;
}
  800238:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800246:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800249:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024d:	8b 45 08             	mov    0x8(%ebp),%eax
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	e8 87 ff ff ff       	call   8001df <vcprintf>
	va_end(ap);

	return cnt;
}
  800258:	c9                   	leave  
  800259:	c3                   	ret    
	...

0080025c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	57                   	push   %edi
  800260:	56                   	push   %esi
  800261:	53                   	push   %ebx
  800262:	83 ec 3c             	sub    $0x3c,%esp
  800265:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800268:	89 d7                	mov    %edx,%edi
  80026a:	8b 45 08             	mov    0x8(%ebp),%eax
  80026d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800270:	8b 45 0c             	mov    0xc(%ebp),%eax
  800273:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800276:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800279:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80027c:	85 c0                	test   %eax,%eax
  80027e:	75 08                	jne    800288 <printnum+0x2c>
  800280:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800283:	39 45 10             	cmp    %eax,0x10(%ebp)
  800286:	77 57                	ja     8002df <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800288:	89 74 24 10          	mov    %esi,0x10(%esp)
  80028c:	4b                   	dec    %ebx
  80028d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800291:	8b 45 10             	mov    0x10(%ebp),%eax
  800294:	89 44 24 08          	mov    %eax,0x8(%esp)
  800298:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80029c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002a0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002a7:	00 
  8002a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ab:	89 04 24             	mov    %eax,(%esp)
  8002ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b5:	e8 7e 11 00 00       	call   801438 <__udivdi3>
  8002ba:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002be:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002c2:	89 04 24             	mov    %eax,(%esp)
  8002c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002c9:	89 fa                	mov    %edi,%edx
  8002cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ce:	e8 89 ff ff ff       	call   80025c <printnum>
  8002d3:	eb 0f                	jmp    8002e4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d9:	89 34 24             	mov    %esi,(%esp)
  8002dc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002df:	4b                   	dec    %ebx
  8002e0:	85 db                	test   %ebx,%ebx
  8002e2:	7f f1                	jg     8002d5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002fa:	00 
  8002fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002fe:	89 04 24             	mov    %eax,(%esp)
  800301:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800304:	89 44 24 04          	mov    %eax,0x4(%esp)
  800308:	e8 4b 12 00 00       	call   801558 <__umoddi3>
  80030d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800311:	0f be 80 3b 17 80 00 	movsbl 0x80173b(%eax),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80031e:	83 c4 3c             	add    $0x3c,%esp
  800321:	5b                   	pop    %ebx
  800322:	5e                   	pop    %esi
  800323:	5f                   	pop    %edi
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    

00800326 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800329:	83 fa 01             	cmp    $0x1,%edx
  80032c:	7e 0e                	jle    80033c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80032e:	8b 10                	mov    (%eax),%edx
  800330:	8d 4a 08             	lea    0x8(%edx),%ecx
  800333:	89 08                	mov    %ecx,(%eax)
  800335:	8b 02                	mov    (%edx),%eax
  800337:	8b 52 04             	mov    0x4(%edx),%edx
  80033a:	eb 22                	jmp    80035e <getuint+0x38>
	else if (lflag)
  80033c:	85 d2                	test   %edx,%edx
  80033e:	74 10                	je     800350 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800340:	8b 10                	mov    (%eax),%edx
  800342:	8d 4a 04             	lea    0x4(%edx),%ecx
  800345:	89 08                	mov    %ecx,(%eax)
  800347:	8b 02                	mov    (%edx),%eax
  800349:	ba 00 00 00 00       	mov    $0x0,%edx
  80034e:	eb 0e                	jmp    80035e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800350:	8b 10                	mov    (%eax),%edx
  800352:	8d 4a 04             	lea    0x4(%edx),%ecx
  800355:	89 08                	mov    %ecx,(%eax)
  800357:	8b 02                	mov    (%edx),%eax
  800359:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80035e:	5d                   	pop    %ebp
  80035f:	c3                   	ret    

00800360 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800363:	83 fa 01             	cmp    $0x1,%edx
  800366:	7e 0e                	jle    800376 <getint+0x16>
		return va_arg(*ap, long long);
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 02                	mov    (%edx),%eax
  800371:	8b 52 04             	mov    0x4(%edx),%edx
  800374:	eb 1a                	jmp    800390 <getint+0x30>
	else if (lflag)
  800376:	85 d2                	test   %edx,%edx
  800378:	74 0c                	je     800386 <getint+0x26>
		return va_arg(*ap, long);
  80037a:	8b 10                	mov    (%eax),%edx
  80037c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037f:	89 08                	mov    %ecx,(%eax)
  800381:	8b 02                	mov    (%edx),%eax
  800383:	99                   	cltd   
  800384:	eb 0a                	jmp    800390 <getint+0x30>
	else
		return va_arg(*ap, int);
  800386:	8b 10                	mov    (%eax),%edx
  800388:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038b:	89 08                	mov    %ecx,(%eax)
  80038d:	8b 02                	mov    (%edx),%eax
  80038f:	99                   	cltd   
}
  800390:	5d                   	pop    %ebp
  800391:	c3                   	ret    

00800392 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
  800395:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800398:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80039b:	8b 10                	mov    (%eax),%edx
  80039d:	3b 50 04             	cmp    0x4(%eax),%edx
  8003a0:	73 08                	jae    8003aa <sprintputch+0x18>
		*b->buf++ = ch;
  8003a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a5:	88 0a                	mov    %cl,(%edx)
  8003a7:	42                   	inc    %edx
  8003a8:	89 10                	mov    %edx,(%eax)
}
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003b2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ca:	89 04 24             	mov    %eax,(%esp)
  8003cd:	e8 02 00 00 00       	call   8003d4 <vprintfmt>
	va_end(ap);
}
  8003d2:	c9                   	leave  
  8003d3:	c3                   	ret    

008003d4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	57                   	push   %edi
  8003d8:	56                   	push   %esi
  8003d9:	53                   	push   %ebx
  8003da:	83 ec 4c             	sub    $0x4c,%esp
  8003dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003e0:	8b 75 10             	mov    0x10(%ebp),%esi
  8003e3:	eb 12                	jmp    8003f7 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003e5:	85 c0                	test   %eax,%eax
  8003e7:	0f 84 40 03 00 00    	je     80072d <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  8003ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003f1:	89 04 24             	mov    %eax,(%esp)
  8003f4:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f7:	0f b6 06             	movzbl (%esi),%eax
  8003fa:	46                   	inc    %esi
  8003fb:	83 f8 25             	cmp    $0x25,%eax
  8003fe:	75 e5                	jne    8003e5 <vprintfmt+0x11>
  800400:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800404:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80040b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800410:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800417:	ba 00 00 00 00       	mov    $0x0,%edx
  80041c:	eb 26                	jmp    800444 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800421:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800425:	eb 1d                	jmp    800444 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80042a:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80042e:	eb 14                	jmp    800444 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800433:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80043a:	eb 08                	jmp    800444 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80043c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80043f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	0f b6 06             	movzbl (%esi),%eax
  800447:	8d 4e 01             	lea    0x1(%esi),%ecx
  80044a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80044d:	8a 0e                	mov    (%esi),%cl
  80044f:	83 e9 23             	sub    $0x23,%ecx
  800452:	80 f9 55             	cmp    $0x55,%cl
  800455:	0f 87 b6 02 00 00    	ja     800711 <vprintfmt+0x33d>
  80045b:	0f b6 c9             	movzbl %cl,%ecx
  80045e:	ff 24 8d 00 18 80 00 	jmp    *0x801800(,%ecx,4)
  800465:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800468:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80046d:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800470:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  800474:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800477:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80047a:	83 f9 09             	cmp    $0x9,%ecx
  80047d:	77 2a                	ja     8004a9 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80047f:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800480:	eb eb                	jmp    80046d <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800482:	8b 45 14             	mov    0x14(%ebp),%eax
  800485:	8d 48 04             	lea    0x4(%eax),%ecx
  800488:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80048b:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800490:	eb 17                	jmp    8004a9 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800492:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800496:	78 98                	js     800430 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80049b:	eb a7                	jmp    800444 <vprintfmt+0x70>
  80049d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004a0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004a7:	eb 9b                	jmp    800444 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004a9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ad:	79 95                	jns    800444 <vprintfmt+0x70>
  8004af:	eb 8b                	jmp    80043c <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004b1:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004b5:	eb 8d                	jmp    800444 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ba:	8d 50 04             	lea    0x4(%eax),%edx
  8004bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c4:	8b 00                	mov    (%eax),%eax
  8004c6:	89 04 24             	mov    %eax,(%esp)
  8004c9:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004cf:	e9 23 ff ff ff       	jmp    8003f7 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	8d 50 04             	lea    0x4(%eax),%edx
  8004da:	89 55 14             	mov    %edx,0x14(%ebp)
  8004dd:	8b 00                	mov    (%eax),%eax
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	79 02                	jns    8004e5 <vprintfmt+0x111>
  8004e3:	f7 d8                	neg    %eax
  8004e5:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e7:	83 f8 09             	cmp    $0x9,%eax
  8004ea:	7f 0b                	jg     8004f7 <vprintfmt+0x123>
  8004ec:	8b 04 85 60 19 80 00 	mov    0x801960(,%eax,4),%eax
  8004f3:	85 c0                	test   %eax,%eax
  8004f5:	75 23                	jne    80051a <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004fb:	c7 44 24 08 53 17 80 	movl   $0x801753,0x8(%esp)
  800502:	00 
  800503:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800507:	8b 45 08             	mov    0x8(%ebp),%eax
  80050a:	89 04 24             	mov    %eax,(%esp)
  80050d:	e8 9a fe ff ff       	call   8003ac <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800512:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800515:	e9 dd fe ff ff       	jmp    8003f7 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80051a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051e:	c7 44 24 08 5c 17 80 	movl   $0x80175c,0x8(%esp)
  800525:	00 
  800526:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052a:	8b 55 08             	mov    0x8(%ebp),%edx
  80052d:	89 14 24             	mov    %edx,(%esp)
  800530:	e8 77 fe ff ff       	call   8003ac <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800535:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800538:	e9 ba fe ff ff       	jmp    8003f7 <vprintfmt+0x23>
  80053d:	89 f9                	mov    %edi,%ecx
  80053f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800542:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 50 04             	lea    0x4(%eax),%edx
  80054b:	89 55 14             	mov    %edx,0x14(%ebp)
  80054e:	8b 30                	mov    (%eax),%esi
  800550:	85 f6                	test   %esi,%esi
  800552:	75 05                	jne    800559 <vprintfmt+0x185>
				p = "(null)";
  800554:	be 4c 17 80 00       	mov    $0x80174c,%esi
			if (width > 0 && padc != '-')
  800559:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80055d:	0f 8e 84 00 00 00    	jle    8005e7 <vprintfmt+0x213>
  800563:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800567:	74 7e                	je     8005e7 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800569:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80056d:	89 34 24             	mov    %esi,(%esp)
  800570:	e8 5d 02 00 00       	call   8007d2 <strnlen>
  800575:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800578:	29 c2                	sub    %eax,%edx
  80057a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80057d:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800581:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800584:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800587:	89 de                	mov    %ebx,%esi
  800589:	89 d3                	mov    %edx,%ebx
  80058b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058d:	eb 0b                	jmp    80059a <vprintfmt+0x1c6>
					putch(padc, putdat);
  80058f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800593:	89 3c 24             	mov    %edi,(%esp)
  800596:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800599:	4b                   	dec    %ebx
  80059a:	85 db                	test   %ebx,%ebx
  80059c:	7f f1                	jg     80058f <vprintfmt+0x1bb>
  80059e:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005a1:	89 f3                	mov    %esi,%ebx
  8005a3:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	79 05                	jns    8005b2 <vprintfmt+0x1de>
  8005ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b5:	29 c2                	sub    %eax,%edx
  8005b7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005ba:	eb 2b                	jmp    8005e7 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005bc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c0:	74 18                	je     8005da <vprintfmt+0x206>
  8005c2:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005c5:	83 fa 5e             	cmp    $0x5e,%edx
  8005c8:	76 10                	jbe    8005da <vprintfmt+0x206>
					putch('?', putdat);
  8005ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ce:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005d5:	ff 55 08             	call   *0x8(%ebp)
  8005d8:	eb 0a                	jmp    8005e4 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005de:	89 04 24             	mov    %eax,(%esp)
  8005e1:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e4:	ff 4d e4             	decl   -0x1c(%ebp)
  8005e7:	0f be 06             	movsbl (%esi),%eax
  8005ea:	46                   	inc    %esi
  8005eb:	85 c0                	test   %eax,%eax
  8005ed:	74 21                	je     800610 <vprintfmt+0x23c>
  8005ef:	85 ff                	test   %edi,%edi
  8005f1:	78 c9                	js     8005bc <vprintfmt+0x1e8>
  8005f3:	4f                   	dec    %edi
  8005f4:	79 c6                	jns    8005bc <vprintfmt+0x1e8>
  8005f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005f9:	89 de                	mov    %ebx,%esi
  8005fb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005fe:	eb 18                	jmp    800618 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800600:	89 74 24 04          	mov    %esi,0x4(%esp)
  800604:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80060b:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060d:	4b                   	dec    %ebx
  80060e:	eb 08                	jmp    800618 <vprintfmt+0x244>
  800610:	8b 7d 08             	mov    0x8(%ebp),%edi
  800613:	89 de                	mov    %ebx,%esi
  800615:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800618:	85 db                	test   %ebx,%ebx
  80061a:	7f e4                	jg     800600 <vprintfmt+0x22c>
  80061c:	89 7d 08             	mov    %edi,0x8(%ebp)
  80061f:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800621:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800624:	e9 ce fd ff ff       	jmp    8003f7 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800629:	8d 45 14             	lea    0x14(%ebp),%eax
  80062c:	e8 2f fd ff ff       	call   800360 <getint>
  800631:	89 c6                	mov    %eax,%esi
  800633:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800635:	85 d2                	test   %edx,%edx
  800637:	78 07                	js     800640 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800639:	be 0a 00 00 00       	mov    $0xa,%esi
  80063e:	eb 7e                	jmp    8006be <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800640:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800644:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80064b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80064e:	89 f0                	mov    %esi,%eax
  800650:	89 fa                	mov    %edi,%edx
  800652:	f7 d8                	neg    %eax
  800654:	83 d2 00             	adc    $0x0,%edx
  800657:	f7 da                	neg    %edx
			}
			base = 10;
  800659:	be 0a 00 00 00       	mov    $0xa,%esi
  80065e:	eb 5e                	jmp    8006be <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800660:	8d 45 14             	lea    0x14(%ebp),%eax
  800663:	e8 be fc ff ff       	call   800326 <getuint>
			base = 10;
  800668:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80066d:	eb 4f                	jmp    8006be <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80066f:	8d 45 14             	lea    0x14(%ebp),%eax
  800672:	e8 af fc ff ff       	call   800326 <getuint>
			base = 8;
  800677:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80067c:	eb 40                	jmp    8006be <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  80067e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800682:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800689:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80068c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800690:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800697:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8d 50 04             	lea    0x4(%eax),%edx
  8006a0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a3:	8b 00                	mov    (%eax),%eax
  8006a5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006aa:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8006af:	eb 0d                	jmp    8006be <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b4:	e8 6d fc ff ff       	call   800326 <getuint>
			base = 16;
  8006b9:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006be:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8006c2:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8006c6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8006cd:	89 74 24 08          	mov    %esi,0x8(%esp)
  8006d1:	89 04 24             	mov    %eax,(%esp)
  8006d4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006d8:	89 da                	mov    %ebx,%edx
  8006da:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dd:	e8 7a fb ff ff       	call   80025c <printnum>
			break;
  8006e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006e5:	e9 0d fd ff ff       	jmp    8003f7 <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  8006ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ed:	e8 6e fc ff ff       	call   800360 <getint>
  8006f2:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  8006fa:	e9 f8 fc ff ff       	jmp    8003f7 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800703:	89 04 24             	mov    %eax,(%esp)
  800706:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800709:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80070c:	e9 e6 fc ff ff       	jmp    8003f7 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800711:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800715:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80071c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071f:	eb 01                	jmp    800722 <vprintfmt+0x34e>
  800721:	4e                   	dec    %esi
  800722:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800726:	75 f9                	jne    800721 <vprintfmt+0x34d>
  800728:	e9 ca fc ff ff       	jmp    8003f7 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80072d:	83 c4 4c             	add    $0x4c,%esp
  800730:	5b                   	pop    %ebx
  800731:	5e                   	pop    %esi
  800732:	5f                   	pop    %edi
  800733:	5d                   	pop    %ebp
  800734:	c3                   	ret    

00800735 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	83 ec 28             	sub    $0x28,%esp
  80073b:	8b 45 08             	mov    0x8(%ebp),%eax
  80073e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800741:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800744:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800748:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800752:	85 c0                	test   %eax,%eax
  800754:	74 30                	je     800786 <vsnprintf+0x51>
  800756:	85 d2                	test   %edx,%edx
  800758:	7e 33                	jle    80078d <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075a:	8b 45 14             	mov    0x14(%ebp),%eax
  80075d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800761:	8b 45 10             	mov    0x10(%ebp),%eax
  800764:	89 44 24 08          	mov    %eax,0x8(%esp)
  800768:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076f:	c7 04 24 92 03 80 00 	movl   $0x800392,(%esp)
  800776:	e8 59 fc ff ff       	call   8003d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80077b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800781:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800784:	eb 0c                	jmp    800792 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800786:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80078b:	eb 05                	jmp    800792 <vsnprintf+0x5d>
  80078d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800792:	c9                   	leave  
  800793:	c3                   	ret    

00800794 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80079d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	89 04 24             	mov    %eax,(%esp)
  8007b5:	e8 7b ff ff ff       	call   800735 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c7:	eb 01                	jmp    8007ca <strlen+0xe>
		n++;
  8007c9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ca:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ce:	75 f9                	jne    8007c9 <strlen+0xd>
		n++;
	return n;
}
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007d8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007db:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e0:	eb 01                	jmp    8007e3 <strnlen+0x11>
		n++;
  8007e2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e3:	39 d0                	cmp    %edx,%eax
  8007e5:	74 06                	je     8007ed <strnlen+0x1b>
  8007e7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007eb:	75 f5                	jne    8007e2 <strnlen+0x10>
		n++;
	return n;
}
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	53                   	push   %ebx
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fe:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800801:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800804:	42                   	inc    %edx
  800805:	84 c9                	test   %cl,%cl
  800807:	75 f5                	jne    8007fe <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800809:	5b                   	pop    %ebx
  80080a:	5d                   	pop    %ebp
  80080b:	c3                   	ret    

0080080c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	53                   	push   %ebx
  800810:	83 ec 08             	sub    $0x8,%esp
  800813:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800816:	89 1c 24             	mov    %ebx,(%esp)
  800819:	e8 9e ff ff ff       	call   8007bc <strlen>
	strcpy(dst + len, src);
  80081e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800821:	89 54 24 04          	mov    %edx,0x4(%esp)
  800825:	01 d8                	add    %ebx,%eax
  800827:	89 04 24             	mov    %eax,(%esp)
  80082a:	e8 c0 ff ff ff       	call   8007ef <strcpy>
	return dst;
}
  80082f:	89 d8                	mov    %ebx,%eax
  800831:	83 c4 08             	add    $0x8,%esp
  800834:	5b                   	pop    %ebx
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	56                   	push   %esi
  80083b:	53                   	push   %ebx
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800842:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800845:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084a:	eb 0c                	jmp    800858 <strncpy+0x21>
		*dst++ = *src;
  80084c:	8a 1a                	mov    (%edx),%bl
  80084e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800851:	80 3a 01             	cmpb   $0x1,(%edx)
  800854:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800857:	41                   	inc    %ecx
  800858:	39 f1                	cmp    %esi,%ecx
  80085a:	75 f0                	jne    80084c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085c:	5b                   	pop    %ebx
  80085d:	5e                   	pop    %esi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	56                   	push   %esi
  800864:	53                   	push   %ebx
  800865:	8b 75 08             	mov    0x8(%ebp),%esi
  800868:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086e:	85 d2                	test   %edx,%edx
  800870:	75 0a                	jne    80087c <strlcpy+0x1c>
  800872:	89 f0                	mov    %esi,%eax
  800874:	eb 1a                	jmp    800890 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800876:	88 18                	mov    %bl,(%eax)
  800878:	40                   	inc    %eax
  800879:	41                   	inc    %ecx
  80087a:	eb 02                	jmp    80087e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80087e:	4a                   	dec    %edx
  80087f:	74 0a                	je     80088b <strlcpy+0x2b>
  800881:	8a 19                	mov    (%ecx),%bl
  800883:	84 db                	test   %bl,%bl
  800885:	75 ef                	jne    800876 <strlcpy+0x16>
  800887:	89 c2                	mov    %eax,%edx
  800889:	eb 02                	jmp    80088d <strlcpy+0x2d>
  80088b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80088d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800890:	29 f0                	sub    %esi,%eax
}
  800892:	5b                   	pop    %ebx
  800893:	5e                   	pop    %esi
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089f:	eb 02                	jmp    8008a3 <strcmp+0xd>
		p++, q++;
  8008a1:	41                   	inc    %ecx
  8008a2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a3:	8a 01                	mov    (%ecx),%al
  8008a5:	84 c0                	test   %al,%al
  8008a7:	74 04                	je     8008ad <strcmp+0x17>
  8008a9:	3a 02                	cmp    (%edx),%al
  8008ab:	74 f4                	je     8008a1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ad:	0f b6 c0             	movzbl %al,%eax
  8008b0:	0f b6 12             	movzbl (%edx),%edx
  8008b3:	29 d0                	sub    %edx,%eax
}
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	53                   	push   %ebx
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008c4:	eb 03                	jmp    8008c9 <strncmp+0x12>
		n--, p++, q++;
  8008c6:	4a                   	dec    %edx
  8008c7:	40                   	inc    %eax
  8008c8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c9:	85 d2                	test   %edx,%edx
  8008cb:	74 14                	je     8008e1 <strncmp+0x2a>
  8008cd:	8a 18                	mov    (%eax),%bl
  8008cf:	84 db                	test   %bl,%bl
  8008d1:	74 04                	je     8008d7 <strncmp+0x20>
  8008d3:	3a 19                	cmp    (%ecx),%bl
  8008d5:	74 ef                	je     8008c6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d7:	0f b6 00             	movzbl (%eax),%eax
  8008da:	0f b6 11             	movzbl (%ecx),%edx
  8008dd:	29 d0                	sub    %edx,%eax
  8008df:	eb 05                	jmp    8008e6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e6:	5b                   	pop    %ebx
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008f2:	eb 05                	jmp    8008f9 <strchr+0x10>
		if (*s == c)
  8008f4:	38 ca                	cmp    %cl,%dl
  8008f6:	74 0c                	je     800904 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f8:	40                   	inc    %eax
  8008f9:	8a 10                	mov    (%eax),%dl
  8008fb:	84 d2                	test   %dl,%dl
  8008fd:	75 f5                	jne    8008f4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80090f:	eb 05                	jmp    800916 <strfind+0x10>
		if (*s == c)
  800911:	38 ca                	cmp    %cl,%dl
  800913:	74 07                	je     80091c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800915:	40                   	inc    %eax
  800916:	8a 10                	mov    (%eax),%dl
  800918:	84 d2                	test   %dl,%dl
  80091a:	75 f5                	jne    800911 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	57                   	push   %edi
  800922:	56                   	push   %esi
  800923:	53                   	push   %ebx
  800924:	8b 7d 08             	mov    0x8(%ebp),%edi
  800927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80092d:	85 c9                	test   %ecx,%ecx
  80092f:	74 30                	je     800961 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800931:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800937:	75 25                	jne    80095e <memset+0x40>
  800939:	f6 c1 03             	test   $0x3,%cl
  80093c:	75 20                	jne    80095e <memset+0x40>
		c &= 0xFF;
  80093e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800941:	89 d3                	mov    %edx,%ebx
  800943:	c1 e3 08             	shl    $0x8,%ebx
  800946:	89 d6                	mov    %edx,%esi
  800948:	c1 e6 18             	shl    $0x18,%esi
  80094b:	89 d0                	mov    %edx,%eax
  80094d:	c1 e0 10             	shl    $0x10,%eax
  800950:	09 f0                	or     %esi,%eax
  800952:	09 d0                	or     %edx,%eax
  800954:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800956:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800959:	fc                   	cld    
  80095a:	f3 ab                	rep stos %eax,%es:(%edi)
  80095c:	eb 03                	jmp    800961 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095e:	fc                   	cld    
  80095f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800961:	89 f8                	mov    %edi,%eax
  800963:	5b                   	pop    %ebx
  800964:	5e                   	pop    %esi
  800965:	5f                   	pop    %edi
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	57                   	push   %edi
  80096c:	56                   	push   %esi
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 75 0c             	mov    0xc(%ebp),%esi
  800973:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800976:	39 c6                	cmp    %eax,%esi
  800978:	73 34                	jae    8009ae <memmove+0x46>
  80097a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097d:	39 d0                	cmp    %edx,%eax
  80097f:	73 2d                	jae    8009ae <memmove+0x46>
		s += n;
		d += n;
  800981:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	f6 c2 03             	test   $0x3,%dl
  800987:	75 1b                	jne    8009a4 <memmove+0x3c>
  800989:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098f:	75 13                	jne    8009a4 <memmove+0x3c>
  800991:	f6 c1 03             	test   $0x3,%cl
  800994:	75 0e                	jne    8009a4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800996:	83 ef 04             	sub    $0x4,%edi
  800999:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80099f:	fd                   	std    
  8009a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a2:	eb 07                	jmp    8009ab <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a4:	4f                   	dec    %edi
  8009a5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a8:	fd                   	std    
  8009a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ab:	fc                   	cld    
  8009ac:	eb 20                	jmp    8009ce <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ae:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b4:	75 13                	jne    8009c9 <memmove+0x61>
  8009b6:	a8 03                	test   $0x3,%al
  8009b8:	75 0f                	jne    8009c9 <memmove+0x61>
  8009ba:	f6 c1 03             	test   $0x3,%cl
  8009bd:	75 0a                	jne    8009c9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009bf:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009c2:	89 c7                	mov    %eax,%edi
  8009c4:	fc                   	cld    
  8009c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c7:	eb 05                	jmp    8009ce <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c9:	89 c7                	mov    %eax,%edi
  8009cb:	fc                   	cld    
  8009cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ce:	5e                   	pop    %esi
  8009cf:	5f                   	pop    %edi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	89 04 24             	mov    %eax,(%esp)
  8009ec:	e8 77 ff ff ff       	call   800968 <memmove>
}
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	57                   	push   %edi
  8009f7:	56                   	push   %esi
  8009f8:	53                   	push   %ebx
  8009f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a02:	ba 00 00 00 00       	mov    $0x0,%edx
  800a07:	eb 16                	jmp    800a1f <memcmp+0x2c>
		if (*s1 != *s2)
  800a09:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a0c:	42                   	inc    %edx
  800a0d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a11:	38 c8                	cmp    %cl,%al
  800a13:	74 0a                	je     800a1f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a15:	0f b6 c0             	movzbl %al,%eax
  800a18:	0f b6 c9             	movzbl %cl,%ecx
  800a1b:	29 c8                	sub    %ecx,%eax
  800a1d:	eb 09                	jmp    800a28 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1f:	39 da                	cmp    %ebx,%edx
  800a21:	75 e6                	jne    800a09 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a28:	5b                   	pop    %ebx
  800a29:	5e                   	pop    %esi
  800a2a:	5f                   	pop    %edi
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a36:	89 c2                	mov    %eax,%edx
  800a38:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a3b:	eb 05                	jmp    800a42 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3d:	38 08                	cmp    %cl,(%eax)
  800a3f:	74 05                	je     800a46 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a41:	40                   	inc    %eax
  800a42:	39 d0                	cmp    %edx,%eax
  800a44:	72 f7                	jb     800a3d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    

00800a48 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	57                   	push   %edi
  800a4c:	56                   	push   %esi
  800a4d:	53                   	push   %ebx
  800a4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a54:	eb 01                	jmp    800a57 <strtol+0xf>
		s++;
  800a56:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a57:	8a 02                	mov    (%edx),%al
  800a59:	3c 20                	cmp    $0x20,%al
  800a5b:	74 f9                	je     800a56 <strtol+0xe>
  800a5d:	3c 09                	cmp    $0x9,%al
  800a5f:	74 f5                	je     800a56 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a61:	3c 2b                	cmp    $0x2b,%al
  800a63:	75 08                	jne    800a6d <strtol+0x25>
		s++;
  800a65:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a66:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6b:	eb 13                	jmp    800a80 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a6d:	3c 2d                	cmp    $0x2d,%al
  800a6f:	75 0a                	jne    800a7b <strtol+0x33>
		s++, neg = 1;
  800a71:	8d 52 01             	lea    0x1(%edx),%edx
  800a74:	bf 01 00 00 00       	mov    $0x1,%edi
  800a79:	eb 05                	jmp    800a80 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a80:	85 db                	test   %ebx,%ebx
  800a82:	74 05                	je     800a89 <strtol+0x41>
  800a84:	83 fb 10             	cmp    $0x10,%ebx
  800a87:	75 28                	jne    800ab1 <strtol+0x69>
  800a89:	8a 02                	mov    (%edx),%al
  800a8b:	3c 30                	cmp    $0x30,%al
  800a8d:	75 10                	jne    800a9f <strtol+0x57>
  800a8f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a93:	75 0a                	jne    800a9f <strtol+0x57>
		s += 2, base = 16;
  800a95:	83 c2 02             	add    $0x2,%edx
  800a98:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a9d:	eb 12                	jmp    800ab1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a9f:	85 db                	test   %ebx,%ebx
  800aa1:	75 0e                	jne    800ab1 <strtol+0x69>
  800aa3:	3c 30                	cmp    $0x30,%al
  800aa5:	75 05                	jne    800aac <strtol+0x64>
		s++, base = 8;
  800aa7:	42                   	inc    %edx
  800aa8:	b3 08                	mov    $0x8,%bl
  800aaa:	eb 05                	jmp    800ab1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800aac:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ab1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab8:	8a 0a                	mov    (%edx),%cl
  800aba:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800abd:	80 fb 09             	cmp    $0x9,%bl
  800ac0:	77 08                	ja     800aca <strtol+0x82>
			dig = *s - '0';
  800ac2:	0f be c9             	movsbl %cl,%ecx
  800ac5:	83 e9 30             	sub    $0x30,%ecx
  800ac8:	eb 1e                	jmp    800ae8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aca:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800acd:	80 fb 19             	cmp    $0x19,%bl
  800ad0:	77 08                	ja     800ada <strtol+0x92>
			dig = *s - 'a' + 10;
  800ad2:	0f be c9             	movsbl %cl,%ecx
  800ad5:	83 e9 57             	sub    $0x57,%ecx
  800ad8:	eb 0e                	jmp    800ae8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ada:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800add:	80 fb 19             	cmp    $0x19,%bl
  800ae0:	77 12                	ja     800af4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ae2:	0f be c9             	movsbl %cl,%ecx
  800ae5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ae8:	39 f1                	cmp    %esi,%ecx
  800aea:	7d 0c                	jge    800af8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800aec:	42                   	inc    %edx
  800aed:	0f af c6             	imul   %esi,%eax
  800af0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800af2:	eb c4                	jmp    800ab8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800af4:	89 c1                	mov    %eax,%ecx
  800af6:	eb 02                	jmp    800afa <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800af8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800afa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afe:	74 05                	je     800b05 <strtol+0xbd>
		*endptr = (char *) s;
  800b00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b03:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b05:	85 ff                	test   %edi,%edi
  800b07:	74 04                	je     800b0d <strtol+0xc5>
  800b09:	89 c8                	mov    %ecx,%eax
  800b0b:	f7 d8                	neg    %eax
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    
	...

00800b14 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b22:	8b 55 08             	mov    0x8(%ebp),%edx
  800b25:	89 c3                	mov    %eax,%ebx
  800b27:	89 c7                	mov    %eax,%edi
  800b29:	89 c6                	mov    %eax,%esi
  800b2b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	57                   	push   %edi
  800b36:	56                   	push   %esi
  800b37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b38:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b42:	89 d1                	mov    %edx,%ecx
  800b44:	89 d3                	mov    %edx,%ebx
  800b46:	89 d7                	mov    %edx,%edi
  800b48:	89 d6                	mov    %edx,%esi
  800b4a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	57                   	push   %edi
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
  800b57:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	89 cb                	mov    %ecx,%ebx
  800b69:	89 cf                	mov    %ecx,%edi
  800b6b:	89 ce                	mov    %ecx,%esi
  800b6d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b6f:	85 c0                	test   %eax,%eax
  800b71:	7e 28                	jle    800b9b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b77:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b7e:	00 
  800b7f:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  800b86:	00 
  800b87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b8e:	00 
  800b8f:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  800b96:	e8 ad f5 ff ff       	call   800148 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b9b:	83 c4 2c             	add    $0x2c,%esp
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bae:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb3:	89 d1                	mov    %edx,%ecx
  800bb5:	89 d3                	mov    %edx,%ebx
  800bb7:	89 d7                	mov    %edx,%edi
  800bb9:	89 d6                	mov    %edx,%esi
  800bbb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_yield>:

void
sys_yield(void)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bd2:	89 d1                	mov    %edx,%ecx
  800bd4:	89 d3                	mov    %edx,%ebx
  800bd6:	89 d7                	mov    %edx,%edi
  800bd8:	89 d6                	mov    %edx,%esi
  800bda:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	be 00 00 00 00       	mov    $0x0,%esi
  800bef:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	89 f7                	mov    %esi,%edi
  800bff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	7e 28                	jle    800c2d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c05:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c09:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c10:	00 
  800c11:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  800c18:	00 
  800c19:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c20:	00 
  800c21:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  800c28:	e8 1b f5 ff ff       	call   800148 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c2d:	83 c4 2c             	add    $0x2c,%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c43:	8b 75 18             	mov    0x18(%ebp),%esi
  800c46:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c54:	85 c0                	test   %eax,%eax
  800c56:	7e 28                	jle    800c80 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c58:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c63:	00 
  800c64:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  800c6b:	00 
  800c6c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c73:	00 
  800c74:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  800c7b:	e8 c8 f4 ff ff       	call   800148 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c80:	83 c4 2c             	add    $0x2c,%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
  800c8e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c96:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	89 df                	mov    %ebx,%edi
  800ca3:	89 de                	mov    %ebx,%esi
  800ca5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7e 28                	jle    800cd3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cab:	89 44 24 10          	mov    %eax,0x10(%esp)
  800caf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cb6:	00 
  800cb7:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  800cbe:	00 
  800cbf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc6:	00 
  800cc7:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  800cce:	e8 75 f4 ff ff       	call   800148 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd3:	83 c4 2c             	add    $0x2c,%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	89 df                	mov    %ebx,%edi
  800cf6:	89 de                	mov    %ebx,%esi
  800cf8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7e 28                	jle    800d26 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d02:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d09:	00 
  800d0a:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  800d11:	00 
  800d12:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d19:	00 
  800d1a:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  800d21:	e8 22 f4 ff ff       	call   800148 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d26:	83 c4 2c             	add    $0x2c,%esp
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	89 df                	mov    %ebx,%edi
  800d49:	89 de                	mov    %ebx,%esi
  800d4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	7e 28                	jle    800d79 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d55:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d5c:	00 
  800d5d:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  800d64:	00 
  800d65:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6c:	00 
  800d6d:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  800d74:	e8 cf f3 ff ff       	call   800148 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d79:	83 c4 2c             	add    $0x2c,%esp
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d87:	be 00 00 00 00       	mov    $0x0,%esi
  800d8c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d91:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d94:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
  800daa:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dad:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dba:	89 cb                	mov    %ecx,%ebx
  800dbc:	89 cf                	mov    %ecx,%edi
  800dbe:	89 ce                	mov    %ecx,%esi
  800dc0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	7e 28                	jle    800dee <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dca:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800dd1:	00 
  800dd2:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  800dd9:	00 
  800dda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de1:	00 
  800de2:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  800de9:	e8 5a f3 ff ff       	call   800148 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dee:	83 c4 2c             	add    $0x2c,%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
  800dfc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e04:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0f:	89 df                	mov    %ebx,%edi
  800e11:	89 de                	mov    %ebx,%esi
  800e13:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e15:	85 c0                	test   %eax,%eax
  800e17:	7e 28                	jle    800e41 <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e19:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e24:	00 
  800e25:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  800e2c:	00 
  800e2d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e34:	00 
  800e35:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  800e3c:	e8 07 f3 ff ff       	call   800148 <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800e41:	83 c4 2c             	add    $0x2c,%esp
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <sys_env_set_debug_upcall>:

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
  800e4f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e57:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e62:	89 df                	mov    %ebx,%edi
  800e64:	89 de                	mov    %ebx,%esi
  800e66:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	7e 28                	jle    800e94 <sys_env_set_debug_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e70:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800e77:	00 
  800e78:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  800e7f:	00 
  800e80:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e87:	00 
  800e88:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  800e8f:	e8 b4 f2 ff ff       	call   800148 <_panic>
}

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_debug_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800e94:	83 c4 2c             	add    $0x2c,%esp
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5f                   	pop    %edi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <sys_env_set_nmskint_upcall>:

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	57                   	push   %edi
  800ea0:	56                   	push   %esi
  800ea1:	53                   	push   %ebx
  800ea2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eaa:	b8 0f 00 00 00       	mov    $0xf,%eax
  800eaf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb5:	89 df                	mov    %ebx,%edi
  800eb7:	89 de                	mov    %ebx,%esi
  800eb9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	7e 28                	jle    800ee7 <sys_env_set_nmskint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec3:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800eca:	00 
  800ecb:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  800ed2:	00 
  800ed3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eda:	00 
  800edb:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  800ee2:	e8 61 f2 ff ff       	call   800148 <_panic>
}

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_nmskint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800ee7:	83 c4 2c             	add    $0x2c,%esp
  800eea:	5b                   	pop    %ebx
  800eeb:	5e                   	pop    %esi
  800eec:	5f                   	pop    %edi
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    

00800eef <sys_env_set_bpoint_upcall>:

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	57                   	push   %edi
  800ef3:	56                   	push   %esi
  800ef4:	53                   	push   %ebx
  800ef5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efd:	b8 10 00 00 00       	mov    $0x10,%eax
  800f02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f05:	8b 55 08             	mov    0x8(%ebp),%edx
  800f08:	89 df                	mov    %ebx,%edi
  800f0a:	89 de                	mov    %ebx,%esi
  800f0c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f0e:	85 c0                	test   %eax,%eax
  800f10:	7e 28                	jle    800f3a <sys_env_set_bpoint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f12:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f16:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800f1d:	00 
  800f1e:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  800f25:	00 
  800f26:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2d:	00 
  800f2e:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  800f35:	e8 0e f2 ff ff       	call   800148 <_panic>
}

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bpoint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800f3a:	83 c4 2c             	add    $0x2c,%esp
  800f3d:	5b                   	pop    %ebx
  800f3e:	5e                   	pop    %esi
  800f3f:	5f                   	pop    %edi
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    

00800f42 <sys_env_set_oflow_upcall>:

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	57                   	push   %edi
  800f46:	56                   	push   %esi
  800f47:	53                   	push   %ebx
  800f48:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f50:	b8 11 00 00 00       	mov    $0x11,%eax
  800f55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f58:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5b:	89 df                	mov    %ebx,%edi
  800f5d:	89 de                	mov    %ebx,%esi
  800f5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f61:	85 c0                	test   %eax,%eax
  800f63:	7e 28                	jle    800f8d <sys_env_set_oflow_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f65:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f69:	c7 44 24 0c 11 00 00 	movl   $0x11,0xc(%esp)
  800f70:	00 
  800f71:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  800f78:	00 
  800f79:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f80:	00 
  800f81:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  800f88:	e8 bb f1 ff ff       	call   800148 <_panic>
}

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_oflow_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800f8d:	83 c4 2c             	add    $0x2c,%esp
  800f90:	5b                   	pop    %ebx
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    

00800f95 <sys_env_set_bdschk_upcall>:

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	57                   	push   %edi
  800f99:	56                   	push   %esi
  800f9a:	53                   	push   %ebx
  800f9b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa3:	b8 12 00 00 00       	mov    $0x12,%eax
  800fa8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fab:	8b 55 08             	mov    0x8(%ebp),%edx
  800fae:	89 df                	mov    %ebx,%edi
  800fb0:	89 de                	mov    %ebx,%esi
  800fb2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	7e 28                	jle    800fe0 <sys_env_set_bdschk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fbc:	c7 44 24 0c 12 00 00 	movl   $0x12,0xc(%esp)
  800fc3:	00 
  800fc4:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  800fcb:	00 
  800fcc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd3:	00 
  800fd4:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  800fdb:	e8 68 f1 ff ff       	call   800148 <_panic>
}

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bdschk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800fe0:	83 c4 2c             	add    $0x2c,%esp
  800fe3:	5b                   	pop    %ebx
  800fe4:	5e                   	pop    %esi
  800fe5:	5f                   	pop    %edi
  800fe6:	5d                   	pop    %ebp
  800fe7:	c3                   	ret    

00800fe8 <sys_env_set_illopcd_upcall>:

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	57                   	push   %edi
  800fec:	56                   	push   %esi
  800fed:	53                   	push   %ebx
  800fee:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff6:	b8 13 00 00 00       	mov    $0x13,%eax
  800ffb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffe:	8b 55 08             	mov    0x8(%ebp),%edx
  801001:	89 df                	mov    %ebx,%edi
  801003:	89 de                	mov    %ebx,%esi
  801005:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801007:	85 c0                	test   %eax,%eax
  801009:	7e 28                	jle    801033 <sys_env_set_illopcd_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80100f:	c7 44 24 0c 13 00 00 	movl   $0x13,0xc(%esp)
  801016:	00 
  801017:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  80101e:	00 
  80101f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801026:	00 
  801027:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  80102e:	e8 15 f1 ff ff       	call   800148 <_panic>
}

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_illopcd_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801033:	83 c4 2c             	add    $0x2c,%esp
  801036:	5b                   	pop    %ebx
  801037:	5e                   	pop    %esi
  801038:	5f                   	pop    %edi
  801039:	5d                   	pop    %ebp
  80103a:	c3                   	ret    

0080103b <sys_env_set_dvcntavl_upcall>:

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	57                   	push   %edi
  80103f:	56                   	push   %esi
  801040:	53                   	push   %ebx
  801041:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801044:	bb 00 00 00 00       	mov    $0x0,%ebx
  801049:	b8 14 00 00 00       	mov    $0x14,%eax
  80104e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801051:	8b 55 08             	mov    0x8(%ebp),%edx
  801054:	89 df                	mov    %ebx,%edi
  801056:	89 de                	mov    %ebx,%esi
  801058:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80105a:	85 c0                	test   %eax,%eax
  80105c:	7e 28                	jle    801086 <sys_env_set_dvcntavl_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80105e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801062:	c7 44 24 0c 14 00 00 	movl   $0x14,0xc(%esp)
  801069:	00 
  80106a:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  801071:	00 
  801072:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801079:	00 
  80107a:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  801081:	e8 c2 f0 ff ff       	call   800148 <_panic>
}

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dvcntavl_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801086:	83 c4 2c             	add    $0x2c,%esp
  801089:	5b                   	pop    %ebx
  80108a:	5e                   	pop    %esi
  80108b:	5f                   	pop    %edi
  80108c:	5d                   	pop    %ebp
  80108d:	c3                   	ret    

0080108e <sys_env_set_dbfault_upcall>:

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
  80108e:	55                   	push   %ebp
  80108f:	89 e5                	mov    %esp,%ebp
  801091:	57                   	push   %edi
  801092:	56                   	push   %esi
  801093:	53                   	push   %ebx
  801094:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801097:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109c:	b8 15 00 00 00       	mov    $0x15,%eax
  8010a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a7:	89 df                	mov    %ebx,%edi
  8010a9:	89 de                	mov    %ebx,%esi
  8010ab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	7e 28                	jle    8010d9 <sys_env_set_dbfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b5:	c7 44 24 0c 15 00 00 	movl   $0x15,0xc(%esp)
  8010bc:	00 
  8010bd:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  8010c4:	00 
  8010c5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010cc:	00 
  8010cd:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  8010d4:	e8 6f f0 ff ff       	call   800148 <_panic>
}

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dbfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8010d9:	83 c4 2c             	add    $0x2c,%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5e                   	pop    %esi
  8010de:	5f                   	pop    %edi
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <sys_env_set_ivldtss_upcall>:

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	57                   	push   %edi
  8010e5:	56                   	push   %esi
  8010e6:	53                   	push   %ebx
  8010e7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ef:	b8 16 00 00 00       	mov    $0x16,%eax
  8010f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fa:	89 df                	mov    %ebx,%edi
  8010fc:	89 de                	mov    %ebx,%esi
  8010fe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801100:	85 c0                	test   %eax,%eax
  801102:	7e 28                	jle    80112c <sys_env_set_ivldtss_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801104:	89 44 24 10          	mov    %eax,0x10(%esp)
  801108:	c7 44 24 0c 16 00 00 	movl   $0x16,0xc(%esp)
  80110f:	00 
  801110:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  801117:	00 
  801118:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80111f:	00 
  801120:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  801127:	e8 1c f0 ff ff       	call   800148 <_panic>
}

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_ivldtss_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80112c:	83 c4 2c             	add    $0x2c,%esp
  80112f:	5b                   	pop    %ebx
  801130:	5e                   	pop    %esi
  801131:	5f                   	pop    %edi
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    

00801134 <sys_env_set_segntprst_upcall>:

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	57                   	push   %edi
  801138:	56                   	push   %esi
  801139:	53                   	push   %ebx
  80113a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801142:	b8 17 00 00 00       	mov    $0x17,%eax
  801147:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114a:	8b 55 08             	mov    0x8(%ebp),%edx
  80114d:	89 df                	mov    %ebx,%edi
  80114f:	89 de                	mov    %ebx,%esi
  801151:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801153:	85 c0                	test   %eax,%eax
  801155:	7e 28                	jle    80117f <sys_env_set_segntprst_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801157:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115b:	c7 44 24 0c 17 00 00 	movl   $0x17,0xc(%esp)
  801162:	00 
  801163:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  80116a:	00 
  80116b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801172:	00 
  801173:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  80117a:	e8 c9 ef ff ff       	call   800148 <_panic>
}

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_segntprst_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80117f:	83 c4 2c             	add    $0x2c,%esp
  801182:	5b                   	pop    %ebx
  801183:	5e                   	pop    %esi
  801184:	5f                   	pop    %edi
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <sys_env_set_stkexception_upcall>:

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	57                   	push   %edi
  80118b:	56                   	push   %esi
  80118c:	53                   	push   %ebx
  80118d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801190:	bb 00 00 00 00       	mov    $0x0,%ebx
  801195:	b8 18 00 00 00       	mov    $0x18,%eax
  80119a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119d:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a0:	89 df                	mov    %ebx,%edi
  8011a2:	89 de                	mov    %ebx,%esi
  8011a4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	7e 28                	jle    8011d2 <sys_env_set_stkexception_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ae:	c7 44 24 0c 18 00 00 	movl   $0x18,0xc(%esp)
  8011b5:	00 
  8011b6:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  8011bd:	00 
  8011be:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c5:	00 
  8011c6:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  8011cd:	e8 76 ef ff ff       	call   800148 <_panic>
}

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_stkexception_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8011d2:	83 c4 2c             	add    $0x2c,%esp
  8011d5:	5b                   	pop    %ebx
  8011d6:	5e                   	pop    %esi
  8011d7:	5f                   	pop    %edi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <sys_env_set_gpfault_upcall>:

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	57                   	push   %edi
  8011de:	56                   	push   %esi
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e8:	b8 19 00 00 00       	mov    $0x19,%eax
  8011ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f3:	89 df                	mov    %ebx,%edi
  8011f5:	89 de                	mov    %ebx,%esi
  8011f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	7e 28                	jle    801225 <sys_env_set_gpfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801201:	c7 44 24 0c 19 00 00 	movl   $0x19,0xc(%esp)
  801208:	00 
  801209:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  801210:	00 
  801211:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801218:	00 
  801219:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  801220:	e8 23 ef ff ff       	call   800148 <_panic>
}

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_gpfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801225:	83 c4 2c             	add    $0x2c,%esp
  801228:	5b                   	pop    %ebx
  801229:	5e                   	pop    %esi
  80122a:	5f                   	pop    %edi
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <sys_env_set_fperror_upcall>:

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	57                   	push   %edi
  801231:	56                   	push   %esi
  801232:	53                   	push   %ebx
  801233:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80123b:	b8 1a 00 00 00       	mov    $0x1a,%eax
  801240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801243:	8b 55 08             	mov    0x8(%ebp),%edx
  801246:	89 df                	mov    %ebx,%edi
  801248:	89 de                	mov    %ebx,%esi
  80124a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80124c:	85 c0                	test   %eax,%eax
  80124e:	7e 28                	jle    801278 <sys_env_set_fperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801250:	89 44 24 10          	mov    %eax,0x10(%esp)
  801254:	c7 44 24 0c 1a 00 00 	movl   $0x1a,0xc(%esp)
  80125b:	00 
  80125c:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  801263:	00 
  801264:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80126b:	00 
  80126c:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  801273:	e8 d0 ee ff ff       	call   800148 <_panic>
}

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_fperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801278:	83 c4 2c             	add    $0x2c,%esp
  80127b:	5b                   	pop    %ebx
  80127c:	5e                   	pop    %esi
  80127d:	5f                   	pop    %edi
  80127e:	5d                   	pop    %ebp
  80127f:	c3                   	ret    

00801280 <sys_env_set_algchk_upcall>:

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	57                   	push   %edi
  801284:	56                   	push   %esi
  801285:	53                   	push   %ebx
  801286:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801289:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128e:	b8 1b 00 00 00       	mov    $0x1b,%eax
  801293:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801296:	8b 55 08             	mov    0x8(%ebp),%edx
  801299:	89 df                	mov    %ebx,%edi
  80129b:	89 de                	mov    %ebx,%esi
  80129d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	7e 28                	jle    8012cb <sys_env_set_algchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012a7:	c7 44 24 0c 1b 00 00 	movl   $0x1b,0xc(%esp)
  8012ae:	00 
  8012af:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  8012b6:	00 
  8012b7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012be:	00 
  8012bf:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  8012c6:	e8 7d ee ff ff       	call   800148 <_panic>
}

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_algchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8012cb:	83 c4 2c             	add    $0x2c,%esp
  8012ce:	5b                   	pop    %ebx
  8012cf:	5e                   	pop    %esi
  8012d0:	5f                   	pop    %edi
  8012d1:	5d                   	pop    %ebp
  8012d2:	c3                   	ret    

008012d3 <sys_env_set_mchchk_upcall>:

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	57                   	push   %edi
  8012d7:	56                   	push   %esi
  8012d8:	53                   	push   %ebx
  8012d9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e1:	b8 1c 00 00 00       	mov    $0x1c,%eax
  8012e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ec:	89 df                	mov    %ebx,%edi
  8012ee:	89 de                	mov    %ebx,%esi
  8012f0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	7e 28                	jle    80131e <sys_env_set_mchchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012fa:	c7 44 24 0c 1c 00 00 	movl   $0x1c,0xc(%esp)
  801301:	00 
  801302:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  801309:	00 
  80130a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801311:	00 
  801312:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  801319:	e8 2a ee ff ff       	call   800148 <_panic>
}

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_mchchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80131e:	83 c4 2c             	add    $0x2c,%esp
  801321:	5b                   	pop    %ebx
  801322:	5e                   	pop    %esi
  801323:	5f                   	pop    %edi
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    

00801326 <sys_env_set_SIMDfperror_upcall>:

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	57                   	push   %edi
  80132a:	56                   	push   %esi
  80132b:	53                   	push   %ebx
  80132c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80132f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801334:	b8 1d 00 00 00       	mov    $0x1d,%eax
  801339:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133c:	8b 55 08             	mov    0x8(%ebp),%edx
  80133f:	89 df                	mov    %ebx,%edi
  801341:	89 de                	mov    %ebx,%esi
  801343:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801345:	85 c0                	test   %eax,%eax
  801347:	7e 28                	jle    801371 <sys_env_set_SIMDfperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801349:	89 44 24 10          	mov    %eax,0x10(%esp)
  80134d:	c7 44 24 0c 1d 00 00 	movl   $0x1d,0xc(%esp)
  801354:	00 
  801355:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  80135c:	00 
  80135d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801364:	00 
  801365:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  80136c:	e8 d7 ed ff ff       	call   800148 <_panic>
}

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_SIMDfperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801371:	83 c4 2c             	add    $0x2c,%esp
  801374:	5b                   	pop    %ebx
  801375:	5e                   	pop    %esi
  801376:	5f                   	pop    %edi
  801377:	5d                   	pop    %ebp
  801378:	c3                   	ret    
  801379:	00 00                	add    %al,(%eax)
	...

0080137c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801382:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801389:	75 40                	jne    8013cb <set_pgfault_handler+0x4f>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
  80138b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801392:	00 
  801393:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80139a:	ee 
  80139b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013a2:	e8 3a f8 ff ff       	call   800be1 <sys_page_alloc>
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	79 20                	jns    8013cb <set_pgfault_handler+0x4f>
            panic("set_pgfault_handler: sys_page_alloc: %e", r);
  8013ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013af:	c7 44 24 08 b4 19 80 	movl   $0x8019b4,0x8(%esp)
  8013b6:	00 
  8013b7:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8013be:	00 
  8013bf:	c7 04 24 10 1a 80 00 	movl   $0x801a10,(%esp)
  8013c6:	e8 7d ed ff ff       	call   800148 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8013cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ce:	a3 0c 20 80 00       	mov    %eax,0x80200c
    if ((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0 )
  8013d3:	c7 44 24 04 10 14 80 	movl   $0x801410,0x4(%esp)
  8013da:	00 
  8013db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013e2:	e8 47 f9 ff ff       	call   800d2e <sys_env_set_pgfault_upcall>
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	79 20                	jns    80140b <set_pgfault_handler+0x8f>
        panic("set_pgfault_handler: sys_env_set_pgfault_upcall: %e", r);
  8013eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013ef:	c7 44 24 08 dc 19 80 	movl   $0x8019dc,0x8(%esp)
  8013f6:	00 
  8013f7:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8013fe:	00 
  8013ff:	c7 04 24 10 1a 80 00 	movl   $0x801a10,(%esp)
  801406:	e8 3d ed ff ff       	call   800148 <_panic>
}
  80140b:	c9                   	leave  
  80140c:	c3                   	ret    
  80140d:	00 00                	add    %al,(%eax)
	...

00801410 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801410:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801411:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801416:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801418:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// sub 4 from old esp
	movl 0x30(%esp), %eax
  80141b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80141f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801422:	89 44 24 30          	mov    %eax,0x30(%esp)
	// put old eip into the pre-reserved 4-byte space
	movl 0x28(%esp), %ebx
  801426:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80142a:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  80142c:	83 c4 08             	add    $0x8,%esp
	popal
  80142f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  801430:	83 c4 04             	add    $0x4,%esp
	popfl
  801433:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801434:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801435:	c3                   	ret    
	...

00801438 <__udivdi3>:
  801438:	55                   	push   %ebp
  801439:	57                   	push   %edi
  80143a:	56                   	push   %esi
  80143b:	83 ec 10             	sub    $0x10,%esp
  80143e:	8b 74 24 20          	mov    0x20(%esp),%esi
  801442:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801446:	89 74 24 04          	mov    %esi,0x4(%esp)
  80144a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80144e:	89 cd                	mov    %ecx,%ebp
  801450:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801454:	85 c0                	test   %eax,%eax
  801456:	75 2c                	jne    801484 <__udivdi3+0x4c>
  801458:	39 f9                	cmp    %edi,%ecx
  80145a:	77 68                	ja     8014c4 <__udivdi3+0x8c>
  80145c:	85 c9                	test   %ecx,%ecx
  80145e:	75 0b                	jne    80146b <__udivdi3+0x33>
  801460:	b8 01 00 00 00       	mov    $0x1,%eax
  801465:	31 d2                	xor    %edx,%edx
  801467:	f7 f1                	div    %ecx
  801469:	89 c1                	mov    %eax,%ecx
  80146b:	31 d2                	xor    %edx,%edx
  80146d:	89 f8                	mov    %edi,%eax
  80146f:	f7 f1                	div    %ecx
  801471:	89 c7                	mov    %eax,%edi
  801473:	89 f0                	mov    %esi,%eax
  801475:	f7 f1                	div    %ecx
  801477:	89 c6                	mov    %eax,%esi
  801479:	89 f0                	mov    %esi,%eax
  80147b:	89 fa                	mov    %edi,%edx
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	5e                   	pop    %esi
  801481:	5f                   	pop    %edi
  801482:	5d                   	pop    %ebp
  801483:	c3                   	ret    
  801484:	39 f8                	cmp    %edi,%eax
  801486:	77 2c                	ja     8014b4 <__udivdi3+0x7c>
  801488:	0f bd f0             	bsr    %eax,%esi
  80148b:	83 f6 1f             	xor    $0x1f,%esi
  80148e:	75 4c                	jne    8014dc <__udivdi3+0xa4>
  801490:	39 f8                	cmp    %edi,%eax
  801492:	bf 00 00 00 00       	mov    $0x0,%edi
  801497:	72 0a                	jb     8014a3 <__udivdi3+0x6b>
  801499:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80149d:	0f 87 ad 00 00 00    	ja     801550 <__udivdi3+0x118>
  8014a3:	be 01 00 00 00       	mov    $0x1,%esi
  8014a8:	89 f0                	mov    %esi,%eax
  8014aa:	89 fa                	mov    %edi,%edx
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	5e                   	pop    %esi
  8014b0:	5f                   	pop    %edi
  8014b1:	5d                   	pop    %ebp
  8014b2:	c3                   	ret    
  8014b3:	90                   	nop
  8014b4:	31 ff                	xor    %edi,%edi
  8014b6:	31 f6                	xor    %esi,%esi
  8014b8:	89 f0                	mov    %esi,%eax
  8014ba:	89 fa                	mov    %edi,%edx
  8014bc:	83 c4 10             	add    $0x10,%esp
  8014bf:	5e                   	pop    %esi
  8014c0:	5f                   	pop    %edi
  8014c1:	5d                   	pop    %ebp
  8014c2:	c3                   	ret    
  8014c3:	90                   	nop
  8014c4:	89 fa                	mov    %edi,%edx
  8014c6:	89 f0                	mov    %esi,%eax
  8014c8:	f7 f1                	div    %ecx
  8014ca:	89 c6                	mov    %eax,%esi
  8014cc:	31 ff                	xor    %edi,%edi
  8014ce:	89 f0                	mov    %esi,%eax
  8014d0:	89 fa                	mov    %edi,%edx
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	5e                   	pop    %esi
  8014d6:	5f                   	pop    %edi
  8014d7:	5d                   	pop    %ebp
  8014d8:	c3                   	ret    
  8014d9:	8d 76 00             	lea    0x0(%esi),%esi
  8014dc:	89 f1                	mov    %esi,%ecx
  8014de:	d3 e0                	shl    %cl,%eax
  8014e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014e4:	b8 20 00 00 00       	mov    $0x20,%eax
  8014e9:	29 f0                	sub    %esi,%eax
  8014eb:	89 ea                	mov    %ebp,%edx
  8014ed:	88 c1                	mov    %al,%cl
  8014ef:	d3 ea                	shr    %cl,%edx
  8014f1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8014f5:	09 ca                	or     %ecx,%edx
  8014f7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8014fb:	89 f1                	mov    %esi,%ecx
  8014fd:	d3 e5                	shl    %cl,%ebp
  8014ff:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801503:	89 fd                	mov    %edi,%ebp
  801505:	88 c1                	mov    %al,%cl
  801507:	d3 ed                	shr    %cl,%ebp
  801509:	89 fa                	mov    %edi,%edx
  80150b:	89 f1                	mov    %esi,%ecx
  80150d:	d3 e2                	shl    %cl,%edx
  80150f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801513:	88 c1                	mov    %al,%cl
  801515:	d3 ef                	shr    %cl,%edi
  801517:	09 d7                	or     %edx,%edi
  801519:	89 f8                	mov    %edi,%eax
  80151b:	89 ea                	mov    %ebp,%edx
  80151d:	f7 74 24 08          	divl   0x8(%esp)
  801521:	89 d1                	mov    %edx,%ecx
  801523:	89 c7                	mov    %eax,%edi
  801525:	f7 64 24 0c          	mull   0xc(%esp)
  801529:	39 d1                	cmp    %edx,%ecx
  80152b:	72 17                	jb     801544 <__udivdi3+0x10c>
  80152d:	74 09                	je     801538 <__udivdi3+0x100>
  80152f:	89 fe                	mov    %edi,%esi
  801531:	31 ff                	xor    %edi,%edi
  801533:	e9 41 ff ff ff       	jmp    801479 <__udivdi3+0x41>
  801538:	8b 54 24 04          	mov    0x4(%esp),%edx
  80153c:	89 f1                	mov    %esi,%ecx
  80153e:	d3 e2                	shl    %cl,%edx
  801540:	39 c2                	cmp    %eax,%edx
  801542:	73 eb                	jae    80152f <__udivdi3+0xf7>
  801544:	8d 77 ff             	lea    -0x1(%edi),%esi
  801547:	31 ff                	xor    %edi,%edi
  801549:	e9 2b ff ff ff       	jmp    801479 <__udivdi3+0x41>
  80154e:	66 90                	xchg   %ax,%ax
  801550:	31 f6                	xor    %esi,%esi
  801552:	e9 22 ff ff ff       	jmp    801479 <__udivdi3+0x41>
	...

00801558 <__umoddi3>:
  801558:	55                   	push   %ebp
  801559:	57                   	push   %edi
  80155a:	56                   	push   %esi
  80155b:	83 ec 20             	sub    $0x20,%esp
  80155e:	8b 44 24 30          	mov    0x30(%esp),%eax
  801562:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801566:	89 44 24 14          	mov    %eax,0x14(%esp)
  80156a:	8b 74 24 34          	mov    0x34(%esp),%esi
  80156e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801572:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801576:	89 c7                	mov    %eax,%edi
  801578:	89 f2                	mov    %esi,%edx
  80157a:	85 ed                	test   %ebp,%ebp
  80157c:	75 16                	jne    801594 <__umoddi3+0x3c>
  80157e:	39 f1                	cmp    %esi,%ecx
  801580:	0f 86 a6 00 00 00    	jbe    80162c <__umoddi3+0xd4>
  801586:	f7 f1                	div    %ecx
  801588:	89 d0                	mov    %edx,%eax
  80158a:	31 d2                	xor    %edx,%edx
  80158c:	83 c4 20             	add    $0x20,%esp
  80158f:	5e                   	pop    %esi
  801590:	5f                   	pop    %edi
  801591:	5d                   	pop    %ebp
  801592:	c3                   	ret    
  801593:	90                   	nop
  801594:	39 f5                	cmp    %esi,%ebp
  801596:	0f 87 ac 00 00 00    	ja     801648 <__umoddi3+0xf0>
  80159c:	0f bd c5             	bsr    %ebp,%eax
  80159f:	83 f0 1f             	xor    $0x1f,%eax
  8015a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015a6:	0f 84 a8 00 00 00    	je     801654 <__umoddi3+0xfc>
  8015ac:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015b0:	d3 e5                	shl    %cl,%ebp
  8015b2:	bf 20 00 00 00       	mov    $0x20,%edi
  8015b7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8015bb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015bf:	89 f9                	mov    %edi,%ecx
  8015c1:	d3 e8                	shr    %cl,%eax
  8015c3:	09 e8                	or     %ebp,%eax
  8015c5:	89 44 24 18          	mov    %eax,0x18(%esp)
  8015c9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015cd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015d1:	d3 e0                	shl    %cl,%eax
  8015d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015d7:	89 f2                	mov    %esi,%edx
  8015d9:	d3 e2                	shl    %cl,%edx
  8015db:	8b 44 24 14          	mov    0x14(%esp),%eax
  8015df:	d3 e0                	shl    %cl,%eax
  8015e1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8015e5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8015e9:	89 f9                	mov    %edi,%ecx
  8015eb:	d3 e8                	shr    %cl,%eax
  8015ed:	09 d0                	or     %edx,%eax
  8015ef:	d3 ee                	shr    %cl,%esi
  8015f1:	89 f2                	mov    %esi,%edx
  8015f3:	f7 74 24 18          	divl   0x18(%esp)
  8015f7:	89 d6                	mov    %edx,%esi
  8015f9:	f7 64 24 0c          	mull   0xc(%esp)
  8015fd:	89 c5                	mov    %eax,%ebp
  8015ff:	89 d1                	mov    %edx,%ecx
  801601:	39 d6                	cmp    %edx,%esi
  801603:	72 67                	jb     80166c <__umoddi3+0x114>
  801605:	74 75                	je     80167c <__umoddi3+0x124>
  801607:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80160b:	29 e8                	sub    %ebp,%eax
  80160d:	19 ce                	sbb    %ecx,%esi
  80160f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801613:	d3 e8                	shr    %cl,%eax
  801615:	89 f2                	mov    %esi,%edx
  801617:	89 f9                	mov    %edi,%ecx
  801619:	d3 e2                	shl    %cl,%edx
  80161b:	09 d0                	or     %edx,%eax
  80161d:	89 f2                	mov    %esi,%edx
  80161f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801623:	d3 ea                	shr    %cl,%edx
  801625:	83 c4 20             	add    $0x20,%esp
  801628:	5e                   	pop    %esi
  801629:	5f                   	pop    %edi
  80162a:	5d                   	pop    %ebp
  80162b:	c3                   	ret    
  80162c:	85 c9                	test   %ecx,%ecx
  80162e:	75 0b                	jne    80163b <__umoddi3+0xe3>
  801630:	b8 01 00 00 00       	mov    $0x1,%eax
  801635:	31 d2                	xor    %edx,%edx
  801637:	f7 f1                	div    %ecx
  801639:	89 c1                	mov    %eax,%ecx
  80163b:	89 f0                	mov    %esi,%eax
  80163d:	31 d2                	xor    %edx,%edx
  80163f:	f7 f1                	div    %ecx
  801641:	89 f8                	mov    %edi,%eax
  801643:	e9 3e ff ff ff       	jmp    801586 <__umoddi3+0x2e>
  801648:	89 f2                	mov    %esi,%edx
  80164a:	83 c4 20             	add    $0x20,%esp
  80164d:	5e                   	pop    %esi
  80164e:	5f                   	pop    %edi
  80164f:	5d                   	pop    %ebp
  801650:	c3                   	ret    
  801651:	8d 76 00             	lea    0x0(%esi),%esi
  801654:	39 f5                	cmp    %esi,%ebp
  801656:	72 04                	jb     80165c <__umoddi3+0x104>
  801658:	39 f9                	cmp    %edi,%ecx
  80165a:	77 06                	ja     801662 <__umoddi3+0x10a>
  80165c:	89 f2                	mov    %esi,%edx
  80165e:	29 cf                	sub    %ecx,%edi
  801660:	19 ea                	sbb    %ebp,%edx
  801662:	89 f8                	mov    %edi,%eax
  801664:	83 c4 20             	add    $0x20,%esp
  801667:	5e                   	pop    %esi
  801668:	5f                   	pop    %edi
  801669:	5d                   	pop    %ebp
  80166a:	c3                   	ret    
  80166b:	90                   	nop
  80166c:	89 d1                	mov    %edx,%ecx
  80166e:	89 c5                	mov    %eax,%ebp
  801670:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801674:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801678:	eb 8d                	jmp    801607 <__umoddi3+0xaf>
  80167a:	66 90                	xchg   %ax,%ax
  80167c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801680:	72 ea                	jb     80166c <__umoddi3+0x114>
  801682:	89 f1                	mov    %esi,%ecx
  801684:	eb 81                	jmp    801607 <__umoddi3+0xaf>
