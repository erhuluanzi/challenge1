
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 c3 00 00 00       	call   8000f4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003e:	e8 18 0b 00 00       	call   800b5b <sys_getenvid>
  800043:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004b:	c7 04 24 20 14 80 00 	movl   $0x801420,(%esp)
  800052:	e8 a1 01 00 00       	call   8001f8 <cprintf>

	forkchild(cur, '0');
  800057:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80005e:	00 
  80005f:	89 1c 24             	mov    %ebx,(%esp)
  800062:	e8 16 00 00 00       	call   80007d <forkchild>
	forkchild(cur, '1');
  800067:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80006e:	00 
  80006f:	89 1c 24             	mov    %ebx,(%esp)
  800072:	e8 06 00 00 00       	call   80007d <forkchild>
}
  800077:	83 c4 14             	add    $0x14,%esp
  80007a:	5b                   	pop    %ebx
  80007b:	5d                   	pop    %ebp
  80007c:	c3                   	ret    

0080007d <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	53                   	push   %ebx
  800081:	83 ec 44             	sub    $0x44,%esp
  800084:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800087:	8a 45 0c             	mov    0xc(%ebp),%al
  80008a:	88 45 e7             	mov    %al,-0x19(%ebp)
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80008d:	89 1c 24             	mov    %ebx,(%esp)
  800090:	e8 df 06 00 00       	call   800774 <strlen>
  800095:	83 f8 02             	cmp    $0x2,%eax
  800098:	7f 40                	jg     8000da <forkchild+0x5d>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009a:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80009e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000a2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a6:	c7 44 24 08 31 14 80 	movl   $0x801431,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b5:	00 
  8000b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 8b 06 00 00       	call   80074c <snprintf>
	if (fork() == 0) {
  8000c1:	e8 2d 0e 00 00       	call   800ef3 <fork>
  8000c6:	85 c0                	test   %eax,%eax
  8000c8:	75 10                	jne    8000da <forkchild+0x5d>
		forktree(nxt);
  8000ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000cd:	89 04 24             	mov    %eax,(%esp)
  8000d0:	e8 5f ff ff ff       	call   800034 <forktree>
		exit();
  8000d5:	e8 6a 00 00 00       	call   800144 <exit>
	}
}
  8000da:	83 c4 44             	add    $0x44,%esp
  8000dd:	5b                   	pop    %ebx
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000e6:	c7 04 24 30 14 80 00 	movl   $0x801430,(%esp)
  8000ed:	e8 42 ff ff ff       	call   800034 <forktree>
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 10             	sub    $0x10,%esp
  8000fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800102:	e8 54 0a 00 00       	call   800b5b <sys_getenvid>
  800107:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010c:	8d 14 80             	lea    (%eax,%eax,4),%edx
  80010f:	8d 14 90             	lea    (%eax,%edx,4),%edx
  800112:	8d 04 50             	lea    (%eax,%edx,2),%eax
  800115:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  80011c:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800121:	85 f6                	test   %esi,%esi
  800123:	7e 07                	jle    80012c <libmain+0x38>
		binaryname = argv[0];
  800125:	8b 03                	mov    (%ebx),%eax
  800127:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800130:	89 34 24             	mov    %esi,(%esp)
  800133:	e8 a8 ff ff ff       	call   8000e0 <umain>

	// exit gracefully
	exit();
  800138:	e8 07 00 00 00       	call   800144 <exit>
}
  80013d:	83 c4 10             	add    $0x10,%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80014a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800151:	e8 b3 09 00 00       	call   800b09 <sys_env_destroy>
}
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	53                   	push   %ebx
  80015c:	83 ec 14             	sub    $0x14,%esp
  80015f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800162:	8b 03                	mov    (%ebx),%eax
  800164:	8b 55 08             	mov    0x8(%ebp),%edx
  800167:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80016b:	40                   	inc    %eax
  80016c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80016e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800173:	75 19                	jne    80018e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800175:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80017c:	00 
  80017d:	8d 43 08             	lea    0x8(%ebx),%eax
  800180:	89 04 24             	mov    %eax,(%esp)
  800183:	e8 44 09 00 00       	call   800acc <sys_cputs>
		b->idx = 0;
  800188:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80018e:	ff 43 04             	incl   0x4(%ebx)
}
  800191:	83 c4 14             	add    $0x14,%esp
  800194:	5b                   	pop    %ebx
  800195:	5d                   	pop    %ebp
  800196:	c3                   	ret    

00800197 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001a0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a7:	00 00 00 
	b.cnt = 0;
  8001aa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cc:	c7 04 24 58 01 80 00 	movl   $0x800158,(%esp)
  8001d3:	e8 b4 01 00 00       	call   80038c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	e8 dc 08 00 00       	call   800acc <sys_cputs>

	return b.cnt;
}
  8001f0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f6:	c9                   	leave  
  8001f7:	c3                   	ret    

008001f8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800201:	89 44 24 04          	mov    %eax,0x4(%esp)
  800205:	8b 45 08             	mov    0x8(%ebp),%eax
  800208:	89 04 24             	mov    %eax,(%esp)
  80020b:	e8 87 ff ff ff       	call   800197 <vcprintf>
	va_end(ap);

	return cnt;
}
  800210:	c9                   	leave  
  800211:	c3                   	ret    
	...

00800214 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 3c             	sub    $0x3c,%esp
  80021d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800220:	89 d7                	mov    %edx,%edi
  800222:	8b 45 08             	mov    0x8(%ebp),%eax
  800225:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800228:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80022e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800231:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800234:	85 c0                	test   %eax,%eax
  800236:	75 08                	jne    800240 <printnum+0x2c>
  800238:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80023b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80023e:	77 57                	ja     800297 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800240:	89 74 24 10          	mov    %esi,0x10(%esp)
  800244:	4b                   	dec    %ebx
  800245:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800249:	8b 45 10             	mov    0x10(%ebp),%eax
  80024c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800250:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800254:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800258:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80025f:	00 
  800260:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800263:	89 04 24             	mov    %eax,(%esp)
  800266:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800269:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026d:	e8 5a 0f 00 00       	call   8011cc <__udivdi3>
  800272:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800276:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80027a:	89 04 24             	mov    %eax,(%esp)
  80027d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800281:	89 fa                	mov    %edi,%edx
  800283:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800286:	e8 89 ff ff ff       	call   800214 <printnum>
  80028b:	eb 0f                	jmp    80029c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800291:	89 34 24             	mov    %esi,(%esp)
  800294:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800297:	4b                   	dec    %ebx
  800298:	85 db                	test   %ebx,%ebx
  80029a:	7f f1                	jg     80028d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ab:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b2:	00 
  8002b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002b6:	89 04 24             	mov    %eax,(%esp)
  8002b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c0:	e8 27 10 00 00       	call   8012ec <__umoddi3>
  8002c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002c9:	0f be 80 40 14 80 00 	movsbl 0x801440(%eax),%eax
  8002d0:	89 04 24             	mov    %eax,(%esp)
  8002d3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002d6:	83 c4 3c             	add    $0x3c,%esp
  8002d9:	5b                   	pop    %ebx
  8002da:	5e                   	pop    %esi
  8002db:	5f                   	pop    %edi
  8002dc:	5d                   	pop    %ebp
  8002dd:	c3                   	ret    

008002de <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e1:	83 fa 01             	cmp    $0x1,%edx
  8002e4:	7e 0e                	jle    8002f4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e6:	8b 10                	mov    (%eax),%edx
  8002e8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002eb:	89 08                	mov    %ecx,(%eax)
  8002ed:	8b 02                	mov    (%edx),%eax
  8002ef:	8b 52 04             	mov    0x4(%edx),%edx
  8002f2:	eb 22                	jmp    800316 <getuint+0x38>
	else if (lflag)
  8002f4:	85 d2                	test   %edx,%edx
  8002f6:	74 10                	je     800308 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f8:	8b 10                	mov    (%eax),%edx
  8002fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fd:	89 08                	mov    %ecx,(%eax)
  8002ff:	8b 02                	mov    (%edx),%eax
  800301:	ba 00 00 00 00       	mov    $0x0,%edx
  800306:	eb 0e                	jmp    800316 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800308:	8b 10                	mov    (%eax),%edx
  80030a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030d:	89 08                	mov    %ecx,(%eax)
  80030f:	8b 02                	mov    (%edx),%eax
  800311:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80031b:	83 fa 01             	cmp    $0x1,%edx
  80031e:	7e 0e                	jle    80032e <getint+0x16>
		return va_arg(*ap, long long);
  800320:	8b 10                	mov    (%eax),%edx
  800322:	8d 4a 08             	lea    0x8(%edx),%ecx
  800325:	89 08                	mov    %ecx,(%eax)
  800327:	8b 02                	mov    (%edx),%eax
  800329:	8b 52 04             	mov    0x4(%edx),%edx
  80032c:	eb 1a                	jmp    800348 <getint+0x30>
	else if (lflag)
  80032e:	85 d2                	test   %edx,%edx
  800330:	74 0c                	je     80033e <getint+0x26>
		return va_arg(*ap, long);
  800332:	8b 10                	mov    (%eax),%edx
  800334:	8d 4a 04             	lea    0x4(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 02                	mov    (%edx),%eax
  80033b:	99                   	cltd   
  80033c:	eb 0a                	jmp    800348 <getint+0x30>
	else
		return va_arg(*ap, int);
  80033e:	8b 10                	mov    (%eax),%edx
  800340:	8d 4a 04             	lea    0x4(%edx),%ecx
  800343:	89 08                	mov    %ecx,(%eax)
  800345:	8b 02                	mov    (%edx),%eax
  800347:	99                   	cltd   
}
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    

