
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 60 15 80 00 	movl   $0x801560,(%esp)
  800041:	e8 1e 01 00 00       	call   800164 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 08 20 80 00       	mov    0x802008,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 6e 15 80 00 	movl   $0x80156e,(%esp)
  800059:	e8 06 01 00 00       	call   800164 <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	83 ec 10             	sub    $0x10,%esp
  800068:	8b 75 08             	mov    0x8(%ebp),%esi
  80006b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80006e:	e8 54 0a 00 00       	call   800ac7 <sys_getenvid>
  800073:	25 ff 03 00 00       	and    $0x3ff,%eax
  800078:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80007b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80007e:	c1 e0 04             	shl    $0x4,%eax
  800081:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800086:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008b:	85 f6                	test   %esi,%esi
  80008d:	7e 07                	jle    800096 <libmain+0x36>
		binaryname = argv[0];
  80008f:	8b 03                	mov    (%ebx),%eax
  800091:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800096:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80009a:	89 34 24             	mov    %esi,(%esp)
  80009d:	e8 92 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a2:	e8 09 00 00 00       	call   8000b0 <exit>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	5b                   	pop    %ebx
  8000ab:	5e                   	pop    %esi
  8000ac:	5d                   	pop    %ebp
  8000ad:	c3                   	ret    
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bd:	e8 b3 09 00 00       	call   800a75 <sys_env_destroy>
}
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	53                   	push   %ebx
  8000c8:	83 ec 14             	sub    $0x14,%esp
  8000cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ce:	8b 03                	mov    (%ebx),%eax
  8000d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000d7:	40                   	inc    %eax
  8000d8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000df:	75 19                	jne    8000fa <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000e1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000e8:	00 
  8000e9:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ec:	89 04 24             	mov    %eax,(%esp)
  8000ef:	e8 44 09 00 00       	call   800a38 <sys_cputs>
		b->idx = 0;
  8000f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000fa:	ff 43 04             	incl   0x4(%ebx)
}
  8000fd:	83 c4 14             	add    $0x14,%esp
  800100:	5b                   	pop    %ebx
  800101:	5d                   	pop    %ebp
  800102:	c3                   	ret    

00800103 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80010c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800113:	00 00 00 
	b.cnt = 0;
  800116:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800120:	8b 45 0c             	mov    0xc(%ebp),%eax
  800123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800127:	8b 45 08             	mov    0x8(%ebp),%eax
  80012a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800134:	89 44 24 04          	mov    %eax,0x4(%esp)
  800138:	c7 04 24 c4 00 80 00 	movl   $0x8000c4,(%esp)
  80013f:	e8 b4 01 00 00       	call   8002f8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800144:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800154:	89 04 24             	mov    %eax,(%esp)
  800157:	e8 dc 08 00 00       	call   800a38 <sys_cputs>

	return b.cnt;
}
  80015c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800171:	8b 45 08             	mov    0x8(%ebp),%eax
  800174:	89 04 24             	mov    %eax,(%esp)
  800177:	e8 87 ff ff ff       	call   800103 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017c:	c9                   	leave  
  80017d:	c3                   	ret    
	...

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 3c             	sub    $0x3c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d7                	mov    %edx,%edi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800194:	8b 45 0c             	mov    0xc(%ebp),%eax
  800197:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80019d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	85 c0                	test   %eax,%eax
  8001a2:	75 08                	jne    8001ac <printnum+0x2c>
  8001a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001a7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001aa:	77 57                	ja     800203 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ac:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001b0:	4b                   	dec    %ebx
  8001b1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001bc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001c0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001c4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001cb:	00 
  8001cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001cf:	89 04 24             	mov    %eax,(%esp)
  8001d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d9:	e8 1a 11 00 00       	call   8012f8 <__udivdi3>
  8001de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001e6:	89 04 24             	mov    %eax,(%esp)
  8001e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001ed:	89 fa                	mov    %edi,%edx
  8001ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001f2:	e8 89 ff ff ff       	call   800180 <printnum>
  8001f7:	eb 0f                	jmp    800208 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001fd:	89 34 24             	mov    %esi,(%esp)
  800200:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800203:	4b                   	dec    %ebx
  800204:	85 db                	test   %ebx,%ebx
  800206:	7f f1                	jg     8001f9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800208:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80020c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800210:	8b 45 10             	mov    0x10(%ebp),%eax
  800213:	89 44 24 08          	mov    %eax,0x8(%esp)
  800217:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80021e:	00 
  80021f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800222:	89 04 24             	mov    %eax,(%esp)
  800225:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800228:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022c:	e8 e7 11 00 00       	call   801418 <__umoddi3>
  800231:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800235:	0f be 80 8f 15 80 00 	movsbl 0x80158f(%eax),%eax
  80023c:	89 04 24             	mov    %eax,(%esp)
  80023f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800242:	83 c4 3c             	add    $0x3c,%esp
  800245:	5b                   	pop    %ebx
  800246:	5e                   	pop    %esi
  800247:	5f                   	pop    %edi
  800248:	5d                   	pop    %ebp
  800249:	c3                   	ret    

0080024a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80024d:	83 fa 01             	cmp    $0x1,%edx
  800250:	7e 0e                	jle    800260 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800252:	8b 10                	mov    (%eax),%edx
  800254:	8d 4a 08             	lea    0x8(%edx),%ecx
  800257:	89 08                	mov    %ecx,(%eax)
  800259:	8b 02                	mov    (%edx),%eax
  80025b:	8b 52 04             	mov    0x4(%edx),%edx
  80025e:	eb 22                	jmp    800282 <getuint+0x38>
	else if (lflag)
  800260:	85 d2                	test   %edx,%edx
  800262:	74 10                	je     800274 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800264:	8b 10                	mov    (%eax),%edx
  800266:	8d 4a 04             	lea    0x4(%edx),%ecx
  800269:	89 08                	mov    %ecx,(%eax)
  80026b:	8b 02                	mov    (%edx),%eax
  80026d:	ba 00 00 00 00       	mov    $0x0,%edx
  800272:	eb 0e                	jmp    800282 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 04             	lea    0x4(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    

00800284 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800287:	83 fa 01             	cmp    $0x1,%edx
  80028a:	7e 0e                	jle    80029a <getint+0x16>
		return va_arg(*ap, long long);
  80028c:	8b 10                	mov    (%eax),%edx
  80028e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800291:	89 08                	mov    %ecx,(%eax)
  800293:	8b 02                	mov    (%edx),%eax
  800295:	8b 52 04             	mov    0x4(%edx),%edx
  800298:	eb 1a                	jmp    8002b4 <getint+0x30>
	else if (lflag)
  80029a:	85 d2                	test   %edx,%edx
  80029c:	74 0c                	je     8002aa <getint+0x26>
		return va_arg(*ap, long);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	99                   	cltd   
  8002a8:	eb 0a                	jmp    8002b4 <getint+0x30>
	else
		return va_arg(*ap, int);
  8002aa:	8b 10                	mov    (%eax),%edx
  8002ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002af:	89 08                	mov    %ecx,(%eax)
  8002b1:	8b 02                	mov    (%edx),%eax
  8002b3:	99                   	cltd   
}
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    

008002b6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002bc:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002bf:	8b 10                	mov    (%eax),%edx
  8002c1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c4:	73 08                	jae    8002ce <sprintputch+0x18>
		*b->buf++ = ch;
  8002c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c9:	88 0a                	mov    %cl,(%edx)
  8002cb:	42                   	inc    %edx
  8002cc:	89 10                	mov    %edx,(%eax)
}
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ee:	89 04 24             	mov    %eax,(%esp)
  8002f1:	e8 02 00 00 00       	call   8002f8 <vprintfmt>
	va_end(ap);
}
  8002f6:	c9                   	leave  
  8002f7:	c3                   	ret    

