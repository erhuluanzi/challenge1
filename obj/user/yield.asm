
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 6f 00 00 00       	call   8000a0 <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 08 20 80 00       	mov    0x802008,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	89 44 24 04          	mov    %eax,0x4(%esp)
  800047:	c7 04 24 a0 15 80 00 	movl   $0x8015a0,(%esp)
  80004e:	e8 51 01 00 00       	call   8001a4 <cprintf>
	for (i = 0; i < 5; i++) {
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800058:	e8 c9 0a 00 00       	call   800b26 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005d:	a1 08 20 80 00       	mov    0x802008,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 40 48             	mov    0x48(%eax),%eax
  800065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006d:	c7 04 24 c0 15 80 00 	movl   $0x8015c0,(%esp)
  800074:	e8 2b 01 00 00       	call   8001a4 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800079:	43                   	inc    %ebx
  80007a:	83 fb 05             	cmp    $0x5,%ebx
  80007d:	75 d9                	jne    800058 <umain+0x24>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007f:	a1 08 20 80 00       	mov    0x802008,%eax
  800084:	8b 40 48             	mov    0x48(%eax),%eax
  800087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008b:	c7 04 24 ec 15 80 00 	movl   $0x8015ec,(%esp)
  800092:	e8 0d 01 00 00       	call   8001a4 <cprintf>
}
  800097:	83 c4 14             	add    $0x14,%esp
  80009a:	5b                   	pop    %ebx
  80009b:	5d                   	pop    %ebp
  80009c:	c3                   	ret    
  80009d:	00 00                	add    %al,(%eax)
	...

008000a0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	56                   	push   %esi
  8000a4:	53                   	push   %ebx
  8000a5:	83 ec 10             	sub    $0x10,%esp
  8000a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000ae:	e8 54 0a 00 00       	call   800b07 <sys_getenvid>
  8000b3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b8:	8d 04 40             	lea    (%eax,%eax,2),%eax
  8000bb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8000be:	c1 e0 04             	shl    $0x4,%eax
  8000c1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c6:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cb:	85 f6                	test   %esi,%esi
  8000cd:	7e 07                	jle    8000d6 <libmain+0x36>
		binaryname = argv[0];
  8000cf:	8b 03                	mov    (%ebx),%eax
  8000d1:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000da:	89 34 24             	mov    %esi,(%esp)
  8000dd:	e8 52 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000e2:	e8 09 00 00 00       	call   8000f0 <exit>
}
  8000e7:	83 c4 10             	add    $0x10,%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    
	...

008000f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fd:	e8 b3 09 00 00       	call   800ab5 <sys_env_destroy>
}
  800102:	c9                   	leave  
  800103:	c3                   	ret    

00800104 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	53                   	push   %ebx
  800108:	83 ec 14             	sub    $0x14,%esp
  80010b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010e:	8b 03                	mov    (%ebx),%eax
  800110:	8b 55 08             	mov    0x8(%ebp),%edx
  800113:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800117:	40                   	inc    %eax
  800118:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80011a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011f:	75 19                	jne    80013a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800121:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800128:	00 
  800129:	8d 43 08             	lea    0x8(%ebx),%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 44 09 00 00       	call   800a78 <sys_cputs>
		b->idx = 0;
  800134:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80013a:	ff 43 04             	incl   0x4(%ebx)
}
  80013d:	83 c4 14             	add    $0x14,%esp
  800140:	5b                   	pop    %ebx
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80014c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800153:	00 00 00 
	b.cnt = 0;
  800156:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800160:	8b 45 0c             	mov    0xc(%ebp),%eax
  800163:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800167:	8b 45 08             	mov    0x8(%ebp),%eax
  80016a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80016e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800174:	89 44 24 04          	mov    %eax,0x4(%esp)
  800178:	c7 04 24 04 01 80 00 	movl   $0x800104,(%esp)
  80017f:	e8 b4 01 00 00       	call   800338 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800184:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80018a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800194:	89 04 24             	mov    %eax,(%esp)
  800197:	e8 dc 08 00 00       	call   800a78 <sys_cputs>

	return b.cnt;
}
  80019c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001aa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b4:	89 04 24             	mov    %eax,(%esp)
  8001b7:	e8 87 ff ff ff       	call   800143 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    
	...

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 3c             	sub    $0x3c,%esp
  8001c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001cc:	89 d7                	mov    %edx,%edi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001da:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001dd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e0:	85 c0                	test   %eax,%eax
  8001e2:	75 08                	jne    8001ec <printnum+0x2c>
  8001e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ea:	77 57                	ja     800243 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ec:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001f0:	4b                   	dec    %ebx
  8001f1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001fc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800200:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800204:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80020b:	00 
  80020c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80020f:	89 04 24             	mov    %eax,(%esp)
  800212:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800215:	89 44 24 04          	mov    %eax,0x4(%esp)
  800219:	e8 1a 11 00 00       	call   801338 <__udivdi3>
  80021e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800222:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800226:	89 04 24             	mov    %eax,(%esp)
  800229:	89 54 24 04          	mov    %edx,0x4(%esp)
  80022d:	89 fa                	mov    %edi,%edx
  80022f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800232:	e8 89 ff ff ff       	call   8001c0 <printnum>
  800237:	eb 0f                	jmp    800248 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800239:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80023d:	89 34 24             	mov    %esi,(%esp)
  800240:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800243:	4b                   	dec    %ebx
  800244:	85 db                	test   %ebx,%ebx
  800246:	7f f1                	jg     800239 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800248:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80024c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800250:	8b 45 10             	mov    0x10(%ebp),%eax
  800253:	89 44 24 08          	mov    %eax,0x8(%esp)
  800257:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80025e:	00 
  80025f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800262:	89 04 24             	mov    %eax,(%esp)
  800265:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026c:	e8 e7 11 00 00       	call   801458 <__umoddi3>
  800271:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800275:	0f be 80 15 16 80 00 	movsbl 0x801615(%eax),%eax
  80027c:	89 04 24             	mov    %eax,(%esp)
  80027f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800282:	83 c4 3c             	add    $0x3c,%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80028d:	83 fa 01             	cmp    $0x1,%edx
  800290:	7e 0e                	jle    8002a0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800292:	8b 10                	mov    (%eax),%edx
  800294:	8d 4a 08             	lea    0x8(%edx),%ecx
  800297:	89 08                	mov    %ecx,(%eax)
  800299:	8b 02                	mov    (%edx),%eax
  80029b:	8b 52 04             	mov    0x4(%edx),%edx
  80029e:	eb 22                	jmp    8002c2 <getuint+0x38>
	else if (lflag)
  8002a0:	85 d2                	test   %edx,%edx
  8002a2:	74 10                	je     8002b4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a4:	8b 10                	mov    (%eax),%edx
  8002a6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a9:	89 08                	mov    %ecx,(%eax)
  8002ab:	8b 02                	mov    (%edx),%eax
  8002ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b2:	eb 0e                	jmp    8002c2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b4:	8b 10                	mov    (%eax),%edx
  8002b6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 02                	mov    (%edx),%eax
  8002bd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c7:	83 fa 01             	cmp    $0x1,%edx
  8002ca:	7e 0e                	jle    8002da <getint+0x16>
		return va_arg(*ap, long long);
  8002cc:	8b 10                	mov    (%eax),%edx
  8002ce:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d1:	89 08                	mov    %ecx,(%eax)
  8002d3:	8b 02                	mov    (%edx),%eax
  8002d5:	8b 52 04             	mov    0x4(%edx),%edx
  8002d8:	eb 1a                	jmp    8002f4 <getint+0x30>
	else if (lflag)
  8002da:	85 d2                	test   %edx,%edx
  8002dc:	74 0c                	je     8002ea <getint+0x26>
		return va_arg(*ap, long);
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 02                	mov    (%edx),%eax
  8002e7:	99                   	cltd   
  8002e8:	eb 0a                	jmp    8002f4 <getint+0x30>
	else
		return va_arg(*ap, int);
  8002ea:	8b 10                	mov    (%eax),%edx
  8002ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ef:	89 08                	mov    %ecx,(%eax)
  8002f1:	8b 02                	mov    (%edx),%eax
  8002f3:	99                   	cltd   
}
  8002f4:	5d                   	pop    %ebp
  8002f5:	c3                   	ret    

008002f6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fc:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002ff:	8b 10                	mov    (%eax),%edx
  800301:	3b 50 04             	cmp    0x4(%eax),%edx
  800304:	73 08                	jae    80030e <sprintputch+0x18>
		*b->buf++ = ch;
  800306:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800309:	88 0a                	mov    %cl,(%edx)
  80030b:	42                   	inc    %edx
  80030c:	89 10                	mov    %edx,(%eax)
}
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800316:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800319:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80031d:	8b 45 10             	mov    0x10(%ebp),%eax
  800320:	89 44 24 08          	mov    %eax,0x8(%esp)
  800324:	8b 45 0c             	mov    0xc(%ebp),%eax
  800327:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032b:	8b 45 08             	mov    0x8(%ebp),%eax
  80032e:	89 04 24             	mov    %eax,(%esp)
  800331:	e8 02 00 00 00       	call   800338 <vprintfmt>
	va_end(ap);
}
  800336:	c9                   	leave  
  800337:	c3                   	ret    

