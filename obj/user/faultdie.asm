
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 57 00 00 00       	call   800088 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003d:	8b 50 04             	mov    0x4(%eax),%edx
  800040:	83 e2 07             	and    $0x7,%edx
  800043:	89 54 24 08          	mov    %edx,0x8(%esp)
  800047:	8b 00                	mov    (%eax),%eax
  800049:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004d:	c7 04 24 c0 10 80 00 	movl   $0x8010c0,(%esp)
  800054:	e8 33 01 00 00       	call   80018c <cprintf>
	sys_env_destroy(sys_getenvid());
  800059:	e8 91 0a 00 00       	call   800aef <sys_getenvid>
  80005e:	89 04 24             	mov    %eax,(%esp)
  800061:	e8 37 0a 00 00       	call   800a9d <sys_env_destroy>
}
  800066:	c9                   	leave  
  800067:	c3                   	ret    

00800068 <umain>:

void
umain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80006e:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  800075:	e8 ca 0c 00 00       	call   800d44 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  80007a:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800081:	00 00 00 
}
  800084:	c9                   	leave  
  800085:	c3                   	ret    
	...

00800088 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	56                   	push   %esi
  80008c:	53                   	push   %ebx
  80008d:	83 ec 10             	sub    $0x10,%esp
  800090:	8b 75 08             	mov    0x8(%ebp),%esi
  800093:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800096:	e8 54 0a 00 00       	call   800aef <sys_getenvid>
  80009b:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a0:	8d 14 80             	lea    (%eax,%eax,4),%edx
  8000a3:	8d 14 90             	lea    (%eax,%edx,4),%edx
  8000a6:	8d 04 50             	lea    (%eax,%edx,2),%eax
  8000a9:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  8000b0:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b5:	85 f6                	test   %esi,%esi
  8000b7:	7e 07                	jle    8000c0 <libmain+0x38>
		binaryname = argv[0];
  8000b9:	8b 03                	mov    (%ebx),%eax
  8000bb:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c4:	89 34 24             	mov    %esi,(%esp)
  8000c7:	e8 9c ff ff ff       	call   800068 <umain>

	// exit gracefully
	exit();
  8000cc:	e8 07 00 00 00       	call   8000d8 <exit>
}
  8000d1:	83 c4 10             	add    $0x10,%esp
  8000d4:	5b                   	pop    %ebx
  8000d5:	5e                   	pop    %esi
  8000d6:	5d                   	pop    %ebp
  8000d7:	c3                   	ret    

008000d8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e5:	e8 b3 09 00 00       	call   800a9d <sys_env_destroy>
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 14             	sub    $0x14,%esp
  8000f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000f6:	8b 03                	mov    (%ebx),%eax
  8000f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000ff:	40                   	inc    %eax
  800100:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800102:	3d ff 00 00 00       	cmp    $0xff,%eax
  800107:	75 19                	jne    800122 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800109:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800110:	00 
  800111:	8d 43 08             	lea    0x8(%ebx),%eax
  800114:	89 04 24             	mov    %eax,(%esp)
  800117:	e8 44 09 00 00       	call   800a60 <sys_cputs>
		b->idx = 0;
  80011c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800122:	ff 43 04             	incl   0x4(%ebx)
}
  800125:	83 c4 14             	add    $0x14,%esp
  800128:	5b                   	pop    %ebx
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    

0080012b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800134:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80013b:	00 00 00 
	b.cnt = 0;
  80013e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800145:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800148:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80014f:	8b 45 08             	mov    0x8(%ebp),%eax
  800152:	89 44 24 08          	mov    %eax,0x8(%esp)
  800156:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800160:	c7 04 24 ec 00 80 00 	movl   $0x8000ec,(%esp)
  800167:	e8 b4 01 00 00       	call   800320 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800172:	89 44 24 04          	mov    %eax,0x4(%esp)
  800176:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017c:	89 04 24             	mov    %eax,(%esp)
  80017f:	e8 dc 08 00 00       	call   800a60 <sys_cputs>

	return b.cnt;
}
  800184:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800192:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	8b 45 08             	mov    0x8(%ebp),%eax
  80019c:	89 04 24             	mov    %eax,(%esp)
  80019f:	e8 87 ff ff ff       	call   80012b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a4:	c9                   	leave  
  8001a5:	c3                   	ret    
	...

008001a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 3c             	sub    $0x3c,%esp
  8001b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001b4:	89 d7                	mov    %edx,%edi
  8001b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001c5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	75 08                	jne    8001d4 <printnum+0x2c>
  8001cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001cf:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d2:	77 57                	ja     80022b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001d8:	4b                   	dec    %ebx
  8001d9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001e8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001ec:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001f3:	00 
  8001f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001f7:	89 04 24             	mov    %eax,(%esp)
  8001fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800201:	e8 52 0c 00 00       	call   800e58 <__udivdi3>
  800206:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80020a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80020e:	89 04 24             	mov    %eax,(%esp)
  800211:	89 54 24 04          	mov    %edx,0x4(%esp)
  800215:	89 fa                	mov    %edi,%edx
  800217:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80021a:	e8 89 ff ff ff       	call   8001a8 <printnum>
  80021f:	eb 0f                	jmp    800230 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800221:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800225:	89 34 24             	mov    %esi,(%esp)
  800228:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022b:	4b                   	dec    %ebx
  80022c:	85 db                	test   %ebx,%ebx
  80022e:	7f f1                	jg     800221 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800230:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800234:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800238:	8b 45 10             	mov    0x10(%ebp),%eax
  80023b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800246:	00 
  800247:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024a:	89 04 24             	mov    %eax,(%esp)
  80024d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800250:	89 44 24 04          	mov    %eax,0x4(%esp)
  800254:	e8 1f 0d 00 00       	call   800f78 <__umoddi3>
  800259:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80025d:	0f be 80 e6 10 80 00 	movsbl 0x8010e6(%eax),%eax
  800264:	89 04 24             	mov    %eax,(%esp)
  800267:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80026a:	83 c4 3c             	add    $0x3c,%esp
  80026d:	5b                   	pop    %ebx
  80026e:	5e                   	pop    %esi
  80026f:	5f                   	pop    %edi
  800270:	5d                   	pop    %ebp
  800271:	c3                   	ret    

00800272 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800275:	83 fa 01             	cmp    $0x1,%edx
  800278:	7e 0e                	jle    800288 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 02                	mov    (%edx),%eax
  800283:	8b 52 04             	mov    0x4(%edx),%edx
  800286:	eb 22                	jmp    8002aa <getuint+0x38>
	else if (lflag)
  800288:	85 d2                	test   %edx,%edx
  80028a:	74 10                	je     80029c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028c:	8b 10                	mov    (%eax),%edx
  80028e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800291:	89 08                	mov    %ecx,(%eax)
  800293:	8b 02                	mov    (%edx),%eax
  800295:	ba 00 00 00 00       	mov    $0x0,%edx
  80029a:	eb 0e                	jmp    8002aa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029c:	8b 10                	mov    (%eax),%edx
  80029e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a1:	89 08                	mov    %ecx,(%eax)
  8002a3:	8b 02                	mov    (%edx),%eax
  8002a5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002aa:	5d                   	pop    %ebp
  8002ab:	c3                   	ret    

