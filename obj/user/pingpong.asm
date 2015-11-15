
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 39 14 00 00       	call   80147b <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 0f 0b 00 00       	call   800b5f <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 e0 1a 80 00 	movl   $0x801ae0,(%esp)
  80005f:	e8 98 01 00 00       	call   8001fc <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 25 16 00 00       	call   8016ac <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 9a 15 00 00       	call   80163c <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 b3 0a 00 00       	call   800b5f <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 f6 1a 80 00 	movl   $0x801af6,(%esp)
  8000bf:	e8 38 01 00 00       	call   8001fc <cprintf>
		if (i == 10)
  8000c4:	83 fb 0a             	cmp    $0xa,%ebx
  8000c7:	74 25                	je     8000ee <umain+0xba>
			return;
		i++;
  8000c9:	43                   	inc    %ebx
		ipc_send(who, i, 0, 0);
  8000ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d1:	00 
  8000d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d9:	00 
  8000da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e1:	89 04 24             	mov    %eax,(%esp)
  8000e4:	e8 c3 15 00 00       	call   8016ac <ipc_send>
		if (i == 10)
  8000e9:	83 fb 0a             	cmp    $0xa,%ebx
  8000ec:	75 9c                	jne    80008a <umain+0x56>
			return;
	}

}
  8000ee:	83 c4 2c             	add    $0x2c,%esp
  8000f1:	5b                   	pop    %ebx
  8000f2:	5e                   	pop    %esi
  8000f3:	5f                   	pop    %edi
  8000f4:	5d                   	pop    %ebp
  8000f5:	c3                   	ret    
	...

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 10             	sub    $0x10,%esp
  800100:	8b 75 08             	mov    0x8(%ebp),%esi
  800103:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800106:	e8 54 0a 00 00       	call   800b5f <sys_getenvid>
  80010b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800110:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800113:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800116:	c1 e0 04             	shl    $0x4,%eax
  800119:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011e:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800123:	85 f6                	test   %esi,%esi
  800125:	7e 07                	jle    80012e <libmain+0x36>
		binaryname = argv[0];
  800127:	8b 03                	mov    (%ebx),%eax
  800129:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800132:	89 34 24             	mov    %esi,(%esp)
  800135:	e8 fa fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80013a:	e8 09 00 00 00       	call   800148 <exit>
}
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    
	...

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80014e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800155:	e8 b3 09 00 00       	call   800b0d <sys_env_destroy>
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	53                   	push   %ebx
  800160:	83 ec 14             	sub    $0x14,%esp
  800163:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800166:	8b 03                	mov    (%ebx),%eax
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80016f:	40                   	inc    %eax
  800170:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800172:	3d ff 00 00 00       	cmp    $0xff,%eax
  800177:	75 19                	jne    800192 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800179:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800180:	00 
  800181:	8d 43 08             	lea    0x8(%ebx),%eax
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	e8 44 09 00 00       	call   800ad0 <sys_cputs>
		b->idx = 0;
  80018c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800192:	ff 43 04             	incl   0x4(%ebx)
}
  800195:	83 c4 14             	add    $0x14,%esp
  800198:	5b                   	pop    %ebx
  800199:	5d                   	pop    %ebp
  80019a:	c3                   	ret    

0080019b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001a4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ab:	00 00 00 
	b.cnt = 0;
  8001ae:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d0:	c7 04 24 5c 01 80 00 	movl   $0x80015c,(%esp)
  8001d7:	e8 b4 01 00 00       	call   800390 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001dc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ec:	89 04 24             	mov    %eax,(%esp)
  8001ef:	e8 dc 08 00 00       	call   800ad0 <sys_cputs>

	return b.cnt;
}
  8001f4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fa:	c9                   	leave  
  8001fb:	c3                   	ret    

008001fc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800202:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800205:	89 44 24 04          	mov    %eax,0x4(%esp)
  800209:	8b 45 08             	mov    0x8(%ebp),%eax
  80020c:	89 04 24             	mov    %eax,(%esp)
  80020f:	e8 87 ff ff ff       	call   80019b <vcprintf>
	va_end(ap);

	return cnt;
}
  800214:	c9                   	leave  
  800215:	c3                   	ret    
	...

00800218 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	57                   	push   %edi
  80021c:	56                   	push   %esi
  80021d:	53                   	push   %ebx
  80021e:	83 ec 3c             	sub    $0x3c,%esp
  800221:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800224:	89 d7                	mov    %edx,%edi
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80022c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800232:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800235:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800238:	85 c0                	test   %eax,%eax
  80023a:	75 08                	jne    800244 <printnum+0x2c>
  80023c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80023f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800242:	77 57                	ja     80029b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800244:	89 74 24 10          	mov    %esi,0x10(%esp)
  800248:	4b                   	dec    %ebx
  800249:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80024d:	8b 45 10             	mov    0x10(%ebp),%eax
  800250:	89 44 24 08          	mov    %eax,0x8(%esp)
  800254:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800258:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80025c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800263:	00 
  800264:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800267:	89 04 24             	mov    %eax,(%esp)
  80026a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80026d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800271:	e8 1a 16 00 00       	call   801890 <__udivdi3>
  800276:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80027a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80027e:	89 04 24             	mov    %eax,(%esp)
  800281:	89 54 24 04          	mov    %edx,0x4(%esp)
  800285:	89 fa                	mov    %edi,%edx
  800287:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80028a:	e8 89 ff ff ff       	call   800218 <printnum>
  80028f:	eb 0f                	jmp    8002a0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800291:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800295:	89 34 24             	mov    %esi,(%esp)
  800298:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029b:	4b                   	dec    %ebx
  80029c:	85 db                	test   %ebx,%ebx
  80029e:	7f f1                	jg     800291 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b6:	00 
  8002b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ba:	89 04 24             	mov    %eax,(%esp)
  8002bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c4:	e8 e7 16 00 00       	call   8019b0 <__umoddi3>
  8002c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002cd:	0f be 80 13 1b 80 00 	movsbl 0x801b13(%eax),%eax
  8002d4:	89 04 24             	mov    %eax,(%esp)
  8002d7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002da:	83 c4 3c             	add    $0x3c,%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e5:	83 fa 01             	cmp    $0x1,%edx
  8002e8:	7e 0e                	jle    8002f8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ea:	8b 10                	mov    (%eax),%edx
  8002ec:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ef:	89 08                	mov    %ecx,(%eax)
  8002f1:	8b 02                	mov    (%edx),%eax
  8002f3:	8b 52 04             	mov    0x4(%edx),%edx
  8002f6:	eb 22                	jmp    80031a <getuint+0x38>
	else if (lflag)
  8002f8:	85 d2                	test   %edx,%edx
  8002fa:	74 10                	je     80030c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	ba 00 00 00 00       	mov    $0x0,%edx
  80030a:	eb 0e                	jmp    80031a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80030c:	8b 10                	mov    (%eax),%edx
  80030e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 02                	mov    (%edx),%eax
  800315:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80031f:	83 fa 01             	cmp    $0x1,%edx
  800322:	7e 0e                	jle    800332 <getint+0x16>
		return va_arg(*ap, long long);
  800324:	8b 10                	mov    (%eax),%edx
  800326:	8d 4a 08             	lea    0x8(%edx),%ecx
  800329:	89 08                	mov    %ecx,(%eax)
  80032b:	8b 02                	mov    (%edx),%eax
  80032d:	8b 52 04             	mov    0x4(%edx),%edx
  800330:	eb 1a                	jmp    80034c <getint+0x30>
	else if (lflag)
  800332:	85 d2                	test   %edx,%edx
  800334:	74 0c                	je     800342 <getint+0x26>
		return va_arg(*ap, long);
  800336:	8b 10                	mov    (%eax),%edx
  800338:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033b:	89 08                	mov    %ecx,(%eax)
  80033d:	8b 02                	mov    (%edx),%eax
  80033f:	99                   	cltd   
  800340:	eb 0a                	jmp    80034c <getint+0x30>
	else
		return va_arg(*ap, int);
  800342:	8b 10                	mov    (%eax),%edx
  800344:	8d 4a 04             	lea    0x4(%edx),%ecx
  800347:	89 08                	mov    %ecx,(%eax)
  800349:	8b 02                	mov    (%edx),%eax
  80034b:	99                   	cltd   
}
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800354:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800357:	8b 10                	mov    (%eax),%edx
  800359:	3b 50 04             	cmp    0x4(%eax),%edx
  80035c:	73 08                	jae    800366 <sprintputch+0x18>
		*b->buf++ = ch;
  80035e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800361:	88 0a                	mov    %cl,(%edx)
  800363:	42                   	inc    %edx
  800364:	89 10                	mov    %edx,(%eax)
}
  800366:	5d                   	pop    %ebp
  800367:	c3                   	ret    