00800338 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	57                   	push   %edi
  80033c:	56                   	push   %esi
  80033d:	53                   	push   %ebx
  80033e:	83 ec 4c             	sub    $0x4c,%esp
  800341:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800344:	8b 75 10             	mov    0x10(%ebp),%esi
  800347:	eb 12                	jmp    80035b <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800349:	85 c0                	test   %eax,%eax
  80034b:	0f 84 40 03 00 00    	je     800691 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800351:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800355:	89 04 24             	mov    %eax,(%esp)
  800358:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80035b:	0f b6 06             	movzbl (%esi),%eax
  80035e:	46                   	inc    %esi
  80035f:	83 f8 25             	cmp    $0x25,%eax
  800362:	75 e5                	jne    800349 <vprintfmt+0x11>
  800364:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800368:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80036f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800374:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80037b:	ba 00 00 00 00       	mov    $0x0,%edx
  800380:	eb 26                	jmp    8003a8 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800382:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800385:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800389:	eb 1d                	jmp    8003a8 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038e:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800392:	eb 14                	jmp    8003a8 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800394:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800397:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80039e:	eb 08                	jmp    8003a8 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003a0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003a3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	0f b6 06             	movzbl (%esi),%eax
  8003ab:	8d 4e 01             	lea    0x1(%esi),%ecx
  8003ae:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003b1:	8a 0e                	mov    (%esi),%cl
  8003b3:	83 e9 23             	sub    $0x23,%ecx
  8003b6:	80 f9 55             	cmp    $0x55,%cl
  8003b9:	0f 87 b6 02 00 00    	ja     800675 <vprintfmt+0x33d>
  8003bf:	0f b6 c9             	movzbl %cl,%ecx
  8003c2:	ff 24 8d e0 16 80 00 	jmp    *0x8016e0(,%ecx,4)
  8003c9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003cc:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d1:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  8003d4:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  8003d8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003db:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003de:	83 f9 09             	cmp    $0x9,%ecx
  8003e1:	77 2a                	ja     80040d <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e3:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e4:	eb eb                	jmp    8003d1 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ec:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ef:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f4:	eb 17                	jmp    80040d <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003f6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003fa:	78 98                	js     800394 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003ff:	eb a7                	jmp    8003a8 <vprintfmt+0x70>
  800401:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800404:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80040b:	eb 9b                	jmp    8003a8 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80040d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800411:	79 95                	jns    8003a8 <vprintfmt+0x70>
  800413:	eb 8b                	jmp    8003a0 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800415:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800419:	eb 8d                	jmp    8003a8 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80041b:	8b 45 14             	mov    0x14(%ebp),%eax
  80041e:	8d 50 04             	lea    0x4(%eax),%edx
  800421:	89 55 14             	mov    %edx,0x14(%ebp)
  800424:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800428:	8b 00                	mov    (%eax),%eax
  80042a:	89 04 24             	mov    %eax,(%esp)
  80042d:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800433:	e9 23 ff ff ff       	jmp    80035b <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8d 50 04             	lea    0x4(%eax),%edx
  80043e:	89 55 14             	mov    %edx,0x14(%ebp)
  800441:	8b 00                	mov    (%eax),%eax
  800443:	85 c0                	test   %eax,%eax
  800445:	79 02                	jns    800449 <vprintfmt+0x111>
  800447:	f7 d8                	neg    %eax
  800449:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044b:	83 f8 09             	cmp    $0x9,%eax
  80044e:	7f 0b                	jg     80045b <vprintfmt+0x123>
  800450:	8b 04 85 40 18 80 00 	mov    0x801840(,%eax,4),%eax
  800457:	85 c0                	test   %eax,%eax
  800459:	75 23                	jne    80047e <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80045b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045f:	c7 44 24 08 2d 16 80 	movl   $0x80162d,0x8(%esp)
  800466:	00 
  800467:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80046b:	8b 45 08             	mov    0x8(%ebp),%eax
  80046e:	89 04 24             	mov    %eax,(%esp)
  800471:	e8 9a fe ff ff       	call   800310 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800479:	e9 dd fe ff ff       	jmp    80035b <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80047e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800482:	c7 44 24 08 36 16 80 	movl   $0x801636,0x8(%esp)
  800489:	00 
  80048a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80048e:	8b 55 08             	mov    0x8(%ebp),%edx
  800491:	89 14 24             	mov    %edx,(%esp)
  800494:	e8 77 fe ff ff       	call   800310 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80049c:	e9 ba fe ff ff       	jmp    80035b <vprintfmt+0x23>
  8004a1:	89 f9                	mov    %edi,%ecx
  8004a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	8b 30                	mov    (%eax),%esi
  8004b4:	85 f6                	test   %esi,%esi
  8004b6:	75 05                	jne    8004bd <vprintfmt+0x185>
				p = "(null)";
  8004b8:	be 26 16 80 00       	mov    $0x801626,%esi
			if (width > 0 && padc != '-')
  8004bd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004c1:	0f 8e 84 00 00 00    	jle    80054b <vprintfmt+0x213>
  8004c7:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004cb:	74 7e                	je     80054b <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004d1:	89 34 24             	mov    %esi,(%esp)
  8004d4:	e8 5d 02 00 00       	call   800736 <strnlen>
  8004d9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004dc:	29 c2                	sub    %eax,%edx
  8004de:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004e1:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8004e5:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004e8:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004eb:	89 de                	mov    %ebx,%esi
  8004ed:	89 d3                	mov    %edx,%ebx
  8004ef:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	eb 0b                	jmp    8004fe <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004f7:	89 3c 24             	mov    %edi,(%esp)
  8004fa:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fd:	4b                   	dec    %ebx
  8004fe:	85 db                	test   %ebx,%ebx
  800500:	7f f1                	jg     8004f3 <vprintfmt+0x1bb>
  800502:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800505:	89 f3                	mov    %esi,%ebx
  800507:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80050a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80050d:	85 c0                	test   %eax,%eax
  80050f:	79 05                	jns    800516 <vprintfmt+0x1de>
  800511:	b8 00 00 00 00       	mov    $0x0,%eax
  800516:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800519:	29 c2                	sub    %eax,%edx
  80051b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80051e:	eb 2b                	jmp    80054b <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800520:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800524:	74 18                	je     80053e <vprintfmt+0x206>
  800526:	8d 50 e0             	lea    -0x20(%eax),%edx
  800529:	83 fa 5e             	cmp    $0x5e,%edx
  80052c:	76 10                	jbe    80053e <vprintfmt+0x206>
					putch('?', putdat);
  80052e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800532:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800539:	ff 55 08             	call   *0x8(%ebp)
  80053c:	eb 0a                	jmp    800548 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80053e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800542:	89 04 24             	mov    %eax,(%esp)
  800545:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800548:	ff 4d e4             	decl   -0x1c(%ebp)
  80054b:	0f be 06             	movsbl (%esi),%eax
  80054e:	46                   	inc    %esi
  80054f:	85 c0                	test   %eax,%eax
  800551:	74 21                	je     800574 <vprintfmt+0x23c>
  800553:	85 ff                	test   %edi,%edi
  800555:	78 c9                	js     800520 <vprintfmt+0x1e8>
  800557:	4f                   	dec    %edi
  800558:	79 c6                	jns    800520 <vprintfmt+0x1e8>
  80055a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80055d:	89 de                	mov    %ebx,%esi
  80055f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800562:	eb 18                	jmp    80057c <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800564:	89 74 24 04          	mov    %esi,0x4(%esp)
  800568:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80056f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800571:	4b                   	dec    %ebx
  800572:	eb 08                	jmp    80057c <vprintfmt+0x244>
  800574:	8b 7d 08             	mov    0x8(%ebp),%edi
  800577:	89 de                	mov    %ebx,%esi
  800579:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80057c:	85 db                	test   %ebx,%ebx
  80057e:	7f e4                	jg     800564 <vprintfmt+0x22c>
  800580:	89 7d 08             	mov    %edi,0x8(%ebp)
  800583:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800585:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800588:	e9 ce fd ff ff       	jmp    80035b <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80058d:	8d 45 14             	lea    0x14(%ebp),%eax
  800590:	e8 2f fd ff ff       	call   8002c4 <getint>
  800595:	89 c6                	mov    %eax,%esi
  800597:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800599:	85 d2                	test   %edx,%edx
  80059b:	78 07                	js     8005a4 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80059d:	be 0a 00 00 00       	mov    $0xa,%esi
  8005a2:	eb 7e                	jmp    800622 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005af:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005b2:	89 f0                	mov    %esi,%eax
  8005b4:	89 fa                	mov    %edi,%edx
  8005b6:	f7 d8                	neg    %eax
  8005b8:	83 d2 00             	adc    $0x0,%edx
  8005bb:	f7 da                	neg    %edx
			}
			base = 10;
  8005bd:	be 0a 00 00 00       	mov    $0xa,%esi
  8005c2:	eb 5e                	jmp    800622 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c7:	e8 be fc ff ff       	call   80028a <getuint>
			base = 10;
  8005cc:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8005d1:	eb 4f                	jmp    800622 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d6:	e8 af fc ff ff       	call   80028a <getuint>
			base = 8;
  8005db:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8005e0:	eb 40                	jmp    800622 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005ed:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005fb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8d 50 04             	lea    0x4(%eax),%edx
  800604:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800607:	8b 00                	mov    (%eax),%eax
  800609:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80060e:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800613:	eb 0d                	jmp    800622 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800615:	8d 45 14             	lea    0x14(%ebp),%eax
  800618:	e8 6d fc ff ff       	call   80028a <getuint>
			base = 16;
  80061d:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800622:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800626:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80062a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80062d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800631:	89 74 24 08          	mov    %esi,0x8(%esp)
  800635:	89 04 24             	mov    %eax,(%esp)
  800638:	89 54 24 04          	mov    %edx,0x4(%esp)
  80063c:	89 da                	mov    %ebx,%edx
  80063e:	8b 45 08             	mov    0x8(%ebp),%eax
  800641:	e8 7a fb ff ff       	call   8001c0 <printnum>
			break;
  800646:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800649:	e9 0d fd ff ff       	jmp    80035b <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  80064e:	8d 45 14             	lea    0x14(%ebp),%eax
  800651:	e8 6e fc ff ff       	call   8002c4 <getint>
  800656:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  80065e:	e9 f8 fc ff ff       	jmp    80035b <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800663:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800667:	89 04 24             	mov    %eax,(%esp)
  80066a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800670:	e9 e6 fc ff ff       	jmp    80035b <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800675:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800679:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800680:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800683:	eb 01                	jmp    800686 <vprintfmt+0x34e>
  800685:	4e                   	dec    %esi
  800686:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80068a:	75 f9                	jne    800685 <vprintfmt+0x34d>
  80068c:	e9 ca fc ff ff       	jmp    80035b <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800691:	83 c4 4c             	add    $0x4c,%esp
  800694:	5b                   	pop    %ebx
  800695:	5e                   	pop    %esi
  800696:	5f                   	pop    %edi
  800697:	5d                   	pop    %ebp
  800698:	c3                   	ret    