0080034a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800350:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800353:	8b 10                	mov    (%eax),%edx
  800355:	3b 50 04             	cmp    0x4(%eax),%edx
  800358:	73 08                	jae    800362 <sprintputch+0x18>
		*b->buf++ = ch;
  80035a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80035d:	88 0a                	mov    %cl,(%edx)
  80035f:	42                   	inc    %edx
  800360:	89 10                	mov    %edx,(%eax)
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80036a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80036d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800371:	8b 45 10             	mov    0x10(%ebp),%eax
  800374:	89 44 24 08          	mov    %eax,0x8(%esp)
  800378:	8b 45 0c             	mov    0xc(%ebp),%eax
  80037b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037f:	8b 45 08             	mov    0x8(%ebp),%eax
  800382:	89 04 24             	mov    %eax,(%esp)
  800385:	e8 02 00 00 00       	call   80038c <vprintfmt>
	va_end(ap);
}
  80038a:	c9                   	leave  
  80038b:	c3                   	ret    

0080038c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	57                   	push   %edi
  800390:	56                   	push   %esi
  800391:	53                   	push   %ebx
  800392:	83 ec 4c             	sub    $0x4c,%esp
  800395:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800398:	8b 75 10             	mov    0x10(%ebp),%esi
  80039b:	eb 12                	jmp    8003af <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80039d:	85 c0                	test   %eax,%eax
  80039f:	0f 84 40 03 00 00    	je     8006e5 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  8003a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003a9:	89 04 24             	mov    %eax,(%esp)
  8003ac:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003af:	0f b6 06             	movzbl (%esi),%eax
  8003b2:	46                   	inc    %esi
  8003b3:	83 f8 25             	cmp    $0x25,%eax
  8003b6:	75 e5                	jne    80039d <vprintfmt+0x11>
  8003b8:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003bc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003c3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003c8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d4:	eb 26                	jmp    8003fc <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003d9:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003dd:	eb 1d                	jmp    8003fc <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e2:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003e6:	eb 14                	jmp    8003fc <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003eb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003f2:	eb 08                	jmp    8003fc <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003f4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003f7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	0f b6 06             	movzbl (%esi),%eax
  8003ff:	8d 4e 01             	lea    0x1(%esi),%ecx
  800402:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800405:	8a 0e                	mov    (%esi),%cl
  800407:	83 e9 23             	sub    $0x23,%ecx
  80040a:	80 f9 55             	cmp    $0x55,%cl
  80040d:	0f 87 b6 02 00 00    	ja     8006c9 <vprintfmt+0x33d>
  800413:	0f b6 c9             	movzbl %cl,%ecx
  800416:	ff 24 8d 00 15 80 00 	jmp    *0x801500(,%ecx,4)
  80041d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800420:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800425:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800428:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  80042c:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80042f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800432:	83 f9 09             	cmp    $0x9,%ecx
  800435:	77 2a                	ja     800461 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800437:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800438:	eb eb                	jmp    800425 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8d 48 04             	lea    0x4(%eax),%ecx
  800440:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800443:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800445:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800448:	eb 17                	jmp    800461 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80044a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80044e:	78 98                	js     8003e8 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800453:	eb a7                	jmp    8003fc <vprintfmt+0x70>
  800455:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800458:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80045f:	eb 9b                	jmp    8003fc <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800461:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800465:	79 95                	jns    8003fc <vprintfmt+0x70>
  800467:	eb 8b                	jmp    8003f4 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800469:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80046d:	eb 8d                	jmp    8003fc <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80046f:	8b 45 14             	mov    0x14(%ebp),%eax
  800472:	8d 50 04             	lea    0x4(%eax),%edx
  800475:	89 55 14             	mov    %edx,0x14(%ebp)
  800478:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80047c:	8b 00                	mov    (%eax),%eax
  80047e:	89 04 24             	mov    %eax,(%esp)
  800481:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800487:	e9 23 ff ff ff       	jmp    8003af <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8d 50 04             	lea    0x4(%eax),%edx
  800492:	89 55 14             	mov    %edx,0x14(%ebp)
  800495:	8b 00                	mov    (%eax),%eax
  800497:	85 c0                	test   %eax,%eax
  800499:	79 02                	jns    80049d <vprintfmt+0x111>
  80049b:	f7 d8                	neg    %eax
  80049d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049f:	83 f8 09             	cmp    $0x9,%eax
  8004a2:	7f 0b                	jg     8004af <vprintfmt+0x123>
  8004a4:	8b 04 85 60 16 80 00 	mov    0x801660(,%eax,4),%eax
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	75 23                	jne    8004d2 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004af:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004b3:	c7 44 24 08 58 14 80 	movl   $0x801458,0x8(%esp)
  8004ba:	00 
  8004bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c2:	89 04 24             	mov    %eax,(%esp)
  8004c5:	e8 9a fe ff ff       	call   800364 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004cd:	e9 dd fe ff ff       	jmp    8003af <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004d6:	c7 44 24 08 61 14 80 	movl   $0x801461,0x8(%esp)
  8004dd:	00 
  8004de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8004e5:	89 14 24             	mov    %edx,(%esp)
  8004e8:	e8 77 fe ff ff       	call   800364 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ed:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004f0:	e9 ba fe ff ff       	jmp    8003af <vprintfmt+0x23>
  8004f5:	89 f9                	mov    %edi,%ecx
  8004f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800500:	8d 50 04             	lea    0x4(%eax),%edx
  800503:	89 55 14             	mov    %edx,0x14(%ebp)
  800506:	8b 30                	mov    (%eax),%esi
  800508:	85 f6                	test   %esi,%esi
  80050a:	75 05                	jne    800511 <vprintfmt+0x185>
				p = "(null)";
  80050c:	be 51 14 80 00       	mov    $0x801451,%esi
			if (width > 0 && padc != '-')
  800511:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800515:	0f 8e 84 00 00 00    	jle    80059f <vprintfmt+0x213>
  80051b:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80051f:	74 7e                	je     80059f <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800521:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800525:	89 34 24             	mov    %esi,(%esp)
  800528:	e8 5d 02 00 00       	call   80078a <strnlen>
  80052d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800530:	29 c2                	sub    %eax,%edx
  800532:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800535:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800539:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80053c:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80053f:	89 de                	mov    %ebx,%esi
  800541:	89 d3                	mov    %edx,%ebx
  800543:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800545:	eb 0b                	jmp    800552 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800547:	89 74 24 04          	mov    %esi,0x4(%esp)
  80054b:	89 3c 24             	mov    %edi,(%esp)
  80054e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800551:	4b                   	dec    %ebx
  800552:	85 db                	test   %ebx,%ebx
  800554:	7f f1                	jg     800547 <vprintfmt+0x1bb>
  800556:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800559:	89 f3                	mov    %esi,%ebx
  80055b:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80055e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800561:	85 c0                	test   %eax,%eax
  800563:	79 05                	jns    80056a <vprintfmt+0x1de>
  800565:	b8 00 00 00 00       	mov    $0x0,%eax
  80056a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80056d:	29 c2                	sub    %eax,%edx
  80056f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800572:	eb 2b                	jmp    80059f <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800574:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800578:	74 18                	je     800592 <vprintfmt+0x206>
  80057a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80057d:	83 fa 5e             	cmp    $0x5e,%edx
  800580:	76 10                	jbe    800592 <vprintfmt+0x206>
					putch('?', putdat);
  800582:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800586:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80058d:	ff 55 08             	call   *0x8(%ebp)
  800590:	eb 0a                	jmp    80059c <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800592:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800596:	89 04 24             	mov    %eax,(%esp)
  800599:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059c:	ff 4d e4             	decl   -0x1c(%ebp)
  80059f:	0f be 06             	movsbl (%esi),%eax
  8005a2:	46                   	inc    %esi
  8005a3:	85 c0                	test   %eax,%eax
  8005a5:	74 21                	je     8005c8 <vprintfmt+0x23c>
  8005a7:	85 ff                	test   %edi,%edi
  8005a9:	78 c9                	js     800574 <vprintfmt+0x1e8>
  8005ab:	4f                   	dec    %edi
  8005ac:	79 c6                	jns    800574 <vprintfmt+0x1e8>
  8005ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005b1:	89 de                	mov    %ebx,%esi
  8005b3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005b6:	eb 18                	jmp    8005d0 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005bc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005c3:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c5:	4b                   	dec    %ebx
  8005c6:	eb 08                	jmp    8005d0 <vprintfmt+0x244>
  8005c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005cb:	89 de                	mov    %ebx,%esi
  8005cd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005d0:	85 db                	test   %ebx,%ebx
  8005d2:	7f e4                	jg     8005b8 <vprintfmt+0x22c>
  8005d4:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005d7:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005dc:	e9 ce fd ff ff       	jmp    8003af <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e4:	e8 2f fd ff ff       	call   800318 <getint>
  8005e9:	89 c6                	mov    %eax,%esi
  8005eb:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8005ed:	85 d2                	test   %edx,%edx
  8005ef:	78 07                	js     8005f8 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f1:	be 0a 00 00 00       	mov    $0xa,%esi
  8005f6:	eb 7e                	jmp    800676 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800603:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800606:	89 f0                	mov    %esi,%eax
  800608:	89 fa                	mov    %edi,%edx
  80060a:	f7 d8                	neg    %eax
  80060c:	83 d2 00             	adc    $0x0,%edx
  80060f:	f7 da                	neg    %edx
			}
			base = 10;
  800611:	be 0a 00 00 00       	mov    $0xa,%esi
  800616:	eb 5e                	jmp    800676 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800618:	8d 45 14             	lea    0x14(%ebp),%eax
  80061b:	e8 be fc ff ff       	call   8002de <getuint>
			base = 10;
  800620:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800625:	eb 4f                	jmp    800676 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800627:	8d 45 14             	lea    0x14(%ebp),%eax
  80062a:	e8 af fc ff ff       	call   8002de <getuint>
			base = 8;
  80062f:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800634:	eb 40                	jmp    800676 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  800636:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800641:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800644:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800648:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80064f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 50 04             	lea    0x4(%eax),%edx
  800658:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065b:	8b 00                	mov    (%eax),%eax
  80065d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800662:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800667:	eb 0d                	jmp    800676 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800669:	8d 45 14             	lea    0x14(%ebp),%eax
  80066c:	e8 6d fc ff ff       	call   8002de <getuint>
			base = 16;
  800671:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800676:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  80067a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80067e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800681:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800685:	89 74 24 08          	mov    %esi,0x8(%esp)
  800689:	89 04 24             	mov    %eax,(%esp)
  80068c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800690:	89 da                	mov    %ebx,%edx
  800692:	8b 45 08             	mov    0x8(%ebp),%eax
  800695:	e8 7a fb ff ff       	call   800214 <printnum>
			break;
  80069a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80069d:	e9 0d fd ff ff       	jmp    8003af <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  8006a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a5:	e8 6e fc ff ff       	call   800318 <getint>
  8006aa:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006af:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  8006b2:	e9 f8 fc ff ff       	jmp    8003af <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bb:	89 04 24             	mov    %eax,(%esp)
  8006be:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c4:	e9 e6 fc ff ff       	jmp    8003af <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cd:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006d4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d7:	eb 01                	jmp    8006da <vprintfmt+0x34e>
  8006d9:	4e                   	dec    %esi
  8006da:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006de:	75 f9                	jne    8006d9 <vprintfmt+0x34d>
  8006e0:	e9 ca fc ff ff       	jmp    8003af <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006e5:	83 c4 4c             	add    $0x4c,%esp
  8006e8:	5b                   	pop    %ebx
  8006e9:	5e                   	pop    %esi
  8006ea:	5f                   	pop    %edi
  8006eb:	5d                   	pop    %ebp
  8006ec:	c3                   	ret    

