
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 7f 00 00 00       	call   8000b0 <libmain>
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
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003b:	c7 04 24 40 14 80 00 	movl   $0x801440,(%esp)
  800042:	e8 6d 01 00 00       	call   8001b4 <cprintf>
	if ((env = fork()) == 0) {
  800047:	e8 b7 0e 00 00       	call   800f03 <fork>
  80004c:	89 c3                	mov    %eax,%ebx
  80004e:	85 c0                	test   %eax,%eax
  800050:	75 0e                	jne    800060 <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  800052:	c7 04 24 b8 14 80 00 	movl   $0x8014b8,(%esp)
  800059:	e8 56 01 00 00       	call   8001b4 <cprintf>
  80005e:	eb fe                	jmp    80005e <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800060:	c7 04 24 68 14 80 00 	movl   $0x801468,(%esp)
  800067:	e8 48 01 00 00       	call   8001b4 <cprintf>
	sys_yield();
  80006c:	e8 c5 0a 00 00       	call   800b36 <sys_yield>
	sys_yield();
  800071:	e8 c0 0a 00 00       	call   800b36 <sys_yield>
	sys_yield();
  800076:	e8 bb 0a 00 00       	call   800b36 <sys_yield>
	sys_yield();
  80007b:	e8 b6 0a 00 00       	call   800b36 <sys_yield>
	sys_yield();
  800080:	e8 b1 0a 00 00       	call   800b36 <sys_yield>
	sys_yield();
  800085:	e8 ac 0a 00 00       	call   800b36 <sys_yield>
	sys_yield();
  80008a:	e8 a7 0a 00 00       	call   800b36 <sys_yield>
	sys_yield();
  80008f:	e8 a2 0a 00 00       	call   800b36 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800094:	c7 04 24 90 14 80 00 	movl   $0x801490,(%esp)
  80009b:	e8 14 01 00 00       	call   8001b4 <cprintf>
	sys_env_destroy(env);
  8000a0:	89 1c 24             	mov    %ebx,(%esp)
  8000a3:	e8 1d 0a 00 00       	call   800ac5 <sys_env_destroy>
}
  8000a8:	83 c4 14             	add    $0x14,%esp
  8000ab:	5b                   	pop    %ebx
  8000ac:	5d                   	pop    %ebp
  8000ad:	c3                   	ret    
	...

008000b0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
  8000b5:	83 ec 10             	sub    $0x10,%esp
  8000b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8000bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000be:	e8 54 0a 00 00       	call   800b17 <sys_getenvid>
  8000c3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c8:	8d 14 80             	lea    (%eax,%eax,4),%edx
  8000cb:	8d 04 50             	lea    (%eax,%edx,2),%eax
  8000ce:	c1 e0 04             	shl    $0x4,%eax
  8000d1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d6:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000db:	85 f6                	test   %esi,%esi
  8000dd:	7e 07                	jle    8000e6 <libmain+0x36>
		binaryname = argv[0];
  8000df:	8b 03                	mov    (%ebx),%eax
  8000e1:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ea:	89 34 24             	mov    %esi,(%esp)
  8000ed:	e8 42 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000f2:	e8 09 00 00 00       	call   800100 <exit>
}
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    
	...

00800100 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800106:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80010d:	e8 b3 09 00 00       	call   800ac5 <sys_env_destroy>
}
  800112:	c9                   	leave  
  800113:	c3                   	ret    

00800114 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	53                   	push   %ebx
  800118:	83 ec 14             	sub    $0x14,%esp
  80011b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011e:	8b 03                	mov    (%ebx),%eax
  800120:	8b 55 08             	mov    0x8(%ebp),%edx
  800123:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800127:	40                   	inc    %eax
  800128:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80012a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012f:	75 19                	jne    80014a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800131:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800138:	00 
  800139:	8d 43 08             	lea    0x8(%ebx),%eax
  80013c:	89 04 24             	mov    %eax,(%esp)
  80013f:	e8 44 09 00 00       	call   800a88 <sys_cputs>
		b->idx = 0;
  800144:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80014a:	ff 43 04             	incl   0x4(%ebx)
}
  80014d:	83 c4 14             	add    $0x14,%esp
  800150:	5b                   	pop    %ebx
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80015c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800163:	00 00 00 
	b.cnt = 0;
  800166:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800170:	8b 45 0c             	mov    0xc(%ebp),%eax
  800173:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800177:	8b 45 08             	mov    0x8(%ebp),%eax
  80017a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80017e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800184:	89 44 24 04          	mov    %eax,0x4(%esp)
  800188:	c7 04 24 14 01 80 00 	movl   $0x800114,(%esp)
  80018f:	e8 b4 01 00 00       	call   800348 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800194:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80019a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a4:	89 04 24             	mov    %eax,(%esp)
  8001a7:	e8 dc 08 00 00       	call   800a88 <sys_cputs>

	return b.cnt;
}
  8001ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c4:	89 04 24             	mov    %eax,(%esp)
  8001c7:	e8 87 ff ff ff       	call   800153 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001cc:	c9                   	leave  
  8001cd:	c3                   	ret    
	...

008001d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 3c             	sub    $0x3c,%esp
  8001d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001dc:	89 d7                	mov    %edx,%edi
  8001de:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001ed:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f0:	85 c0                	test   %eax,%eax
  8001f2:	75 08                	jne    8001fc <printnum+0x2c>
  8001f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001f7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001fa:	77 57                	ja     800253 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fc:	89 74 24 10          	mov    %esi,0x10(%esp)
  800200:	4b                   	dec    %ebx
  800201:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800205:	8b 45 10             	mov    0x10(%ebp),%eax
  800208:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800210:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800214:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80021b:	00 
  80021c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80021f:	89 04 24             	mov    %eax,(%esp)
  800222:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800225:	89 44 24 04          	mov    %eax,0x4(%esp)
  800229:	e8 aa 0f 00 00       	call   8011d8 <__udivdi3>
  80022e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800232:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800236:	89 04 24             	mov    %eax,(%esp)
  800239:	89 54 24 04          	mov    %edx,0x4(%esp)
  80023d:	89 fa                	mov    %edi,%edx
  80023f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800242:	e8 89 ff ff ff       	call   8001d0 <printnum>
  800247:	eb 0f                	jmp    800258 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800249:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80024d:	89 34 24             	mov    %esi,(%esp)
  800250:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800253:	4b                   	dec    %ebx
  800254:	85 db                	test   %ebx,%ebx
  800256:	7f f1                	jg     800249 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800258:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80025c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800260:	8b 45 10             	mov    0x10(%ebp),%eax
  800263:	89 44 24 08          	mov    %eax,0x8(%esp)
  800267:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026e:	00 
  80026f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800272:	89 04 24             	mov    %eax,(%esp)
  800275:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800278:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027c:	e8 77 10 00 00       	call   8012f8 <__umoddi3>
  800281:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800285:	0f be 80 e0 14 80 00 	movsbl 0x8014e0(%eax),%eax
  80028c:	89 04 24             	mov    %eax,(%esp)
  80028f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800292:	83 c4 3c             	add    $0x3c,%esp
  800295:	5b                   	pop    %ebx
  800296:	5e                   	pop    %esi
  800297:	5f                   	pop    %edi
  800298:	5d                   	pop    %ebp
  800299:	c3                   	ret    

0080029a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80029d:	83 fa 01             	cmp    $0x1,%edx
  8002a0:	7e 0e                	jle    8002b0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a2:	8b 10                	mov    (%eax),%edx
  8002a4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a7:	89 08                	mov    %ecx,(%eax)
  8002a9:	8b 02                	mov    (%edx),%eax
  8002ab:	8b 52 04             	mov    0x4(%edx),%edx
  8002ae:	eb 22                	jmp    8002d2 <getuint+0x38>
	else if (lflag)
  8002b0:	85 d2                	test   %edx,%edx
  8002b2:	74 10                	je     8002c4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b4:	8b 10                	mov    (%eax),%edx
  8002b6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 02                	mov    (%edx),%eax
  8002bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c2:	eb 0e                	jmp    8002d2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c4:	8b 10                	mov    (%eax),%edx
  8002c6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c9:	89 08                	mov    %ecx,(%eax)
  8002cb:	8b 02                	mov    (%edx),%eax
  8002cd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d2:	5d                   	pop    %ebp
  8002d3:	c3                   	ret    

