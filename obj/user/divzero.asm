
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 33 00 00 00       	call   800064 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  80003a:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	99                   	cltd   
  80004f:	f7 f9                	idiv   %ecx
  800051:	89 44 24 04          	mov    %eax,0x4(%esp)
  800055:	c7 04 24 e0 0f 80 00 	movl   $0x800fe0,(%esp)
  80005c:	e8 07 01 00 00       	call   800168 <cprintf>
}
  800061:	c9                   	leave  
  800062:	c3                   	ret    
	...

00800064 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800064:	55                   	push   %ebp
  800065:	89 e5                	mov    %esp,%ebp
  800067:	56                   	push   %esi
  800068:	53                   	push   %ebx
  800069:	83 ec 10             	sub    $0x10,%esp
  80006c:	8b 75 08             	mov    0x8(%ebp),%esi
  80006f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800072:	e8 54 0a 00 00       	call   800acb <sys_getenvid>
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	8d 14 80             	lea    (%eax,%eax,4),%edx
  80007f:	8d 14 90             	lea    (%eax,%edx,4),%edx
  800082:	8d 04 50             	lea    (%eax,%edx,2),%eax
  800085:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  80008c:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800091:	85 f6                	test   %esi,%esi
  800093:	7e 07                	jle    80009c <libmain+0x38>
		binaryname = argv[0];
  800095:	8b 03                	mov    (%ebx),%eax
  800097:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a0:	89 34 24             	mov    %esi,(%esp)
  8000a3:	e8 8c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a8:	e8 07 00 00 00       	call   8000b4 <exit>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	5b                   	pop    %ebx
  8000b1:	5e                   	pop    %esi
  8000b2:	5d                   	pop    %ebp
  8000b3:	c3                   	ret    

008000b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c1:	e8 b3 09 00 00       	call   800a79 <sys_env_destroy>
}
  8000c6:	c9                   	leave  
  8000c7:	c3                   	ret    

008000c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	53                   	push   %ebx
  8000cc:	83 ec 14             	sub    $0x14,%esp
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d2:	8b 03                	mov    (%ebx),%eax
  8000d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000db:	40                   	inc    %eax
  8000dc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e3:	75 19                	jne    8000fe <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000e5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000ec:	00 
  8000ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f0:	89 04 24             	mov    %eax,(%esp)
  8000f3:	e8 44 09 00 00       	call   800a3c <sys_cputs>
		b->idx = 0;
  8000f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000fe:	ff 43 04             	incl   0x4(%ebx)
}
  800101:	83 c4 14             	add    $0x14,%esp
  800104:	5b                   	pop    %ebx
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800110:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800117:	00 00 00 
	b.cnt = 0;
  80011a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800121:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800124:	8b 45 0c             	mov    0xc(%ebp),%eax
  800127:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012b:	8b 45 08             	mov    0x8(%ebp),%eax
  80012e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800132:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800138:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013c:	c7 04 24 c8 00 80 00 	movl   $0x8000c8,(%esp)
  800143:	e8 b4 01 00 00       	call   8002fc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800148:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800152:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800158:	89 04 24             	mov    %eax,(%esp)
  80015b:	e8 dc 08 00 00       	call   800a3c <sys_cputs>

	return b.cnt;
}
  800160:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800171:	89 44 24 04          	mov    %eax,0x4(%esp)
  800175:	8b 45 08             	mov    0x8(%ebp),%eax
  800178:	89 04 24             	mov    %eax,(%esp)
  80017b:	e8 87 ff ff ff       	call   800107 <vcprintf>
	va_end(ap);

	return cnt;
}
  800180:	c9                   	leave  
  800181:	c3                   	ret    
	...

00800184 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	83 ec 3c             	sub    $0x3c,%esp
  80018d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800190:	89 d7                	mov    %edx,%edi
  800192:	8b 45 08             	mov    0x8(%ebp),%eax
  800195:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800198:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a4:	85 c0                	test   %eax,%eax
  8001a6:	75 08                	jne    8001b0 <printnum+0x2c>
  8001a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ae:	77 57                	ja     800207 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001b4:	4b                   	dec    %ebx
  8001b5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001c4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001cf:	00 
  8001d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001d3:	89 04 24             	mov    %eax,(%esp)
  8001d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001dd:	e8 96 0b 00 00       	call   800d78 <__udivdi3>
  8001e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001ea:	89 04 24             	mov    %eax,(%esp)
  8001ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f1:	89 fa                	mov    %edi,%edx
  8001f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001f6:	e8 89 ff ff ff       	call   800184 <printnum>
  8001fb:	eb 0f                	jmp    80020c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800201:	89 34 24             	mov    %esi,(%esp)
  800204:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800207:	4b                   	dec    %ebx
  800208:	85 db                	test   %ebx,%ebx
  80020a:	7f f1                	jg     8001fd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80020c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800210:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800214:	8b 45 10             	mov    0x10(%ebp),%eax
  800217:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800222:	00 
  800223:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800226:	89 04 24             	mov    %eax,(%esp)
  800229:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80022c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800230:	e8 63 0c 00 00       	call   800e98 <__umoddi3>
  800235:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800239:	0f be 80 f8 0f 80 00 	movsbl 0x800ff8(%eax),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800246:	83 c4 3c             	add    $0x3c,%esp
  800249:	5b                   	pop    %ebx
  80024a:	5e                   	pop    %esi
  80024b:	5f                   	pop    %edi
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800251:	83 fa 01             	cmp    $0x1,%edx
  800254:	7e 0e                	jle    800264 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800256:	8b 10                	mov    (%eax),%edx
  800258:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025b:	89 08                	mov    %ecx,(%eax)
  80025d:	8b 02                	mov    (%edx),%eax
  80025f:	8b 52 04             	mov    0x4(%edx),%edx
  800262:	eb 22                	jmp    800286 <getuint+0x38>
	else if (lflag)
  800264:	85 d2                	test   %edx,%edx
  800266:	74 10                	je     800278 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800268:	8b 10                	mov    (%eax),%edx
  80026a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026d:	89 08                	mov    %ecx,(%eax)
  80026f:	8b 02                	mov    (%edx),%eax
  800271:	ba 00 00 00 00       	mov    $0x0,%edx
  800276:	eb 0e                	jmp    800286 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800278:	8b 10                	mov    (%eax),%edx
  80027a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027d:	89 08                	mov    %ecx,(%eax)
  80027f:	8b 02                	mov    (%edx),%eax
  800281:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800286:	5d                   	pop    %ebp
  800287:	c3                   	ret    