008002f8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	57                   	push   %edi
  8002fc:	56                   	push   %esi
  8002fd:	53                   	push   %ebx
  8002fe:	83 ec 4c             	sub    $0x4c,%esp
  800301:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800304:	8b 75 10             	mov    0x10(%ebp),%esi
  800307:	eb 12                	jmp    80031b <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800309:	85 c0                	test   %eax,%eax
  80030b:	0f 84 40 03 00 00    	je     800651 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800311:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800315:	89 04 24             	mov    %eax,(%esp)
  800318:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80031b:	0f b6 06             	movzbl (%esi),%eax
  80031e:	46                   	inc    %esi
  80031f:	83 f8 25             	cmp    $0x25,%eax
  800322:	75 e5                	jne    800309 <vprintfmt+0x11>
  800324:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800328:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80032f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800334:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80033b:	ba 00 00 00 00       	mov    $0x0,%edx
  800340:	eb 26                	jmp    800368 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800345:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800349:	eb 1d                	jmp    800368 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034e:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800352:	eb 14                	jmp    800368 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800354:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800357:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80035e:	eb 08                	jmp    800368 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800360:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800363:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800368:	0f b6 06             	movzbl (%esi),%eax
  80036b:	8d 4e 01             	lea    0x1(%esi),%ecx
  80036e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800371:	8a 0e                	mov    (%esi),%cl
  800373:	83 e9 23             	sub    $0x23,%ecx
  800376:	80 f9 55             	cmp    $0x55,%cl
  800379:	0f 87 b6 02 00 00    	ja     800635 <vprintfmt+0x33d>
  80037f:	0f b6 c9             	movzbl %cl,%ecx
  800382:	ff 24 8d 60 16 80 00 	jmp    *0x801660(,%ecx,4)
  800389:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80038c:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800391:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800394:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  800398:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80039b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80039e:	83 f9 09             	cmp    $0x9,%ecx
  8003a1:	77 2a                	ja     8003cd <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a3:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a4:	eb eb                	jmp    800391 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a9:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ac:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003af:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b4:	eb 17                	jmp    8003cd <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003b6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ba:	78 98                	js     800354 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003bf:	eb a7                	jmp    800368 <vprintfmt+0x70>
  8003c1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003c4:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003cb:	eb 9b                	jmp    800368 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003cd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d1:	79 95                	jns    800368 <vprintfmt+0x70>
  8003d3:	eb 8b                	jmp    800360 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d5:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d9:	eb 8d                	jmp    800368 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003db:	8b 45 14             	mov    0x14(%ebp),%eax
  8003de:	8d 50 04             	lea    0x4(%eax),%edx
  8003e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e8:	8b 00                	mov    (%eax),%eax
  8003ea:	89 04 24             	mov    %eax,(%esp)
  8003ed:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f3:	e9 23 ff ff ff       	jmp    80031b <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fb:	8d 50 04             	lea    0x4(%eax),%edx
  8003fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800401:	8b 00                	mov    (%eax),%eax
  800403:	85 c0                	test   %eax,%eax
  800405:	79 02                	jns    800409 <vprintfmt+0x111>
  800407:	f7 d8                	neg    %eax
  800409:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040b:	83 f8 09             	cmp    $0x9,%eax
  80040e:	7f 0b                	jg     80041b <vprintfmt+0x123>
  800410:	8b 04 85 c0 17 80 00 	mov    0x8017c0(,%eax,4),%eax
  800417:	85 c0                	test   %eax,%eax
  800419:	75 23                	jne    80043e <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80041b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80041f:	c7 44 24 08 a7 15 80 	movl   $0x8015a7,0x8(%esp)
  800426:	00 
  800427:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042b:	8b 45 08             	mov    0x8(%ebp),%eax
  80042e:	89 04 24             	mov    %eax,(%esp)
  800431:	e8 9a fe ff ff       	call   8002d0 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800439:	e9 dd fe ff ff       	jmp    80031b <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80043e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800442:	c7 44 24 08 b0 15 80 	movl   $0x8015b0,0x8(%esp)
  800449:	00 
  80044a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044e:	8b 55 08             	mov    0x8(%ebp),%edx
  800451:	89 14 24             	mov    %edx,(%esp)
  800454:	e8 77 fe ff ff       	call   8002d0 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80045c:	e9 ba fe ff ff       	jmp    80031b <vprintfmt+0x23>
  800461:	89 f9                	mov    %edi,%ecx
  800463:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800466:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800469:	8b 45 14             	mov    0x14(%ebp),%eax
  80046c:	8d 50 04             	lea    0x4(%eax),%edx
  80046f:	89 55 14             	mov    %edx,0x14(%ebp)
  800472:	8b 30                	mov    (%eax),%esi
  800474:	85 f6                	test   %esi,%esi
  800476:	75 05                	jne    80047d <vprintfmt+0x185>
				p = "(null)";
  800478:	be a0 15 80 00       	mov    $0x8015a0,%esi
			if (width > 0 && padc != '-')
  80047d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800481:	0f 8e 84 00 00 00    	jle    80050b <vprintfmt+0x213>
  800487:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80048b:	74 7e                	je     80050b <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800491:	89 34 24             	mov    %esi,(%esp)
  800494:	e8 5d 02 00 00       	call   8006f6 <strnlen>
  800499:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80049c:	29 c2                	sub    %eax,%edx
  80049e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004a1:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8004a5:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004a8:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004ab:	89 de                	mov    %ebx,%esi
  8004ad:	89 d3                	mov    %edx,%ebx
  8004af:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	eb 0b                	jmp    8004be <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b7:	89 3c 24             	mov    %edi,(%esp)
  8004ba:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bd:	4b                   	dec    %ebx
  8004be:	85 db                	test   %ebx,%ebx
  8004c0:	7f f1                	jg     8004b3 <vprintfmt+0x1bb>
  8004c2:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004c5:	89 f3                	mov    %esi,%ebx
  8004c7:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004cd:	85 c0                	test   %eax,%eax
  8004cf:	79 05                	jns    8004d6 <vprintfmt+0x1de>
  8004d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004d9:	29 c2                	sub    %eax,%edx
  8004db:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004de:	eb 2b                	jmp    80050b <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004e4:	74 18                	je     8004fe <vprintfmt+0x206>
  8004e6:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004e9:	83 fa 5e             	cmp    $0x5e,%edx
  8004ec:	76 10                	jbe    8004fe <vprintfmt+0x206>
					putch('?', putdat);
  8004ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f2:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004f9:	ff 55 08             	call   *0x8(%ebp)
  8004fc:	eb 0a                	jmp    800508 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800502:	89 04 24             	mov    %eax,(%esp)
  800505:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800508:	ff 4d e4             	decl   -0x1c(%ebp)
  80050b:	0f be 06             	movsbl (%esi),%eax
  80050e:	46                   	inc    %esi
  80050f:	85 c0                	test   %eax,%eax
  800511:	74 21                	je     800534 <vprintfmt+0x23c>
  800513:	85 ff                	test   %edi,%edi
  800515:	78 c9                	js     8004e0 <vprintfmt+0x1e8>
  800517:	4f                   	dec    %edi
  800518:	79 c6                	jns    8004e0 <vprintfmt+0x1e8>
  80051a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80051d:	89 de                	mov    %ebx,%esi
  80051f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800522:	eb 18                	jmp    80053c <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800524:	89 74 24 04          	mov    %esi,0x4(%esp)
  800528:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80052f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800531:	4b                   	dec    %ebx
  800532:	eb 08                	jmp    80053c <vprintfmt+0x244>
  800534:	8b 7d 08             	mov    0x8(%ebp),%edi
  800537:	89 de                	mov    %ebx,%esi
  800539:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80053c:	85 db                	test   %ebx,%ebx
  80053e:	7f e4                	jg     800524 <vprintfmt+0x22c>
  800540:	89 7d 08             	mov    %edi,0x8(%ebp)
  800543:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800545:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800548:	e9 ce fd ff ff       	jmp    80031b <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80054d:	8d 45 14             	lea    0x14(%ebp),%eax
  800550:	e8 2f fd ff ff       	call   800284 <getint>
  800555:	89 c6                	mov    %eax,%esi
  800557:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800559:	85 d2                	test   %edx,%edx
  80055b:	78 07                	js     800564 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80055d:	be 0a 00 00 00       	mov    $0xa,%esi
  800562:	eb 7e                	jmp    8005e2 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800564:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800568:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80056f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800572:	89 f0                	mov    %esi,%eax
  800574:	89 fa                	mov    %edi,%edx
  800576:	f7 d8                	neg    %eax
  800578:	83 d2 00             	adc    $0x0,%edx
  80057b:	f7 da                	neg    %edx
			}
			base = 10;
  80057d:	be 0a 00 00 00       	mov    $0xa,%esi
  800582:	eb 5e                	jmp    8005e2 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800584:	8d 45 14             	lea    0x14(%ebp),%eax
  800587:	e8 be fc ff ff       	call   80024a <getuint>
			base = 10;
  80058c:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800591:	eb 4f                	jmp    8005e2 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800593:	8d 45 14             	lea    0x14(%ebp),%eax
  800596:	e8 af fc ff ff       	call   80024a <getuint>
			base = 8;
  80059b:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8005a0:	eb 40                	jmp    8005e2 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  8005a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005ad:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005bb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8d 50 04             	lea    0x4(%eax),%edx
  8005c4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005c7:	8b 00                	mov    (%eax),%eax
  8005c9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ce:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8005d3:	eb 0d                	jmp    8005e2 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d8:	e8 6d fc ff ff       	call   80024a <getuint>
			base = 16;
  8005dd:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005e2:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8005e6:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005ea:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005ed:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8005f1:	89 74 24 08          	mov    %esi,0x8(%esp)
  8005f5:	89 04 24             	mov    %eax,(%esp)
  8005f8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005fc:	89 da                	mov    %ebx,%edx
  8005fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800601:	e8 7a fb ff ff       	call   800180 <printnum>
			break;
  800606:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800609:	e9 0d fd ff ff       	jmp    80031b <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  80060e:	8d 45 14             	lea    0x14(%ebp),%eax
  800611:	e8 6e fc ff ff       	call   800284 <getint>
  800616:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  80061e:	e9 f8 fc ff ff       	jmp    80031b <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800623:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800627:	89 04 24             	mov    %eax,(%esp)
  80062a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800630:	e9 e6 fc ff ff       	jmp    80031b <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800635:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800639:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800640:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800643:	eb 01                	jmp    800646 <vprintfmt+0x34e>
  800645:	4e                   	dec    %esi
  800646:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80064a:	75 f9                	jne    800645 <vprintfmt+0x34d>
  80064c:	e9 ca fc ff ff       	jmp    80031b <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800651:	83 c4 4c             	add    $0x4c,%esp
  800654:	5b                   	pop    %ebx
  800655:	5e                   	pop    %esi
  800656:	5f                   	pop    %edi
  800657:	5d                   	pop    %ebp
  800658:	c3                   	ret    