00800699 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800699:	55                   	push   %ebp
  80069a:	89 e5                	mov    %esp,%ebp
  80069c:	83 ec 28             	sub    $0x28,%esp
  80069f:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ac:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b6:	85 c0                	test   %eax,%eax
  8006b8:	74 30                	je     8006ea <vsnprintf+0x51>
  8006ba:	85 d2                	test   %edx,%edx
  8006bc:	7e 33                	jle    8006f1 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8006c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006cc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d3:	c7 04 24 f6 02 80 00 	movl   $0x8002f6,(%esp)
  8006da:	e8 59 fc ff ff       	call   800338 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006df:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e8:	eb 0c                	jmp    8006f6 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ef:	eb 05                	jmp    8006f6 <vsnprintf+0x5d>
  8006f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006f6:	c9                   	leave  
  8006f7:	c3                   	ret    

008006f8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006fe:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800701:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800705:	8b 45 10             	mov    0x10(%ebp),%eax
  800708:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80070f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800713:	8b 45 08             	mov    0x8(%ebp),%eax
  800716:	89 04 24             	mov    %eax,(%esp)
  800719:	e8 7b ff ff ff       	call   800699 <vsnprintf>
	va_end(ap);

	return rc;
}
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800726:	b8 00 00 00 00       	mov    $0x0,%eax
  80072b:	eb 01                	jmp    80072e <strlen+0xe>
		n++;
  80072d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80072e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800732:	75 f9                	jne    80072d <strlen+0xd>
		n++;
	return n;
}
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80073c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073f:	b8 00 00 00 00       	mov    $0x0,%eax
  800744:	eb 01                	jmp    800747 <strnlen+0x11>
		n++;
  800746:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800747:	39 d0                	cmp    %edx,%eax
  800749:	74 06                	je     800751 <strnlen+0x1b>
  80074b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80074f:	75 f5                	jne    800746 <strnlen+0x10>
		n++;
	return n;
}
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	53                   	push   %ebx
  800757:	8b 45 08             	mov    0x8(%ebp),%eax
  80075a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80075d:	ba 00 00 00 00       	mov    $0x0,%edx
  800762:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800765:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800768:	42                   	inc    %edx
  800769:	84 c9                	test   %cl,%cl
  80076b:	75 f5                	jne    800762 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80076d:	5b                   	pop    %ebx
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	53                   	push   %ebx
  800774:	83 ec 08             	sub    $0x8,%esp
  800777:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80077a:	89 1c 24             	mov    %ebx,(%esp)
  80077d:	e8 9e ff ff ff       	call   800720 <strlen>
	strcpy(dst + len, src);
  800782:	8b 55 0c             	mov    0xc(%ebp),%edx
  800785:	89 54 24 04          	mov    %edx,0x4(%esp)
  800789:	01 d8                	add    %ebx,%eax
  80078b:	89 04 24             	mov    %eax,(%esp)
  80078e:	e8 c0 ff ff ff       	call   800753 <strcpy>
	return dst;
}
  800793:	89 d8                	mov    %ebx,%eax
  800795:	83 c4 08             	add    $0x8,%esp
  800798:	5b                   	pop    %ebx
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	56                   	push   %esi
  80079f:	53                   	push   %ebx
  8007a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ae:	eb 0c                	jmp    8007bc <strncpy+0x21>
		*dst++ = *src;
  8007b0:	8a 1a                	mov    (%edx),%bl
  8007b2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b5:	80 3a 01             	cmpb   $0x1,(%edx)
  8007b8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bb:	41                   	inc    %ecx
  8007bc:	39 f1                	cmp    %esi,%ecx
  8007be:	75 f0                	jne    8007b0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c0:	5b                   	pop    %ebx
  8007c1:	5e                   	pop    %esi
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    