00800288 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80028b:	83 fa 01             	cmp    $0x1,%edx
  80028e:	7e 0e                	jle    80029e <getint+0x16>
		return va_arg(*ap, long long);
  800290:	8b 10                	mov    (%eax),%edx
  800292:	8d 4a 08             	lea    0x8(%edx),%ecx
  800295:	89 08                	mov    %ecx,(%eax)
  800297:	8b 02                	mov    (%edx),%eax
  800299:	8b 52 04             	mov    0x4(%edx),%edx
  80029c:	eb 1a                	jmp    8002b8 <getint+0x30>
	else if (lflag)
  80029e:	85 d2                	test   %edx,%edx
  8002a0:	74 0c                	je     8002ae <getint+0x26>
		return va_arg(*ap, long);
  8002a2:	8b 10                	mov    (%eax),%edx
  8002a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a7:	89 08                	mov    %ecx,(%eax)
  8002a9:	8b 02                	mov    (%edx),%eax
  8002ab:	99                   	cltd   
  8002ac:	eb 0a                	jmp    8002b8 <getint+0x30>
	else
		return va_arg(*ap, int);
  8002ae:	8b 10                	mov    (%eax),%edx
  8002b0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b3:	89 08                	mov    %ecx,(%eax)
  8002b5:	8b 02                	mov    (%edx),%eax
  8002b7:	99                   	cltd   
}
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002c3:	8b 10                	mov    (%eax),%edx
  8002c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c8:	73 08                	jae    8002d2 <sprintputch+0x18>
		*b->buf++ = ch;
  8002ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002cd:	88 0a                	mov    %cl,(%edx)
  8002cf:	42                   	inc    %edx
  8002d0:	89 10                	mov    %edx,(%eax)
}
  8002d2:	5d                   	pop    %ebp
  8002d3:	c3                   	ret    

008002d4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002da:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f2:	89 04 24             	mov    %eax,(%esp)
  8002f5:	e8 02 00 00 00       	call   8002fc <vprintfmt>
	va_end(ap);
}
  8002fa:	c9                   	leave  
  8002fb:	c3                   	ret    

