
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
  80003d:	e8 b5 0e 00 00       	call   800ef7 <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 0f 0b 00 00       	call   800b5f <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 60 15 80 00 	movl   $0x801560,(%esp)
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
  800082:	e8 9c 10 00 00       	call   801123 <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 1a 10 00 00       	call   8010bc <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 b3 0a 00 00       	call   800b5f <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 76 15 80 00 	movl   $0x801576,(%esp)
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
  8000e4:	e8 3a 10 00 00       	call   801123 <ipc_send>
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
  800110:	8d 14 80             	lea    (%eax,%eax,4),%edx
  800113:	8d 14 90             	lea    (%eax,%edx,4),%edx
  800116:	8d 04 50             	lea    (%eax,%edx,2),%eax
  800119:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  800120:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800125:	85 f6                	test   %esi,%esi
  800127:	7e 07                	jle    800130 <libmain+0x38>
		binaryname = argv[0];
  800129:	8b 03                	mov    (%ebx),%eax
  80012b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800130:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800134:	89 34 24             	mov    %esi,(%esp)
  800137:	e8 f8 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80013c:	e8 07 00 00 00       	call   800148 <exit>
}
  800141:	83 c4 10             	add    $0x10,%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5d                   	pop    %ebp
  800147:	c3                   	ret    

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
  800271:	e8 96 10 00 00       	call   80130c <__udivdi3>
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
  8002c4:	e8 63 11 00 00       	call   80142c <__umoddi3>
  8002c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002cd:	0f be 80 93 15 80 00 	movsbl 0x801593(%eax),%eax
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
  80041a:	ff 24 8d 60 16 80 00 	jmp    *0x801660(,%ecx,4)
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
  8004a8:	8b 04 85 c0 17 80 00 	mov    0x8017c0(,%eax,4),%eax
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	75 23                	jne    8004d6 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004b3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004b7:	c7 44 24 08 ab 15 80 	movl   $0x8015ab,0x8(%esp)
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
  8004da:	c7 44 24 08 b4 15 80 	movl   $0x8015b4,0x8(%esp)
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
  800510:	be a4 15 80 00       	mov    $0x8015a4,%esi
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
  800b3b:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800b42:	00 
  800b43:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b4a:	00 
  800b4b:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800b52:	e8 a1 06 00 00       	call   8011f8 <_panic>

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
  800bcd:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800bd4:	00 
  800bd5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bdc:	00 
  800bdd:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800be4:	e8 0f 06 00 00       	call   8011f8 <_panic>

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
  800c20:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800c27:	00 
  800c28:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c2f:	00 
  800c30:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800c37:	e8 bc 05 00 00       	call   8011f8 <_panic>

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
  800c73:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800c7a:	00 
  800c7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c82:	00 
  800c83:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800c8a:	e8 69 05 00 00       	call   8011f8 <_panic>

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
  800cc6:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800ccd:	00 
  800cce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd5:	00 
  800cd6:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800cdd:	e8 16 05 00 00       	call   8011f8 <_panic>

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
  800d19:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800d20:	00 
  800d21:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d28:	00 
  800d29:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800d30:	e8 c3 04 00 00       	call   8011f8 <_panic>

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
  800d8e:	c7 44 24 08 e8 17 80 	movl   $0x8017e8,0x8(%esp)
  800d95:	00 
  800d96:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d9d:	00 
  800d9e:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  800da5:	e8 4e 04 00 00       	call   8011f8 <_panic>

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
	...

