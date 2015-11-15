
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 17 01 00 00       	call   800148 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 4c             	sub    $0x4c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003d:	e8 f8 10 00 00       	call   80113a <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 0c 20 80 00    	mov    0x80200c,%ebx
  80004f:	e8 5b 0b 00 00       	call   800baf <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 00 16 80 00 	movl   $0x801600,(%esp)
  800063:	e8 e4 01 00 00       	call   80024c <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 3f 0b 00 00       	call   800baf <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 1a 16 80 00 	movl   $0x80161a,(%esp)
  80007f:	e8 c8 01 00 00       	call   80024c <cprintf>
		ipc_send(who, 0, 0, 0);
  800084:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008b:	00 
  80008c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 1c 11 00 00       	call   8011c3 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 9a 10 00 00       	call   80115c <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 0c 20 80 00    	mov    0x80200c,%ebx
  8000c8:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ce:	8b 15 08 20 80 00    	mov    0x802008,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 d3 0a 00 00       	call   800baf <sys_getenvid>
  8000dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 30 16 80 00 	movl   $0x801630,(%esp)
  8000fa:	e8 4d 01 00 00       	call   80024c <cprintf>
		if (val == 10)
  8000ff:	a1 08 20 80 00       	mov    0x802008,%eax
  800104:	83 f8 0a             	cmp    $0xa,%eax
  800107:	74 36                	je     80013f <umain+0x10b>
			return;
		++val;
  800109:	40                   	inc    %eax
  80010a:	a3 08 20 80 00       	mov    %eax,0x802008
		ipc_send(who, 0, 0, 0);
  80010f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800116:	00 
  800117:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800126:	00 
  800127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 91 10 00 00       	call   8011c3 <ipc_send>
		if (val == 10)
  800132:	83 3d 08 20 80 00 0a 	cmpl   $0xa,0x802008
  800139:	0f 85 68 ff ff ff    	jne    8000a7 <umain+0x73>
			return;
	}

}
  80013f:	83 c4 4c             	add    $0x4c,%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    
	...

00800148 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 10             	sub    $0x10,%esp
  800150:	8b 75 08             	mov    0x8(%ebp),%esi
  800153:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800156:	e8 54 0a 00 00       	call   800baf <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	8d 14 80             	lea    (%eax,%eax,4),%edx
  800163:	8d 04 50             	lea    (%eax,%edx,2),%eax
  800166:	c1 e0 04             	shl    $0x4,%eax
  800169:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80016e:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800173:	85 f6                	test   %esi,%esi
  800175:	7e 07                	jle    80017e <libmain+0x36>
		binaryname = argv[0];
  800177:	8b 03                	mov    (%ebx),%eax
  800179:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80017e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800182:	89 34 24             	mov    %esi,(%esp)
  800185:	e8 aa fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80018a:	e8 09 00 00 00       	call   800198 <exit>
}
  80018f:	83 c4 10             	add    $0x10,%esp
  800192:	5b                   	pop    %ebx
  800193:	5e                   	pop    %esi
  800194:	5d                   	pop    %ebp
  800195:	c3                   	ret    
	...

00800198 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80019e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a5:	e8 b3 09 00 00       	call   800b5d <sys_env_destroy>
}
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 14             	sub    $0x14,%esp
  8001b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b6:	8b 03                	mov    (%ebx),%eax
  8001b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001bf:	40                   	inc    %eax
  8001c0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c7:	75 19                	jne    8001e2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001c9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d0:	00 
  8001d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d4:	89 04 24             	mov    %eax,(%esp)
  8001d7:	e8 44 09 00 00       	call   800b20 <sys_cputs>
		b->idx = 0;
  8001dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e2:	ff 43 04             	incl   0x4(%ebx)
}
  8001e5:	83 c4 14             	add    $0x14,%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fb:	00 00 00 
	b.cnt = 0;
  8001fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800205:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800208:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	89 44 24 08          	mov    %eax,0x8(%esp)
  800216:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800220:	c7 04 24 ac 01 80 00 	movl   $0x8001ac,(%esp)
  800227:	e8 b4 01 00 00       	call   8003e0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800232:	89 44 24 04          	mov    %eax,0x4(%esp)
  800236:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023c:	89 04 24             	mov    %eax,(%esp)
  80023f:	e8 dc 08 00 00       	call   800b20 <sys_cputs>

	return b.cnt;
}
  800244:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800252:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800255:	89 44 24 04          	mov    %eax,0x4(%esp)
  800259:	8b 45 08             	mov    0x8(%ebp),%eax
  80025c:	89 04 24             	mov    %eax,(%esp)
  80025f:	e8 87 ff ff ff       	call   8001eb <vcprintf>
	va_end(ap);

	return cnt;
}
  800264:	c9                   	leave  
  800265:	c3                   	ret    
	...

00800268 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	57                   	push   %edi
  80026c:	56                   	push   %esi
  80026d:	53                   	push   %ebx
  80026e:	83 ec 3c             	sub    $0x3c,%esp
  800271:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800274:	89 d7                	mov    %edx,%edi
  800276:	8b 45 08             	mov    0x8(%ebp),%eax
  800279:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80027c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800282:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800285:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800288:	85 c0                	test   %eax,%eax
  80028a:	75 08                	jne    800294 <printnum+0x2c>
  80028c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80028f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800292:	77 57                	ja     8002eb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800294:	89 74 24 10          	mov    %esi,0x10(%esp)
  800298:	4b                   	dec    %ebx
  800299:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80029d:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002a8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b3:	00 
  8002b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002b7:	89 04 24             	mov    %eax,(%esp)
  8002ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c1:	e8 e2 10 00 00       	call   8013a8 <__udivdi3>
  8002c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ce:	89 04 24             	mov    %eax,(%esp)
  8002d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d5:	89 fa                	mov    %edi,%edx
  8002d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002da:	e8 89 ff ff ff       	call   800268 <printnum>
  8002df:	eb 0f                	jmp    8002f0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e5:	89 34 24             	mov    %esi,(%esp)
  8002e8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002eb:	4b                   	dec    %ebx
  8002ec:	85 db                	test   %ebx,%ebx
  8002ee:	7f f1                	jg     8002e1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800306:	00 
  800307:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030a:	89 04 24             	mov    %eax,(%esp)
  80030d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800310:	89 44 24 04          	mov    %eax,0x4(%esp)
  800314:	e8 af 11 00 00       	call   8014c8 <__umoddi3>
  800319:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031d:	0f be 80 60 16 80 00 	movsbl 0x801660(%eax),%eax
  800324:	89 04 24             	mov    %eax,(%esp)
  800327:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80032a:	83 c4 3c             	add    $0x3c,%esp
  80032d:	5b                   	pop    %ebx
  80032e:	5e                   	pop    %esi
  80032f:	5f                   	pop    %edi
  800330:	5d                   	pop    %ebp
  800331:	c3                   	ret    

00800332 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800335:	83 fa 01             	cmp    $0x1,%edx
  800338:	7e 0e                	jle    800348 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80033a:	8b 10                	mov    (%eax),%edx
  80033c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033f:	89 08                	mov    %ecx,(%eax)
  800341:	8b 02                	mov    (%edx),%eax
  800343:	8b 52 04             	mov    0x4(%edx),%edx
  800346:	eb 22                	jmp    80036a <getuint+0x38>
	else if (lflag)
  800348:	85 d2                	test   %edx,%edx
  80034a:	74 10                	je     80035c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80034c:	8b 10                	mov    (%eax),%edx
  80034e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800351:	89 08                	mov    %ecx,(%eax)
  800353:	8b 02                	mov    (%edx),%eax
  800355:	ba 00 00 00 00       	mov    $0x0,%edx
  80035a:	eb 0e                	jmp    80036a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80035c:	8b 10                	mov    (%eax),%edx
  80035e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800361:	89 08                	mov    %ecx,(%eax)
  800363:	8b 02                	mov    (%edx),%eax
  800365:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80036f:	83 fa 01             	cmp    $0x1,%edx
  800372:	7e 0e                	jle    800382 <getint+0x16>
		return va_arg(*ap, long long);
  800374:	8b 10                	mov    (%eax),%edx
  800376:	8d 4a 08             	lea    0x8(%edx),%ecx
  800379:	89 08                	mov    %ecx,(%eax)
  80037b:	8b 02                	mov    (%edx),%eax
  80037d:	8b 52 04             	mov    0x4(%edx),%edx
  800380:	eb 1a                	jmp    80039c <getint+0x30>
	else if (lflag)
  800382:	85 d2                	test   %edx,%edx
  800384:	74 0c                	je     800392 <getint+0x26>
		return va_arg(*ap, long);
  800386:	8b 10                	mov    (%eax),%edx
  800388:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038b:	89 08                	mov    %ecx,(%eax)
  80038d:	8b 02                	mov    (%edx),%eax
  80038f:	99                   	cltd   
  800390:	eb 0a                	jmp    80039c <getint+0x30>
	else
		return va_arg(*ap, int);
  800392:	8b 10                	mov    (%eax),%edx
  800394:	8d 4a 04             	lea    0x4(%edx),%ecx
  800397:	89 08                	mov    %ecx,(%eax)
  800399:	8b 02                	mov    (%edx),%eax
  80039b:	99                   	cltd   
}
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003a4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003a7:	8b 10                	mov    (%eax),%edx
  8003a9:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ac:	73 08                	jae    8003b6 <sprintputch+0x18>
		*b->buf++ = ch;
  8003ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b1:	88 0a                	mov    %cl,(%edx)
  8003b3:	42                   	inc    %edx
  8003b4:	89 10                	mov    %edx,(%eax)
}
  8003b6:	5d                   	pop    %ebp
  8003b7:	c3                   	ret    

