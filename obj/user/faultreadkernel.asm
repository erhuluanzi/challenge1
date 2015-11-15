
obj/user/faultreadkernel:     file format elf32-i386


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

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  80003a:	a1 00 00 10 f0       	mov    0xf0100000,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 40 15 80 00 	movl   $0x801540,(%esp)
  80004a:	e8 09 01 00 00       	call   800158 <cprintf>
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
  800062:	e8 54 0a 00 00       	call   800abb <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80006f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800072:	c1 e0 04             	shl    $0x4,%eax
  800075:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007a:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007f:	85 f6                	test   %esi,%esi
  800081:	7e 07                	jle    80008a <libmain+0x36>
		binaryname = argv[0];
  800083:	8b 03                	mov    (%ebx),%eax
  800085:	a3 00 20 80 00       	mov    %eax,0x802000

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
  8000b1:	e8 b3 09 00 00       	call   800a69 <sys_env_destroy>
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 14             	sub    $0x14,%esp
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c2:	8b 03                	mov    (%ebx),%eax
  8000c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000cb:	40                   	inc    %eax
  8000cc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d3:	75 19                	jne    8000ee <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000d5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000dc:	00 
  8000dd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e0:	89 04 24             	mov    %eax,(%esp)
  8000e3:	e8 44 09 00 00       	call   800a2c <sys_cputs>
		b->idx = 0;
  8000e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000ee:	ff 43 04             	incl   0x4(%ebx)
}
  8000f1:	83 c4 14             	add    $0x14,%esp
  8000f4:	5b                   	pop    %ebx
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800100:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800107:	00 00 00 
	b.cnt = 0;
  80010a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800111:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800114:	8b 45 0c             	mov    0xc(%ebp),%eax
  800117:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011b:	8b 45 08             	mov    0x8(%ebp),%eax
  80011e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800122:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800128:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012c:	c7 04 24 b8 00 80 00 	movl   $0x8000b8,(%esp)
  800133:	e8 b4 01 00 00       	call   8002ec <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800138:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80013e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800142:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800148:	89 04 24             	mov    %eax,(%esp)
  80014b:	e8 dc 08 00 00       	call   800a2c <sys_cputs>

	return b.cnt;
}
  800150:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800161:	89 44 24 04          	mov    %eax,0x4(%esp)
  800165:	8b 45 08             	mov    0x8(%ebp),%eax
  800168:	89 04 24             	mov    %eax,(%esp)
  80016b:	e8 87 ff ff ff       	call   8000f7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800170:	c9                   	leave  
  800171:	c3                   	ret    
	...

00800174 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	57                   	push   %edi
  800178:	56                   	push   %esi
  800179:	53                   	push   %ebx
  80017a:	83 ec 3c             	sub    $0x3c,%esp
  80017d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800180:	89 d7                	mov    %edx,%edi
  800182:	8b 45 08             	mov    0x8(%ebp),%eax
  800185:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800188:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80018e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800191:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800194:	85 c0                	test   %eax,%eax
  800196:	75 08                	jne    8001a0 <printnum+0x2c>
  800198:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80019b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80019e:	77 57                	ja     8001f7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001a4:	4b                   	dec    %ebx
  8001a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001b4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001bf:	00 
  8001c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001c3:	89 04 24             	mov    %eax,(%esp)
  8001c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cd:	e8 1a 11 00 00       	call   8012ec <__udivdi3>
  8001d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001da:	89 04 24             	mov    %eax,(%esp)
  8001dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001e1:	89 fa                	mov    %edi,%edx
  8001e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001e6:	e8 89 ff ff ff       	call   800174 <printnum>
  8001eb:	eb 0f                	jmp    8001fc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001f1:	89 34 24             	mov    %esi,(%esp)
  8001f4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f7:	4b                   	dec    %ebx
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7f f1                	jg     8001ed <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800200:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800204:	8b 45 10             	mov    0x10(%ebp),%eax
  800207:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800212:	00 
  800213:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800216:	89 04 24             	mov    %eax,(%esp)
  800219:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80021c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800220:	e8 e7 11 00 00       	call   80140c <__umoddi3>
  800225:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800229:	0f be 80 71 15 80 00 	movsbl 0x801571(%eax),%eax
  800230:	89 04 24             	mov    %eax,(%esp)
  800233:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800236:	83 c4 3c             	add    $0x3c,%esp
  800239:	5b                   	pop    %ebx
  80023a:	5e                   	pop    %esi
  80023b:	5f                   	pop    %edi
  80023c:	5d                   	pop    %ebp
  80023d:	c3                   	ret    

0080023e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800241:	83 fa 01             	cmp    $0x1,%edx
  800244:	7e 0e                	jle    800254 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800246:	8b 10                	mov    (%eax),%edx
  800248:	8d 4a 08             	lea    0x8(%edx),%ecx
  80024b:	89 08                	mov    %ecx,(%eax)
  80024d:	8b 02                	mov    (%edx),%eax
  80024f:	8b 52 04             	mov    0x4(%edx),%edx
  800252:	eb 22                	jmp    800276 <getuint+0x38>
	else if (lflag)
  800254:	85 d2                	test   %edx,%edx
  800256:	74 10                	je     800268 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80025d:	89 08                	mov    %ecx,(%eax)
  80025f:	8b 02                	mov    (%edx),%eax
  800261:	ba 00 00 00 00       	mov    $0x0,%edx
  800266:	eb 0e                	jmp    800276 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800268:	8b 10                	mov    (%eax),%edx
  80026a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026d:	89 08                	mov    %ecx,(%eax)
  80026f:	8b 02                	mov    (%edx),%eax
  800271:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800276:	5d                   	pop    %ebp
  800277:	c3                   	ret    

00800278 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027b:	83 fa 01             	cmp    $0x1,%edx
  80027e:	7e 0e                	jle    80028e <getint+0x16>
		return va_arg(*ap, long long);
  800280:	8b 10                	mov    (%eax),%edx
  800282:	8d 4a 08             	lea    0x8(%edx),%ecx
  800285:	89 08                	mov    %ecx,(%eax)
  800287:	8b 02                	mov    (%edx),%eax
  800289:	8b 52 04             	mov    0x4(%edx),%edx
  80028c:	eb 1a                	jmp    8002a8 <getint+0x30>
	else if (lflag)
  80028e:	85 d2                	test   %edx,%edx
  800290:	74 0c                	je     80029e <getint+0x26>
		return va_arg(*ap, long);
  800292:	8b 10                	mov    (%eax),%edx
  800294:	8d 4a 04             	lea    0x4(%edx),%ecx
  800297:	89 08                	mov    %ecx,(%eax)
  800299:	8b 02                	mov    (%edx),%eax
  80029b:	99                   	cltd   
  80029c:	eb 0a                	jmp    8002a8 <getint+0x30>
	else
		return va_arg(*ap, int);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	99                   	cltd   
}
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002b3:	8b 10                	mov    (%eax),%edx
  8002b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b8:	73 08                	jae    8002c2 <sprintputch+0x18>
		*b->buf++ = ch;
  8002ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002bd:	88 0a                	mov    %cl,(%edx)
  8002bf:	42                   	inc    %edx
  8002c0:	89 10                	mov    %edx,(%eax)
}
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ca:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	89 04 24             	mov    %eax,(%esp)
  8002e5:	e8 02 00 00 00       	call   8002ec <vprintfmt>
	va_end(ap);
}
  8002ea:	c9                   	leave  
  8002eb:	c3                   	ret    