00800db4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	53                   	push   %ebx
  800db8:	83 ec 24             	sub    $0x24,%esp
  800dbb:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dbe:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800dc0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dc4:	74 2d                	je     800df3 <pgfault+0x3f>
  800dc6:	89 d8                	mov    %ebx,%eax
  800dc8:	c1 e8 16             	shr    $0x16,%eax
  800dcb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800dd2:	a8 01                	test   $0x1,%al
  800dd4:	74 1d                	je     800df3 <pgfault+0x3f>
		(uvpt[PGNUM(addr)] & PTE_P) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800dd6:	89 d8                	mov    %ebx,%eax
  800dd8:	c1 e8 0c             	shr    $0xc,%eax
  800ddb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800de2:	f6 c2 01             	test   $0x1,%dl
  800de5:	74 0c                	je     800df3 <pgfault+0x3f>
		(uvpt[PGNUM(addr)] & PTE_P) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800de7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dee:	f6 c4 08             	test   $0x8,%ah
  800df1:	75 1c                	jne    800e0f <pgfault+0x5b>
		panic("pgfault: not a write or a copy on write page fault!");
  800df3:	c7 44 24 08 14 18 80 	movl   $0x801814,0x8(%esp)
  800dfa:	00 
  800dfb:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800e02:	00 
  800e03:	c7 04 24 48 18 80 00 	movl   $0x801848,(%esp)
  800e0a:	e8 e9 03 00 00       	call   8011f8 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	// we need to make addr page-aligned
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)) < 0)
  800e0f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e16:	00 
  800e17:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e1e:	00 
  800e1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e26:	e8 72 fd ff ff       	call   800b9d <sys_page_alloc>
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	79 20                	jns    800e4f <pgfault+0x9b>
		panic("pgfault: sys_page_alloc: %e", r);
  800e2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e33:	c7 44 24 08 53 18 80 	movl   $0x801853,0x8(%esp)
  800e3a:	00 
  800e3b:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800e42:	00 
  800e43:	c7 04 24 48 18 80 00 	movl   $0x801848,(%esp)
  800e4a:	e8 a9 03 00 00       	call   8011f8 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// we need to make addr page-aligned
	addr = ROUNDDOWN(addr, PGSIZE);
  800e4f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)) < 0)
		panic("pgfault: sys_page_alloc: %e", r);
	memcpy(PFTEMP, addr, PGSIZE);
  800e55:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800e5c:	00 
  800e5d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e61:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800e68:	e8 21 fb ff ff       	call   80098e <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P)) < 0)
  800e6d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800e74:	00 
  800e75:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e79:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e80:	00 
  800e81:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e88:	00 
  800e89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e90:	e8 5c fd ff ff       	call   800bf1 <sys_page_map>
  800e95:	85 c0                	test   %eax,%eax
  800e97:	79 20                	jns    800eb9 <pgfault+0x105>
		panic("pgfault: sys_page_map: %e", r);
  800e99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e9d:	c7 44 24 08 6f 18 80 	movl   $0x80186f,0x8(%esp)
  800ea4:	00 
  800ea5:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800eac:	00 
  800ead:	c7 04 24 48 18 80 00 	movl   $0x801848,(%esp)
  800eb4:	e8 3f 03 00 00       	call   8011f8 <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800eb9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ec0:	00 
  800ec1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ec8:	e8 77 fd ff ff       	call   800c44 <sys_page_unmap>
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	79 20                	jns    800ef1 <pgfault+0x13d>
		panic("pgfault: sys_page_unmap: %e", r);
  800ed1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ed5:	c7 44 24 08 89 18 80 	movl   $0x801889,0x8(%esp)
  800edc:	00 
  800edd:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800ee4:	00 
  800ee5:	c7 04 24 48 18 80 00 	movl   $0x801848,(%esp)
  800eec:	e8 07 03 00 00       	call   8011f8 <_panic>
}
  800ef1:	83 c4 24             	add    $0x24,%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	57                   	push   %edi
  800efb:	56                   	push   %esi
  800efc:	53                   	push   %ebx
  800efd:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800f00:	c7 04 24 b4 0d 80 00 	movl   $0x800db4,(%esp)
  800f07:	e8 44 03 00 00       	call   801250 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f0c:	ba 07 00 00 00       	mov    $0x7,%edx
  800f11:	89 d0                	mov    %edx,%eax
  800f13:	cd 30                	int    $0x30
  800f15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f18:	89 c7                	mov    %eax,%edi
	envid_t envid;
	uint8_t *addr;
	int r;
	extern unsigned char end[];
	envid = sys_exofork();
	if (envid < 0)
  800f1a:	85 c0                	test   %eax,%eax
  800f1c:	79 20                	jns    800f3e <fork+0x47>
		panic("sys_exofork: %e", envid);
  800f1e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f22:	c7 44 24 08 a5 18 80 	movl   $0x8018a5,0x8(%esp)
  800f29:	00 
  800f2a:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  800f31:	00 
  800f32:	c7 04 24 48 18 80 00 	movl   $0x801848,(%esp)
  800f39:	e8 ba 02 00 00       	call   8011f8 <_panic>
	if (envid == 0) {
  800f3e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f42:	75 29                	jne    800f6d <fork+0x76>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800f44:	e8 16 fc ff ff       	call   800b5f <sys_getenvid>
  800f49:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f4e:	8d 14 80             	lea    (%eax,%eax,4),%edx
  800f51:	8d 14 90             	lea    (%eax,%edx,4),%edx
  800f54:	8d 04 50             	lea    (%eax,%edx,2),%eax
  800f57:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  800f5e:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800f63:	b8 00 00 00 00       	mov    $0x0,%eax
  800f68:	e9 23 01 00 00       	jmp    801090 <fork+0x199>
	int r;
	extern unsigned char end[];
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  800f6d:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	}

	// We're the parent.
	for (addr = 0; addr < (uint8_t *)USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  800f72:	89 d8                	mov    %ebx,%eax
  800f74:	c1 e8 16             	shr    $0x16,%eax
  800f77:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f7e:	a8 01                	test   $0x1,%al
  800f80:	0f 84 ac 00 00 00    	je     801032 <fork+0x13b>
  800f86:	89 d8                	mov    %ebx,%eax
  800f88:	c1 e8 0c             	shr    $0xc,%eax
  800f8b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f92:	f6 c2 01             	test   $0x1,%dl
  800f95:	0f 84 97 00 00 00    	je     801032 <fork+0x13b>
			&& (uvpt[PGNUM(addr)] & PTE_U))
  800f9b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fa2:	f6 c2 04             	test   $0x4,%dl
  800fa5:	0f 84 87 00 00 00    	je     801032 <fork+0x13b>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	void *va = (void *)(pn * PGSIZE);
  800fab:	89 c6                	mov    %eax,%esi
  800fad:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  800fb0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb7:	f6 c2 02             	test   $0x2,%dl
  800fba:	75 0c                	jne    800fc8 <fork+0xd1>
  800fbc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc3:	f6 c4 08             	test   $0x8,%ah
  800fc6:	74 4a                	je     801012 <fork+0x11b>
		if ((r = sys_page_map(0, va, envid, va, PTE_COW|PTE_U|PTE_P)) < 0)
  800fc8:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  800fcf:	00 
  800fd0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800fd4:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fd8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fdc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fe3:	e8 09 fc ff ff       	call   800bf1 <sys_page_map>
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	78 46                	js     801032 <fork+0x13b>
			return r;
		if ((r = sys_page_map(0, va, 0, va, PTE_COW|PTE_U|PTE_P)) < 0)
  800fec:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  800ff3:	00 
  800ff4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ff8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fff:	00 
  801000:	89 74 24 04          	mov    %esi,0x4(%esp)
  801004:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80100b:	e8 e1 fb ff ff       	call   800bf1 <sys_page_map>
  801010:	eb 20                	jmp    801032 <fork+0x13b>
			return r;
	}
	else {
		if ((r = sys_page_map(0, va, envid, va, PTE_U|PTE_P)) < 0)
  801012:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801019:	00 
  80101a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80101e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801022:	89 74 24 04          	mov    %esi,0x4(%esp)
  801026:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80102d:	e8 bf fb ff ff       	call   800bf1 <sys_page_map>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	// We're the parent.
	for (addr = 0; addr < (uint8_t *)USTACKTOP; addr += PGSIZE)
  801032:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801038:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80103e:	0f 85 2e ff ff ff    	jne    800f72 <fork+0x7b>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
			&& (uvpt[PGNUM(addr)] & PTE_U))
			duppage(envid, PGNUM(addr));

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  801044:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80104b:	00 
  80104c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801053:	ee 
  801054:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801057:	89 04 24             	mov    %eax,(%esp)
  80105a:	e8 3e fb ff ff       	call   800b9d <sys_page_alloc>
  80105f:	85 c0                	test   %eax,%eax
  801061:	78 2d                	js     801090 <fork+0x199>
		return r;
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801063:	c7 44 24 04 e4 12 80 	movl   $0x8012e4,0x4(%esp)
  80106a:	00 
  80106b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80106e:	89 04 24             	mov    %eax,(%esp)
  801071:	e8 74 fc ff ff       	call   800cea <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801076:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80107d:	00 
  80107e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801081:	89 04 24             	mov    %eax,(%esp)
  801084:	e8 0e fc ff ff       	call   800c97 <sys_env_set_status>
  801089:	85 c0                	test   %eax,%eax
  80108b:	78 03                	js     801090 <fork+0x199>
		return r;

	return envid;
  80108d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801090:	83 c4 3c             	add    $0x3c,%esp
  801093:	5b                   	pop    %ebx
  801094:	5e                   	pop    %esi
  801095:	5f                   	pop    %edi
  801096:	5d                   	pop    %ebp
  801097:	c3                   	ret    