00800659 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800659:	55                   	push   %ebp
  80065a:	89 e5                	mov    %esp,%ebp
  80065c:	83 ec 28             	sub    $0x28,%esp
  80065f:	8b 45 08             	mov    0x8(%ebp),%eax
  800662:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800665:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800668:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80066c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80066f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800676:	85 c0                	test   %eax,%eax
  800678:	74 30                	je     8006aa <vsnprintf+0x51>
  80067a:	85 d2                	test   %edx,%edx
  80067c:	7e 33                	jle    8006b1 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800685:	8b 45 10             	mov    0x10(%ebp),%eax
  800688:	89 44 24 08          	mov    %eax,0x8(%esp)
  80068c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80068f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800693:	c7 04 24 b6 02 80 00 	movl   $0x8002b6,(%esp)
  80069a:	e8 59 fc ff ff       	call   8002f8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80069f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a8:	eb 0c                	jmp    8006b6 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006af:	eb 05                	jmp    8006b6 <vsnprintf+0x5d>
  8006b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006b6:	c9                   	leave  
  8006b7:	c3                   	ret    

008006b8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006be:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8006c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d6:	89 04 24             	mov    %eax,(%esp)
  8006d9:	e8 7b ff ff ff       	call   800659 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006de:	c9                   	leave  
  8006df:	c3                   	ret    

008006e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006eb:	eb 01                	jmp    8006ee <strlen+0xe>
		n++;
  8006ed:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ee:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f2:	75 f9                	jne    8006ed <strlen+0xd>
		n++;
	return n;
}
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8006fc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800704:	eb 01                	jmp    800707 <strnlen+0x11>
		n++;
  800706:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800707:	39 d0                	cmp    %edx,%eax
  800709:	74 06                	je     800711 <strnlen+0x1b>
  80070b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80070f:	75 f5                	jne    800706 <strnlen+0x10>
		n++;
	return n;
}
  800711:	5d                   	pop    %ebp
  800712:	c3                   	ret    

00800713 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	53                   	push   %ebx
  800717:	8b 45 08             	mov    0x8(%ebp),%eax
  80071a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80071d:	ba 00 00 00 00       	mov    $0x0,%edx
  800722:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800725:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800728:	42                   	inc    %edx
  800729:	84 c9                	test   %cl,%cl
  80072b:	75 f5                	jne    800722 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80072d:	5b                   	pop    %ebx
  80072e:	5d                   	pop    %ebp
  80072f:	c3                   	ret    

00800730 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	53                   	push   %ebx
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80073a:	89 1c 24             	mov    %ebx,(%esp)
  80073d:	e8 9e ff ff ff       	call   8006e0 <strlen>
	strcpy(dst + len, src);
  800742:	8b 55 0c             	mov    0xc(%ebp),%edx
  800745:	89 54 24 04          	mov    %edx,0x4(%esp)
  800749:	01 d8                	add    %ebx,%eax
  80074b:	89 04 24             	mov    %eax,(%esp)
  80074e:	e8 c0 ff ff ff       	call   800713 <strcpy>
	return dst;
}
  800753:	89 d8                	mov    %ebx,%eax
  800755:	83 c4 08             	add    $0x8,%esp
  800758:	5b                   	pop    %ebx
  800759:	5d                   	pop    %ebp
  80075a:	c3                   	ret    

0080075b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	56                   	push   %esi
  80075f:	53                   	push   %ebx
  800760:	8b 45 08             	mov    0x8(%ebp),%eax
  800763:	8b 55 0c             	mov    0xc(%ebp),%edx
  800766:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800769:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076e:	eb 0c                	jmp    80077c <strncpy+0x21>
		*dst++ = *src;
  800770:	8a 1a                	mov    (%edx),%bl
  800772:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800775:	80 3a 01             	cmpb   $0x1,(%edx)
  800778:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077b:	41                   	inc    %ecx
  80077c:	39 f1                	cmp    %esi,%ecx
  80077e:	75 f0                	jne    800770 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800780:	5b                   	pop    %ebx
  800781:	5e                   	pop    %esi
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	56                   	push   %esi
  800788:	53                   	push   %ebx
  800789:	8b 75 08             	mov    0x8(%ebp),%esi
  80078c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800792:	85 d2                	test   %edx,%edx
  800794:	75 0a                	jne    8007a0 <strlcpy+0x1c>
  800796:	89 f0                	mov    %esi,%eax
  800798:	eb 1a                	jmp    8007b4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80079a:	88 18                	mov    %bl,(%eax)
  80079c:	40                   	inc    %eax
  80079d:	41                   	inc    %ecx
  80079e:	eb 02                	jmp    8007a2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007a2:	4a                   	dec    %edx
  8007a3:	74 0a                	je     8007af <strlcpy+0x2b>
  8007a5:	8a 19                	mov    (%ecx),%bl
  8007a7:	84 db                	test   %bl,%bl
  8007a9:	75 ef                	jne    80079a <strlcpy+0x16>
  8007ab:	89 c2                	mov    %eax,%edx
  8007ad:	eb 02                	jmp    8007b1 <strlcpy+0x2d>
  8007af:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007b1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007b4:	29 f0                	sub    %esi,%eax
}
  8007b6:	5b                   	pop    %ebx
  8007b7:	5e                   	pop    %esi
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c3:	eb 02                	jmp    8007c7 <strcmp+0xd>
		p++, q++;
  8007c5:	41                   	inc    %ecx
  8007c6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007c7:	8a 01                	mov    (%ecx),%al
  8007c9:	84 c0                	test   %al,%al
  8007cb:	74 04                	je     8007d1 <strcmp+0x17>
  8007cd:	3a 02                	cmp    (%edx),%al
  8007cf:	74 f4                	je     8007c5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d1:	0f b6 c0             	movzbl %al,%eax
  8007d4:	0f b6 12             	movzbl (%edx),%edx
  8007d7:	29 d0                	sub    %edx,%eax
}
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007e8:	eb 03                	jmp    8007ed <strncmp+0x12>
		n--, p++, q++;
  8007ea:	4a                   	dec    %edx
  8007eb:	40                   	inc    %eax
  8007ec:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007ed:	85 d2                	test   %edx,%edx
  8007ef:	74 14                	je     800805 <strncmp+0x2a>
  8007f1:	8a 18                	mov    (%eax),%bl
  8007f3:	84 db                	test   %bl,%bl
  8007f5:	74 04                	je     8007fb <strncmp+0x20>
  8007f7:	3a 19                	cmp    (%ecx),%bl
  8007f9:	74 ef                	je     8007ea <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fb:	0f b6 00             	movzbl (%eax),%eax
  8007fe:	0f b6 11             	movzbl (%ecx),%edx
  800801:	29 d0                	sub    %edx,%eax
  800803:	eb 05                	jmp    80080a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800805:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80080a:	5b                   	pop    %ebx
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	8b 45 08             	mov    0x8(%ebp),%eax
  800813:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800816:	eb 05                	jmp    80081d <strchr+0x10>
		if (*s == c)
  800818:	38 ca                	cmp    %cl,%dl
  80081a:	74 0c                	je     800828 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80081c:	40                   	inc    %eax
  80081d:	8a 10                	mov    (%eax),%dl
  80081f:	84 d2                	test   %dl,%dl
  800821:	75 f5                	jne    800818 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800823:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	8b 45 08             	mov    0x8(%ebp),%eax
  800830:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800833:	eb 05                	jmp    80083a <strfind+0x10>
		if (*s == c)
  800835:	38 ca                	cmp    %cl,%dl
  800837:	74 07                	je     800840 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800839:	40                   	inc    %eax
  80083a:	8a 10                	mov    (%eax),%dl
  80083c:	84 d2                	test   %dl,%dl
  80083e:	75 f5                	jne    800835 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	57                   	push   %edi
  800846:	56                   	push   %esi
  800847:	53                   	push   %ebx
  800848:	8b 7d 08             	mov    0x8(%ebp),%edi
  80084b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800851:	85 c9                	test   %ecx,%ecx
  800853:	74 30                	je     800885 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800855:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80085b:	75 25                	jne    800882 <memset+0x40>
  80085d:	f6 c1 03             	test   $0x3,%cl
  800860:	75 20                	jne    800882 <memset+0x40>
		c &= 0xFF;
  800862:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800865:	89 d3                	mov    %edx,%ebx
  800867:	c1 e3 08             	shl    $0x8,%ebx
  80086a:	89 d6                	mov    %edx,%esi
  80086c:	c1 e6 18             	shl    $0x18,%esi
  80086f:	89 d0                	mov    %edx,%eax
  800871:	c1 e0 10             	shl    $0x10,%eax
  800874:	09 f0                	or     %esi,%eax
  800876:	09 d0                	or     %edx,%eax
  800878:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80087a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80087d:	fc                   	cld    
  80087e:	f3 ab                	rep stos %eax,%es:(%edi)
  800880:	eb 03                	jmp    800885 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800882:	fc                   	cld    
  800883:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800885:	89 f8                	mov    %edi,%eax
  800887:	5b                   	pop    %ebx
  800888:	5e                   	pop    %esi
  800889:	5f                   	pop    %edi
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	57                   	push   %edi
  800890:	56                   	push   %esi
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
  800894:	8b 75 0c             	mov    0xc(%ebp),%esi
  800897:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80089a:	39 c6                	cmp    %eax,%esi
  80089c:	73 34                	jae    8008d2 <memmove+0x46>
  80089e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a1:	39 d0                	cmp    %edx,%eax
  8008a3:	73 2d                	jae    8008d2 <memmove+0x46>
		s += n;
		d += n;
  8008a5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a8:	f6 c2 03             	test   $0x3,%dl
  8008ab:	75 1b                	jne    8008c8 <memmove+0x3c>
  8008ad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b3:	75 13                	jne    8008c8 <memmove+0x3c>
  8008b5:	f6 c1 03             	test   $0x3,%cl
  8008b8:	75 0e                	jne    8008c8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008ba:	83 ef 04             	sub    $0x4,%edi
  8008bd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008c0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008c3:	fd                   	std    
  8008c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c6:	eb 07                	jmp    8008cf <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008c8:	4f                   	dec    %edi
  8008c9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008cc:	fd                   	std    
  8008cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008cf:	fc                   	cld    
  8008d0:	eb 20                	jmp    8008f2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d8:	75 13                	jne    8008ed <memmove+0x61>
  8008da:	a8 03                	test   $0x3,%al
  8008dc:	75 0f                	jne    8008ed <memmove+0x61>
  8008de:	f6 c1 03             	test   $0x3,%cl
  8008e1:	75 0a                	jne    8008ed <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008e3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008e6:	89 c7                	mov    %eax,%edi
  8008e8:	fc                   	cld    
  8008e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008eb:	eb 05                	jmp    8008f2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008ed:	89 c7                	mov    %eax,%edi
  8008ef:	fc                   	cld    
  8008f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008f2:	5e                   	pop    %esi
  8008f3:	5f                   	pop    %edi
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800903:	8b 45 0c             	mov    0xc(%ebp),%eax
  800906:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	89 04 24             	mov    %eax,(%esp)
  800910:	e8 77 ff ff ff       	call   80088c <memmove>
}
  800915:	c9                   	leave  
  800916:	c3                   	ret    