008002d4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d7:	83 fa 01             	cmp    $0x1,%edx
  8002da:	7e 0e                	jle    8002ea <getint+0x16>
		return va_arg(*ap, long long);
  8002dc:	8b 10                	mov    (%eax),%edx
  8002de:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e1:	89 08                	mov    %ecx,(%eax)
  8002e3:	8b 02                	mov    (%edx),%eax
  8002e5:	8b 52 04             	mov    0x4(%edx),%edx
  8002e8:	eb 1a                	jmp    800304 <getint+0x30>
	else if (lflag)
  8002ea:	85 d2                	test   %edx,%edx
  8002ec:	74 0c                	je     8002fa <getint+0x26>
		return va_arg(*ap, long);
  8002ee:	8b 10                	mov    (%eax),%edx
  8002f0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f3:	89 08                	mov    %ecx,(%eax)
  8002f5:	8b 02                	mov    (%edx),%eax
  8002f7:	99                   	cltd   
  8002f8:	eb 0a                	jmp    800304 <getint+0x30>
	else
		return va_arg(*ap, int);
  8002fa:	8b 10                	mov    (%eax),%edx
  8002fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ff:	89 08                	mov    %ecx,(%eax)
  800301:	8b 02                	mov    (%edx),%eax
  800303:	99                   	cltd   
}
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80030c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80030f:	8b 10                	mov    (%eax),%edx
  800311:	3b 50 04             	cmp    0x4(%eax),%edx
  800314:	73 08                	jae    80031e <sprintputch+0x18>
		*b->buf++ = ch;
  800316:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800319:	88 0a                	mov    %cl,(%edx)
  80031b:	42                   	inc    %edx
  80031c:	89 10                	mov    %edx,(%eax)
}
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800326:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800329:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80032d:	8b 45 10             	mov    0x10(%ebp),%eax
  800330:	89 44 24 08          	mov    %eax,0x8(%esp)
  800334:	8b 45 0c             	mov    0xc(%ebp),%eax
  800337:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033b:	8b 45 08             	mov    0x8(%ebp),%eax
  80033e:	89 04 24             	mov    %eax,(%esp)
  800341:	e8 02 00 00 00       	call   800348 <vprintfmt>
	va_end(ap);
}
  800346:	c9                   	leave  
  800347:	c3                   	ret    

00800348 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
  80034b:	57                   	push   %edi
  80034c:	56                   	push   %esi
  80034d:	53                   	push   %ebx
  80034e:	83 ec 4c             	sub    $0x4c,%esp
  800351:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800354:	8b 75 10             	mov    0x10(%ebp),%esi
  800357:	eb 12                	jmp    80036b <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800359:	85 c0                	test   %eax,%eax
  80035b:	0f 84 40 03 00 00    	je     8006a1 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800361:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800365:	89 04 24             	mov    %eax,(%esp)
  800368:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80036b:	0f b6 06             	movzbl (%esi),%eax
  80036e:	46                   	inc    %esi
  80036f:	83 f8 25             	cmp    $0x25,%eax
  800372:	75 e5                	jne    800359 <vprintfmt+0x11>
  800374:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800378:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80037f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800384:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80038b:	ba 00 00 00 00       	mov    $0x0,%edx
  800390:	eb 26                	jmp    8003b8 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800395:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800399:	eb 1d                	jmp    8003b8 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80039e:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003a2:	eb 14                	jmp    8003b8 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003a7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003ae:	eb 08                	jmp    8003b8 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003b0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003b3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b8:	0f b6 06             	movzbl (%esi),%eax
  8003bb:	8d 4e 01             	lea    0x1(%esi),%ecx
  8003be:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003c1:	8a 0e                	mov    (%esi),%cl
  8003c3:	83 e9 23             	sub    $0x23,%ecx
  8003c6:	80 f9 55             	cmp    $0x55,%cl
  8003c9:	0f 87 b6 02 00 00    	ja     800685 <vprintfmt+0x33d>
  8003cf:	0f b6 c9             	movzbl %cl,%ecx
  8003d2:	ff 24 8d a0 15 80 00 	jmp    *0x8015a0(,%ecx,4)
  8003d9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003dc:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e1:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  8003e4:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  8003e8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003eb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003ee:	83 f9 09             	cmp    $0x9,%ecx
  8003f1:	77 2a                	ja     80041d <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f3:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f4:	eb eb                	jmp    8003e1 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f9:	8d 48 04             	lea    0x4(%eax),%ecx
  8003fc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ff:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800404:	eb 17                	jmp    80041d <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800406:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80040a:	78 98                	js     8003a4 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80040f:	eb a7                	jmp    8003b8 <vprintfmt+0x70>
  800411:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800414:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80041b:	eb 9b                	jmp    8003b8 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80041d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800421:	79 95                	jns    8003b8 <vprintfmt+0x70>
  800423:	eb 8b                	jmp    8003b0 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800425:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800429:	eb 8d                	jmp    8003b8 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042b:	8b 45 14             	mov    0x14(%ebp),%eax
  80042e:	8d 50 04             	lea    0x4(%eax),%edx
  800431:	89 55 14             	mov    %edx,0x14(%ebp)
  800434:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800438:	8b 00                	mov    (%eax),%eax
  80043a:	89 04 24             	mov    %eax,(%esp)
  80043d:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800443:	e9 23 ff ff ff       	jmp    80036b <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	8d 50 04             	lea    0x4(%eax),%edx
  80044e:	89 55 14             	mov    %edx,0x14(%ebp)
  800451:	8b 00                	mov    (%eax),%eax
  800453:	85 c0                	test   %eax,%eax
  800455:	79 02                	jns    800459 <vprintfmt+0x111>
  800457:	f7 d8                	neg    %eax
  800459:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045b:	83 f8 09             	cmp    $0x9,%eax
  80045e:	7f 0b                	jg     80046b <vprintfmt+0x123>
  800460:	8b 04 85 00 17 80 00 	mov    0x801700(,%eax,4),%eax
  800467:	85 c0                	test   %eax,%eax
  800469:	75 23                	jne    80048e <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80046b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80046f:	c7 44 24 08 f8 14 80 	movl   $0x8014f8,0x8(%esp)
  800476:	00 
  800477:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80047b:	8b 45 08             	mov    0x8(%ebp),%eax
  80047e:	89 04 24             	mov    %eax,(%esp)
  800481:	e8 9a fe ff ff       	call   800320 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800489:	e9 dd fe ff ff       	jmp    80036b <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80048e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800492:	c7 44 24 08 01 15 80 	movl   $0x801501,0x8(%esp)
  800499:	00 
  80049a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049e:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a1:	89 14 24             	mov    %edx,(%esp)
  8004a4:	e8 77 fe ff ff       	call   800320 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ac:	e9 ba fe ff ff       	jmp    80036b <vprintfmt+0x23>
  8004b1:	89 f9                	mov    %edi,%ecx
  8004b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bc:	8d 50 04             	lea    0x4(%eax),%edx
  8004bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c2:	8b 30                	mov    (%eax),%esi
  8004c4:	85 f6                	test   %esi,%esi
  8004c6:	75 05                	jne    8004cd <vprintfmt+0x185>
				p = "(null)";
  8004c8:	be f1 14 80 00       	mov    $0x8014f1,%esi
			if (width > 0 && padc != '-')
  8004cd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004d1:	0f 8e 84 00 00 00    	jle    80055b <vprintfmt+0x213>
  8004d7:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004db:	74 7e                	je     80055b <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004e1:	89 34 24             	mov    %esi,(%esp)
  8004e4:	e8 5d 02 00 00       	call   800746 <strnlen>
  8004e9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004ec:	29 c2                	sub    %eax,%edx
  8004ee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004f1:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8004f5:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004f8:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004fb:	89 de                	mov    %ebx,%esi
  8004fd:	89 d3                	mov    %edx,%ebx
  8004ff:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800501:	eb 0b                	jmp    80050e <vprintfmt+0x1c6>
					putch(padc, putdat);
  800503:	89 74 24 04          	mov    %esi,0x4(%esp)
  800507:	89 3c 24             	mov    %edi,(%esp)
  80050a:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050d:	4b                   	dec    %ebx
  80050e:	85 db                	test   %ebx,%ebx
  800510:	7f f1                	jg     800503 <vprintfmt+0x1bb>
  800512:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800515:	89 f3                	mov    %esi,%ebx
  800517:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80051a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051d:	85 c0                	test   %eax,%eax
  80051f:	79 05                	jns    800526 <vprintfmt+0x1de>
  800521:	b8 00 00 00 00       	mov    $0x0,%eax
  800526:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800529:	29 c2                	sub    %eax,%edx
  80052b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80052e:	eb 2b                	jmp    80055b <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800530:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800534:	74 18                	je     80054e <vprintfmt+0x206>
  800536:	8d 50 e0             	lea    -0x20(%eax),%edx
  800539:	83 fa 5e             	cmp    $0x5e,%edx
  80053c:	76 10                	jbe    80054e <vprintfmt+0x206>
					putch('?', putdat);
  80053e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800542:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800549:	ff 55 08             	call   *0x8(%ebp)
  80054c:	eb 0a                	jmp    800558 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80054e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800552:	89 04 24             	mov    %eax,(%esp)
  800555:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800558:	ff 4d e4             	decl   -0x1c(%ebp)
  80055b:	0f be 06             	movsbl (%esi),%eax
  80055e:	46                   	inc    %esi
  80055f:	85 c0                	test   %eax,%eax
  800561:	74 21                	je     800584 <vprintfmt+0x23c>
  800563:	85 ff                	test   %edi,%edi
  800565:	78 c9                	js     800530 <vprintfmt+0x1e8>
  800567:	4f                   	dec    %edi
  800568:	79 c6                	jns    800530 <vprintfmt+0x1e8>
  80056a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80056d:	89 de                	mov    %ebx,%esi
  80056f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800572:	eb 18                	jmp    80058c <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800574:	89 74 24 04          	mov    %esi,0x4(%esp)
  800578:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80057f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800581:	4b                   	dec    %ebx
  800582:	eb 08                	jmp    80058c <vprintfmt+0x244>
  800584:	8b 7d 08             	mov    0x8(%ebp),%edi
  800587:	89 de                	mov    %ebx,%esi
  800589:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80058c:	85 db                	test   %ebx,%ebx
  80058e:	7f e4                	jg     800574 <vprintfmt+0x22c>
  800590:	89 7d 08             	mov    %edi,0x8(%ebp)
  800593:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800595:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800598:	e9 ce fd ff ff       	jmp    80036b <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059d:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a0:	e8 2f fd ff ff       	call   8002d4 <getint>
  8005a5:	89 c6                	mov    %eax,%esi
  8005a7:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8005a9:	85 d2                	test   %edx,%edx
  8005ab:	78 07                	js     8005b4 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ad:	be 0a 00 00 00       	mov    $0xa,%esi
  8005b2:	eb 7e                	jmp    800632 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005bf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005c2:	89 f0                	mov    %esi,%eax
  8005c4:	89 fa                	mov    %edi,%edx
  8005c6:	f7 d8                	neg    %eax
  8005c8:	83 d2 00             	adc    $0x0,%edx
  8005cb:	f7 da                	neg    %edx
			}
			base = 10;
  8005cd:	be 0a 00 00 00       	mov    $0xa,%esi
  8005d2:	eb 5e                	jmp    800632 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d7:	e8 be fc ff ff       	call   80029a <getuint>
			base = 10;
  8005dc:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8005e1:	eb 4f                	jmp    800632 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e6:	e8 af fc ff ff       	call   80029a <getuint>
			base = 8;
  8005eb:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8005f0:	eb 40                	jmp    800632 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  8005f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005fd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800600:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800604:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80060b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 04             	lea    0x4(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800617:	8b 00                	mov    (%eax),%eax
  800619:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80061e:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800623:	eb 0d                	jmp    800632 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800625:	8d 45 14             	lea    0x14(%ebp),%eax
  800628:	e8 6d fc ff ff       	call   80029a <getuint>
			base = 16;
  80062d:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800632:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800636:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80063a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80063d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800641:	89 74 24 08          	mov    %esi,0x8(%esp)
  800645:	89 04 24             	mov    %eax,(%esp)
  800648:	89 54 24 04          	mov    %edx,0x4(%esp)
  80064c:	89 da                	mov    %ebx,%edx
  80064e:	8b 45 08             	mov    0x8(%ebp),%eax
  800651:	e8 7a fb ff ff       	call   8001d0 <printnum>
			break;
  800656:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800659:	e9 0d fd ff ff       	jmp    80036b <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  80065e:	8d 45 14             	lea    0x14(%ebp),%eax
  800661:	e8 6e fc ff ff       	call   8002d4 <getint>
  800666:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  80066e:	e9 f8 fc ff ff       	jmp    80036b <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800673:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800677:	89 04 24             	mov    %eax,(%esp)
  80067a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800680:	e9 e6 fc ff ff       	jmp    80036b <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800685:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800689:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800690:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800693:	eb 01                	jmp    800696 <vprintfmt+0x34e>
  800695:	4e                   	dec    %esi
  800696:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80069a:	75 f9                	jne    800695 <vprintfmt+0x34d>
  80069c:	e9 ca fc ff ff       	jmp    80036b <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006a1:	83 c4 4c             	add    $0x4c,%esp
  8006a4:	5b                   	pop    %ebx
  8006a5:	5e                   	pop    %esi
  8006a6:	5f                   	pop    %edi
  8006a7:	5d                   	pop    %ebp
  8006a8:	c3                   	ret    

008006a9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a9:	55                   	push   %ebp
  8006aa:	89 e5                	mov    %esp,%ebp
  8006ac:	83 ec 28             	sub    $0x28,%esp
  8006af:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006bc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c6:	85 c0                	test   %eax,%eax
  8006c8:	74 30                	je     8006fa <vsnprintf+0x51>
  8006ca:	85 d2                	test   %edx,%edx
  8006cc:	7e 33                	jle    800701 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006dc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e3:	c7 04 24 06 03 80 00 	movl   $0x800306,(%esp)
  8006ea:	e8 59 fc ff ff       	call   800348 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f8:	eb 0c                	jmp    800706 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ff:	eb 05                	jmp    800706 <vsnprintf+0x5d>
  800701:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800706:	c9                   	leave  
  800707:	c3                   	ret    

00800708 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800711:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800715:	8b 45 10             	mov    0x10(%ebp),%eax
  800718:	89 44 24 08          	mov    %eax,0x8(%esp)
  80071c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80071f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800723:	8b 45 08             	mov    0x8(%ebp),%eax
  800726:	89 04 24             	mov    %eax,(%esp)
  800729:	e8 7b ff ff ff       	call   8006a9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80072e:	c9                   	leave  
  80072f:	c3                   	ret    

00800730 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800736:	b8 00 00 00 00       	mov    $0x0,%eax
  80073b:	eb 01                	jmp    80073e <strlen+0xe>
		n++;
  80073d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80073e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800742:	75 f9                	jne    80073d <strlen+0xd>
		n++;
	return n;
}
  800744:	5d                   	pop    %ebp
  800745:	c3                   	ret    