008003b8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003be:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d6:	89 04 24             	mov    %eax,(%esp)
  8003d9:	e8 02 00 00 00       	call   8003e0 <vprintfmt>
	va_end(ap);
}
  8003de:	c9                   	leave  
  8003df:	c3                   	ret    

008003e0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	83 ec 4c             	sub    $0x4c,%esp
  8003e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ec:	8b 75 10             	mov    0x10(%ebp),%esi
  8003ef:	eb 12                	jmp    800403 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003f1:	85 c0                	test   %eax,%eax
  8003f3:	0f 84 40 03 00 00    	je     800739 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  8003f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003fd:	89 04 24             	mov    %eax,(%esp)
  800400:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800403:	0f b6 06             	movzbl (%esi),%eax
  800406:	46                   	inc    %esi
  800407:	83 f8 25             	cmp    $0x25,%eax
  80040a:	75 e5                	jne    8003f1 <vprintfmt+0x11>
  80040c:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800410:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800417:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80041c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800423:	ba 00 00 00 00       	mov    $0x0,%edx
  800428:	eb 26                	jmp    800450 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80042d:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800431:	eb 1d                	jmp    800450 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800433:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800436:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80043a:	eb 14                	jmp    800450 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80043f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800446:	eb 08                	jmp    800450 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800448:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80044b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	0f b6 06             	movzbl (%esi),%eax
  800453:	8d 4e 01             	lea    0x1(%esi),%ecx
  800456:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800459:	8a 0e                	mov    (%esi),%cl
  80045b:	83 e9 23             	sub    $0x23,%ecx
  80045e:	80 f9 55             	cmp    $0x55,%cl
  800461:	0f 87 b6 02 00 00    	ja     80071d <vprintfmt+0x33d>
  800467:	0f b6 c9             	movzbl %cl,%ecx
  80046a:	ff 24 8d 20 17 80 00 	jmp    *0x801720(,%ecx,4)
  800471:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800474:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800479:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  80047c:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  800480:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800483:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800486:	83 f9 09             	cmp    $0x9,%ecx
  800489:	77 2a                	ja     8004b5 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80048b:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80048c:	eb eb                	jmp    800479 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048e:	8b 45 14             	mov    0x14(%ebp),%eax
  800491:	8d 48 04             	lea    0x4(%eax),%ecx
  800494:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800497:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80049c:	eb 17                	jmp    8004b5 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80049e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004a2:	78 98                	js     80043c <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004a7:	eb a7                	jmp    800450 <vprintfmt+0x70>
  8004a9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004ac:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004b3:	eb 9b                	jmp    800450 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004b5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b9:	79 95                	jns    800450 <vprintfmt+0x70>
  8004bb:	eb 8b                	jmp    800448 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004bd:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c1:	eb 8d                	jmp    800450 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c6:	8d 50 04             	lea    0x4(%eax),%edx
  8004c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d0:	8b 00                	mov    (%eax),%eax
  8004d2:	89 04 24             	mov    %eax,(%esp)
  8004d5:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004db:	e9 23 ff ff ff       	jmp    800403 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 50 04             	lea    0x4(%eax),%edx
  8004e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e9:	8b 00                	mov    (%eax),%eax
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	79 02                	jns    8004f1 <vprintfmt+0x111>
  8004ef:	f7 d8                	neg    %eax
  8004f1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f3:	83 f8 09             	cmp    $0x9,%eax
  8004f6:	7f 0b                	jg     800503 <vprintfmt+0x123>
  8004f8:	8b 04 85 80 18 80 00 	mov    0x801880(,%eax,4),%eax
  8004ff:	85 c0                	test   %eax,%eax
  800501:	75 23                	jne    800526 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800503:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800507:	c7 44 24 08 78 16 80 	movl   $0x801678,0x8(%esp)
  80050e:	00 
  80050f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800513:	8b 45 08             	mov    0x8(%ebp),%eax
  800516:	89 04 24             	mov    %eax,(%esp)
  800519:	e8 9a fe ff ff       	call   8003b8 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800521:	e9 dd fe ff ff       	jmp    800403 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800526:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80052a:	c7 44 24 08 81 16 80 	movl   $0x801681,0x8(%esp)
  800531:	00 
  800532:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800536:	8b 55 08             	mov    0x8(%ebp),%edx
  800539:	89 14 24             	mov    %edx,(%esp)
  80053c:	e8 77 fe ff ff       	call   8003b8 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800541:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800544:	e9 ba fe ff ff       	jmp    800403 <vprintfmt+0x23>
  800549:	89 f9                	mov    %edi,%ecx
  80054b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80054e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8d 50 04             	lea    0x4(%eax),%edx
  800557:	89 55 14             	mov    %edx,0x14(%ebp)
  80055a:	8b 30                	mov    (%eax),%esi
  80055c:	85 f6                	test   %esi,%esi
  80055e:	75 05                	jne    800565 <vprintfmt+0x185>
				p = "(null)";
  800560:	be 71 16 80 00       	mov    $0x801671,%esi
			if (width > 0 && padc != '-')
  800565:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800569:	0f 8e 84 00 00 00    	jle    8005f3 <vprintfmt+0x213>
  80056f:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800573:	74 7e                	je     8005f3 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800575:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800579:	89 34 24             	mov    %esi,(%esp)
  80057c:	e8 5d 02 00 00       	call   8007de <strnlen>
  800581:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800584:	29 c2                	sub    %eax,%edx
  800586:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800589:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  80058d:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800590:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800593:	89 de                	mov    %ebx,%esi
  800595:	89 d3                	mov    %edx,%ebx
  800597:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800599:	eb 0b                	jmp    8005a6 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80059b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80059f:	89 3c 24             	mov    %edi,(%esp)
  8005a2:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a5:	4b                   	dec    %ebx
  8005a6:	85 db                	test   %ebx,%ebx
  8005a8:	7f f1                	jg     80059b <vprintfmt+0x1bb>
  8005aa:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005ad:	89 f3                	mov    %esi,%ebx
  8005af:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005b5:	85 c0                	test   %eax,%eax
  8005b7:	79 05                	jns    8005be <vprintfmt+0x1de>
  8005b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8005be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005c1:	29 c2                	sub    %eax,%edx
  8005c3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005c6:	eb 2b                	jmp    8005f3 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005c8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005cc:	74 18                	je     8005e6 <vprintfmt+0x206>
  8005ce:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005d1:	83 fa 5e             	cmp    $0x5e,%edx
  8005d4:	76 10                	jbe    8005e6 <vprintfmt+0x206>
					putch('?', putdat);
  8005d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005da:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005e1:	ff 55 08             	call   *0x8(%ebp)
  8005e4:	eb 0a                	jmp    8005f0 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ea:	89 04 24             	mov    %eax,(%esp)
  8005ed:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f0:	ff 4d e4             	decl   -0x1c(%ebp)
  8005f3:	0f be 06             	movsbl (%esi),%eax
  8005f6:	46                   	inc    %esi
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	74 21                	je     80061c <vprintfmt+0x23c>
  8005fb:	85 ff                	test   %edi,%edi
  8005fd:	78 c9                	js     8005c8 <vprintfmt+0x1e8>
  8005ff:	4f                   	dec    %edi
  800600:	79 c6                	jns    8005c8 <vprintfmt+0x1e8>
  800602:	8b 7d 08             	mov    0x8(%ebp),%edi
  800605:	89 de                	mov    %ebx,%esi
  800607:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80060a:	eb 18                	jmp    800624 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80060c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800610:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800617:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800619:	4b                   	dec    %ebx
  80061a:	eb 08                	jmp    800624 <vprintfmt+0x244>
  80061c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80061f:	89 de                	mov    %ebx,%esi
  800621:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800624:	85 db                	test   %ebx,%ebx
  800626:	7f e4                	jg     80060c <vprintfmt+0x22c>
  800628:	89 7d 08             	mov    %edi,0x8(%ebp)
  80062b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800630:	e9 ce fd ff ff       	jmp    800403 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800635:	8d 45 14             	lea    0x14(%ebp),%eax
  800638:	e8 2f fd ff ff       	call   80036c <getint>
  80063d:	89 c6                	mov    %eax,%esi
  80063f:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800641:	85 d2                	test   %edx,%edx
  800643:	78 07                	js     80064c <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800645:	be 0a 00 00 00       	mov    $0xa,%esi
  80064a:	eb 7e                	jmp    8006ca <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80064c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800650:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800657:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80065a:	89 f0                	mov    %esi,%eax
  80065c:	89 fa                	mov    %edi,%edx
  80065e:	f7 d8                	neg    %eax
  800660:	83 d2 00             	adc    $0x0,%edx
  800663:	f7 da                	neg    %edx
			}
			base = 10;
  800665:	be 0a 00 00 00       	mov    $0xa,%esi
  80066a:	eb 5e                	jmp    8006ca <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066c:	8d 45 14             	lea    0x14(%ebp),%eax
  80066f:	e8 be fc ff ff       	call   800332 <getuint>
			base = 10;
  800674:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800679:	eb 4f                	jmp    8006ca <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
  80067e:	e8 af fc ff ff       	call   800332 <getuint>
			base = 8;
  800683:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800688:	eb 40                	jmp    8006ca <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  80068a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800695:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800698:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006a3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006af:	8b 00                	mov    (%eax),%eax
  8006b1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b6:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8006bb:	eb 0d                	jmp    8006ca <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c0:	e8 6d fc ff ff       	call   800332 <getuint>
			base = 16;
  8006c5:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ca:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8006ce:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8006d2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006d5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8006d9:	89 74 24 08          	mov    %esi,0x8(%esp)
  8006dd:	89 04 24             	mov    %eax,(%esp)
  8006e0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006e4:	89 da                	mov    %ebx,%edx
  8006e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e9:	e8 7a fb ff ff       	call   800268 <printnum>
			break;
  8006ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006f1:	e9 0d fd ff ff       	jmp    800403 <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  8006f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f9:	e8 6e fc ff ff       	call   80036c <getint>
  8006fe:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800703:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  800706:	e9 f8 fc ff ff       	jmp    800403 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80070b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070f:	89 04 24             	mov    %eax,(%esp)
  800712:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800715:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800718:	e9 e6 fc ff ff       	jmp    800403 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80071d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800721:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800728:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072b:	eb 01                	jmp    80072e <vprintfmt+0x34e>
  80072d:	4e                   	dec    %esi
  80072e:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800732:	75 f9                	jne    80072d <vprintfmt+0x34d>
  800734:	e9 ca fc ff ff       	jmp    800403 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800739:	83 c4 4c             	add    $0x4c,%esp
  80073c:	5b                   	pop    %ebx
  80073d:	5e                   	pop    %esi
  80073e:	5f                   	pop    %edi
  80073f:	5d                   	pop    %ebp
  800740:	c3                   	ret    