00800368 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80036e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800371:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800375:	8b 45 10             	mov    0x10(%ebp),%eax
  800378:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80037f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800383:	8b 45 08             	mov    0x8(%ebp),%eax
  800386:	89 04 24             	mov    %eax,(%esp)
  800389:	e8 02 00 00 00       	call   800390 <vprintfmt>
	va_end(ap);
}
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	57                   	push   %edi
  800394:	56                   	push   %esi
  800395:	53                   	push   %ebx
  800396:	83 ec 4c             	sub    $0x4c,%esp
  800399:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80039c:	8b 75 10             	mov    0x10(%ebp),%esi
  80039f:	eb 12                	jmp    8003b3 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003a1:	85 c0                	test   %eax,%eax
  8003a3:	0f 84 40 03 00 00    	je     8006e9 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  8003a9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ad:	89 04 24             	mov    %eax,(%esp)
  8003b0:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b3:	0f b6 06             	movzbl (%esi),%eax
  8003b6:	46                   	inc    %esi
  8003b7:	83 f8 25             	cmp    $0x25,%eax
  8003ba:	75 e5                	jne    8003a1 <vprintfmt+0x11>
  8003bc:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003c0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003c7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003cc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d8:	eb 26                	jmp    800400 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003dd:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003e1:	eb 1d                	jmp    800400 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e6:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003ea:	eb 14                	jmp    800400 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003ef:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003f6:	eb 08                	jmp    800400 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003f8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003fb:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	0f b6 06             	movzbl (%esi),%eax
  800403:	8d 4e 01             	lea    0x1(%esi),%ecx
  800406:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800409:	8a 0e                	mov    (%esi),%cl
  80040b:	83 e9 23             	sub    $0x23,%ecx
  80040e:	80 f9 55             	cmp    $0x55,%cl
  800411:	0f 87 b6 02 00 00    	ja     8006cd <vprintfmt+0x33d>
  800417:	0f b6 c9             	movzbl %cl,%ecx
  80041a:	ff 24 8d e0 1b 80 00 	jmp    *0x801be0(,%ecx,4)
  800421:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800424:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800429:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  80042c:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  800430:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800433:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800436:	83 f9 09             	cmp    $0x9,%ecx
  800439:	77 2a                	ja     800465 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80043b:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80043c:	eb eb                	jmp    800429 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80043e:	8b 45 14             	mov    0x14(%ebp),%eax
  800441:	8d 48 04             	lea    0x4(%eax),%ecx
  800444:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800447:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80044c:	eb 17                	jmp    800465 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80044e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800452:	78 98                	js     8003ec <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800457:	eb a7                	jmp    800400 <vprintfmt+0x70>
  800459:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80045c:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800463:	eb 9b                	jmp    800400 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800465:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800469:	79 95                	jns    800400 <vprintfmt+0x70>
  80046b:	eb 8b                	jmp    8003f8 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046d:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800471:	eb 8d                	jmp    800400 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800473:	8b 45 14             	mov    0x14(%ebp),%eax
  800476:	8d 50 04             	lea    0x4(%eax),%edx
  800479:	89 55 14             	mov    %edx,0x14(%ebp)
  80047c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800480:	8b 00                	mov    (%eax),%eax
  800482:	89 04 24             	mov    %eax,(%esp)
  800485:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800488:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80048b:	e9 23 ff ff ff       	jmp    8003b3 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800490:	8b 45 14             	mov    0x14(%ebp),%eax
  800493:	8d 50 04             	lea    0x4(%eax),%edx
  800496:	89 55 14             	mov    %edx,0x14(%ebp)
  800499:	8b 00                	mov    (%eax),%eax
  80049b:	85 c0                	test   %eax,%eax
  80049d:	79 02                	jns    8004a1 <vprintfmt+0x111>
  80049f:	f7 d8                	neg    %eax
  8004a1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a3:	83 f8 09             	cmp    $0x9,%eax
  8004a6:	7f 0b                	jg     8004b3 <vprintfmt+0x123>
  8004a8:	8b 04 85 40 1d 80 00 	mov    0x801d40(,%eax,4),%eax
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	75 23                	jne    8004d6 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004b3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004b7:	c7 44 24 08 2b 1b 80 	movl   $0x801b2b,0x8(%esp)
  8004be:	00 
  8004bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c6:	89 04 24             	mov    %eax,(%esp)
  8004c9:	e8 9a fe ff ff       	call   800368 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004d1:	e9 dd fe ff ff       	jmp    8003b3 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004da:	c7 44 24 08 34 1b 80 	movl   $0x801b34,0x8(%esp)
  8004e1:	00 
  8004e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8004e9:	89 14 24             	mov    %edx,(%esp)
  8004ec:	e8 77 fe ff ff       	call   800368 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004f4:	e9 ba fe ff ff       	jmp    8003b3 <vprintfmt+0x23>
  8004f9:	89 f9                	mov    %edi,%ecx
  8004fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004fe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8d 50 04             	lea    0x4(%eax),%edx
  800507:	89 55 14             	mov    %edx,0x14(%ebp)
  80050a:	8b 30                	mov    (%eax),%esi
  80050c:	85 f6                	test   %esi,%esi
  80050e:	75 05                	jne    800515 <vprintfmt+0x185>
				p = "(null)";
  800510:	be 24 1b 80 00       	mov    $0x801b24,%esi
			if (width > 0 && padc != '-')
  800515:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800519:	0f 8e 84 00 00 00    	jle    8005a3 <vprintfmt+0x213>
  80051f:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800523:	74 7e                	je     8005a3 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800525:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800529:	89 34 24             	mov    %esi,(%esp)
  80052c:	e8 5d 02 00 00       	call   80078e <strnlen>
  800531:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800534:	29 c2                	sub    %eax,%edx
  800536:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800539:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  80053d:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800540:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800543:	89 de                	mov    %ebx,%esi
  800545:	89 d3                	mov    %edx,%ebx
  800547:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800549:	eb 0b                	jmp    800556 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80054b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80054f:	89 3c 24             	mov    %edi,(%esp)
  800552:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800555:	4b                   	dec    %ebx
  800556:	85 db                	test   %ebx,%ebx
  800558:	7f f1                	jg     80054b <vprintfmt+0x1bb>
  80055a:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80055d:	89 f3                	mov    %esi,%ebx
  80055f:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800562:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800565:	85 c0                	test   %eax,%eax
  800567:	79 05                	jns    80056e <vprintfmt+0x1de>
  800569:	b8 00 00 00 00       	mov    $0x0,%eax
  80056e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800571:	29 c2                	sub    %eax,%edx
  800573:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800576:	eb 2b                	jmp    8005a3 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800578:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80057c:	74 18                	je     800596 <vprintfmt+0x206>
  80057e:	8d 50 e0             	lea    -0x20(%eax),%edx
  800581:	83 fa 5e             	cmp    $0x5e,%edx
  800584:	76 10                	jbe    800596 <vprintfmt+0x206>
					putch('?', putdat);
  800586:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80058a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800591:	ff 55 08             	call   *0x8(%ebp)
  800594:	eb 0a                	jmp    8005a0 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800596:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059a:	89 04 24             	mov    %eax,(%esp)
  80059d:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a0:	ff 4d e4             	decl   -0x1c(%ebp)
  8005a3:	0f be 06             	movsbl (%esi),%eax
  8005a6:	46                   	inc    %esi
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	74 21                	je     8005cc <vprintfmt+0x23c>
  8005ab:	85 ff                	test   %edi,%edi
  8005ad:	78 c9                	js     800578 <vprintfmt+0x1e8>
  8005af:	4f                   	dec    %edi
  8005b0:	79 c6                	jns    800578 <vprintfmt+0x1e8>
  8005b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005b5:	89 de                	mov    %ebx,%esi
  8005b7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ba:	eb 18                	jmp    8005d4 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005c0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005c7:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c9:	4b                   	dec    %ebx
  8005ca:	eb 08                	jmp    8005d4 <vprintfmt+0x244>
  8005cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005cf:	89 de                	mov    %ebx,%esi
  8005d1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005d4:	85 db                	test   %ebx,%ebx
  8005d6:	7f e4                	jg     8005bc <vprintfmt+0x22c>
  8005d8:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005db:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005e0:	e9 ce fd ff ff       	jmp    8003b3 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e8:	e8 2f fd ff ff       	call   80031c <getint>
  8005ed:	89 c6                	mov    %eax,%esi
  8005ef:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8005f1:	85 d2                	test   %edx,%edx
  8005f3:	78 07                	js     8005fc <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f5:	be 0a 00 00 00       	mov    $0xa,%esi
  8005fa:	eb 7e                	jmp    80067a <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800600:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800607:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80060a:	89 f0                	mov    %esi,%eax
  80060c:	89 fa                	mov    %edi,%edx
  80060e:	f7 d8                	neg    %eax
  800610:	83 d2 00             	adc    $0x0,%edx
  800613:	f7 da                	neg    %edx
			}
			base = 10;
  800615:	be 0a 00 00 00       	mov    $0xa,%esi
  80061a:	eb 5e                	jmp    80067a <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80061c:	8d 45 14             	lea    0x14(%ebp),%eax
  80061f:	e8 be fc ff ff       	call   8002e2 <getuint>
			base = 10;
  800624:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800629:	eb 4f                	jmp    80067a <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80062b:	8d 45 14             	lea    0x14(%ebp),%eax
  80062e:	e8 af fc ff ff       	call   8002e2 <getuint>
			base = 8;
  800633:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800638:	eb 40                	jmp    80067a <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  80063a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800645:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800648:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800653:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800666:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80066b:	eb 0d                	jmp    80067a <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80066d:	8d 45 14             	lea    0x14(%ebp),%eax
  800670:	e8 6d fc ff ff       	call   8002e2 <getuint>
			base = 16;
  800675:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067a:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  80067e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800682:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800685:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800689:	89 74 24 08          	mov    %esi,0x8(%esp)
  80068d:	89 04 24             	mov    %eax,(%esp)
  800690:	89 54 24 04          	mov    %edx,0x4(%esp)
  800694:	89 da                	mov    %ebx,%edx
  800696:	8b 45 08             	mov    0x8(%ebp),%eax
  800699:	e8 7a fb ff ff       	call   800218 <printnum>
			break;
  80069e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006a1:	e9 0d fd ff ff       	jmp    8003b3 <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  8006a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a9:	e8 6e fc ff ff       	call   80031c <getint>
  8006ae:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  8006b6:	e9 f8 fc ff ff       	jmp    8003b3 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bf:	89 04 24             	mov    %eax,(%esp)
  8006c2:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c8:	e9 e6 fc ff ff       	jmp    8003b3 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006d8:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006db:	eb 01                	jmp    8006de <vprintfmt+0x34e>
  8006dd:	4e                   	dec    %esi
  8006de:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006e2:	75 f9                	jne    8006dd <vprintfmt+0x34d>
  8006e4:	e9 ca fc ff ff       	jmp    8003b3 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006e9:	83 c4 4c             	add    $0x4c,%esp
  8006ec:	5b                   	pop    %ebx
  8006ed:	5e                   	pop    %esi
  8006ee:	5f                   	pop    %edi
  8006ef:	5d                   	pop    %ebp
  8006f0:	c3                   	ret    

008006f1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	83 ec 28             	sub    $0x28,%esp
  8006f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800700:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800704:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800707:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 30                	je     800742 <vsnprintf+0x51>
  800712:	85 d2                	test   %edx,%edx
  800714:	7e 33                	jle    800749 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80071d:	8b 45 10             	mov    0x10(%ebp),%eax
  800720:	89 44 24 08          	mov    %eax,0x8(%esp)
  800724:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800727:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072b:	c7 04 24 4e 03 80 00 	movl   $0x80034e,(%esp)
  800732:	e8 59 fc ff ff       	call   800390 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800737:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800740:	eb 0c                	jmp    80074e <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800742:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800747:	eb 05                	jmp    80074e <vsnprintf+0x5d>
  800749:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80074e:	c9                   	leave  
  80074f:	c3                   	ret    

00800750 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800759:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075d:	8b 45 10             	mov    0x10(%ebp),%eax
  800760:	89 44 24 08          	mov    %eax,0x8(%esp)
  800764:	8b 45 0c             	mov    0xc(%ebp),%eax
  800767:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076b:	8b 45 08             	mov    0x8(%ebp),%eax
  80076e:	89 04 24             	mov    %eax,(%esp)
  800771:	e8 7b ff ff ff       	call   8006f1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800776:	c9                   	leave  
  800777:	c3                   	ret    

00800778 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077e:	b8 00 00 00 00       	mov    $0x0,%eax
  800783:	eb 01                	jmp    800786 <strlen+0xe>
		n++;
  800785:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800786:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078a:	75 f9                	jne    800785 <strlen+0xd>
		n++;
	return n;
}
  80078c:	5d                   	pop    %ebp
  80078d:	c3                   	ret    