00800746 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80074c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074f:	b8 00 00 00 00       	mov    $0x0,%eax
  800754:	eb 01                	jmp    800757 <strnlen+0x11>
		n++;
  800756:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800757:	39 d0                	cmp    %edx,%eax
  800759:	74 06                	je     800761 <strnlen+0x1b>
  80075b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80075f:	75 f5                	jne    800756 <strnlen+0x10>
		n++;
	return n;
}
  800761:	5d                   	pop    %ebp
  800762:	c3                   	ret    

00800763 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	53                   	push   %ebx
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80076d:	ba 00 00 00 00       	mov    $0x0,%edx
  800772:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800775:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800778:	42                   	inc    %edx
  800779:	84 c9                	test   %cl,%cl
  80077b:	75 f5                	jne    800772 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80077d:	5b                   	pop    %ebx
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	53                   	push   %ebx
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80078a:	89 1c 24             	mov    %ebx,(%esp)
  80078d:	e8 9e ff ff ff       	call   800730 <strlen>
	strcpy(dst + len, src);
  800792:	8b 55 0c             	mov    0xc(%ebp),%edx
  800795:	89 54 24 04          	mov    %edx,0x4(%esp)
  800799:	01 d8                	add    %ebx,%eax
  80079b:	89 04 24             	mov    %eax,(%esp)
  80079e:	e8 c0 ff ff ff       	call   800763 <strcpy>
	return dst;
}
  8007a3:	89 d8                	mov    %ebx,%eax
  8007a5:	83 c4 08             	add    $0x8,%esp
  8007a8:	5b                   	pop    %ebx
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	56                   	push   %esi
  8007af:	53                   	push   %ebx
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007be:	eb 0c                	jmp    8007cc <strncpy+0x21>
		*dst++ = *src;
  8007c0:	8a 1a                	mov    (%edx),%bl
  8007c2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c5:	80 3a 01             	cmpb   $0x1,(%edx)
  8007c8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cb:	41                   	inc    %ecx
  8007cc:	39 f1                	cmp    %esi,%ecx
  8007ce:	75 f0                	jne    8007c0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d0:	5b                   	pop    %ebx
  8007d1:	5e                   	pop    %esi
  8007d2:	5d                   	pop    %ebp
  8007d3:	c3                   	ret    