008002ec <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	57                   	push   %edi
  8002f0:	56                   	push   %esi
  8002f1:	53                   	push   %ebx
  8002f2:	83 ec 4c             	sub    $0x4c,%esp
  8002f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f8:	8b 75 10             	mov    0x10(%ebp),%esi
  8002fb:	eb 12                	jmp    80030f <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002fd:	85 c0                	test   %eax,%eax
  8002ff:	0f 84 40 03 00 00    	je     800645 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800305:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800309:	89 04 24             	mov    %eax,(%esp)
  80030c:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030f:	0f b6 06             	movzbl (%esi),%eax
  800312:	46                   	inc    %esi
  800313:	83 f8 25             	cmp    $0x25,%eax
  800316:	75 e5                	jne    8002fd <vprintfmt+0x11>
  800318:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80031c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800323:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800328:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80032f:	ba 00 00 00 00       	mov    $0x0,%edx
  800334:	eb 26                	jmp    80035c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800336:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800339:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80033d:	eb 1d                	jmp    80035c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800342:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800346:	eb 14                	jmp    80035c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800348:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80034b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800352:	eb 08                	jmp    80035c <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800354:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800357:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035c:	0f b6 06             	movzbl (%esi),%eax
  80035f:	8d 4e 01             	lea    0x1(%esi),%ecx
  800362:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800365:	8a 0e                	mov    (%esi),%cl
  800367:	83 e9 23             	sub    $0x23,%ecx
  80036a:	80 f9 55             	cmp    $0x55,%cl
  80036d:	0f 87 b6 02 00 00    	ja     800629 <vprintfmt+0x33d>
  800373:	0f b6 c9             	movzbl %cl,%ecx
  800376:	ff 24 8d 40 16 80 00 	jmp    *0x801640(,%ecx,4)
  80037d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800380:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800385:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800388:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  80038c:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80038f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800392:	83 f9 09             	cmp    $0x9,%ecx
  800395:	77 2a                	ja     8003c1 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800397:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800398:	eb eb                	jmp    800385 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80039a:	8b 45 14             	mov    0x14(%ebp),%eax
  80039d:	8d 48 04             	lea    0x4(%eax),%ecx
  8003a0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003a3:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a8:	eb 17                	jmp    8003c1 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003aa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ae:	78 98                	js     800348 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003b3:	eb a7                	jmp    80035c <vprintfmt+0x70>
  8003b5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b8:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003bf:	eb 9b                	jmp    80035c <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003c1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003c5:	79 95                	jns    80035c <vprintfmt+0x70>
  8003c7:	eb 8b                	jmp    800354 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c9:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003cd:	eb 8d                	jmp    80035c <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d2:	8d 50 04             	lea    0x4(%eax),%edx
  8003d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003dc:	8b 00                	mov    (%eax),%eax
  8003de:	89 04 24             	mov    %eax,(%esp)
  8003e1:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e7:	e9 23 ff ff ff       	jmp    80030f <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ef:	8d 50 04             	lea    0x4(%eax),%edx
  8003f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f5:	8b 00                	mov    (%eax),%eax
  8003f7:	85 c0                	test   %eax,%eax
  8003f9:	79 02                	jns    8003fd <vprintfmt+0x111>
  8003fb:	f7 d8                	neg    %eax
  8003fd:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ff:	83 f8 09             	cmp    $0x9,%eax
  800402:	7f 0b                	jg     80040f <vprintfmt+0x123>
  800404:	8b 04 85 a0 17 80 00 	mov    0x8017a0(,%eax,4),%eax
  80040b:	85 c0                	test   %eax,%eax
  80040d:	75 23                	jne    800432 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80040f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800413:	c7 44 24 08 89 15 80 	movl   $0x801589,0x8(%esp)
  80041a:	00 
  80041b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80041f:	8b 45 08             	mov    0x8(%ebp),%eax
  800422:	89 04 24             	mov    %eax,(%esp)
  800425:	e8 9a fe ff ff       	call   8002c4 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80042d:	e9 dd fe ff ff       	jmp    80030f <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800432:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800436:	c7 44 24 08 92 15 80 	movl   $0x801592,0x8(%esp)
  80043d:	00 
  80043e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800442:	8b 55 08             	mov    0x8(%ebp),%edx
  800445:	89 14 24             	mov    %edx,(%esp)
  800448:	e8 77 fe ff ff       	call   8002c4 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800450:	e9 ba fe ff ff       	jmp    80030f <vprintfmt+0x23>
  800455:	89 f9                	mov    %edi,%ecx
  800457:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80045a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045d:	8b 45 14             	mov    0x14(%ebp),%eax
  800460:	8d 50 04             	lea    0x4(%eax),%edx
  800463:	89 55 14             	mov    %edx,0x14(%ebp)
  800466:	8b 30                	mov    (%eax),%esi
  800468:	85 f6                	test   %esi,%esi
  80046a:	75 05                	jne    800471 <vprintfmt+0x185>
				p = "(null)";
  80046c:	be 82 15 80 00       	mov    $0x801582,%esi
			if (width > 0 && padc != '-')
  800471:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800475:	0f 8e 84 00 00 00    	jle    8004ff <vprintfmt+0x213>
  80047b:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80047f:	74 7e                	je     8004ff <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800481:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800485:	89 34 24             	mov    %esi,(%esp)
  800488:	e8 5d 02 00 00       	call   8006ea <strnlen>
  80048d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800490:	29 c2                	sub    %eax,%edx
  800492:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800495:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800499:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80049c:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80049f:	89 de                	mov    %ebx,%esi
  8004a1:	89 d3                	mov    %edx,%ebx
  8004a3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a5:	eb 0b                	jmp    8004b2 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004ab:	89 3c 24             	mov    %edi,(%esp)
  8004ae:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	4b                   	dec    %ebx
  8004b2:	85 db                	test   %ebx,%ebx
  8004b4:	7f f1                	jg     8004a7 <vprintfmt+0x1bb>
  8004b6:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004b9:	89 f3                	mov    %esi,%ebx
  8004bb:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004c1:	85 c0                	test   %eax,%eax
  8004c3:	79 05                	jns    8004ca <vprintfmt+0x1de>
  8004c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004cd:	29 c2                	sub    %eax,%edx
  8004cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004d2:	eb 2b                	jmp    8004ff <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004d8:	74 18                	je     8004f2 <vprintfmt+0x206>
  8004da:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004dd:	83 fa 5e             	cmp    $0x5e,%edx
  8004e0:	76 10                	jbe    8004f2 <vprintfmt+0x206>
					putch('?', putdat);
  8004e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004ed:	ff 55 08             	call   *0x8(%ebp)
  8004f0:	eb 0a                	jmp    8004fc <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f6:	89 04 24             	mov    %eax,(%esp)
  8004f9:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fc:	ff 4d e4             	decl   -0x1c(%ebp)
  8004ff:	0f be 06             	movsbl (%esi),%eax
  800502:	46                   	inc    %esi
  800503:	85 c0                	test   %eax,%eax
  800505:	74 21                	je     800528 <vprintfmt+0x23c>
  800507:	85 ff                	test   %edi,%edi
  800509:	78 c9                	js     8004d4 <vprintfmt+0x1e8>
  80050b:	4f                   	dec    %edi
  80050c:	79 c6                	jns    8004d4 <vprintfmt+0x1e8>
  80050e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800511:	89 de                	mov    %ebx,%esi
  800513:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800516:	eb 18                	jmp    800530 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800518:	89 74 24 04          	mov    %esi,0x4(%esp)
  80051c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800523:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800525:	4b                   	dec    %ebx
  800526:	eb 08                	jmp    800530 <vprintfmt+0x244>
  800528:	8b 7d 08             	mov    0x8(%ebp),%edi
  80052b:	89 de                	mov    %ebx,%esi
  80052d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800530:	85 db                	test   %ebx,%ebx
  800532:	7f e4                	jg     800518 <vprintfmt+0x22c>
  800534:	89 7d 08             	mov    %edi,0x8(%ebp)
  800537:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800539:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80053c:	e9 ce fd ff ff       	jmp    80030f <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800541:	8d 45 14             	lea    0x14(%ebp),%eax
  800544:	e8 2f fd ff ff       	call   800278 <getint>
  800549:	89 c6                	mov    %eax,%esi
  80054b:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  80054d:	85 d2                	test   %edx,%edx
  80054f:	78 07                	js     800558 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800551:	be 0a 00 00 00       	mov    $0xa,%esi
  800556:	eb 7e                	jmp    8005d6 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800558:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80055c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800563:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800566:	89 f0                	mov    %esi,%eax
  800568:	89 fa                	mov    %edi,%edx
  80056a:	f7 d8                	neg    %eax
  80056c:	83 d2 00             	adc    $0x0,%edx
  80056f:	f7 da                	neg    %edx
			}
			base = 10;
  800571:	be 0a 00 00 00       	mov    $0xa,%esi
  800576:	eb 5e                	jmp    8005d6 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800578:	8d 45 14             	lea    0x14(%ebp),%eax
  80057b:	e8 be fc ff ff       	call   80023e <getuint>
			base = 10;
  800580:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800585:	eb 4f                	jmp    8005d6 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800587:	8d 45 14             	lea    0x14(%ebp),%eax
  80058a:	e8 af fc ff ff       	call   80023e <getuint>
			base = 8;
  80058f:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800594:	eb 40                	jmp    8005d6 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  800596:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005a1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005af:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8d 50 04             	lea    0x4(%eax),%edx
  8005b8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005c2:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8005c7:	eb 0d                	jmp    8005d6 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005c9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cc:	e8 6d fc ff ff       	call   80023e <getuint>
			base = 16;
  8005d1:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005d6:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8005da:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005de:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005e1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8005e5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8005e9:	89 04 24             	mov    %eax,(%esp)
  8005ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005f0:	89 da                	mov    %ebx,%edx
  8005f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f5:	e8 7a fb ff ff       	call   800174 <printnum>
			break;
  8005fa:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005fd:	e9 0d fd ff ff       	jmp    80030f <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  800602:	8d 45 14             	lea    0x14(%ebp),%eax
  800605:	e8 6e fc ff ff       	call   800278 <getint>
  80060a:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  800612:	e9 f8 fc ff ff       	jmp    80030f <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800617:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061b:	89 04 24             	mov    %eax,(%esp)
  80061e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800621:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800624:	e9 e6 fc ff ff       	jmp    80030f <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800629:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800634:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800637:	eb 01                	jmp    80063a <vprintfmt+0x34e>
  800639:	4e                   	dec    %esi
  80063a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80063e:	75 f9                	jne    800639 <vprintfmt+0x34d>
  800640:	e9 ca fc ff ff       	jmp    80030f <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800645:	83 c4 4c             	add    $0x4c,%esp
  800648:	5b                   	pop    %ebx
  800649:	5e                   	pop    %esi
  80064a:	5f                   	pop    %edi
  80064b:	5d                   	pop    %ebp
  80064c:	c3                   	ret    