008002fc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	57                   	push   %edi
  800300:	56                   	push   %esi
  800301:	53                   	push   %ebx
  800302:	83 ec 4c             	sub    $0x4c,%esp
  800305:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800308:	8b 75 10             	mov    0x10(%ebp),%esi
  80030b:	eb 12                	jmp    80031f <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80030d:	85 c0                	test   %eax,%eax
  80030f:	0f 84 40 03 00 00    	je     800655 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800315:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800319:	89 04 24             	mov    %eax,(%esp)
  80031c:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80031f:	0f b6 06             	movzbl (%esi),%eax
  800322:	46                   	inc    %esi
  800323:	83 f8 25             	cmp    $0x25,%eax
  800326:	75 e5                	jne    80030d <vprintfmt+0x11>
  800328:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80032c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800333:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800338:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80033f:	ba 00 00 00 00       	mov    $0x0,%edx
  800344:	eb 26                	jmp    80036c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800346:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800349:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80034d:	eb 1d                	jmp    80036c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800352:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800356:	eb 14                	jmp    80036c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800358:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80035b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800362:	eb 08                	jmp    80036c <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800364:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800367:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	0f b6 06             	movzbl (%esi),%eax
  80036f:	8d 4e 01             	lea    0x1(%esi),%ecx
  800372:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800375:	8a 0e                	mov    (%esi),%cl
  800377:	83 e9 23             	sub    $0x23,%ecx
  80037a:	80 f9 55             	cmp    $0x55,%cl
  80037d:	0f 87 b6 02 00 00    	ja     800639 <vprintfmt+0x33d>
  800383:	0f b6 c9             	movzbl %cl,%ecx
  800386:	ff 24 8d c0 10 80 00 	jmp    *0x8010c0(,%ecx,4)
  80038d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800390:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800395:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800398:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  80039c:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80039f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003a2:	83 f9 09             	cmp    $0x9,%ecx
  8003a5:	77 2a                	ja     8003d1 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a7:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a8:	eb eb                	jmp    800395 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ad:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003b3:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b8:	eb 17                	jmp    8003d1 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003ba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003be:	78 98                	js     800358 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003c3:	eb a7                	jmp    80036c <vprintfmt+0x70>
  8003c5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003c8:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003cf:	eb 9b                	jmp    80036c <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003d1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d5:	79 95                	jns    80036c <vprintfmt+0x70>
  8003d7:	eb 8b                	jmp    800364 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d9:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003dd:	eb 8d                	jmp    80036c <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003df:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e2:	8d 50 04             	lea    0x4(%eax),%edx
  8003e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ec:	8b 00                	mov    (%eax),%eax
  8003ee:	89 04 24             	mov    %eax,(%esp)
  8003f1:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f7:	e9 23 ff ff ff       	jmp    80031f <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ff:	8d 50 04             	lea    0x4(%eax),%edx
  800402:	89 55 14             	mov    %edx,0x14(%ebp)
  800405:	8b 00                	mov    (%eax),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	79 02                	jns    80040d <vprintfmt+0x111>
  80040b:	f7 d8                	neg    %eax
  80040d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040f:	83 f8 09             	cmp    $0x9,%eax
  800412:	7f 0b                	jg     80041f <vprintfmt+0x123>
  800414:	8b 04 85 20 12 80 00 	mov    0x801220(,%eax,4),%eax
  80041b:	85 c0                	test   %eax,%eax
  80041d:	75 23                	jne    800442 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80041f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800423:	c7 44 24 08 10 10 80 	movl   $0x801010,0x8(%esp)
  80042a:	00 
  80042b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042f:	8b 45 08             	mov    0x8(%ebp),%eax
  800432:	89 04 24             	mov    %eax,(%esp)
  800435:	e8 9a fe ff ff       	call   8002d4 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043d:	e9 dd fe ff ff       	jmp    80031f <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800442:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800446:	c7 44 24 08 19 10 80 	movl   $0x801019,0x8(%esp)
  80044d:	00 
  80044e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800452:	8b 55 08             	mov    0x8(%ebp),%edx
  800455:	89 14 24             	mov    %edx,(%esp)
  800458:	e8 77 fe ff ff       	call   8002d4 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800460:	e9 ba fe ff ff       	jmp    80031f <vprintfmt+0x23>
  800465:	89 f9                	mov    %edi,%ecx
  800467:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80046a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80046d:	8b 45 14             	mov    0x14(%ebp),%eax
  800470:	8d 50 04             	lea    0x4(%eax),%edx
  800473:	89 55 14             	mov    %edx,0x14(%ebp)
  800476:	8b 30                	mov    (%eax),%esi
  800478:	85 f6                	test   %esi,%esi
  80047a:	75 05                	jne    800481 <vprintfmt+0x185>
				p = "(null)";
  80047c:	be 09 10 80 00       	mov    $0x801009,%esi
			if (width > 0 && padc != '-')
  800481:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800485:	0f 8e 84 00 00 00    	jle    80050f <vprintfmt+0x213>
  80048b:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80048f:	74 7e                	je     80050f <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800491:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800495:	89 34 24             	mov    %esi,(%esp)
  800498:	e8 5d 02 00 00       	call   8006fa <strnlen>
  80049d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004a0:	29 c2                	sub    %eax,%edx
  8004a2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004a5:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8004a9:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004ac:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004af:	89 de                	mov    %ebx,%esi
  8004b1:	89 d3                	mov    %edx,%ebx
  8004b3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b5:	eb 0b                	jmp    8004c2 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004bb:	89 3c 24             	mov    %edi,(%esp)
  8004be:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c1:	4b                   	dec    %ebx
  8004c2:	85 db                	test   %ebx,%ebx
  8004c4:	7f f1                	jg     8004b7 <vprintfmt+0x1bb>
  8004c6:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004c9:	89 f3                	mov    %esi,%ebx
  8004cb:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	79 05                	jns    8004da <vprintfmt+0x1de>
  8004d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004dd:	29 c2                	sub    %eax,%edx
  8004df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004e2:	eb 2b                	jmp    80050f <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004e8:	74 18                	je     800502 <vprintfmt+0x206>
  8004ea:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004ed:	83 fa 5e             	cmp    $0x5e,%edx
  8004f0:	76 10                	jbe    800502 <vprintfmt+0x206>
					putch('?', putdat);
  8004f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004fd:	ff 55 08             	call   *0x8(%ebp)
  800500:	eb 0a                	jmp    80050c <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800502:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800506:	89 04 24             	mov    %eax,(%esp)
  800509:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050c:	ff 4d e4             	decl   -0x1c(%ebp)
  80050f:	0f be 06             	movsbl (%esi),%eax
  800512:	46                   	inc    %esi
  800513:	85 c0                	test   %eax,%eax
  800515:	74 21                	je     800538 <vprintfmt+0x23c>
  800517:	85 ff                	test   %edi,%edi
  800519:	78 c9                	js     8004e4 <vprintfmt+0x1e8>
  80051b:	4f                   	dec    %edi
  80051c:	79 c6                	jns    8004e4 <vprintfmt+0x1e8>
  80051e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800521:	89 de                	mov    %ebx,%esi
  800523:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800526:	eb 18                	jmp    800540 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800528:	89 74 24 04          	mov    %esi,0x4(%esp)
  80052c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800533:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800535:	4b                   	dec    %ebx
  800536:	eb 08                	jmp    800540 <vprintfmt+0x244>
  800538:	8b 7d 08             	mov    0x8(%ebp),%edi
  80053b:	89 de                	mov    %ebx,%esi
  80053d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800540:	85 db                	test   %ebx,%ebx
  800542:	7f e4                	jg     800528 <vprintfmt+0x22c>
  800544:	89 7d 08             	mov    %edi,0x8(%ebp)
  800547:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800549:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80054c:	e9 ce fd ff ff       	jmp    80031f <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800551:	8d 45 14             	lea    0x14(%ebp),%eax
  800554:	e8 2f fd ff ff       	call   800288 <getint>
  800559:	89 c6                	mov    %eax,%esi
  80055b:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  80055d:	85 d2                	test   %edx,%edx
  80055f:	78 07                	js     800568 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800561:	be 0a 00 00 00       	mov    $0xa,%esi
  800566:	eb 7e                	jmp    8005e6 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800568:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80056c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800573:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800576:	89 f0                	mov    %esi,%eax
  800578:	89 fa                	mov    %edi,%edx
  80057a:	f7 d8                	neg    %eax
  80057c:	83 d2 00             	adc    $0x0,%edx
  80057f:	f7 da                	neg    %edx
			}
			base = 10;
  800581:	be 0a 00 00 00       	mov    $0xa,%esi
  800586:	eb 5e                	jmp    8005e6 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800588:	8d 45 14             	lea    0x14(%ebp),%eax
  80058b:	e8 be fc ff ff       	call   80024e <getuint>
			base = 10;
  800590:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800595:	eb 4f                	jmp    8005e6 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800597:	8d 45 14             	lea    0x14(%ebp),%eax
  80059a:	e8 af fc ff ff       	call   80024e <getuint>
			base = 8;
  80059f:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8005a4:	eb 40                	jmp    8005e6 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  8005a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005aa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005b1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005bf:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 04             	lea    0x4(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005d2:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8005d7:	eb 0d                	jmp    8005e6 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005dc:	e8 6d fc ff ff       	call   80024e <getuint>
			base = 16;
  8005e1:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005e6:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8005ea:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005ee:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005f1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8005f5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8005f9:	89 04 24             	mov    %eax,(%esp)
  8005fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800600:	89 da                	mov    %ebx,%edx
  800602:	8b 45 08             	mov    0x8(%ebp),%eax
  800605:	e8 7a fb ff ff       	call   800184 <printnum>
			break;
  80060a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80060d:	e9 0d fd ff ff       	jmp    80031f <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  800612:	8d 45 14             	lea    0x14(%ebp),%eax
  800615:	e8 6e fc ff ff       	call   800288 <getint>
  80061a:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  800622:	e9 f8 fc ff ff       	jmp    80031f <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800627:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062b:	89 04 24             	mov    %eax,(%esp)
  80062e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800631:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800634:	e9 e6 fc ff ff       	jmp    80031f <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800639:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800644:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800647:	eb 01                	jmp    80064a <vprintfmt+0x34e>
  800649:	4e                   	dec    %esi
  80064a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80064e:	75 f9                	jne    800649 <vprintfmt+0x34d>
  800650:	e9 ca fc ff ff       	jmp    80031f <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800655:	83 c4 4c             	add    $0x4c,%esp
  800658:	5b                   	pop    %ebx
  800659:	5e                   	pop    %esi
  80065a:	5f                   	pop    %edi
  80065b:	5d                   	pop    %ebp
  80065c:	c3                   	ret    

0080065d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80065d:	55                   	push   %ebp
  80065e:	89 e5                	mov    %esp,%ebp
  800660:	83 ec 28             	sub    $0x28,%esp
  800663:	8b 45 08             	mov    0x8(%ebp),%eax
  800666:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800669:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80066c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800670:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800673:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80067a:	85 c0                	test   %eax,%eax
  80067c:	74 30                	je     8006ae <vsnprintf+0x51>
  80067e:	85 d2                	test   %edx,%edx
  800680:	7e 33                	jle    8006b5 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800689:	8b 45 10             	mov    0x10(%ebp),%eax
  80068c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800690:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800693:	89 44 24 04          	mov    %eax,0x4(%esp)
  800697:	c7 04 24 ba 02 80 00 	movl   $0x8002ba,(%esp)
  80069e:	e8 59 fc ff ff       	call   8002fc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ac:	eb 0c                	jmp    8006ba <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b3:	eb 05                	jmp    8006ba <vsnprintf+0x5d>
  8006b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ba:	c9                   	leave  
  8006bb:	c3                   	ret    

008006bc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8006cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006da:	89 04 24             	mov    %eax,(%esp)
  8006dd:	e8 7b ff ff ff       	call   80065d <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ef:	eb 01                	jmp    8006f2 <strlen+0xe>
		n++;
  8006f1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f6:	75 f9                	jne    8006f1 <strlen+0xd>
		n++;
	return n;
}
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800700:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800703:	b8 00 00 00 00       	mov    $0x0,%eax
  800708:	eb 01                	jmp    80070b <strnlen+0x11>
		n++;
  80070a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070b:	39 d0                	cmp    %edx,%eax
  80070d:	74 06                	je     800715 <strnlen+0x1b>
  80070f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800713:	75 f5                	jne    80070a <strnlen+0x10>
		n++;
	return n;
}
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	53                   	push   %ebx
  80071b:	8b 45 08             	mov    0x8(%ebp),%eax
  80071e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800721:	ba 00 00 00 00       	mov    $0x0,%edx
  800726:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800729:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80072c:	42                   	inc    %edx
  80072d:	84 c9                	test   %cl,%cl
  80072f:	75 f5                	jne    800726 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800731:	5b                   	pop    %ebx
  800732:	5d                   	pop    %ebp
  800733:	c3                   	ret    