008007d4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	56                   	push   %esi
  8007d8:	53                   	push   %ebx
  8007d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007df:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e2:	85 d2                	test   %edx,%edx
  8007e4:	75 0a                	jne    8007f0 <strlcpy+0x1c>
  8007e6:	89 f0                	mov    %esi,%eax
  8007e8:	eb 1a                	jmp    800804 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ea:	88 18                	mov    %bl,(%eax)
  8007ec:	40                   	inc    %eax
  8007ed:	41                   	inc    %ecx
  8007ee:	eb 02                	jmp    8007f2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007f2:	4a                   	dec    %edx
  8007f3:	74 0a                	je     8007ff <strlcpy+0x2b>
  8007f5:	8a 19                	mov    (%ecx),%bl
  8007f7:	84 db                	test   %bl,%bl
  8007f9:	75 ef                	jne    8007ea <strlcpy+0x16>
  8007fb:	89 c2                	mov    %eax,%edx
  8007fd:	eb 02                	jmp    800801 <strlcpy+0x2d>
  8007ff:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800801:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800804:	29 f0                	sub    %esi,%eax
}
  800806:	5b                   	pop    %ebx
  800807:	5e                   	pop    %esi
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800810:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800813:	eb 02                	jmp    800817 <strcmp+0xd>
		p++, q++;
  800815:	41                   	inc    %ecx
  800816:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800817:	8a 01                	mov    (%ecx),%al
  800819:	84 c0                	test   %al,%al
  80081b:	74 04                	je     800821 <strcmp+0x17>
  80081d:	3a 02                	cmp    (%edx),%al
  80081f:	74 f4                	je     800815 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800821:	0f b6 c0             	movzbl %al,%eax
  800824:	0f b6 12             	movzbl (%edx),%edx
  800827:	29 d0                	sub    %edx,%eax
}
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 45 08             	mov    0x8(%ebp),%eax
  800832:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800835:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800838:	eb 03                	jmp    80083d <strncmp+0x12>
		n--, p++, q++;
  80083a:	4a                   	dec    %edx
  80083b:	40                   	inc    %eax
  80083c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80083d:	85 d2                	test   %edx,%edx
  80083f:	74 14                	je     800855 <strncmp+0x2a>
  800841:	8a 18                	mov    (%eax),%bl
  800843:	84 db                	test   %bl,%bl
  800845:	74 04                	je     80084b <strncmp+0x20>
  800847:	3a 19                	cmp    (%ecx),%bl
  800849:	74 ef                	je     80083a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084b:	0f b6 00             	movzbl (%eax),%eax
  80084e:	0f b6 11             	movzbl (%ecx),%edx
  800851:	29 d0                	sub    %edx,%eax
  800853:	eb 05                	jmp    80085a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800855:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80085a:	5b                   	pop    %ebx
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800866:	eb 05                	jmp    80086d <strchr+0x10>
		if (*s == c)
  800868:	38 ca                	cmp    %cl,%dl
  80086a:	74 0c                	je     800878 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80086c:	40                   	inc    %eax
  80086d:	8a 10                	mov    (%eax),%dl
  80086f:	84 d2                	test   %dl,%dl
  800871:	75 f5                	jne    800868 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800873:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800883:	eb 05                	jmp    80088a <strfind+0x10>
		if (*s == c)
  800885:	38 ca                	cmp    %cl,%dl
  800887:	74 07                	je     800890 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800889:	40                   	inc    %eax
  80088a:	8a 10                	mov    (%eax),%dl
  80088c:	84 d2                	test   %dl,%dl
  80088e:	75 f5                	jne    800885 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	57                   	push   %edi
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
  800898:	8b 7d 08             	mov    0x8(%ebp),%edi
  80089b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a1:	85 c9                	test   %ecx,%ecx
  8008a3:	74 30                	je     8008d5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ab:	75 25                	jne    8008d2 <memset+0x40>
  8008ad:	f6 c1 03             	test   $0x3,%cl
  8008b0:	75 20                	jne    8008d2 <memset+0x40>
		c &= 0xFF;
  8008b2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008b5:	89 d3                	mov    %edx,%ebx
  8008b7:	c1 e3 08             	shl    $0x8,%ebx
  8008ba:	89 d6                	mov    %edx,%esi
  8008bc:	c1 e6 18             	shl    $0x18,%esi
  8008bf:	89 d0                	mov    %edx,%eax
  8008c1:	c1 e0 10             	shl    $0x10,%eax
  8008c4:	09 f0                	or     %esi,%eax
  8008c6:	09 d0                	or     %edx,%eax
  8008c8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ca:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008cd:	fc                   	cld    
  8008ce:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d0:	eb 03                	jmp    8008d5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d2:	fc                   	cld    
  8008d3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d5:	89 f8                	mov    %edi,%eax
  8008d7:	5b                   	pop    %ebx
  8008d8:	5e                   	pop    %esi
  8008d9:	5f                   	pop    %edi
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	57                   	push   %edi
  8008e0:	56                   	push   %esi
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ea:	39 c6                	cmp    %eax,%esi
  8008ec:	73 34                	jae    800922 <memmove+0x46>
  8008ee:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008f1:	39 d0                	cmp    %edx,%eax
  8008f3:	73 2d                	jae    800922 <memmove+0x46>
		s += n;
		d += n;
  8008f5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f8:	f6 c2 03             	test   $0x3,%dl
  8008fb:	75 1b                	jne    800918 <memmove+0x3c>
  8008fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800903:	75 13                	jne    800918 <memmove+0x3c>
  800905:	f6 c1 03             	test   $0x3,%cl
  800908:	75 0e                	jne    800918 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80090a:	83 ef 04             	sub    $0x4,%edi
  80090d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800910:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800913:	fd                   	std    
  800914:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800916:	eb 07                	jmp    80091f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800918:	4f                   	dec    %edi
  800919:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80091c:	fd                   	std    
  80091d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80091f:	fc                   	cld    
  800920:	eb 20                	jmp    800942 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800922:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800928:	75 13                	jne    80093d <memmove+0x61>
  80092a:	a8 03                	test   $0x3,%al
  80092c:	75 0f                	jne    80093d <memmove+0x61>
  80092e:	f6 c1 03             	test   $0x3,%cl
  800931:	75 0a                	jne    80093d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800933:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800936:	89 c7                	mov    %eax,%edi
  800938:	fc                   	cld    
  800939:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093b:	eb 05                	jmp    800942 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80093d:	89 c7                	mov    %eax,%edi
  80093f:	fc                   	cld    
  800940:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800942:	5e                   	pop    %esi
  800943:	5f                   	pop    %edi
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80094c:	8b 45 10             	mov    0x10(%ebp),%eax
  80094f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800953:	8b 45 0c             	mov    0xc(%ebp),%eax
  800956:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	89 04 24             	mov    %eax,(%esp)
  800960:	e8 77 ff ff ff       	call   8008dc <memmove>
}
  800965:	c9                   	leave  
  800966:	c3                   	ret    

00800967 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	57                   	push   %edi
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800970:	8b 75 0c             	mov    0xc(%ebp),%esi
  800973:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800976:	ba 00 00 00 00       	mov    $0x0,%edx
  80097b:	eb 16                	jmp    800993 <memcmp+0x2c>
		if (*s1 != *s2)
  80097d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800980:	42                   	inc    %edx
  800981:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800985:	38 c8                	cmp    %cl,%al
  800987:	74 0a                	je     800993 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800989:	0f b6 c0             	movzbl %al,%eax
  80098c:	0f b6 c9             	movzbl %cl,%ecx
  80098f:	29 c8                	sub    %ecx,%eax
  800991:	eb 09                	jmp    80099c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800993:	39 da                	cmp    %ebx,%edx
  800995:	75 e6                	jne    80097d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800997:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5f                   	pop    %edi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009aa:	89 c2                	mov    %eax,%edx
  8009ac:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009af:	eb 05                	jmp    8009b6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b1:	38 08                	cmp    %cl,(%eax)
  8009b3:	74 05                	je     8009ba <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b5:	40                   	inc    %eax
  8009b6:	39 d0                	cmp    %edx,%eax
  8009b8:	72 f7                	jb     8009b1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	57                   	push   %edi
  8009c0:	56                   	push   %esi
  8009c1:	53                   	push   %ebx
  8009c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c8:	eb 01                	jmp    8009cb <strtol+0xf>
		s++;
  8009ca:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cb:	8a 02                	mov    (%edx),%al
  8009cd:	3c 20                	cmp    $0x20,%al
  8009cf:	74 f9                	je     8009ca <strtol+0xe>
  8009d1:	3c 09                	cmp    $0x9,%al
  8009d3:	74 f5                	je     8009ca <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009d5:	3c 2b                	cmp    $0x2b,%al
  8009d7:	75 08                	jne    8009e1 <strtol+0x25>
		s++;
  8009d9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009da:	bf 00 00 00 00       	mov    $0x0,%edi
  8009df:	eb 13                	jmp    8009f4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009e1:	3c 2d                	cmp    $0x2d,%al
  8009e3:	75 0a                	jne    8009ef <strtol+0x33>
		s++, neg = 1;
  8009e5:	8d 52 01             	lea    0x1(%edx),%edx
  8009e8:	bf 01 00 00 00       	mov    $0x1,%edi
  8009ed:	eb 05                	jmp    8009f4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f4:	85 db                	test   %ebx,%ebx
  8009f6:	74 05                	je     8009fd <strtol+0x41>
  8009f8:	83 fb 10             	cmp    $0x10,%ebx
  8009fb:	75 28                	jne    800a25 <strtol+0x69>
  8009fd:	8a 02                	mov    (%edx),%al
  8009ff:	3c 30                	cmp    $0x30,%al
  800a01:	75 10                	jne    800a13 <strtol+0x57>
  800a03:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a07:	75 0a                	jne    800a13 <strtol+0x57>
		s += 2, base = 16;
  800a09:	83 c2 02             	add    $0x2,%edx
  800a0c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a11:	eb 12                	jmp    800a25 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a13:	85 db                	test   %ebx,%ebx
  800a15:	75 0e                	jne    800a25 <strtol+0x69>
  800a17:	3c 30                	cmp    $0x30,%al
  800a19:	75 05                	jne    800a20 <strtol+0x64>
		s++, base = 8;
  800a1b:	42                   	inc    %edx
  800a1c:	b3 08                	mov    $0x8,%bl
  800a1e:	eb 05                	jmp    800a25 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a20:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a2c:	8a 0a                	mov    (%edx),%cl
  800a2e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a31:	80 fb 09             	cmp    $0x9,%bl
  800a34:	77 08                	ja     800a3e <strtol+0x82>
			dig = *s - '0';
  800a36:	0f be c9             	movsbl %cl,%ecx
  800a39:	83 e9 30             	sub    $0x30,%ecx
  800a3c:	eb 1e                	jmp    800a5c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a3e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a41:	80 fb 19             	cmp    $0x19,%bl
  800a44:	77 08                	ja     800a4e <strtol+0x92>
			dig = *s - 'a' + 10;
  800a46:	0f be c9             	movsbl %cl,%ecx
  800a49:	83 e9 57             	sub    $0x57,%ecx
  800a4c:	eb 0e                	jmp    800a5c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a4e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a51:	80 fb 19             	cmp    $0x19,%bl
  800a54:	77 12                	ja     800a68 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a56:	0f be c9             	movsbl %cl,%ecx
  800a59:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a5c:	39 f1                	cmp    %esi,%ecx
  800a5e:	7d 0c                	jge    800a6c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a60:	42                   	inc    %edx
  800a61:	0f af c6             	imul   %esi,%eax
  800a64:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a66:	eb c4                	jmp    800a2c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a68:	89 c1                	mov    %eax,%ecx
  800a6a:	eb 02                	jmp    800a6e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a6c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a6e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a72:	74 05                	je     800a79 <strtol+0xbd>
		*endptr = (char *) s;
  800a74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a77:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a79:	85 ff                	test   %edi,%edi
  800a7b:	74 04                	je     800a81 <strtol+0xc5>
  800a7d:	89 c8                	mov    %ecx,%eax
  800a7f:	f7 d8                	neg    %eax
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5f                   	pop    %edi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    
	...