00800917 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	57                   	push   %edi
  80091b:	56                   	push   %esi
  80091c:	53                   	push   %ebx
  80091d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800920:	8b 75 0c             	mov    0xc(%ebp),%esi
  800923:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800926:	ba 00 00 00 00       	mov    $0x0,%edx
  80092b:	eb 16                	jmp    800943 <memcmp+0x2c>
		if (*s1 != *s2)
  80092d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800930:	42                   	inc    %edx
  800931:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800935:	38 c8                	cmp    %cl,%al
  800937:	74 0a                	je     800943 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800939:	0f b6 c0             	movzbl %al,%eax
  80093c:	0f b6 c9             	movzbl %cl,%ecx
  80093f:	29 c8                	sub    %ecx,%eax
  800941:	eb 09                	jmp    80094c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800943:	39 da                	cmp    %ebx,%edx
  800945:	75 e6                	jne    80092d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800947:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80094c:	5b                   	pop    %ebx
  80094d:	5e                   	pop    %esi
  80094e:	5f                   	pop    %edi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80095a:	89 c2                	mov    %eax,%edx
  80095c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80095f:	eb 05                	jmp    800966 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800961:	38 08                	cmp    %cl,(%eax)
  800963:	74 05                	je     80096a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800965:	40                   	inc    %eax
  800966:	39 d0                	cmp    %edx,%eax
  800968:	72 f7                	jb     800961 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	57                   	push   %edi
  800970:	56                   	push   %esi
  800971:	53                   	push   %ebx
  800972:	8b 55 08             	mov    0x8(%ebp),%edx
  800975:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800978:	eb 01                	jmp    80097b <strtol+0xf>
		s++;
  80097a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097b:	8a 02                	mov    (%edx),%al
  80097d:	3c 20                	cmp    $0x20,%al
  80097f:	74 f9                	je     80097a <strtol+0xe>
  800981:	3c 09                	cmp    $0x9,%al
  800983:	74 f5                	je     80097a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800985:	3c 2b                	cmp    $0x2b,%al
  800987:	75 08                	jne    800991 <strtol+0x25>
		s++;
  800989:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80098a:	bf 00 00 00 00       	mov    $0x0,%edi
  80098f:	eb 13                	jmp    8009a4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800991:	3c 2d                	cmp    $0x2d,%al
  800993:	75 0a                	jne    80099f <strtol+0x33>
		s++, neg = 1;
  800995:	8d 52 01             	lea    0x1(%edx),%edx
  800998:	bf 01 00 00 00       	mov    $0x1,%edi
  80099d:	eb 05                	jmp    8009a4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80099f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a4:	85 db                	test   %ebx,%ebx
  8009a6:	74 05                	je     8009ad <strtol+0x41>
  8009a8:	83 fb 10             	cmp    $0x10,%ebx
  8009ab:	75 28                	jne    8009d5 <strtol+0x69>
  8009ad:	8a 02                	mov    (%edx),%al
  8009af:	3c 30                	cmp    $0x30,%al
  8009b1:	75 10                	jne    8009c3 <strtol+0x57>
  8009b3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009b7:	75 0a                	jne    8009c3 <strtol+0x57>
		s += 2, base = 16;
  8009b9:	83 c2 02             	add    $0x2,%edx
  8009bc:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009c1:	eb 12                	jmp    8009d5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009c3:	85 db                	test   %ebx,%ebx
  8009c5:	75 0e                	jne    8009d5 <strtol+0x69>
  8009c7:	3c 30                	cmp    $0x30,%al
  8009c9:	75 05                	jne    8009d0 <strtol+0x64>
		s++, base = 8;
  8009cb:	42                   	inc    %edx
  8009cc:	b3 08                	mov    $0x8,%bl
  8009ce:	eb 05                	jmp    8009d5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009d0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009da:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009dc:	8a 0a                	mov    (%edx),%cl
  8009de:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009e1:	80 fb 09             	cmp    $0x9,%bl
  8009e4:	77 08                	ja     8009ee <strtol+0x82>
			dig = *s - '0';
  8009e6:	0f be c9             	movsbl %cl,%ecx
  8009e9:	83 e9 30             	sub    $0x30,%ecx
  8009ec:	eb 1e                	jmp    800a0c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009ee:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009f1:	80 fb 19             	cmp    $0x19,%bl
  8009f4:	77 08                	ja     8009fe <strtol+0x92>
			dig = *s - 'a' + 10;
  8009f6:	0f be c9             	movsbl %cl,%ecx
  8009f9:	83 e9 57             	sub    $0x57,%ecx
  8009fc:	eb 0e                	jmp    800a0c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8009fe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a01:	80 fb 19             	cmp    $0x19,%bl
  800a04:	77 12                	ja     800a18 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a06:	0f be c9             	movsbl %cl,%ecx
  800a09:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a0c:	39 f1                	cmp    %esi,%ecx
  800a0e:	7d 0c                	jge    800a1c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a10:	42                   	inc    %edx
  800a11:	0f af c6             	imul   %esi,%eax
  800a14:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a16:	eb c4                	jmp    8009dc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a18:	89 c1                	mov    %eax,%ecx
  800a1a:	eb 02                	jmp    800a1e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a1c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a1e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a22:	74 05                	je     800a29 <strtol+0xbd>
		*endptr = (char *) s;
  800a24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a27:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a29:	85 ff                	test   %edi,%edi
  800a2b:	74 04                	je     800a31 <strtol+0xc5>
  800a2d:	89 c8                	mov    %ecx,%eax
  800a2f:	f7 d8                	neg    %eax
}
  800a31:	5b                   	pop    %ebx
  800a32:	5e                   	pop    %esi
  800a33:	5f                   	pop    %edi
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    
	...