00801098 <sfork>:

// Challenge!
int
sfork(void)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80109e:	c7 44 24 08 b5 18 80 	movl   $0x8018b5,0x8(%esp)
  8010a5:	00 
  8010a6:	c7 44 24 04 8d 00 00 	movl   $0x8d,0x4(%esp)
  8010ad:	00 
  8010ae:	c7 04 24 48 18 80 00 	movl   $0x801848,(%esp)
  8010b5:	e8 3e 01 00 00       	call   8011f8 <_panic>
	...

008010bc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	56                   	push   %esi
  8010c0:	53                   	push   %ebx
  8010c1:	83 ec 10             	sub    $0x10,%esp
  8010c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8010c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010ca:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	// -1 must be an invalid address.
	if (!pg) pg = (void *)-1;
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	75 05                	jne    8010d6 <ipc_recv+0x1a>
  8010d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	if ((r = sys_ipc_recv(pg)) < 0) {
  8010d6:	89 04 24             	mov    %eax,(%esp)
  8010d9:	e8 82 fc ff ff       	call   800d60 <sys_ipc_recv>
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	79 16                	jns    8010f8 <ipc_recv+0x3c>
		if (from_env_store) *from_env_store = 0;
  8010e2:	85 db                	test   %ebx,%ebx
  8010e4:	74 06                	je     8010ec <ipc_recv+0x30>
  8010e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  8010ec:	85 f6                	test   %esi,%esi
  8010ee:	74 2c                	je     80111c <ipc_recv+0x60>
  8010f0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8010f6:	eb 24                	jmp    80111c <ipc_recv+0x60>
		return r;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  8010f8:	85 db                	test   %ebx,%ebx
  8010fa:	74 0a                	je     801106 <ipc_recv+0x4a>
  8010fc:	a1 08 20 80 00       	mov    0x802008,%eax
  801101:	8b 40 74             	mov    0x74(%eax),%eax
  801104:	89 03                	mov    %eax,(%ebx)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801106:	85 f6                	test   %esi,%esi
  801108:	74 0a                	je     801114 <ipc_recv+0x58>
  80110a:	a1 08 20 80 00       	mov    0x802008,%eax
  80110f:	8b 40 78             	mov    0x78(%eax),%eax
  801112:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  801114:	a1 08 20 80 00       	mov    0x802008,%eax
  801119:	8b 40 70             	mov    0x70(%eax),%eax
}
  80111c:	83 c4 10             	add    $0x10,%esp
  80111f:	5b                   	pop    %ebx
  801120:	5e                   	pop    %esi
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    