00800a88 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	57                   	push   %edi
  800a8c:	56                   	push   %esi
  800a8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a96:	8b 55 08             	mov    0x8(%ebp),%edx
  800a99:	89 c3                	mov    %eax,%ebx
  800a9b:	89 c7                	mov    %eax,%edi
  800a9d:	89 c6                	mov    %eax,%esi
  800a9f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	57                   	push   %edi
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aac:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab6:	89 d1                	mov    %edx,%ecx
  800ab8:	89 d3                	mov    %edx,%ebx
  800aba:	89 d7                	mov    %edx,%edi
  800abc:	89 d6                	mov    %edx,%esi
  800abe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5f                   	pop    %edi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	57                   	push   %edi
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ace:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad8:	8b 55 08             	mov    0x8(%ebp),%edx
  800adb:	89 cb                	mov    %ecx,%ebx
  800add:	89 cf                	mov    %ecx,%edi
  800adf:	89 ce                	mov    %ecx,%esi
  800ae1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ae3:	85 c0                	test   %eax,%eax
  800ae5:	7e 28                	jle    800b0f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800aeb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800af2:	00 
  800af3:	c7 44 24 08 28 17 80 	movl   $0x801728,0x8(%esp)
  800afa:	00 
  800afb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b02:	00 
  800b03:	c7 04 24 45 17 80 00 	movl   $0x801745,(%esp)
  800b0a:	e8 b5 05 00 00       	call   8010c4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b0f:	83 c4 2c             	add    $0x2c,%esp
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	57                   	push   %edi
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b22:	b8 02 00 00 00       	mov    $0x2,%eax
  800b27:	89 d1                	mov    %edx,%ecx
  800b29:	89 d3                	mov    %edx,%ebx
  800b2b:	89 d7                	mov    %edx,%edi
  800b2d:	89 d6                	mov    %edx,%esi
  800b2f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <sys_yield>:

void
sys_yield(void)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b41:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b46:	89 d1                	mov    %edx,%ecx
  800b48:	89 d3                	mov    %edx,%ebx
  800b4a:	89 d7                	mov    %edx,%edi
  800b4c:	89 d6                	mov    %edx,%esi
  800b4e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5e:	be 00 00 00 00       	mov    $0x0,%esi
  800b63:	b8 04 00 00 00       	mov    $0x4,%eax
  800b68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b71:	89 f7                	mov    %esi,%edi
  800b73:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b75:	85 c0                	test   %eax,%eax
  800b77:	7e 28                	jle    800ba1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b7d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b84:	00 
  800b85:	c7 44 24 08 28 17 80 	movl   $0x801728,0x8(%esp)
  800b8c:	00 
  800b8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b94:	00 
  800b95:	c7 04 24 45 17 80 00 	movl   $0x801745,(%esp)
  800b9c:	e8 23 05 00 00       	call   8010c4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ba1:	83 c4 2c             	add    $0x2c,%esp
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc8:	85 c0                	test   %eax,%eax
  800bca:	7e 28                	jle    800bf4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bd7:	00 
  800bd8:	c7 44 24 08 28 17 80 	movl   $0x801728,0x8(%esp)
  800bdf:	00 
  800be0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be7:	00 
  800be8:	c7 04 24 45 17 80 00 	movl   $0x801745,(%esp)
  800bef:	e8 d0 04 00 00       	call   8010c4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf4:	83 c4 2c             	add    $0x2c,%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	89 df                	mov    %ebx,%edi
  800c17:	89 de                	mov    %ebx,%esi
  800c19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7e 28                	jle    800c47 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c23:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c2a:	00 
  800c2b:	c7 44 24 08 28 17 80 	movl   $0x801728,0x8(%esp)
  800c32:	00 
  800c33:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c3a:	00 
  800c3b:	c7 04 24 45 17 80 00 	movl   $0x801745,(%esp)
  800c42:	e8 7d 04 00 00       	call   8010c4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c47:	83 c4 2c             	add    $0x2c,%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
  800c55:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	89 df                	mov    %ebx,%edi
  800c6a:	89 de                	mov    %ebx,%esi
  800c6c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6e:	85 c0                	test   %eax,%eax
  800c70:	7e 28                	jle    800c9a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c72:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c76:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c7d:	00 
  800c7e:	c7 44 24 08 28 17 80 	movl   $0x801728,0x8(%esp)
  800c85:	00 
  800c86:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8d:	00 
  800c8e:	c7 04 24 45 17 80 00 	movl   $0x801745,(%esp)
  800c95:	e8 2a 04 00 00       	call   8010c4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9a:	83 c4 2c             	add    $0x2c,%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	89 df                	mov    %ebx,%edi
  800cbd:	89 de                	mov    %ebx,%esi
  800cbf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7e 28                	jle    800ced <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cd0:	00 
  800cd1:	c7 44 24 08 28 17 80 	movl   $0x801728,0x8(%esp)
  800cd8:	00 
  800cd9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce0:	00 
  800ce1:	c7 04 24 45 17 80 00 	movl   $0x801745,(%esp)
  800ce8:	e8 d7 03 00 00       	call   8010c4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ced:	83 c4 2c             	add    $0x2c,%esp
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfb:	be 00 00 00 00       	mov    $0x0,%esi
  800d00:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d05:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d08:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d11:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    

00800d18 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
  800d1e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d21:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d26:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2e:	89 cb                	mov    %ecx,%ebx
  800d30:	89 cf                	mov    %ecx,%edi
  800d32:	89 ce                	mov    %ecx,%esi
  800d34:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	7e 28                	jle    800d62 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d45:	00 
  800d46:	c7 44 24 08 28 17 80 	movl   $0x801728,0x8(%esp)
  800d4d:	00 
  800d4e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d55:	00 
  800d56:	c7 04 24 45 17 80 00 	movl   $0x801745,(%esp)
  800d5d:	e8 62 03 00 00       	call   8010c4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d62:	83 c4 2c             	add    $0x2c,%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
  800d70:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d78:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d80:	8b 55 08             	mov    0x8(%ebp),%edx
  800d83:	89 df                	mov    %ebx,%edi
  800d85:	89 de                	mov    %ebx,%esi
  800d87:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	7e 28                	jle    800db5 <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d91:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d98:	00 
  800d99:	c7 44 24 08 28 17 80 	movl   $0x801728,0x8(%esp)
  800da0:	00 
  800da1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da8:	00 
  800da9:	c7 04 24 45 17 80 00 	movl   $0x801745,(%esp)
  800db0:	e8 0f 03 00 00       	call   8010c4 <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800db5:	83 c4 2c             	add    $0x2c,%esp
  800db8:	5b                   	pop    %ebx
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    
  800dbd:	00 00                	add    %al,(%eax)
	...