008006ed <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	83 ec 28             	sub    $0x28,%esp
  8006f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006fc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800700:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800703:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070a:	85 c0                	test   %eax,%eax
  80070c:	74 30                	je     80073e <vsnprintf+0x51>
  80070e:	85 d2                	test   %edx,%edx
  800710:	7e 33                	jle    800745 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800719:	8b 45 10             	mov    0x10(%ebp),%eax
  80071c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800720:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800723:	89 44 24 04          	mov    %eax,0x4(%esp)
  800727:	c7 04 24 4a 03 80 00 	movl   $0x80034a,(%esp)
  80072e:	e8 59 fc ff ff       	call   80038c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800733:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800736:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800739:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073c:	eb 0c                	jmp    80074a <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800743:	eb 05                	jmp    80074a <vsnprintf+0x5d>
  800745:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    

0080074c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800752:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800755:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800759:	8b 45 10             	mov    0x10(%ebp),%eax
  80075c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800760:	8b 45 0c             	mov    0xc(%ebp),%eax
  800763:	89 44 24 04          	mov    %eax,0x4(%esp)
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	89 04 24             	mov    %eax,(%esp)
  80076d:	e8 7b ff ff ff       	call   8006ed <vsnprintf>
	va_end(ap);

	return rc;
}
  800772:	c9                   	leave  
  800773:	c3                   	ret    

00800774 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077a:	b8 00 00 00 00       	mov    $0x0,%eax
  80077f:	eb 01                	jmp    800782 <strlen+0xe>
		n++;
  800781:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800782:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800786:	75 f9                	jne    800781 <strlen+0xd>
		n++;
	return n;
}
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800790:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800793:	b8 00 00 00 00       	mov    $0x0,%eax
  800798:	eb 01                	jmp    80079b <strnlen+0x11>
		n++;
  80079a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079b:	39 d0                	cmp    %edx,%eax
  80079d:	74 06                	je     8007a5 <strnlen+0x1b>
  80079f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a3:	75 f5                	jne    80079a <strnlen+0x10>
		n++;
	return n;
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007b9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007bc:	42                   	inc    %edx
  8007bd:	84 c9                	test   %cl,%cl
  8007bf:	75 f5                	jne    8007b6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c1:	5b                   	pop    %ebx
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    