00800a38 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	57                   	push   %edi
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a46:	8b 55 08             	mov    0x8(%ebp),%edx
  800a49:	89 c3                	mov    %eax,%ebx
  800a4b:	89 c7                	mov    %eax,%edi
  800a4d:	89 c6                	mov    %eax,%esi
  800a4f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a51:	5b                   	pop    %ebx
  800a52:	5e                   	pop    %esi
  800a53:	5f                   	pop    %edi
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	57                   	push   %edi
  800a5a:	56                   	push   %esi
  800a5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a61:	b8 01 00 00 00       	mov    $0x1,%eax
  800a66:	89 d1                	mov    %edx,%ecx
  800a68:	89 d3                	mov    %edx,%ebx
  800a6a:	89 d7                	mov    %edx,%edi
  800a6c:	89 d6                	mov    %edx,%esi
  800a6e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5f                   	pop    %edi
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	57                   	push   %edi
  800a79:	56                   	push   %esi
  800a7a:	53                   	push   %ebx
  800a7b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a83:	b8 03 00 00 00       	mov    $0x3,%eax
  800a88:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8b:	89 cb                	mov    %ecx,%ebx
  800a8d:	89 cf                	mov    %ecx,%edi
  800a8f:	89 ce                	mov    %ecx,%esi
  800a91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a93:	85 c0                	test   %eax,%eax
  800a95:	7e 28                	jle    800abf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a9b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800aa2:	00 
  800aa3:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800aaa:	00 
  800aab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ab2:	00 
  800ab3:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800aba:	e8 e1 07 00 00       	call   8012a0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800abf:	83 c4 2c             	add    $0x2c,%esp
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ad7:	89 d1                	mov    %edx,%ecx
  800ad9:	89 d3                	mov    %edx,%ebx
  800adb:	89 d7                	mov    %edx,%edi
  800add:	89 d6                	mov    %edx,%esi
  800adf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <sys_yield>:

void
sys_yield(void)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	57                   	push   %edi
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aec:	ba 00 00 00 00       	mov    $0x0,%edx
  800af1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800af6:	89 d1                	mov    %edx,%ecx
  800af8:	89 d3                	mov    %edx,%ebx
  800afa:	89 d7                	mov    %edx,%edi
  800afc:	89 d6                	mov    %edx,%esi
  800afe:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
  800b0b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0e:	be 00 00 00 00       	mov    $0x0,%esi
  800b13:	b8 04 00 00 00       	mov    $0x4,%eax
  800b18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b21:	89 f7                	mov    %esi,%edi
  800b23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b25:	85 c0                	test   %eax,%eax
  800b27:	7e 28                	jle    800b51 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b29:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b2d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b34:	00 
  800b35:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800b3c:	00 
  800b3d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b44:	00 
  800b45:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800b4c:	e8 4f 07 00 00       	call   8012a0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b51:	83 c4 2c             	add    $0x2c,%esp
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
  800b5f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b62:	b8 05 00 00 00       	mov    $0x5,%eax
  800b67:	8b 75 18             	mov    0x18(%ebp),%esi
  800b6a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b73:	8b 55 08             	mov    0x8(%ebp),%edx
  800b76:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b78:	85 c0                	test   %eax,%eax
  800b7a:	7e 28                	jle    800ba4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b80:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800b87:	00 
  800b88:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800b8f:	00 
  800b90:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b97:	00 
  800b98:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800b9f:	e8 fc 06 00 00       	call   8012a0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba4:	83 c4 2c             	add    $0x2c,%esp
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bba:	b8 06 00 00 00       	mov    $0x6,%eax
  800bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	89 df                	mov    %ebx,%edi
  800bc7:	89 de                	mov    %ebx,%esi
  800bc9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bcb:	85 c0                	test   %eax,%eax
  800bcd:	7e 28                	jle    800bf7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800bda:	00 
  800bdb:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800be2:	00 
  800be3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bea:	00 
  800beb:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800bf2:	e8 a9 06 00 00       	call   8012a0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf7:	83 c4 2c             	add    $0x2c,%esp
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	89 df                	mov    %ebx,%edi
  800c1a:	89 de                	mov    %ebx,%esi
  800c1c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	7e 28                	jle    800c4a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c22:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c26:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c2d:	00 
  800c2e:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800c35:	00 
  800c36:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c3d:	00 
  800c3e:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800c45:	e8 56 06 00 00       	call   8012a0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c4a:	83 c4 2c             	add    $0x2c,%esp
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    

00800c52 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c60:	b8 09 00 00 00       	mov    $0x9,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	89 df                	mov    %ebx,%edi
  800c6d:	89 de                	mov    %ebx,%esi
  800c6f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c71:	85 c0                	test   %eax,%eax
  800c73:	7e 28                	jle    800c9d <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c75:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c79:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c80:	00 
  800c81:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800c88:	00 
  800c89:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c90:	00 
  800c91:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800c98:	e8 03 06 00 00       	call   8012a0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c9d:	83 c4 2c             	add    $0x2c,%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	be 00 00 00 00       	mov    $0x0,%esi
  800cb0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
  800cce:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cde:	89 cb                	mov    %ecx,%ebx
  800ce0:	89 cf                	mov    %ecx,%edi
  800ce2:	89 ce                	mov    %ecx,%esi
  800ce4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7e 28                	jle    800d12 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cea:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cee:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800cf5:	00 
  800cf6:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800cfd:	00 
  800cfe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d05:	00 
  800d06:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800d0d:	e8 8e 05 00 00       	call   8012a0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d12:	83 c4 2c             	add    $0x2c,%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	57                   	push   %edi
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
  800d20:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d28:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d30:	8b 55 08             	mov    0x8(%ebp),%edx
  800d33:	89 df                	mov    %ebx,%edi
  800d35:	89 de                	mov    %ebx,%esi
  800d37:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	7e 28                	jle    800d65 <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d41:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d48:	00 
  800d49:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800d50:	00 
  800d51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d58:	00 
  800d59:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800d60:	e8 3b 05 00 00       	call   8012a0 <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800d65:	83 c4 2c             	add    $0x2c,%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_env_set_debug_upcall>:

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
  800d73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	89 df                	mov    %ebx,%edi
  800d88:	89 de                	mov    %ebx,%esi
  800d8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	7e 28                	jle    800db8 <sys_env_set_debug_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d94:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800d9b:	00 
  800d9c:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800da3:	00 
  800da4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dab:	00 
  800dac:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800db3:	e8 e8 04 00 00       	call   8012a0 <_panic>
}

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_debug_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800db8:	83 c4 2c             	add    $0x2c,%esp
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_env_set_nmskint_upcall>:

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dce:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd9:	89 df                	mov    %ebx,%edi
  800ddb:	89 de                	mov    %ebx,%esi
  800ddd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	7e 28                	jle    800e0b <sys_env_set_nmskint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de7:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800dee:	00 
  800def:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800df6:	00 
  800df7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dfe:	00 
  800dff:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800e06:	e8 95 04 00 00       	call   8012a0 <_panic>
}

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_nmskint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800e0b:	83 c4 2c             	add    $0x2c,%esp
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <sys_env_set_bpoint_upcall>:

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e21:	b8 10 00 00 00       	mov    $0x10,%eax
  800e26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e29:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2c:	89 df                	mov    %ebx,%edi
  800e2e:	89 de                	mov    %ebx,%esi
  800e30:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e32:	85 c0                	test   %eax,%eax
  800e34:	7e 28                	jle    800e5e <sys_env_set_bpoint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e36:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3a:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800e41:	00 
  800e42:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800e49:	00 
  800e4a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e51:	00 
  800e52:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800e59:	e8 42 04 00 00       	call   8012a0 <_panic>
}

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bpoint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800e5e:	83 c4 2c             	add    $0x2c,%esp
  800e61:	5b                   	pop    %ebx
  800e62:	5e                   	pop    %esi
  800e63:	5f                   	pop    %edi
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <sys_env_set_oflow_upcall>:

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	57                   	push   %edi
  800e6a:	56                   	push   %esi
  800e6b:	53                   	push   %ebx
  800e6c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e74:	b8 11 00 00 00       	mov    $0x11,%eax
  800e79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7f:	89 df                	mov    %ebx,%edi
  800e81:	89 de                	mov    %ebx,%esi
  800e83:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e85:	85 c0                	test   %eax,%eax
  800e87:	7e 28                	jle    800eb1 <sys_env_set_oflow_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e89:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8d:	c7 44 24 0c 11 00 00 	movl   $0x11,0xc(%esp)
  800e94:	00 
  800e95:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800e9c:	00 
  800e9d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea4:	00 
  800ea5:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800eac:	e8 ef 03 00 00       	call   8012a0 <_panic>
}

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_oflow_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800eb1:	83 c4 2c             	add    $0x2c,%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <sys_env_set_bdschk_upcall>:

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	57                   	push   %edi
  800ebd:	56                   	push   %esi
  800ebe:	53                   	push   %ebx
  800ebf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec7:	b8 12 00 00 00       	mov    $0x12,%eax
  800ecc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed2:	89 df                	mov    %ebx,%edi
  800ed4:	89 de                	mov    %ebx,%esi
  800ed6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	7e 28                	jle    800f04 <sys_env_set_bdschk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee0:	c7 44 24 0c 12 00 00 	movl   $0x12,0xc(%esp)
  800ee7:	00 
  800ee8:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800eef:	00 
  800ef0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef7:	00 
  800ef8:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800eff:	e8 9c 03 00 00       	call   8012a0 <_panic>
}

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bdschk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800f04:	83 c4 2c             	add    $0x2c,%esp
  800f07:	5b                   	pop    %ebx
  800f08:	5e                   	pop    %esi
  800f09:	5f                   	pop    %edi
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <sys_env_set_illopcd_upcall>:

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	57                   	push   %edi
  800f10:	56                   	push   %esi
  800f11:	53                   	push   %ebx
  800f12:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1a:	b8 13 00 00 00       	mov    $0x13,%eax
  800f1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f22:	8b 55 08             	mov    0x8(%ebp),%edx
  800f25:	89 df                	mov    %ebx,%edi
  800f27:	89 de                	mov    %ebx,%esi
  800f29:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	7e 28                	jle    800f57 <sys_env_set_illopcd_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f33:	c7 44 24 0c 13 00 00 	movl   $0x13,0xc(%esp)
  800f3a:	00 
  800f3b:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800f42:	00 
  800f43:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4a:	00 
  800f4b:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800f52:	e8 49 03 00 00       	call   8012a0 <_panic>
}

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_illopcd_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800f57:	83 c4 2c             	add    $0x2c,%esp
  800f5a:	5b                   	pop    %ebx
  800f5b:	5e                   	pop    %esi
  800f5c:	5f                   	pop    %edi
  800f5d:	5d                   	pop    %ebp
  800f5e:	c3                   	ret    