00800dc0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 24             	sub    $0x24,%esp
  800dc7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dca:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800dcc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dd0:	74 2d                	je     800dff <pgfault+0x3f>
  800dd2:	89 d8                	mov    %ebx,%eax
  800dd4:	c1 e8 16             	shr    $0x16,%eax
  800dd7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800dde:	a8 01                	test   $0x1,%al
  800de0:	74 1d                	je     800dff <pgfault+0x3f>
		(uvpt[PGNUM(addr)] & PTE_P) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800de2:	89 d8                	mov    %ebx,%eax
  800de4:	c1 e8 0c             	shr    $0xc,%eax
  800de7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800dee:	f6 c2 01             	test   $0x1,%dl
  800df1:	74 0c                	je     800dff <pgfault+0x3f>
		(uvpt[PGNUM(addr)] & PTE_P) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800df3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dfa:	f6 c4 08             	test   $0x8,%ah
  800dfd:	75 1c                	jne    800e1b <pgfault+0x5b>
		panic("pgfault: not a write or a copy on write page fault!");
  800dff:	c7 44 24 08 54 17 80 	movl   $0x801754,0x8(%esp)
  800e06:	00 
  800e07:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800e0e:	00 
  800e0f:	c7 04 24 88 17 80 00 	movl   $0x801788,(%esp)
  800e16:	e8 a9 02 00 00       	call   8010c4 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	// we need to make addr page-aligned
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)) < 0)
  800e1b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e22:	00 
  800e23:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e2a:	00 
  800e2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e32:	e8 1e fd ff ff       	call   800b55 <sys_page_alloc>
  800e37:	85 c0                	test   %eax,%eax
  800e39:	79 20                	jns    800e5b <pgfault+0x9b>
		panic("pgfault: sys_page_alloc: %e", r);
  800e3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e3f:	c7 44 24 08 93 17 80 	movl   $0x801793,0x8(%esp)
  800e46:	00 
  800e47:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800e4e:	00 
  800e4f:	c7 04 24 88 17 80 00 	movl   $0x801788,(%esp)
  800e56:	e8 69 02 00 00       	call   8010c4 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// we need to make addr page-aligned
	addr = ROUNDDOWN(addr, PGSIZE);
  800e5b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)) < 0)
		panic("pgfault: sys_page_alloc: %e", r);
	memcpy(PFTEMP, addr, PGSIZE);
  800e61:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800e68:	00 
  800e69:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e6d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800e74:	e8 cd fa ff ff       	call   800946 <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P)) < 0)
  800e79:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800e80:	00 
  800e81:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e85:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e8c:	00 
  800e8d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e94:	00 
  800e95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e9c:	e8 08 fd ff ff       	call   800ba9 <sys_page_map>
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	79 20                	jns    800ec5 <pgfault+0x105>
		panic("pgfault: sys_page_map: %e", r);
  800ea5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ea9:	c7 44 24 08 af 17 80 	movl   $0x8017af,0x8(%esp)
  800eb0:	00 
  800eb1:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800eb8:	00 
  800eb9:	c7 04 24 88 17 80 00 	movl   $0x801788,(%esp)
  800ec0:	e8 ff 01 00 00       	call   8010c4 <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800ec5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ecc:	00 
  800ecd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ed4:	e8 23 fd ff ff       	call   800bfc <sys_page_unmap>
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	79 20                	jns    800efd <pgfault+0x13d>
		panic("pgfault: sys_page_unmap: %e", r);
  800edd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ee1:	c7 44 24 08 c9 17 80 	movl   $0x8017c9,0x8(%esp)
  800ee8:	00 
  800ee9:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800ef0:	00 
  800ef1:	c7 04 24 88 17 80 00 	movl   $0x801788,(%esp)
  800ef8:	e8 c7 01 00 00       	call   8010c4 <_panic>
}
  800efd:	83 c4 24             	add    $0x24,%esp
  800f00:	5b                   	pop    %ebx
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	57                   	push   %edi
  800f07:	56                   	push   %esi
  800f08:	53                   	push   %ebx
  800f09:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800f0c:	c7 04 24 c0 0d 80 00 	movl   $0x800dc0,(%esp)
  800f13:	e8 04 02 00 00       	call   80111c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f18:	ba 07 00 00 00       	mov    $0x7,%edx
  800f1d:	89 d0                	mov    %edx,%eax
  800f1f:	cd 30                	int    $0x30
  800f21:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f24:	89 c7                	mov    %eax,%edi
	envid_t envid;
	uint8_t *addr;
	int r;
	extern unsigned char end[];
	envid = sys_exofork();
	if (envid < 0)
  800f26:	85 c0                	test   %eax,%eax
  800f28:	79 20                	jns    800f4a <fork+0x47>
		panic("sys_exofork: %e", envid);
  800f2a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f2e:	c7 44 24 08 e5 17 80 	movl   $0x8017e5,0x8(%esp)
  800f35:	00 
  800f36:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  800f3d:	00 
  800f3e:	c7 04 24 88 17 80 00 	movl   $0x801788,(%esp)
  800f45:	e8 7a 01 00 00       	call   8010c4 <_panic>
	if (envid == 0) {
  800f4a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f4e:	75 27                	jne    800f77 <fork+0x74>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800f50:	e8 c2 fb ff ff       	call   800b17 <sys_getenvid>
  800f55:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f5a:	8d 14 80             	lea    (%eax,%eax,4),%edx
  800f5d:	8d 04 50             	lea    (%eax,%edx,2),%eax
  800f60:	c1 e0 04             	shl    $0x4,%eax
  800f63:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f68:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800f6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f72:	e9 23 01 00 00       	jmp    80109a <fork+0x197>
	int r;
	extern unsigned char end[];
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  800f77:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	}

	// We're the parent.
	for (addr = 0; addr < (uint8_t *)USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  800f7c:	89 d8                	mov    %ebx,%eax
  800f7e:	c1 e8 16             	shr    $0x16,%eax
  800f81:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f88:	a8 01                	test   $0x1,%al
  800f8a:	0f 84 ac 00 00 00    	je     80103c <fork+0x139>
  800f90:	89 d8                	mov    %ebx,%eax
  800f92:	c1 e8 0c             	shr    $0xc,%eax
  800f95:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f9c:	f6 c2 01             	test   $0x1,%dl
  800f9f:	0f 84 97 00 00 00    	je     80103c <fork+0x139>
			&& (uvpt[PGNUM(addr)] & PTE_U))
  800fa5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fac:	f6 c2 04             	test   $0x4,%dl
  800faf:	0f 84 87 00 00 00    	je     80103c <fork+0x139>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	void *va = (void *)(pn * PGSIZE);
  800fb5:	89 c6                	mov    %eax,%esi
  800fb7:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  800fba:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fc1:	f6 c2 02             	test   $0x2,%dl
  800fc4:	75 0c                	jne    800fd2 <fork+0xcf>
  800fc6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fcd:	f6 c4 08             	test   $0x8,%ah
  800fd0:	74 4a                	je     80101c <fork+0x119>
		if ((r = sys_page_map(0, va, envid, va, PTE_COW|PTE_U|PTE_P)) < 0)
  800fd2:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  800fd9:	00 
  800fda:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800fde:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fe2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fe6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fed:	e8 b7 fb ff ff       	call   800ba9 <sys_page_map>
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	78 46                	js     80103c <fork+0x139>
			return r;
		if ((r = sys_page_map(0, va, 0, va, PTE_COW|PTE_U|PTE_P)) < 0)
  800ff6:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  800ffd:	00 
  800ffe:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801002:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801009:	00 
  80100a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80100e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801015:	e8 8f fb ff ff       	call   800ba9 <sys_page_map>
  80101a:	eb 20                	jmp    80103c <fork+0x139>
			return r;
	}
	else {
		if ((r = sys_page_map(0, va, envid, va, PTE_U|PTE_P)) < 0)
  80101c:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801023:	00 
  801024:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801028:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80102c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801030:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801037:	e8 6d fb ff ff       	call   800ba9 <sys_page_map>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	// We're the parent.
	for (addr = 0; addr < (uint8_t *)USTACKTOP; addr += PGSIZE)
  80103c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801042:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801048:	0f 85 2e ff ff ff    	jne    800f7c <fork+0x79>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
			&& (uvpt[PGNUM(addr)] & PTE_U))
			duppage(envid, PGNUM(addr));

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  80104e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801055:	00 
  801056:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80105d:	ee 
  80105e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801061:	89 04 24             	mov    %eax,(%esp)
  801064:	e8 ec fa ff ff       	call   800b55 <sys_page_alloc>
  801069:	85 c0                	test   %eax,%eax
  80106b:	78 2d                	js     80109a <fork+0x197>
		return r;
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80106d:	c7 44 24 04 b0 11 80 	movl   $0x8011b0,0x4(%esp)
  801074:	00 
  801075:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801078:	89 04 24             	mov    %eax,(%esp)
  80107b:	e8 22 fc ff ff       	call   800ca2 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801080:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801087:	00 
  801088:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80108b:	89 04 24             	mov    %eax,(%esp)
  80108e:	e8 bc fb ff ff       	call   800c4f <sys_env_set_status>
  801093:	85 c0                	test   %eax,%eax
  801095:	78 03                	js     80109a <fork+0x197>
		return r;

	return envid;
  801097:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  80109a:	83 c4 3c             	add    $0x3c,%esp
  80109d:	5b                   	pop    %ebx
  80109e:	5e                   	pop    %esi
  80109f:	5f                   	pop    %edi
  8010a0:	5d                   	pop    %ebp
  8010a1:	c3                   	ret    