008002ac <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002af:	83 fa 01             	cmp    $0x1,%edx
  8002b2:	7e 0e                	jle    8002c2 <getint+0x16>
		return va_arg(*ap, long long);
  8002b4:	8b 10                	mov    (%eax),%edx
  8002b6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 02                	mov    (%edx),%eax
  8002bd:	8b 52 04             	mov    0x4(%edx),%edx
  8002c0:	eb 1a                	jmp    8002dc <getint+0x30>
	else if (lflag)
  8002c2:	85 d2                	test   %edx,%edx
  8002c4:	74 0c                	je     8002d2 <getint+0x26>
		return va_arg(*ap, long);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	99                   	cltd   
  8002d0:	eb 0a                	jmp    8002dc <getint+0x30>
	else
		return va_arg(*ap, int);
  8002d2:	8b 10                	mov    (%eax),%edx
  8002d4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d7:	89 08                	mov    %ecx,(%eax)
  8002d9:	8b 02                	mov    (%edx),%eax
  8002db:	99                   	cltd   
}
  8002dc:	5d                   	pop    %ebp
  8002dd:	c3                   	ret    

008002de <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002e7:	8b 10                	mov    (%eax),%edx
  8002e9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ec:	73 08                	jae    8002f6 <sprintputch+0x18>
		*b->buf++ = ch;
  8002ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f1:	88 0a                	mov    %cl,(%edx)
  8002f3:	42                   	inc    %edx
  8002f4:	89 10                	mov    %edx,(%eax)
}
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002fe:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800301:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800305:	8b 45 10             	mov    0x10(%ebp),%eax
  800308:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80030f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800313:	8b 45 08             	mov    0x8(%ebp),%eax
  800316:	89 04 24             	mov    %eax,(%esp)
  800319:	e8 02 00 00 00       	call   800320 <vprintfmt>
	va_end(ap);
}
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 4c             	sub    $0x4c,%esp
  800329:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032c:	8b 75 10             	mov    0x10(%ebp),%esi
  80032f:	eb 12                	jmp    800343 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800331:	85 c0                	test   %eax,%eax
  800333:	0f 84 40 03 00 00    	je     800679 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800339:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80033d:	89 04 24             	mov    %eax,(%esp)
  800340:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800343:	0f b6 06             	movzbl (%esi),%eax
  800346:	46                   	inc    %esi
  800347:	83 f8 25             	cmp    $0x25,%eax
  80034a:	75 e5                	jne    800331 <vprintfmt+0x11>
  80034c:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800350:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800357:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80035c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800363:	ba 00 00 00 00       	mov    $0x0,%edx
  800368:	eb 26                	jmp    800390 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80036d:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800371:	eb 1d                	jmp    800390 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800373:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800376:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80037a:	eb 14                	jmp    800390 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80037f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800386:	eb 08                	jmp    800390 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800388:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80038b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800390:	0f b6 06             	movzbl (%esi),%eax
  800393:	8d 4e 01             	lea    0x1(%esi),%ecx
  800396:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800399:	8a 0e                	mov    (%esi),%cl
  80039b:	83 e9 23             	sub    $0x23,%ecx
  80039e:	80 f9 55             	cmp    $0x55,%cl
  8003a1:	0f 87 b6 02 00 00    	ja     80065d <vprintfmt+0x33d>
  8003a7:	0f b6 c9             	movzbl %cl,%ecx
  8003aa:	ff 24 8d a0 11 80 00 	jmp    *0x8011a0(,%ecx,4)
  8003b1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003b4:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b9:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  8003bc:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  8003c0:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003c3:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003c6:	83 f9 09             	cmp    $0x9,%ecx
  8003c9:	77 2a                	ja     8003f5 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cb:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003cc:	eb eb                	jmp    8003b9 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d1:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d7:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003dc:	eb 17                	jmp    8003f5 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003de:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e2:	78 98                	js     80037c <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003e7:	eb a7                	jmp    800390 <vprintfmt+0x70>
  8003e9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ec:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003f3:	eb 9b                	jmp    800390 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003f5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f9:	79 95                	jns    800390 <vprintfmt+0x70>
  8003fb:	eb 8b                	jmp    800388 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003fd:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800401:	eb 8d                	jmp    800390 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800403:	8b 45 14             	mov    0x14(%ebp),%eax
  800406:	8d 50 04             	lea    0x4(%eax),%edx
  800409:	89 55 14             	mov    %edx,0x14(%ebp)
  80040c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800410:	8b 00                	mov    (%eax),%eax
  800412:	89 04 24             	mov    %eax,(%esp)
  800415:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80041b:	e9 23 ff ff ff       	jmp    800343 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	8d 50 04             	lea    0x4(%eax),%edx
  800426:	89 55 14             	mov    %edx,0x14(%ebp)
  800429:	8b 00                	mov    (%eax),%eax
  80042b:	85 c0                	test   %eax,%eax
  80042d:	79 02                	jns    800431 <vprintfmt+0x111>
  80042f:	f7 d8                	neg    %eax
  800431:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800433:	83 f8 09             	cmp    $0x9,%eax
  800436:	7f 0b                	jg     800443 <vprintfmt+0x123>
  800438:	8b 04 85 00 13 80 00 	mov    0x801300(,%eax,4),%eax
  80043f:	85 c0                	test   %eax,%eax
  800441:	75 23                	jne    800466 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800443:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800447:	c7 44 24 08 fe 10 80 	movl   $0x8010fe,0x8(%esp)
  80044e:	00 
  80044f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800453:	8b 45 08             	mov    0x8(%ebp),%eax
  800456:	89 04 24             	mov    %eax,(%esp)
  800459:	e8 9a fe ff ff       	call   8002f8 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800461:	e9 dd fe ff ff       	jmp    800343 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800466:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046a:	c7 44 24 08 07 11 80 	movl   $0x801107,0x8(%esp)
  800471:	00 
  800472:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800476:	8b 55 08             	mov    0x8(%ebp),%edx
  800479:	89 14 24             	mov    %edx,(%esp)
  80047c:	e8 77 fe ff ff       	call   8002f8 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800484:	e9 ba fe ff ff       	jmp    800343 <vprintfmt+0x23>
  800489:	89 f9                	mov    %edi,%ecx
  80048b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80048e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800491:	8b 45 14             	mov    0x14(%ebp),%eax
  800494:	8d 50 04             	lea    0x4(%eax),%edx
  800497:	89 55 14             	mov    %edx,0x14(%ebp)
  80049a:	8b 30                	mov    (%eax),%esi
  80049c:	85 f6                	test   %esi,%esi
  80049e:	75 05                	jne    8004a5 <vprintfmt+0x185>
				p = "(null)";
  8004a0:	be f7 10 80 00       	mov    $0x8010f7,%esi
			if (width > 0 && padc != '-')
  8004a5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004a9:	0f 8e 84 00 00 00    	jle    800533 <vprintfmt+0x213>
  8004af:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004b3:	74 7e                	je     800533 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004b9:	89 34 24             	mov    %esi,(%esp)
  8004bc:	e8 5d 02 00 00       	call   80071e <strnlen>
  8004c1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004c4:	29 c2                	sub    %eax,%edx
  8004c6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004c9:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8004cd:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004d0:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004d3:	89 de                	mov    %ebx,%esi
  8004d5:	89 d3                	mov    %edx,%ebx
  8004d7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d9:	eb 0b                	jmp    8004e6 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004df:	89 3c 24             	mov    %edi,(%esp)
  8004e2:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e5:	4b                   	dec    %ebx
  8004e6:	85 db                	test   %ebx,%ebx
  8004e8:	7f f1                	jg     8004db <vprintfmt+0x1bb>
  8004ea:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004ed:	89 f3                	mov    %esi,%ebx
  8004ef:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004f5:	85 c0                	test   %eax,%eax
  8004f7:	79 05                	jns    8004fe <vprintfmt+0x1de>
  8004f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800501:	29 c2                	sub    %eax,%edx
  800503:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800506:	eb 2b                	jmp    800533 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800508:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80050c:	74 18                	je     800526 <vprintfmt+0x206>
  80050e:	8d 50 e0             	lea    -0x20(%eax),%edx
  800511:	83 fa 5e             	cmp    $0x5e,%edx
  800514:	76 10                	jbe    800526 <vprintfmt+0x206>
					putch('?', putdat);
  800516:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800521:	ff 55 08             	call   *0x8(%ebp)
  800524:	eb 0a                	jmp    800530 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800526:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052a:	89 04 24             	mov    %eax,(%esp)
  80052d:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800530:	ff 4d e4             	decl   -0x1c(%ebp)
  800533:	0f be 06             	movsbl (%esi),%eax
  800536:	46                   	inc    %esi
  800537:	85 c0                	test   %eax,%eax
  800539:	74 21                	je     80055c <vprintfmt+0x23c>
  80053b:	85 ff                	test   %edi,%edi
  80053d:	78 c9                	js     800508 <vprintfmt+0x1e8>
  80053f:	4f                   	dec    %edi
  800540:	79 c6                	jns    800508 <vprintfmt+0x1e8>
  800542:	8b 7d 08             	mov    0x8(%ebp),%edi
  800545:	89 de                	mov    %ebx,%esi
  800547:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80054a:	eb 18                	jmp    800564 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800550:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800557:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800559:	4b                   	dec    %ebx
  80055a:	eb 08                	jmp    800564 <vprintfmt+0x244>
  80055c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80055f:	89 de                	mov    %ebx,%esi
  800561:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800564:	85 db                	test   %ebx,%ebx
  800566:	7f e4                	jg     80054c <vprintfmt+0x22c>
  800568:	89 7d 08             	mov    %edi,0x8(%ebp)
  80056b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800570:	e9 ce fd ff ff       	jmp    800343 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800575:	8d 45 14             	lea    0x14(%ebp),%eax
  800578:	e8 2f fd ff ff       	call   8002ac <getint>
  80057d:	89 c6                	mov    %eax,%esi
  80057f:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800581:	85 d2                	test   %edx,%edx
  800583:	78 07                	js     80058c <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800585:	be 0a 00 00 00       	mov    $0xa,%esi
  80058a:	eb 7e                	jmp    80060a <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80058c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800590:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800597:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80059a:	89 f0                	mov    %esi,%eax
  80059c:	89 fa                	mov    %edi,%edx
  80059e:	f7 d8                	neg    %eax
  8005a0:	83 d2 00             	adc    $0x0,%edx
  8005a3:	f7 da                	neg    %edx
			}
			base = 10;
  8005a5:	be 0a 00 00 00       	mov    $0xa,%esi
  8005aa:	eb 5e                	jmp    80060a <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8005af:	e8 be fc ff ff       	call   800272 <getuint>
			base = 10;
  8005b4:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8005b9:	eb 4f                	jmp    80060a <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005be:	e8 af fc ff ff       	call   800272 <getuint>
			base = 8;
  8005c3:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8005c8:	eb 40                	jmp    80060a <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ce:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005d5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005dc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005e3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005ef:	8b 00                	mov    (%eax),%eax
  8005f1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005f6:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8005fb:	eb 0d                	jmp    80060a <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005fd:	8d 45 14             	lea    0x14(%ebp),%eax
  800600:	e8 6d fc ff ff       	call   800272 <getuint>
			base = 16;
  800605:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80060a:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  80060e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800612:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800615:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800619:	89 74 24 08          	mov    %esi,0x8(%esp)
  80061d:	89 04 24             	mov    %eax,(%esp)
  800620:	89 54 24 04          	mov    %edx,0x4(%esp)
  800624:	89 da                	mov    %ebx,%edx
  800626:	8b 45 08             	mov    0x8(%ebp),%eax
  800629:	e8 7a fb ff ff       	call   8001a8 <printnum>
			break;
  80062e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800631:	e9 0d fd ff ff       	jmp    800343 <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  800636:	8d 45 14             	lea    0x14(%ebp),%eax
  800639:	e8 6e fc ff ff       	call   8002ac <getint>
  80063e:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800643:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  800646:	e9 f8 fc ff ff       	jmp    800343 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80064b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064f:	89 04 24             	mov    %eax,(%esp)
  800652:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800655:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800658:	e9 e6 fc ff ff       	jmp    800343 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80065d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800661:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800668:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80066b:	eb 01                	jmp    80066e <vprintfmt+0x34e>
  80066d:	4e                   	dec    %esi
  80066e:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800672:	75 f9                	jne    80066d <vprintfmt+0x34d>
  800674:	e9 ca fc ff ff       	jmp    800343 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800679:	83 c4 4c             	add    $0x4c,%esp
  80067c:	5b                   	pop    %ebx
  80067d:	5e                   	pop    %esi
  80067e:	5f                   	pop    %edi
  80067f:	5d                   	pop    %ebp
  800680:	c3                   	ret    