00800734 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	53                   	push   %ebx
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80073e:	89 1c 24             	mov    %ebx,(%esp)
  800741:	e8 9e ff ff ff       	call   8006e4 <strlen>
	strcpy(dst + len, src);
  800746:	8b 55 0c             	mov    0xc(%ebp),%edx
  800749:	89 54 24 04          	mov    %edx,0x4(%esp)
  80074d:	01 d8                	add    %ebx,%eax
  80074f:	89 04 24             	mov    %eax,(%esp)
  800752:	e8 c0 ff ff ff       	call   800717 <strcpy>
	return dst;
}
  800757:	89 d8                	mov    %ebx,%eax
  800759:	83 c4 08             	add    $0x8,%esp
  80075c:	5b                   	pop    %ebx
  80075d:	5d                   	pop    %ebp
  80075e:	c3                   	ret    

0080075f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	56                   	push   %esi
  800763:	53                   	push   %ebx
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800772:	eb 0c                	jmp    800780 <strncpy+0x21>
		*dst++ = *src;
  800774:	8a 1a                	mov    (%edx),%bl
  800776:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800779:	80 3a 01             	cmpb   $0x1,(%edx)
  80077c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077f:	41                   	inc    %ecx
  800780:	39 f1                	cmp    %esi,%ecx
  800782:	75 f0                	jne    800774 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800784:	5b                   	pop    %ebx
  800785:	5e                   	pop    %esi
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	56                   	push   %esi
  80078c:	53                   	push   %ebx
  80078d:	8b 75 08             	mov    0x8(%ebp),%esi
  800790:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800793:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800796:	85 d2                	test   %edx,%edx
  800798:	75 0a                	jne    8007a4 <strlcpy+0x1c>
  80079a:	89 f0                	mov    %esi,%eax
  80079c:	eb 1a                	jmp    8007b8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80079e:	88 18                	mov    %bl,(%eax)
  8007a0:	40                   	inc    %eax
  8007a1:	41                   	inc    %ecx
  8007a2:	eb 02                	jmp    8007a6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007a6:	4a                   	dec    %edx
  8007a7:	74 0a                	je     8007b3 <strlcpy+0x2b>
  8007a9:	8a 19                	mov    (%ecx),%bl
  8007ab:	84 db                	test   %bl,%bl
  8007ad:	75 ef                	jne    80079e <strlcpy+0x16>
  8007af:	89 c2                	mov    %eax,%edx
  8007b1:	eb 02                	jmp    8007b5 <strlcpy+0x2d>
  8007b3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007b5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007b8:	29 f0                	sub    %esi,%eax
}
  8007ba:	5b                   	pop    %ebx
  8007bb:	5e                   	pop    %esi
  8007bc:	5d                   	pop    %ebp
  8007bd:	c3                   	ret    

008007be <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c7:	eb 02                	jmp    8007cb <strcmp+0xd>
		p++, q++;
  8007c9:	41                   	inc    %ecx
  8007ca:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007cb:	8a 01                	mov    (%ecx),%al
  8007cd:	84 c0                	test   %al,%al
  8007cf:	74 04                	je     8007d5 <strcmp+0x17>
  8007d1:	3a 02                	cmp    (%edx),%al
  8007d3:	74 f4                	je     8007c9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d5:	0f b6 c0             	movzbl %al,%eax
  8007d8:	0f b6 12             	movzbl (%edx),%edx
  8007db:	29 d0                	sub    %edx,%eax
}
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	53                   	push   %ebx
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007ec:	eb 03                	jmp    8007f1 <strncmp+0x12>
		n--, p++, q++;
  8007ee:	4a                   	dec    %edx
  8007ef:	40                   	inc    %eax
  8007f0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f1:	85 d2                	test   %edx,%edx
  8007f3:	74 14                	je     800809 <strncmp+0x2a>
  8007f5:	8a 18                	mov    (%eax),%bl
  8007f7:	84 db                	test   %bl,%bl
  8007f9:	74 04                	je     8007ff <strncmp+0x20>
  8007fb:	3a 19                	cmp    (%ecx),%bl
  8007fd:	74 ef                	je     8007ee <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ff:	0f b6 00             	movzbl (%eax),%eax
  800802:	0f b6 11             	movzbl (%ecx),%edx
  800805:	29 d0                	sub    %edx,%eax
  800807:	eb 05                	jmp    80080e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800809:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80080e:	5b                   	pop    %ebx
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	8b 45 08             	mov    0x8(%ebp),%eax
  800817:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80081a:	eb 05                	jmp    800821 <strchr+0x10>
		if (*s == c)
  80081c:	38 ca                	cmp    %cl,%dl
  80081e:	74 0c                	je     80082c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800820:	40                   	inc    %eax
  800821:	8a 10                	mov    (%eax),%dl
  800823:	84 d2                	test   %dl,%dl
  800825:	75 f5                	jne    80081c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800827:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80082c:	5d                   	pop    %ebp
  80082d:	c3                   	ret    