008007c4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	56                   	push   %esi
  8007c8:	53                   	push   %ebx
  8007c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cf:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d2:	85 d2                	test   %edx,%edx
  8007d4:	75 0a                	jne    8007e0 <strlcpy+0x1c>
  8007d6:	89 f0                	mov    %esi,%eax
  8007d8:	eb 1a                	jmp    8007f4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007da:	88 18                	mov    %bl,(%eax)
  8007dc:	40                   	inc    %eax
  8007dd:	41                   	inc    %ecx
  8007de:	eb 02                	jmp    8007e2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007e2:	4a                   	dec    %edx
  8007e3:	74 0a                	je     8007ef <strlcpy+0x2b>
  8007e5:	8a 19                	mov    (%ecx),%bl
  8007e7:	84 db                	test   %bl,%bl
  8007e9:	75 ef                	jne    8007da <strlcpy+0x16>
  8007eb:	89 c2                	mov    %eax,%edx
  8007ed:	eb 02                	jmp    8007f1 <strlcpy+0x2d>
  8007ef:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007f1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007f4:	29 f0                	sub    %esi,%eax
}
  8007f6:	5b                   	pop    %ebx
  8007f7:	5e                   	pop    %esi
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800800:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800803:	eb 02                	jmp    800807 <strcmp+0xd>
		p++, q++;
  800805:	41                   	inc    %ecx
  800806:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800807:	8a 01                	mov    (%ecx),%al
  800809:	84 c0                	test   %al,%al
  80080b:	74 04                	je     800811 <strcmp+0x17>
  80080d:	3a 02                	cmp    (%edx),%al
  80080f:	74 f4                	je     800805 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800811:	0f b6 c0             	movzbl %al,%eax
  800814:	0f b6 12             	movzbl (%edx),%edx
  800817:	29 d0                	sub    %edx,%eax
}
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800825:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800828:	eb 03                	jmp    80082d <strncmp+0x12>
		n--, p++, q++;
  80082a:	4a                   	dec    %edx
  80082b:	40                   	inc    %eax
  80082c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80082d:	85 d2                	test   %edx,%edx
  80082f:	74 14                	je     800845 <strncmp+0x2a>
  800831:	8a 18                	mov    (%eax),%bl
  800833:	84 db                	test   %bl,%bl
  800835:	74 04                	je     80083b <strncmp+0x20>
  800837:	3a 19                	cmp    (%ecx),%bl
  800839:	74 ef                	je     80082a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80083b:	0f b6 00             	movzbl (%eax),%eax
  80083e:	0f b6 11             	movzbl (%ecx),%edx
  800841:	29 d0                	sub    %edx,%eax
  800843:	eb 05                	jmp    80084a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800845:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80084a:	5b                   	pop    %ebx
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800856:	eb 05                	jmp    80085d <strchr+0x10>
		if (*s == c)
  800858:	38 ca                	cmp    %cl,%dl
  80085a:	74 0c                	je     800868 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80085c:	40                   	inc    %eax
  80085d:	8a 10                	mov    (%eax),%dl
  80085f:	84 d2                	test   %dl,%dl
  800861:	75 f5                	jne    800858 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800863:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	8b 45 08             	mov    0x8(%ebp),%eax
  800870:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800873:	eb 05                	jmp    80087a <strfind+0x10>
		if (*s == c)
  800875:	38 ca                	cmp    %cl,%dl
  800877:	74 07                	je     800880 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800879:	40                   	inc    %eax
  80087a:	8a 10                	mov    (%eax),%dl
  80087c:	84 d2                	test   %dl,%dl
  80087e:	75 f5                	jne    800875 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	57                   	push   %edi
  800886:	56                   	push   %esi
  800887:	53                   	push   %ebx
  800888:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800891:	85 c9                	test   %ecx,%ecx
  800893:	74 30                	je     8008c5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800895:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80089b:	75 25                	jne    8008c2 <memset+0x40>
  80089d:	f6 c1 03             	test   $0x3,%cl
  8008a0:	75 20                	jne    8008c2 <memset+0x40>
		c &= 0xFF;
  8008a2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a5:	89 d3                	mov    %edx,%ebx
  8008a7:	c1 e3 08             	shl    $0x8,%ebx
  8008aa:	89 d6                	mov    %edx,%esi
  8008ac:	c1 e6 18             	shl    $0x18,%esi
  8008af:	89 d0                	mov    %edx,%eax
  8008b1:	c1 e0 10             	shl    $0x10,%eax
  8008b4:	09 f0                	or     %esi,%eax
  8008b6:	09 d0                	or     %edx,%eax
  8008b8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ba:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008bd:	fc                   	cld    
  8008be:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c0:	eb 03                	jmp    8008c5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c2:	fc                   	cld    
  8008c3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c5:	89 f8                	mov    %edi,%eax
  8008c7:	5b                   	pop    %ebx
  8008c8:	5e                   	pop    %esi
  8008c9:	5f                   	pop    %edi
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	57                   	push   %edi
  8008d0:	56                   	push   %esi
  8008d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008da:	39 c6                	cmp    %eax,%esi
  8008dc:	73 34                	jae    800912 <memmove+0x46>
  8008de:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e1:	39 d0                	cmp    %edx,%eax
  8008e3:	73 2d                	jae    800912 <memmove+0x46>
		s += n;
		d += n;
  8008e5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e8:	f6 c2 03             	test   $0x3,%dl
  8008eb:	75 1b                	jne    800908 <memmove+0x3c>
  8008ed:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f3:	75 13                	jne    800908 <memmove+0x3c>
  8008f5:	f6 c1 03             	test   $0x3,%cl
  8008f8:	75 0e                	jne    800908 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008fa:	83 ef 04             	sub    $0x4,%edi
  8008fd:	8d 72 fc             	lea    -0x4(%edx),%esi
  800900:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800903:	fd                   	std    
  800904:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800906:	eb 07                	jmp    80090f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800908:	4f                   	dec    %edi
  800909:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80090c:	fd                   	std    
  80090d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090f:	fc                   	cld    
  800910:	eb 20                	jmp    800932 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800912:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800918:	75 13                	jne    80092d <memmove+0x61>
  80091a:	a8 03                	test   $0x3,%al
  80091c:	75 0f                	jne    80092d <memmove+0x61>
  80091e:	f6 c1 03             	test   $0x3,%cl
  800921:	75 0a                	jne    80092d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800923:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800926:	89 c7                	mov    %eax,%edi
  800928:	fc                   	cld    
  800929:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092b:	eb 05                	jmp    800932 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80092d:	89 c7                	mov    %eax,%edi
  80092f:	fc                   	cld    
  800930:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800932:	5e                   	pop    %esi
  800933:	5f                   	pop    %edi
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80093c:	8b 45 10             	mov    0x10(%ebp),%eax
  80093f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800943:	8b 45 0c             	mov    0xc(%ebp),%eax
  800946:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	89 04 24             	mov    %eax,(%esp)
  800950:	e8 77 ff ff ff       	call   8008cc <memmove>
}
  800955:	c9                   	leave  
  800956:	c3                   	ret    

00800957 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	57                   	push   %edi
  80095b:	56                   	push   %esi
  80095c:	53                   	push   %ebx
  80095d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800960:	8b 75 0c             	mov    0xc(%ebp),%esi
  800963:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800966:	ba 00 00 00 00       	mov    $0x0,%edx
  80096b:	eb 16                	jmp    800983 <memcmp+0x2c>
		if (*s1 != *s2)
  80096d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800970:	42                   	inc    %edx
  800971:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800975:	38 c8                	cmp    %cl,%al
  800977:	74 0a                	je     800983 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800979:	0f b6 c0             	movzbl %al,%eax
  80097c:	0f b6 c9             	movzbl %cl,%ecx
  80097f:	29 c8                	sub    %ecx,%eax
  800981:	eb 09                	jmp    80098c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800983:	39 da                	cmp    %ebx,%edx
  800985:	75 e6                	jne    80096d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800987:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098c:	5b                   	pop    %ebx
  80098d:	5e                   	pop    %esi
  80098e:	5f                   	pop    %edi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80099a:	89 c2                	mov    %eax,%edx
  80099c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80099f:	eb 05                	jmp    8009a6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a1:	38 08                	cmp    %cl,(%eax)
  8009a3:	74 05                	je     8009aa <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a5:	40                   	inc    %eax
  8009a6:	39 d0                	cmp    %edx,%eax
  8009a8:	72 f7                	jb     8009a1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	57                   	push   %edi
  8009b0:	56                   	push   %esi
  8009b1:	53                   	push   %ebx
  8009b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b8:	eb 01                	jmp    8009bb <strtol+0xf>
		s++;
  8009ba:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009bb:	8a 02                	mov    (%edx),%al
  8009bd:	3c 20                	cmp    $0x20,%al
  8009bf:	74 f9                	je     8009ba <strtol+0xe>
  8009c1:	3c 09                	cmp    $0x9,%al
  8009c3:	74 f5                	je     8009ba <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009c5:	3c 2b                	cmp    $0x2b,%al
  8009c7:	75 08                	jne    8009d1 <strtol+0x25>
		s++;
  8009c9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ca:	bf 00 00 00 00       	mov    $0x0,%edi
  8009cf:	eb 13                	jmp    8009e4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d1:	3c 2d                	cmp    $0x2d,%al
  8009d3:	75 0a                	jne    8009df <strtol+0x33>
		s++, neg = 1;
  8009d5:	8d 52 01             	lea    0x1(%edx),%edx
  8009d8:	bf 01 00 00 00       	mov    $0x1,%edi
  8009dd:	eb 05                	jmp    8009e4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009df:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e4:	85 db                	test   %ebx,%ebx
  8009e6:	74 05                	je     8009ed <strtol+0x41>
  8009e8:	83 fb 10             	cmp    $0x10,%ebx
  8009eb:	75 28                	jne    800a15 <strtol+0x69>
  8009ed:	8a 02                	mov    (%edx),%al
  8009ef:	3c 30                	cmp    $0x30,%al
  8009f1:	75 10                	jne    800a03 <strtol+0x57>
  8009f3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009f7:	75 0a                	jne    800a03 <strtol+0x57>
		s += 2, base = 16;
  8009f9:	83 c2 02             	add    $0x2,%edx
  8009fc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a01:	eb 12                	jmp    800a15 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a03:	85 db                	test   %ebx,%ebx
  800a05:	75 0e                	jne    800a15 <strtol+0x69>
  800a07:	3c 30                	cmp    $0x30,%al
  800a09:	75 05                	jne    800a10 <strtol+0x64>
		s++, base = 8;
  800a0b:	42                   	inc    %edx
  800a0c:	b3 08                	mov    $0x8,%bl
  800a0e:	eb 05                	jmp    800a15 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a10:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a1c:	8a 0a                	mov    (%edx),%cl
  800a1e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a21:	80 fb 09             	cmp    $0x9,%bl
  800a24:	77 08                	ja     800a2e <strtol+0x82>
			dig = *s - '0';
  800a26:	0f be c9             	movsbl %cl,%ecx
  800a29:	83 e9 30             	sub    $0x30,%ecx
  800a2c:	eb 1e                	jmp    800a4c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a2e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a31:	80 fb 19             	cmp    $0x19,%bl
  800a34:	77 08                	ja     800a3e <strtol+0x92>
			dig = *s - 'a' + 10;
  800a36:	0f be c9             	movsbl %cl,%ecx
  800a39:	83 e9 57             	sub    $0x57,%ecx
  800a3c:	eb 0e                	jmp    800a4c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a3e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a41:	80 fb 19             	cmp    $0x19,%bl
  800a44:	77 12                	ja     800a58 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a46:	0f be c9             	movsbl %cl,%ecx
  800a49:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a4c:	39 f1                	cmp    %esi,%ecx
  800a4e:	7d 0c                	jge    800a5c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a50:	42                   	inc    %edx
  800a51:	0f af c6             	imul   %esi,%eax
  800a54:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a56:	eb c4                	jmp    800a1c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a58:	89 c1                	mov    %eax,%ecx
  800a5a:	eb 02                	jmp    800a5e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a5c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a5e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a62:	74 05                	je     800a69 <strtol+0xbd>
		*endptr = (char *) s;
  800a64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a67:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a69:	85 ff                	test   %edi,%edi
  800a6b:	74 04                	je     800a71 <strtol+0xc5>
  800a6d:	89 c8                	mov    %ecx,%eax
  800a6f:	f7 d8                	neg    %eax
}
  800a71:	5b                   	pop    %ebx
  800a72:	5e                   	pop    %esi
  800a73:	5f                   	pop    %edi
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    
	...