0080064d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80064d:	55                   	push   %ebp
  80064e:	89 e5                	mov    %esp,%ebp
  800650:	83 ec 28             	sub    $0x28,%esp
  800653:	8b 45 08             	mov    0x8(%ebp),%eax
  800656:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800659:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80065c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800660:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800663:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80066a:	85 c0                	test   %eax,%eax
  80066c:	74 30                	je     80069e <vsnprintf+0x51>
  80066e:	85 d2                	test   %edx,%edx
  800670:	7e 33                	jle    8006a5 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800679:	8b 45 10             	mov    0x10(%ebp),%eax
  80067c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800680:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800683:	89 44 24 04          	mov    %eax,0x4(%esp)
  800687:	c7 04 24 aa 02 80 00 	movl   $0x8002aa,(%esp)
  80068e:	e8 59 fc ff ff       	call   8002ec <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800693:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800696:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800699:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069c:	eb 0c                	jmp    8006aa <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80069e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006a3:	eb 05                	jmp    8006aa <vsnprintf+0x5d>
  8006a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006aa:	c9                   	leave  
  8006ab:	c3                   	ret    

008006ac <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006ac:	55                   	push   %ebp
  8006ad:	89 e5                	mov    %esp,%ebp
  8006af:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006b2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8006bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ca:	89 04 24             	mov    %eax,(%esp)
  8006cd:	e8 7b ff ff ff       	call   80064d <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d2:	c9                   	leave  
  8006d3:	c3                   	ret    

008006d4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006da:	b8 00 00 00 00       	mov    $0x0,%eax
  8006df:	eb 01                	jmp    8006e2 <strlen+0xe>
		n++;
  8006e1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006e6:	75 f9                	jne    8006e1 <strlen+0xd>
		n++;
	return n;
}
  8006e8:	5d                   	pop    %ebp
  8006e9:	c3                   	ret    

008006ea <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ea:	55                   	push   %ebp
  8006eb:	89 e5                	mov    %esp,%ebp
  8006ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8006f0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f8:	eb 01                	jmp    8006fb <strnlen+0x11>
		n++;
  8006fa:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fb:	39 d0                	cmp    %edx,%eax
  8006fd:	74 06                	je     800705 <strnlen+0x1b>
  8006ff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800703:	75 f5                	jne    8006fa <strnlen+0x10>
		n++;
	return n;
}
  800705:	5d                   	pop    %ebp
  800706:	c3                   	ret    

00800707 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	53                   	push   %ebx
  80070b:	8b 45 08             	mov    0x8(%ebp),%eax
  80070e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800711:	ba 00 00 00 00       	mov    $0x0,%edx
  800716:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800719:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80071c:	42                   	inc    %edx
  80071d:	84 c9                	test   %cl,%cl
  80071f:	75 f5                	jne    800716 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800721:	5b                   	pop    %ebx
  800722:	5d                   	pop    %ebp
  800723:	c3                   	ret    

00800724 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	53                   	push   %ebx
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80072e:	89 1c 24             	mov    %ebx,(%esp)
  800731:	e8 9e ff ff ff       	call   8006d4 <strlen>
	strcpy(dst + len, src);
  800736:	8b 55 0c             	mov    0xc(%ebp),%edx
  800739:	89 54 24 04          	mov    %edx,0x4(%esp)
  80073d:	01 d8                	add    %ebx,%eax
  80073f:	89 04 24             	mov    %eax,(%esp)
  800742:	e8 c0 ff ff ff       	call   800707 <strcpy>
	return dst;
}
  800747:	89 d8                	mov    %ebx,%eax
  800749:	83 c4 08             	add    $0x8,%esp
  80074c:	5b                   	pop    %ebx
  80074d:	5d                   	pop    %ebp
  80074e:	c3                   	ret    