0080082e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	8b 45 08             	mov    0x8(%ebp),%eax
  800834:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800837:	eb 05                	jmp    80083e <strfind+0x10>
		if (*s == c)
  800839:	38 ca                	cmp    %cl,%dl
  80083b:	74 07                	je     800844 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80083d:	40                   	inc    %eax
  80083e:	8a 10                	mov    (%eax),%dl
  800840:	84 d2                	test   %dl,%dl
  800842:	75 f5                	jne    800839 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	57                   	push   %edi
  80084a:	56                   	push   %esi
  80084b:	53                   	push   %ebx
  80084c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80084f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800852:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800855:	85 c9                	test   %ecx,%ecx
  800857:	74 30                	je     800889 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800859:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80085f:	75 25                	jne    800886 <memset+0x40>
  800861:	f6 c1 03             	test   $0x3,%cl
  800864:	75 20                	jne    800886 <memset+0x40>
		c &= 0xFF;
  800866:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800869:	89 d3                	mov    %edx,%ebx
  80086b:	c1 e3 08             	shl    $0x8,%ebx
  80086e:	89 d6                	mov    %edx,%esi
  800870:	c1 e6 18             	shl    $0x18,%esi
  800873:	89 d0                	mov    %edx,%eax
  800875:	c1 e0 10             	shl    $0x10,%eax
  800878:	09 f0                	or     %esi,%eax
  80087a:	09 d0                	or     %edx,%eax
  80087c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80087e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800881:	fc                   	cld    
  800882:	f3 ab                	rep stos %eax,%es:(%edi)
  800884:	eb 03                	jmp    800889 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800886:	fc                   	cld    
  800887:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800889:	89 f8                	mov    %edi,%eax
  80088b:	5b                   	pop    %ebx
  80088c:	5e                   	pop    %esi
  80088d:	5f                   	pop    %edi
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	57                   	push   %edi
  800894:	56                   	push   %esi
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	8b 75 0c             	mov    0xc(%ebp),%esi
  80089b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80089e:	39 c6                	cmp    %eax,%esi
  8008a0:	73 34                	jae    8008d6 <memmove+0x46>
  8008a2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a5:	39 d0                	cmp    %edx,%eax
  8008a7:	73 2d                	jae    8008d6 <memmove+0x46>
		s += n;
		d += n;
  8008a9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ac:	f6 c2 03             	test   $0x3,%dl
  8008af:	75 1b                	jne    8008cc <memmove+0x3c>
  8008b1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b7:	75 13                	jne    8008cc <memmove+0x3c>
  8008b9:	f6 c1 03             	test   $0x3,%cl
  8008bc:	75 0e                	jne    8008cc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008be:	83 ef 04             	sub    $0x4,%edi
  8008c1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008c4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008c7:	fd                   	std    
  8008c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ca:	eb 07                	jmp    8008d3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008cc:	4f                   	dec    %edi
  8008cd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008d0:	fd                   	std    
  8008d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008d3:	fc                   	cld    
  8008d4:	eb 20                	jmp    8008f6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008dc:	75 13                	jne    8008f1 <memmove+0x61>
  8008de:	a8 03                	test   $0x3,%al
  8008e0:	75 0f                	jne    8008f1 <memmove+0x61>
  8008e2:	f6 c1 03             	test   $0x3,%cl
  8008e5:	75 0a                	jne    8008f1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008e7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008ea:	89 c7                	mov    %eax,%edi
  8008ec:	fc                   	cld    
  8008ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ef:	eb 05                	jmp    8008f6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008f1:	89 c7                	mov    %eax,%edi
  8008f3:	fc                   	cld    
  8008f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008f6:	5e                   	pop    %esi
  8008f7:	5f                   	pop    %edi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800900:	8b 45 10             	mov    0x10(%ebp),%eax
  800903:	89 44 24 08          	mov    %eax,0x8(%esp)
  800907:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	89 04 24             	mov    %eax,(%esp)
  800914:	e8 77 ff ff ff       	call   800890 <memmove>
}
  800919:	c9                   	leave  
  80091a:	c3                   	ret    

0080091b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	57                   	push   %edi
  80091f:	56                   	push   %esi
  800920:	53                   	push   %ebx
  800921:	8b 7d 08             	mov    0x8(%ebp),%edi
  800924:	8b 75 0c             	mov    0xc(%ebp),%esi
  800927:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092a:	ba 00 00 00 00       	mov    $0x0,%edx
  80092f:	eb 16                	jmp    800947 <memcmp+0x2c>
		if (*s1 != *s2)
  800931:	8a 04 17             	mov    (%edi,%edx,1),%al
  800934:	42                   	inc    %edx
  800935:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800939:	38 c8                	cmp    %cl,%al
  80093b:	74 0a                	je     800947 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  80093d:	0f b6 c0             	movzbl %al,%eax
  800940:	0f b6 c9             	movzbl %cl,%ecx
  800943:	29 c8                	sub    %ecx,%eax
  800945:	eb 09                	jmp    800950 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800947:	39 da                	cmp    %ebx,%edx
  800949:	75 e6                	jne    800931 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80094b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800950:	5b                   	pop    %ebx
  800951:	5e                   	pop    %esi
  800952:	5f                   	pop    %edi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80095e:	89 c2                	mov    %eax,%edx
  800960:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800963:	eb 05                	jmp    80096a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800965:	38 08                	cmp    %cl,(%eax)
  800967:	74 05                	je     80096e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800969:	40                   	inc    %eax
  80096a:	39 d0                	cmp    %edx,%eax
  80096c:	72 f7                	jb     800965 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	57                   	push   %edi
  800974:	56                   	push   %esi
  800975:	53                   	push   %ebx
  800976:	8b 55 08             	mov    0x8(%ebp),%edx
  800979:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097c:	eb 01                	jmp    80097f <strtol+0xf>
		s++;
  80097e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097f:	8a 02                	mov    (%edx),%al
  800981:	3c 20                	cmp    $0x20,%al
  800983:	74 f9                	je     80097e <strtol+0xe>
  800985:	3c 09                	cmp    $0x9,%al
  800987:	74 f5                	je     80097e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800989:	3c 2b                	cmp    $0x2b,%al
  80098b:	75 08                	jne    800995 <strtol+0x25>
		s++;
  80098d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80098e:	bf 00 00 00 00       	mov    $0x0,%edi
  800993:	eb 13                	jmp    8009a8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800995:	3c 2d                	cmp    $0x2d,%al
  800997:	75 0a                	jne    8009a3 <strtol+0x33>
		s++, neg = 1;
  800999:	8d 52 01             	lea    0x1(%edx),%edx
  80099c:	bf 01 00 00 00       	mov    $0x1,%edi
  8009a1:	eb 05                	jmp    8009a8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a8:	85 db                	test   %ebx,%ebx
  8009aa:	74 05                	je     8009b1 <strtol+0x41>
  8009ac:	83 fb 10             	cmp    $0x10,%ebx
  8009af:	75 28                	jne    8009d9 <strtol+0x69>
  8009b1:	8a 02                	mov    (%edx),%al
  8009b3:	3c 30                	cmp    $0x30,%al
  8009b5:	75 10                	jne    8009c7 <strtol+0x57>
  8009b7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009bb:	75 0a                	jne    8009c7 <strtol+0x57>
		s += 2, base = 16;
  8009bd:	83 c2 02             	add    $0x2,%edx
  8009c0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009c5:	eb 12                	jmp    8009d9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009c7:	85 db                	test   %ebx,%ebx
  8009c9:	75 0e                	jne    8009d9 <strtol+0x69>
  8009cb:	3c 30                	cmp    $0x30,%al
  8009cd:	75 05                	jne    8009d4 <strtol+0x64>
		s++, base = 8;
  8009cf:	42                   	inc    %edx
  8009d0:	b3 08                	mov    $0x8,%bl
  8009d2:	eb 05                	jmp    8009d9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009d4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009de:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009e0:	8a 0a                	mov    (%edx),%cl
  8009e2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009e5:	80 fb 09             	cmp    $0x9,%bl
  8009e8:	77 08                	ja     8009f2 <strtol+0x82>
			dig = *s - '0';
  8009ea:	0f be c9             	movsbl %cl,%ecx
  8009ed:	83 e9 30             	sub    $0x30,%ecx
  8009f0:	eb 1e                	jmp    800a10 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009f2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009f5:	80 fb 19             	cmp    $0x19,%bl
  8009f8:	77 08                	ja     800a02 <strtol+0x92>
			dig = *s - 'a' + 10;
  8009fa:	0f be c9             	movsbl %cl,%ecx
  8009fd:	83 e9 57             	sub    $0x57,%ecx
  800a00:	eb 0e                	jmp    800a10 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a02:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a05:	80 fb 19             	cmp    $0x19,%bl
  800a08:	77 12                	ja     800a1c <strtol+0xac>
			dig = *s - 'A' + 10;
  800a0a:	0f be c9             	movsbl %cl,%ecx
  800a0d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a10:	39 f1                	cmp    %esi,%ecx
  800a12:	7d 0c                	jge    800a20 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a14:	42                   	inc    %edx
  800a15:	0f af c6             	imul   %esi,%eax
  800a18:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a1a:	eb c4                	jmp    8009e0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a1c:	89 c1                	mov    %eax,%ecx
  800a1e:	eb 02                	jmp    800a22 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a20:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a22:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a26:	74 05                	je     800a2d <strtol+0xbd>
		*endptr = (char *) s;
  800a28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a2b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a2d:	85 ff                	test   %edi,%edi
  800a2f:	74 04                	je     800a35 <strtol+0xc5>
  800a31:	89 c8                	mov    %ecx,%eax
  800a33:	f7 d8                	neg    %eax
}
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5f                   	pop    %edi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    
	...