00800a78 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	57                   	push   %edi
  800a7c:	56                   	push   %esi
  800a7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a86:	8b 55 08             	mov    0x8(%ebp),%edx
  800a89:	89 c3                	mov    %eax,%ebx
  800a8b:	89 c7                	mov    %eax,%edi
  800a8d:	89 c6                	mov    %eax,%esi
  800a8f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a91:	5b                   	pop    %ebx
  800a92:	5e                   	pop    %esi
  800a93:	5f                   	pop    %edi
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	57                   	push   %edi
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa1:	b8 01 00 00 00       	mov    $0x1,%eax
  800aa6:	89 d1                	mov    %edx,%ecx
  800aa8:	89 d3                	mov    %edx,%ebx
  800aaa:	89 d7                	mov    %edx,%edi
  800aac:	89 d6                	mov    %edx,%esi
  800aae:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5f                   	pop    %edi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	57                   	push   %edi
  800ab9:	56                   	push   %esi
  800aba:	53                   	push   %ebx
  800abb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac8:	8b 55 08             	mov    0x8(%ebp),%edx
  800acb:	89 cb                	mov    %ecx,%ebx
  800acd:	89 cf                	mov    %ecx,%edi
  800acf:	89 ce                	mov    %ecx,%esi
  800ad1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ad3:	85 c0                	test   %eax,%eax
  800ad5:	7e 28                	jle    800aff <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800adb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ae2:	00 
  800ae3:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800aea:	00 
  800aeb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800af2:	00 
  800af3:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800afa:	e8 e1 07 00 00       	call   8012e0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aff:	83 c4 2c             	add    $0x2c,%esp
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b12:	b8 02 00 00 00       	mov    $0x2,%eax
  800b17:	89 d1                	mov    %edx,%ecx
  800b19:	89 d3                	mov    %edx,%ebx
  800b1b:	89 d7                	mov    %edx,%edi
  800b1d:	89 d6                	mov    %edx,%esi
  800b1f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <sys_yield>:

void
sys_yield(void)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	57                   	push   %edi
  800b2a:	56                   	push   %esi
  800b2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b31:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b36:	89 d1                	mov    %edx,%ecx
  800b38:	89 d3                	mov    %edx,%ebx
  800b3a:	89 d7                	mov    %edx,%edi
  800b3c:	89 d6                	mov    %edx,%esi
  800b3e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
  800b4b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4e:	be 00 00 00 00       	mov    $0x0,%esi
  800b53:	b8 04 00 00 00       	mov    $0x4,%eax
  800b58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b61:	89 f7                	mov    %esi,%edi
  800b63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b65:	85 c0                	test   %eax,%eax
  800b67:	7e 28                	jle    800b91 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b69:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b6d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b74:	00 
  800b75:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800b7c:	00 
  800b7d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b84:	00 
  800b85:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800b8c:	e8 4f 07 00 00       	call   8012e0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b91:	83 c4 2c             	add    $0x2c,%esp
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800ba2:	b8 05 00 00 00       	mov    $0x5,%eax
  800ba7:	8b 75 18             	mov    0x18(%ebp),%esi
  800baa:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb8:	85 c0                	test   %eax,%eax
  800bba:	7e 28                	jle    800be4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bc7:	00 
  800bc8:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800bcf:	00 
  800bd0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bd7:	00 
  800bd8:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800bdf:	e8 fc 06 00 00       	call   8012e0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800be4:	83 c4 2c             	add    $0x2c,%esp
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
  800bf2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bfa:	b8 06 00 00 00       	mov    $0x6,%eax
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	89 df                	mov    %ebx,%edi
  800c07:	89 de                	mov    %ebx,%esi
  800c09:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0b:	85 c0                	test   %eax,%eax
  800c0d:	7e 28                	jle    800c37 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c13:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c1a:	00 
  800c1b:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800c22:	00 
  800c23:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c2a:	00 
  800c2b:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800c32:	e8 a9 06 00 00       	call   8012e0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c37:	83 c4 2c             	add    $0x2c,%esp
  800c3a:	5b                   	pop    %ebx
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	89 df                	mov    %ebx,%edi
  800c5a:	89 de                	mov    %ebx,%esi
  800c5c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5e:	85 c0                	test   %eax,%eax
  800c60:	7e 28                	jle    800c8a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c62:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c66:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c6d:	00 
  800c6e:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800c75:	00 
  800c76:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c7d:	00 
  800c7e:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800c85:	e8 56 06 00 00       	call   8012e0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c8a:	83 c4 2c             	add    $0x2c,%esp
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
  800c98:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca0:	b8 09 00 00 00       	mov    $0x9,%eax
  800ca5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cab:	89 df                	mov    %ebx,%edi
  800cad:	89 de                	mov    %ebx,%esi
  800caf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	7e 28                	jle    800cdd <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cc0:	00 
  800cc1:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800cc8:	00 
  800cc9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd0:	00 
  800cd1:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800cd8:	e8 03 06 00 00       	call   8012e0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cdd:	83 c4 2c             	add    $0x2c,%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ceb:	be 00 00 00 00       	mov    $0x0,%esi
  800cf0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d16:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	89 cb                	mov    %ecx,%ebx
  800d20:	89 cf                	mov    %ecx,%edi
  800d22:	89 ce                	mov    %ecx,%esi
  800d24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 28                	jle    800d52 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d35:	00 
  800d36:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800d3d:	00 
  800d3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d45:	00 
  800d46:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800d4d:	e8 8e 05 00 00       	call   8012e0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d52:	83 c4 2c             	add    $0x2c,%esp
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d68:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	89 df                	mov    %ebx,%edi
  800d75:	89 de                	mov    %ebx,%esi
  800d77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 28                	jle    800da5 <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d81:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d88:	00 
  800d89:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800d90:	00 
  800d91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d98:	00 
  800d99:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800da0:	e8 3b 05 00 00       	call   8012e0 <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800da5:	83 c4 2c             	add    $0x2c,%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_env_set_debug_upcall>:

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbb:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	89 df                	mov    %ebx,%edi
  800dc8:	89 de                	mov    %ebx,%esi
  800dca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	7e 28                	jle    800df8 <sys_env_set_debug_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd4:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800ddb:	00 
  800ddc:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800de3:	00 
  800de4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800deb:	00 
  800dec:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800df3:	e8 e8 04 00 00       	call   8012e0 <_panic>
}

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_debug_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800df8:	83 c4 2c             	add    $0x2c,%esp
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_env_set_nmskint_upcall>:

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e16:	8b 55 08             	mov    0x8(%ebp),%edx
  800e19:	89 df                	mov    %ebx,%edi
  800e1b:	89 de                	mov    %ebx,%esi
  800e1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	7e 28                	jle    800e4b <sys_env_set_nmskint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e27:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800e2e:	00 
  800e2f:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800e36:	00 
  800e37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3e:	00 
  800e3f:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800e46:	e8 95 04 00 00       	call   8012e0 <_panic>
}

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_nmskint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800e4b:	83 c4 2c             	add    $0x2c,%esp
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <sys_env_set_bpoint_upcall>:

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	57                   	push   %edi
  800e57:	56                   	push   %esi
  800e58:	53                   	push   %ebx
  800e59:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e61:	b8 10 00 00 00       	mov    $0x10,%eax
  800e66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e69:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6c:	89 df                	mov    %ebx,%edi
  800e6e:	89 de                	mov    %ebx,%esi
  800e70:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e72:	85 c0                	test   %eax,%eax
  800e74:	7e 28                	jle    800e9e <sys_env_set_bpoint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7a:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800e81:	00 
  800e82:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800e89:	00 
  800e8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e91:	00 
  800e92:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800e99:	e8 42 04 00 00       	call   8012e0 <_panic>
}

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bpoint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800e9e:	83 c4 2c             	add    $0x2c,%esp
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <sys_env_set_oflow_upcall>:

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	57                   	push   %edi
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
  800eac:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb4:	b8 11 00 00 00       	mov    $0x11,%eax
  800eb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebf:	89 df                	mov    %ebx,%edi
  800ec1:	89 de                	mov    %ebx,%esi
  800ec3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	7e 28                	jle    800ef1 <sys_env_set_oflow_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ecd:	c7 44 24 0c 11 00 00 	movl   $0x11,0xc(%esp)
  800ed4:	00 
  800ed5:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800edc:	00 
  800edd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee4:	00 
  800ee5:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800eec:	e8 ef 03 00 00       	call   8012e0 <_panic>
}

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_oflow_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800ef1:	83 c4 2c             	add    $0x2c,%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <sys_env_set_bdschk_upcall>:

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	57                   	push   %edi
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
  800eff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f07:	b8 12 00 00 00       	mov    $0x12,%eax
  800f0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f12:	89 df                	mov    %ebx,%edi
  800f14:	89 de                	mov    %ebx,%esi
  800f16:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	7e 28                	jle    800f44 <sys_env_set_bdschk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f20:	c7 44 24 0c 12 00 00 	movl   $0x12,0xc(%esp)
  800f27:	00 
  800f28:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800f2f:	00 
  800f30:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f37:	00 
  800f38:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800f3f:	e8 9c 03 00 00       	call   8012e0 <_panic>
}

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bdschk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800f44:	83 c4 2c             	add    $0x2c,%esp
  800f47:	5b                   	pop    %ebx
  800f48:	5e                   	pop    %esi
  800f49:	5f                   	pop    %edi
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    