00800741 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	83 ec 28             	sub    $0x28,%esp
  800747:	8b 45 08             	mov    0x8(%ebp),%eax
  80074a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800750:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800754:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800757:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80075e:	85 c0                	test   %eax,%eax
  800760:	74 30                	je     800792 <vsnprintf+0x51>
  800762:	85 d2                	test   %edx,%edx
  800764:	7e 33                	jle    800799 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076d:	8b 45 10             	mov    0x10(%ebp),%eax
  800770:	89 44 24 08          	mov    %eax,0x8(%esp)
  800774:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077b:	c7 04 24 9e 03 80 00 	movl   $0x80039e,(%esp)
  800782:	e8 59 fc ff ff       	call   8003e0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800787:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800790:	eb 0c                	jmp    80079e <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800792:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800797:	eb 05                	jmp    80079e <vsnprintf+0x5d>
  800799:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079e:	c9                   	leave  
  80079f:	c3                   	ret    

008007a0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007be:	89 04 24             	mov    %eax,(%esp)
  8007c1:	e8 7b ff ff ff       	call   800741 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c6:	c9                   	leave  
  8007c7:	c3                   	ret    

008007c8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d3:	eb 01                	jmp    8007d6 <strlen+0xe>
		n++;
  8007d5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007da:	75 f9                	jne    8007d5 <strlen+0xd>
		n++;
	return n;
}
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007e4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ec:	eb 01                	jmp    8007ef <strnlen+0x11>
		n++;
  8007ee:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ef:	39 d0                	cmp    %edx,%eax
  8007f1:	74 06                	je     8007f9 <strnlen+0x1b>
  8007f3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f7:	75 f5                	jne    8007ee <strnlen+0x10>
		n++;
	return n;
}
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800805:	ba 00 00 00 00       	mov    $0x0,%edx
  80080a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80080d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800810:	42                   	inc    %edx
  800811:	84 c9                	test   %cl,%cl
  800813:	75 f5                	jne    80080a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800815:	5b                   	pop    %ebx
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	53                   	push   %ebx
  80081c:	83 ec 08             	sub    $0x8,%esp
  80081f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800822:	89 1c 24             	mov    %ebx,(%esp)
  800825:	e8 9e ff ff ff       	call   8007c8 <strlen>
	strcpy(dst + len, src);
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800831:	01 d8                	add    %ebx,%eax
  800833:	89 04 24             	mov    %eax,(%esp)
  800836:	e8 c0 ff ff ff       	call   8007fb <strcpy>
	return dst;
}
  80083b:	89 d8                	mov    %ebx,%eax
  80083d:	83 c4 08             	add    $0x8,%esp
  800840:	5b                   	pop    %ebx
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	56                   	push   %esi
  800847:	53                   	push   %ebx
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800851:	b9 00 00 00 00       	mov    $0x0,%ecx
  800856:	eb 0c                	jmp    800864 <strncpy+0x21>
		*dst++ = *src;
  800858:	8a 1a                	mov    (%edx),%bl
  80085a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80085d:	80 3a 01             	cmpb   $0x1,(%edx)
  800860:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800863:	41                   	inc    %ecx
  800864:	39 f1                	cmp    %esi,%ecx
  800866:	75 f0                	jne    800858 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800868:	5b                   	pop    %ebx
  800869:	5e                   	pop    %esi
  80086a:	5d                   	pop    %ebp
  80086b:	c3                   	ret    