00800a3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	57                   	push   %edi
  800a40:	56                   	push   %esi
  800a41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
  800a47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4d:	89 c3                	mov    %eax,%ebx
  800a4f:	89 c7                	mov    %eax,%edi
  800a51:	89 c6                	mov    %eax,%esi
  800a53:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a55:	5b                   	pop    %ebx
  800a56:	5e                   	pop    %esi
  800a57:	5f                   	pop    %edi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	57                   	push   %edi
  800a5e:	56                   	push   %esi
  800a5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a60:	ba 00 00 00 00       	mov    $0x0,%edx
  800a65:	b8 01 00 00 00       	mov    $0x1,%eax
  800a6a:	89 d1                	mov    %edx,%ecx
  800a6c:	89 d3                	mov    %edx,%ebx
  800a6e:	89 d7                	mov    %edx,%edi
  800a70:	89 d6                	mov    %edx,%esi
  800a72:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a74:	5b                   	pop    %ebx
  800a75:	5e                   	pop    %esi
  800a76:	5f                   	pop    %edi
  800a77:	5d                   	pop    %ebp
  800a78:	c3                   	ret    

00800a79 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	57                   	push   %edi
  800a7d:	56                   	push   %esi
  800a7e:	53                   	push   %ebx
  800a7f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a87:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8f:	89 cb                	mov    %ecx,%ebx
  800a91:	89 cf                	mov    %ecx,%edi
  800a93:	89 ce                	mov    %ecx,%esi
  800a95:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a97:	85 c0                	test   %eax,%eax
  800a99:	7e 28                	jle    800ac3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a9f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800aa6:	00 
  800aa7:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800aae:	00 
  800aaf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ab6:	00 
  800ab7:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800abe:	e8 5d 02 00 00       	call   800d20 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ac3:	83 c4 2c             	add    $0x2c,%esp
  800ac6:	5b                   	pop    %ebx
  800ac7:	5e                   	pop    %esi
  800ac8:	5f                   	pop    %edi
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	57                   	push   %edi
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad6:	b8 02 00 00 00       	mov    $0x2,%eax
  800adb:	89 d1                	mov    %edx,%ecx
  800add:	89 d3                	mov    %edx,%ebx
  800adf:	89 d7                	mov    %edx,%edi
  800ae1:	89 d6                	mov    %edx,%esi
  800ae3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <sys_yield>:

void
sys_yield(void)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af0:	ba 00 00 00 00       	mov    $0x0,%edx
  800af5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800afa:	89 d1                	mov    %edx,%ecx
  800afc:	89 d3                	mov    %edx,%ebx
  800afe:	89 d7                	mov    %edx,%edi
  800b00:	89 d6                	mov    %edx,%esi
  800b02:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	57                   	push   %edi
  800b0d:	56                   	push   %esi
  800b0e:	53                   	push   %ebx
  800b0f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b12:	be 00 00 00 00       	mov    $0x0,%esi
  800b17:	b8 04 00 00 00       	mov    $0x4,%eax
  800b1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b22:	8b 55 08             	mov    0x8(%ebp),%edx
  800b25:	89 f7                	mov    %esi,%edi
  800b27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b29:	85 c0                	test   %eax,%eax
  800b2b:	7e 28                	jle    800b55 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b31:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b38:	00 
  800b39:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800b40:	00 
  800b41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b48:	00 
  800b49:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800b50:	e8 cb 01 00 00       	call   800d20 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b55:	83 c4 2c             	add    $0x2c,%esp
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800b66:	b8 05 00 00 00       	mov    $0x5,%eax
  800b6b:	8b 75 18             	mov    0x18(%ebp),%esi
  800b6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b77:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7c:	85 c0                	test   %eax,%eax
  800b7e:	7e 28                	jle    800ba8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b80:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b84:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800b8b:	00 
  800b8c:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800b93:	00 
  800b94:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b9b:	00 
  800b9c:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800ba3:	e8 78 01 00 00       	call   800d20 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba8:	83 c4 2c             	add    $0x2c,%esp
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bbe:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	89 df                	mov    %ebx,%edi
  800bcb:	89 de                	mov    %ebx,%esi
  800bcd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	7e 28                	jle    800bfb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800bde:	00 
  800bdf:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800be6:	00 
  800be7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bee:	00 
  800bef:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800bf6:	e8 25 01 00 00       	call   800d20 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bfb:	83 c4 2c             	add    $0x2c,%esp
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c11:	b8 08 00 00 00       	mov    $0x8,%eax
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	89 df                	mov    %ebx,%edi
  800c1e:	89 de                	mov    %ebx,%esi
  800c20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c22:	85 c0                	test   %eax,%eax
  800c24:	7e 28                	jle    800c4e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c26:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c31:	00 
  800c32:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800c39:	00 
  800c3a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c41:	00 
  800c42:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800c49:	e8 d2 00 00 00       	call   800d20 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c4e:	83 c4 2c             	add    $0x2c,%esp
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
  800c5c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c64:	b8 09 00 00 00       	mov    $0x9,%eax
  800c69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6f:	89 df                	mov    %ebx,%edi
  800c71:	89 de                	mov    %ebx,%esi
  800c73:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c75:	85 c0                	test   %eax,%eax
  800c77:	7e 28                	jle    800ca1 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c84:	00 
  800c85:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800c8c:	00 
  800c8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c94:	00 
  800c95:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800c9c:	e8 7f 00 00 00       	call   800d20 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca1:	83 c4 2c             	add    $0x2c,%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	be 00 00 00 00       	mov    $0x0,%esi
  800cb4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cda:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	89 cb                	mov    %ecx,%ebx
  800ce4:	89 cf                	mov    %ecx,%edi
  800ce6:	89 ce                	mov    %ecx,%esi
  800ce8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7e 28                	jle    800d16 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf2:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800cf9:	00 
  800cfa:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800d01:	00 
  800d02:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d09:	00 
  800d0a:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800d11:	e8 0a 00 00 00       	call   800d20 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d16:	83 c4 2c             	add    $0x2c,%esp
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    
	...