00800f5f <sys_env_set_dvcntavl_upcall>:

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	57                   	push   %edi
  800f63:	56                   	push   %esi
  800f64:	53                   	push   %ebx
  800f65:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f6d:	b8 14 00 00 00       	mov    $0x14,%eax
  800f72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f75:	8b 55 08             	mov    0x8(%ebp),%edx
  800f78:	89 df                	mov    %ebx,%edi
  800f7a:	89 de                	mov    %ebx,%esi
  800f7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	7e 28                	jle    800faa <sys_env_set_dvcntavl_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f86:	c7 44 24 0c 14 00 00 	movl   $0x14,0xc(%esp)
  800f8d:	00 
  800f8e:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800f95:	00 
  800f96:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f9d:	00 
  800f9e:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800fa5:	e8 f6 02 00 00       	call   8012a0 <_panic>
}

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dvcntavl_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800faa:	83 c4 2c             	add    $0x2c,%esp
  800fad:	5b                   	pop    %ebx
  800fae:	5e                   	pop    %esi
  800faf:	5f                   	pop    %edi
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    

00800fb2 <sys_env_set_dbfault_upcall>:

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	57                   	push   %edi
  800fb6:	56                   	push   %esi
  800fb7:	53                   	push   %ebx
  800fb8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc0:	b8 15 00 00 00       	mov    $0x15,%eax
  800fc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcb:	89 df                	mov    %ebx,%edi
  800fcd:	89 de                	mov    %ebx,%esi
  800fcf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	7e 28                	jle    800ffd <sys_env_set_dbfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd9:	c7 44 24 0c 15 00 00 	movl   $0x15,0xc(%esp)
  800fe0:	00 
  800fe1:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800fe8:	00 
  800fe9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ff0:	00 
  800ff1:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800ff8:	e8 a3 02 00 00       	call   8012a0 <_panic>
}

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dbfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800ffd:	83 c4 2c             	add    $0x2c,%esp
  801000:	5b                   	pop    %ebx
  801001:	5e                   	pop    %esi
  801002:	5f                   	pop    %edi
  801003:	5d                   	pop    %ebp
  801004:	c3                   	ret    

00801005 <sys_env_set_ivldtss_upcall>:

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	57                   	push   %edi
  801009:	56                   	push   %esi
  80100a:	53                   	push   %ebx
  80100b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801013:	b8 16 00 00 00       	mov    $0x16,%eax
  801018:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101b:	8b 55 08             	mov    0x8(%ebp),%edx
  80101e:	89 df                	mov    %ebx,%edi
  801020:	89 de                	mov    %ebx,%esi
  801022:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801024:	85 c0                	test   %eax,%eax
  801026:	7e 28                	jle    801050 <sys_env_set_ivldtss_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801028:	89 44 24 10          	mov    %eax,0x10(%esp)
  80102c:	c7 44 24 0c 16 00 00 	movl   $0x16,0xc(%esp)
  801033:	00 
  801034:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  80103b:	00 
  80103c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801043:	00 
  801044:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  80104b:	e8 50 02 00 00       	call   8012a0 <_panic>
}

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_ivldtss_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801050:	83 c4 2c             	add    $0x2c,%esp
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <sys_env_set_segntprst_upcall>:

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	57                   	push   %edi
  80105c:	56                   	push   %esi
  80105d:	53                   	push   %ebx
  80105e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801061:	bb 00 00 00 00       	mov    $0x0,%ebx
  801066:	b8 17 00 00 00       	mov    $0x17,%eax
  80106b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106e:	8b 55 08             	mov    0x8(%ebp),%edx
  801071:	89 df                	mov    %ebx,%edi
  801073:	89 de                	mov    %ebx,%esi
  801075:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801077:	85 c0                	test   %eax,%eax
  801079:	7e 28                	jle    8010a3 <sys_env_set_segntprst_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80107f:	c7 44 24 0c 17 00 00 	movl   $0x17,0xc(%esp)
  801086:	00 
  801087:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  80108e:	00 
  80108f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801096:	00 
  801097:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  80109e:	e8 fd 01 00 00       	call   8012a0 <_panic>
}

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_segntprst_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8010a3:	83 c4 2c             	add    $0x2c,%esp
  8010a6:	5b                   	pop    %ebx
  8010a7:	5e                   	pop    %esi
  8010a8:	5f                   	pop    %edi
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <sys_env_set_stkexception_upcall>:

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	57                   	push   %edi
  8010af:	56                   	push   %esi
  8010b0:	53                   	push   %ebx
  8010b1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b9:	b8 18 00 00 00       	mov    $0x18,%eax
  8010be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c4:	89 df                	mov    %ebx,%edi
  8010c6:	89 de                	mov    %ebx,%esi
  8010c8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010ca:	85 c0                	test   %eax,%eax
  8010cc:	7e 28                	jle    8010f6 <sys_env_set_stkexception_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ce:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010d2:	c7 44 24 0c 18 00 00 	movl   $0x18,0xc(%esp)
  8010d9:	00 
  8010da:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  8010e1:	00 
  8010e2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010e9:	00 
  8010ea:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  8010f1:	e8 aa 01 00 00       	call   8012a0 <_panic>
}

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_stkexception_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8010f6:	83 c4 2c             	add    $0x2c,%esp
  8010f9:	5b                   	pop    %ebx
  8010fa:	5e                   	pop    %esi
  8010fb:	5f                   	pop    %edi
  8010fc:	5d                   	pop    %ebp
  8010fd:	c3                   	ret    

008010fe <sys_env_set_gpfault_upcall>:

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	57                   	push   %edi
  801102:	56                   	push   %esi
  801103:	53                   	push   %ebx
  801104:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801107:	bb 00 00 00 00       	mov    $0x0,%ebx
  80110c:	b8 19 00 00 00       	mov    $0x19,%eax
  801111:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801114:	8b 55 08             	mov    0x8(%ebp),%edx
  801117:	89 df                	mov    %ebx,%edi
  801119:	89 de                	mov    %ebx,%esi
  80111b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80111d:	85 c0                	test   %eax,%eax
  80111f:	7e 28                	jle    801149 <sys_env_set_gpfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801121:	89 44 24 10          	mov    %eax,0x10(%esp)
  801125:	c7 44 24 0c 19 00 00 	movl   $0x19,0xc(%esp)
  80112c:	00 
  80112d:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  801134:	00 
  801135:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80113c:	00 
  80113d:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  801144:	e8 57 01 00 00       	call   8012a0 <_panic>
}

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_gpfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801149:	83 c4 2c             	add    $0x2c,%esp
  80114c:	5b                   	pop    %ebx
  80114d:	5e                   	pop    %esi
  80114e:	5f                   	pop    %edi
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    