008010a2 <sfork>:

// Challenge!
int
sfork(void)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8010a8:	c7 44 24 08 f5 17 80 	movl   $0x8017f5,0x8(%esp)
  8010af:	00 
  8010b0:	c7 44 24 04 8d 00 00 	movl   $0x8d,0x4(%esp)
  8010b7:	00 
  8010b8:	c7 04 24 88 17 80 00 	movl   $0x801788,(%esp)
  8010bf:	e8 00 00 00 00       	call   8010c4 <_panic>

008010c4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	56                   	push   %esi
  8010c8:	53                   	push   %ebx
  8010c9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8010cc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010cf:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8010d5:	e8 3d fa ff ff       	call   800b17 <sys_getenvid>
  8010da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010dd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010e8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f0:	c7 04 24 0c 18 80 00 	movl   $0x80180c,(%esp)
  8010f7:	e8 b8 f0 ff ff       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801100:	8b 45 10             	mov    0x10(%ebp),%eax
  801103:	89 04 24             	mov    %eax,(%esp)
  801106:	e8 48 f0 ff ff       	call   800153 <vcprintf>
	cprintf("\n");
  80110b:	c7 04 24 d4 14 80 00 	movl   $0x8014d4,(%esp)
  801112:	e8 9d f0 ff ff       	call   8001b4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801117:	cc                   	int3   
  801118:	eb fd                	jmp    801117 <_panic+0x53>
	...

0080111c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801122:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801129:	75 40                	jne    80116b <set_pgfault_handler+0x4f>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
  80112b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801132:	00 
  801133:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80113a:	ee 
  80113b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801142:	e8 0e fa ff ff       	call   800b55 <sys_page_alloc>
  801147:	85 c0                	test   %eax,%eax
  801149:	79 20                	jns    80116b <set_pgfault_handler+0x4f>
            panic("set_pgfault_handler: sys_page_alloc: %e", r);
  80114b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80114f:	c7 44 24 08 30 18 80 	movl   $0x801830,0x8(%esp)
  801156:	00 
  801157:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80115e:	00 
  80115f:	c7 04 24 8c 18 80 00 	movl   $0x80188c,(%esp)
  801166:	e8 59 ff ff ff       	call   8010c4 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80116b:	8b 45 08             	mov    0x8(%ebp),%eax
  80116e:	a3 0c 20 80 00       	mov    %eax,0x80200c
    if ((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0 )
  801173:	c7 44 24 04 b0 11 80 	movl   $0x8011b0,0x4(%esp)
  80117a:	00 
  80117b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801182:	e8 1b fb ff ff       	call   800ca2 <sys_env_set_pgfault_upcall>
  801187:	85 c0                	test   %eax,%eax
  801189:	79 20                	jns    8011ab <set_pgfault_handler+0x8f>
        panic("set_pgfault_handler: sys_env_set_pgfault_upcall: %e", r);
  80118b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80118f:	c7 44 24 08 58 18 80 	movl   $0x801858,0x8(%esp)
  801196:	00 
  801197:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80119e:	00 
  80119f:	c7 04 24 8c 18 80 00 	movl   $0x80188c,(%esp)
  8011a6:	e8 19 ff ff ff       	call   8010c4 <_panic>
}
  8011ab:	c9                   	leave  
  8011ac:	c3                   	ret    
  8011ad:	00 00                	add    %al,(%eax)
	...

008011b0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8011b0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8011b1:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8011b6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8011b8:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// sub 4 from old esp
	movl 0x30(%esp), %eax
  8011bb:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8011bf:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8011c2:	89 44 24 30          	mov    %eax,0x30(%esp)
	// put old eip into the pre-reserved 4-byte space
	movl 0x28(%esp), %ebx
  8011c6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8011ca:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8011cc:	83 c4 08             	add    $0x8,%esp
	popal
  8011cf:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  8011d0:	83 c4 04             	add    $0x4,%esp
	popfl
  8011d3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8011d4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8011d5:	c3                   	ret    
	...

008011d8 <__udivdi3>:
  8011d8:	55                   	push   %ebp
  8011d9:	57                   	push   %edi
  8011da:	56                   	push   %esi
  8011db:	83 ec 10             	sub    $0x10,%esp
  8011de:	8b 74 24 20          	mov    0x20(%esp),%esi
  8011e2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011ea:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8011ee:	89 cd                	mov    %ecx,%ebp
  8011f0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	75 2c                	jne    801224 <__udivdi3+0x4c>
  8011f8:	39 f9                	cmp    %edi,%ecx
  8011fa:	77 68                	ja     801264 <__udivdi3+0x8c>
  8011fc:	85 c9                	test   %ecx,%ecx
  8011fe:	75 0b                	jne    80120b <__udivdi3+0x33>
  801200:	b8 01 00 00 00       	mov    $0x1,%eax
  801205:	31 d2                	xor    %edx,%edx
  801207:	f7 f1                	div    %ecx
  801209:	89 c1                	mov    %eax,%ecx
  80120b:	31 d2                	xor    %edx,%edx
  80120d:	89 f8                	mov    %edi,%eax
  80120f:	f7 f1                	div    %ecx
  801211:	89 c7                	mov    %eax,%edi
  801213:	89 f0                	mov    %esi,%eax
  801215:	f7 f1                	div    %ecx
  801217:	89 c6                	mov    %eax,%esi
  801219:	89 f0                	mov    %esi,%eax
  80121b:	89 fa                	mov    %edi,%edx
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	5e                   	pop    %esi
  801221:	5f                   	pop    %edi
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    
  801224:	39 f8                	cmp    %edi,%eax
  801226:	77 2c                	ja     801254 <__udivdi3+0x7c>
  801228:	0f bd f0             	bsr    %eax,%esi
  80122b:	83 f6 1f             	xor    $0x1f,%esi
  80122e:	75 4c                	jne    80127c <__udivdi3+0xa4>
  801230:	39 f8                	cmp    %edi,%eax
  801232:	bf 00 00 00 00       	mov    $0x0,%edi
  801237:	72 0a                	jb     801243 <__udivdi3+0x6b>
  801239:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80123d:	0f 87 ad 00 00 00    	ja     8012f0 <__udivdi3+0x118>
  801243:	be 01 00 00 00       	mov    $0x1,%esi
  801248:	89 f0                	mov    %esi,%eax
  80124a:	89 fa                	mov    %edi,%edx
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	5e                   	pop    %esi
  801250:	5f                   	pop    %edi
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    
  801253:	90                   	nop
  801254:	31 ff                	xor    %edi,%edi
  801256:	31 f6                	xor    %esi,%esi
  801258:	89 f0                	mov    %esi,%eax
  80125a:	89 fa                	mov    %edi,%edx
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	5e                   	pop    %esi
  801260:	5f                   	pop    %edi
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    
  801263:	90                   	nop
  801264:	89 fa                	mov    %edi,%edx
  801266:	89 f0                	mov    %esi,%eax
  801268:	f7 f1                	div    %ecx
  80126a:	89 c6                	mov    %eax,%esi
  80126c:	31 ff                	xor    %edi,%edi
  80126e:	89 f0                	mov    %esi,%eax
  801270:	89 fa                	mov    %edi,%edx
  801272:	83 c4 10             	add    $0x10,%esp
  801275:	5e                   	pop    %esi
  801276:	5f                   	pop    %edi
  801277:	5d                   	pop    %ebp
  801278:	c3                   	ret    
  801279:	8d 76 00             	lea    0x0(%esi),%esi
  80127c:	89 f1                	mov    %esi,%ecx
  80127e:	d3 e0                	shl    %cl,%eax
  801280:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801284:	b8 20 00 00 00       	mov    $0x20,%eax
  801289:	29 f0                	sub    %esi,%eax
  80128b:	89 ea                	mov    %ebp,%edx
  80128d:	88 c1                	mov    %al,%cl
  80128f:	d3 ea                	shr    %cl,%edx
  801291:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801295:	09 ca                	or     %ecx,%edx
  801297:	89 54 24 08          	mov    %edx,0x8(%esp)
  80129b:	89 f1                	mov    %esi,%ecx
  80129d:	d3 e5                	shl    %cl,%ebp
  80129f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8012a3:	89 fd                	mov    %edi,%ebp
  8012a5:	88 c1                	mov    %al,%cl
  8012a7:	d3 ed                	shr    %cl,%ebp
  8012a9:	89 fa                	mov    %edi,%edx
  8012ab:	89 f1                	mov    %esi,%ecx
  8012ad:	d3 e2                	shl    %cl,%edx
  8012af:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012b3:	88 c1                	mov    %al,%cl
  8012b5:	d3 ef                	shr    %cl,%edi
  8012b7:	09 d7                	or     %edx,%edi
  8012b9:	89 f8                	mov    %edi,%eax
  8012bb:	89 ea                	mov    %ebp,%edx
  8012bd:	f7 74 24 08          	divl   0x8(%esp)
  8012c1:	89 d1                	mov    %edx,%ecx
  8012c3:	89 c7                	mov    %eax,%edi
  8012c5:	f7 64 24 0c          	mull   0xc(%esp)
  8012c9:	39 d1                	cmp    %edx,%ecx
  8012cb:	72 17                	jb     8012e4 <__udivdi3+0x10c>
  8012cd:	74 09                	je     8012d8 <__udivdi3+0x100>
  8012cf:	89 fe                	mov    %edi,%esi
  8012d1:	31 ff                	xor    %edi,%edi
  8012d3:	e9 41 ff ff ff       	jmp    801219 <__udivdi3+0x41>
  8012d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012dc:	89 f1                	mov    %esi,%ecx
  8012de:	d3 e2                	shl    %cl,%edx
  8012e0:	39 c2                	cmp    %eax,%edx
  8012e2:	73 eb                	jae    8012cf <__udivdi3+0xf7>
  8012e4:	8d 77 ff             	lea    -0x1(%edi),%esi
  8012e7:	31 ff                	xor    %edi,%edi
  8012e9:	e9 2b ff ff ff       	jmp    801219 <__udivdi3+0x41>
  8012ee:	66 90                	xchg   %ax,%ax
  8012f0:	31 f6                	xor    %esi,%esi
  8012f2:	e9 22 ff ff ff       	jmp    801219 <__udivdi3+0x41>
	...