0080086c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	56                   	push   %esi
  800870:	53                   	push   %ebx
  800871:	8b 75 08             	mov    0x8(%ebp),%esi
  800874:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800877:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087a:	85 d2                	test   %edx,%edx
  80087c:	75 0a                	jne    800888 <strlcpy+0x1c>
  80087e:	89 f0                	mov    %esi,%eax
  800880:	eb 1a                	jmp    80089c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800882:	88 18                	mov    %bl,(%eax)
  800884:	40                   	inc    %eax
  800885:	41                   	inc    %ecx
  800886:	eb 02                	jmp    80088a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800888:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80088a:	4a                   	dec    %edx
  80088b:	74 0a                	je     800897 <strlcpy+0x2b>
  80088d:	8a 19                	mov    (%ecx),%bl
  80088f:	84 db                	test   %bl,%bl
  800891:	75 ef                	jne    800882 <strlcpy+0x16>
  800893:	89 c2                	mov    %eax,%edx
  800895:	eb 02                	jmp    800899 <strlcpy+0x2d>
  800897:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800899:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80089c:	29 f0                	sub    %esi,%eax
}
  80089e:	5b                   	pop    %ebx
  80089f:	5e                   	pop    %esi
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ab:	eb 02                	jmp    8008af <strcmp+0xd>
		p++, q++;
  8008ad:	41                   	inc    %ecx
  8008ae:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008af:	8a 01                	mov    (%ecx),%al
  8008b1:	84 c0                	test   %al,%al
  8008b3:	74 04                	je     8008b9 <strcmp+0x17>
  8008b5:	3a 02                	cmp    (%edx),%al
  8008b7:	74 f4                	je     8008ad <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b9:	0f b6 c0             	movzbl %al,%eax
  8008bc:	0f b6 12             	movzbl (%edx),%edx
  8008bf:	29 d0                	sub    %edx,%eax
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	53                   	push   %ebx
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008d0:	eb 03                	jmp    8008d5 <strncmp+0x12>
		n--, p++, q++;
  8008d2:	4a                   	dec    %edx
  8008d3:	40                   	inc    %eax
  8008d4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d5:	85 d2                	test   %edx,%edx
  8008d7:	74 14                	je     8008ed <strncmp+0x2a>
  8008d9:	8a 18                	mov    (%eax),%bl
  8008db:	84 db                	test   %bl,%bl
  8008dd:	74 04                	je     8008e3 <strncmp+0x20>
  8008df:	3a 19                	cmp    (%ecx),%bl
  8008e1:	74 ef                	je     8008d2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e3:	0f b6 00             	movzbl (%eax),%eax
  8008e6:	0f b6 11             	movzbl (%ecx),%edx
  8008e9:	29 d0                	sub    %edx,%eax
  8008eb:	eb 05                	jmp    8008f2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ed:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f2:	5b                   	pop    %ebx
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008fe:	eb 05                	jmp    800905 <strchr+0x10>
		if (*s == c)
  800900:	38 ca                	cmp    %cl,%dl
  800902:	74 0c                	je     800910 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800904:	40                   	inc    %eax
  800905:	8a 10                	mov    (%eax),%dl
  800907:	84 d2                	test   %dl,%dl
  800909:	75 f5                	jne    800900 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80091b:	eb 05                	jmp    800922 <strfind+0x10>
		if (*s == c)
  80091d:	38 ca                	cmp    %cl,%dl
  80091f:	74 07                	je     800928 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800921:	40                   	inc    %eax
  800922:	8a 10                	mov    (%eax),%dl
  800924:	84 d2                	test   %dl,%dl
  800926:	75 f5                	jne    80091d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	57                   	push   %edi
  80092e:	56                   	push   %esi
  80092f:	53                   	push   %ebx
  800930:	8b 7d 08             	mov    0x8(%ebp),%edi
  800933:	8b 45 0c             	mov    0xc(%ebp),%eax
  800936:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800939:	85 c9                	test   %ecx,%ecx
  80093b:	74 30                	je     80096d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800943:	75 25                	jne    80096a <memset+0x40>
  800945:	f6 c1 03             	test   $0x3,%cl
  800948:	75 20                	jne    80096a <memset+0x40>
		c &= 0xFF;
  80094a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094d:	89 d3                	mov    %edx,%ebx
  80094f:	c1 e3 08             	shl    $0x8,%ebx
  800952:	89 d6                	mov    %edx,%esi
  800954:	c1 e6 18             	shl    $0x18,%esi
  800957:	89 d0                	mov    %edx,%eax
  800959:	c1 e0 10             	shl    $0x10,%eax
  80095c:	09 f0                	or     %esi,%eax
  80095e:	09 d0                	or     %edx,%eax
  800960:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800962:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800965:	fc                   	cld    
  800966:	f3 ab                	rep stos %eax,%es:(%edi)
  800968:	eb 03                	jmp    80096d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096a:	fc                   	cld    
  80096b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096d:	89 f8                	mov    %edi,%eax
  80096f:	5b                   	pop    %ebx
  800970:	5e                   	pop    %esi
  800971:	5f                   	pop    %edi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	57                   	push   %edi
  800978:	56                   	push   %esi
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800982:	39 c6                	cmp    %eax,%esi
  800984:	73 34                	jae    8009ba <memmove+0x46>
  800986:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800989:	39 d0                	cmp    %edx,%eax
  80098b:	73 2d                	jae    8009ba <memmove+0x46>
		s += n;
		d += n;
  80098d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800990:	f6 c2 03             	test   $0x3,%dl
  800993:	75 1b                	jne    8009b0 <memmove+0x3c>
  800995:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099b:	75 13                	jne    8009b0 <memmove+0x3c>
  80099d:	f6 c1 03             	test   $0x3,%cl
  8009a0:	75 0e                	jne    8009b0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a2:	83 ef 04             	sub    $0x4,%edi
  8009a5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ab:	fd                   	std    
  8009ac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ae:	eb 07                	jmp    8009b7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b0:	4f                   	dec    %edi
  8009b1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b4:	fd                   	std    
  8009b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b7:	fc                   	cld    
  8009b8:	eb 20                	jmp    8009da <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ba:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c0:	75 13                	jne    8009d5 <memmove+0x61>
  8009c2:	a8 03                	test   $0x3,%al
  8009c4:	75 0f                	jne    8009d5 <memmove+0x61>
  8009c6:	f6 c1 03             	test   $0x3,%cl
  8009c9:	75 0a                	jne    8009d5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009cb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ce:	89 c7                	mov    %eax,%edi
  8009d0:	fc                   	cld    
  8009d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d3:	eb 05                	jmp    8009da <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d5:	89 c7                	mov    %eax,%edi
  8009d7:	fc                   	cld    
  8009d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009da:	5e                   	pop    %esi
  8009db:	5f                   	pop    %edi
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	89 04 24             	mov    %eax,(%esp)
  8009f8:	e8 77 ff ff ff       	call   800974 <memmove>
}
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	57                   	push   %edi
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a13:	eb 16                	jmp    800a2b <memcmp+0x2c>
		if (*s1 != *s2)
  800a15:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a18:	42                   	inc    %edx
  800a19:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a1d:	38 c8                	cmp    %cl,%al
  800a1f:	74 0a                	je     800a2b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a21:	0f b6 c0             	movzbl %al,%eax
  800a24:	0f b6 c9             	movzbl %cl,%ecx
  800a27:	29 c8                	sub    %ecx,%eax
  800a29:	eb 09                	jmp    800a34 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2b:	39 da                	cmp    %ebx,%edx
  800a2d:	75 e6                	jne    800a15 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a34:	5b                   	pop    %ebx
  800a35:	5e                   	pop    %esi
  800a36:	5f                   	pop    %edi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a42:	89 c2                	mov    %eax,%edx
  800a44:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a47:	eb 05                	jmp    800a4e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a49:	38 08                	cmp    %cl,(%eax)
  800a4b:	74 05                	je     800a52 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4d:	40                   	inc    %eax
  800a4e:	39 d0                	cmp    %edx,%eax
  800a50:	72 f7                	jb     800a49 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
  800a5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a60:	eb 01                	jmp    800a63 <strtol+0xf>
		s++;
  800a62:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a63:	8a 02                	mov    (%edx),%al
  800a65:	3c 20                	cmp    $0x20,%al
  800a67:	74 f9                	je     800a62 <strtol+0xe>
  800a69:	3c 09                	cmp    $0x9,%al
  800a6b:	74 f5                	je     800a62 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a6d:	3c 2b                	cmp    $0x2b,%al
  800a6f:	75 08                	jne    800a79 <strtol+0x25>
		s++;
  800a71:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a72:	bf 00 00 00 00       	mov    $0x0,%edi
  800a77:	eb 13                	jmp    800a8c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a79:	3c 2d                	cmp    $0x2d,%al
  800a7b:	75 0a                	jne    800a87 <strtol+0x33>
		s++, neg = 1;
  800a7d:	8d 52 01             	lea    0x1(%edx),%edx
  800a80:	bf 01 00 00 00       	mov    $0x1,%edi
  800a85:	eb 05                	jmp    800a8c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a87:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8c:	85 db                	test   %ebx,%ebx
  800a8e:	74 05                	je     800a95 <strtol+0x41>
  800a90:	83 fb 10             	cmp    $0x10,%ebx
  800a93:	75 28                	jne    800abd <strtol+0x69>
  800a95:	8a 02                	mov    (%edx),%al
  800a97:	3c 30                	cmp    $0x30,%al
  800a99:	75 10                	jne    800aab <strtol+0x57>
  800a9b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a9f:	75 0a                	jne    800aab <strtol+0x57>
		s += 2, base = 16;
  800aa1:	83 c2 02             	add    $0x2,%edx
  800aa4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa9:	eb 12                	jmp    800abd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800aab:	85 db                	test   %ebx,%ebx
  800aad:	75 0e                	jne    800abd <strtol+0x69>
  800aaf:	3c 30                	cmp    $0x30,%al
  800ab1:	75 05                	jne    800ab8 <strtol+0x64>
		s++, base = 8;
  800ab3:	42                   	inc    %edx
  800ab4:	b3 08                	mov    $0x8,%bl
  800ab6:	eb 05                	jmp    800abd <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ab8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800abd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac4:	8a 0a                	mov    (%edx),%cl
  800ac6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ac9:	80 fb 09             	cmp    $0x9,%bl
  800acc:	77 08                	ja     800ad6 <strtol+0x82>
			dig = *s - '0';
  800ace:	0f be c9             	movsbl %cl,%ecx
  800ad1:	83 e9 30             	sub    $0x30,%ecx
  800ad4:	eb 1e                	jmp    800af4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ad6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ad9:	80 fb 19             	cmp    $0x19,%bl
  800adc:	77 08                	ja     800ae6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800ade:	0f be c9             	movsbl %cl,%ecx
  800ae1:	83 e9 57             	sub    $0x57,%ecx
  800ae4:	eb 0e                	jmp    800af4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ae6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ae9:	80 fb 19             	cmp    $0x19,%bl
  800aec:	77 12                	ja     800b00 <strtol+0xac>
			dig = *s - 'A' + 10;
  800aee:	0f be c9             	movsbl %cl,%ecx
  800af1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800af4:	39 f1                	cmp    %esi,%ecx
  800af6:	7d 0c                	jge    800b04 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800af8:	42                   	inc    %edx
  800af9:	0f af c6             	imul   %esi,%eax
  800afc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800afe:	eb c4                	jmp    800ac4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b00:	89 c1                	mov    %eax,%ecx
  800b02:	eb 02                	jmp    800b06 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b04:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b06:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0a:	74 05                	je     800b11 <strtol+0xbd>
		*endptr = (char *) s;
  800b0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b0f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b11:	85 ff                	test   %edi,%edi
  800b13:	74 04                	je     800b19 <strtol+0xc5>
  800b15:	89 c8                	mov    %ecx,%eax
  800b17:	f7 d8                	neg    %eax
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    
	...

00800b20 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b26:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b31:	89 c3                	mov    %eax,%ebx
  800b33:	89 c7                	mov    %eax,%edi
  800b35:	89 c6                	mov    %eax,%esi
  800b37:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4e:	89 d1                	mov    %edx,%ecx
  800b50:	89 d3                	mov    %edx,%ebx
  800b52:	89 d7                	mov    %edx,%edi
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
  800b63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b70:	8b 55 08             	mov    0x8(%ebp),%edx
  800b73:	89 cb                	mov    %ecx,%ebx
  800b75:	89 cf                	mov    %ecx,%edi
  800b77:	89 ce                	mov    %ecx,%esi
  800b79:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7b:	85 c0                	test   %eax,%eax
  800b7d:	7e 28                	jle    800ba7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b83:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b8a:	00 
  800b8b:	c7 44 24 08 a8 18 80 	movl   $0x8018a8,0x8(%esp)
  800b92:	00 
  800b93:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b9a:	00 
  800b9b:	c7 04 24 c5 18 80 00 	movl   $0x8018c5,(%esp)
  800ba2:	e8 ed 06 00 00       	call   801294 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba7:	83 c4 2c             	add    $0x2c,%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbf:	89 d1                	mov    %edx,%ecx
  800bc1:	89 d3                	mov    %edx,%ebx
  800bc3:	89 d7                	mov    %edx,%edi
  800bc5:	89 d6                	mov    %edx,%esi
  800bc7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_yield>:

void
sys_yield(void)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bde:	89 d1                	mov    %edx,%ecx
  800be0:	89 d3                	mov    %edx,%ebx
  800be2:	89 d7                	mov    %edx,%edi
  800be4:	89 d6                	mov    %edx,%esi
  800be6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	57                   	push   %edi
  800bf1:	56                   	push   %esi
  800bf2:	53                   	push   %ebx
  800bf3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf6:	be 00 00 00 00       	mov    $0x0,%esi
  800bfb:	b8 04 00 00 00       	mov    $0x4,%eax
  800c00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	89 f7                	mov    %esi,%edi
  800c0b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0d:	85 c0                	test   %eax,%eax
  800c0f:	7e 28                	jle    800c39 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c11:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c15:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c1c:	00 
  800c1d:	c7 44 24 08 a8 18 80 	movl   $0x8018a8,0x8(%esp)
  800c24:	00 
  800c25:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c2c:	00 
  800c2d:	c7 04 24 c5 18 80 00 	movl   $0x8018c5,(%esp)
  800c34:	e8 5b 06 00 00       	call   801294 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c39:	83 c4 2c             	add    $0x2c,%esp
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c60:	85 c0                	test   %eax,%eax
  800c62:	7e 28                	jle    800c8c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c64:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c68:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c6f:	00 
  800c70:	c7 44 24 08 a8 18 80 	movl   $0x8018a8,0x8(%esp)
  800c77:	00 
  800c78:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c7f:	00 
  800c80:	c7 04 24 c5 18 80 00 	movl   $0x8018c5,(%esp)
  800c87:	e8 08 06 00 00       	call   801294 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c8c:	83 c4 2c             	add    $0x2c,%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	89 df                	mov    %ebx,%edi
  800caf:	89 de                	mov    %ebx,%esi
  800cb1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 28                	jle    800cdf <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cbb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cc2:	00 
  800cc3:	c7 44 24 08 a8 18 80 	movl   $0x8018a8,0x8(%esp)
  800cca:	00 
  800ccb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd2:	00 
  800cd3:	c7 04 24 c5 18 80 00 	movl   $0x8018c5,(%esp)
  800cda:	e8 b5 05 00 00       	call   801294 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cdf:	83 c4 2c             	add    $0x2c,%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf5:	b8 08 00 00 00       	mov    $0x8,%eax
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800d00:	89 df                	mov    %ebx,%edi
  800d02:	89 de                	mov    %ebx,%esi
  800d04:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7e 28                	jle    800d32 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d15:	00 
  800d16:	c7 44 24 08 a8 18 80 	movl   $0x8018a8,0x8(%esp)
  800d1d:	00 
  800d1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d25:	00 
  800d26:	c7 04 24 c5 18 80 00 	movl   $0x8018c5,(%esp)
  800d2d:	e8 62 05 00 00       	call   801294 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d32:	83 c4 2c             	add    $0x2c,%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d48:	b8 09 00 00 00       	mov    $0x9,%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	89 df                	mov    %ebx,%edi
  800d55:	89 de                	mov    %ebx,%esi
  800d57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 28                	jle    800d85 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d61:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d68:	00 
  800d69:	c7 44 24 08 a8 18 80 	movl   $0x8018a8,0x8(%esp)
  800d70:	00 
  800d71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d78:	00 
  800d79:	c7 04 24 c5 18 80 00 	movl   $0x8018c5,(%esp)
  800d80:	e8 0f 05 00 00       	call   801294 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d85:	83 c4 2c             	add    $0x2c,%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d93:	be 00 00 00 00       	mov    $0x0,%esi
  800d98:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d9d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da6:	8b 55 08             	mov    0x8(%ebp),%edx
  800da9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dab:	5b                   	pop    %ebx
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    

00800db0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	57                   	push   %edi
  800db4:	56                   	push   %esi
  800db5:	53                   	push   %ebx
  800db6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	89 cb                	mov    %ecx,%ebx
  800dc8:	89 cf                	mov    %ecx,%edi
  800dca:	89 ce                	mov    %ecx,%esi
  800dcc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	7e 28                	jle    800dfa <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd6:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ddd:	00 
  800dde:	c7 44 24 08 a8 18 80 	movl   $0x8018a8,0x8(%esp)
  800de5:	00 
  800de6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ded:	00 
  800dee:	c7 04 24 c5 18 80 00 	movl   $0x8018c5,(%esp)
  800df5:	e8 9a 04 00 00       	call   801294 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dfa:	83 c4 2c             	add    $0x2c,%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e10:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	89 df                	mov    %ebx,%edi
  800e1d:	89 de                	mov    %ebx,%esi
  800e1f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e21:	85 c0                	test   %eax,%eax
  800e23:	7e 28                	jle    800e4d <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e29:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e30:	00 
  800e31:	c7 44 24 08 a8 18 80 	movl   $0x8018a8,0x8(%esp)
  800e38:	00 
  800e39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e40:	00 
  800e41:	c7 04 24 c5 18 80 00 	movl   $0x8018c5,(%esp)
  800e48:	e8 47 04 00 00       	call   801294 <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800e4d:	83 c4 2c             	add    $0x2c,%esp
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    
  800e55:	00 00                	add    %al,(%eax)
	...

00800e58 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	53                   	push   %ebx
  800e5c:	83 ec 24             	sub    $0x24,%esp
  800e5f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e62:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800e64:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e68:	74 2d                	je     800e97 <pgfault+0x3f>
  800e6a:	89 d8                	mov    %ebx,%eax
  800e6c:	c1 e8 16             	shr    $0x16,%eax
  800e6f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e76:	a8 01                	test   $0x1,%al
  800e78:	74 1d                	je     800e97 <pgfault+0x3f>
		(uvpt[PGNUM(addr)] & PTE_P) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800e7a:	89 d8                	mov    %ebx,%eax
  800e7c:	c1 e8 0c             	shr    $0xc,%eax
  800e7f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800e86:	f6 c2 01             	test   $0x1,%dl
  800e89:	74 0c                	je     800e97 <pgfault+0x3f>
		(uvpt[PGNUM(addr)] & PTE_P) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800e8b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e92:	f6 c4 08             	test   $0x8,%ah
  800e95:	75 1c                	jne    800eb3 <pgfault+0x5b>
		panic("pgfault: not a write or a copy on write page fault!");
  800e97:	c7 44 24 08 d4 18 80 	movl   $0x8018d4,0x8(%esp)
  800e9e:	00 
  800e9f:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800ea6:	00 
  800ea7:	c7 04 24 08 19 80 00 	movl   $0x801908,(%esp)
  800eae:	e8 e1 03 00 00       	call   801294 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	// we need to make addr page-aligned
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)) < 0)
  800eb3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800eba:	00 
  800ebb:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ec2:	00 
  800ec3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eca:	e8 1e fd ff ff       	call   800bed <sys_page_alloc>
  800ecf:	85 c0                	test   %eax,%eax
  800ed1:	79 20                	jns    800ef3 <pgfault+0x9b>
		panic("pgfault: sys_page_alloc: %e", r);
  800ed3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ed7:	c7 44 24 08 13 19 80 	movl   $0x801913,0x8(%esp)
  800ede:	00 
  800edf:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800ee6:	00 
  800ee7:	c7 04 24 08 19 80 00 	movl   $0x801908,(%esp)
  800eee:	e8 a1 03 00 00       	call   801294 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// we need to make addr page-aligned
	addr = ROUNDDOWN(addr, PGSIZE);
  800ef3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)) < 0)
		panic("pgfault: sys_page_alloc: %e", r);
	memcpy(PFTEMP, addr, PGSIZE);
  800ef9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f00:	00 
  800f01:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f05:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f0c:	e8 cd fa ff ff       	call   8009de <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P)) < 0)
  800f11:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f18:	00 
  800f19:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f1d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f24:	00 
  800f25:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f2c:	00 
  800f2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f34:	e8 08 fd ff ff       	call   800c41 <sys_page_map>
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	79 20                	jns    800f5d <pgfault+0x105>
		panic("pgfault: sys_page_map: %e", r);
  800f3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f41:	c7 44 24 08 2f 19 80 	movl   $0x80192f,0x8(%esp)
  800f48:	00 
  800f49:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800f50:	00 
  800f51:	c7 04 24 08 19 80 00 	movl   $0x801908,(%esp)
  800f58:	e8 37 03 00 00       	call   801294 <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f5d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f64:	00 
  800f65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f6c:	e8 23 fd ff ff       	call   800c94 <sys_page_unmap>
  800f71:	85 c0                	test   %eax,%eax
  800f73:	79 20                	jns    800f95 <pgfault+0x13d>
		panic("pgfault: sys_page_unmap: %e", r);
  800f75:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f79:	c7 44 24 08 49 19 80 	movl   $0x801949,0x8(%esp)
  800f80:	00 
  800f81:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800f88:	00 
  800f89:	c7 04 24 08 19 80 00 	movl   $0x801908,(%esp)
  800f90:	e8 ff 02 00 00       	call   801294 <_panic>
}
  800f95:	83 c4 24             	add    $0x24,%esp
  800f98:	5b                   	pop    %ebx
  800f99:	5d                   	pop    %ebp
  800f9a:	c3                   	ret    