00801123 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	57                   	push   %edi
  801127:	56                   	push   %esi
  801128:	53                   	push   %ebx
  801129:	83 ec 1c             	sub    $0x1c,%esp
  80112c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80112f:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	int retry_times = 0;
	if (!pg) pg = (void *)-1;
  801132:	85 db                	test   %ebx,%ebx
  801134:	75 05                	jne    80113b <ipc_send+0x18>
  801136:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80113b:	be 03 00 00 00       	mov    $0x3,%esi
  801140:	eb 49                	jmp    80118b <ipc_send+0x68>
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801142:	83 f8 f8             	cmp    $0xfffffff8,%eax
  801145:	74 20                	je     801167 <ipc_send+0x44>
			panic("ipc_send: %e", r);
  801147:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80114b:	c7 44 24 08 cb 18 80 	movl   $0x8018cb,0x8(%esp)
  801152:	00 
  801153:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  80115a:	00 
  80115b:	c7 04 24 d8 18 80 00 	movl   $0x8018d8,(%esp)
  801162:	e8 91 00 00 00       	call   8011f8 <_panic>
		retry_times++;
		if (retry_times > 2) panic("Retry times out!");
  801167:	4e                   	dec    %esi
  801168:	75 1c                	jne    801186 <ipc_send+0x63>
  80116a:	c7 44 24 08 e2 18 80 	movl   $0x8018e2,0x8(%esp)
  801171:	00 
  801172:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801179:	00 
  80117a:	c7 04 24 d8 18 80 00 	movl   $0x8018d8,(%esp)
  801181:	e8 72 00 00 00       	call   8011f8 <_panic>
		sys_yield();
  801186:	e8 f3 f9 ff ff       	call   800b7e <sys_yield>
{
	// LAB 4: Your code here.
	int r;
	int retry_times = 0;
	if (!pg) pg = (void *)-1;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80118b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80118f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801193:	8b 45 0c             	mov    0xc(%ebp),%eax
  801196:	89 44 24 04          	mov    %eax,0x4(%esp)
  80119a:	8b 45 08             	mov    0x8(%ebp),%eax
  80119d:	89 04 24             	mov    %eax,(%esp)
  8011a0:	e8 98 fb ff ff       	call   800d3d <sys_ipc_try_send>
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	78 99                	js     801142 <ipc_send+0x1f>
			panic("ipc_send: %e", r);
		retry_times++;
		if (retry_times > 2) panic("Retry times out!");
		sys_yield();
	}
}
  8011a9:	83 c4 1c             	add    $0x1c,%esp
  8011ac:	5b                   	pop    %ebx
  8011ad:	5e                   	pop    %esi
  8011ae:	5f                   	pop    %edi
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    