00800f4c <sys_env_set_illopcd_upcall>:

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	57                   	push   %edi
  800f50:	56                   	push   %esi
  800f51:	53                   	push   %ebx
  800f52:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5a:	b8 13 00 00 00       	mov    $0x13,%eax
  800f5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f62:	8b 55 08             	mov    0x8(%ebp),%edx
  800f65:	89 df                	mov    %ebx,%edi
  800f67:	89 de                	mov    %ebx,%esi
  800f69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	7e 28                	jle    800f97 <sys_env_set_illopcd_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f73:	c7 44 24 0c 13 00 00 	movl   $0x13,0xc(%esp)
  800f7a:	00 
  800f7b:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800f82:	00 
  800f83:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f8a:	00 
  800f8b:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800f92:	e8 49 03 00 00       	call   8012e0 <_panic>
}

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_illopcd_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800f97:	83 c4 2c             	add    $0x2c,%esp
  800f9a:	5b                   	pop    %ebx
  800f9b:	5e                   	pop    %esi
  800f9c:	5f                   	pop    %edi
  800f9d:	5d                   	pop    %ebp
  800f9e:	c3                   	ret    

00800f9f <sys_env_set_dvcntavl_upcall>:

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	57                   	push   %edi
  800fa3:	56                   	push   %esi
  800fa4:	53                   	push   %ebx
  800fa5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fad:	b8 14 00 00 00       	mov    $0x14,%eax
  800fb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb8:	89 df                	mov    %ebx,%edi
  800fba:	89 de                	mov    %ebx,%esi
  800fbc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	7e 28                	jle    800fea <sys_env_set_dvcntavl_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc6:	c7 44 24 0c 14 00 00 	movl   $0x14,0xc(%esp)
  800fcd:	00 
  800fce:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800fd5:	00 
  800fd6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fdd:	00 
  800fde:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800fe5:	e8 f6 02 00 00       	call   8012e0 <_panic>
}

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dvcntavl_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800fea:	83 c4 2c             	add    $0x2c,%esp
  800fed:	5b                   	pop    %ebx
  800fee:	5e                   	pop    %esi
  800fef:	5f                   	pop    %edi
  800ff0:	5d                   	pop    %ebp
  800ff1:	c3                   	ret    

00800ff2 <sys_env_set_dbfault_upcall>:

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	57                   	push   %edi
  800ff6:	56                   	push   %esi
  800ff7:	53                   	push   %ebx
  800ff8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801000:	b8 15 00 00 00       	mov    $0x15,%eax
  801005:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801008:	8b 55 08             	mov    0x8(%ebp),%edx
  80100b:	89 df                	mov    %ebx,%edi
  80100d:	89 de                	mov    %ebx,%esi
  80100f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801011:	85 c0                	test   %eax,%eax
  801013:	7e 28                	jle    80103d <sys_env_set_dbfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801015:	89 44 24 10          	mov    %eax,0x10(%esp)
  801019:	c7 44 24 0c 15 00 00 	movl   $0x15,0xc(%esp)
  801020:	00 
  801021:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  801028:	00 
  801029:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801030:	00 
  801031:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  801038:	e8 a3 02 00 00       	call   8012e0 <_panic>
}

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dbfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80103d:	83 c4 2c             	add    $0x2c,%esp
  801040:	5b                   	pop    %ebx
  801041:	5e                   	pop    %esi
  801042:	5f                   	pop    %edi
  801043:	5d                   	pop    %ebp
  801044:	c3                   	ret    

00801045 <sys_env_set_ivldtss_upcall>:

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	57                   	push   %edi
  801049:	56                   	push   %esi
  80104a:	53                   	push   %ebx
  80104b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80104e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801053:	b8 16 00 00 00       	mov    $0x16,%eax
  801058:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105b:	8b 55 08             	mov    0x8(%ebp),%edx
  80105e:	89 df                	mov    %ebx,%edi
  801060:	89 de                	mov    %ebx,%esi
  801062:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801064:	85 c0                	test   %eax,%eax
  801066:	7e 28                	jle    801090 <sys_env_set_ivldtss_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801068:	89 44 24 10          	mov    %eax,0x10(%esp)
  80106c:	c7 44 24 0c 16 00 00 	movl   $0x16,0xc(%esp)
  801073:	00 
  801074:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  80107b:	00 
  80107c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801083:	00 
  801084:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  80108b:	e8 50 02 00 00       	call   8012e0 <_panic>
}

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_ivldtss_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801090:	83 c4 2c             	add    $0x2c,%esp
  801093:	5b                   	pop    %ebx
  801094:	5e                   	pop    %esi
  801095:	5f                   	pop    %edi
  801096:	5d                   	pop    %ebp
  801097:	c3                   	ret    

00801098 <sys_env_set_segntprst_upcall>:

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	57                   	push   %edi
  80109c:	56                   	push   %esi
  80109d:	53                   	push   %ebx
  80109e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a6:	b8 17 00 00 00       	mov    $0x17,%eax
  8010ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b1:	89 df                	mov    %ebx,%edi
  8010b3:	89 de                	mov    %ebx,%esi
  8010b5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	7e 28                	jle    8010e3 <sys_env_set_segntprst_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010bb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010bf:	c7 44 24 0c 17 00 00 	movl   $0x17,0xc(%esp)
  8010c6:	00 
  8010c7:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  8010ce:	00 
  8010cf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010d6:	00 
  8010d7:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  8010de:	e8 fd 01 00 00       	call   8012e0 <_panic>
}

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_segntprst_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8010e3:	83 c4 2c             	add    $0x2c,%esp
  8010e6:	5b                   	pop    %ebx
  8010e7:	5e                   	pop    %esi
  8010e8:	5f                   	pop    %edi
  8010e9:	5d                   	pop    %ebp
  8010ea:	c3                   	ret    

008010eb <sys_env_set_stkexception_upcall>:

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	57                   	push   %edi
  8010ef:	56                   	push   %esi
  8010f0:	53                   	push   %ebx
  8010f1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f9:	b8 18 00 00 00       	mov    $0x18,%eax
  8010fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801101:	8b 55 08             	mov    0x8(%ebp),%edx
  801104:	89 df                	mov    %ebx,%edi
  801106:	89 de                	mov    %ebx,%esi
  801108:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80110a:	85 c0                	test   %eax,%eax
  80110c:	7e 28                	jle    801136 <sys_env_set_stkexception_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801112:	c7 44 24 0c 18 00 00 	movl   $0x18,0xc(%esp)
  801119:	00 
  80111a:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  801121:	00 
  801122:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801129:	00 
  80112a:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  801131:	e8 aa 01 00 00       	call   8012e0 <_panic>
}

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_stkexception_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801136:	83 c4 2c             	add    $0x2c,%esp
  801139:	5b                   	pop    %ebx
  80113a:	5e                   	pop    %esi
  80113b:	5f                   	pop    %edi
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    

0080113e <sys_env_set_gpfault_upcall>:

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	57                   	push   %edi
  801142:	56                   	push   %esi
  801143:	53                   	push   %ebx
  801144:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801147:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114c:	b8 19 00 00 00       	mov    $0x19,%eax
  801151:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801154:	8b 55 08             	mov    0x8(%ebp),%edx
  801157:	89 df                	mov    %ebx,%edi
  801159:	89 de                	mov    %ebx,%esi
  80115b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80115d:	85 c0                	test   %eax,%eax
  80115f:	7e 28                	jle    801189 <sys_env_set_gpfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801161:	89 44 24 10          	mov    %eax,0x10(%esp)
  801165:	c7 44 24 0c 19 00 00 	movl   $0x19,0xc(%esp)
  80116c:	00 
  80116d:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  801174:	00 
  801175:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80117c:	00 
  80117d:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  801184:	e8 57 01 00 00       	call   8012e0 <_panic>
}

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_gpfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801189:	83 c4 2c             	add    $0x2c,%esp
  80118c:	5b                   	pop    %ebx
  80118d:	5e                   	pop    %esi
  80118e:	5f                   	pop    %edi
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    