008007c4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	53                   	push   %ebx
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ce:	89 1c 24             	mov    %ebx,(%esp)
  8007d1:	e8 9e ff ff ff       	call   800774 <strlen>
	strcpy(dst + len, src);
  8007d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007dd:	01 d8                	add    %ebx,%eax
  8007df:	89 04 24             	mov    %eax,(%esp)
  8007e2:	e8 c0 ff ff ff       	call   8007a7 <strcpy>
	return dst;
}
  8007e7:	89 d8                	mov    %ebx,%eax
  8007e9:	83 c4 08             	add    $0x8,%esp
  8007ec:	5b                   	pop    %ebx
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	56                   	push   %esi
  8007f3:	53                   	push   %ebx
  8007f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fa:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800802:	eb 0c                	jmp    800810 <strncpy+0x21>
		*dst++ = *src;
  800804:	8a 1a                	mov    (%edx),%bl
  800806:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800809:	80 3a 01             	cmpb   $0x1,(%edx)
  80080c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080f:	41                   	inc    %ecx
  800810:	39 f1                	cmp    %esi,%ecx
  800812:	75 f0                	jne    800804 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800814:	5b                   	pop    %ebx
  800815:	5e                   	pop    %esi
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	56                   	push   %esi
  80081c:	53                   	push   %ebx
  80081d:	8b 75 08             	mov    0x8(%ebp),%esi
  800820:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800823:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800826:	85 d2                	test   %edx,%edx
  800828:	75 0a                	jne    800834 <strlcpy+0x1c>
  80082a:	89 f0                	mov    %esi,%eax
  80082c:	eb 1a                	jmp    800848 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80082e:	88 18                	mov    %bl,(%eax)
  800830:	40                   	inc    %eax
  800831:	41                   	inc    %ecx
  800832:	eb 02                	jmp    800836 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800834:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800836:	4a                   	dec    %edx
  800837:	74 0a                	je     800843 <strlcpy+0x2b>
  800839:	8a 19                	mov    (%ecx),%bl
  80083b:	84 db                	test   %bl,%bl
  80083d:	75 ef                	jne    80082e <strlcpy+0x16>
  80083f:	89 c2                	mov    %eax,%edx
  800841:	eb 02                	jmp    800845 <strlcpy+0x2d>
  800843:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800845:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800848:	29 f0                	sub    %esi,%eax
}
  80084a:	5b                   	pop    %ebx
  80084b:	5e                   	pop    %esi
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800854:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800857:	eb 02                	jmp    80085b <strcmp+0xd>
		p++, q++;
  800859:	41                   	inc    %ecx
  80085a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80085b:	8a 01                	mov    (%ecx),%al
  80085d:	84 c0                	test   %al,%al
  80085f:	74 04                	je     800865 <strcmp+0x17>
  800861:	3a 02                	cmp    (%edx),%al
  800863:	74 f4                	je     800859 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800865:	0f b6 c0             	movzbl %al,%eax
  800868:	0f b6 12             	movzbl (%edx),%edx
  80086b:	29 d0                	sub    %edx,%eax
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	53                   	push   %ebx
  800873:	8b 45 08             	mov    0x8(%ebp),%eax
  800876:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800879:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80087c:	eb 03                	jmp    800881 <strncmp+0x12>
		n--, p++, q++;
  80087e:	4a                   	dec    %edx
  80087f:	40                   	inc    %eax
  800880:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800881:	85 d2                	test   %edx,%edx
  800883:	74 14                	je     800899 <strncmp+0x2a>
  800885:	8a 18                	mov    (%eax),%bl
  800887:	84 db                	test   %bl,%bl
  800889:	74 04                	je     80088f <strncmp+0x20>
  80088b:	3a 19                	cmp    (%ecx),%bl
  80088d:	74 ef                	je     80087e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088f:	0f b6 00             	movzbl (%eax),%eax
  800892:	0f b6 11             	movzbl (%ecx),%edx
  800895:	29 d0                	sub    %edx,%eax
  800897:	eb 05                	jmp    80089e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089e:	5b                   	pop    %ebx
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008aa:	eb 05                	jmp    8008b1 <strchr+0x10>
		if (*s == c)
  8008ac:	38 ca                	cmp    %cl,%dl
  8008ae:	74 0c                	je     8008bc <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b0:	40                   	inc    %eax
  8008b1:	8a 10                	mov    (%eax),%dl
  8008b3:	84 d2                	test   %dl,%dl
  8008b5:	75 f5                	jne    8008ac <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008c7:	eb 05                	jmp    8008ce <strfind+0x10>
		if (*s == c)
  8008c9:	38 ca                	cmp    %cl,%dl
  8008cb:	74 07                	je     8008d4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008cd:	40                   	inc    %eax
  8008ce:	8a 10                	mov    (%eax),%dl
  8008d0:	84 d2                	test   %dl,%dl
  8008d2:	75 f5                	jne    8008c9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	57                   	push   %edi
  8008da:	56                   	push   %esi
  8008db:	53                   	push   %ebx
  8008dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e5:	85 c9                	test   %ecx,%ecx
  8008e7:	74 30                	je     800919 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ef:	75 25                	jne    800916 <memset+0x40>
  8008f1:	f6 c1 03             	test   $0x3,%cl
  8008f4:	75 20                	jne    800916 <memset+0x40>
		c &= 0xFF;
  8008f6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f9:	89 d3                	mov    %edx,%ebx
  8008fb:	c1 e3 08             	shl    $0x8,%ebx
  8008fe:	89 d6                	mov    %edx,%esi
  800900:	c1 e6 18             	shl    $0x18,%esi
  800903:	89 d0                	mov    %edx,%eax
  800905:	c1 e0 10             	shl    $0x10,%eax
  800908:	09 f0                	or     %esi,%eax
  80090a:	09 d0                	or     %edx,%eax
  80090c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80090e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800911:	fc                   	cld    
  800912:	f3 ab                	rep stos %eax,%es:(%edi)
  800914:	eb 03                	jmp    800919 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800916:	fc                   	cld    
  800917:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800919:	89 f8                	mov    %edi,%eax
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5f                   	pop    %edi
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	57                   	push   %edi
  800924:	56                   	push   %esi
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092e:	39 c6                	cmp    %eax,%esi
  800930:	73 34                	jae    800966 <memmove+0x46>
  800932:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800935:	39 d0                	cmp    %edx,%eax
  800937:	73 2d                	jae    800966 <memmove+0x46>
		s += n;
		d += n;
  800939:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093c:	f6 c2 03             	test   $0x3,%dl
  80093f:	75 1b                	jne    80095c <memmove+0x3c>
  800941:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800947:	75 13                	jne    80095c <memmove+0x3c>
  800949:	f6 c1 03             	test   $0x3,%cl
  80094c:	75 0e                	jne    80095c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80094e:	83 ef 04             	sub    $0x4,%edi
  800951:	8d 72 fc             	lea    -0x4(%edx),%esi
  800954:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800957:	fd                   	std    
  800958:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095a:	eb 07                	jmp    800963 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80095c:	4f                   	dec    %edi
  80095d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800960:	fd                   	std    
  800961:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800963:	fc                   	cld    
  800964:	eb 20                	jmp    800986 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800966:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096c:	75 13                	jne    800981 <memmove+0x61>
  80096e:	a8 03                	test   $0x3,%al
  800970:	75 0f                	jne    800981 <memmove+0x61>
  800972:	f6 c1 03             	test   $0x3,%cl
  800975:	75 0a                	jne    800981 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800977:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80097a:	89 c7                	mov    %eax,%edi
  80097c:	fc                   	cld    
  80097d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097f:	eb 05                	jmp    800986 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800981:	89 c7                	mov    %eax,%edi
  800983:	fc                   	cld    
  800984:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800986:	5e                   	pop    %esi
  800987:	5f                   	pop    %edi
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800990:	8b 45 10             	mov    0x10(%ebp),%eax
  800993:	89 44 24 08          	mov    %eax,0x8(%esp)
  800997:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	89 04 24             	mov    %eax,(%esp)
  8009a4:	e8 77 ff ff ff       	call   800920 <memmove>
}
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	57                   	push   %edi
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bf:	eb 16                	jmp    8009d7 <memcmp+0x2c>
		if (*s1 != *s2)
  8009c1:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009c4:	42                   	inc    %edx
  8009c5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009c9:	38 c8                	cmp    %cl,%al
  8009cb:	74 0a                	je     8009d7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009cd:	0f b6 c0             	movzbl %al,%eax
  8009d0:	0f b6 c9             	movzbl %cl,%ecx
  8009d3:	29 c8                	sub    %ecx,%eax
  8009d5:	eb 09                	jmp    8009e0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d7:	39 da                	cmp    %ebx,%edx
  8009d9:	75 e6                	jne    8009c1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e0:	5b                   	pop    %ebx
  8009e1:	5e                   	pop    %esi
  8009e2:	5f                   	pop    %edi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ee:	89 c2                	mov    %eax,%edx
  8009f0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009f3:	eb 05                	jmp    8009fa <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f5:	38 08                	cmp    %cl,(%eax)
  8009f7:	74 05                	je     8009fe <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f9:	40                   	inc    %eax
  8009fa:	39 d0                	cmp    %edx,%eax
  8009fc:	72 f7                	jb     8009f5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	57                   	push   %edi
  800a04:	56                   	push   %esi
  800a05:	53                   	push   %ebx
  800a06:	8b 55 08             	mov    0x8(%ebp),%edx
  800a09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0c:	eb 01                	jmp    800a0f <strtol+0xf>
		s++;
  800a0e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0f:	8a 02                	mov    (%edx),%al
  800a11:	3c 20                	cmp    $0x20,%al
  800a13:	74 f9                	je     800a0e <strtol+0xe>
  800a15:	3c 09                	cmp    $0x9,%al
  800a17:	74 f5                	je     800a0e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a19:	3c 2b                	cmp    $0x2b,%al
  800a1b:	75 08                	jne    800a25 <strtol+0x25>
		s++;
  800a1d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a1e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a23:	eb 13                	jmp    800a38 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a25:	3c 2d                	cmp    $0x2d,%al
  800a27:	75 0a                	jne    800a33 <strtol+0x33>
		s++, neg = 1;
  800a29:	8d 52 01             	lea    0x1(%edx),%edx
  800a2c:	bf 01 00 00 00       	mov    $0x1,%edi
  800a31:	eb 05                	jmp    800a38 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a33:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a38:	85 db                	test   %ebx,%ebx
  800a3a:	74 05                	je     800a41 <strtol+0x41>
  800a3c:	83 fb 10             	cmp    $0x10,%ebx
  800a3f:	75 28                	jne    800a69 <strtol+0x69>
  800a41:	8a 02                	mov    (%edx),%al
  800a43:	3c 30                	cmp    $0x30,%al
  800a45:	75 10                	jne    800a57 <strtol+0x57>
  800a47:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a4b:	75 0a                	jne    800a57 <strtol+0x57>
		s += 2, base = 16;
  800a4d:	83 c2 02             	add    $0x2,%edx
  800a50:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a55:	eb 12                	jmp    800a69 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a57:	85 db                	test   %ebx,%ebx
  800a59:	75 0e                	jne    800a69 <strtol+0x69>
  800a5b:	3c 30                	cmp    $0x30,%al
  800a5d:	75 05                	jne    800a64 <strtol+0x64>
		s++, base = 8;
  800a5f:	42                   	inc    %edx
  800a60:	b3 08                	mov    $0x8,%bl
  800a62:	eb 05                	jmp    800a69 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a64:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a69:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a70:	8a 0a                	mov    (%edx),%cl
  800a72:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a75:	80 fb 09             	cmp    $0x9,%bl
  800a78:	77 08                	ja     800a82 <strtol+0x82>
			dig = *s - '0';
  800a7a:	0f be c9             	movsbl %cl,%ecx
  800a7d:	83 e9 30             	sub    $0x30,%ecx
  800a80:	eb 1e                	jmp    800aa0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a82:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a85:	80 fb 19             	cmp    $0x19,%bl
  800a88:	77 08                	ja     800a92 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a8a:	0f be c9             	movsbl %cl,%ecx
  800a8d:	83 e9 57             	sub    $0x57,%ecx
  800a90:	eb 0e                	jmp    800aa0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a92:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a95:	80 fb 19             	cmp    $0x19,%bl
  800a98:	77 12                	ja     800aac <strtol+0xac>
			dig = *s - 'A' + 10;
  800a9a:	0f be c9             	movsbl %cl,%ecx
  800a9d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aa0:	39 f1                	cmp    %esi,%ecx
  800aa2:	7d 0c                	jge    800ab0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800aa4:	42                   	inc    %edx
  800aa5:	0f af c6             	imul   %esi,%eax
  800aa8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800aaa:	eb c4                	jmp    800a70 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800aac:	89 c1                	mov    %eax,%ecx
  800aae:	eb 02                	jmp    800ab2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ab2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab6:	74 05                	je     800abd <strtol+0xbd>
		*endptr = (char *) s;
  800ab8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800abb:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800abd:	85 ff                	test   %edi,%edi
  800abf:	74 04                	je     800ac5 <strtol+0xc5>
  800ac1:	89 c8                	mov    %ecx,%eax
  800ac3:	f7 d8                	neg    %eax
}
  800ac5:	5b                   	pop    %ebx
  800ac6:	5e                   	pop    %esi
  800ac7:	5f                   	pop    %edi
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    
	...