0080078e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800794:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800797:	b8 00 00 00 00       	mov    $0x0,%eax
  80079c:	eb 01                	jmp    80079f <strnlen+0x11>
		n++;
  80079e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079f:	39 d0                	cmp    %edx,%eax
  8007a1:	74 06                	je     8007a9 <strnlen+0x1b>
  8007a3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a7:	75 f5                	jne    80079e <strnlen+0x10>
		n++;
	return n;
}
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	53                   	push   %ebx
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ba:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007bd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007c0:	42                   	inc    %edx
  8007c1:	84 c9                	test   %cl,%cl
  8007c3:	75 f5                	jne    8007ba <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c5:	5b                   	pop    %ebx
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	53                   	push   %ebx
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d2:	89 1c 24             	mov    %ebx,(%esp)
  8007d5:	e8 9e ff ff ff       	call   800778 <strlen>
	strcpy(dst + len, src);
  8007da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007e1:	01 d8                	add    %ebx,%eax
  8007e3:	89 04 24             	mov    %eax,(%esp)
  8007e6:	e8 c0 ff ff ff       	call   8007ab <strcpy>
	return dst;
}
  8007eb:	89 d8                	mov    %ebx,%eax
  8007ed:	83 c4 08             	add    $0x8,%esp
  8007f0:	5b                   	pop    %ebx
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	56                   	push   %esi
  8007f7:	53                   	push   %ebx
  8007f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fe:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800801:	b9 00 00 00 00       	mov    $0x0,%ecx
  800806:	eb 0c                	jmp    800814 <strncpy+0x21>
		*dst++ = *src;
  800808:	8a 1a                	mov    (%edx),%bl
  80080a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080d:	80 3a 01             	cmpb   $0x1,(%edx)
  800810:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800813:	41                   	inc    %ecx
  800814:	39 f1                	cmp    %esi,%ecx
  800816:	75 f0                	jne    800808 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800818:	5b                   	pop    %ebx
  800819:	5e                   	pop    %esi
  80081a:	5d                   	pop    %ebp
  80081b:	c3                   	ret    

0080081c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	56                   	push   %esi
  800820:	53                   	push   %ebx
  800821:	8b 75 08             	mov    0x8(%ebp),%esi
  800824:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800827:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082a:	85 d2                	test   %edx,%edx
  80082c:	75 0a                	jne    800838 <strlcpy+0x1c>
  80082e:	89 f0                	mov    %esi,%eax
  800830:	eb 1a                	jmp    80084c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800832:	88 18                	mov    %bl,(%eax)
  800834:	40                   	inc    %eax
  800835:	41                   	inc    %ecx
  800836:	eb 02                	jmp    80083a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800838:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80083a:	4a                   	dec    %edx
  80083b:	74 0a                	je     800847 <strlcpy+0x2b>
  80083d:	8a 19                	mov    (%ecx),%bl
  80083f:	84 db                	test   %bl,%bl
  800841:	75 ef                	jne    800832 <strlcpy+0x16>
  800843:	89 c2                	mov    %eax,%edx
  800845:	eb 02                	jmp    800849 <strlcpy+0x2d>
  800847:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800849:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80084c:	29 f0                	sub    %esi,%eax
}
  80084e:	5b                   	pop    %ebx
  80084f:	5e                   	pop    %esi
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800858:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085b:	eb 02                	jmp    80085f <strcmp+0xd>
		p++, q++;
  80085d:	41                   	inc    %ecx
  80085e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80085f:	8a 01                	mov    (%ecx),%al
  800861:	84 c0                	test   %al,%al
  800863:	74 04                	je     800869 <strcmp+0x17>
  800865:	3a 02                	cmp    (%edx),%al
  800867:	74 f4                	je     80085d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800869:	0f b6 c0             	movzbl %al,%eax
  80086c:	0f b6 12             	movzbl (%edx),%edx
  80086f:	29 d0                	sub    %edx,%eax
}
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	53                   	push   %ebx
  800877:	8b 45 08             	mov    0x8(%ebp),%eax
  80087a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800880:	eb 03                	jmp    800885 <strncmp+0x12>
		n--, p++, q++;
  800882:	4a                   	dec    %edx
  800883:	40                   	inc    %eax
  800884:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800885:	85 d2                	test   %edx,%edx
  800887:	74 14                	je     80089d <strncmp+0x2a>
  800889:	8a 18                	mov    (%eax),%bl
  80088b:	84 db                	test   %bl,%bl
  80088d:	74 04                	je     800893 <strncmp+0x20>
  80088f:	3a 19                	cmp    (%ecx),%bl
  800891:	74 ef                	je     800882 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800893:	0f b6 00             	movzbl (%eax),%eax
  800896:	0f b6 11             	movzbl (%ecx),%edx
  800899:	29 d0                	sub    %edx,%eax
  80089b:	eb 05                	jmp    8008a2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a2:	5b                   	pop    %ebx
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ae:	eb 05                	jmp    8008b5 <strchr+0x10>
		if (*s == c)
  8008b0:	38 ca                	cmp    %cl,%dl
  8008b2:	74 0c                	je     8008c0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b4:	40                   	inc    %eax
  8008b5:	8a 10                	mov    (%eax),%dl
  8008b7:	84 d2                	test   %dl,%dl
  8008b9:	75 f5                	jne    8008b0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008cb:	eb 05                	jmp    8008d2 <strfind+0x10>
		if (*s == c)
  8008cd:	38 ca                	cmp    %cl,%dl
  8008cf:	74 07                	je     8008d8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008d1:	40                   	inc    %eax
  8008d2:	8a 10                	mov    (%eax),%dl
  8008d4:	84 d2                	test   %dl,%dl
  8008d6:	75 f5                	jne    8008cd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	57                   	push   %edi
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
  8008e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e9:	85 c9                	test   %ecx,%ecx
  8008eb:	74 30                	je     80091d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ed:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f3:	75 25                	jne    80091a <memset+0x40>
  8008f5:	f6 c1 03             	test   $0x3,%cl
  8008f8:	75 20                	jne    80091a <memset+0x40>
		c &= 0xFF;
  8008fa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fd:	89 d3                	mov    %edx,%ebx
  8008ff:	c1 e3 08             	shl    $0x8,%ebx
  800902:	89 d6                	mov    %edx,%esi
  800904:	c1 e6 18             	shl    $0x18,%esi
  800907:	89 d0                	mov    %edx,%eax
  800909:	c1 e0 10             	shl    $0x10,%eax
  80090c:	09 f0                	or     %esi,%eax
  80090e:	09 d0                	or     %edx,%eax
  800910:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800912:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800915:	fc                   	cld    
  800916:	f3 ab                	rep stos %eax,%es:(%edi)
  800918:	eb 03                	jmp    80091d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091a:	fc                   	cld    
  80091b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091d:	89 f8                	mov    %edi,%eax
  80091f:	5b                   	pop    %ebx
  800920:	5e                   	pop    %esi
  800921:	5f                   	pop    %edi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	57                   	push   %edi
  800928:	56                   	push   %esi
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800932:	39 c6                	cmp    %eax,%esi
  800934:	73 34                	jae    80096a <memmove+0x46>
  800936:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800939:	39 d0                	cmp    %edx,%eax
  80093b:	73 2d                	jae    80096a <memmove+0x46>
		s += n;
		d += n;
  80093d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800940:	f6 c2 03             	test   $0x3,%dl
  800943:	75 1b                	jne    800960 <memmove+0x3c>
  800945:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094b:	75 13                	jne    800960 <memmove+0x3c>
  80094d:	f6 c1 03             	test   $0x3,%cl
  800950:	75 0e                	jne    800960 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800952:	83 ef 04             	sub    $0x4,%edi
  800955:	8d 72 fc             	lea    -0x4(%edx),%esi
  800958:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80095b:	fd                   	std    
  80095c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095e:	eb 07                	jmp    800967 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800960:	4f                   	dec    %edi
  800961:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800964:	fd                   	std    
  800965:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800967:	fc                   	cld    
  800968:	eb 20                	jmp    80098a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800970:	75 13                	jne    800985 <memmove+0x61>
  800972:	a8 03                	test   $0x3,%al
  800974:	75 0f                	jne    800985 <memmove+0x61>
  800976:	f6 c1 03             	test   $0x3,%cl
  800979:	75 0a                	jne    800985 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80097b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80097e:	89 c7                	mov    %eax,%edi
  800980:	fc                   	cld    
  800981:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800983:	eb 05                	jmp    80098a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800985:	89 c7                	mov    %eax,%edi
  800987:	fc                   	cld    
  800988:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098a:	5e                   	pop    %esi
  80098b:	5f                   	pop    %edi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800994:	8b 45 10             	mov    0x10(%ebp),%eax
  800997:	89 44 24 08          	mov    %eax,0x8(%esp)
  80099b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	89 04 24             	mov    %eax,(%esp)
  8009a8:	e8 77 ff ff ff       	call   800924 <memmove>
}
  8009ad:	c9                   	leave  
  8009ae:	c3                   	ret    

008009af <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	57                   	push   %edi
  8009b3:	56                   	push   %esi
  8009b4:	53                   	push   %ebx
  8009b5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009be:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c3:	eb 16                	jmp    8009db <memcmp+0x2c>
		if (*s1 != *s2)
  8009c5:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009c8:	42                   	inc    %edx
  8009c9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009cd:	38 c8                	cmp    %cl,%al
  8009cf:	74 0a                	je     8009db <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009d1:	0f b6 c0             	movzbl %al,%eax
  8009d4:	0f b6 c9             	movzbl %cl,%ecx
  8009d7:	29 c8                	sub    %ecx,%eax
  8009d9:	eb 09                	jmp    8009e4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009db:	39 da                	cmp    %ebx,%edx
  8009dd:	75 e6                	jne    8009c5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e4:	5b                   	pop    %ebx
  8009e5:	5e                   	pop    %esi
  8009e6:	5f                   	pop    %edi
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009f2:	89 c2                	mov    %eax,%edx
  8009f4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009f7:	eb 05                	jmp    8009fe <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f9:	38 08                	cmp    %cl,(%eax)
  8009fb:	74 05                	je     800a02 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009fd:	40                   	inc    %eax
  8009fe:	39 d0                	cmp    %edx,%eax
  800a00:	72 f7                	jb     8009f9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	57                   	push   %edi
  800a08:	56                   	push   %esi
  800a09:	53                   	push   %ebx
  800a0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a10:	eb 01                	jmp    800a13 <strtol+0xf>
		s++;
  800a12:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a13:	8a 02                	mov    (%edx),%al
  800a15:	3c 20                	cmp    $0x20,%al
  800a17:	74 f9                	je     800a12 <strtol+0xe>
  800a19:	3c 09                	cmp    $0x9,%al
  800a1b:	74 f5                	je     800a12 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1d:	3c 2b                	cmp    $0x2b,%al
  800a1f:	75 08                	jne    800a29 <strtol+0x25>
		s++;
  800a21:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a22:	bf 00 00 00 00       	mov    $0x0,%edi
  800a27:	eb 13                	jmp    800a3c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a29:	3c 2d                	cmp    $0x2d,%al
  800a2b:	75 0a                	jne    800a37 <strtol+0x33>
		s++, neg = 1;
  800a2d:	8d 52 01             	lea    0x1(%edx),%edx
  800a30:	bf 01 00 00 00       	mov    $0x1,%edi
  800a35:	eb 05                	jmp    800a3c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a37:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3c:	85 db                	test   %ebx,%ebx
  800a3e:	74 05                	je     800a45 <strtol+0x41>
  800a40:	83 fb 10             	cmp    $0x10,%ebx
  800a43:	75 28                	jne    800a6d <strtol+0x69>
  800a45:	8a 02                	mov    (%edx),%al
  800a47:	3c 30                	cmp    $0x30,%al
  800a49:	75 10                	jne    800a5b <strtol+0x57>
  800a4b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a4f:	75 0a                	jne    800a5b <strtol+0x57>
		s += 2, base = 16;
  800a51:	83 c2 02             	add    $0x2,%edx
  800a54:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a59:	eb 12                	jmp    800a6d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a5b:	85 db                	test   %ebx,%ebx
  800a5d:	75 0e                	jne    800a6d <strtol+0x69>
  800a5f:	3c 30                	cmp    $0x30,%al
  800a61:	75 05                	jne    800a68 <strtol+0x64>
		s++, base = 8;
  800a63:	42                   	inc    %edx
  800a64:	b3 08                	mov    $0x8,%bl
  800a66:	eb 05                	jmp    800a6d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a68:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a72:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a74:	8a 0a                	mov    (%edx),%cl
  800a76:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a79:	80 fb 09             	cmp    $0x9,%bl
  800a7c:	77 08                	ja     800a86 <strtol+0x82>
			dig = *s - '0';
  800a7e:	0f be c9             	movsbl %cl,%ecx
  800a81:	83 e9 30             	sub    $0x30,%ecx
  800a84:	eb 1e                	jmp    800aa4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a86:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a89:	80 fb 19             	cmp    $0x19,%bl
  800a8c:	77 08                	ja     800a96 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a8e:	0f be c9             	movsbl %cl,%ecx
  800a91:	83 e9 57             	sub    $0x57,%ecx
  800a94:	eb 0e                	jmp    800aa4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a96:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a99:	80 fb 19             	cmp    $0x19,%bl
  800a9c:	77 12                	ja     800ab0 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a9e:	0f be c9             	movsbl %cl,%ecx
  800aa1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aa4:	39 f1                	cmp    %esi,%ecx
  800aa6:	7d 0c                	jge    800ab4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800aa8:	42                   	inc    %edx
  800aa9:	0f af c6             	imul   %esi,%eax
  800aac:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800aae:	eb c4                	jmp    800a74 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ab0:	89 c1                	mov    %eax,%ecx
  800ab2:	eb 02                	jmp    800ab6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ab6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aba:	74 05                	je     800ac1 <strtol+0xbd>
		*endptr = (char *) s;
  800abc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800abf:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ac1:	85 ff                	test   %edi,%edi
  800ac3:	74 04                	je     800ac9 <strtol+0xc5>
  800ac5:	89 c8                	mov    %ecx,%eax
  800ac7:	f7 d8                	neg    %eax
}
  800ac9:	5b                   	pop    %ebx
  800aca:	5e                   	pop    %esi
  800acb:	5f                   	pop    %edi
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    
	...