00801151 <sys_env_set_fperror_upcall>:

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	57                   	push   %edi
  801155:	56                   	push   %esi
  801156:	53                   	push   %ebx
  801157:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80115a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80115f:	b8 1a 00 00 00       	mov    $0x1a,%eax
  801164:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801167:	8b 55 08             	mov    0x8(%ebp),%edx
  80116a:	89 df                	mov    %ebx,%edi
  80116c:	89 de                	mov    %ebx,%esi
  80116e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801170:	85 c0                	test   %eax,%eax
  801172:	7e 28                	jle    80119c <sys_env_set_fperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801174:	89 44 24 10          	mov    %eax,0x10(%esp)
  801178:	c7 44 24 0c 1a 00 00 	movl   $0x1a,0xc(%esp)
  80117f:	00 
  801180:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  801187:	00 
  801188:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80118f:	00 
  801190:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  801197:	e8 04 01 00 00       	call   8012a0 <_panic>
}

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_fperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80119c:	83 c4 2c             	add    $0x2c,%esp
  80119f:	5b                   	pop    %ebx
  8011a0:	5e                   	pop    %esi
  8011a1:	5f                   	pop    %edi
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <sys_env_set_algchk_upcall>:

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	57                   	push   %edi
  8011a8:	56                   	push   %esi
  8011a9:	53                   	push   %ebx
  8011aa:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b2:	b8 1b 00 00 00       	mov    $0x1b,%eax
  8011b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8011bd:	89 df                	mov    %ebx,%edi
  8011bf:	89 de                	mov    %ebx,%esi
  8011c1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	7e 28                	jle    8011ef <sys_env_set_algchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011cb:	c7 44 24 0c 1b 00 00 	movl   $0x1b,0xc(%esp)
  8011d2:	00 
  8011d3:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  8011da:	00 
  8011db:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011e2:	00 
  8011e3:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  8011ea:	e8 b1 00 00 00       	call   8012a0 <_panic>
}

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_algchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8011ef:	83 c4 2c             	add    $0x2c,%esp
  8011f2:	5b                   	pop    %ebx
  8011f3:	5e                   	pop    %esi
  8011f4:	5f                   	pop    %edi
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <sys_env_set_mchchk_upcall>:

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	57                   	push   %edi
  8011fb:	56                   	push   %esi
  8011fc:	53                   	push   %ebx
  8011fd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801200:	bb 00 00 00 00       	mov    $0x0,%ebx
  801205:	b8 1c 00 00 00       	mov    $0x1c,%eax
  80120a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120d:	8b 55 08             	mov    0x8(%ebp),%edx
  801210:	89 df                	mov    %ebx,%edi
  801212:	89 de                	mov    %ebx,%esi
  801214:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801216:	85 c0                	test   %eax,%eax
  801218:	7e 28                	jle    801242 <sys_env_set_mchchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80121a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80121e:	c7 44 24 0c 1c 00 00 	movl   $0x1c,0xc(%esp)
  801225:	00 
  801226:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  80122d:	00 
  80122e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801235:	00 
  801236:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  80123d:	e8 5e 00 00 00       	call   8012a0 <_panic>
}

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_mchchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801242:	83 c4 2c             	add    $0x2c,%esp
  801245:	5b                   	pop    %ebx
  801246:	5e                   	pop    %esi
  801247:	5f                   	pop    %edi
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <sys_env_set_SIMDfperror_upcall>:

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	57                   	push   %edi
  80124e:	56                   	push   %esi
  80124f:	53                   	push   %ebx
  801250:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801253:	bb 00 00 00 00       	mov    $0x0,%ebx
  801258:	b8 1d 00 00 00       	mov    $0x1d,%eax
  80125d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801260:	8b 55 08             	mov    0x8(%ebp),%edx
  801263:	89 df                	mov    %ebx,%edi
  801265:	89 de                	mov    %ebx,%esi
  801267:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801269:	85 c0                	test   %eax,%eax
  80126b:	7e 28                	jle    801295 <sys_env_set_SIMDfperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80126d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801271:	c7 44 24 0c 1d 00 00 	movl   $0x1d,0xc(%esp)
  801278:	00 
  801279:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  801280:	00 
  801281:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801288:	00 
  801289:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  801290:	e8 0b 00 00 00       	call   8012a0 <_panic>
}

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_SIMDfperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801295:	83 c4 2c             	add    $0x2c,%esp
  801298:	5b                   	pop    %ebx
  801299:	5e                   	pop    %esi
  80129a:	5f                   	pop    %edi
  80129b:	5d                   	pop    %ebp
  80129c:	c3                   	ret    
  80129d:	00 00                	add    %al,(%eax)
	...

008012a0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	56                   	push   %esi
  8012a4:	53                   	push   %ebx
  8012a5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8012a8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012ab:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8012b1:	e8 11 f8 ff ff       	call   800ac7 <sys_getenvid>
  8012b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012c4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cc:	c7 04 24 14 18 80 00 	movl   $0x801814,(%esp)
  8012d3:	e8 8c ee ff ff       	call   800164 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8012d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8012df:	89 04 24             	mov    %eax,(%esp)
  8012e2:	e8 1c ee ff ff       	call   800103 <vcprintf>
	cprintf("\n");
  8012e7:	c7 04 24 6c 15 80 00 	movl   $0x80156c,(%esp)
  8012ee:	e8 71 ee ff ff       	call   800164 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8012f3:	cc                   	int3   
  8012f4:	eb fd                	jmp    8012f3 <_panic+0x53>
	...

008012f8 <__udivdi3>:
  8012f8:	55                   	push   %ebp
  8012f9:	57                   	push   %edi
  8012fa:	56                   	push   %esi
  8012fb:	83 ec 10             	sub    $0x10,%esp
  8012fe:	8b 74 24 20          	mov    0x20(%esp),%esi
  801302:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801306:	89 74 24 04          	mov    %esi,0x4(%esp)
  80130a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80130e:	89 cd                	mov    %ecx,%ebp
  801310:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801314:	85 c0                	test   %eax,%eax
  801316:	75 2c                	jne    801344 <__udivdi3+0x4c>
  801318:	39 f9                	cmp    %edi,%ecx
  80131a:	77 68                	ja     801384 <__udivdi3+0x8c>
  80131c:	85 c9                	test   %ecx,%ecx
  80131e:	75 0b                	jne    80132b <__udivdi3+0x33>
  801320:	b8 01 00 00 00       	mov    $0x1,%eax
  801325:	31 d2                	xor    %edx,%edx
  801327:	f7 f1                	div    %ecx
  801329:	89 c1                	mov    %eax,%ecx
  80132b:	31 d2                	xor    %edx,%edx
  80132d:	89 f8                	mov    %edi,%eax
  80132f:	f7 f1                	div    %ecx
  801331:	89 c7                	mov    %eax,%edi
  801333:	89 f0                	mov    %esi,%eax
  801335:	f7 f1                	div    %ecx
  801337:	89 c6                	mov    %eax,%esi
  801339:	89 f0                	mov    %esi,%eax
  80133b:	89 fa                	mov    %edi,%edx
  80133d:	83 c4 10             	add    $0x10,%esp
  801340:	5e                   	pop    %esi
  801341:	5f                   	pop    %edi
  801342:	5d                   	pop    %ebp
  801343:	c3                   	ret    
  801344:	39 f8                	cmp    %edi,%eax
  801346:	77 2c                	ja     801374 <__udivdi3+0x7c>
  801348:	0f bd f0             	bsr    %eax,%esi
  80134b:	83 f6 1f             	xor    $0x1f,%esi
  80134e:	75 4c                	jne    80139c <__udivdi3+0xa4>
  801350:	39 f8                	cmp    %edi,%eax
  801352:	bf 00 00 00 00       	mov    $0x0,%edi
  801357:	72 0a                	jb     801363 <__udivdi3+0x6b>
  801359:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80135d:	0f 87 ad 00 00 00    	ja     801410 <__udivdi3+0x118>
  801363:	be 01 00 00 00       	mov    $0x1,%esi
  801368:	89 f0                	mov    %esi,%eax
  80136a:	89 fa                	mov    %edi,%edx
  80136c:	83 c4 10             	add    $0x10,%esp
  80136f:	5e                   	pop    %esi
  801370:	5f                   	pop    %edi
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    
  801373:	90                   	nop
  801374:	31 ff                	xor    %edi,%edi
  801376:	31 f6                	xor    %esi,%esi
  801378:	89 f0                	mov    %esi,%eax
  80137a:	89 fa                	mov    %edi,%edx
  80137c:	83 c4 10             	add    $0x10,%esp
  80137f:	5e                   	pop    %esi
  801380:	5f                   	pop    %edi
  801381:	5d                   	pop    %ebp
  801382:	c3                   	ret    
  801383:	90                   	nop
  801384:	89 fa                	mov    %edi,%edx
  801386:	89 f0                	mov    %esi,%eax
  801388:	f7 f1                	div    %ecx
  80138a:	89 c6                	mov    %eax,%esi
  80138c:	31 ff                	xor    %edi,%edi
  80138e:	89 f0                	mov    %esi,%eax
  801390:	89 fa                	mov    %edi,%edx
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	5e                   	pop    %esi
  801396:	5f                   	pop    %edi
  801397:	5d                   	pop    %ebp
  801398:	c3                   	ret    
  801399:	8d 76 00             	lea    0x0(%esi),%esi
  80139c:	89 f1                	mov    %esi,%ecx
  80139e:	d3 e0                	shl    %cl,%eax
  8013a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013a4:	b8 20 00 00 00       	mov    $0x20,%eax
  8013a9:	29 f0                	sub    %esi,%eax
  8013ab:	89 ea                	mov    %ebp,%edx
  8013ad:	88 c1                	mov    %al,%cl
  8013af:	d3 ea                	shr    %cl,%edx
  8013b1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8013b5:	09 ca                	or     %ecx,%edx
  8013b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013bb:	89 f1                	mov    %esi,%ecx
  8013bd:	d3 e5                	shl    %cl,%ebp
  8013bf:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8013c3:	89 fd                	mov    %edi,%ebp
  8013c5:	88 c1                	mov    %al,%cl
  8013c7:	d3 ed                	shr    %cl,%ebp
  8013c9:	89 fa                	mov    %edi,%edx
  8013cb:	89 f1                	mov    %esi,%ecx
  8013cd:	d3 e2                	shl    %cl,%edx
  8013cf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013d3:	88 c1                	mov    %al,%cl
  8013d5:	d3 ef                	shr    %cl,%edi
  8013d7:	09 d7                	or     %edx,%edi
  8013d9:	89 f8                	mov    %edi,%eax
  8013db:	89 ea                	mov    %ebp,%edx
  8013dd:	f7 74 24 08          	divl   0x8(%esp)
  8013e1:	89 d1                	mov    %edx,%ecx
  8013e3:	89 c7                	mov    %eax,%edi
  8013e5:	f7 64 24 0c          	mull   0xc(%esp)
  8013e9:	39 d1                	cmp    %edx,%ecx
  8013eb:	72 17                	jb     801404 <__udivdi3+0x10c>
  8013ed:	74 09                	je     8013f8 <__udivdi3+0x100>
  8013ef:	89 fe                	mov    %edi,%esi
  8013f1:	31 ff                	xor    %edi,%edi
  8013f3:	e9 41 ff ff ff       	jmp    801339 <__udivdi3+0x41>
  8013f8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013fc:	89 f1                	mov    %esi,%ecx
  8013fe:	d3 e2                	shl    %cl,%edx
  801400:	39 c2                	cmp    %eax,%edx
  801402:	73 eb                	jae    8013ef <__udivdi3+0xf7>
  801404:	8d 77 ff             	lea    -0x1(%edi),%esi
  801407:	31 ff                	xor    %edi,%edi
  801409:	e9 2b ff ff ff       	jmp    801339 <__udivdi3+0x41>
  80140e:	66 90                	xchg   %ax,%ax
  801410:	31 f6                	xor    %esi,%esi
  801412:	e9 22 ff ff ff       	jmp    801339 <__udivdi3+0x41>
	...