00800acc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ada:	8b 55 08             	mov    0x8(%ebp),%edx
  800add:	89 c3                	mov    %eax,%ebx
  800adf:	89 c7                	mov    %eax,%edi
  800ae1:	89 c6                	mov    %eax,%esi
  800ae3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <sys_cgetc>:

int
sys_cgetc(void)
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
  800af5:	b8 01 00 00 00       	mov    $0x1,%eax
  800afa:	89 d1                	mov    %edx,%ecx
  800afc:	89 d3                	mov    %edx,%ebx
  800afe:	89 d7                	mov    %edx,%edi
  800b00:	89 d6                	mov    %edx,%esi
  800b02:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800b12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b17:	b8 03 00 00 00       	mov    $0x3,%eax
  800b1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1f:	89 cb                	mov    %ecx,%ebx
  800b21:	89 cf                	mov    %ecx,%edi
  800b23:	89 ce                	mov    %ecx,%esi
  800b25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b27:	85 c0                	test   %eax,%eax
  800b29:	7e 28                	jle    800b53 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b2f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b36:	00 
  800b37:	c7 44 24 08 88 16 80 	movl   $0x801688,0x8(%esp)
  800b3e:	00 
  800b3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b46:	00 
  800b47:	c7 04 24 a5 16 80 00 	movl   $0x8016a5,(%esp)
  800b4e:	e8 65 05 00 00       	call   8010b8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b53:	83 c4 2c             	add    $0x2c,%esp
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	ba 00 00 00 00       	mov    $0x0,%edx
  800b66:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6b:	89 d1                	mov    %edx,%ecx
  800b6d:	89 d3                	mov    %edx,%ebx
  800b6f:	89 d7                	mov    %edx,%edi
  800b71:	89 d6                	mov    %edx,%esi
  800b73:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <sys_yield>:

void
sys_yield(void)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b8a:	89 d1                	mov    %edx,%ecx
  800b8c:	89 d3                	mov    %edx,%ebx
  800b8e:	89 d7                	mov    %edx,%edi
  800b90:	89 d6                	mov    %edx,%esi
  800b92:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
  800b9f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	be 00 00 00 00       	mov    $0x0,%esi
  800ba7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800baf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb5:	89 f7                	mov    %esi,%edi
  800bb7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	7e 28                	jle    800be5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bc8:	00 
  800bc9:	c7 44 24 08 88 16 80 	movl   $0x801688,0x8(%esp)
  800bd0:	00 
  800bd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bd8:	00 
  800bd9:	c7 04 24 a5 16 80 00 	movl   $0x8016a5,(%esp)
  800be0:	e8 d3 04 00 00       	call   8010b8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be5:	83 c4 2c             	add    $0x2c,%esp
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800bf6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bfb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c07:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	7e 28                	jle    800c38 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c14:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c1b:	00 
  800c1c:	c7 44 24 08 88 16 80 	movl   $0x801688,0x8(%esp)
  800c23:	00 
  800c24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c2b:	00 
  800c2c:	c7 04 24 a5 16 80 00 	movl   $0x8016a5,(%esp)
  800c33:	e8 80 04 00 00       	call   8010b8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c38:	83 c4 2c             	add    $0x2c,%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c56:	8b 55 08             	mov    0x8(%ebp),%edx
  800c59:	89 df                	mov    %ebx,%edi
  800c5b:	89 de                	mov    %ebx,%esi
  800c5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7e 28                	jle    800c8b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c67:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c6e:	00 
  800c6f:	c7 44 24 08 88 16 80 	movl   $0x801688,0x8(%esp)
  800c76:	00 
  800c77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c7e:	00 
  800c7f:	c7 04 24 a5 16 80 00 	movl   $0x8016a5,(%esp)
  800c86:	e8 2d 04 00 00       	call   8010b8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c8b:	83 c4 2c             	add    $0x2c,%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	89 df                	mov    %ebx,%edi
  800cae:	89 de                	mov    %ebx,%esi
  800cb0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	7e 28                	jle    800cde <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cba:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cc1:	00 
  800cc2:	c7 44 24 08 88 16 80 	movl   $0x801688,0x8(%esp)
  800cc9:	00 
  800cca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd1:	00 
  800cd2:	c7 04 24 a5 16 80 00 	movl   $0x8016a5,(%esp)
  800cd9:	e8 da 03 00 00       	call   8010b8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cde:	83 c4 2c             	add    $0x2c,%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
  800cec:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cef:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf4:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	89 df                	mov    %ebx,%edi
  800d01:	89 de                	mov    %ebx,%esi
  800d03:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d05:	85 c0                	test   %eax,%eax
  800d07:	7e 28                	jle    800d31 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d09:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d14:	00 
  800d15:	c7 44 24 08 88 16 80 	movl   $0x801688,0x8(%esp)
  800d1c:	00 
  800d1d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d24:	00 
  800d25:	c7 04 24 a5 16 80 00 	movl   $0x8016a5,(%esp)
  800d2c:	e8 87 03 00 00       	call   8010b8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d31:	83 c4 2c             	add    $0x2c,%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	57                   	push   %edi
  800d3d:	56                   	push   %esi
  800d3e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3f:	be 00 00 00 00       	mov    $0x0,%esi
  800d44:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d49:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d52:	8b 55 08             	mov    0x8(%ebp),%edx
  800d55:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d57:	5b                   	pop    %ebx
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	57                   	push   %edi
  800d60:	56                   	push   %esi
  800d61:	53                   	push   %ebx
  800d62:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	89 cb                	mov    %ecx,%ebx
  800d74:	89 cf                	mov    %ecx,%edi
  800d76:	89 ce                	mov    %ecx,%esi
  800d78:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	7e 28                	jle    800da6 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d82:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d89:	00 
  800d8a:	c7 44 24 08 88 16 80 	movl   $0x801688,0x8(%esp)
  800d91:	00 
  800d92:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d99:	00 
  800d9a:	c7 04 24 a5 16 80 00 	movl   $0x8016a5,(%esp)
  800da1:	e8 12 03 00 00       	call   8010b8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da6:	83 c4 2c             	add    $0x2c,%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    
	...