008011b1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011b7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011bc:	8d 14 80             	lea    (%eax,%eax,4),%edx
  8011bf:	8d 14 90             	lea    (%eax,%edx,4),%edx
  8011c2:	8d 14 50             	lea    (%eax,%edx,2),%edx
  8011c5:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  8011cc:	8b 52 50             	mov    0x50(%edx),%edx
  8011cf:	39 ca                	cmp    %ecx,%edx
  8011d1:	75 15                	jne    8011e8 <ipc_find_env+0x37>
			return envs[i].env_id;
  8011d3:	8d 14 80             	lea    (%eax,%eax,4),%edx
  8011d6:	8d 14 90             	lea    (%eax,%edx,4),%edx
  8011d9:	8d 04 50             	lea    (%eax,%edx,2),%eax
  8011dc:	8d 04 85 08 00 c0 ee 	lea    -0x113ffff8(,%eax,4),%eax
  8011e3:	8b 40 40             	mov    0x40(%eax),%eax
  8011e6:	eb 0c                	jmp    8011f4 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011e8:	40                   	inc    %eax
  8011e9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011ee:	75 cc                	jne    8011bc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011f0:	66 b8 00 00          	mov    $0x0,%ax
}
  8011f4:	5d                   	pop    %ebp
  8011f5:	c3                   	ret    
	...

008011f8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	56                   	push   %esi
  8011fc:	53                   	push   %ebx
  8011fd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801200:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801203:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801209:	e8 51 f9 ff ff       	call   800b5f <sys_getenvid>
  80120e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801211:	89 54 24 10          	mov    %edx,0x10(%esp)
  801215:	8b 55 08             	mov    0x8(%ebp),%edx
  801218:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80121c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801220:	89 44 24 04          	mov    %eax,0x4(%esp)
  801224:	c7 04 24 f4 18 80 00 	movl   $0x8018f4,(%esp)
  80122b:	e8 cc ef ff ff       	call   8001fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801230:	89 74 24 04          	mov    %esi,0x4(%esp)
  801234:	8b 45 10             	mov    0x10(%ebp),%eax
  801237:	89 04 24             	mov    %eax,(%esp)
  80123a:	e8 5c ef ff ff       	call   80019b <vcprintf>
	cprintf("\n");
  80123f:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  801246:	e8 b1 ef ff ff       	call   8001fc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80124b:	cc                   	int3   
  80124c:	eb fd                	jmp    80124b <_panic+0x53>
	...

00801250 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801256:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  80125d:	75 40                	jne    80129f <set_pgfault_handler+0x4f>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
  80125f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801266:	00 
  801267:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80126e:	ee 
  80126f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801276:	e8 22 f9 ff ff       	call   800b9d <sys_page_alloc>
  80127b:	85 c0                	test   %eax,%eax
  80127d:	79 20                	jns    80129f <set_pgfault_handler+0x4f>
            panic("set_pgfault_handler: sys_page_alloc: %e", r);
  80127f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801283:	c7 44 24 08 18 19 80 	movl   $0x801918,0x8(%esp)
  80128a:	00 
  80128b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801292:	00 
  801293:	c7 04 24 74 19 80 00 	movl   $0x801974,(%esp)
  80129a:	e8 59 ff ff ff       	call   8011f8 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80129f:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a2:	a3 0c 20 80 00       	mov    %eax,0x80200c
    if ((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0 )
  8012a7:	c7 44 24 04 e4 12 80 	movl   $0x8012e4,0x4(%esp)
  8012ae:	00 
  8012af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012b6:	e8 2f fa ff ff       	call   800cea <sys_env_set_pgfault_upcall>
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	79 20                	jns    8012df <set_pgfault_handler+0x8f>
        panic("set_pgfault_handler: sys_env_set_pgfault_upcall: %e", r);
  8012bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012c3:	c7 44 24 08 40 19 80 	movl   $0x801940,0x8(%esp)
  8012ca:	00 
  8012cb:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8012d2:	00 
  8012d3:	c7 04 24 74 19 80 00 	movl   $0x801974,(%esp)
  8012da:	e8 19 ff ff ff       	call   8011f8 <_panic>
}
  8012df:	c9                   	leave  
  8012e0:	c3                   	ret    
  8012e1:	00 00                	add    %al,(%eax)
	...