00800681 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800681:	55                   	push   %ebp
  800682:	89 e5                	mov    %esp,%ebp
  800684:	83 ec 28             	sub    $0x28,%esp
  800687:	8b 45 08             	mov    0x8(%ebp),%eax
  80068a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80068d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800690:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800694:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800697:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80069e:	85 c0                	test   %eax,%eax
  8006a0:	74 30                	je     8006d2 <vsnprintf+0x51>
  8006a2:	85 d2                	test   %edx,%edx
  8006a4:	7e 33                	jle    8006d9 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8006b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006bb:	c7 04 24 de 02 80 00 	movl   $0x8002de,(%esp)
  8006c2:	e8 59 fc ff ff       	call   800320 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ca:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d0:	eb 0c                	jmp    8006de <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d7:	eb 05                	jmp    8006de <vsnprintf+0x5d>
  8006d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006de:	c9                   	leave  
  8006df:	c3                   	ret    

008006e0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fe:	89 04 24             	mov    %eax,(%esp)
  800701:	e8 7b ff ff ff       	call   800681 <vsnprintf>
	va_end(ap);

	return rc;
}
  800706:	c9                   	leave  
  800707:	c3                   	ret    

00800708 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80070e:	b8 00 00 00 00       	mov    $0x0,%eax
  800713:	eb 01                	jmp    800716 <strlen+0xe>
		n++;
  800715:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800716:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80071a:	75 f9                	jne    800715 <strlen+0xd>
		n++;
	return n;
}
  80071c:	5d                   	pop    %ebp
  80071d:	c3                   	ret    