0080074f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	56                   	push   %esi
  800753:	53                   	push   %ebx
  800754:	8b 45 08             	mov    0x8(%ebp),%eax
  800757:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800762:	eb 0c                	jmp    800770 <strncpy+0x21>
		*dst++ = *src;
  800764:	8a 1a                	mov    (%edx),%bl
  800766:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800769:	80 3a 01             	cmpb   $0x1,(%edx)
  80076c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076f:	41                   	inc    %ecx
  800770:	39 f1                	cmp    %esi,%ecx
  800772:	75 f0                	jne    800764 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800774:	5b                   	pop    %ebx
  800775:	5e                   	pop    %esi
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	56                   	push   %esi
  80077c:	53                   	push   %ebx
  80077d:	8b 75 08             	mov    0x8(%ebp),%esi
  800780:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800783:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800786:	85 d2                	test   %edx,%edx
  800788:	75 0a                	jne    800794 <strlcpy+0x1c>
  80078a:	89 f0                	mov    %esi,%eax
  80078c:	eb 1a                	jmp    8007a8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80078e:	88 18                	mov    %bl,(%eax)
  800790:	40                   	inc    %eax
  800791:	41                   	inc    %ecx
  800792:	eb 02                	jmp    800796 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800794:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800796:	4a                   	dec    %edx
  800797:	74 0a                	je     8007a3 <strlcpy+0x2b>
  800799:	8a 19                	mov    (%ecx),%bl
  80079b:	84 db                	test   %bl,%bl
  80079d:	75 ef                	jne    80078e <strlcpy+0x16>
  80079f:	89 c2                	mov    %eax,%edx
  8007a1:	eb 02                	jmp    8007a5 <strlcpy+0x2d>
  8007a3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007a5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007a8:	29 f0                	sub    %esi,%eax
}
  8007aa:	5b                   	pop    %ebx
  8007ab:	5e                   	pop    %esi
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007b7:	eb 02                	jmp    8007bb <strcmp+0xd>
		p++, q++;
  8007b9:	41                   	inc    %ecx
  8007ba:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007bb:	8a 01                	mov    (%ecx),%al
  8007bd:	84 c0                	test   %al,%al
  8007bf:	74 04                	je     8007c5 <strcmp+0x17>
  8007c1:	3a 02                	cmp    (%edx),%al
  8007c3:	74 f4                	je     8007b9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c5:	0f b6 c0             	movzbl %al,%eax
  8007c8:	0f b6 12             	movzbl (%edx),%edx
  8007cb:	29 d0                	sub    %edx,%eax
}
  8007cd:	5d                   	pop    %ebp
  8007ce:	c3                   	ret    

008007cf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	53                   	push   %ebx
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007dc:	eb 03                	jmp    8007e1 <strncmp+0x12>
		n--, p++, q++;
  8007de:	4a                   	dec    %edx
  8007df:	40                   	inc    %eax
  8007e0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007e1:	85 d2                	test   %edx,%edx
  8007e3:	74 14                	je     8007f9 <strncmp+0x2a>
  8007e5:	8a 18                	mov    (%eax),%bl
  8007e7:	84 db                	test   %bl,%bl
  8007e9:	74 04                	je     8007ef <strncmp+0x20>
  8007eb:	3a 19                	cmp    (%ecx),%bl
  8007ed:	74 ef                	je     8007de <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ef:	0f b6 00             	movzbl (%eax),%eax
  8007f2:	0f b6 11             	movzbl (%ecx),%edx
  8007f5:	29 d0                	sub    %edx,%eax
  8007f7:	eb 05                	jmp    8007fe <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007f9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007fe:	5b                   	pop    %ebx
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	8b 45 08             	mov    0x8(%ebp),%eax
  800807:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80080a:	eb 05                	jmp    800811 <strchr+0x10>
		if (*s == c)
  80080c:	38 ca                	cmp    %cl,%dl
  80080e:	74 0c                	je     80081c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800810:	40                   	inc    %eax
  800811:	8a 10                	mov    (%eax),%dl
  800813:	84 d2                	test   %dl,%dl
  800815:	75 f5                	jne    80080c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800817:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	8b 45 08             	mov    0x8(%ebp),%eax
  800824:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800827:	eb 05                	jmp    80082e <strfind+0x10>
		if (*s == c)
  800829:	38 ca                	cmp    %cl,%dl
  80082b:	74 07                	je     800834 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80082d:	40                   	inc    %eax
  80082e:	8a 10                	mov    (%eax),%dl
  800830:	84 d2                	test   %dl,%dl
  800832:	75 f5                	jne    800829 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	57                   	push   %edi
  80083a:	56                   	push   %esi
  80083b:	53                   	push   %ebx
  80083c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80083f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800842:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800845:	85 c9                	test   %ecx,%ecx
  800847:	74 30                	je     800879 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800849:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80084f:	75 25                	jne    800876 <memset+0x40>
  800851:	f6 c1 03             	test   $0x3,%cl
  800854:	75 20                	jne    800876 <memset+0x40>
		c &= 0xFF;
  800856:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800859:	89 d3                	mov    %edx,%ebx
  80085b:	c1 e3 08             	shl    $0x8,%ebx
  80085e:	89 d6                	mov    %edx,%esi
  800860:	c1 e6 18             	shl    $0x18,%esi
  800863:	89 d0                	mov    %edx,%eax
  800865:	c1 e0 10             	shl    $0x10,%eax
  800868:	09 f0                	or     %esi,%eax
  80086a:	09 d0                	or     %edx,%eax
  80086c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80086e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800871:	fc                   	cld    
  800872:	f3 ab                	rep stos %eax,%es:(%edi)
  800874:	eb 03                	jmp    800879 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800876:	fc                   	cld    
  800877:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800879:	89 f8                	mov    %edi,%eax
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5f                   	pop    %edi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	57                   	push   %edi
  800884:	56                   	push   %esi
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	8b 75 0c             	mov    0xc(%ebp),%esi
  80088b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80088e:	39 c6                	cmp    %eax,%esi
  800890:	73 34                	jae    8008c6 <memmove+0x46>
  800892:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800895:	39 d0                	cmp    %edx,%eax
  800897:	73 2d                	jae    8008c6 <memmove+0x46>
		s += n;
		d += n;
  800899:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80089c:	f6 c2 03             	test   $0x3,%dl
  80089f:	75 1b                	jne    8008bc <memmove+0x3c>
  8008a1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a7:	75 13                	jne    8008bc <memmove+0x3c>
  8008a9:	f6 c1 03             	test   $0x3,%cl
  8008ac:	75 0e                	jne    8008bc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008ae:	83 ef 04             	sub    $0x4,%edi
  8008b1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008b4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008b7:	fd                   	std    
  8008b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ba:	eb 07                	jmp    8008c3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008bc:	4f                   	dec    %edi
  8008bd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c0:	fd                   	std    
  8008c1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008c3:	fc                   	cld    
  8008c4:	eb 20                	jmp    8008e6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008cc:	75 13                	jne    8008e1 <memmove+0x61>
  8008ce:	a8 03                	test   $0x3,%al
  8008d0:	75 0f                	jne    8008e1 <memmove+0x61>
  8008d2:	f6 c1 03             	test   $0x3,%cl
  8008d5:	75 0a                	jne    8008e1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008d7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008da:	89 c7                	mov    %eax,%edi
  8008dc:	fc                   	cld    
  8008dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008df:	eb 05                	jmp    8008e6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e1:	89 c7                	mov    %eax,%edi
  8008e3:	fc                   	cld    
  8008e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008e6:	5e                   	pop    %esi
  8008e7:	5f                   	pop    %edi
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8008f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	89 04 24             	mov    %eax,(%esp)
  800904:	e8 77 ff ff ff       	call   800880 <memmove>
}
  800909:	c9                   	leave  
  80090a:	c3                   	ret    