00800d20 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
  800d25:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d28:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d2b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d31:	e8 95 fd ff ff       	call   800acb <sys_getenvid>
  800d36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d39:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d44:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d48:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d4c:	c7 04 24 74 12 80 00 	movl   $0x801274,(%esp)
  800d53:	e8 10 f4 ff ff       	call   800168 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d58:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d5f:	89 04 24             	mov    %eax,(%esp)
  800d62:	e8 a0 f3 ff ff       	call   800107 <vcprintf>
	cprintf("\n");
  800d67:	c7 04 24 ec 0f 80 00 	movl   $0x800fec,(%esp)
  800d6e:	e8 f5 f3 ff ff       	call   800168 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d73:	cc                   	int3   
  800d74:	eb fd                	jmp    800d73 <_panic+0x53>
	...

00800d78 <__udivdi3>:
  800d78:	55                   	push   %ebp
  800d79:	57                   	push   %edi
  800d7a:	56                   	push   %esi
  800d7b:	83 ec 10             	sub    $0x10,%esp
  800d7e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d82:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800d86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d8a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800d8e:	89 cd                	mov    %ecx,%ebp
  800d90:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800d94:	85 c0                	test   %eax,%eax
  800d96:	75 2c                	jne    800dc4 <__udivdi3+0x4c>
  800d98:	39 f9                	cmp    %edi,%ecx
  800d9a:	77 68                	ja     800e04 <__udivdi3+0x8c>
  800d9c:	85 c9                	test   %ecx,%ecx
  800d9e:	75 0b                	jne    800dab <__udivdi3+0x33>
  800da0:	b8 01 00 00 00       	mov    $0x1,%eax
  800da5:	31 d2                	xor    %edx,%edx
  800da7:	f7 f1                	div    %ecx
  800da9:	89 c1                	mov    %eax,%ecx
  800dab:	31 d2                	xor    %edx,%edx
  800dad:	89 f8                	mov    %edi,%eax
  800daf:	f7 f1                	div    %ecx
  800db1:	89 c7                	mov    %eax,%edi
  800db3:	89 f0                	mov    %esi,%eax
  800db5:	f7 f1                	div    %ecx
  800db7:	89 c6                	mov    %eax,%esi
  800db9:	89 f0                	mov    %esi,%eax
  800dbb:	89 fa                	mov    %edi,%edx
  800dbd:	83 c4 10             	add    $0x10,%esp
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    
  800dc4:	39 f8                	cmp    %edi,%eax
  800dc6:	77 2c                	ja     800df4 <__udivdi3+0x7c>
  800dc8:	0f bd f0             	bsr    %eax,%esi
  800dcb:	83 f6 1f             	xor    $0x1f,%esi
  800dce:	75 4c                	jne    800e1c <__udivdi3+0xa4>
  800dd0:	39 f8                	cmp    %edi,%eax
  800dd2:	bf 00 00 00 00       	mov    $0x0,%edi
  800dd7:	72 0a                	jb     800de3 <__udivdi3+0x6b>
  800dd9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800ddd:	0f 87 ad 00 00 00    	ja     800e90 <__udivdi3+0x118>
  800de3:	be 01 00 00 00       	mov    $0x1,%esi
  800de8:	89 f0                	mov    %esi,%eax
  800dea:	89 fa                	mov    %edi,%edx
  800dec:	83 c4 10             	add    $0x10,%esp
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    
  800df3:	90                   	nop
  800df4:	31 ff                	xor    %edi,%edi
  800df6:	31 f6                	xor    %esi,%esi
  800df8:	89 f0                	mov    %esi,%eax
  800dfa:	89 fa                	mov    %edi,%edx
  800dfc:	83 c4 10             	add    $0x10,%esp
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    
  800e03:	90                   	nop
  800e04:	89 fa                	mov    %edi,%edx
  800e06:	89 f0                	mov    %esi,%eax
  800e08:	f7 f1                	div    %ecx
  800e0a:	89 c6                	mov    %eax,%esi
  800e0c:	31 ff                	xor    %edi,%edi
  800e0e:	89 f0                	mov    %esi,%eax
  800e10:	89 fa                	mov    %edi,%edx
  800e12:	83 c4 10             	add    $0x10,%esp
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    
  800e19:	8d 76 00             	lea    0x0(%esi),%esi
  800e1c:	89 f1                	mov    %esi,%ecx
  800e1e:	d3 e0                	shl    %cl,%eax
  800e20:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e24:	b8 20 00 00 00       	mov    $0x20,%eax
  800e29:	29 f0                	sub    %esi,%eax
  800e2b:	89 ea                	mov    %ebp,%edx
  800e2d:	88 c1                	mov    %al,%cl
  800e2f:	d3 ea                	shr    %cl,%edx
  800e31:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e35:	09 ca                	or     %ecx,%edx
  800e37:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e3b:	89 f1                	mov    %esi,%ecx
  800e3d:	d3 e5                	shl    %cl,%ebp
  800e3f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800e43:	89 fd                	mov    %edi,%ebp
  800e45:	88 c1                	mov    %al,%cl
  800e47:	d3 ed                	shr    %cl,%ebp
  800e49:	89 fa                	mov    %edi,%edx
  800e4b:	89 f1                	mov    %esi,%ecx
  800e4d:	d3 e2                	shl    %cl,%edx
  800e4f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e53:	88 c1                	mov    %al,%cl
  800e55:	d3 ef                	shr    %cl,%edi
  800e57:	09 d7                	or     %edx,%edi
  800e59:	89 f8                	mov    %edi,%eax
  800e5b:	89 ea                	mov    %ebp,%edx
  800e5d:	f7 74 24 08          	divl   0x8(%esp)
  800e61:	89 d1                	mov    %edx,%ecx
  800e63:	89 c7                	mov    %eax,%edi
  800e65:	f7 64 24 0c          	mull   0xc(%esp)
  800e69:	39 d1                	cmp    %edx,%ecx
  800e6b:	72 17                	jb     800e84 <__udivdi3+0x10c>
  800e6d:	74 09                	je     800e78 <__udivdi3+0x100>
  800e6f:	89 fe                	mov    %edi,%esi
  800e71:	31 ff                	xor    %edi,%edi
  800e73:	e9 41 ff ff ff       	jmp    800db9 <__udivdi3+0x41>
  800e78:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e7c:	89 f1                	mov    %esi,%ecx
  800e7e:	d3 e2                	shl    %cl,%edx
  800e80:	39 c2                	cmp    %eax,%edx
  800e82:	73 eb                	jae    800e6f <__udivdi3+0xf7>
  800e84:	8d 77 ff             	lea    -0x1(%edi),%esi
  800e87:	31 ff                	xor    %edi,%edi
  800e89:	e9 2b ff ff ff       	jmp    800db9 <__udivdi3+0x41>
  800e8e:	66 90                	xchg   %ax,%ax
  800e90:	31 f6                	xor    %esi,%esi
  800e92:	e9 22 ff ff ff       	jmp    800db9 <__udivdi3+0x41>
	...