00800db0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	53                   	push   %ebx
  800db4:	83 ec 24             	sub    $0x24,%esp
  800db7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dba:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800dbc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dc0:	74 2d                	je     800def <pgfault+0x3f>
  800dc2:	89 d8                	mov    %ebx,%eax
  800dc4:	c1 e8 16             	shr    $0x16,%eax
  800dc7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800dce:	a8 01                	test   $0x1,%al
  800dd0:	74 1d                	je     800def <pgfault+0x3f>
		(uvpt[PGNUM(addr)] & PTE_P) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800dd2:	89 d8                	mov    %ebx,%eax
  800dd4:	c1 e8 0c             	shr    $0xc,%eax
  800dd7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800dde:	f6 c2 01             	test   $0x1,%dl
  800de1:	74 0c                	je     800def <pgfault+0x3f>
		(uvpt[PGNUM(addr)] & PTE_P) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800de3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dea:	f6 c4 08             	test   $0x8,%ah
  800ded:	75 1c                	jne    800e0b <pgfault+0x5b>
		panic("pgfault: not a write or a copy on write page fault!");
  800def:	c7 44 24 08 b4 16 80 	movl   $0x8016b4,0x8(%esp)
  800df6:	00 
  800df7:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800dfe:	00 
  800dff:	c7 04 24 e8 16 80 00 	movl   $0x8016e8,(%esp)
  800e06:	e8 ad 02 00 00       	call   8010b8 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	// we need to make addr page-aligned
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)) < 0)
  800e0b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e12:	00 
  800e13:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e1a:	00 
  800e1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e22:	e8 72 fd ff ff       	call   800b99 <sys_page_alloc>
  800e27:	85 c0                	test   %eax,%eax
  800e29:	79 20                	jns    800e4b <pgfault+0x9b>
		panic("pgfault: sys_page_alloc: %e", r);
  800e2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e2f:	c7 44 24 08 f3 16 80 	movl   $0x8016f3,0x8(%esp)
  800e36:	00 
  800e37:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800e3e:	00 
  800e3f:	c7 04 24 e8 16 80 00 	movl   $0x8016e8,(%esp)
  800e46:	e8 6d 02 00 00       	call   8010b8 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// we need to make addr page-aligned
	addr = ROUNDDOWN(addr, PGSIZE);
  800e4b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)) < 0)
		panic("pgfault: sys_page_alloc: %e", r);
	memcpy(PFTEMP, addr, PGSIZE);
  800e51:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800e58:	00 
  800e59:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e5d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800e64:	e8 21 fb ff ff       	call   80098a <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P)) < 0)
  800e69:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800e70:	00 
  800e71:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e75:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e7c:	00 
  800e7d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e84:	00 
  800e85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e8c:	e8 5c fd ff ff       	call   800bed <sys_page_map>
  800e91:	85 c0                	test   %eax,%eax
  800e93:	79 20                	jns    800eb5 <pgfault+0x105>
		panic("pgfault: sys_page_map: %e", r);
  800e95:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e99:	c7 44 24 08 0f 17 80 	movl   $0x80170f,0x8(%esp)
  800ea0:	00 
  800ea1:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800ea8:	00 
  800ea9:	c7 04 24 e8 16 80 00 	movl   $0x8016e8,(%esp)
  800eb0:	e8 03 02 00 00       	call   8010b8 <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800eb5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ebc:	00 
  800ebd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ec4:	e8 77 fd ff ff       	call   800c40 <sys_page_unmap>
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	79 20                	jns    800eed <pgfault+0x13d>
		panic("pgfault: sys_page_unmap: %e", r);
  800ecd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ed1:	c7 44 24 08 29 17 80 	movl   $0x801729,0x8(%esp)
  800ed8:	00 
  800ed9:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800ee0:	00 
  800ee1:	c7 04 24 e8 16 80 00 	movl   $0x8016e8,(%esp)
  800ee8:	e8 cb 01 00 00       	call   8010b8 <_panic>
}
  800eed:	83 c4 24             	add    $0x24,%esp
  800ef0:	5b                   	pop    %ebx
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	57                   	push   %edi
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800efc:	c7 04 24 b0 0d 80 00 	movl   $0x800db0,(%esp)
  800f03:	e8 08 02 00 00       	call   801110 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f08:	ba 07 00 00 00       	mov    $0x7,%edx
  800f0d:	89 d0                	mov    %edx,%eax
  800f0f:	cd 30                	int    $0x30
  800f11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f14:	89 c7                	mov    %eax,%edi
	envid_t envid;
	uint8_t *addr;
	int r;
	extern unsigned char end[];
	envid = sys_exofork();
	if (envid < 0)
  800f16:	85 c0                	test   %eax,%eax
  800f18:	79 20                	jns    800f3a <fork+0x47>
		panic("sys_exofork: %e", envid);
  800f1a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f1e:	c7 44 24 08 45 17 80 	movl   $0x801745,0x8(%esp)
  800f25:	00 
  800f26:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  800f2d:	00 
  800f2e:	c7 04 24 e8 16 80 00 	movl   $0x8016e8,(%esp)
  800f35:	e8 7e 01 00 00       	call   8010b8 <_panic>
	if (envid == 0) {
  800f3a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f3e:	75 29                	jne    800f69 <fork+0x76>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800f40:	e8 16 fc ff ff       	call   800b5b <sys_getenvid>
  800f45:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f4a:	8d 14 80             	lea    (%eax,%eax,4),%edx
  800f4d:	8d 14 90             	lea    (%eax,%edx,4),%edx
  800f50:	8d 04 50             	lea    (%eax,%edx,2),%eax
  800f53:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  800f5a:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800f5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f64:	e9 23 01 00 00       	jmp    80108c <fork+0x199>
	int r;
	extern unsigned char end[];
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  800f69:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	}

	// We're the parent.
	for (addr = 0; addr < (uint8_t *)USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  800f6e:	89 d8                	mov    %ebx,%eax
  800f70:	c1 e8 16             	shr    $0x16,%eax
  800f73:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f7a:	a8 01                	test   $0x1,%al
  800f7c:	0f 84 ac 00 00 00    	je     80102e <fork+0x13b>
  800f82:	89 d8                	mov    %ebx,%eax
  800f84:	c1 e8 0c             	shr    $0xc,%eax
  800f87:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f8e:	f6 c2 01             	test   $0x1,%dl
  800f91:	0f 84 97 00 00 00    	je     80102e <fork+0x13b>
			&& (uvpt[PGNUM(addr)] & PTE_U))
  800f97:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f9e:	f6 c2 04             	test   $0x4,%dl
  800fa1:	0f 84 87 00 00 00    	je     80102e <fork+0x13b>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	void *va = (void *)(pn * PGSIZE);
  800fa7:	89 c6                	mov    %eax,%esi
  800fa9:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  800fac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb3:	f6 c2 02             	test   $0x2,%dl
  800fb6:	75 0c                	jne    800fc4 <fork+0xd1>
  800fb8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fbf:	f6 c4 08             	test   $0x8,%ah
  800fc2:	74 4a                	je     80100e <fork+0x11b>
		if ((r = sys_page_map(0, va, envid, va, PTE_COW|PTE_U|PTE_P)) < 0)
  800fc4:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  800fcb:	00 
  800fcc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800fd0:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fd8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fdf:	e8 09 fc ff ff       	call   800bed <sys_page_map>
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	78 46                	js     80102e <fork+0x13b>
			return r;
		if ((r = sys_page_map(0, va, 0, va, PTE_COW|PTE_U|PTE_P)) < 0)
  800fe8:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  800fef:	00 
  800ff0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ff4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ffb:	00 
  800ffc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801000:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801007:	e8 e1 fb ff ff       	call   800bed <sys_page_map>
  80100c:	eb 20                	jmp    80102e <fork+0x13b>
			return r;
	}
	else {
		if ((r = sys_page_map(0, va, envid, va, PTE_U|PTE_P)) < 0)
  80100e:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801015:	00 
  801016:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80101a:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80101e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801022:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801029:	e8 bf fb ff ff       	call   800bed <sys_page_map>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	// We're the parent.
	for (addr = 0; addr < (uint8_t *)USTACKTOP; addr += PGSIZE)
  80102e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801034:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80103a:	0f 85 2e ff ff ff    	jne    800f6e <fork+0x7b>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
			&& (uvpt[PGNUM(addr)] & PTE_U))
			duppage(envid, PGNUM(addr));

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  801040:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801047:	00 
  801048:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80104f:	ee 
  801050:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801053:	89 04 24             	mov    %eax,(%esp)
  801056:	e8 3e fb ff ff       	call   800b99 <sys_page_alloc>
  80105b:	85 c0                	test   %eax,%eax
  80105d:	78 2d                	js     80108c <fork+0x199>
		return r;
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80105f:	c7 44 24 04 a4 11 80 	movl   $0x8011a4,0x4(%esp)
  801066:	00 
  801067:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80106a:	89 04 24             	mov    %eax,(%esp)
  80106d:	e8 74 fc ff ff       	call   800ce6 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801072:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801079:	00 
  80107a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80107d:	89 04 24             	mov    %eax,(%esp)
  801080:	e8 0e fc ff ff       	call   800c93 <sys_env_set_status>
  801085:	85 c0                	test   %eax,%eax
  801087:	78 03                	js     80108c <fork+0x199>
		return r;

	return envid;
  801089:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  80108c:	83 c4 3c             	add    $0x3c,%esp
  80108f:	5b                   	pop    %ebx
  801090:	5e                   	pop    %esi
  801091:	5f                   	pop    %edi
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <sfork>:

// Challenge!
int
sfork(void)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80109a:	c7 44 24 08 55 17 80 	movl   $0x801755,0x8(%esp)
  8010a1:	00 
  8010a2:	c7 44 24 04 8d 00 00 	movl   $0x8d,0x4(%esp)
  8010a9:	00 
  8010aa:	c7 04 24 e8 16 80 00 	movl   $0x8016e8,(%esp)
  8010b1:	e8 02 00 00 00       	call   8010b8 <_panic>
	...

008010b8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	56                   	push   %esi
  8010bc:	53                   	push   %ebx
  8010bd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8010c0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010c3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8010c9:	e8 8d fa ff ff       	call   800b5b <sys_getenvid>
  8010ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010dc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e4:	c7 04 24 6c 17 80 00 	movl   $0x80176c,(%esp)
  8010eb:	e8 08 f1 ff ff       	call   8001f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8010f7:	89 04 24             	mov    %eax,(%esp)
  8010fa:	e8 98 f0 ff ff       	call   800197 <vcprintf>
	cprintf("\n");
  8010ff:	c7 04 24 2f 14 80 00 	movl   $0x80142f,(%esp)
  801106:	e8 ed f0 ff ff       	call   8001f8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80110b:	cc                   	int3   
  80110c:	eb fd                	jmp    80110b <_panic+0x53>
	...

00801110 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801116:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  80111d:	75 40                	jne    80115f <set_pgfault_handler+0x4f>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
  80111f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801126:	00 
  801127:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80112e:	ee 
  80112f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801136:	e8 5e fa ff ff       	call   800b99 <sys_page_alloc>
  80113b:	85 c0                	test   %eax,%eax
  80113d:	79 20                	jns    80115f <set_pgfault_handler+0x4f>
            panic("set_pgfault_handler: sys_page_alloc: %e", r);
  80113f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801143:	c7 44 24 08 90 17 80 	movl   $0x801790,0x8(%esp)
  80114a:	00 
  80114b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801152:	00 
  801153:	c7 04 24 ec 17 80 00 	movl   $0x8017ec,(%esp)
  80115a:	e8 59 ff ff ff       	call   8010b8 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80115f:	8b 45 08             	mov    0x8(%ebp),%eax
  801162:	a3 0c 20 80 00       	mov    %eax,0x80200c
    if ((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0 )
  801167:	c7 44 24 04 a4 11 80 	movl   $0x8011a4,0x4(%esp)
  80116e:	00 
  80116f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801176:	e8 6b fb ff ff       	call   800ce6 <sys_env_set_pgfault_upcall>
  80117b:	85 c0                	test   %eax,%eax
  80117d:	79 20                	jns    80119f <set_pgfault_handler+0x8f>
        panic("set_pgfault_handler: sys_env_set_pgfault_upcall: %e", r);
  80117f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801183:	c7 44 24 08 b8 17 80 	movl   $0x8017b8,0x8(%esp)
  80118a:	00 
  80118b:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  801192:	00 
  801193:	c7 04 24 ec 17 80 00 	movl   $0x8017ec,(%esp)
  80119a:	e8 19 ff ff ff       	call   8010b8 <_panic>
}
  80119f:	c9                   	leave  
  8011a0:	c3                   	ret    
  8011a1:	00 00                	add    %al,(%eax)
	...

008011a4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8011a4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8011a5:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8011aa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8011ac:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// sub 4 from old esp
	movl 0x30(%esp), %eax
  8011af:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8011b3:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8011b6:	89 44 24 30          	mov    %eax,0x30(%esp)
	// put old eip into the pre-reserved 4-byte space
	movl 0x28(%esp), %ebx
  8011ba:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8011be:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8011c0:	83 c4 08             	add    $0x8,%esp
	popal
  8011c3:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  8011c4:	83 c4 04             	add    $0x4,%esp
	popfl
  8011c7:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8011c8:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8011c9:	c3                   	ret    
	...

008011cc <__udivdi3>:
  8011cc:	55                   	push   %ebp
  8011cd:	57                   	push   %edi
  8011ce:	56                   	push   %esi
  8011cf:	83 ec 10             	sub    $0x10,%esp
  8011d2:	8b 74 24 20          	mov    0x20(%esp),%esi
  8011d6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011de:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8011e2:	89 cd                	mov    %ecx,%ebp
  8011e4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	75 2c                	jne    801218 <__udivdi3+0x4c>
  8011ec:	39 f9                	cmp    %edi,%ecx
  8011ee:	77 68                	ja     801258 <__udivdi3+0x8c>
  8011f0:	85 c9                	test   %ecx,%ecx
  8011f2:	75 0b                	jne    8011ff <__udivdi3+0x33>
  8011f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8011f9:	31 d2                	xor    %edx,%edx
  8011fb:	f7 f1                	div    %ecx
  8011fd:	89 c1                	mov    %eax,%ecx
  8011ff:	31 d2                	xor    %edx,%edx
  801201:	89 f8                	mov    %edi,%eax
  801203:	f7 f1                	div    %ecx
  801205:	89 c7                	mov    %eax,%edi
  801207:	89 f0                	mov    %esi,%eax
  801209:	f7 f1                	div    %ecx
  80120b:	89 c6                	mov    %eax,%esi
  80120d:	89 f0                	mov    %esi,%eax
  80120f:	89 fa                	mov    %edi,%edx
  801211:	83 c4 10             	add    $0x10,%esp
  801214:	5e                   	pop    %esi
  801215:	5f                   	pop    %edi
  801216:	5d                   	pop    %ebp
  801217:	c3                   	ret    
  801218:	39 f8                	cmp    %edi,%eax
  80121a:	77 2c                	ja     801248 <__udivdi3+0x7c>
  80121c:	0f bd f0             	bsr    %eax,%esi
  80121f:	83 f6 1f             	xor    $0x1f,%esi
  801222:	75 4c                	jne    801270 <__udivdi3+0xa4>
  801224:	39 f8                	cmp    %edi,%eax
  801226:	bf 00 00 00 00       	mov    $0x0,%edi
  80122b:	72 0a                	jb     801237 <__udivdi3+0x6b>
  80122d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801231:	0f 87 ad 00 00 00    	ja     8012e4 <__udivdi3+0x118>
  801237:	be 01 00 00 00       	mov    $0x1,%esi
  80123c:	89 f0                	mov    %esi,%eax
  80123e:	89 fa                	mov    %edi,%edx
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	5e                   	pop    %esi
  801244:	5f                   	pop    %edi
  801245:	5d                   	pop    %ebp
  801246:	c3                   	ret    
  801247:	90                   	nop
  801248:	31 ff                	xor    %edi,%edi
  80124a:	31 f6                	xor    %esi,%esi
  80124c:	89 f0                	mov    %esi,%eax
  80124e:	89 fa                	mov    %edi,%edx
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	5e                   	pop    %esi
  801254:	5f                   	pop    %edi
  801255:	5d                   	pop    %ebp
  801256:	c3                   	ret    
  801257:	90                   	nop
  801258:	89 fa                	mov    %edi,%edx
  80125a:	89 f0                	mov    %esi,%eax
  80125c:	f7 f1                	div    %ecx
  80125e:	89 c6                	mov    %eax,%esi
  801260:	31 ff                	xor    %edi,%edi
  801262:	89 f0                	mov    %esi,%eax
  801264:	89 fa                	mov    %edi,%edx
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	5e                   	pop    %esi
  80126a:	5f                   	pop    %edi
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    
  80126d:	8d 76 00             	lea    0x0(%esi),%esi
  801270:	89 f1                	mov    %esi,%ecx
  801272:	d3 e0                	shl    %cl,%eax
  801274:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801278:	b8 20 00 00 00       	mov    $0x20,%eax
  80127d:	29 f0                	sub    %esi,%eax
  80127f:	89 ea                	mov    %ebp,%edx
  801281:	88 c1                	mov    %al,%cl
  801283:	d3 ea                	shr    %cl,%edx
  801285:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801289:	09 ca                	or     %ecx,%edx
  80128b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80128f:	89 f1                	mov    %esi,%ecx
  801291:	d3 e5                	shl    %cl,%ebp
  801293:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801297:	89 fd                	mov    %edi,%ebp
  801299:	88 c1                	mov    %al,%cl
  80129b:	d3 ed                	shr    %cl,%ebp
  80129d:	89 fa                	mov    %edi,%edx
  80129f:	89 f1                	mov    %esi,%ecx
  8012a1:	d3 e2                	shl    %cl,%edx
  8012a3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012a7:	88 c1                	mov    %al,%cl
  8012a9:	d3 ef                	shr    %cl,%edi
  8012ab:	09 d7                	or     %edx,%edi
  8012ad:	89 f8                	mov    %edi,%eax
  8012af:	89 ea                	mov    %ebp,%edx
  8012b1:	f7 74 24 08          	divl   0x8(%esp)
  8012b5:	89 d1                	mov    %edx,%ecx
  8012b7:	89 c7                	mov    %eax,%edi
  8012b9:	f7 64 24 0c          	mull   0xc(%esp)
  8012bd:	39 d1                	cmp    %edx,%ecx
  8012bf:	72 17                	jb     8012d8 <__udivdi3+0x10c>
  8012c1:	74 09                	je     8012cc <__udivdi3+0x100>
  8012c3:	89 fe                	mov    %edi,%esi
  8012c5:	31 ff                	xor    %edi,%edi
  8012c7:	e9 41 ff ff ff       	jmp    80120d <__udivdi3+0x41>
  8012cc:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012d0:	89 f1                	mov    %esi,%ecx
  8012d2:	d3 e2                	shl    %cl,%edx
  8012d4:	39 c2                	cmp    %eax,%edx
  8012d6:	73 eb                	jae    8012c3 <__udivdi3+0xf7>
  8012d8:	8d 77 ff             	lea    -0x1(%edi),%esi
  8012db:	31 ff                	xor    %edi,%edi
  8012dd:	e9 2b ff ff ff       	jmp    80120d <__udivdi3+0x41>
  8012e2:	66 90                	xchg   %ax,%ax
  8012e4:	31 f6                	xor    %esi,%esi
  8012e6:	e9 22 ff ff ff       	jmp    80120d <__udivdi3+0x41>
	...