008012e4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012e4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012e5:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8012ea:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012ec:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// sub 4 from old esp
	movl 0x30(%esp), %eax
  8012ef:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8012f3:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8012f6:	89 44 24 30          	mov    %eax,0x30(%esp)
	// put old eip into the pre-reserved 4-byte space
	movl 0x28(%esp), %ebx
  8012fa:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8012fe:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  801300:	83 c4 08             	add    $0x8,%esp
	popal
  801303:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  801304:	83 c4 04             	add    $0x4,%esp
	popfl
  801307:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801308:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801309:	c3                   	ret    
	...

0080130c <__udivdi3>:
  80130c:	55                   	push   %ebp
  80130d:	57                   	push   %edi
  80130e:	56                   	push   %esi
  80130f:	83 ec 10             	sub    $0x10,%esp
  801312:	8b 74 24 20          	mov    0x20(%esp),%esi
  801316:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80131a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80131e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801322:	89 cd                	mov    %ecx,%ebp
  801324:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801328:	85 c0                	test   %eax,%eax
  80132a:	75 2c                	jne    801358 <__udivdi3+0x4c>
  80132c:	39 f9                	cmp    %edi,%ecx
  80132e:	77 68                	ja     801398 <__udivdi3+0x8c>
  801330:	85 c9                	test   %ecx,%ecx
  801332:	75 0b                	jne    80133f <__udivdi3+0x33>
  801334:	b8 01 00 00 00       	mov    $0x1,%eax
  801339:	31 d2                	xor    %edx,%edx
  80133b:	f7 f1                	div    %ecx
  80133d:	89 c1                	mov    %eax,%ecx
  80133f:	31 d2                	xor    %edx,%edx
  801341:	89 f8                	mov    %edi,%eax
  801343:	f7 f1                	div    %ecx
  801345:	89 c7                	mov    %eax,%edi
  801347:	89 f0                	mov    %esi,%eax
  801349:	f7 f1                	div    %ecx
  80134b:	89 c6                	mov    %eax,%esi
  80134d:	89 f0                	mov    %esi,%eax
  80134f:	89 fa                	mov    %edi,%edx
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	5e                   	pop    %esi
  801355:	5f                   	pop    %edi
  801356:	5d                   	pop    %ebp
  801357:	c3                   	ret    
  801358:	39 f8                	cmp    %edi,%eax
  80135a:	77 2c                	ja     801388 <__udivdi3+0x7c>
  80135c:	0f bd f0             	bsr    %eax,%esi
  80135f:	83 f6 1f             	xor    $0x1f,%esi
  801362:	75 4c                	jne    8013b0 <__udivdi3+0xa4>
  801364:	39 f8                	cmp    %edi,%eax
  801366:	bf 00 00 00 00       	mov    $0x0,%edi
  80136b:	72 0a                	jb     801377 <__udivdi3+0x6b>
  80136d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801371:	0f 87 ad 00 00 00    	ja     801424 <__udivdi3+0x118>
  801377:	be 01 00 00 00       	mov    $0x1,%esi
  80137c:	89 f0                	mov    %esi,%eax
  80137e:	89 fa                	mov    %edi,%edx
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	5e                   	pop    %esi
  801384:	5f                   	pop    %edi
  801385:	5d                   	pop    %ebp
  801386:	c3                   	ret    
  801387:	90                   	nop
  801388:	31 ff                	xor    %edi,%edi
  80138a:	31 f6                	xor    %esi,%esi
  80138c:	89 f0                	mov    %esi,%eax
  80138e:	89 fa                	mov    %edi,%edx
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	5e                   	pop    %esi
  801394:	5f                   	pop    %edi
  801395:	5d                   	pop    %ebp
  801396:	c3                   	ret    
  801397:	90                   	nop
  801398:	89 fa                	mov    %edi,%edx
  80139a:	89 f0                	mov    %esi,%eax
  80139c:	f7 f1                	div    %ecx
  80139e:	89 c6                	mov    %eax,%esi
  8013a0:	31 ff                	xor    %edi,%edi
  8013a2:	89 f0                	mov    %esi,%eax
  8013a4:	89 fa                	mov    %edi,%edx
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	5e                   	pop    %esi
  8013aa:	5f                   	pop    %edi
  8013ab:	5d                   	pop    %ebp
  8013ac:	c3                   	ret    
  8013ad:	8d 76 00             	lea    0x0(%esi),%esi
  8013b0:	89 f1                	mov    %esi,%ecx
  8013b2:	d3 e0                	shl    %cl,%eax
  8013b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013b8:	b8 20 00 00 00       	mov    $0x20,%eax
  8013bd:	29 f0                	sub    %esi,%eax
  8013bf:	89 ea                	mov    %ebp,%edx
  8013c1:	88 c1                	mov    %al,%cl
  8013c3:	d3 ea                	shr    %cl,%edx
  8013c5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8013c9:	09 ca                	or     %ecx,%edx
  8013cb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013cf:	89 f1                	mov    %esi,%ecx
  8013d1:	d3 e5                	shl    %cl,%ebp
  8013d3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8013d7:	89 fd                	mov    %edi,%ebp
  8013d9:	88 c1                	mov    %al,%cl
  8013db:	d3 ed                	shr    %cl,%ebp
  8013dd:	89 fa                	mov    %edi,%edx
  8013df:	89 f1                	mov    %esi,%ecx
  8013e1:	d3 e2                	shl    %cl,%edx
  8013e3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013e7:	88 c1                	mov    %al,%cl
  8013e9:	d3 ef                	shr    %cl,%edi
  8013eb:	09 d7                	or     %edx,%edi
  8013ed:	89 f8                	mov    %edi,%eax
  8013ef:	89 ea                	mov    %ebp,%edx
  8013f1:	f7 74 24 08          	divl   0x8(%esp)
  8013f5:	89 d1                	mov    %edx,%ecx
  8013f7:	89 c7                	mov    %eax,%edi
  8013f9:	f7 64 24 0c          	mull   0xc(%esp)
  8013fd:	39 d1                	cmp    %edx,%ecx
  8013ff:	72 17                	jb     801418 <__udivdi3+0x10c>
  801401:	74 09                	je     80140c <__udivdi3+0x100>
  801403:	89 fe                	mov    %edi,%esi
  801405:	31 ff                	xor    %edi,%edi
  801407:	e9 41 ff ff ff       	jmp    80134d <__udivdi3+0x41>
  80140c:	8b 54 24 04          	mov    0x4(%esp),%edx
  801410:	89 f1                	mov    %esi,%ecx
  801412:	d3 e2                	shl    %cl,%edx
  801414:	39 c2                	cmp    %eax,%edx
  801416:	73 eb                	jae    801403 <__udivdi3+0xf7>
  801418:	8d 77 ff             	lea    -0x1(%edi),%esi
  80141b:	31 ff                	xor    %edi,%edi
  80141d:	e9 2b ff ff ff       	jmp    80134d <__udivdi3+0x41>
  801422:	66 90                	xchg   %ax,%ax
  801424:	31 f6                	xor    %esi,%esi
  801426:	e9 22 ff ff ff       	jmp    80134d <__udivdi3+0x41>
	...