0080090b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	57                   	push   %edi
  80090f:	56                   	push   %esi
  800910:	53                   	push   %ebx
  800911:	8b 7d 08             	mov    0x8(%ebp),%edi
  800914:	8b 75 0c             	mov    0xc(%ebp),%esi
  800917:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80091a:	ba 00 00 00 00       	mov    $0x0,%edx
  80091f:	eb 16                	jmp    800937 <memcmp+0x2c>
		if (*s1 != *s2)
  800921:	8a 04 17             	mov    (%edi,%edx,1),%al
  800924:	42                   	inc    %edx
  800925:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800929:	38 c8                	cmp    %cl,%al
  80092b:	74 0a                	je     800937 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  80092d:	0f b6 c0             	movzbl %al,%eax
  800930:	0f b6 c9             	movzbl %cl,%ecx
  800933:	29 c8                	sub    %ecx,%eax
  800935:	eb 09                	jmp    800940 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800937:	39 da                	cmp    %ebx,%edx
  800939:	75 e6                	jne    800921 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80093b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800940:	5b                   	pop    %ebx
  800941:	5e                   	pop    %esi
  800942:	5f                   	pop    %edi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80094e:	89 c2                	mov    %eax,%edx
  800950:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800953:	eb 05                	jmp    80095a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800955:	38 08                	cmp    %cl,(%eax)
  800957:	74 05                	je     80095e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800959:	40                   	inc    %eax
  80095a:	39 d0                	cmp    %edx,%eax
  80095c:	72 f7                	jb     800955 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	57                   	push   %edi
  800964:	56                   	push   %esi
  800965:	53                   	push   %ebx
  800966:	8b 55 08             	mov    0x8(%ebp),%edx
  800969:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096c:	eb 01                	jmp    80096f <strtol+0xf>
		s++;
  80096e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096f:	8a 02                	mov    (%edx),%al
  800971:	3c 20                	cmp    $0x20,%al
  800973:	74 f9                	je     80096e <strtol+0xe>
  800975:	3c 09                	cmp    $0x9,%al
  800977:	74 f5                	je     80096e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800979:	3c 2b                	cmp    $0x2b,%al
  80097b:	75 08                	jne    800985 <strtol+0x25>
		s++;
  80097d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80097e:	bf 00 00 00 00       	mov    $0x0,%edi
  800983:	eb 13                	jmp    800998 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800985:	3c 2d                	cmp    $0x2d,%al
  800987:	75 0a                	jne    800993 <strtol+0x33>
		s++, neg = 1;
  800989:	8d 52 01             	lea    0x1(%edx),%edx
  80098c:	bf 01 00 00 00       	mov    $0x1,%edi
  800991:	eb 05                	jmp    800998 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800993:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800998:	85 db                	test   %ebx,%ebx
  80099a:	74 05                	je     8009a1 <strtol+0x41>
  80099c:	83 fb 10             	cmp    $0x10,%ebx
  80099f:	75 28                	jne    8009c9 <strtol+0x69>
  8009a1:	8a 02                	mov    (%edx),%al
  8009a3:	3c 30                	cmp    $0x30,%al
  8009a5:	75 10                	jne    8009b7 <strtol+0x57>
  8009a7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009ab:	75 0a                	jne    8009b7 <strtol+0x57>
		s += 2, base = 16;
  8009ad:	83 c2 02             	add    $0x2,%edx
  8009b0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b5:	eb 12                	jmp    8009c9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009b7:	85 db                	test   %ebx,%ebx
  8009b9:	75 0e                	jne    8009c9 <strtol+0x69>
  8009bb:	3c 30                	cmp    $0x30,%al
  8009bd:	75 05                	jne    8009c4 <strtol+0x64>
		s++, base = 8;
  8009bf:	42                   	inc    %edx
  8009c0:	b3 08                	mov    $0x8,%bl
  8009c2:	eb 05                	jmp    8009c9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009c4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ce:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d0:	8a 0a                	mov    (%edx),%cl
  8009d2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009d5:	80 fb 09             	cmp    $0x9,%bl
  8009d8:	77 08                	ja     8009e2 <strtol+0x82>
			dig = *s - '0';
  8009da:	0f be c9             	movsbl %cl,%ecx
  8009dd:	83 e9 30             	sub    $0x30,%ecx
  8009e0:	eb 1e                	jmp    800a00 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009e2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009e5:	80 fb 19             	cmp    $0x19,%bl
  8009e8:	77 08                	ja     8009f2 <strtol+0x92>
			dig = *s - 'a' + 10;
  8009ea:	0f be c9             	movsbl %cl,%ecx
  8009ed:	83 e9 57             	sub    $0x57,%ecx
  8009f0:	eb 0e                	jmp    800a00 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8009f2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8009f5:	80 fb 19             	cmp    $0x19,%bl
  8009f8:	77 12                	ja     800a0c <strtol+0xac>
			dig = *s - 'A' + 10;
  8009fa:	0f be c9             	movsbl %cl,%ecx
  8009fd:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a00:	39 f1                	cmp    %esi,%ecx
  800a02:	7d 0c                	jge    800a10 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a04:	42                   	inc    %edx
  800a05:	0f af c6             	imul   %esi,%eax
  800a08:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a0a:	eb c4                	jmp    8009d0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a0c:	89 c1                	mov    %eax,%ecx
  800a0e:	eb 02                	jmp    800a12 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a10:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a12:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a16:	74 05                	je     800a1d <strtol+0xbd>
		*endptr = (char *) s;
  800a18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a1b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a1d:	85 ff                	test   %edi,%edi
  800a1f:	74 04                	je     800a25 <strtol+0xc5>
  800a21:	89 c8                	mov    %ecx,%eax
  800a23:	f7 d8                	neg    %eax
}
  800a25:	5b                   	pop    %ebx
  800a26:	5e                   	pop    %esi
  800a27:	5f                   	pop    %edi
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    
	...

00800a2c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	57                   	push   %edi
  800a30:	56                   	push   %esi
  800a31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a32:	b8 00 00 00 00       	mov    $0x0,%eax
  800a37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3d:	89 c3                	mov    %eax,%ebx
  800a3f:	89 c7                	mov    %eax,%edi
  800a41:	89 c6                	mov    %eax,%esi
  800a43:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5f                   	pop    %edi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	57                   	push   %edi
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a50:	ba 00 00 00 00       	mov    $0x0,%edx
  800a55:	b8 01 00 00 00       	mov    $0x1,%eax
  800a5a:	89 d1                	mov    %edx,%ecx
  800a5c:	89 d3                	mov    %edx,%ebx
  800a5e:	89 d7                	mov    %edx,%edi
  800a60:	89 d6                	mov    %edx,%esi
  800a62:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a64:	5b                   	pop    %ebx
  800a65:	5e                   	pop    %esi
  800a66:	5f                   	pop    %edi
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	57                   	push   %edi
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
  800a6f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a77:	b8 03 00 00 00       	mov    $0x3,%eax
  800a7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7f:	89 cb                	mov    %ecx,%ebx
  800a81:	89 cf                	mov    %ecx,%edi
  800a83:	89 ce                	mov    %ecx,%esi
  800a85:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a87:	85 c0                	test   %eax,%eax
  800a89:	7e 28                	jle    800ab3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a8b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a8f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800a96:	00 
  800a97:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800a9e:	00 
  800a9f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800aa6:	00 
  800aa7:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800aae:	e8 e1 07 00 00       	call   801294 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab3:	83 c4 2c             	add    $0x2c,%esp
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5f                   	pop    %edi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	57                   	push   %edi
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac6:	b8 02 00 00 00       	mov    $0x2,%eax
  800acb:	89 d1                	mov    %edx,%ecx
  800acd:	89 d3                	mov    %edx,%ebx
  800acf:	89 d7                	mov    %edx,%edi
  800ad1:	89 d6                	mov    %edx,%esi
  800ad3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5f                   	pop    %edi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <sys_yield>:

void
sys_yield(void)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	57                   	push   %edi
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aea:	89 d1                	mov    %edx,%ecx
  800aec:	89 d3                	mov    %edx,%ebx
  800aee:	89 d7                	mov    %edx,%edi
  800af0:	89 d6                	mov    %edx,%esi
  800af2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	be 00 00 00 00       	mov    $0x0,%esi
  800b07:	b8 04 00 00 00       	mov    $0x4,%eax
  800b0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b12:	8b 55 08             	mov    0x8(%ebp),%edx
  800b15:	89 f7                	mov    %esi,%edi
  800b17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b19:	85 c0                	test   %eax,%eax
  800b1b:	7e 28                	jle    800b45 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b21:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b28:	00 
  800b29:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800b30:	00 
  800b31:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b38:	00 
  800b39:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800b40:	e8 4f 07 00 00       	call   801294 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b45:	83 c4 2c             	add    $0x2c,%esp
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
  800b53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b56:	b8 05 00 00 00       	mov    $0x5,%eax
  800b5b:	8b 75 18             	mov    0x18(%ebp),%esi
  800b5e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b67:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b6c:	85 c0                	test   %eax,%eax
  800b6e:	7e 28                	jle    800b98 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b70:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b74:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800b7b:	00 
  800b7c:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800b83:	00 
  800b84:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b8b:	00 
  800b8c:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800b93:	e8 fc 06 00 00       	call   801294 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b98:	83 c4 2c             	add    $0x2c,%esp
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
  800ba6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bae:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	89 df                	mov    %ebx,%edi
  800bbb:	89 de                	mov    %ebx,%esi
  800bbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	7e 28                	jle    800beb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800bce:	00 
  800bcf:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800bd6:	00 
  800bd7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bde:	00 
  800bdf:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800be6:	e8 a9 06 00 00       	call   801294 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800beb:	83 c4 2c             	add    $0x2c,%esp
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c01:	b8 08 00 00 00       	mov    $0x8,%eax
  800c06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c09:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0c:	89 df                	mov    %ebx,%edi
  800c0e:	89 de                	mov    %ebx,%esi
  800c10:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c12:	85 c0                	test   %eax,%eax
  800c14:	7e 28                	jle    800c3e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c16:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c1a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c21:	00 
  800c22:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800c29:	00 
  800c2a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c31:	00 
  800c32:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800c39:	e8 56 06 00 00       	call   801294 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c3e:	83 c4 2c             	add    $0x2c,%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c54:	b8 09 00 00 00       	mov    $0x9,%eax
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	89 df                	mov    %ebx,%edi
  800c61:	89 de                	mov    %ebx,%esi
  800c63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 28                	jle    800c91 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c69:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c74:	00 
  800c75:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800c7c:	00 
  800c7d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c84:	00 
  800c85:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800c8c:	e8 03 06 00 00       	call   801294 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c91:	83 c4 2c             	add    $0x2c,%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9f:	be 00 00 00 00       	mov    $0x0,%esi
  800ca4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cca:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ccf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd2:	89 cb                	mov    %ecx,%ebx
  800cd4:	89 cf                	mov    %ecx,%edi
  800cd6:	89 ce                	mov    %ecx,%esi
  800cd8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	7e 28                	jle    800d06 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cde:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce2:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ce9:	00 
  800cea:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800cf1:	00 
  800cf2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf9:	00 
  800cfa:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800d01:	e8 8e 05 00 00       	call   801294 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d06:	83 c4 2c             	add    $0x2c,%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d24:	8b 55 08             	mov    0x8(%ebp),%edx
  800d27:	89 df                	mov    %ebx,%edi
  800d29:	89 de                	mov    %ebx,%esi
  800d2b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	7e 28                	jle    800d59 <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d31:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d35:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d3c:	00 
  800d3d:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800d44:	00 
  800d45:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4c:	00 
  800d4d:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800d54:	e8 3b 05 00 00       	call   801294 <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800d59:	83 c4 2c             	add    $0x2c,%esp
  800d5c:	5b                   	pop    %ebx
  800d5d:	5e                   	pop    %esi
  800d5e:	5f                   	pop    %edi
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <sys_env_set_debug_upcall>:

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	57                   	push   %edi
  800d65:	56                   	push   %esi
  800d66:	53                   	push   %ebx
  800d67:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d77:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7a:	89 df                	mov    %ebx,%edi
  800d7c:	89 de                	mov    %ebx,%esi
  800d7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d80:	85 c0                	test   %eax,%eax
  800d82:	7e 28                	jle    800dac <sys_env_set_debug_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d84:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d88:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800d8f:	00 
  800d90:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800d97:	00 
  800d98:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d9f:	00 
  800da0:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800da7:	e8 e8 04 00 00       	call   801294 <_panic>
}

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_debug_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800dac:	83 c4 2c             	add    $0x2c,%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <sys_env_set_nmskint_upcall>:

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
  800dba:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc2:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dca:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcd:	89 df                	mov    %ebx,%edi
  800dcf:	89 de                	mov    %ebx,%esi
  800dd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	7e 28                	jle    800dff <sys_env_set_nmskint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ddb:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800de2:	00 
  800de3:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800dea:	00 
  800deb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df2:	00 
  800df3:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800dfa:	e8 95 04 00 00       	call   801294 <_panic>
}

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_nmskint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800dff:	83 c4 2c             	add    $0x2c,%esp
  800e02:	5b                   	pop    %ebx
  800e03:	5e                   	pop    %esi
  800e04:	5f                   	pop    %edi
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <sys_env_set_bpoint_upcall>:

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	57                   	push   %edi
  800e0b:	56                   	push   %esi
  800e0c:	53                   	push   %ebx
  800e0d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e15:	b8 10 00 00 00       	mov    $0x10,%eax
  800e1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e20:	89 df                	mov    %ebx,%edi
  800e22:	89 de                	mov    %ebx,%esi
  800e24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e26:	85 c0                	test   %eax,%eax
  800e28:	7e 28                	jle    800e52 <sys_env_set_bpoint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800e35:	00 
  800e36:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800e3d:	00 
  800e3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e45:	00 
  800e46:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800e4d:	e8 42 04 00 00       	call   801294 <_panic>
}

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bpoint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800e52:	83 c4 2c             	add    $0x2c,%esp
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <sys_env_set_oflow_upcall>:

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	57                   	push   %edi
  800e5e:	56                   	push   %esi
  800e5f:	53                   	push   %ebx
  800e60:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e68:	b8 11 00 00 00       	mov    $0x11,%eax
  800e6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e70:	8b 55 08             	mov    0x8(%ebp),%edx
  800e73:	89 df                	mov    %ebx,%edi
  800e75:	89 de                	mov    %ebx,%esi
  800e77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	7e 28                	jle    800ea5 <sys_env_set_oflow_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e81:	c7 44 24 0c 11 00 00 	movl   $0x11,0xc(%esp)
  800e88:	00 
  800e89:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800e90:	00 
  800e91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e98:	00 
  800e99:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800ea0:	e8 ef 03 00 00       	call   801294 <_panic>
}

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_oflow_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800ea5:	83 c4 2c             	add    $0x2c,%esp
  800ea8:	5b                   	pop    %ebx
  800ea9:	5e                   	pop    %esi
  800eaa:	5f                   	pop    %edi
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <sys_env_set_bdschk_upcall>:

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	57                   	push   %edi
  800eb1:	56                   	push   %esi
  800eb2:	53                   	push   %ebx
  800eb3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebb:	b8 12 00 00 00       	mov    $0x12,%eax
  800ec0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec6:	89 df                	mov    %ebx,%edi
  800ec8:	89 de                	mov    %ebx,%esi
  800eca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	7e 28                	jle    800ef8 <sys_env_set_bdschk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed4:	c7 44 24 0c 12 00 00 	movl   $0x12,0xc(%esp)
  800edb:	00 
  800edc:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800ee3:	00 
  800ee4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eeb:	00 
  800eec:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800ef3:	e8 9c 03 00 00       	call   801294 <_panic>
}

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bdschk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800ef8:	83 c4 2c             	add    $0x2c,%esp
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <sys_env_set_illopcd_upcall>:

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
  800f06:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f0e:	b8 13 00 00 00       	mov    $0x13,%eax
  800f13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f16:	8b 55 08             	mov    0x8(%ebp),%edx
  800f19:	89 df                	mov    %ebx,%edi
  800f1b:	89 de                	mov    %ebx,%esi
  800f1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	7e 28                	jle    800f4b <sys_env_set_illopcd_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f27:	c7 44 24 0c 13 00 00 	movl   $0x13,0xc(%esp)
  800f2e:	00 
  800f2f:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800f36:	00 
  800f37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f3e:	00 
  800f3f:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800f46:	e8 49 03 00 00       	call   801294 <_panic>
}

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_illopcd_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800f4b:	83 c4 2c             	add    $0x2c,%esp
  800f4e:	5b                   	pop    %ebx
  800f4f:	5e                   	pop    %esi
  800f50:	5f                   	pop    %edi
  800f51:	5d                   	pop    %ebp
  800f52:	c3                   	ret    