0080071e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800724:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800727:	b8 00 00 00 00       	mov    $0x0,%eax
  80072c:	eb 01                	jmp    80072f <strnlen+0x11>
		n++;
  80072e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072f:	39 d0                	cmp    %edx,%eax
  800731:	74 06                	je     800739 <strnlen+0x1b>
  800733:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800737:	75 f5                	jne    80072e <strnlen+0x10>
		n++;
	return n;
}
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	53                   	push   %ebx
  80073f:	8b 45 08             	mov    0x8(%ebp),%eax
  800742:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800745:	ba 00 00 00 00       	mov    $0x0,%edx
  80074a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80074d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800750:	42                   	inc    %edx
  800751:	84 c9                	test   %cl,%cl
  800753:	75 f5                	jne    80074a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800755:	5b                   	pop    %ebx
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	53                   	push   %ebx
  80075c:	83 ec 08             	sub    $0x8,%esp
  80075f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800762:	89 1c 24             	mov    %ebx,(%esp)
  800765:	e8 9e ff ff ff       	call   800708 <strlen>
	strcpy(dst + len, src);
  80076a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800771:	01 d8                	add    %ebx,%eax
  800773:	89 04 24             	mov    %eax,(%esp)
  800776:	e8 c0 ff ff ff       	call   80073b <strcpy>
	return dst;
}
  80077b:	89 d8                	mov    %ebx,%eax
  80077d:	83 c4 08             	add    $0x8,%esp
  800780:	5b                   	pop    %ebx
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	56                   	push   %esi
  800787:	53                   	push   %ebx
  800788:	8b 45 08             	mov    0x8(%ebp),%eax
  80078b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800791:	b9 00 00 00 00       	mov    $0x0,%ecx
  800796:	eb 0c                	jmp    8007a4 <strncpy+0x21>
		*dst++ = *src;
  800798:	8a 1a                	mov    (%edx),%bl
  80079a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80079d:	80 3a 01             	cmpb   $0x1,(%edx)
  8007a0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a3:	41                   	inc    %ecx
  8007a4:	39 f1                	cmp    %esi,%ecx
  8007a6:	75 f0                	jne    800798 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a8:	5b                   	pop    %ebx
  8007a9:	5e                   	pop    %esi
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	56                   	push   %esi
  8007b0:	53                   	push   %ebx
  8007b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ba:	85 d2                	test   %edx,%edx
  8007bc:	75 0a                	jne    8007c8 <strlcpy+0x1c>
  8007be:	89 f0                	mov    %esi,%eax
  8007c0:	eb 1a                	jmp    8007dc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c2:	88 18                	mov    %bl,(%eax)
  8007c4:	40                   	inc    %eax
  8007c5:	41                   	inc    %ecx
  8007c6:	eb 02                	jmp    8007ca <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007ca:	4a                   	dec    %edx
  8007cb:	74 0a                	je     8007d7 <strlcpy+0x2b>
  8007cd:	8a 19                	mov    (%ecx),%bl
  8007cf:	84 db                	test   %bl,%bl
  8007d1:	75 ef                	jne    8007c2 <strlcpy+0x16>
  8007d3:	89 c2                	mov    %eax,%edx
  8007d5:	eb 02                	jmp    8007d9 <strlcpy+0x2d>
  8007d7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007d9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007dc:	29 f0                	sub    %esi,%eax
}
  8007de:	5b                   	pop    %ebx
  8007df:	5e                   	pop    %esi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007eb:	eb 02                	jmp    8007ef <strcmp+0xd>
		p++, q++;
  8007ed:	41                   	inc    %ecx
  8007ee:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007ef:	8a 01                	mov    (%ecx),%al
  8007f1:	84 c0                	test   %al,%al
  8007f3:	74 04                	je     8007f9 <strcmp+0x17>
  8007f5:	3a 02                	cmp    (%edx),%al
  8007f7:	74 f4                	je     8007ed <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f9:	0f b6 c0             	movzbl %al,%eax
  8007fc:	0f b6 12             	movzbl (%edx),%edx
  8007ff:	29 d0                	sub    %edx,%eax
}
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	53                   	push   %ebx
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800810:	eb 03                	jmp    800815 <strncmp+0x12>
		n--, p++, q++;
  800812:	4a                   	dec    %edx
  800813:	40                   	inc    %eax
  800814:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800815:	85 d2                	test   %edx,%edx
  800817:	74 14                	je     80082d <strncmp+0x2a>
  800819:	8a 18                	mov    (%eax),%bl
  80081b:	84 db                	test   %bl,%bl
  80081d:	74 04                	je     800823 <strncmp+0x20>
  80081f:	3a 19                	cmp    (%ecx),%bl
  800821:	74 ef                	je     800812 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800823:	0f b6 00             	movzbl (%eax),%eax
  800826:	0f b6 11             	movzbl (%ecx),%edx
  800829:	29 d0                	sub    %edx,%eax
  80082b:	eb 05                	jmp    800832 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80082d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800832:	5b                   	pop    %ebx
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80083e:	eb 05                	jmp    800845 <strchr+0x10>
		if (*s == c)
  800840:	38 ca                	cmp    %cl,%dl
  800842:	74 0c                	je     800850 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800844:	40                   	inc    %eax
  800845:	8a 10                	mov    (%eax),%dl
  800847:	84 d2                	test   %dl,%dl
  800849:	75 f5                	jne    800840 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80084b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 45 08             	mov    0x8(%ebp),%eax
  800858:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80085b:	eb 05                	jmp    800862 <strfind+0x10>
		if (*s == c)
  80085d:	38 ca                	cmp    %cl,%dl
  80085f:	74 07                	je     800868 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800861:	40                   	inc    %eax
  800862:	8a 10                	mov    (%eax),%dl
  800864:	84 d2                	test   %dl,%dl
  800866:	75 f5                	jne    80085d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	57                   	push   %edi
  80086e:	56                   	push   %esi
  80086f:	53                   	push   %ebx
  800870:	8b 7d 08             	mov    0x8(%ebp),%edi
  800873:	8b 45 0c             	mov    0xc(%ebp),%eax
  800876:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800879:	85 c9                	test   %ecx,%ecx
  80087b:	74 30                	je     8008ad <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80087d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800883:	75 25                	jne    8008aa <memset+0x40>
  800885:	f6 c1 03             	test   $0x3,%cl
  800888:	75 20                	jne    8008aa <memset+0x40>
		c &= 0xFF;
  80088a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80088d:	89 d3                	mov    %edx,%ebx
  80088f:	c1 e3 08             	shl    $0x8,%ebx
  800892:	89 d6                	mov    %edx,%esi
  800894:	c1 e6 18             	shl    $0x18,%esi
  800897:	89 d0                	mov    %edx,%eax
  800899:	c1 e0 10             	shl    $0x10,%eax
  80089c:	09 f0                	or     %esi,%eax
  80089e:	09 d0                	or     %edx,%eax
  8008a0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008a2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008a5:	fc                   	cld    
  8008a6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a8:	eb 03                	jmp    8008ad <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008aa:	fc                   	cld    
  8008ab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ad:	89 f8                	mov    %edi,%eax
  8008af:	5b                   	pop    %ebx
  8008b0:	5e                   	pop    %esi
  8008b1:	5f                   	pop    %edi
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	57                   	push   %edi
  8008b8:	56                   	push   %esi
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c2:	39 c6                	cmp    %eax,%esi
  8008c4:	73 34                	jae    8008fa <memmove+0x46>
  8008c6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c9:	39 d0                	cmp    %edx,%eax
  8008cb:	73 2d                	jae    8008fa <memmove+0x46>
		s += n;
		d += n;
  8008cd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d0:	f6 c2 03             	test   $0x3,%dl
  8008d3:	75 1b                	jne    8008f0 <memmove+0x3c>
  8008d5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008db:	75 13                	jne    8008f0 <memmove+0x3c>
  8008dd:	f6 c1 03             	test   $0x3,%cl
  8008e0:	75 0e                	jne    8008f0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008e2:	83 ef 04             	sub    $0x4,%edi
  8008e5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008eb:	fd                   	std    
  8008ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ee:	eb 07                	jmp    8008f7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008f0:	4f                   	dec    %edi
  8008f1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008f4:	fd                   	std    
  8008f5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f7:	fc                   	cld    
  8008f8:	eb 20                	jmp    80091a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800900:	75 13                	jne    800915 <memmove+0x61>
  800902:	a8 03                	test   $0x3,%al
  800904:	75 0f                	jne    800915 <memmove+0x61>
  800906:	f6 c1 03             	test   $0x3,%cl
  800909:	75 0a                	jne    800915 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80090b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80090e:	89 c7                	mov    %eax,%edi
  800910:	fc                   	cld    
  800911:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800913:	eb 05                	jmp    80091a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800915:	89 c7                	mov    %eax,%edi
  800917:	fc                   	cld    
  800918:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80091a:	5e                   	pop    %esi
  80091b:	5f                   	pop    %edi
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800924:	8b 45 10             	mov    0x10(%ebp),%eax
  800927:	89 44 24 08          	mov    %eax,0x8(%esp)
  80092b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	89 04 24             	mov    %eax,(%esp)
  800938:	e8 77 ff ff ff       	call   8008b4 <memmove>
}
  80093d:	c9                   	leave  
  80093e:	c3                   	ret    