00800ad0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	57                   	push   %edi
  800ad4:	56                   	push   %esi
  800ad5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad6:	b8 00 00 00 00       	mov    $0x0,%eax
  800adb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ade:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae1:	89 c3                	mov    %eax,%ebx
  800ae3:	89 c7                	mov    %eax,%edi
  800ae5:	89 c6                	mov    %eax,%esi
  800ae7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <sys_cgetc>:

int
sys_cgetc(void)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af4:	ba 00 00 00 00       	mov    $0x0,%edx
  800af9:	b8 01 00 00 00       	mov    $0x1,%eax
  800afe:	89 d1                	mov    %edx,%ecx
  800b00:	89 d3                	mov    %edx,%ebx
  800b02:	89 d7                	mov    %edx,%edi
  800b04:	89 d6                	mov    %edx,%esi
  800b06:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	57                   	push   %edi
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
  800b13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b20:	8b 55 08             	mov    0x8(%ebp),%edx
  800b23:	89 cb                	mov    %ecx,%ebx
  800b25:	89 cf                	mov    %ecx,%edi
  800b27:	89 ce                	mov    %ecx,%esi
  800b29:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	7e 28                	jle    800b57 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b33:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b3a:	00 
  800b3b:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  800b42:	00 
  800b43:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b4a:	00 
  800b4b:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  800b52:	e8 25 0c 00 00       	call   80177c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b57:	83 c4 2c             	add    $0x2c,%esp
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6f:	89 d1                	mov    %edx,%ecx
  800b71:	89 d3                	mov    %edx,%ebx
  800b73:	89 d7                	mov    %edx,%edi
  800b75:	89 d6                	mov    %edx,%esi
  800b77:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_yield>:

void
sys_yield(void)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b84:	ba 00 00 00 00       	mov    $0x0,%edx
  800b89:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b8e:	89 d1                	mov    %edx,%ecx
  800b90:	89 d3                	mov    %edx,%ebx
  800b92:	89 d7                	mov    %edx,%edi
  800b94:	89 d6                	mov    %edx,%esi
  800b96:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	be 00 00 00 00       	mov    $0x0,%esi
  800bab:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	89 f7                	mov    %esi,%edi
  800bbb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	7e 28                	jle    800be9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bcc:	00 
  800bcd:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  800bd4:	00 
  800bd5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bdc:	00 
  800bdd:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  800be4:	e8 93 0b 00 00       	call   80177c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be9:	83 c4 2c             	add    $0x2c,%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	b8 05 00 00 00       	mov    $0x5,%eax
  800bff:	8b 75 18             	mov    0x18(%ebp),%esi
  800c02:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7e 28                	jle    800c3c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c18:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c1f:	00 
  800c20:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  800c27:	00 
  800c28:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c2f:	00 
  800c30:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  800c37:	e8 40 0b 00 00       	call   80177c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c3c:	83 c4 2c             	add    $0x2c,%esp
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c52:	b8 06 00 00 00       	mov    $0x6,%eax
  800c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	89 df                	mov    %ebx,%edi
  800c5f:	89 de                	mov    %ebx,%esi
  800c61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c63:	85 c0                	test   %eax,%eax
  800c65:	7e 28                	jle    800c8f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c72:	00 
  800c73:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  800c7a:	00 
  800c7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c82:	00 
  800c83:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  800c8a:	e8 ed 0a 00 00       	call   80177c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c8f:	83 c4 2c             	add    $0x2c,%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca5:	b8 08 00 00 00       	mov    $0x8,%eax
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	89 df                	mov    %ebx,%edi
  800cb2:	89 de                	mov    %ebx,%esi
  800cb4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	7e 28                	jle    800ce2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cba:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cbe:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cc5:	00 
  800cc6:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  800ccd:	00 
  800cce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd5:	00 
  800cd6:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  800cdd:	e8 9a 0a 00 00       	call   80177c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce2:	83 c4 2c             	add    $0x2c,%esp
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf8:	b8 09 00 00 00       	mov    $0x9,%eax
  800cfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	89 df                	mov    %ebx,%edi
  800d05:	89 de                	mov    %ebx,%esi
  800d07:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	7e 28                	jle    800d35 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d11:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d18:	00 
  800d19:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  800d20:	00 
  800d21:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d28:	00 
  800d29:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  800d30:	e8 47 0a 00 00       	call   80177c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d35:	83 c4 2c             	add    $0x2c,%esp
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d43:	be 00 00 00 00       	mov    $0x0,%esi
  800d48:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d4d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d50:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
  800d66:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d69:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d73:	8b 55 08             	mov    0x8(%ebp),%edx
  800d76:	89 cb                	mov    %ecx,%ebx
  800d78:	89 cf                	mov    %ecx,%edi
  800d7a:	89 ce                	mov    %ecx,%esi
  800d7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	7e 28                	jle    800daa <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d86:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d8d:	00 
  800d8e:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  800d95:	00 
  800d96:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d9d:	00 
  800d9e:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  800da5:	e8 d2 09 00 00       	call   80177c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800daa:	83 c4 2c             	add    $0x2c,%esp
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    

00800db2 <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
  800db8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcb:	89 df                	mov    %ebx,%edi
  800dcd:	89 de                	mov    %ebx,%esi
  800dcf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd1:	85 c0                	test   %eax,%eax
  800dd3:	7e 28                	jle    800dfd <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800de0:	00 
  800de1:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  800de8:	00 
  800de9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df0:	00 
  800df1:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  800df8:	e8 7f 09 00 00       	call   80177c <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800dfd:	83 c4 2c             	add    $0x2c,%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_env_set_debug_upcall>:

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
  800e0b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e13:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1e:	89 df                	mov    %ebx,%edi
  800e20:	89 de                	mov    %ebx,%esi
  800e22:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e24:	85 c0                	test   %eax,%eax
  800e26:	7e 28                	jle    800e50 <sys_env_set_debug_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e28:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2c:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800e33:	00 
  800e34:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  800e3b:	00 
  800e3c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e43:	00 
  800e44:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  800e4b:	e8 2c 09 00 00       	call   80177c <_panic>
}

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_debug_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800e50:	83 c4 2c             	add    $0x2c,%esp
  800e53:	5b                   	pop    %ebx
  800e54:	5e                   	pop    %esi
  800e55:	5f                   	pop    %edi
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    

00800e58 <sys_env_set_nmskint_upcall>:

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	57                   	push   %edi
  800e5c:	56                   	push   %esi
  800e5d:	53                   	push   %ebx
  800e5e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e61:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e66:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e71:	89 df                	mov    %ebx,%edi
  800e73:	89 de                	mov    %ebx,%esi
  800e75:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e77:	85 c0                	test   %eax,%eax
  800e79:	7e 28                	jle    800ea3 <sys_env_set_nmskint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800e86:	00 
  800e87:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  800e8e:	00 
  800e8f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e96:	00 
  800e97:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  800e9e:	e8 d9 08 00 00       	call   80177c <_panic>
}

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_nmskint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800ea3:	83 c4 2c             	add    $0x2c,%esp
  800ea6:	5b                   	pop    %ebx
  800ea7:	5e                   	pop    %esi
  800ea8:	5f                   	pop    %edi
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <sys_env_set_bpoint_upcall>:

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	57                   	push   %edi
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
  800eb1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb9:	b8 10 00 00 00       	mov    $0x10,%eax
  800ebe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec4:	89 df                	mov    %ebx,%edi
  800ec6:	89 de                	mov    %ebx,%esi
  800ec8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	7e 28                	jle    800ef6 <sys_env_set_bpoint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ece:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed2:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800ed9:	00 
  800eda:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  800ee1:	00 
  800ee2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee9:	00 
  800eea:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  800ef1:	e8 86 08 00 00       	call   80177c <_panic>
}

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bpoint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800ef6:	83 c4 2c             	add    $0x2c,%esp
  800ef9:	5b                   	pop    %ebx
  800efa:	5e                   	pop    %esi
  800efb:	5f                   	pop    %edi
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    

00800efe <sys_env_set_oflow_upcall>:

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f0c:	b8 11 00 00 00       	mov    $0x11,%eax
  800f11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f14:	8b 55 08             	mov    0x8(%ebp),%edx
  800f17:	89 df                	mov    %ebx,%edi
  800f19:	89 de                	mov    %ebx,%esi
  800f1b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	7e 28                	jle    800f49 <sys_env_set_oflow_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f21:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f25:	c7 44 24 0c 11 00 00 	movl   $0x11,0xc(%esp)
  800f2c:	00 
  800f2d:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  800f34:	00 
  800f35:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f3c:	00 
  800f3d:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  800f44:	e8 33 08 00 00       	call   80177c <_panic>
}

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_oflow_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800f49:	83 c4 2c             	add    $0x2c,%esp
  800f4c:	5b                   	pop    %ebx
  800f4d:	5e                   	pop    %esi
  800f4e:	5f                   	pop    %edi
  800f4f:	5d                   	pop    %ebp
  800f50:	c3                   	ret    