00801418 <__umoddi3>:
  801418:	55                   	push   %ebp
  801419:	57                   	push   %edi
  80141a:	56                   	push   %esi
  80141b:	83 ec 20             	sub    $0x20,%esp
  80141e:	8b 44 24 30          	mov    0x30(%esp),%eax
  801422:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801426:	89 44 24 14          	mov    %eax,0x14(%esp)
  80142a:	8b 74 24 34          	mov    0x34(%esp),%esi
  80142e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801432:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801436:	89 c7                	mov    %eax,%edi
  801438:	89 f2                	mov    %esi,%edx
  80143a:	85 ed                	test   %ebp,%ebp
  80143c:	75 16                	jne    801454 <__umoddi3+0x3c>
  80143e:	39 f1                	cmp    %esi,%ecx
  801440:	0f 86 a6 00 00 00    	jbe    8014ec <__umoddi3+0xd4>
  801446:	f7 f1                	div    %ecx
  801448:	89 d0                	mov    %edx,%eax
  80144a:	31 d2                	xor    %edx,%edx
  80144c:	83 c4 20             	add    $0x20,%esp
  80144f:	5e                   	pop    %esi
  801450:	5f                   	pop    %edi
  801451:	5d                   	pop    %ebp
  801452:	c3                   	ret    
  801453:	90                   	nop
  801454:	39 f5                	cmp    %esi,%ebp
  801456:	0f 87 ac 00 00 00    	ja     801508 <__umoddi3+0xf0>
  80145c:	0f bd c5             	bsr    %ebp,%eax
  80145f:	83 f0 1f             	xor    $0x1f,%eax
  801462:	89 44 24 10          	mov    %eax,0x10(%esp)
  801466:	0f 84 a8 00 00 00    	je     801514 <__umoddi3+0xfc>
  80146c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801470:	d3 e5                	shl    %cl,%ebp
  801472:	bf 20 00 00 00       	mov    $0x20,%edi
  801477:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80147b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80147f:	89 f9                	mov    %edi,%ecx
  801481:	d3 e8                	shr    %cl,%eax
  801483:	09 e8                	or     %ebp,%eax
  801485:	89 44 24 18          	mov    %eax,0x18(%esp)
  801489:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80148d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801491:	d3 e0                	shl    %cl,%eax
  801493:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801497:	89 f2                	mov    %esi,%edx
  801499:	d3 e2                	shl    %cl,%edx
  80149b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80149f:	d3 e0                	shl    %cl,%eax
  8014a1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8014a5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8014a9:	89 f9                	mov    %edi,%ecx
  8014ab:	d3 e8                	shr    %cl,%eax
  8014ad:	09 d0                	or     %edx,%eax
  8014af:	d3 ee                	shr    %cl,%esi
  8014b1:	89 f2                	mov    %esi,%edx
  8014b3:	f7 74 24 18          	divl   0x18(%esp)
  8014b7:	89 d6                	mov    %edx,%esi
  8014b9:	f7 64 24 0c          	mull   0xc(%esp)
  8014bd:	89 c5                	mov    %eax,%ebp
  8014bf:	89 d1                	mov    %edx,%ecx
  8014c1:	39 d6                	cmp    %edx,%esi
  8014c3:	72 67                	jb     80152c <__umoddi3+0x114>
  8014c5:	74 75                	je     80153c <__umoddi3+0x124>
  8014c7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8014cb:	29 e8                	sub    %ebp,%eax
  8014cd:	19 ce                	sbb    %ecx,%esi
  8014cf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014d3:	d3 e8                	shr    %cl,%eax
  8014d5:	89 f2                	mov    %esi,%edx
  8014d7:	89 f9                	mov    %edi,%ecx
  8014d9:	d3 e2                	shl    %cl,%edx
  8014db:	09 d0                	or     %edx,%eax
  8014dd:	89 f2                	mov    %esi,%edx
  8014df:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014e3:	d3 ea                	shr    %cl,%edx
  8014e5:	83 c4 20             	add    $0x20,%esp
  8014e8:	5e                   	pop    %esi
  8014e9:	5f                   	pop    %edi
  8014ea:	5d                   	pop    %ebp
  8014eb:	c3                   	ret    
  8014ec:	85 c9                	test   %ecx,%ecx
  8014ee:	75 0b                	jne    8014fb <__umoddi3+0xe3>
  8014f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8014f5:	31 d2                	xor    %edx,%edx
  8014f7:	f7 f1                	div    %ecx
  8014f9:	89 c1                	mov    %eax,%ecx
  8014fb:	89 f0                	mov    %esi,%eax
  8014fd:	31 d2                	xor    %edx,%edx
  8014ff:	f7 f1                	div    %ecx
  801501:	89 f8                	mov    %edi,%eax
  801503:	e9 3e ff ff ff       	jmp    801446 <__umoddi3+0x2e>
  801508:	89 f2                	mov    %esi,%edx
  80150a:	83 c4 20             	add    $0x20,%esp
  80150d:	5e                   	pop    %esi
  80150e:	5f                   	pop    %edi
  80150f:	5d                   	pop    %ebp
  801510:	c3                   	ret    
  801511:	8d 76 00             	lea    0x0(%esi),%esi
  801514:	39 f5                	cmp    %esi,%ebp
  801516:	72 04                	jb     80151c <__umoddi3+0x104>
  801518:	39 f9                	cmp    %edi,%ecx
  80151a:	77 06                	ja     801522 <__umoddi3+0x10a>
  80151c:	89 f2                	mov    %esi,%edx
  80151e:	29 cf                	sub    %ecx,%edi
  801520:	19 ea                	sbb    %ebp,%edx
  801522:	89 f8                	mov    %edi,%eax
  801524:	83 c4 20             	add    $0x20,%esp
  801527:	5e                   	pop    %esi
  801528:	5f                   	pop    %edi
  801529:	5d                   	pop    %ebp
  80152a:	c3                   	ret    
  80152b:	90                   	nop
  80152c:	89 d1                	mov    %edx,%ecx
  80152e:	89 c5                	mov    %eax,%ebp
  801530:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801534:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801538:	eb 8d                	jmp    8014c7 <__umoddi3+0xaf>
  80153a:	66 90                	xchg   %ax,%ax
  80153c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801540:	72 ea                	jb     80152c <__umoddi3+0x114>
  801542:	89 f1                	mov    %esi,%ecx
  801544:	eb 81                	jmp    8014c7 <__umoddi3+0xaf>