00800f9b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	57                   	push   %edi
  800f9f:	56                   	push   %esi
  800fa0:	53                   	push   %ebx
  800fa1:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800fa4:	c7 04 24 58 0e 80 00 	movl   $0x800e58,(%esp)
  800fab:	e8 3c 03 00 00       	call   8012ec <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fb0:	ba 07 00 00 00       	mov    $0x7,%edx
  800fb5:	89 d0                	mov    %edx,%eax
  800fb7:	cd 30                	int    $0x30
  800fb9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fbc:	89 c7                	mov    %eax,%edi
	envid_t envid;
	uint8_t *addr;
	int r;
	extern unsigned char end[];
	envid = sys_exofork();
	if (envid < 0)
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	79 20                	jns    800fe2 <fork+0x47>
		panic("sys_exofork: %e", envid);
  800fc2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fc6:	c7 44 24 08 65 19 80 	movl   $0x801965,0x8(%esp)
  800fcd:	00 
  800fce:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  800fd5:	00 
  800fd6:	c7 04 24 08 19 80 00 	movl   $0x801908,(%esp)
  800fdd:	e8 b2 02 00 00       	call   801294 <_panic>
	if (envid == 0) {
  800fe2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fe6:	75 27                	jne    80100f <fork+0x74>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800fe8:	e8 c2 fb ff ff       	call   800baf <sys_getenvid>
  800fed:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ff2:	8d 14 80             	lea    (%eax,%eax,4),%edx
  800ff5:	8d 04 50             	lea    (%eax,%edx,2),%eax
  800ff8:	c1 e0 04             	shl    $0x4,%eax
  800ffb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801000:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return 0;
  801005:	b8 00 00 00 00       	mov    $0x0,%eax
  80100a:	e9 23 01 00 00       	jmp    801132 <fork+0x197>
	int r;
	extern unsigned char end[];
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  80100f:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	}

	// We're the parent.
	for (addr = 0; addr < (uint8_t *)USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  801014:	89 d8                	mov    %ebx,%eax
  801016:	c1 e8 16             	shr    $0x16,%eax
  801019:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801020:	a8 01                	test   $0x1,%al
  801022:	0f 84 ac 00 00 00    	je     8010d4 <fork+0x139>
  801028:	89 d8                	mov    %ebx,%eax
  80102a:	c1 e8 0c             	shr    $0xc,%eax
  80102d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801034:	f6 c2 01             	test   $0x1,%dl
  801037:	0f 84 97 00 00 00    	je     8010d4 <fork+0x139>
			&& (uvpt[PGNUM(addr)] & PTE_U))
  80103d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801044:	f6 c2 04             	test   $0x4,%dl
  801047:	0f 84 87 00 00 00    	je     8010d4 <fork+0x139>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	void *va = (void *)(pn * PGSIZE);
  80104d:	89 c6                	mov    %eax,%esi
  80104f:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  801052:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801059:	f6 c2 02             	test   $0x2,%dl
  80105c:	75 0c                	jne    80106a <fork+0xcf>
  80105e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801065:	f6 c4 08             	test   $0x8,%ah
  801068:	74 4a                	je     8010b4 <fork+0x119>
		if ((r = sys_page_map(0, va, envid, va, PTE_COW|PTE_U|PTE_P)) < 0)
  80106a:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801071:	00 
  801072:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801076:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80107a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80107e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801085:	e8 b7 fb ff ff       	call   800c41 <sys_page_map>
  80108a:	85 c0                	test   %eax,%eax
  80108c:	78 46                	js     8010d4 <fork+0x139>
			return r;
		if ((r = sys_page_map(0, va, 0, va, PTE_COW|PTE_U|PTE_P)) < 0)
  80108e:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801095:	00 
  801096:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80109a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010a1:	00 
  8010a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ad:	e8 8f fb ff ff       	call   800c41 <sys_page_map>
  8010b2:	eb 20                	jmp    8010d4 <fork+0x139>
			return r;
	}
	else {
		if ((r = sys_page_map(0, va, envid, va, PTE_U|PTE_P)) < 0)
  8010b4:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8010bb:	00 
  8010bc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010c0:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010cf:	e8 6d fb ff ff       	call   800c41 <sys_page_map>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	// We're the parent.
	for (addr = 0; addr < (uint8_t *)USTACKTOP; addr += PGSIZE)
  8010d4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010da:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010e0:	0f 85 2e ff ff ff    	jne    801014 <fork+0x79>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
			&& (uvpt[PGNUM(addr)] & PTE_U))
			duppage(envid, PGNUM(addr));

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  8010e6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010ed:	00 
  8010ee:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010f5:	ee 
  8010f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f9:	89 04 24             	mov    %eax,(%esp)
  8010fc:	e8 ec fa ff ff       	call   800bed <sys_page_alloc>
  801101:	85 c0                	test   %eax,%eax
  801103:	78 2d                	js     801132 <fork+0x197>
		return r;
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801105:	c7 44 24 04 80 13 80 	movl   $0x801380,0x4(%esp)
  80110c:	00 
  80110d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801110:	89 04 24             	mov    %eax,(%esp)
  801113:	e8 22 fc ff ff       	call   800d3a <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801118:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80111f:	00 
  801120:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801123:	89 04 24             	mov    %eax,(%esp)
  801126:	e8 bc fb ff ff       	call   800ce7 <sys_env_set_status>
  80112b:	85 c0                	test   %eax,%eax
  80112d:	78 03                	js     801132 <fork+0x197>
		return r;

	return envid;
  80112f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801132:	83 c4 3c             	add    $0x3c,%esp
  801135:	5b                   	pop    %ebx
  801136:	5e                   	pop    %esi
  801137:	5f                   	pop    %edi
  801138:	5d                   	pop    %ebp
  801139:	c3                   	ret    

0080113a <sfork>:

// Challenge!
int
sfork(void)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801140:	c7 44 24 08 75 19 80 	movl   $0x801975,0x8(%esp)
  801147:	00 
  801148:	c7 44 24 04 8d 00 00 	movl   $0x8d,0x4(%esp)
  80114f:	00 
  801150:	c7 04 24 08 19 80 00 	movl   $0x801908,(%esp)
  801157:	e8 38 01 00 00       	call   801294 <_panic>

0080115c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	56                   	push   %esi
  801160:	53                   	push   %ebx
  801161:	83 ec 10             	sub    $0x10,%esp
  801164:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801167:	8b 45 0c             	mov    0xc(%ebp),%eax
  80116a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	// -1 must be an invalid address.
	if (!pg) pg = (void *)-1;
  80116d:	85 c0                	test   %eax,%eax
  80116f:	75 05                	jne    801176 <ipc_recv+0x1a>
  801171:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	if ((r = sys_ipc_recv(pg)) < 0) {
  801176:	89 04 24             	mov    %eax,(%esp)
  801179:	e8 32 fc ff ff       	call   800db0 <sys_ipc_recv>
  80117e:	85 c0                	test   %eax,%eax
  801180:	79 16                	jns    801198 <ipc_recv+0x3c>
		if (from_env_store) *from_env_store = 0;
  801182:	85 db                	test   %ebx,%ebx
  801184:	74 06                	je     80118c <ipc_recv+0x30>
  801186:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  80118c:	85 f6                	test   %esi,%esi
  80118e:	74 2c                	je     8011bc <ipc_recv+0x60>
  801190:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801196:	eb 24                	jmp    8011bc <ipc_recv+0x60>
		return r;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801198:	85 db                	test   %ebx,%ebx
  80119a:	74 0a                	je     8011a6 <ipc_recv+0x4a>
  80119c:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8011a1:	8b 40 78             	mov    0x78(%eax),%eax
  8011a4:	89 03                	mov    %eax,(%ebx)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  8011a6:	85 f6                	test   %esi,%esi
  8011a8:	74 0a                	je     8011b4 <ipc_recv+0x58>
  8011aa:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8011af:	8b 40 7c             	mov    0x7c(%eax),%eax
  8011b2:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  8011b4:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8011b9:	8b 40 74             	mov    0x74(%eax),%eax
}
  8011bc:	83 c4 10             	add    $0x10,%esp
  8011bf:	5b                   	pop    %ebx
  8011c0:	5e                   	pop    %esi
  8011c1:	5d                   	pop    %ebp
  8011c2:	c3                   	ret    

008011c3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	57                   	push   %edi
  8011c7:	56                   	push   %esi
  8011c8:	53                   	push   %ebx
  8011c9:	83 ec 1c             	sub    $0x1c,%esp
  8011cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011cf:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	int retry_times = 0;
	if (!pg) pg = (void *)-1;
  8011d2:	85 db                	test   %ebx,%ebx
  8011d4:	75 05                	jne    8011db <ipc_send+0x18>
  8011d6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8011db:	be 03 00 00 00       	mov    $0x3,%esi
  8011e0:	eb 49                	jmp    80122b <ipc_send+0x68>
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  8011e2:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8011e5:	74 20                	je     801207 <ipc_send+0x44>
			panic("ipc_send: %e", r);
  8011e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011eb:	c7 44 24 08 8b 19 80 	movl   $0x80198b,0x8(%esp)
  8011f2:	00 
  8011f3:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  8011fa:	00 
  8011fb:	c7 04 24 98 19 80 00 	movl   $0x801998,(%esp)
  801202:	e8 8d 00 00 00       	call   801294 <_panic>
		retry_times++;
		if (retry_times > 2) panic("Retry times out!");
  801207:	4e                   	dec    %esi
  801208:	75 1c                	jne    801226 <ipc_send+0x63>
  80120a:	c7 44 24 08 a2 19 80 	movl   $0x8019a2,0x8(%esp)
  801211:	00 
  801212:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801219:	00 
  80121a:	c7 04 24 98 19 80 00 	movl   $0x801998,(%esp)
  801221:	e8 6e 00 00 00       	call   801294 <_panic>
		sys_yield();
  801226:	e8 a3 f9 ff ff       	call   800bce <sys_yield>
{
	// LAB 4: Your code here.
	int r;
	int retry_times = 0;
	if (!pg) pg = (void *)-1;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80122b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80122f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801233:	8b 45 0c             	mov    0xc(%ebp),%eax
  801236:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123a:	8b 45 08             	mov    0x8(%ebp),%eax
  80123d:	89 04 24             	mov    %eax,(%esp)
  801240:	e8 48 fb ff ff       	call   800d8d <sys_ipc_try_send>
  801245:	85 c0                	test   %eax,%eax
  801247:	78 99                	js     8011e2 <ipc_send+0x1f>
			panic("ipc_send: %e", r);
		retry_times++;
		if (retry_times > 2) panic("Retry times out!");
		sys_yield();
	}
}
  801249:	83 c4 1c             	add    $0x1c,%esp
  80124c:	5b                   	pop    %ebx
  80124d:	5e                   	pop    %esi
  80124e:	5f                   	pop    %edi
  80124f:	5d                   	pop    %ebp
  801250:	c3                   	ret    