00801191 <sys_env_set_fperror_upcall>:

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	57                   	push   %edi
  801195:	56                   	push   %esi
  801196:	53                   	push   %ebx
  801197:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80119a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119f:	b8 1a 00 00 00       	mov    $0x1a,%eax
  8011a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8011aa:	89 df                	mov    %ebx,%edi
  8011ac:	89 de                	mov    %ebx,%esi
  8011ae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	7e 28                	jle    8011dc <sys_env_set_fperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011b4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b8:	c7 44 24 0c 1a 00 00 	movl   $0x1a,0xc(%esp)
  8011bf:	00 
  8011c0:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  8011c7:	00 
  8011c8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011cf:	00 
  8011d0:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  8011d7:	e8 04 01 00 00       	call   8012e0 <_panic>
}

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_fperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8011dc:	83 c4 2c             	add    $0x2c,%esp
  8011df:	5b                   	pop    %ebx
  8011e0:	5e                   	pop    %esi
  8011e1:	5f                   	pop    %edi
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    

008011e4 <sys_env_set_algchk_upcall>:

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	57                   	push   %edi
  8011e8:	56                   	push   %esi
  8011e9:	53                   	push   %ebx
  8011ea:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011f2:	b8 1b 00 00 00       	mov    $0x1b,%eax
  8011f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fd:	89 df                	mov    %ebx,%edi
  8011ff:	89 de                	mov    %ebx,%esi
  801201:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801203:	85 c0                	test   %eax,%eax
  801205:	7e 28                	jle    80122f <sys_env_set_algchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801207:	89 44 24 10          	mov    %eax,0x10(%esp)
  80120b:	c7 44 24 0c 1b 00 00 	movl   $0x1b,0xc(%esp)
  801212:	00 
  801213:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  80121a:	00 
  80121b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801222:	00 
  801223:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  80122a:	e8 b1 00 00 00       	call   8012e0 <_panic>
}

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_algchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80122f:	83 c4 2c             	add    $0x2c,%esp
  801232:	5b                   	pop    %ebx
  801233:	5e                   	pop    %esi
  801234:	5f                   	pop    %edi
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    

00801237 <sys_env_set_mchchk_upcall>:

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	57                   	push   %edi
  80123b:	56                   	push   %esi
  80123c:	53                   	push   %ebx
  80123d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801240:	bb 00 00 00 00       	mov    $0x0,%ebx
  801245:	b8 1c 00 00 00       	mov    $0x1c,%eax
  80124a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80124d:	8b 55 08             	mov    0x8(%ebp),%edx
  801250:	89 df                	mov    %ebx,%edi
  801252:	89 de                	mov    %ebx,%esi
  801254:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801256:	85 c0                	test   %eax,%eax
  801258:	7e 28                	jle    801282 <sys_env_set_mchchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80125a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80125e:	c7 44 24 0c 1c 00 00 	movl   $0x1c,0xc(%esp)
  801265:	00 
  801266:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  80126d:	00 
  80126e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801275:	00 
  801276:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  80127d:	e8 5e 00 00 00       	call   8012e0 <_panic>
}

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_mchchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801282:	83 c4 2c             	add    $0x2c,%esp
  801285:	5b                   	pop    %ebx
  801286:	5e                   	pop    %esi
  801287:	5f                   	pop    %edi
  801288:	5d                   	pop    %ebp
  801289:	c3                   	ret    

0080128a <sys_env_set_SIMDfperror_upcall>:

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	57                   	push   %edi
  80128e:	56                   	push   %esi
  80128f:	53                   	push   %ebx
  801290:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801293:	bb 00 00 00 00       	mov    $0x0,%ebx
  801298:	b8 1d 00 00 00       	mov    $0x1d,%eax
  80129d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a3:	89 df                	mov    %ebx,%edi
  8012a5:	89 de                	mov    %ebx,%esi
  8012a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	7e 28                	jle    8012d5 <sys_env_set_SIMDfperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012b1:	c7 44 24 0c 1d 00 00 	movl   $0x1d,0xc(%esp)
  8012b8:	00 
  8012b9:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  8012c0:	00 
  8012c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012c8:	00 
  8012c9:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  8012d0:	e8 0b 00 00 00       	call   8012e0 <_panic>
}

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_SIMDfperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8012d5:	83 c4 2c             	add    $0x2c,%esp
  8012d8:	5b                   	pop    %ebx
  8012d9:	5e                   	pop    %esi
  8012da:	5f                   	pop    %edi
  8012db:	5d                   	pop    %ebp
  8012dc:	c3                   	ret    
  8012dd:	00 00                	add    %al,(%eax)
	...

008012e0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	56                   	push   %esi
  8012e4:	53                   	push   %ebx
  8012e5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8012e8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012eb:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8012f1:	e8 11 f8 ff ff       	call   800b07 <sys_getenvid>
  8012f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801300:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801304:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801308:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130c:	c7 04 24 94 18 80 00 	movl   $0x801894,(%esp)
  801313:	e8 8c ee ff ff       	call   8001a4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801318:	89 74 24 04          	mov    %esi,0x4(%esp)
  80131c:	8b 45 10             	mov    0x10(%ebp),%eax
  80131f:	89 04 24             	mov    %eax,(%esp)
  801322:	e8 1c ee ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  801327:	c7 04 24 b8 18 80 00 	movl   $0x8018b8,(%esp)
  80132e:	e8 71 ee ff ff       	call   8001a4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801333:	cc                   	int3   
  801334:	eb fd                	jmp    801333 <_panic+0x53>
	...

00801338 <__udivdi3>:
  801338:	55                   	push   %ebp
  801339:	57                   	push   %edi
  80133a:	56                   	push   %esi
  80133b:	83 ec 10             	sub    $0x10,%esp
  80133e:	8b 74 24 20          	mov    0x20(%esp),%esi
  801342:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801346:	89 74 24 04          	mov    %esi,0x4(%esp)
  80134a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80134e:	89 cd                	mov    %ecx,%ebp
  801350:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801354:	85 c0                	test   %eax,%eax
  801356:	75 2c                	jne    801384 <__udivdi3+0x4c>
  801358:	39 f9                	cmp    %edi,%ecx
  80135a:	77 68                	ja     8013c4 <__udivdi3+0x8c>
  80135c:	85 c9                	test   %ecx,%ecx
  80135e:	75 0b                	jne    80136b <__udivdi3+0x33>
  801360:	b8 01 00 00 00       	mov    $0x1,%eax
  801365:	31 d2                	xor    %edx,%edx
  801367:	f7 f1                	div    %ecx
  801369:	89 c1                	mov    %eax,%ecx
  80136b:	31 d2                	xor    %edx,%edx
  80136d:	89 f8                	mov    %edi,%eax
  80136f:	f7 f1                	div    %ecx
  801371:	89 c7                	mov    %eax,%edi
  801373:	89 f0                	mov    %esi,%eax
  801375:	f7 f1                	div    %ecx
  801377:	89 c6                	mov    %eax,%esi
  801379:	89 f0                	mov    %esi,%eax
  80137b:	89 fa                	mov    %edi,%edx
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	5e                   	pop    %esi
  801381:	5f                   	pop    %edi
  801382:	5d                   	pop    %ebp
  801383:	c3                   	ret    
  801384:	39 f8                	cmp    %edi,%eax
  801386:	77 2c                	ja     8013b4 <__udivdi3+0x7c>
  801388:	0f bd f0             	bsr    %eax,%esi
  80138b:	83 f6 1f             	xor    $0x1f,%esi
  80138e:	75 4c                	jne    8013dc <__udivdi3+0xa4>
  801390:	39 f8                	cmp    %edi,%eax
  801392:	bf 00 00 00 00       	mov    $0x0,%edi
  801397:	72 0a                	jb     8013a3 <__udivdi3+0x6b>
  801399:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80139d:	0f 87 ad 00 00 00    	ja     801450 <__udivdi3+0x118>
  8013a3:	be 01 00 00 00       	mov    $0x1,%esi
  8013a8:	89 f0                	mov    %esi,%eax
  8013aa:	89 fa                	mov    %edi,%edx
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	5e                   	pop    %esi
  8013b0:	5f                   	pop    %edi
  8013b1:	5d                   	pop    %ebp
  8013b2:	c3                   	ret    
  8013b3:	90                   	nop
  8013b4:	31 ff                	xor    %edi,%edi
  8013b6:	31 f6                	xor    %esi,%esi
  8013b8:	89 f0                	mov    %esi,%eax
  8013ba:	89 fa                	mov    %edi,%edx
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	5e                   	pop    %esi
  8013c0:	5f                   	pop    %edi
  8013c1:	5d                   	pop    %ebp
  8013c2:	c3                   	ret    
  8013c3:	90                   	nop
  8013c4:	89 fa                	mov    %edi,%edx
  8013c6:	89 f0                	mov    %esi,%eax
  8013c8:	f7 f1                	div    %ecx
  8013ca:	89 c6                	mov    %eax,%esi
  8013cc:	31 ff                	xor    %edi,%edi
  8013ce:	89 f0                	mov    %esi,%eax
  8013d0:	89 fa                	mov    %edi,%edx
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	5e                   	pop    %esi
  8013d6:	5f                   	pop    %edi
  8013d7:	5d                   	pop    %ebp
  8013d8:	c3                   	ret    
  8013d9:	8d 76 00             	lea    0x0(%esi),%esi
  8013dc:	89 f1                	mov    %esi,%ecx
  8013de:	d3 e0                	shl    %cl,%eax
  8013e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013e4:	b8 20 00 00 00       	mov    $0x20,%eax
  8013e9:	29 f0                	sub    %esi,%eax
  8013eb:	89 ea                	mov    %ebp,%edx
  8013ed:	88 c1                	mov    %al,%cl
  8013ef:	d3 ea                	shr    %cl,%edx
  8013f1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8013f5:	09 ca                	or     %ecx,%edx
  8013f7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013fb:	89 f1                	mov    %esi,%ecx
  8013fd:	d3 e5                	shl    %cl,%ebp
  8013ff:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801403:	89 fd                	mov    %edi,%ebp
  801405:	88 c1                	mov    %al,%cl
  801407:	d3 ed                	shr    %cl,%ebp
  801409:	89 fa                	mov    %edi,%edx
  80140b:	89 f1                	mov    %esi,%ecx
  80140d:	d3 e2                	shl    %cl,%edx
  80140f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801413:	88 c1                	mov    %al,%cl
  801415:	d3 ef                	shr    %cl,%edi
  801417:	09 d7                	or     %edx,%edi
  801419:	89 f8                	mov    %edi,%eax
  80141b:	89 ea                	mov    %ebp,%edx
  80141d:	f7 74 24 08          	divl   0x8(%esp)
  801421:	89 d1                	mov    %edx,%ecx
  801423:	89 c7                	mov    %eax,%edi
  801425:	f7 64 24 0c          	mull   0xc(%esp)
  801429:	39 d1                	cmp    %edx,%ecx
  80142b:	72 17                	jb     801444 <__udivdi3+0x10c>
  80142d:	74 09                	je     801438 <__udivdi3+0x100>
  80142f:	89 fe                	mov    %edi,%esi
  801431:	31 ff                	xor    %edi,%edi
  801433:	e9 41 ff ff ff       	jmp    801379 <__udivdi3+0x41>
  801438:	8b 54 24 04          	mov    0x4(%esp),%edx
  80143c:	89 f1                	mov    %esi,%ecx
  80143e:	d3 e2                	shl    %cl,%edx
  801440:	39 c2                	cmp    %eax,%edx
  801442:	73 eb                	jae    80142f <__udivdi3+0xf7>
  801444:	8d 77 ff             	lea    -0x1(%edi),%esi
  801447:	31 ff                	xor    %edi,%edi
  801449:	e9 2b ff ff ff       	jmp    801379 <__udivdi3+0x41>
  80144e:	66 90                	xchg   %ax,%ax
  801450:	31 f6                	xor    %esi,%esi
  801452:	e9 22 ff ff ff       	jmp    801379 <__udivdi3+0x41>
	...