008012f8 <__umoddi3>:
  8012f8:	55                   	push   %ebp
  8012f9:	57                   	push   %edi
  8012fa:	56                   	push   %esi
  8012fb:	83 ec 20             	sub    $0x20,%esp
  8012fe:	8b 44 24 30          	mov    0x30(%esp),%eax
  801302:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801306:	89 44 24 14          	mov    %eax,0x14(%esp)
  80130a:	8b 74 24 34          	mov    0x34(%esp),%esi
  80130e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801312:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801316:	89 c7                	mov    %eax,%edi
  801318:	89 f2                	mov    %esi,%edx
  80131a:	85 ed                	test   %ebp,%ebp
  80131c:	75 16                	jne    801334 <__umoddi3+0x3c>
  80131e:	39 f1                	cmp    %esi,%ecx
  801320:	0f 86 a6 00 00 00    	jbe    8013cc <__umoddi3+0xd4>
  801326:	f7 f1                	div    %ecx
  801328:	89 d0                	mov    %edx,%eax
  80132a:	31 d2                	xor    %edx,%edx
  80132c:	83 c4 20             	add    $0x20,%esp
  80132f:	5e                   	pop    %esi
  801330:	5f                   	pop    %edi
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    
  801333:	90                   	nop
  801334:	39 f5                	cmp    %esi,%ebp
  801336:	0f 87 ac 00 00 00    	ja     8013e8 <__umoddi3+0xf0>
  80133c:	0f bd c5             	bsr    %ebp,%eax
  80133f:	83 f0 1f             	xor    $0x1f,%eax
  801342:	89 44 24 10          	mov    %eax,0x10(%esp)
  801346:	0f 84 a8 00 00 00    	je     8013f4 <__umoddi3+0xfc>
  80134c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801350:	d3 e5                	shl    %cl,%ebp
  801352:	bf 20 00 00 00       	mov    $0x20,%edi
  801357:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80135b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80135f:	89 f9                	mov    %edi,%ecx
  801361:	d3 e8                	shr    %cl,%eax
  801363:	09 e8                	or     %ebp,%eax
  801365:	89 44 24 18          	mov    %eax,0x18(%esp)
  801369:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80136d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801371:	d3 e0                	shl    %cl,%eax
  801373:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801377:	89 f2                	mov    %esi,%edx
  801379:	d3 e2                	shl    %cl,%edx
  80137b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80137f:	d3 e0                	shl    %cl,%eax
  801381:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801385:	8b 44 24 14          	mov    0x14(%esp),%eax
  801389:	89 f9                	mov    %edi,%ecx
  80138b:	d3 e8                	shr    %cl,%eax
  80138d:	09 d0                	or     %edx,%eax
  80138f:	d3 ee                	shr    %cl,%esi
  801391:	89 f2                	mov    %esi,%edx
  801393:	f7 74 24 18          	divl   0x18(%esp)
  801397:	89 d6                	mov    %edx,%esi
  801399:	f7 64 24 0c          	mull   0xc(%esp)
  80139d:	89 c5                	mov    %eax,%ebp
  80139f:	89 d1                	mov    %edx,%ecx
  8013a1:	39 d6                	cmp    %edx,%esi
  8013a3:	72 67                	jb     80140c <__umoddi3+0x114>
  8013a5:	74 75                	je     80141c <__umoddi3+0x124>
  8013a7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8013ab:	29 e8                	sub    %ebp,%eax
  8013ad:	19 ce                	sbb    %ecx,%esi
  8013af:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8013b3:	d3 e8                	shr    %cl,%eax
  8013b5:	89 f2                	mov    %esi,%edx
  8013b7:	89 f9                	mov    %edi,%ecx
  8013b9:	d3 e2                	shl    %cl,%edx
  8013bb:	09 d0                	or     %edx,%eax
  8013bd:	89 f2                	mov    %esi,%edx
  8013bf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8013c3:	d3 ea                	shr    %cl,%edx
  8013c5:	83 c4 20             	add    $0x20,%esp
  8013c8:	5e                   	pop    %esi
  8013c9:	5f                   	pop    %edi
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    
  8013cc:	85 c9                	test   %ecx,%ecx
  8013ce:	75 0b                	jne    8013db <__umoddi3+0xe3>
  8013d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8013d5:	31 d2                	xor    %edx,%edx
  8013d7:	f7 f1                	div    %ecx
  8013d9:	89 c1                	mov    %eax,%ecx
  8013db:	89 f0                	mov    %esi,%eax
  8013dd:	31 d2                	xor    %edx,%edx
  8013df:	f7 f1                	div    %ecx
  8013e1:	89 f8                	mov    %edi,%eax
  8013e3:	e9 3e ff ff ff       	jmp    801326 <__umoddi3+0x2e>
  8013e8:	89 f2                	mov    %esi,%edx
  8013ea:	83 c4 20             	add    $0x20,%esp
  8013ed:	5e                   	pop    %esi
  8013ee:	5f                   	pop    %edi
  8013ef:	5d                   	pop    %ebp
  8013f0:	c3                   	ret    
  8013f1:	8d 76 00             	lea    0x0(%esi),%esi
  8013f4:	39 f5                	cmp    %esi,%ebp
  8013f6:	72 04                	jb     8013fc <__umoddi3+0x104>
  8013f8:	39 f9                	cmp    %edi,%ecx
  8013fa:	77 06                	ja     801402 <__umoddi3+0x10a>
  8013fc:	89 f2                	mov    %esi,%edx
  8013fe:	29 cf                	sub    %ecx,%edi
  801400:	19 ea                	sbb    %ebp,%edx
  801402:	89 f8                	mov    %edi,%eax
  801404:	83 c4 20             	add    $0x20,%esp
  801407:	5e                   	pop    %esi
  801408:	5f                   	pop    %edi
  801409:	5d                   	pop    %ebp
  80140a:	c3                   	ret    
  80140b:	90                   	nop
  80140c:	89 d1                	mov    %edx,%ecx
  80140e:	89 c5                	mov    %eax,%ebp
  801410:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801414:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801418:	eb 8d                	jmp    8013a7 <__umoddi3+0xaf>
  80141a:	66 90                	xchg   %ax,%ax
  80141c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801420:	72 ea                	jb     80140c <__umoddi3+0x114>
  801422:	89 f1                	mov    %esi,%ecx
  801424:	eb 81                	jmp    8013a7 <__umoddi3+0xaf>