0080142c <__umoddi3>:
  80142c:	55                   	push   %ebp
  80142d:	57                   	push   %edi
  80142e:	56                   	push   %esi
  80142f:	83 ec 20             	sub    $0x20,%esp
  801432:	8b 44 24 30          	mov    0x30(%esp),%eax
  801436:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80143a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80143e:	8b 74 24 34          	mov    0x34(%esp),%esi
  801442:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801446:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80144a:	89 c7                	mov    %eax,%edi
  80144c:	89 f2                	mov    %esi,%edx
  80144e:	85 ed                	test   %ebp,%ebp
  801450:	75 16                	jne    801468 <__umoddi3+0x3c>
  801452:	39 f1                	cmp    %esi,%ecx
  801454:	0f 86 a6 00 00 00    	jbe    801500 <__umoddi3+0xd4>
  80145a:	f7 f1                	div    %ecx
  80145c:	89 d0                	mov    %edx,%eax
  80145e:	31 d2                	xor    %edx,%edx
  801460:	83 c4 20             	add    $0x20,%esp
  801463:	5e                   	pop    %esi
  801464:	5f                   	pop    %edi
  801465:	5d                   	pop    %ebp
  801466:	c3                   	ret    
  801467:	90                   	nop
  801468:	39 f5                	cmp    %esi,%ebp
  80146a:	0f 87 ac 00 00 00    	ja     80151c <__umoddi3+0xf0>
  801470:	0f bd c5             	bsr    %ebp,%eax
  801473:	83 f0 1f             	xor    $0x1f,%eax
  801476:	89 44 24 10          	mov    %eax,0x10(%esp)
  80147a:	0f 84 a8 00 00 00    	je     801528 <__umoddi3+0xfc>
  801480:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801484:	d3 e5                	shl    %cl,%ebp
  801486:	bf 20 00 00 00       	mov    $0x20,%edi
  80148b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80148f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801493:	89 f9                	mov    %edi,%ecx
  801495:	d3 e8                	shr    %cl,%eax
  801497:	09 e8                	or     %ebp,%eax
  801499:	89 44 24 18          	mov    %eax,0x18(%esp)
  80149d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014a1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014a5:	d3 e0                	shl    %cl,%eax
  8014a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ab:	89 f2                	mov    %esi,%edx
  8014ad:	d3 e2                	shl    %cl,%edx
  8014af:	8b 44 24 14          	mov    0x14(%esp),%eax
  8014b3:	d3 e0                	shl    %cl,%eax
  8014b5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8014b9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8014bd:	89 f9                	mov    %edi,%ecx
  8014bf:	d3 e8                	shr    %cl,%eax
  8014c1:	09 d0                	or     %edx,%eax
  8014c3:	d3 ee                	shr    %cl,%esi
  8014c5:	89 f2                	mov    %esi,%edx
  8014c7:	f7 74 24 18          	divl   0x18(%esp)
  8014cb:	89 d6                	mov    %edx,%esi
  8014cd:	f7 64 24 0c          	mull   0xc(%esp)
  8014d1:	89 c5                	mov    %eax,%ebp
  8014d3:	89 d1                	mov    %edx,%ecx
  8014d5:	39 d6                	cmp    %edx,%esi
  8014d7:	72 67                	jb     801540 <__umoddi3+0x114>
  8014d9:	74 75                	je     801550 <__umoddi3+0x124>
  8014db:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8014df:	29 e8                	sub    %ebp,%eax
  8014e1:	19 ce                	sbb    %ecx,%esi
  8014e3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014e7:	d3 e8                	shr    %cl,%eax
  8014e9:	89 f2                	mov    %esi,%edx
  8014eb:	89 f9                	mov    %edi,%ecx
  8014ed:	d3 e2                	shl    %cl,%edx
  8014ef:	09 d0                	or     %edx,%eax
  8014f1:	89 f2                	mov    %esi,%edx
  8014f3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014f7:	d3 ea                	shr    %cl,%edx
  8014f9:	83 c4 20             	add    $0x20,%esp
  8014fc:	5e                   	pop    %esi
  8014fd:	5f                   	pop    %edi
  8014fe:	5d                   	pop    %ebp
  8014ff:	c3                   	ret    
  801500:	85 c9                	test   %ecx,%ecx
  801502:	75 0b                	jne    80150f <__umoddi3+0xe3>
  801504:	b8 01 00 00 00       	mov    $0x1,%eax
  801509:	31 d2                	xor    %edx,%edx
  80150b:	f7 f1                	div    %ecx
  80150d:	89 c1                	mov    %eax,%ecx
  80150f:	89 f0                	mov    %esi,%eax
  801511:	31 d2                	xor    %edx,%edx
  801513:	f7 f1                	div    %ecx
  801515:	89 f8                	mov    %edi,%eax
  801517:	e9 3e ff ff ff       	jmp    80145a <__umoddi3+0x2e>
  80151c:	89 f2                	mov    %esi,%edx
  80151e:	83 c4 20             	add    $0x20,%esp
  801521:	5e                   	pop    %esi
  801522:	5f                   	pop    %edi
  801523:	5d                   	pop    %ebp
  801524:	c3                   	ret    
  801525:	8d 76 00             	lea    0x0(%esi),%esi
  801528:	39 f5                	cmp    %esi,%ebp
  80152a:	72 04                	jb     801530 <__umoddi3+0x104>
  80152c:	39 f9                	cmp    %edi,%ecx
  80152e:	77 06                	ja     801536 <__umoddi3+0x10a>
  801530:	89 f2                	mov    %esi,%edx
  801532:	29 cf                	sub    %ecx,%edi
  801534:	19 ea                	sbb    %ebp,%edx
  801536:	89 f8                	mov    %edi,%eax
  801538:	83 c4 20             	add    $0x20,%esp
  80153b:	5e                   	pop    %esi
  80153c:	5f                   	pop    %edi
  80153d:	5d                   	pop    %ebp
  80153e:	c3                   	ret    
  80153f:	90                   	nop
  801540:	89 d1                	mov    %edx,%ecx
  801542:	89 c5                	mov    %eax,%ebp
  801544:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801548:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80154c:	eb 8d                	jmp    8014db <__umoddi3+0xaf>
  80154e:	66 90                	xchg   %ax,%ax
  801550:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801554:	72 ea                	jb     801540 <__umoddi3+0x114>
  801556:	89 f1                	mov    %esi,%ecx
  801558:	eb 81                	jmp    8014db <__umoddi3+0xaf>