00801458 <__umoddi3>:
  801458:	55                   	push   %ebp
  801459:	57                   	push   %edi
  80145a:	56                   	push   %esi
  80145b:	83 ec 20             	sub    $0x20,%esp
  80145e:	8b 44 24 30          	mov    0x30(%esp),%eax
  801462:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801466:	89 44 24 14          	mov    %eax,0x14(%esp)
  80146a:	8b 74 24 34          	mov    0x34(%esp),%esi
  80146e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801472:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801476:	89 c7                	mov    %eax,%edi
  801478:	89 f2                	mov    %esi,%edx
  80147a:	85 ed                	test   %ebp,%ebp
  80147c:	75 16                	jne    801494 <__umoddi3+0x3c>
  80147e:	39 f1                	cmp    %esi,%ecx
  801480:	0f 86 a6 00 00 00    	jbe    80152c <__umoddi3+0xd4>
  801486:	f7 f1                	div    %ecx
  801488:	89 d0                	mov    %edx,%eax
  80148a:	31 d2                	xor    %edx,%edx
  80148c:	83 c4 20             	add    $0x20,%esp
  80148f:	5e                   	pop    %esi
  801490:	5f                   	pop    %edi
  801491:	5d                   	pop    %ebp
  801492:	c3                   	ret    
  801493:	90                   	nop
  801494:	39 f5                	cmp    %esi,%ebp
  801496:	0f 87 ac 00 00 00    	ja     801548 <__umoddi3+0xf0>
  80149c:	0f bd c5             	bsr    %ebp,%eax
  80149f:	83 f0 1f             	xor    $0x1f,%eax
  8014a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014a6:	0f 84 a8 00 00 00    	je     801554 <__umoddi3+0xfc>
  8014ac:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014b0:	d3 e5                	shl    %cl,%ebp
  8014b2:	bf 20 00 00 00       	mov    $0x20,%edi
  8014b7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8014bb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014bf:	89 f9                	mov    %edi,%ecx
  8014c1:	d3 e8                	shr    %cl,%eax
  8014c3:	09 e8                	or     %ebp,%eax
  8014c5:	89 44 24 18          	mov    %eax,0x18(%esp)
  8014c9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014cd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014d1:	d3 e0                	shl    %cl,%eax
  8014d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014d7:	89 f2                	mov    %esi,%edx
  8014d9:	d3 e2                	shl    %cl,%edx
  8014db:	8b 44 24 14          	mov    0x14(%esp),%eax
  8014df:	d3 e0                	shl    %cl,%eax
  8014e1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8014e5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8014e9:	89 f9                	mov    %edi,%ecx
  8014eb:	d3 e8                	shr    %cl,%eax
  8014ed:	09 d0                	or     %edx,%eax
  8014ef:	d3 ee                	shr    %cl,%esi
  8014f1:	89 f2                	mov    %esi,%edx
  8014f3:	f7 74 24 18          	divl   0x18(%esp)
  8014f7:	89 d6                	mov    %edx,%esi
  8014f9:	f7 64 24 0c          	mull   0xc(%esp)
  8014fd:	89 c5                	mov    %eax,%ebp
  8014ff:	89 d1                	mov    %edx,%ecx
  801501:	39 d6                	cmp    %edx,%esi
  801503:	72 67                	jb     80156c <__umoddi3+0x114>
  801505:	74 75                	je     80157c <__umoddi3+0x124>
  801507:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80150b:	29 e8                	sub    %ebp,%eax
  80150d:	19 ce                	sbb    %ecx,%esi
  80150f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801513:	d3 e8                	shr    %cl,%eax
  801515:	89 f2                	mov    %esi,%edx
  801517:	89 f9                	mov    %edi,%ecx
  801519:	d3 e2                	shl    %cl,%edx
  80151b:	09 d0                	or     %edx,%eax
  80151d:	89 f2                	mov    %esi,%edx
  80151f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801523:	d3 ea                	shr    %cl,%edx
  801525:	83 c4 20             	add    $0x20,%esp
  801528:	5e                   	pop    %esi
  801529:	5f                   	pop    %edi
  80152a:	5d                   	pop    %ebp
  80152b:	c3                   	ret    
  80152c:	85 c9                	test   %ecx,%ecx
  80152e:	75 0b                	jne    80153b <__umoddi3+0xe3>
  801530:	b8 01 00 00 00       	mov    $0x1,%eax
  801535:	31 d2                	xor    %edx,%edx
  801537:	f7 f1                	div    %ecx
  801539:	89 c1                	mov    %eax,%ecx
  80153b:	89 f0                	mov    %esi,%eax
  80153d:	31 d2                	xor    %edx,%edx
  80153f:	f7 f1                	div    %ecx
  801541:	89 f8                	mov    %edi,%eax
  801543:	e9 3e ff ff ff       	jmp    801486 <__umoddi3+0x2e>
  801548:	89 f2                	mov    %esi,%edx
  80154a:	83 c4 20             	add    $0x20,%esp
  80154d:	5e                   	pop    %esi
  80154e:	5f                   	pop    %edi
  80154f:	5d                   	pop    %ebp
  801550:	c3                   	ret    
  801551:	8d 76 00             	lea    0x0(%esi),%esi
  801554:	39 f5                	cmp    %esi,%ebp
  801556:	72 04                	jb     80155c <__umoddi3+0x104>
  801558:	39 f9                	cmp    %edi,%ecx
  80155a:	77 06                	ja     801562 <__umoddi3+0x10a>
  80155c:	89 f2                	mov    %esi,%edx
  80155e:	29 cf                	sub    %ecx,%edi
  801560:	19 ea                	sbb    %ebp,%edx
  801562:	89 f8                	mov    %edi,%eax
  801564:	83 c4 20             	add    $0x20,%esp
  801567:	5e                   	pop    %esi
  801568:	5f                   	pop    %edi
  801569:	5d                   	pop    %ebp
  80156a:	c3                   	ret    
  80156b:	90                   	nop
  80156c:	89 d1                	mov    %edx,%ecx
  80156e:	89 c5                	mov    %eax,%ebp
  801570:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801574:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801578:	eb 8d                	jmp    801507 <__umoddi3+0xaf>
  80157a:	66 90                	xchg   %ax,%ax
  80157c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801580:	72 ea                	jb     80156c <__umoddi3+0x114>
  801582:	89 f1                	mov    %esi,%ecx
  801584:	eb 81                	jmp    801507 <__umoddi3+0xaf>