00800f53 <sys_env_set_dvcntavl_upcall>:

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	57                   	push   %edi
  800f57:	56                   	push   %esi
  800f58:	53                   	push   %ebx
  800f59:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f61:	b8 14 00 00 00       	mov    $0x14,%eax
  800f66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f69:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6c:	89 df                	mov    %ebx,%edi
  800f6e:	89 de                	mov    %ebx,%esi
  800f70:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f72:	85 c0                	test   %eax,%eax
  800f74:	7e 28                	jle    800f9e <sys_env_set_dvcntavl_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f7a:	c7 44 24 0c 14 00 00 	movl   $0x14,0xc(%esp)
  800f81:	00 
  800f82:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800f89:	00 
  800f8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f91:	00 
  800f92:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800f99:	e8 f6 02 00 00       	call   801294 <_panic>
}

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dvcntavl_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800f9e:	83 c4 2c             	add    $0x2c,%esp
  800fa1:	5b                   	pop    %ebx
  800fa2:	5e                   	pop    %esi
  800fa3:	5f                   	pop    %edi
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    

00800fa6 <sys_env_set_dbfault_upcall>:

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	53                   	push   %ebx
  800fac:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800faf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb4:	b8 15 00 00 00       	mov    $0x15,%eax
  800fb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbf:	89 df                	mov    %ebx,%edi
  800fc1:	89 de                	mov    %ebx,%esi
  800fc3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	7e 28                	jle    800ff1 <sys_env_set_dbfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fcd:	c7 44 24 0c 15 00 00 	movl   $0x15,0xc(%esp)
  800fd4:	00 
  800fd5:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  800fdc:	00 
  800fdd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe4:	00 
  800fe5:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  800fec:	e8 a3 02 00 00       	call   801294 <_panic>
}

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dbfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800ff1:	83 c4 2c             	add    $0x2c,%esp
  800ff4:	5b                   	pop    %ebx
  800ff5:	5e                   	pop    %esi
  800ff6:	5f                   	pop    %edi
  800ff7:	5d                   	pop    %ebp
  800ff8:	c3                   	ret    

00800ff9 <sys_env_set_ivldtss_upcall>:

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	57                   	push   %edi
  800ffd:	56                   	push   %esi
  800ffe:	53                   	push   %ebx
  800fff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801002:	bb 00 00 00 00       	mov    $0x0,%ebx
  801007:	b8 16 00 00 00       	mov    $0x16,%eax
  80100c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80100f:	8b 55 08             	mov    0x8(%ebp),%edx
  801012:	89 df                	mov    %ebx,%edi
  801014:	89 de                	mov    %ebx,%esi
  801016:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801018:	85 c0                	test   %eax,%eax
  80101a:	7e 28                	jle    801044 <sys_env_set_ivldtss_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80101c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801020:	c7 44 24 0c 16 00 00 	movl   $0x16,0xc(%esp)
  801027:	00 
  801028:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  80102f:	00 
  801030:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801037:	00 
  801038:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  80103f:	e8 50 02 00 00       	call   801294 <_panic>
}

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_ivldtss_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801044:	83 c4 2c             	add    $0x2c,%esp
  801047:	5b                   	pop    %ebx
  801048:	5e                   	pop    %esi
  801049:	5f                   	pop    %edi
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    

0080104c <sys_env_set_segntprst_upcall>:

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	57                   	push   %edi
  801050:	56                   	push   %esi
  801051:	53                   	push   %ebx
  801052:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801055:	bb 00 00 00 00       	mov    $0x0,%ebx
  80105a:	b8 17 00 00 00       	mov    $0x17,%eax
  80105f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801062:	8b 55 08             	mov    0x8(%ebp),%edx
  801065:	89 df                	mov    %ebx,%edi
  801067:	89 de                	mov    %ebx,%esi
  801069:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80106b:	85 c0                	test   %eax,%eax
  80106d:	7e 28                	jle    801097 <sys_env_set_segntprst_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80106f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801073:	c7 44 24 0c 17 00 00 	movl   $0x17,0xc(%esp)
  80107a:	00 
  80107b:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  801082:	00 
  801083:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80108a:	00 
  80108b:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  801092:	e8 fd 01 00 00       	call   801294 <_panic>
}

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_segntprst_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801097:	83 c4 2c             	add    $0x2c,%esp
  80109a:	5b                   	pop    %ebx
  80109b:	5e                   	pop    %esi
  80109c:	5f                   	pop    %edi
  80109d:	5d                   	pop    %ebp
  80109e:	c3                   	ret    