0080093f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	57                   	push   %edi
  800943:	56                   	push   %esi
  800944:	53                   	push   %ebx
  800945:	8b 7d 08             	mov    0x8(%ebp),%edi
  800948:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094e:	ba 00 00 00 00       	mov    $0x0,%edx
  800953:	eb 16                	jmp    80096b <memcmp+0x2c>
		if (*s1 != *s2)
  800955:	8a 04 17             	mov    (%edi,%edx,1),%al
  800958:	42                   	inc    %edx
  800959:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80095d:	38 c8                	cmp    %cl,%al
  80095f:	74 0a                	je     80096b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800961:	0f b6 c0             	movzbl %al,%eax
  800964:	0f b6 c9             	movzbl %cl,%ecx
  800967:	29 c8                	sub    %ecx,%eax
  800969:	eb 09                	jmp    800974 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096b:	39 da                	cmp    %ebx,%edx
  80096d:	75 e6                	jne    800955 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80096f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800974:	5b                   	pop    %ebx
  800975:	5e                   	pop    %esi
  800976:	5f                   	pop    %edi
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800982:	89 c2                	mov    %eax,%edx
  800984:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800987:	eb 05                	jmp    80098e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800989:	38 08                	cmp    %cl,(%eax)
  80098b:	74 05                	je     800992 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098d:	40                   	inc    %eax
  80098e:	39 d0                	cmp    %edx,%eax
  800990:	72 f7                	jb     800989 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	57                   	push   %edi
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 55 08             	mov    0x8(%ebp),%edx
  80099d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a0:	eb 01                	jmp    8009a3 <strtol+0xf>
		s++;
  8009a2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a3:	8a 02                	mov    (%edx),%al
  8009a5:	3c 20                	cmp    $0x20,%al
  8009a7:	74 f9                	je     8009a2 <strtol+0xe>
  8009a9:	3c 09                	cmp    $0x9,%al
  8009ab:	74 f5                	je     8009a2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ad:	3c 2b                	cmp    $0x2b,%al
  8009af:	75 08                	jne    8009b9 <strtol+0x25>
		s++;
  8009b1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b7:	eb 13                	jmp    8009cc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b9:	3c 2d                	cmp    $0x2d,%al
  8009bb:	75 0a                	jne    8009c7 <strtol+0x33>
		s++, neg = 1;
  8009bd:	8d 52 01             	lea    0x1(%edx),%edx
  8009c0:	bf 01 00 00 00       	mov    $0x1,%edi
  8009c5:	eb 05                	jmp    8009cc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009cc:	85 db                	test   %ebx,%ebx
  8009ce:	74 05                	je     8009d5 <strtol+0x41>
  8009d0:	83 fb 10             	cmp    $0x10,%ebx
  8009d3:	75 28                	jne    8009fd <strtol+0x69>
  8009d5:	8a 02                	mov    (%edx),%al
  8009d7:	3c 30                	cmp    $0x30,%al
  8009d9:	75 10                	jne    8009eb <strtol+0x57>
  8009db:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009df:	75 0a                	jne    8009eb <strtol+0x57>
		s += 2, base = 16;
  8009e1:	83 c2 02             	add    $0x2,%edx
  8009e4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009e9:	eb 12                	jmp    8009fd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009eb:	85 db                	test   %ebx,%ebx
  8009ed:	75 0e                	jne    8009fd <strtol+0x69>
  8009ef:	3c 30                	cmp    $0x30,%al
  8009f1:	75 05                	jne    8009f8 <strtol+0x64>
		s++, base = 8;
  8009f3:	42                   	inc    %edx
  8009f4:	b3 08                	mov    $0x8,%bl
  8009f6:	eb 05                	jmp    8009fd <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009f8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800a02:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a04:	8a 0a                	mov    (%edx),%cl
  800a06:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a09:	80 fb 09             	cmp    $0x9,%bl
  800a0c:	77 08                	ja     800a16 <strtol+0x82>
			dig = *s - '0';
  800a0e:	0f be c9             	movsbl %cl,%ecx
  800a11:	83 e9 30             	sub    $0x30,%ecx
  800a14:	eb 1e                	jmp    800a34 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a16:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a19:	80 fb 19             	cmp    $0x19,%bl
  800a1c:	77 08                	ja     800a26 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a1e:	0f be c9             	movsbl %cl,%ecx
  800a21:	83 e9 57             	sub    $0x57,%ecx
  800a24:	eb 0e                	jmp    800a34 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a26:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a29:	80 fb 19             	cmp    $0x19,%bl
  800a2c:	77 12                	ja     800a40 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a2e:	0f be c9             	movsbl %cl,%ecx
  800a31:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a34:	39 f1                	cmp    %esi,%ecx
  800a36:	7d 0c                	jge    800a44 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a38:	42                   	inc    %edx
  800a39:	0f af c6             	imul   %esi,%eax
  800a3c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a3e:	eb c4                	jmp    800a04 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a40:	89 c1                	mov    %eax,%ecx
  800a42:	eb 02                	jmp    800a46 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a44:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a4a:	74 05                	je     800a51 <strtol+0xbd>
		*endptr = (char *) s;
  800a4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a4f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a51:	85 ff                	test   %edi,%edi
  800a53:	74 04                	je     800a59 <strtol+0xc5>
  800a55:	89 c8                	mov    %ecx,%eax
  800a57:	f7 d8                	neg    %eax
}
  800a59:	5b                   	pop    %ebx
  800a5a:	5e                   	pop    %esi
  800a5b:	5f                   	pop    %edi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    
	...