00800f51 <sys_env_set_bdschk_upcall>:

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	57                   	push   %edi
  800f55:	56                   	push   %esi
  800f56:	53                   	push   %ebx
  800f57:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5f:	b8 12 00 00 00       	mov    $0x12,%eax
  800f64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f67:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6a:	89 df                	mov    %ebx,%edi
  800f6c:	89 de                	mov    %ebx,%esi
  800f6e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f70:	85 c0                	test   %eax,%eax
  800f72:	7e 28                	jle    800f9c <sys_env_set_bdschk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f74:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f78:	c7 44 24 0c 12 00 00 	movl   $0x12,0xc(%esp)
  800f7f:	00 
  800f80:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  800f87:	00 
  800f88:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f8f:	00 
  800f90:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  800f97:	e8 e0 07 00 00       	call   80177c <_panic>
}

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bdschk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800f9c:	83 c4 2c             	add    $0x2c,%esp
  800f9f:	5b                   	pop    %ebx
  800fa0:	5e                   	pop    %esi
  800fa1:	5f                   	pop    %edi
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    

00800fa4 <sys_env_set_illopcd_upcall>:

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	57                   	push   %edi
  800fa8:	56                   	push   %esi
  800fa9:	53                   	push   %ebx
  800faa:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb2:	b8 13 00 00 00       	mov    $0x13,%eax
  800fb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fba:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbd:	89 df                	mov    %ebx,%edi
  800fbf:	89 de                	mov    %ebx,%esi
  800fc1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	7e 28                	jle    800fef <sys_env_set_illopcd_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fcb:	c7 44 24 0c 13 00 00 	movl   $0x13,0xc(%esp)
  800fd2:	00 
  800fd3:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  800fda:	00 
  800fdb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe2:	00 
  800fe3:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  800fea:	e8 8d 07 00 00       	call   80177c <_panic>
}

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_illopcd_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800fef:	83 c4 2c             	add    $0x2c,%esp
  800ff2:	5b                   	pop    %ebx
  800ff3:	5e                   	pop    %esi
  800ff4:	5f                   	pop    %edi
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <sys_env_set_dvcntavl_upcall>:

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	57                   	push   %edi
  800ffb:	56                   	push   %esi
  800ffc:	53                   	push   %ebx
  800ffd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801000:	bb 00 00 00 00       	mov    $0x0,%ebx
  801005:	b8 14 00 00 00       	mov    $0x14,%eax
  80100a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80100d:	8b 55 08             	mov    0x8(%ebp),%edx
  801010:	89 df                	mov    %ebx,%edi
  801012:	89 de                	mov    %ebx,%esi
  801014:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801016:	85 c0                	test   %eax,%eax
  801018:	7e 28                	jle    801042 <sys_env_set_dvcntavl_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80101a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80101e:	c7 44 24 0c 14 00 00 	movl   $0x14,0xc(%esp)
  801025:	00 
  801026:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  80102d:	00 
  80102e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801035:	00 
  801036:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  80103d:	e8 3a 07 00 00       	call   80177c <_panic>
}

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dvcntavl_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801042:	83 c4 2c             	add    $0x2c,%esp
  801045:	5b                   	pop    %ebx
  801046:	5e                   	pop    %esi
  801047:	5f                   	pop    %edi
  801048:	5d                   	pop    %ebp
  801049:	c3                   	ret    

0080104a <sys_env_set_dbfault_upcall>:

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	57                   	push   %edi
  80104e:	56                   	push   %esi
  80104f:	53                   	push   %ebx
  801050:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801053:	bb 00 00 00 00       	mov    $0x0,%ebx
  801058:	b8 15 00 00 00       	mov    $0x15,%eax
  80105d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801060:	8b 55 08             	mov    0x8(%ebp),%edx
  801063:	89 df                	mov    %ebx,%edi
  801065:	89 de                	mov    %ebx,%esi
  801067:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801069:	85 c0                	test   %eax,%eax
  80106b:	7e 28                	jle    801095 <sys_env_set_dbfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80106d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801071:	c7 44 24 0c 15 00 00 	movl   $0x15,0xc(%esp)
  801078:	00 
  801079:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  801080:	00 
  801081:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801088:	00 
  801089:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  801090:	e8 e7 06 00 00       	call   80177c <_panic>
}

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dbfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801095:	83 c4 2c             	add    $0x2c,%esp
  801098:	5b                   	pop    %ebx
  801099:	5e                   	pop    %esi
  80109a:	5f                   	pop    %edi
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    

0080109d <sys_env_set_ivldtss_upcall>:

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	57                   	push   %edi
  8010a1:	56                   	push   %esi
  8010a2:	53                   	push   %ebx
  8010a3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ab:	b8 16 00 00 00       	mov    $0x16,%eax
  8010b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b6:	89 df                	mov    %ebx,%edi
  8010b8:	89 de                	mov    %ebx,%esi
  8010ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	7e 28                	jle    8010e8 <sys_env_set_ivldtss_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c4:	c7 44 24 0c 16 00 00 	movl   $0x16,0xc(%esp)
  8010cb:	00 
  8010cc:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  8010d3:	00 
  8010d4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010db:	00 
  8010dc:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  8010e3:	e8 94 06 00 00       	call   80177c <_panic>
}

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_ivldtss_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8010e8:	83 c4 2c             	add    $0x2c,%esp
  8010eb:	5b                   	pop    %ebx
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <sys_env_set_segntprst_upcall>:

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	57                   	push   %edi
  8010f4:	56                   	push   %esi
  8010f5:	53                   	push   %ebx
  8010f6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010fe:	b8 17 00 00 00       	mov    $0x17,%eax
  801103:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801106:	8b 55 08             	mov    0x8(%ebp),%edx
  801109:	89 df                	mov    %ebx,%edi
  80110b:	89 de                	mov    %ebx,%esi
  80110d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80110f:	85 c0                	test   %eax,%eax
  801111:	7e 28                	jle    80113b <sys_env_set_segntprst_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801113:	89 44 24 10          	mov    %eax,0x10(%esp)
  801117:	c7 44 24 0c 17 00 00 	movl   $0x17,0xc(%esp)
  80111e:	00 
  80111f:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  801126:	00 
  801127:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80112e:	00 
  80112f:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  801136:	e8 41 06 00 00       	call   80177c <_panic>
}

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_segntprst_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80113b:	83 c4 2c             	add    $0x2c,%esp
  80113e:	5b                   	pop    %ebx
  80113f:	5e                   	pop    %esi
  801140:	5f                   	pop    %edi
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <sys_env_set_stkexception_upcall>:

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	57                   	push   %edi
  801147:	56                   	push   %esi
  801148:	53                   	push   %ebx
  801149:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80114c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801151:	b8 18 00 00 00       	mov    $0x18,%eax
  801156:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801159:	8b 55 08             	mov    0x8(%ebp),%edx
  80115c:	89 df                	mov    %ebx,%edi
  80115e:	89 de                	mov    %ebx,%esi
  801160:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801162:	85 c0                	test   %eax,%eax
  801164:	7e 28                	jle    80118e <sys_env_set_stkexception_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801166:	89 44 24 10          	mov    %eax,0x10(%esp)
  80116a:	c7 44 24 0c 18 00 00 	movl   $0x18,0xc(%esp)
  801171:	00 
  801172:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  801179:	00 
  80117a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801181:	00 
  801182:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  801189:	e8 ee 05 00 00       	call   80177c <_panic>
}

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_stkexception_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80118e:	83 c4 2c             	add    $0x2c,%esp
  801191:	5b                   	pop    %ebx
  801192:	5e                   	pop    %esi
  801193:	5f                   	pop    %edi
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    

00801196 <sys_env_set_gpfault_upcall>:

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	57                   	push   %edi
  80119a:	56                   	push   %esi
  80119b:	53                   	push   %ebx
  80119c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80119f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a4:	b8 19 00 00 00       	mov    $0x19,%eax
  8011a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8011af:	89 df                	mov    %ebx,%edi
  8011b1:	89 de                	mov    %ebx,%esi
  8011b3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	7e 28                	jle    8011e1 <sys_env_set_gpfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011bd:	c7 44 24 0c 19 00 00 	movl   $0x19,0xc(%esp)
  8011c4:	00 
  8011c5:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  8011cc:	00 
  8011cd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011d4:	00 
  8011d5:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  8011dc:	e8 9b 05 00 00       	call   80177c <_panic>
}

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_gpfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8011e1:	83 c4 2c             	add    $0x2c,%esp
  8011e4:	5b                   	pop    %ebx
  8011e5:	5e                   	pop    %esi
  8011e6:	5f                   	pop    %edi
  8011e7:	5d                   	pop    %ebp
  8011e8:	c3                   	ret    

008011e9 <sys_env_set_fperror_upcall>:

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	57                   	push   %edi
  8011ed:	56                   	push   %esi
  8011ee:	53                   	push   %ebx
  8011ef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011f7:	b8 1a 00 00 00       	mov    $0x1a,%eax
  8011fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801202:	89 df                	mov    %ebx,%edi
  801204:	89 de                	mov    %ebx,%esi
  801206:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801208:	85 c0                	test   %eax,%eax
  80120a:	7e 28                	jle    801234 <sys_env_set_fperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80120c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801210:	c7 44 24 0c 1a 00 00 	movl   $0x1a,0xc(%esp)
  801217:	00 
  801218:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  80121f:	00 
  801220:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801227:	00 
  801228:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  80122f:	e8 48 05 00 00       	call   80177c <_panic>
}

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_fperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801234:	83 c4 2c             	add    $0x2c,%esp
  801237:	5b                   	pop    %ebx
  801238:	5e                   	pop    %esi
  801239:	5f                   	pop    %edi
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    

0080123c <sys_env_set_algchk_upcall>:

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	57                   	push   %edi
  801240:	56                   	push   %esi
  801241:	53                   	push   %ebx
  801242:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801245:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124a:	b8 1b 00 00 00       	mov    $0x1b,%eax
  80124f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801252:	8b 55 08             	mov    0x8(%ebp),%edx
  801255:	89 df                	mov    %ebx,%edi
  801257:	89 de                	mov    %ebx,%esi
  801259:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80125b:	85 c0                	test   %eax,%eax
  80125d:	7e 28                	jle    801287 <sys_env_set_algchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80125f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801263:	c7 44 24 0c 1b 00 00 	movl   $0x1b,0xc(%esp)
  80126a:	00 
  80126b:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  801272:	00 
  801273:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80127a:	00 
  80127b:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  801282:	e8 f5 04 00 00       	call   80177c <_panic>
}

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_algchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801287:	83 c4 2c             	add    $0x2c,%esp
  80128a:	5b                   	pop    %ebx
  80128b:	5e                   	pop    %esi
  80128c:	5f                   	pop    %edi
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <sys_env_set_mchchk_upcall>:

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	57                   	push   %edi
  801293:	56                   	push   %esi
  801294:	53                   	push   %ebx
  801295:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801298:	bb 00 00 00 00       	mov    $0x0,%ebx
  80129d:	b8 1c 00 00 00       	mov    $0x1c,%eax
  8012a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a8:	89 df                	mov    %ebx,%edi
  8012aa:	89 de                	mov    %ebx,%esi
  8012ac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	7e 28                	jle    8012da <sys_env_set_mchchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012b6:	c7 44 24 0c 1c 00 00 	movl   $0x1c,0xc(%esp)
  8012bd:	00 
  8012be:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  8012c5:	00 
  8012c6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012cd:	00 
  8012ce:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  8012d5:	e8 a2 04 00 00       	call   80177c <_panic>
}

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_mchchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8012da:	83 c4 2c             	add    $0x2c,%esp
  8012dd:	5b                   	pop    %ebx
  8012de:	5e                   	pop    %esi
  8012df:	5f                   	pop    %edi
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <sys_env_set_SIMDfperror_upcall>:

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	57                   	push   %edi
  8012e6:	56                   	push   %esi
  8012e7:	53                   	push   %ebx
  8012e8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012f0:	b8 1d 00 00 00       	mov    $0x1d,%eax
  8012f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8012fb:	89 df                	mov    %ebx,%edi
  8012fd:	89 de                	mov    %ebx,%esi
  8012ff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801301:	85 c0                	test   %eax,%eax
  801303:	7e 28                	jle    80132d <sys_env_set_SIMDfperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801305:	89 44 24 10          	mov    %eax,0x10(%esp)
  801309:	c7 44 24 0c 1d 00 00 	movl   $0x1d,0xc(%esp)
  801310:	00 
  801311:	c7 44 24 08 68 1d 80 	movl   $0x801d68,0x8(%esp)
  801318:	00 
  801319:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801320:	00 
  801321:	c7 04 24 85 1d 80 00 	movl   $0x801d85,(%esp)
  801328:	e8 4f 04 00 00       	call   80177c <_panic>
}

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_SIMDfperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80132d:	83 c4 2c             	add    $0x2c,%esp
  801330:	5b                   	pop    %ebx
  801331:	5e                   	pop    %esi
  801332:	5f                   	pop    %edi
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    
  801335:	00 00                	add    %al,(%eax)
	...