0080109f <sys_env_set_stkexception_upcall>:

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	57                   	push   %edi
  8010a3:	56                   	push   %esi
  8010a4:	53                   	push   %ebx
  8010a5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ad:	b8 18 00 00 00       	mov    $0x18,%eax
  8010b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b8:	89 df                	mov    %ebx,%edi
  8010ba:	89 de                	mov    %ebx,%esi
  8010bc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	7e 28                	jle    8010ea <sys_env_set_stkexception_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c6:	c7 44 24 0c 18 00 00 	movl   $0x18,0xc(%esp)
  8010cd:	00 
  8010ce:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  8010d5:	00 
  8010d6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010dd:	00 
  8010de:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  8010e5:	e8 aa 01 00 00       	call   801294 <_panic>
}

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_stkexception_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8010ea:	83 c4 2c             	add    $0x2c,%esp
  8010ed:	5b                   	pop    %ebx
  8010ee:	5e                   	pop    %esi
  8010ef:	5f                   	pop    %edi
  8010f0:	5d                   	pop    %ebp
  8010f1:	c3                   	ret    

008010f2 <sys_env_set_gpfault_upcall>:

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	57                   	push   %edi
  8010f6:	56                   	push   %esi
  8010f7:	53                   	push   %ebx
  8010f8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801100:	b8 19 00 00 00       	mov    $0x19,%eax
  801105:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801108:	8b 55 08             	mov    0x8(%ebp),%edx
  80110b:	89 df                	mov    %ebx,%edi
  80110d:	89 de                	mov    %ebx,%esi
  80110f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801111:	85 c0                	test   %eax,%eax
  801113:	7e 28                	jle    80113d <sys_env_set_gpfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801115:	89 44 24 10          	mov    %eax,0x10(%esp)
  801119:	c7 44 24 0c 19 00 00 	movl   $0x19,0xc(%esp)
  801120:	00 
  801121:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  801128:	00 
  801129:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801130:	00 
  801131:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  801138:	e8 57 01 00 00       	call   801294 <_panic>
}

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_gpfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80113d:	83 c4 2c             	add    $0x2c,%esp
  801140:	5b                   	pop    %ebx
  801141:	5e                   	pop    %esi
  801142:	5f                   	pop    %edi
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <sys_env_set_fperror_upcall>:

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	57                   	push   %edi
  801149:	56                   	push   %esi
  80114a:	53                   	push   %ebx
  80114b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80114e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801153:	b8 1a 00 00 00       	mov    $0x1a,%eax
  801158:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115b:	8b 55 08             	mov    0x8(%ebp),%edx
  80115e:	89 df                	mov    %ebx,%edi
  801160:	89 de                	mov    %ebx,%esi
  801162:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801164:	85 c0                	test   %eax,%eax
  801166:	7e 28                	jle    801190 <sys_env_set_fperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801168:	89 44 24 10          	mov    %eax,0x10(%esp)
  80116c:	c7 44 24 0c 1a 00 00 	movl   $0x1a,0xc(%esp)
  801173:	00 
  801174:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  80117b:	00 
  80117c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801183:	00 
  801184:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  80118b:	e8 04 01 00 00       	call   801294 <_panic>
}

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_fperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801190:	83 c4 2c             	add    $0x2c,%esp
  801193:	5b                   	pop    %ebx
  801194:	5e                   	pop    %esi
  801195:	5f                   	pop    %edi
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    

00801198 <sys_env_set_algchk_upcall>:

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	57                   	push   %edi
  80119c:	56                   	push   %esi
  80119d:	53                   	push   %ebx
  80119e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a6:	b8 1b 00 00 00       	mov    $0x1b,%eax
  8011ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b1:	89 df                	mov    %ebx,%edi
  8011b3:	89 de                	mov    %ebx,%esi
  8011b5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	7e 28                	jle    8011e3 <sys_env_set_algchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011bb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011bf:	c7 44 24 0c 1b 00 00 	movl   $0x1b,0xc(%esp)
  8011c6:	00 
  8011c7:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  8011ce:	00 
  8011cf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011d6:	00 
  8011d7:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  8011de:	e8 b1 00 00 00       	call   801294 <_panic>
}

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_algchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8011e3:	83 c4 2c             	add    $0x2c,%esp
  8011e6:	5b                   	pop    %ebx
  8011e7:	5e                   	pop    %esi
  8011e8:	5f                   	pop    %edi
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    

008011eb <sys_env_set_mchchk_upcall>:

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	57                   	push   %edi
  8011ef:	56                   	push   %esi
  8011f0:	53                   	push   %ebx
  8011f1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011f9:	b8 1c 00 00 00       	mov    $0x1c,%eax
  8011fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801201:	8b 55 08             	mov    0x8(%ebp),%edx
  801204:	89 df                	mov    %ebx,%edi
  801206:	89 de                	mov    %ebx,%esi
  801208:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80120a:	85 c0                	test   %eax,%eax
  80120c:	7e 28                	jle    801236 <sys_env_set_mchchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80120e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801212:	c7 44 24 0c 1c 00 00 	movl   $0x1c,0xc(%esp)
  801219:	00 
  80121a:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  801221:	00 
  801222:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801229:	00 
  80122a:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  801231:	e8 5e 00 00 00       	call   801294 <_panic>
}

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_mchchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801236:	83 c4 2c             	add    $0x2c,%esp
  801239:	5b                   	pop    %ebx
  80123a:	5e                   	pop    %esi
  80123b:	5f                   	pop    %edi
  80123c:	5d                   	pop    %ebp
  80123d:	c3                   	ret    

0080123e <sys_env_set_SIMDfperror_upcall>:

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	57                   	push   %edi
  801242:	56                   	push   %esi
  801243:	53                   	push   %ebx
  801244:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801247:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124c:	b8 1d 00 00 00       	mov    $0x1d,%eax
  801251:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801254:	8b 55 08             	mov    0x8(%ebp),%edx
  801257:	89 df                	mov    %ebx,%edi
  801259:	89 de                	mov    %ebx,%esi
  80125b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80125d:	85 c0                	test   %eax,%eax
  80125f:	7e 28                	jle    801289 <sys_env_set_SIMDfperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801261:	89 44 24 10          	mov    %eax,0x10(%esp)
  801265:	c7 44 24 0c 1d 00 00 	movl   $0x1d,0xc(%esp)
  80126c:	00 
  80126d:	c7 44 24 08 c8 17 80 	movl   $0x8017c8,0x8(%esp)
  801274:	00 
  801275:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80127c:	00 
  80127d:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  801284:	e8 0b 00 00 00       	call   801294 <_panic>
}

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_SIMDfperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801289:	83 c4 2c             	add    $0x2c,%esp
  80128c:	5b                   	pop    %ebx
  80128d:	5e                   	pop    %esi
  80128e:	5f                   	pop    %edi
  80128f:	5d                   	pop    %ebp
  801290:	c3                   	ret    
  801291:	00 00                	add    %al,(%eax)
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
  8012a5:	e8 11 f8 ff ff       	call   800abb <sys_getenvid>
  8012aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ad:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c0:	c7 04 24 f4 17 80 00 	movl   $0x8017f4,(%esp)
  8012c7:	e8 8c ee ff ff       	call   800158 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8012cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8012d3:	89 04 24             	mov    %eax,(%esp)
  8012d6:	e8 1c ee ff ff       	call   8000f7 <vcprintf>
	cprintf("\n");
  8012db:	c7 04 24 18 18 80 00 	movl   $0x801818,(%esp)
  8012e2:	e8 71 ee ff ff       	call   800158 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8012e7:	cc                   	int3   
  8012e8:	eb fd                	jmp    8012e7 <_panic+0x53>
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