00800a60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	57                   	push   %edi
  800a64:	56                   	push   %esi
  800a65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a71:	89 c3                	mov    %eax,%ebx
  800a73:	89 c7                	mov    %eax,%edi
  800a75:	89 c6                	mov    %eax,%esi
  800a77:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a84:	ba 00 00 00 00       	mov    $0x0,%edx
  800a89:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8e:	89 d1                	mov    %edx,%ecx
  800a90:	89 d3                	mov    %edx,%ebx
  800a92:	89 d7                	mov    %edx,%edi
  800a94:	89 d6                	mov    %edx,%esi
  800a96:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aab:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab3:	89 cb                	mov    %ecx,%ebx
  800ab5:	89 cf                	mov    %ecx,%edi
  800ab7:	89 ce                	mov    %ecx,%esi
  800ab9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800abb:	85 c0                	test   %eax,%eax
  800abd:	7e 28                	jle    800ae7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ac3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800aca:	00 
  800acb:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800ad2:	00 
  800ad3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ada:	00 
  800adb:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800ae2:	e8 19 03 00 00       	call   800e00 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ae7:	83 c4 2c             	add    $0x2c,%esp
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5f                   	pop    %edi
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	57                   	push   %edi
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af5:	ba 00 00 00 00       	mov    $0x0,%edx
  800afa:	b8 02 00 00 00       	mov    $0x2,%eax
  800aff:	89 d1                	mov    %edx,%ecx
  800b01:	89 d3                	mov    %edx,%ebx
  800b03:	89 d7                	mov    %edx,%edi
  800b05:	89 d6                	mov    %edx,%esi
  800b07:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <sys_yield>:

void
sys_yield(void)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	57                   	push   %edi
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b14:	ba 00 00 00 00       	mov    $0x0,%edx
  800b19:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b1e:	89 d1                	mov    %edx,%ecx
  800b20:	89 d3                	mov    %edx,%ebx
  800b22:	89 d7                	mov    %edx,%edi
  800b24:	89 d6                	mov    %edx,%esi
  800b26:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b36:	be 00 00 00 00       	mov    $0x0,%esi
  800b3b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	89 f7                	mov    %esi,%edi
  800b4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	7e 28                	jle    800b79 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b55:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b5c:	00 
  800b5d:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800b64:	00 
  800b65:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b6c:	00 
  800b6d:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800b74:	e8 87 02 00 00       	call   800e00 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b79:	83 c4 2c             	add    $0x2c,%esp
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8a:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8f:	8b 75 18             	mov    0x18(%ebp),%esi
  800b92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba0:	85 c0                	test   %eax,%eax
  800ba2:	7e 28                	jle    800bcc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ba8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800baf:	00 
  800bb0:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800bb7:	00 
  800bb8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bbf:	00 
  800bc0:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800bc7:	e8 34 02 00 00       	call   800e00 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bcc:	83 c4 2c             	add    $0x2c,%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
  800bda:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be2:	b8 06 00 00 00       	mov    $0x6,%eax
  800be7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bea:	8b 55 08             	mov    0x8(%ebp),%edx
  800bed:	89 df                	mov    %ebx,%edi
  800bef:	89 de                	mov    %ebx,%esi
  800bf1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf3:	85 c0                	test   %eax,%eax
  800bf5:	7e 28                	jle    800c1f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bfb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c02:	00 
  800c03:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800c0a:	00 
  800c0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c12:	00 
  800c13:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800c1a:	e8 e1 01 00 00       	call   800e00 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c1f:	83 c4 2c             	add    $0x2c,%esp
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
  800c2d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c35:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c40:	89 df                	mov    %ebx,%edi
  800c42:	89 de                	mov    %ebx,%esi
  800c44:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c46:	85 c0                	test   %eax,%eax
  800c48:	7e 28                	jle    800c72 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c4e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c55:	00 
  800c56:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800c5d:	00 
  800c5e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c65:	00 
  800c66:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800c6d:	e8 8e 01 00 00       	call   800e00 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c72:	83 c4 2c             	add    $0x2c,%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c88:	b8 09 00 00 00       	mov    $0x9,%eax
  800c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	89 df                	mov    %ebx,%edi
  800c95:	89 de                	mov    %ebx,%esi
  800c97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 28                	jle    800cc5 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ca8:	00 
  800ca9:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800cb0:	00 
  800cb1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb8:	00 
  800cb9:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800cc0:	e8 3b 01 00 00       	call   800e00 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc5:	83 c4 2c             	add    $0x2c,%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd3:	be 00 00 00 00       	mov    $0x0,%esi
  800cd8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cdd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
  800cf6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d03:	8b 55 08             	mov    0x8(%ebp),%edx
  800d06:	89 cb                	mov    %ecx,%ebx
  800d08:	89 cf                	mov    %ecx,%edi
  800d0a:	89 ce                	mov    %ecx,%esi
  800d0c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	7e 28                	jle    800d3a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d12:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d16:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d1d:	00 
  800d1e:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800d25:	00 
  800d26:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2d:	00 
  800d2e:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800d35:	e8 c6 00 00 00       	call   800e00 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d3a:	83 c4 2c             	add    $0x2c,%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    
	...

00800d44 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d4a:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800d51:	75 40                	jne    800d93 <set_pgfault_handler+0x4f>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
  800d53:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800d5a:	00 
  800d5b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800d62:	ee 
  800d63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d6a:	e8 be fd ff ff       	call   800b2d <sys_page_alloc>
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	79 20                	jns    800d93 <set_pgfault_handler+0x4f>
            panic("set_pgfault_handler: sys_page_alloc: %e", r);
  800d73:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d77:	c7 44 24 08 54 13 80 	movl   $0x801354,0x8(%esp)
  800d7e:	00 
  800d7f:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800d86:	00 
  800d87:	c7 04 24 b0 13 80 00 	movl   $0x8013b0,(%esp)
  800d8e:	e8 6d 00 00 00       	call   800e00 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d93:	8b 45 08             	mov    0x8(%ebp),%eax
  800d96:	a3 0c 20 80 00       	mov    %eax,0x80200c
    if ((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0 )
  800d9b:	c7 44 24 04 d8 0d 80 	movl   $0x800dd8,0x4(%esp)
  800da2:	00 
  800da3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800daa:	e8 cb fe ff ff       	call   800c7a <sys_env_set_pgfault_upcall>
  800daf:	85 c0                	test   %eax,%eax
  800db1:	79 20                	jns    800dd3 <set_pgfault_handler+0x8f>
        panic("set_pgfault_handler: sys_env_set_pgfault_upcall: %e", r);
  800db3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800db7:	c7 44 24 08 7c 13 80 	movl   $0x80137c,0x8(%esp)
  800dbe:	00 
  800dbf:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800dc6:	00 
  800dc7:	c7 04 24 b0 13 80 00 	movl   $0x8013b0,(%esp)
  800dce:	e8 2d 00 00 00       	call   800e00 <_panic>
}
  800dd3:	c9                   	leave  
  800dd4:	c3                   	ret    
  800dd5:	00 00                	add    %al,(%eax)
	...