00800e98 <__umoddi3>:
  800e98:	55                   	push   %ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	83 ec 20             	sub    $0x20,%esp
  800e9e:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ea2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800ea6:	89 44 24 14          	mov    %eax,0x14(%esp)
  800eaa:	8b 74 24 34          	mov    0x34(%esp),%esi
  800eae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800eb2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800eb6:	89 c7                	mov    %eax,%edi
  800eb8:	89 f2                	mov    %esi,%edx
  800eba:	85 ed                	test   %ebp,%ebp
  800ebc:	75 16                	jne    800ed4 <__umoddi3+0x3c>
  800ebe:	39 f1                	cmp    %esi,%ecx
  800ec0:	0f 86 a6 00 00 00    	jbe    800f6c <__umoddi3+0xd4>
  800ec6:	f7 f1                	div    %ecx
  800ec8:	89 d0                	mov    %edx,%eax
  800eca:	31 d2                	xor    %edx,%edx
  800ecc:	83 c4 20             	add    $0x20,%esp
  800ecf:	5e                   	pop    %esi
  800ed0:	5f                   	pop    %edi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    
  800ed3:	90                   	nop
  800ed4:	39 f5                	cmp    %esi,%ebp
  800ed6:	0f 87 ac 00 00 00    	ja     800f88 <__umoddi3+0xf0>
  800edc:	0f bd c5             	bsr    %ebp,%eax
  800edf:	83 f0 1f             	xor    $0x1f,%eax
  800ee2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee6:	0f 84 a8 00 00 00    	je     800f94 <__umoddi3+0xfc>
  800eec:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ef0:	d3 e5                	shl    %cl,%ebp
  800ef2:	bf 20 00 00 00       	mov    $0x20,%edi
  800ef7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800efb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800eff:	89 f9                	mov    %edi,%ecx
  800f01:	d3 e8                	shr    %cl,%eax
  800f03:	09 e8                	or     %ebp,%eax
  800f05:	89 44 24 18          	mov    %eax,0x18(%esp)
  800f09:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f0d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f11:	d3 e0                	shl    %cl,%eax
  800f13:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f17:	89 f2                	mov    %esi,%edx
  800f19:	d3 e2                	shl    %cl,%edx
  800f1b:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f1f:	d3 e0                	shl    %cl,%eax
  800f21:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800f25:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f29:	89 f9                	mov    %edi,%ecx
  800f2b:	d3 e8                	shr    %cl,%eax
  800f2d:	09 d0                	or     %edx,%eax
  800f2f:	d3 ee                	shr    %cl,%esi
  800f31:	89 f2                	mov    %esi,%edx
  800f33:	f7 74 24 18          	divl   0x18(%esp)
  800f37:	89 d6                	mov    %edx,%esi
  800f39:	f7 64 24 0c          	mull   0xc(%esp)
  800f3d:	89 c5                	mov    %eax,%ebp
  800f3f:	89 d1                	mov    %edx,%ecx
  800f41:	39 d6                	cmp    %edx,%esi
  800f43:	72 67                	jb     800fac <__umoddi3+0x114>
  800f45:	74 75                	je     800fbc <__umoddi3+0x124>
  800f47:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f4b:	29 e8                	sub    %ebp,%eax
  800f4d:	19 ce                	sbb    %ecx,%esi
  800f4f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f53:	d3 e8                	shr    %cl,%eax
  800f55:	89 f2                	mov    %esi,%edx
  800f57:	89 f9                	mov    %edi,%ecx
  800f59:	d3 e2                	shl    %cl,%edx
  800f5b:	09 d0                	or     %edx,%eax
  800f5d:	89 f2                	mov    %esi,%edx
  800f5f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f63:	d3 ea                	shr    %cl,%edx
  800f65:	83 c4 20             	add    $0x20,%esp
  800f68:	5e                   	pop    %esi
  800f69:	5f                   	pop    %edi
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    
  800f6c:	85 c9                	test   %ecx,%ecx
  800f6e:	75 0b                	jne    800f7b <__umoddi3+0xe3>
  800f70:	b8 01 00 00 00       	mov    $0x1,%eax
  800f75:	31 d2                	xor    %edx,%edx
  800f77:	f7 f1                	div    %ecx
  800f79:	89 c1                	mov    %eax,%ecx
  800f7b:	89 f0                	mov    %esi,%eax
  800f7d:	31 d2                	xor    %edx,%edx
  800f7f:	f7 f1                	div    %ecx
  800f81:	89 f8                	mov    %edi,%eax
  800f83:	e9 3e ff ff ff       	jmp    800ec6 <__umoddi3+0x2e>
  800f88:	89 f2                	mov    %esi,%edx
  800f8a:	83 c4 20             	add    $0x20,%esp
  800f8d:	5e                   	pop    %esi
  800f8e:	5f                   	pop    %edi
  800f8f:	5d                   	pop    %ebp
  800f90:	c3                   	ret    
  800f91:	8d 76 00             	lea    0x0(%esi),%esi
  800f94:	39 f5                	cmp    %esi,%ebp
  800f96:	72 04                	jb     800f9c <__umoddi3+0x104>
  800f98:	39 f9                	cmp    %edi,%ecx
  800f9a:	77 06                	ja     800fa2 <__umoddi3+0x10a>
  800f9c:	89 f2                	mov    %esi,%edx
  800f9e:	29 cf                	sub    %ecx,%edi
  800fa0:	19 ea                	sbb    %ebp,%edx
  800fa2:	89 f8                	mov    %edi,%eax
  800fa4:	83 c4 20             	add    $0x20,%esp
  800fa7:	5e                   	pop    %esi
  800fa8:	5f                   	pop    %edi
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    
  800fab:	90                   	nop
  800fac:	89 d1                	mov    %edx,%ecx
  800fae:	89 c5                	mov    %eax,%ebp
  800fb0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fb4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fb8:	eb 8d                	jmp    800f47 <__umoddi3+0xaf>
  800fba:	66 90                	xchg   %ax,%ax
  800fbc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fc0:	72 ea                	jb     800fac <__umoddi3+0x114>
  800fc2:	89 f1                	mov    %esi,%ecx
  800fc4:	eb 81                	jmp    800f47 <__umoddi3+0xaf>