00801338 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	53                   	push   %ebx
  80133c:	83 ec 24             	sub    $0x24,%esp
  80133f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801342:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  801344:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801348:	74 2d                	je     801377 <pgfault+0x3f>
  80134a:	89 d8                	mov    %ebx,%eax
  80134c:	c1 e8 16             	shr    $0x16,%eax
  80134f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801356:	a8 01                	test   $0x1,%al
  801358:	74 1d                	je     801377 <pgfault+0x3f>
		(uvpt[PGNUM(addr)] & PTE_P) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  80135a:	89 d8                	mov    %ebx,%eax
  80135c:	c1 e8 0c             	shr    $0xc,%eax
  80135f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  801366:	f6 c2 01             	test   $0x1,%dl
  801369:	74 0c                	je     801377 <pgfault+0x3f>
		(uvpt[PGNUM(addr)] & PTE_P) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  80136b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801372:	f6 c4 08             	test   $0x8,%ah
  801375:	75 1c                	jne    801393 <pgfault+0x5b>
		panic("pgfault: not a write or a copy on write page fault!");
  801377:	c7 44 24 08 94 1d 80 	movl   $0x801d94,0x8(%esp)
  80137e:	00 
  80137f:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801386:	00 
  801387:	c7 04 24 c8 1d 80 00 	movl   $0x801dc8,(%esp)
  80138e:	e8 e9 03 00 00       	call   80177c <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	// we need to make addr page-aligned
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)) < 0)
  801393:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80139a:	00 
  80139b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8013a2:	00 
  8013a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013aa:	e8 ee f7 ff ff       	call   800b9d <sys_page_alloc>
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	79 20                	jns    8013d3 <pgfault+0x9b>
		panic("pgfault: sys_page_alloc: %e", r);
  8013b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013b7:	c7 44 24 08 d3 1d 80 	movl   $0x801dd3,0x8(%esp)
  8013be:	00 
  8013bf:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8013c6:	00 
  8013c7:	c7 04 24 c8 1d 80 00 	movl   $0x801dc8,(%esp)
  8013ce:	e8 a9 03 00 00       	call   80177c <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// we need to make addr page-aligned
	addr = ROUNDDOWN(addr, PGSIZE);
  8013d3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)) < 0)
		panic("pgfault: sys_page_alloc: %e", r);
	memcpy(PFTEMP, addr, PGSIZE);
  8013d9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8013e0:	00 
  8013e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013e5:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8013ec:	e8 9d f5 ff ff       	call   80098e <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P)) < 0)
  8013f1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8013f8:	00 
  8013f9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8013fd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801404:	00 
  801405:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80140c:	00 
  80140d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801414:	e8 d8 f7 ff ff       	call   800bf1 <sys_page_map>
  801419:	85 c0                	test   %eax,%eax
  80141b:	79 20                	jns    80143d <pgfault+0x105>
		panic("pgfault: sys_page_map: %e", r);
  80141d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801421:	c7 44 24 08 ef 1d 80 	movl   $0x801def,0x8(%esp)
  801428:	00 
  801429:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801430:	00 
  801431:	c7 04 24 c8 1d 80 00 	movl   $0x801dc8,(%esp)
  801438:	e8 3f 03 00 00       	call   80177c <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  80143d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801444:	00 
  801445:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80144c:	e8 f3 f7 ff ff       	call   800c44 <sys_page_unmap>
  801451:	85 c0                	test   %eax,%eax
  801453:	79 20                	jns    801475 <pgfault+0x13d>
		panic("pgfault: sys_page_unmap: %e", r);
  801455:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801459:	c7 44 24 08 09 1e 80 	movl   $0x801e09,0x8(%esp)
  801460:	00 
  801461:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801468:	00 
  801469:	c7 04 24 c8 1d 80 00 	movl   $0x801dc8,(%esp)
  801470:	e8 07 03 00 00       	call   80177c <_panic>
}
  801475:	83 c4 24             	add    $0x24,%esp
  801478:	5b                   	pop    %ebx
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    

0080147b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	57                   	push   %edi
  80147f:	56                   	push   %esi
  801480:	53                   	push   %ebx
  801481:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801484:	c7 04 24 38 13 80 00 	movl   $0x801338,(%esp)
  80148b:	e8 44 03 00 00       	call   8017d4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801490:	ba 07 00 00 00       	mov    $0x7,%edx
  801495:	89 d0                	mov    %edx,%eax
  801497:	cd 30                	int    $0x30
  801499:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80149c:	89 c7                	mov    %eax,%edi
	envid_t envid;
	uint8_t *addr;
	int r;
	extern unsigned char end[];
	envid = sys_exofork();
	if (envid < 0)
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	79 20                	jns    8014c2 <fork+0x47>
		panic("sys_exofork: %e", envid);
  8014a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014a6:	c7 44 24 08 25 1e 80 	movl   $0x801e25,0x8(%esp)
  8014ad:	00 
  8014ae:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  8014b5:	00 
  8014b6:	c7 04 24 c8 1d 80 00 	movl   $0x801dc8,(%esp)
  8014bd:	e8 ba 02 00 00       	call   80177c <_panic>
	if (envid == 0) {
  8014c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8014c6:	75 27                	jne    8014ef <fork+0x74>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8014c8:	e8 92 f6 ff ff       	call   800b5f <sys_getenvid>
  8014cd:	25 ff 03 00 00       	and    $0x3ff,%eax
  8014d2:	8d 04 40             	lea    (%eax,%eax,2),%eax
  8014d5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8014d8:	c1 e0 04             	shl    $0x4,%eax
  8014db:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8014e0:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  8014e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ea:	e9 23 01 00 00       	jmp    801612 <fork+0x197>
	int r;
	extern unsigned char end[];
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8014ef:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	}

	// We're the parent.
	for (addr = 0; addr < (uint8_t *)USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  8014f4:	89 d8                	mov    %ebx,%eax
  8014f6:	c1 e8 16             	shr    $0x16,%eax
  8014f9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801500:	a8 01                	test   $0x1,%al
  801502:	0f 84 ac 00 00 00    	je     8015b4 <fork+0x139>
  801508:	89 d8                	mov    %ebx,%eax
  80150a:	c1 e8 0c             	shr    $0xc,%eax
  80150d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801514:	f6 c2 01             	test   $0x1,%dl
  801517:	0f 84 97 00 00 00    	je     8015b4 <fork+0x139>
			&& (uvpt[PGNUM(addr)] & PTE_U))
  80151d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801524:	f6 c2 04             	test   $0x4,%dl
  801527:	0f 84 87 00 00 00    	je     8015b4 <fork+0x139>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	void *va = (void *)(pn * PGSIZE);
  80152d:	89 c6                	mov    %eax,%esi
  80152f:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  801532:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801539:	f6 c2 02             	test   $0x2,%dl
  80153c:	75 0c                	jne    80154a <fork+0xcf>
  80153e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801545:	f6 c4 08             	test   $0x8,%ah
  801548:	74 4a                	je     801594 <fork+0x119>
		if ((r = sys_page_map(0, va, envid, va, PTE_COW|PTE_U|PTE_P)) < 0)
  80154a:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801551:	00 
  801552:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801556:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80155a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80155e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801565:	e8 87 f6 ff ff       	call   800bf1 <sys_page_map>
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 46                	js     8015b4 <fork+0x139>
			return r;
		if ((r = sys_page_map(0, va, 0, va, PTE_COW|PTE_U|PTE_P)) < 0)
  80156e:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801575:	00 
  801576:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80157a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801581:	00 
  801582:	89 74 24 04          	mov    %esi,0x4(%esp)
  801586:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80158d:	e8 5f f6 ff ff       	call   800bf1 <sys_page_map>
  801592:	eb 20                	jmp    8015b4 <fork+0x139>
			return r;
	}
	else {
		if ((r = sys_page_map(0, va, envid, va, PTE_U|PTE_P)) < 0)
  801594:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80159b:	00 
  80159c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015a0:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8015a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015af:	e8 3d f6 ff ff       	call   800bf1 <sys_page_map>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	// We're the parent.
	for (addr = 0; addr < (uint8_t *)USTACKTOP; addr += PGSIZE)
  8015b4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8015ba:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8015c0:	0f 85 2e ff ff ff    	jne    8014f4 <fork+0x79>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
			&& (uvpt[PGNUM(addr)] & PTE_U))
			duppage(envid, PGNUM(addr));

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  8015c6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015cd:	00 
  8015ce:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8015d5:	ee 
  8015d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015d9:	89 04 24             	mov    %eax,(%esp)
  8015dc:	e8 bc f5 ff ff       	call   800b9d <sys_page_alloc>
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	78 2d                	js     801612 <fork+0x197>
		return r;
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8015e5:	c7 44 24 04 68 18 80 	movl   $0x801868,0x4(%esp)
  8015ec:	00 
  8015ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015f0:	89 04 24             	mov    %eax,(%esp)
  8015f3:	e8 f2 f6 ff ff       	call   800cea <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8015f8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8015ff:	00 
  801600:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801603:	89 04 24             	mov    %eax,(%esp)
  801606:	e8 8c f6 ff ff       	call   800c97 <sys_env_set_status>
  80160b:	85 c0                	test   %eax,%eax
  80160d:	78 03                	js     801612 <fork+0x197>
		return r;

	return envid;
  80160f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801612:	83 c4 3c             	add    $0x3c,%esp
  801615:	5b                   	pop    %ebx
  801616:	5e                   	pop    %esi
  801617:	5f                   	pop    %edi
  801618:	5d                   	pop    %ebp
  801619:	c3                   	ret    

0080161a <sfork>:

// Challenge!
int
sfork(void)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801620:	c7 44 24 08 35 1e 80 	movl   $0x801e35,0x8(%esp)
  801627:	00 
  801628:	c7 44 24 04 8d 00 00 	movl   $0x8d,0x4(%esp)
  80162f:	00 
  801630:	c7 04 24 c8 1d 80 00 	movl   $0x801dc8,(%esp)
  801637:	e8 40 01 00 00       	call   80177c <_panic>