00800dd8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dd8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800dd9:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  800dde:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800de0:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// sub 4 from old esp
	movl 0x30(%esp), %eax
  800de3:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  800de7:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  800dea:	89 44 24 30          	mov    %eax,0x30(%esp)
	// put old eip into the pre-reserved 4-byte space
	movl 0x28(%esp), %ebx
  800dee:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800df2:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  800df4:	83 c4 08             	add    $0x8,%esp
	popal
  800df7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  800df8:	83 c4 04             	add    $0x4,%esp
	popfl
  800dfb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800dfc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800dfd:	c3                   	ret    
	...

00800e00 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	56                   	push   %esi
  800e04:	53                   	push   %ebx
  800e05:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800e08:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e0b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800e11:	e8 d9 fc ff ff       	call   800aef <sys_getenvid>
  800e16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e19:	89 54 24 10          	mov    %edx,0x10(%esp)
  800e1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e20:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e24:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e28:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e2c:	c7 04 24 c0 13 80 00 	movl   $0x8013c0,(%esp)
  800e33:	e8 54 f3 ff ff       	call   80018c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e38:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e3c:	8b 45 10             	mov    0x10(%ebp),%eax
  800e3f:	89 04 24             	mov    %eax,(%esp)
  800e42:	e8 e4 f2 ff ff       	call   80012b <vcprintf>
	cprintf("\n");
  800e47:	c7 04 24 da 10 80 00 	movl   $0x8010da,(%esp)
  800e4e:	e8 39 f3 ff ff       	call   80018c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e53:	cc                   	int3   
  800e54:	eb fd                	jmp    800e53 <_panic+0x53>
	...

00800e58 <__udivdi3>:
  800e58:	55                   	push   %ebp
  800e59:	57                   	push   %edi
  800e5a:	56                   	push   %esi
  800e5b:	83 ec 10             	sub    $0x10,%esp
  800e5e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e62:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800e66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e6a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800e6e:	89 cd                	mov    %ecx,%ebp
  800e70:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800e74:	85 c0                	test   %eax,%eax
  800e76:	75 2c                	jne    800ea4 <__udivdi3+0x4c>
  800e78:	39 f9                	cmp    %edi,%ecx
  800e7a:	77 68                	ja     800ee4 <__udivdi3+0x8c>
  800e7c:	85 c9                	test   %ecx,%ecx
  800e7e:	75 0b                	jne    800e8b <__udivdi3+0x33>
  800e80:	b8 01 00 00 00       	mov    $0x1,%eax
  800e85:	31 d2                	xor    %edx,%edx
  800e87:	f7 f1                	div    %ecx
  800e89:	89 c1                	mov    %eax,%ecx
  800e8b:	31 d2                	xor    %edx,%edx
  800e8d:	89 f8                	mov    %edi,%eax
  800e8f:	f7 f1                	div    %ecx
  800e91:	89 c7                	mov    %eax,%edi
  800e93:	89 f0                	mov    %esi,%eax
  800e95:	f7 f1                	div    %ecx
  800e97:	89 c6                	mov    %eax,%esi
  800e99:	89 f0                	mov    %esi,%eax
  800e9b:	89 fa                	mov    %edi,%edx
  800e9d:	83 c4 10             	add    $0x10,%esp
  800ea0:	5e                   	pop    %esi
  800ea1:	5f                   	pop    %edi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    
  800ea4:	39 f8                	cmp    %edi,%eax
  800ea6:	77 2c                	ja     800ed4 <__udivdi3+0x7c>
  800ea8:	0f bd f0             	bsr    %eax,%esi
  800eab:	83 f6 1f             	xor    $0x1f,%esi
  800eae:	75 4c                	jne    800efc <__udivdi3+0xa4>
  800eb0:	39 f8                	cmp    %edi,%eax
  800eb2:	bf 00 00 00 00       	mov    $0x0,%edi
  800eb7:	72 0a                	jb     800ec3 <__udivdi3+0x6b>
  800eb9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800ebd:	0f 87 ad 00 00 00    	ja     800f70 <__udivdi3+0x118>
  800ec3:	be 01 00 00 00       	mov    $0x1,%esi
  800ec8:	89 f0                	mov    %esi,%eax
  800eca:	89 fa                	mov    %edi,%edx
  800ecc:	83 c4 10             	add    $0x10,%esp
  800ecf:	5e                   	pop    %esi
  800ed0:	5f                   	pop    %edi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    
  800ed3:	90                   	nop
  800ed4:	31 ff                	xor    %edi,%edi
  800ed6:	31 f6                	xor    %esi,%esi
  800ed8:	89 f0                	mov    %esi,%eax
  800eda:	89 fa                	mov    %edi,%edx
  800edc:	83 c4 10             	add    $0x10,%esp
  800edf:	5e                   	pop    %esi
  800ee0:	5f                   	pop    %edi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    
  800ee3:	90                   	nop
  800ee4:	89 fa                	mov    %edi,%edx
  800ee6:	89 f0                	mov    %esi,%eax
  800ee8:	f7 f1                	div    %ecx
  800eea:	89 c6                	mov    %eax,%esi
  800eec:	31 ff                	xor    %edi,%edi
  800eee:	89 f0                	mov    %esi,%eax
  800ef0:	89 fa                	mov    %edi,%edx
  800ef2:	83 c4 10             	add    $0x10,%esp
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    
  800ef9:	8d 76 00             	lea    0x0(%esi),%esi
  800efc:	89 f1                	mov    %esi,%ecx
  800efe:	d3 e0                	shl    %cl,%eax
  800f00:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f04:	b8 20 00 00 00       	mov    $0x20,%eax
  800f09:	29 f0                	sub    %esi,%eax
  800f0b:	89 ea                	mov    %ebp,%edx
  800f0d:	88 c1                	mov    %al,%cl
  800f0f:	d3 ea                	shr    %cl,%edx
  800f11:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800f15:	09 ca                	or     %ecx,%edx
  800f17:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f1b:	89 f1                	mov    %esi,%ecx
  800f1d:	d3 e5                	shl    %cl,%ebp
  800f1f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800f23:	89 fd                	mov    %edi,%ebp
  800f25:	88 c1                	mov    %al,%cl
  800f27:	d3 ed                	shr    %cl,%ebp
  800f29:	89 fa                	mov    %edi,%edx
  800f2b:	89 f1                	mov    %esi,%ecx
  800f2d:	d3 e2                	shl    %cl,%edx
  800f2f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f33:	88 c1                	mov    %al,%cl
  800f35:	d3 ef                	shr    %cl,%edi
  800f37:	09 d7                	or     %edx,%edi
  800f39:	89 f8                	mov    %edi,%eax
  800f3b:	89 ea                	mov    %ebp,%edx
  800f3d:	f7 74 24 08          	divl   0x8(%esp)
  800f41:	89 d1                	mov    %edx,%ecx
  800f43:	89 c7                	mov    %eax,%edi
  800f45:	f7 64 24 0c          	mull   0xc(%esp)
  800f49:	39 d1                	cmp    %edx,%ecx
  800f4b:	72 17                	jb     800f64 <__udivdi3+0x10c>
  800f4d:	74 09                	je     800f58 <__udivdi3+0x100>
  800f4f:	89 fe                	mov    %edi,%esi
  800f51:	31 ff                	xor    %edi,%edi
  800f53:	e9 41 ff ff ff       	jmp    800e99 <__udivdi3+0x41>
  800f58:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f5c:	89 f1                	mov    %esi,%ecx
  800f5e:	d3 e2                	shl    %cl,%edx
  800f60:	39 c2                	cmp    %eax,%edx
  800f62:	73 eb                	jae    800f4f <__udivdi3+0xf7>
  800f64:	8d 77 ff             	lea    -0x1(%edi),%esi
  800f67:	31 ff                	xor    %edi,%edi
  800f69:	e9 2b ff ff ff       	jmp    800e99 <__udivdi3+0x41>
  800f6e:	66 90                	xchg   %ax,%ax
  800f70:	31 f6                	xor    %esi,%esi
  800f72:	e9 22 ff ff ff       	jmp    800e99 <__udivdi3+0x41>
	...