008012ec <__umoddi3>:
  8012ec:	55                   	push   %ebp
  8012ed:	57                   	push   %edi
  8012ee:	56                   	push   %esi
  8012ef:	83 ec 20             	sub    $0x20,%esp
  8012f2:	8b 44 24 30          	mov    0x30(%esp),%eax
  8012f6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8012fa:	89 44 24 14          	mov    %eax,0x14(%esp)
  8012fe:	8b 74 24 34          	mov    0x34(%esp),%esi
  801302:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801306:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80130a:	89 c7                	mov    %eax,%edi
  80130c:	89 f2                	mov    %esi,%edx
  80130e:	85 ed                	test   %ebp,%ebp
  801310:	75 16                	jne    801328 <__umoddi3+0x3c>
  801312:	39 f1                	cmp    %esi,%ecx
  801314:	0f 86 a6 00 00 00    	jbe    8013c0 <__umoddi3+0xd4>
  80131a:	f7 f1                	div    %ecx
  80131c:	89 d0                	mov    %edx,%eax
  80131e:	31 d2                	xor    %edx,%edx
  801320:	83 c4 20             	add    $0x20,%esp
  801323:	5e                   	pop    %esi
  801324:	5f                   	pop    %edi
  801325:	5d                   	pop    %ebp
  801326:	c3                   	ret    
  801327:	90                   	nop
  801328:	39 f5                	cmp    %esi,%ebp
  80132a:	0f 87 ac 00 00 00    	ja     8013dc <__umoddi3+0xf0>
  801330:	0f bd c5             	bsr    %ebp,%eax
  801333:	83 f0 1f             	xor    $0x1f,%eax
  801336:	89 44 24 10          	mov    %eax,0x10(%esp)
  80133a:	0f 84 a8 00 00 00    	je     8013e8 <__umoddi3+0xfc>
  801340:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801344:	d3 e5                	shl    %cl,%ebp
  801346:	bf 20 00 00 00       	mov    $0x20,%edi
  80134b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80134f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801353:	89 f9                	mov    %edi,%ecx
  801355:	d3 e8                	shr    %cl,%eax
  801357:	09 e8                	or     %ebp,%eax
  801359:	89 44 24 18          	mov    %eax,0x18(%esp)
  80135d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801361:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801365:	d3 e0                	shl    %cl,%eax
  801367:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80136b:	89 f2                	mov    %esi,%edx
  80136d:	d3 e2                	shl    %cl,%edx
  80136f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801373:	d3 e0                	shl    %cl,%eax
  801375:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801379:	8b 44 24 14          	mov    0x14(%esp),%eax
  80137d:	89 f9                	mov    %edi,%ecx
  80137f:	d3 e8                	shr    %cl,%eax
  801381:	09 d0                	or     %edx,%eax
  801383:	d3 ee                	shr    %cl,%esi
  801385:	89 f2                	mov    %esi,%edx
  801387:	f7 74 24 18          	divl   0x18(%esp)
  80138b:	89 d6                	mov    %edx,%esi
  80138d:	f7 64 24 0c          	mull   0xc(%esp)
  801391:	89 c5                	mov    %eax,%ebp
  801393:	89 d1                	mov    %edx,%ecx
  801395:	39 d6                	cmp    %edx,%esi
  801397:	72 67                	jb     801400 <__umoddi3+0x114>
  801399:	74 75                	je     801410 <__umoddi3+0x124>
  80139b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80139f:	29 e8                	sub    %ebp,%eax
  8013a1:	19 ce                	sbb    %ecx,%esi
  8013a3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8013a7:	d3 e8                	shr    %cl,%eax
  8013a9:	89 f2                	mov    %esi,%edx
  8013ab:	89 f9                	mov    %edi,%ecx
  8013ad:	d3 e2                	shl    %cl,%edx
  8013af:	09 d0                	or     %edx,%eax
  8013b1:	89 f2                	mov    %esi,%edx
  8013b3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8013b7:	d3 ea                	shr    %cl,%edx
  8013b9:	83 c4 20             	add    $0x20,%esp
  8013bc:	5e                   	pop    %esi
  8013bd:	5f                   	pop    %edi
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    
  8013c0:	85 c9                	test   %ecx,%ecx
  8013c2:	75 0b                	jne    8013cf <__umoddi3+0xe3>
  8013c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8013c9:	31 d2                	xor    %edx,%edx
  8013cb:	f7 f1                	div    %ecx
  8013cd:	89 c1                	mov    %eax,%ecx
  8013cf:	89 f0                	mov    %esi,%eax
  8013d1:	31 d2                	xor    %edx,%edx
  8013d3:	f7 f1                	div    %ecx
  8013d5:	89 f8                	mov    %edi,%eax
  8013d7:	e9 3e ff ff ff       	jmp    80131a <__umoddi3+0x2e>
  8013dc:	89 f2                	mov    %esi,%edx
  8013de:	83 c4 20             	add    $0x20,%esp
  8013e1:	5e                   	pop    %esi
  8013e2:	5f                   	pop    %edi
  8013e3:	5d                   	pop    %ebp
  8013e4:	c3                   	ret    
  8013e5:	8d 76 00             	lea    0x0(%esi),%esi
  8013e8:	39 f5                	cmp    %esi,%ebp
  8013ea:	72 04                	jb     8013f0 <__umoddi3+0x104>
  8013ec:	39 f9                	cmp    %edi,%ecx
  8013ee:	77 06                	ja     8013f6 <__umoddi3+0x10a>
  8013f0:	89 f2                	mov    %esi,%edx
  8013f2:	29 cf                	sub    %ecx,%edi
  8013f4:	19 ea                	sbb    %ebp,%edx
  8013f6:	89 f8                	mov    %edi,%eax
  8013f8:	83 c4 20             	add    $0x20,%esp
  8013fb:	5e                   	pop    %esi
  8013fc:	5f                   	pop    %edi
  8013fd:	5d                   	pop    %ebp
  8013fe:	c3                   	ret    
  8013ff:	90                   	nop
  801400:	89 d1                	mov    %edx,%ecx
  801402:	89 c5                	mov    %eax,%ebp
  801404:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801408:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80140c:	eb 8d                	jmp    80139b <__umoddi3+0xaf>
  80140e:	66 90                	xchg   %ax,%ax
  801410:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801414:	72 ea                	jb     801400 <__umoddi3+0x114>
  801416:	89 f1                	mov    %esi,%ecx
  801418:	eb 81                	jmp    80139b <__umoddi3+0xaf>