00801251 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801257:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80125c:	8d 14 80             	lea    (%eax,%eax,4),%edx
  80125f:	8d 14 50             	lea    (%eax,%edx,2),%edx
  801262:	c1 e2 04             	shl    $0x4,%edx
  801265:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80126b:	8b 52 50             	mov    0x50(%edx),%edx
  80126e:	39 ca                	cmp    %ecx,%edx
  801270:	75 13                	jne    801285 <ipc_find_env+0x34>
			return envs[i].env_id;
  801272:	8d 14 80             	lea    (%eax,%eax,4),%edx
  801275:	8d 04 50             	lea    (%eax,%edx,2),%eax
  801278:	c1 e0 04             	shl    $0x4,%eax
  80127b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801280:	8b 40 40             	mov    0x40(%eax),%eax
  801283:	eb 0c                	jmp    801291 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801285:	40                   	inc    %eax
  801286:	3d 00 04 00 00       	cmp    $0x400,%eax
  80128b:	75 cf                	jne    80125c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80128d:	66 b8 00 00          	mov    $0x0,%ax
}
  801291:	5d                   	pop    %ebp
  801292:	c3                   	ret    
	...

00801294 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	56                   	push   %esi
  801298:	53                   	push   %ebx
  801299:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80129c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80129f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8012a5:	e8 05 f9 ff ff       	call   800baf <sys_getenvid>
  8012aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ad:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c0:	c7 04 24 b4 19 80 00 	movl   $0x8019b4,(%esp)
  8012c7:	e8 80 ef ff ff       	call   80024c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8012cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8012d3:	89 04 24             	mov    %eax,(%esp)
  8012d6:	e8 10 ef ff ff       	call   8001eb <vcprintf>
	cprintf("\n");
  8012db:	c7 04 24 18 16 80 00 	movl   $0x801618,(%esp)
  8012e2:	e8 65 ef ff ff       	call   80024c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8012e7:	cc                   	int3   
  8012e8:	eb fd                	jmp    8012e7 <_panic+0x53>
	...

008012ec <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012f2:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  8012f9:	75 40                	jne    80133b <set_pgfault_handler+0x4f>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
  8012fb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801302:	00 
  801303:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80130a:	ee 
  80130b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801312:	e8 d6 f8 ff ff       	call   800bed <sys_page_alloc>
  801317:	85 c0                	test   %eax,%eax
  801319:	79 20                	jns    80133b <set_pgfault_handler+0x4f>
            panic("set_pgfault_handler: sys_page_alloc: %e", r);
  80131b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80131f:	c7 44 24 08 d8 19 80 	movl   $0x8019d8,0x8(%esp)
  801326:	00 
  801327:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80132e:	00 
  80132f:	c7 04 24 34 1a 80 00 	movl   $0x801a34,(%esp)
  801336:	e8 59 ff ff ff       	call   801294 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80133b:	8b 45 08             	mov    0x8(%ebp),%eax
  80133e:	a3 10 20 80 00       	mov    %eax,0x802010
    if ((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0 )
  801343:	c7 44 24 04 80 13 80 	movl   $0x801380,0x4(%esp)
  80134a:	00 
  80134b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801352:	e8 e3 f9 ff ff       	call   800d3a <sys_env_set_pgfault_upcall>
  801357:	85 c0                	test   %eax,%eax
  801359:	79 20                	jns    80137b <set_pgfault_handler+0x8f>
        panic("set_pgfault_handler: sys_env_set_pgfault_upcall: %e", r);
  80135b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80135f:	c7 44 24 08 00 1a 80 	movl   $0x801a00,0x8(%esp)
  801366:	00 
  801367:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80136e:	00 
  80136f:	c7 04 24 34 1a 80 00 	movl   $0x801a34,(%esp)
  801376:	e8 19 ff ff ff       	call   801294 <_panic>
}
  80137b:	c9                   	leave  
  80137c:	c3                   	ret    
  80137d:	00 00                	add    %al,(%eax)
	...

00801380 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801380:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801381:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  801386:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801388:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// sub 4 from old esp
	movl 0x30(%esp), %eax
  80138b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80138f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801392:	89 44 24 30          	mov    %eax,0x30(%esp)
	// put old eip into the pre-reserved 4-byte space
	movl 0x28(%esp), %ebx
  801396:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80139a:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  80139c:	83 c4 08             	add    $0x8,%esp
	popal
  80139f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  8013a0:	83 c4 04             	add    $0x4,%esp
	popfl
  8013a3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8013a4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8013a5:	c3                   	ret    
	...

008013a8 <__udivdi3>:
  8013a8:	55                   	push   %ebp
  8013a9:	57                   	push   %edi
  8013aa:	56                   	push   %esi
  8013ab:	83 ec 10             	sub    $0x10,%esp
  8013ae:	8b 74 24 20          	mov    0x20(%esp),%esi
  8013b2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8013b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013ba:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8013be:	89 cd                	mov    %ecx,%ebp
  8013c0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	75 2c                	jne    8013f4 <__udivdi3+0x4c>
  8013c8:	39 f9                	cmp    %edi,%ecx
  8013ca:	77 68                	ja     801434 <__udivdi3+0x8c>
  8013cc:	85 c9                	test   %ecx,%ecx
  8013ce:	75 0b                	jne    8013db <__udivdi3+0x33>
  8013d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8013d5:	31 d2                	xor    %edx,%edx
  8013d7:	f7 f1                	div    %ecx
  8013d9:	89 c1                	mov    %eax,%ecx
  8013db:	31 d2                	xor    %edx,%edx
  8013dd:	89 f8                	mov    %edi,%eax
  8013df:	f7 f1                	div    %ecx
  8013e1:	89 c7                	mov    %eax,%edi
  8013e3:	89 f0                	mov    %esi,%eax
  8013e5:	f7 f1                	div    %ecx
  8013e7:	89 c6                	mov    %eax,%esi
  8013e9:	89 f0                	mov    %esi,%eax
  8013eb:	89 fa                	mov    %edi,%edx
  8013ed:	83 c4 10             	add    $0x10,%esp
  8013f0:	5e                   	pop    %esi
  8013f1:	5f                   	pop    %edi
  8013f2:	5d                   	pop    %ebp
  8013f3:	c3                   	ret    
  8013f4:	39 f8                	cmp    %edi,%eax
  8013f6:	77 2c                	ja     801424 <__udivdi3+0x7c>
  8013f8:	0f bd f0             	bsr    %eax,%esi
  8013fb:	83 f6 1f             	xor    $0x1f,%esi
  8013fe:	75 4c                	jne    80144c <__udivdi3+0xa4>
  801400:	39 f8                	cmp    %edi,%eax
  801402:	bf 00 00 00 00       	mov    $0x0,%edi
  801407:	72 0a                	jb     801413 <__udivdi3+0x6b>
  801409:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80140d:	0f 87 ad 00 00 00    	ja     8014c0 <__udivdi3+0x118>
  801413:	be 01 00 00 00       	mov    $0x1,%esi
  801418:	89 f0                	mov    %esi,%eax
  80141a:	89 fa                	mov    %edi,%edx
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	5e                   	pop    %esi
  801420:	5f                   	pop    %edi
  801421:	5d                   	pop    %ebp
  801422:	c3                   	ret    
  801423:	90                   	nop
  801424:	31 ff                	xor    %edi,%edi
  801426:	31 f6                	xor    %esi,%esi
  801428:	89 f0                	mov    %esi,%eax
  80142a:	89 fa                	mov    %edi,%edx
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	5e                   	pop    %esi
  801430:	5f                   	pop    %edi
  801431:	5d                   	pop    %ebp
  801432:	c3                   	ret    
  801433:	90                   	nop
  801434:	89 fa                	mov    %edi,%edx
  801436:	89 f0                	mov    %esi,%eax
  801438:	f7 f1                	div    %ecx
  80143a:	89 c6                	mov    %eax,%esi
  80143c:	31 ff                	xor    %edi,%edi
  80143e:	89 f0                	mov    %esi,%eax
  801440:	89 fa                	mov    %edi,%edx
  801442:	83 c4 10             	add    $0x10,%esp
  801445:	5e                   	pop    %esi
  801446:	5f                   	pop    %edi
  801447:	5d                   	pop    %ebp
  801448:	c3                   	ret    
  801449:	8d 76 00             	lea    0x0(%esi),%esi
  80144c:	89 f1                	mov    %esi,%ecx
  80144e:	d3 e0                	shl    %cl,%eax
  801450:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801454:	b8 20 00 00 00       	mov    $0x20,%eax
  801459:	29 f0                	sub    %esi,%eax
  80145b:	89 ea                	mov    %ebp,%edx
  80145d:	88 c1                	mov    %al,%cl
  80145f:	d3 ea                	shr    %cl,%edx
  801461:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801465:	09 ca                	or     %ecx,%edx
  801467:	89 54 24 08          	mov    %edx,0x8(%esp)
  80146b:	89 f1                	mov    %esi,%ecx
  80146d:	d3 e5                	shl    %cl,%ebp
  80146f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801473:	89 fd                	mov    %edi,%ebp
  801475:	88 c1                	mov    %al,%cl
  801477:	d3 ed                	shr    %cl,%ebp
  801479:	89 fa                	mov    %edi,%edx
  80147b:	89 f1                	mov    %esi,%ecx
  80147d:	d3 e2                	shl    %cl,%edx
  80147f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801483:	88 c1                	mov    %al,%cl
  801485:	d3 ef                	shr    %cl,%edi
  801487:	09 d7                	or     %edx,%edi
  801489:	89 f8                	mov    %edi,%eax
  80148b:	89 ea                	mov    %ebp,%edx
  80148d:	f7 74 24 08          	divl   0x8(%esp)
  801491:	89 d1                	mov    %edx,%ecx
  801493:	89 c7                	mov    %eax,%edi
  801495:	f7 64 24 0c          	mull   0xc(%esp)
  801499:	39 d1                	cmp    %edx,%ecx
  80149b:	72 17                	jb     8014b4 <__udivdi3+0x10c>
  80149d:	74 09                	je     8014a8 <__udivdi3+0x100>
  80149f:	89 fe                	mov    %edi,%esi
  8014a1:	31 ff                	xor    %edi,%edi
  8014a3:	e9 41 ff ff ff       	jmp    8013e9 <__udivdi3+0x41>
  8014a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014ac:	89 f1                	mov    %esi,%ecx
  8014ae:	d3 e2                	shl    %cl,%edx
  8014b0:	39 c2                	cmp    %eax,%edx
  8014b2:	73 eb                	jae    80149f <__udivdi3+0xf7>
  8014b4:	8d 77 ff             	lea    -0x1(%edi),%esi
  8014b7:	31 ff                	xor    %edi,%edi
  8014b9:	e9 2b ff ff ff       	jmp    8013e9 <__udivdi3+0x41>
  8014be:	66 90                	xchg   %ax,%ax
  8014c0:	31 f6                	xor    %esi,%esi
  8014c2:	e9 22 ff ff ff       	jmp    8013e9 <__udivdi3+0x41>
	...