0080163c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	56                   	push   %esi
  801640:	53                   	push   %ebx
  801641:	83 ec 10             	sub    $0x10,%esp
  801644:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801647:	8b 45 0c             	mov    0xc(%ebp),%eax
  80164a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	// -1 must be an invalid address.
	if (!pg) pg = (void *)-1;
  80164d:	85 c0                	test   %eax,%eax
  80164f:	75 05                	jne    801656 <ipc_recv+0x1a>
  801651:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	if ((r = sys_ipc_recv(pg)) < 0) {
  801656:	89 04 24             	mov    %eax,(%esp)
  801659:	e8 02 f7 ff ff       	call   800d60 <sys_ipc_recv>
  80165e:	85 c0                	test   %eax,%eax
  801660:	79 16                	jns    801678 <ipc_recv+0x3c>
		if (from_env_store) *from_env_store = 0;
  801662:	85 db                	test   %ebx,%ebx
  801664:	74 06                	je     80166c <ipc_recv+0x30>
  801666:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  80166c:	85 f6                	test   %esi,%esi
  80166e:	74 35                	je     8016a5 <ipc_recv+0x69>
  801670:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801676:	eb 2d                	jmp    8016a5 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801678:	85 db                	test   %ebx,%ebx
  80167a:	74 0d                	je     801689 <ipc_recv+0x4d>
  80167c:	a1 08 20 80 00       	mov    0x802008,%eax
  801681:	8b 80 b8 00 00 00    	mov    0xb8(%eax),%eax
  801687:	89 03                	mov    %eax,(%ebx)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801689:	85 f6                	test   %esi,%esi
  80168b:	74 0d                	je     80169a <ipc_recv+0x5e>
  80168d:	a1 08 20 80 00       	mov    0x802008,%eax
  801692:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  801698:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  80169a:	a1 08 20 80 00       	mov    0x802008,%eax
  80169f:	8b 80 b4 00 00 00    	mov    0xb4(%eax),%eax
}
  8016a5:	83 c4 10             	add    $0x10,%esp
  8016a8:	5b                   	pop    %ebx
  8016a9:	5e                   	pop    %esi
  8016aa:	5d                   	pop    %ebp
  8016ab:	c3                   	ret    

008016ac <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	57                   	push   %edi
  8016b0:	56                   	push   %esi
  8016b1:	53                   	push   %ebx
  8016b2:	83 ec 1c             	sub    $0x1c,%esp
  8016b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8016b8:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	int retry_times = 0;
	if (!pg) pg = (void *)-1;
  8016bb:	85 db                	test   %ebx,%ebx
  8016bd:	75 05                	jne    8016c4 <ipc_send+0x18>
  8016bf:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8016c4:	be 03 00 00 00       	mov    $0x3,%esi
  8016c9:	eb 49                	jmp    801714 <ipc_send+0x68>
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  8016cb:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8016ce:	74 20                	je     8016f0 <ipc_send+0x44>
			panic("ipc_send: %e", r);
  8016d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016d4:	c7 44 24 08 4b 1e 80 	movl   $0x801e4b,0x8(%esp)
  8016db:	00 
  8016dc:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  8016e3:	00 
  8016e4:	c7 04 24 58 1e 80 00 	movl   $0x801e58,(%esp)
  8016eb:	e8 8c 00 00 00       	call   80177c <_panic>
		retry_times++;
		if (retry_times > 2) panic("Retry times out!");
  8016f0:	4e                   	dec    %esi
  8016f1:	75 1c                	jne    80170f <ipc_send+0x63>
  8016f3:	c7 44 24 08 62 1e 80 	movl   $0x801e62,0x8(%esp)
  8016fa:	00 
  8016fb:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801702:	00 
  801703:	c7 04 24 58 1e 80 00 	movl   $0x801e58,(%esp)
  80170a:	e8 6d 00 00 00       	call   80177c <_panic>
		sys_yield();
  80170f:	e8 6a f4 ff ff       	call   800b7e <sys_yield>
{
	// LAB 4: Your code here.
	int r;
	int retry_times = 0;
	if (!pg) pg = (void *)-1;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801714:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801718:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80171c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80171f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801723:	8b 45 08             	mov    0x8(%ebp),%eax
  801726:	89 04 24             	mov    %eax,(%esp)
  801729:	e8 0f f6 ff ff       	call   800d3d <sys_ipc_try_send>
  80172e:	85 c0                	test   %eax,%eax
  801730:	78 99                	js     8016cb <ipc_send+0x1f>
			panic("ipc_send: %e", r);
		retry_times++;
		if (retry_times > 2) panic("Retry times out!");
		sys_yield();
	}
}
  801732:	83 c4 1c             	add    $0x1c,%esp
  801735:	5b                   	pop    %ebx
  801736:	5e                   	pop    %esi
  801737:	5f                   	pop    %edi
  801738:	5d                   	pop    %ebp
  801739:	c3                   	ret    

0080173a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801740:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801745:	8d 14 40             	lea    (%eax,%eax,2),%edx
  801748:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80174b:	c1 e2 04             	shl    $0x4,%edx
  80174e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801754:	8b 52 50             	mov    0x50(%edx),%edx
  801757:	39 ca                	cmp    %ecx,%edx
  801759:	75 13                	jne    80176e <ipc_find_env+0x34>
			return envs[i].env_id;
  80175b:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80175e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801761:	c1 e0 04             	shl    $0x4,%eax
  801764:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801769:	8b 40 40             	mov    0x40(%eax),%eax
  80176c:	eb 0c                	jmp    80177a <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80176e:	40                   	inc    %eax
  80176f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801774:	75 cf                	jne    801745 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801776:	66 b8 00 00          	mov    $0x0,%ax
}
  80177a:	5d                   	pop    %ebp
  80177b:	c3                   	ret    

0080177c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	56                   	push   %esi
  801780:	53                   	push   %ebx
  801781:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801784:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801787:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80178d:	e8 cd f3 ff ff       	call   800b5f <sys_getenvid>
  801792:	8b 55 0c             	mov    0xc(%ebp),%edx
  801795:	89 54 24 10          	mov    %edx,0x10(%esp)
  801799:	8b 55 08             	mov    0x8(%ebp),%edx
  80179c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8017a0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a8:	c7 04 24 74 1e 80 00 	movl   $0x801e74,(%esp)
  8017af:	e8 48 ea ff ff       	call   8001fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8017b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8017bb:	89 04 24             	mov    %eax,(%esp)
  8017be:	e8 d8 e9 ff ff       	call   80019b <vcprintf>
	cprintf("\n");
  8017c3:	c7 04 24 07 1b 80 00 	movl   $0x801b07,(%esp)
  8017ca:	e8 2d ea ff ff       	call   8001fc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8017cf:	cc                   	int3   
  8017d0:	eb fd                	jmp    8017cf <_panic+0x53>
	...

008017d4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8017da:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8017e1:	75 40                	jne    801823 <set_pgfault_handler+0x4f>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
  8017e3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8017ea:	00 
  8017eb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8017f2:	ee 
  8017f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017fa:	e8 9e f3 ff ff       	call   800b9d <sys_page_alloc>
  8017ff:	85 c0                	test   %eax,%eax
  801801:	79 20                	jns    801823 <set_pgfault_handler+0x4f>
            panic("set_pgfault_handler: sys_page_alloc: %e", r);
  801803:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801807:	c7 44 24 08 98 1e 80 	movl   $0x801e98,0x8(%esp)
  80180e:	00 
  80180f:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801816:	00 
  801817:	c7 04 24 f4 1e 80 00 	movl   $0x801ef4,(%esp)
  80181e:	e8 59 ff ff ff       	call   80177c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801823:	8b 45 08             	mov    0x8(%ebp),%eax
  801826:	a3 0c 20 80 00       	mov    %eax,0x80200c
    if ((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0 )
  80182b:	c7 44 24 04 68 18 80 	movl   $0x801868,0x4(%esp)
  801832:	00 
  801833:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80183a:	e8 ab f4 ff ff       	call   800cea <sys_env_set_pgfault_upcall>
  80183f:	85 c0                	test   %eax,%eax
  801841:	79 20                	jns    801863 <set_pgfault_handler+0x8f>
        panic("set_pgfault_handler: sys_env_set_pgfault_upcall: %e", r);
  801843:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801847:	c7 44 24 08 c0 1e 80 	movl   $0x801ec0,0x8(%esp)
  80184e:	00 
  80184f:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  801856:	00 
  801857:	c7 04 24 f4 1e 80 00 	movl   $0x801ef4,(%esp)
  80185e:	e8 19 ff ff ff       	call   80177c <_panic>
}
  801863:	c9                   	leave  
  801864:	c3                   	ret    
  801865:	00 00                	add    %al,(%eax)
	...

00801868 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801868:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801869:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80186e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801870:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// sub 4 from old esp
	movl 0x30(%esp), %eax
  801873:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801877:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80187a:	89 44 24 30          	mov    %eax,0x30(%esp)
	// put old eip into the pre-reserved 4-byte space
	movl 0x28(%esp), %ebx
  80187e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801882:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  801884:	83 c4 08             	add    $0x8,%esp
	popal
  801887:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  801888:	83 c4 04             	add    $0x4,%esp
	popfl
  80188b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80188c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80188d:	c3                   	ret    
	...