00800f78 <__umoddi3>:
  800f78:	55                   	push   %ebp
  800f79:	57                   	push   %edi
  800f7a:	56                   	push   %esi
  800f7b:	83 ec 20             	sub    $0x20,%esp
  800f7e:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f82:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800f86:	89 44 24 14          	mov    %eax,0x14(%esp)
  800f8a:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f8e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f92:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f96:	89 c7                	mov    %eax,%edi
  800f98:	89 f2                	mov    %esi,%edx
  800f9a:	85 ed                	test   %ebp,%ebp
  800f9c:	75 16                	jne    800fb4 <__umoddi3+0x3c>
  800f9e:	39 f1                	cmp    %esi,%ecx
  800fa0:	0f 86 a6 00 00 00    	jbe    80104c <__umoddi3+0xd4>
  800fa6:	f7 f1                	div    %ecx
  800fa8:	89 d0                	mov    %edx,%eax
  800faa:	31 d2                	xor    %edx,%edx
  800fac:	83 c4 20             	add    $0x20,%esp
  800faf:	5e                   	pop    %esi
  800fb0:	5f                   	pop    %edi
  800fb1:	5d                   	pop    %ebp
  800fb2:	c3                   	ret    
  800fb3:	90                   	nop
  800fb4:	39 f5                	cmp    %esi,%ebp
  800fb6:	0f 87 ac 00 00 00    	ja     801068 <__umoddi3+0xf0>
  800fbc:	0f bd c5             	bsr    %ebp,%eax
  800fbf:	83 f0 1f             	xor    $0x1f,%eax
  800fc2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc6:	0f 84 a8 00 00 00    	je     801074 <__umoddi3+0xfc>
  800fcc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fd0:	d3 e5                	shl    %cl,%ebp
  800fd2:	bf 20 00 00 00       	mov    $0x20,%edi
  800fd7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800fdb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fdf:	89 f9                	mov    %edi,%ecx
  800fe1:	d3 e8                	shr    %cl,%eax
  800fe3:	09 e8                	or     %ebp,%eax
  800fe5:	89 44 24 18          	mov    %eax,0x18(%esp)
  800fe9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fed:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ff1:	d3 e0                	shl    %cl,%eax
  800ff3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ff7:	89 f2                	mov    %esi,%edx
  800ff9:	d3 e2                	shl    %cl,%edx
  800ffb:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fff:	d3 e0                	shl    %cl,%eax
  801001:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801005:	8b 44 24 14          	mov    0x14(%esp),%eax
  801009:	89 f9                	mov    %edi,%ecx
  80100b:	d3 e8                	shr    %cl,%eax
  80100d:	09 d0                	or     %edx,%eax
  80100f:	d3 ee                	shr    %cl,%esi
  801011:	89 f2                	mov    %esi,%edx
  801013:	f7 74 24 18          	divl   0x18(%esp)
  801017:	89 d6                	mov    %edx,%esi
  801019:	f7 64 24 0c          	mull   0xc(%esp)
  80101d:	89 c5                	mov    %eax,%ebp
  80101f:	89 d1                	mov    %edx,%ecx
  801021:	39 d6                	cmp    %edx,%esi
  801023:	72 67                	jb     80108c <__umoddi3+0x114>
  801025:	74 75                	je     80109c <__umoddi3+0x124>
  801027:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80102b:	29 e8                	sub    %ebp,%eax
  80102d:	19 ce                	sbb    %ecx,%esi
  80102f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801033:	d3 e8                	shr    %cl,%eax
  801035:	89 f2                	mov    %esi,%edx
  801037:	89 f9                	mov    %edi,%ecx
  801039:	d3 e2                	shl    %cl,%edx
  80103b:	09 d0                	or     %edx,%eax
  80103d:	89 f2                	mov    %esi,%edx
  80103f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801043:	d3 ea                	shr    %cl,%edx
  801045:	83 c4 20             	add    $0x20,%esp
  801048:	5e                   	pop    %esi
  801049:	5f                   	pop    %edi
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    
  80104c:	85 c9                	test   %ecx,%ecx
  80104e:	75 0b                	jne    80105b <__umoddi3+0xe3>
  801050:	b8 01 00 00 00       	mov    $0x1,%eax
  801055:	31 d2                	xor    %edx,%edx
  801057:	f7 f1                	div    %ecx
  801059:	89 c1                	mov    %eax,%ecx
  80105b:	89 f0                	mov    %esi,%eax
  80105d:	31 d2                	xor    %edx,%edx
  80105f:	f7 f1                	div    %ecx
  801061:	89 f8                	mov    %edi,%eax
  801063:	e9 3e ff ff ff       	jmp    800fa6 <__umoddi3+0x2e>
  801068:	89 f2                	mov    %esi,%edx
  80106a:	83 c4 20             	add    $0x20,%esp
  80106d:	5e                   	pop    %esi
  80106e:	5f                   	pop    %edi
  80106f:	5d                   	pop    %ebp
  801070:	c3                   	ret    
  801071:	8d 76 00             	lea    0x0(%esi),%esi
  801074:	39 f5                	cmp    %esi,%ebp
  801076:	72 04                	jb     80107c <__umoddi3+0x104>
  801078:	39 f9                	cmp    %edi,%ecx
  80107a:	77 06                	ja     801082 <__umoddi3+0x10a>
  80107c:	89 f2                	mov    %esi,%edx
  80107e:	29 cf                	sub    %ecx,%edi
  801080:	19 ea                	sbb    %ebp,%edx
  801082:	89 f8                	mov    %edi,%eax
  801084:	83 c4 20             	add    $0x20,%esp
  801087:	5e                   	pop    %esi
  801088:	5f                   	pop    %edi
  801089:	5d                   	pop    %ebp
  80108a:	c3                   	ret    
  80108b:	90                   	nop
  80108c:	89 d1                	mov    %edx,%ecx
  80108e:	89 c5                	mov    %eax,%ebp
  801090:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801094:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801098:	eb 8d                	jmp    801027 <__umoddi3+0xaf>
  80109a:	66 90                	xchg   %ax,%ax
  80109c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8010a0:	72 ea                	jb     80108c <__umoddi3+0x114>
  8010a2:	89 f1                	mov    %esi,%ecx
  8010a4:	eb 81                	jmp    801027 <__umoddi3+0xaf>