008014c8 <__umoddi3>:
  8014c8:	55                   	push   %ebp
  8014c9:	57                   	push   %edi
  8014ca:	56                   	push   %esi
  8014cb:	83 ec 20             	sub    $0x20,%esp
  8014ce:	8b 44 24 30          	mov    0x30(%esp),%eax
  8014d2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8014d6:	89 44 24 14          	mov    %eax,0x14(%esp)
  8014da:	8b 74 24 34          	mov    0x34(%esp),%esi
  8014de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8014e2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8014e6:	89 c7                	mov    %eax,%edi
  8014e8:	89 f2                	mov    %esi,%edx
  8014ea:	85 ed                	test   %ebp,%ebp
  8014ec:	75 16                	jne    801504 <__umoddi3+0x3c>
  8014ee:	39 f1                	cmp    %esi,%ecx
  8014f0:	0f 86 a6 00 00 00    	jbe    80159c <__umoddi3+0xd4>
  8014f6:	f7 f1                	div    %ecx
  8014f8:	89 d0                	mov    %edx,%eax
  8014fa:	31 d2                	xor    %edx,%edx
  8014fc:	83 c4 20             	add    $0x20,%esp
  8014ff:	5e                   	pop    %esi
  801500:	5f                   	pop    %edi
  801501:	5d                   	pop    %ebp
  801502:	c3                   	ret    
  801503:	90                   	nop
  801504:	39 f5                	cmp    %esi,%ebp
  801506:	0f 87 ac 00 00 00    	ja     8015b8 <__umoddi3+0xf0>
  80150c:	0f bd c5             	bsr    %ebp,%eax
  80150f:	83 f0 1f             	xor    $0x1f,%eax
  801512:	89 44 24 10          	mov    %eax,0x10(%esp)
  801516:	0f 84 a8 00 00 00    	je     8015c4 <__umoddi3+0xfc>
  80151c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801520:	d3 e5                	shl    %cl,%ebp
  801522:	bf 20 00 00 00       	mov    $0x20,%edi
  801527:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80152b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80152f:	89 f9                	mov    %edi,%ecx
  801531:	d3 e8                	shr    %cl,%eax
  801533:	09 e8                	or     %ebp,%eax
  801535:	89 44 24 18          	mov    %eax,0x18(%esp)
  801539:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80153d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801541:	d3 e0                	shl    %cl,%eax
  801543:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801547:	89 f2                	mov    %esi,%edx
  801549:	d3 e2                	shl    %cl,%edx
  80154b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80154f:	d3 e0                	shl    %cl,%eax
  801551:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801555:	8b 44 24 14          	mov    0x14(%esp),%eax
  801559:	89 f9                	mov    %edi,%ecx
  80155b:	d3 e8                	shr    %cl,%eax
  80155d:	09 d0                	or     %edx,%eax
  80155f:	d3 ee                	shr    %cl,%esi
  801561:	89 f2                	mov    %esi,%edx
  801563:	f7 74 24 18          	divl   0x18(%esp)
  801567:	89 d6                	mov    %edx,%esi
  801569:	f7 64 24 0c          	mull   0xc(%esp)
  80156d:	89 c5                	mov    %eax,%ebp
  80156f:	89 d1                	mov    %edx,%ecx
  801571:	39 d6                	cmp    %edx,%esi
  801573:	72 67                	jb     8015dc <__umoddi3+0x114>
  801575:	74 75                	je     8015ec <__umoddi3+0x124>
  801577:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80157b:	29 e8                	sub    %ebp,%eax
  80157d:	19 ce                	sbb    %ecx,%esi
  80157f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801583:	d3 e8                	shr    %cl,%eax
  801585:	89 f2                	mov    %esi,%edx
  801587:	89 f9                	mov    %edi,%ecx
  801589:	d3 e2                	shl    %cl,%edx
  80158b:	09 d0                	or     %edx,%eax
  80158d:	89 f2                	mov    %esi,%edx
  80158f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801593:	d3 ea                	shr    %cl,%edx
  801595:	83 c4 20             	add    $0x20,%esp
  801598:	5e                   	pop    %esi
  801599:	5f                   	pop    %edi
  80159a:	5d                   	pop    %ebp
  80159b:	c3                   	ret    
  80159c:	85 c9                	test   %ecx,%ecx
  80159e:	75 0b                	jne    8015ab <__umoddi3+0xe3>
  8015a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8015a5:	31 d2                	xor    %edx,%edx
  8015a7:	f7 f1                	div    %ecx
  8015a9:	89 c1                	mov    %eax,%ecx
  8015ab:	89 f0                	mov    %esi,%eax
  8015ad:	31 d2                	xor    %edx,%edx
  8015af:	f7 f1                	div    %ecx
  8015b1:	89 f8                	mov    %edi,%eax
  8015b3:	e9 3e ff ff ff       	jmp    8014f6 <__umoddi3+0x2e>
  8015b8:	89 f2                	mov    %esi,%edx
  8015ba:	83 c4 20             	add    $0x20,%esp
  8015bd:	5e                   	pop    %esi
  8015be:	5f                   	pop    %edi
  8015bf:	5d                   	pop    %ebp
  8015c0:	c3                   	ret    
  8015c1:	8d 76 00             	lea    0x0(%esi),%esi
  8015c4:	39 f5                	cmp    %esi,%ebp
  8015c6:	72 04                	jb     8015cc <__umoddi3+0x104>
  8015c8:	39 f9                	cmp    %edi,%ecx
  8015ca:	77 06                	ja     8015d2 <__umoddi3+0x10a>
  8015cc:	89 f2                	mov    %esi,%edx
  8015ce:	29 cf                	sub    %ecx,%edi
  8015d0:	19 ea                	sbb    %ebp,%edx
  8015d2:	89 f8                	mov    %edi,%eax
  8015d4:	83 c4 20             	add    $0x20,%esp
  8015d7:	5e                   	pop    %esi
  8015d8:	5f                   	pop    %edi
  8015d9:	5d                   	pop    %ebp
  8015da:	c3                   	ret    
  8015db:	90                   	nop
  8015dc:	89 d1                	mov    %edx,%ecx
  8015de:	89 c5                	mov    %eax,%ebp
  8015e0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8015e4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8015e8:	eb 8d                	jmp    801577 <__umoddi3+0xaf>
  8015ea:	66 90                	xchg   %ax,%ax
  8015ec:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8015f0:	72 ea                	jb     8015dc <__umoddi3+0x114>
  8015f2:	89 f1                	mov    %esi,%ecx
  8015f4:	eb 81                	jmp    801577 <__umoddi3+0xaf>