00801890 <__udivdi3>:
  801890:	55                   	push   %ebp
  801891:	57                   	push   %edi
  801892:	56                   	push   %esi
  801893:	83 ec 10             	sub    $0x10,%esp
  801896:	8b 74 24 20          	mov    0x20(%esp),%esi
  80189a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80189e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018a2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8018a6:	89 cd                	mov    %ecx,%ebp
  8018a8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8018ac:	85 c0                	test   %eax,%eax
  8018ae:	75 2c                	jne    8018dc <__udivdi3+0x4c>
  8018b0:	39 f9                	cmp    %edi,%ecx
  8018b2:	77 68                	ja     80191c <__udivdi3+0x8c>
  8018b4:	85 c9                	test   %ecx,%ecx
  8018b6:	75 0b                	jne    8018c3 <__udivdi3+0x33>
  8018b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8018bd:	31 d2                	xor    %edx,%edx
  8018bf:	f7 f1                	div    %ecx
  8018c1:	89 c1                	mov    %eax,%ecx
  8018c3:	31 d2                	xor    %edx,%edx
  8018c5:	89 f8                	mov    %edi,%eax
  8018c7:	f7 f1                	div    %ecx
  8018c9:	89 c7                	mov    %eax,%edi
  8018cb:	89 f0                	mov    %esi,%eax
  8018cd:	f7 f1                	div    %ecx
  8018cf:	89 c6                	mov    %eax,%esi
  8018d1:	89 f0                	mov    %esi,%eax
  8018d3:	89 fa                	mov    %edi,%edx
  8018d5:	83 c4 10             	add    $0x10,%esp
  8018d8:	5e                   	pop    %esi
  8018d9:	5f                   	pop    %edi
  8018da:	5d                   	pop    %ebp
  8018db:	c3                   	ret    
  8018dc:	39 f8                	cmp    %edi,%eax
  8018de:	77 2c                	ja     80190c <__udivdi3+0x7c>
  8018e0:	0f bd f0             	bsr    %eax,%esi
  8018e3:	83 f6 1f             	xor    $0x1f,%esi
  8018e6:	75 4c                	jne    801934 <__udivdi3+0xa4>
  8018e8:	39 f8                	cmp    %edi,%eax
  8018ea:	bf 00 00 00 00       	mov    $0x0,%edi
  8018ef:	72 0a                	jb     8018fb <__udivdi3+0x6b>
  8018f1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8018f5:	0f 87 ad 00 00 00    	ja     8019a8 <__udivdi3+0x118>
  8018fb:	be 01 00 00 00       	mov    $0x1,%esi
  801900:	89 f0                	mov    %esi,%eax
  801902:	89 fa                	mov    %edi,%edx
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	5e                   	pop    %esi
  801908:	5f                   	pop    %edi
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    
  80190b:	90                   	nop
  80190c:	31 ff                	xor    %edi,%edi
  80190e:	31 f6                	xor    %esi,%esi
  801910:	89 f0                	mov    %esi,%eax
  801912:	89 fa                	mov    %edi,%edx
  801914:	83 c4 10             	add    $0x10,%esp
  801917:	5e                   	pop    %esi
  801918:	5f                   	pop    %edi
  801919:	5d                   	pop    %ebp
  80191a:	c3                   	ret    
  80191b:	90                   	nop
  80191c:	89 fa                	mov    %edi,%edx
  80191e:	89 f0                	mov    %esi,%eax
  801920:	f7 f1                	div    %ecx
  801922:	89 c6                	mov    %eax,%esi
  801924:	31 ff                	xor    %edi,%edi
  801926:	89 f0                	mov    %esi,%eax
  801928:	89 fa                	mov    %edi,%edx
  80192a:	83 c4 10             	add    $0x10,%esp
  80192d:	5e                   	pop    %esi
  80192e:	5f                   	pop    %edi
  80192f:	5d                   	pop    %ebp
  801930:	c3                   	ret    
  801931:	8d 76 00             	lea    0x0(%esi),%esi
  801934:	89 f1                	mov    %esi,%ecx
  801936:	d3 e0                	shl    %cl,%eax
  801938:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80193c:	b8 20 00 00 00       	mov    $0x20,%eax
  801941:	29 f0                	sub    %esi,%eax
  801943:	89 ea                	mov    %ebp,%edx
  801945:	88 c1                	mov    %al,%cl
  801947:	d3 ea                	shr    %cl,%edx
  801949:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80194d:	09 ca                	or     %ecx,%edx
  80194f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801953:	89 f1                	mov    %esi,%ecx
  801955:	d3 e5                	shl    %cl,%ebp
  801957:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80195b:	89 fd                	mov    %edi,%ebp
  80195d:	88 c1                	mov    %al,%cl
  80195f:	d3 ed                	shr    %cl,%ebp
  801961:	89 fa                	mov    %edi,%edx
  801963:	89 f1                	mov    %esi,%ecx
  801965:	d3 e2                	shl    %cl,%edx
  801967:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80196b:	88 c1                	mov    %al,%cl
  80196d:	d3 ef                	shr    %cl,%edi
  80196f:	09 d7                	or     %edx,%edi
  801971:	89 f8                	mov    %edi,%eax
  801973:	89 ea                	mov    %ebp,%edx
  801975:	f7 74 24 08          	divl   0x8(%esp)
  801979:	89 d1                	mov    %edx,%ecx
  80197b:	89 c7                	mov    %eax,%edi
  80197d:	f7 64 24 0c          	mull   0xc(%esp)
  801981:	39 d1                	cmp    %edx,%ecx
  801983:	72 17                	jb     80199c <__udivdi3+0x10c>
  801985:	74 09                	je     801990 <__udivdi3+0x100>
  801987:	89 fe                	mov    %edi,%esi
  801989:	31 ff                	xor    %edi,%edi
  80198b:	e9 41 ff ff ff       	jmp    8018d1 <__udivdi3+0x41>
  801990:	8b 54 24 04          	mov    0x4(%esp),%edx
  801994:	89 f1                	mov    %esi,%ecx
  801996:	d3 e2                	shl    %cl,%edx
  801998:	39 c2                	cmp    %eax,%edx
  80199a:	73 eb                	jae    801987 <__udivdi3+0xf7>
  80199c:	8d 77 ff             	lea    -0x1(%edi),%esi
  80199f:	31 ff                	xor    %edi,%edi
  8019a1:	e9 2b ff ff ff       	jmp    8018d1 <__udivdi3+0x41>
  8019a6:	66 90                	xchg   %ax,%ax
  8019a8:	31 f6                	xor    %esi,%esi
  8019aa:	e9 22 ff ff ff       	jmp    8018d1 <__udivdi3+0x41>
	...

008019b0 <__umoddi3>:
  8019b0:	55                   	push   %ebp
  8019b1:	57                   	push   %edi
  8019b2:	56                   	push   %esi
  8019b3:	83 ec 20             	sub    $0x20,%esp
  8019b6:	8b 44 24 30          	mov    0x30(%esp),%eax
  8019ba:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8019be:	89 44 24 14          	mov    %eax,0x14(%esp)
  8019c2:	8b 74 24 34          	mov    0x34(%esp),%esi
  8019c6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8019ca:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8019ce:	89 c7                	mov    %eax,%edi
  8019d0:	89 f2                	mov    %esi,%edx
  8019d2:	85 ed                	test   %ebp,%ebp
  8019d4:	75 16                	jne    8019ec <__umoddi3+0x3c>
  8019d6:	39 f1                	cmp    %esi,%ecx
  8019d8:	0f 86 a6 00 00 00    	jbe    801a84 <__umoddi3+0xd4>
  8019de:	f7 f1                	div    %ecx
  8019e0:	89 d0                	mov    %edx,%eax
  8019e2:	31 d2                	xor    %edx,%edx
  8019e4:	83 c4 20             	add    $0x20,%esp
  8019e7:	5e                   	pop    %esi
  8019e8:	5f                   	pop    %edi
  8019e9:	5d                   	pop    %ebp
  8019ea:	c3                   	ret    
  8019eb:	90                   	nop
  8019ec:	39 f5                	cmp    %esi,%ebp
  8019ee:	0f 87 ac 00 00 00    	ja     801aa0 <__umoddi3+0xf0>
  8019f4:	0f bd c5             	bsr    %ebp,%eax
  8019f7:	83 f0 1f             	xor    $0x1f,%eax
  8019fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8019fe:	0f 84 a8 00 00 00    	je     801aac <__umoddi3+0xfc>
  801a04:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801a08:	d3 e5                	shl    %cl,%ebp
  801a0a:	bf 20 00 00 00       	mov    $0x20,%edi
  801a0f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801a13:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801a17:	89 f9                	mov    %edi,%ecx
  801a19:	d3 e8                	shr    %cl,%eax
  801a1b:	09 e8                	or     %ebp,%eax
  801a1d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801a21:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801a25:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801a29:	d3 e0                	shl    %cl,%eax
  801a2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a2f:	89 f2                	mov    %esi,%edx
  801a31:	d3 e2                	shl    %cl,%edx
  801a33:	8b 44 24 14          	mov    0x14(%esp),%eax
  801a37:	d3 e0                	shl    %cl,%eax
  801a39:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801a3d:	8b 44 24 14          	mov    0x14(%esp),%eax
  801a41:	89 f9                	mov    %edi,%ecx
  801a43:	d3 e8                	shr    %cl,%eax
  801a45:	09 d0                	or     %edx,%eax
  801a47:	d3 ee                	shr    %cl,%esi
  801a49:	89 f2                	mov    %esi,%edx
  801a4b:	f7 74 24 18          	divl   0x18(%esp)
  801a4f:	89 d6                	mov    %edx,%esi
  801a51:	f7 64 24 0c          	mull   0xc(%esp)
  801a55:	89 c5                	mov    %eax,%ebp
  801a57:	89 d1                	mov    %edx,%ecx
  801a59:	39 d6                	cmp    %edx,%esi
  801a5b:	72 67                	jb     801ac4 <__umoddi3+0x114>
  801a5d:	74 75                	je     801ad4 <__umoddi3+0x124>
  801a5f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801a63:	29 e8                	sub    %ebp,%eax
  801a65:	19 ce                	sbb    %ecx,%esi
  801a67:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801a6b:	d3 e8                	shr    %cl,%eax
  801a6d:	89 f2                	mov    %esi,%edx
  801a6f:	89 f9                	mov    %edi,%ecx
  801a71:	d3 e2                	shl    %cl,%edx
  801a73:	09 d0                	or     %edx,%eax
  801a75:	89 f2                	mov    %esi,%edx
  801a77:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801a7b:	d3 ea                	shr    %cl,%edx
  801a7d:	83 c4 20             	add    $0x20,%esp
  801a80:	5e                   	pop    %esi
  801a81:	5f                   	pop    %edi
  801a82:	5d                   	pop    %ebp
  801a83:	c3                   	ret    
  801a84:	85 c9                	test   %ecx,%ecx
  801a86:	75 0b                	jne    801a93 <__umoddi3+0xe3>
  801a88:	b8 01 00 00 00       	mov    $0x1,%eax
  801a8d:	31 d2                	xor    %edx,%edx
  801a8f:	f7 f1                	div    %ecx
  801a91:	89 c1                	mov    %eax,%ecx
  801a93:	89 f0                	mov    %esi,%eax
  801a95:	31 d2                	xor    %edx,%edx
  801a97:	f7 f1                	div    %ecx
  801a99:	89 f8                	mov    %edi,%eax
  801a9b:	e9 3e ff ff ff       	jmp    8019de <__umoddi3+0x2e>
  801aa0:	89 f2                	mov    %esi,%edx
  801aa2:	83 c4 20             	add    $0x20,%esp
  801aa5:	5e                   	pop    %esi
  801aa6:	5f                   	pop    %edi
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    
  801aa9:	8d 76 00             	lea    0x0(%esi),%esi
  801aac:	39 f5                	cmp    %esi,%ebp
  801aae:	72 04                	jb     801ab4 <__umoddi3+0x104>
  801ab0:	39 f9                	cmp    %edi,%ecx
  801ab2:	77 06                	ja     801aba <__umoddi3+0x10a>
  801ab4:	89 f2                	mov    %esi,%edx
  801ab6:	29 cf                	sub    %ecx,%edi
  801ab8:	19 ea                	sbb    %ebp,%edx
  801aba:	89 f8                	mov    %edi,%eax
  801abc:	83 c4 20             	add    $0x20,%esp
  801abf:	5e                   	pop    %esi
  801ac0:	5f                   	pop    %edi
  801ac1:	5d                   	pop    %ebp
  801ac2:	c3                   	ret    
  801ac3:	90                   	nop
  801ac4:	89 d1                	mov    %edx,%ecx
  801ac6:	89 c5                	mov    %eax,%ebp
  801ac8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801acc:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801ad0:	eb 8d                	jmp    801a5f <__umoddi3+0xaf>
  801ad2:	66 90                	xchg   %ax,%ax
  801ad4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801ad8:	72 ea                	jb     801ac4 <__umoddi3+0x114>
  801ada:	89 f1                	mov    %esi,%ecx
  801adc:	eb 81                	jmp    801a5f <__umoddi3+0xaf>
