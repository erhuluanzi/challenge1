
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 ea 0a 00 00       	call   800b2b <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 08 20 80 00 b0 	cmpl   $0xeec000b0,0x802008
  80004a:	00 c0 ee 
  80004d:	75 34                	jne    800083 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800061:	00 
  800062:	89 34 24             	mov    %esi,(%esp)
  800065:	e8 6a 0d 00 00       	call   800dd4 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800071:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800075:	c7 04 24 c0 11 80 00 	movl   $0x8011c0,(%esp)
  80007c:	e8 47 01 00 00       	call   8001c8 <cprintf>
  800081:	eb cf                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800083:	a1 f8 00 c0 ee       	mov    0xeec000f8,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 d1 11 80 00 	movl   $0x8011d1,(%esp)
  800097:	e8 2c 01 00 00       	call   8001c8 <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009c:	a1 f8 00 c0 ee       	mov    0xeec000f8,%eax
  8000a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a8:	00 
  8000a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b8:	00 
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 7a 0d 00 00       	call   800e3b <ipc_send>
  8000c1:	eb d9                	jmp    80009c <umain+0x68>
	...

008000c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
  8000c9:	83 ec 10             	sub    $0x10,%esp
  8000cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000d2:	e8 54 0a 00 00       	call   800b2b <sys_getenvid>
  8000d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dc:	8d 14 80             	lea    (%eax,%eax,4),%edx
  8000df:	8d 04 50             	lea    (%eax,%edx,2),%eax
  8000e2:	c1 e0 04             	shl    $0x4,%eax
  8000e5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ea:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ef:	85 f6                	test   %esi,%esi
  8000f1:	7e 07                	jle    8000fa <libmain+0x36>
		binaryname = argv[0];
  8000f3:	8b 03                	mov    (%ebx),%eax
  8000f5:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000fe:	89 34 24             	mov    %esi,(%esp)
  800101:	e8 2e ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800106:	e8 09 00 00 00       	call   800114 <exit>
}
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5d                   	pop    %ebp
  800111:	c3                   	ret    
	...

00800114 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80011a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800121:	e8 b3 09 00 00       	call   800ad9 <sys_env_destroy>
}
  800126:	c9                   	leave  
  800127:	c3                   	ret    

00800128 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	53                   	push   %ebx
  80012c:	83 ec 14             	sub    $0x14,%esp
  80012f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800132:	8b 03                	mov    (%ebx),%eax
  800134:	8b 55 08             	mov    0x8(%ebp),%edx
  800137:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80013b:	40                   	inc    %eax
  80013c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80013e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800143:	75 19                	jne    80015e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800145:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80014c:	00 
  80014d:	8d 43 08             	lea    0x8(%ebx),%eax
  800150:	89 04 24             	mov    %eax,(%esp)
  800153:	e8 44 09 00 00       	call   800a9c <sys_cputs>
		b->idx = 0;
  800158:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80015e:	ff 43 04             	incl   0x4(%ebx)
}
  800161:	83 c4 14             	add    $0x14,%esp
  800164:	5b                   	pop    %ebx
  800165:	5d                   	pop    %ebp
  800166:	c3                   	ret    

00800167 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800170:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800177:	00 00 00 
	b.cnt = 0;
  80017a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800181:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800184:	8b 45 0c             	mov    0xc(%ebp),%eax
  800187:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018b:	8b 45 08             	mov    0x8(%ebp),%eax
  80018e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800192:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019c:	c7 04 24 28 01 80 00 	movl   $0x800128,(%esp)
  8001a3:	e8 b4 01 00 00       	call   80035c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b8:	89 04 24             	mov    %eax,(%esp)
  8001bb:	e8 dc 08 00 00       	call   800a9c <sys_cputs>

	return b.cnt;
}
  8001c0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ce:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	89 04 24             	mov    %eax,(%esp)
  8001db:	e8 87 ff ff ff       	call   800167 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e0:	c9                   	leave  
  8001e1:	c3                   	ret    
	...

008001e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	57                   	push   %edi
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	83 ec 3c             	sub    $0x3c,%esp
  8001ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001f0:	89 d7                	mov    %edx,%edi
  8001f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001fe:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800201:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800204:	85 c0                	test   %eax,%eax
  800206:	75 08                	jne    800210 <printnum+0x2c>
  800208:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80020b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80020e:	77 57                	ja     800267 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800210:	89 74 24 10          	mov    %esi,0x10(%esp)
  800214:	4b                   	dec    %ebx
  800215:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800219:	8b 45 10             	mov    0x10(%ebp),%eax
  80021c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800220:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800224:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800228:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022f:	00 
  800230:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800233:	89 04 24             	mov    %eax,(%esp)
  800236:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800239:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023d:	e8 22 0d 00 00       	call   800f64 <__udivdi3>
  800242:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800246:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80024a:	89 04 24             	mov    %eax,(%esp)
  80024d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800251:	89 fa                	mov    %edi,%edx
  800253:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800256:	e8 89 ff ff ff       	call   8001e4 <printnum>
  80025b:	eb 0f                	jmp    80026c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80025d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800261:	89 34 24             	mov    %esi,(%esp)
  800264:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800267:	4b                   	dec    %ebx
  800268:	85 db                	test   %ebx,%ebx
  80026a:	7f f1                	jg     80025d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80026c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800270:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800274:	8b 45 10             	mov    0x10(%ebp),%eax
  800277:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800282:	00 
  800283:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800286:	89 04 24             	mov    %eax,(%esp)
  800289:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80028c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800290:	e8 ef 0d 00 00       	call   801084 <__umoddi3>
  800295:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800299:	0f be 80 f2 11 80 00 	movsbl 0x8011f2(%eax),%eax
  8002a0:	89 04 24             	mov    %eax,(%esp)
  8002a3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002a6:	83 c4 3c             	add    $0x3c,%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b1:	83 fa 01             	cmp    $0x1,%edx
  8002b4:	7e 0e                	jle    8002c4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b6:	8b 10                	mov    (%eax),%edx
  8002b8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002bb:	89 08                	mov    %ecx,(%eax)
  8002bd:	8b 02                	mov    (%edx),%eax
  8002bf:	8b 52 04             	mov    0x4(%edx),%edx
  8002c2:	eb 22                	jmp    8002e6 <getuint+0x38>
	else if (lflag)
  8002c4:	85 d2                	test   %edx,%edx
  8002c6:	74 10                	je     8002d8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c8:	8b 10                	mov    (%eax),%edx
  8002ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cd:	89 08                	mov    %ecx,(%eax)
  8002cf:	8b 02                	mov    (%edx),%eax
  8002d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d6:	eb 0e                	jmp    8002e6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 02                	mov    (%edx),%eax
  8002e1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e6:	5d                   	pop    %ebp
  8002e7:	c3                   	ret    

008002e8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002eb:	83 fa 01             	cmp    $0x1,%edx
  8002ee:	7e 0e                	jle    8002fe <getint+0x16>
		return va_arg(*ap, long long);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	8b 52 04             	mov    0x4(%edx),%edx
  8002fc:	eb 1a                	jmp    800318 <getint+0x30>
	else if (lflag)
  8002fe:	85 d2                	test   %edx,%edx
  800300:	74 0c                	je     80030e <getint+0x26>
		return va_arg(*ap, long);
  800302:	8b 10                	mov    (%eax),%edx
  800304:	8d 4a 04             	lea    0x4(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 02                	mov    (%edx),%eax
  80030b:	99                   	cltd   
  80030c:	eb 0a                	jmp    800318 <getint+0x30>
	else
		return va_arg(*ap, int);
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	8d 4a 04             	lea    0x4(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 02                	mov    (%edx),%eax
  800317:	99                   	cltd   
}
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800320:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800323:	8b 10                	mov    (%eax),%edx
  800325:	3b 50 04             	cmp    0x4(%eax),%edx
  800328:	73 08                	jae    800332 <sprintputch+0x18>
		*b->buf++ = ch;
  80032a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80032d:	88 0a                	mov    %cl,(%edx)
  80032f:	42                   	inc    %edx
  800330:	89 10                	mov    %edx,(%eax)
}
  800332:	5d                   	pop    %ebp
  800333:	c3                   	ret    

00800334 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80033a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800341:	8b 45 10             	mov    0x10(%ebp),%eax
  800344:	89 44 24 08          	mov    %eax,0x8(%esp)
  800348:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034f:	8b 45 08             	mov    0x8(%ebp),%eax
  800352:	89 04 24             	mov    %eax,(%esp)
  800355:	e8 02 00 00 00       	call   80035c <vprintfmt>
	va_end(ap);
}
  80035a:	c9                   	leave  
  80035b:	c3                   	ret    

0080035c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	57                   	push   %edi
  800360:	56                   	push   %esi
  800361:	53                   	push   %ebx
  800362:	83 ec 4c             	sub    $0x4c,%esp
  800365:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800368:	8b 75 10             	mov    0x10(%ebp),%esi
  80036b:	eb 12                	jmp    80037f <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80036d:	85 c0                	test   %eax,%eax
  80036f:	0f 84 40 03 00 00    	je     8006b5 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800375:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800379:	89 04 24             	mov    %eax,(%esp)
  80037c:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80037f:	0f b6 06             	movzbl (%esi),%eax
  800382:	46                   	inc    %esi
  800383:	83 f8 25             	cmp    $0x25,%eax
  800386:	75 e5                	jne    80036d <vprintfmt+0x11>
  800388:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80038c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800393:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800398:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80039f:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a4:	eb 26                	jmp    8003cc <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a9:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003ad:	eb 1d                	jmp    8003cc <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b2:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003b6:	eb 14                	jmp    8003cc <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003bb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003c2:	eb 08                	jmp    8003cc <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003c4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003c7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	0f b6 06             	movzbl (%esi),%eax
  8003cf:	8d 4e 01             	lea    0x1(%esi),%ecx
  8003d2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003d5:	8a 0e                	mov    (%esi),%cl
  8003d7:	83 e9 23             	sub    $0x23,%ecx
  8003da:	80 f9 55             	cmp    $0x55,%cl
  8003dd:	0f 87 b6 02 00 00    	ja     800699 <vprintfmt+0x33d>
  8003e3:	0f b6 c9             	movzbl %cl,%ecx
  8003e6:	ff 24 8d c0 12 80 00 	jmp    *0x8012c0(,%ecx,4)
  8003ed:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003f0:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f5:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  8003f8:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  8003fc:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003ff:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800402:	83 f9 09             	cmp    $0x9,%ecx
  800405:	77 2a                	ja     800431 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800407:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800408:	eb eb                	jmp    8003f5 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040a:	8b 45 14             	mov    0x14(%ebp),%eax
  80040d:	8d 48 04             	lea    0x4(%eax),%ecx
  800410:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800413:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800418:	eb 17                	jmp    800431 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80041a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80041e:	78 98                	js     8003b8 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800423:	eb a7                	jmp    8003cc <vprintfmt+0x70>
  800425:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800428:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80042f:	eb 9b                	jmp    8003cc <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800431:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800435:	79 95                	jns    8003cc <vprintfmt+0x70>
  800437:	eb 8b                	jmp    8003c4 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800439:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043d:	eb 8d                	jmp    8003cc <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 50 04             	lea    0x4(%eax),%edx
  800445:	89 55 14             	mov    %edx,0x14(%ebp)
  800448:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044c:	8b 00                	mov    (%eax),%eax
  80044e:	89 04 24             	mov    %eax,(%esp)
  800451:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800457:	e9 23 ff ff ff       	jmp    80037f <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 50 04             	lea    0x4(%eax),%edx
  800462:	89 55 14             	mov    %edx,0x14(%ebp)
  800465:	8b 00                	mov    (%eax),%eax
  800467:	85 c0                	test   %eax,%eax
  800469:	79 02                	jns    80046d <vprintfmt+0x111>
  80046b:	f7 d8                	neg    %eax
  80046d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046f:	83 f8 09             	cmp    $0x9,%eax
  800472:	7f 0b                	jg     80047f <vprintfmt+0x123>
  800474:	8b 04 85 20 14 80 00 	mov    0x801420(,%eax,4),%eax
  80047b:	85 c0                	test   %eax,%eax
  80047d:	75 23                	jne    8004a2 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80047f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800483:	c7 44 24 08 0a 12 80 	movl   $0x80120a,0x8(%esp)
  80048a:	00 
  80048b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80048f:	8b 45 08             	mov    0x8(%ebp),%eax
  800492:	89 04 24             	mov    %eax,(%esp)
  800495:	e8 9a fe ff ff       	call   800334 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80049d:	e9 dd fe ff ff       	jmp    80037f <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004a6:	c7 44 24 08 13 12 80 	movl   $0x801213,0x8(%esp)
  8004ad:	00 
  8004ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8004b5:	89 14 24             	mov    %edx,(%esp)
  8004b8:	e8 77 fe ff ff       	call   800334 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004c0:	e9 ba fe ff ff       	jmp    80037f <vprintfmt+0x23>
  8004c5:	89 f9                	mov    %edi,%ecx
  8004c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004ca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8d 50 04             	lea    0x4(%eax),%edx
  8004d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d6:	8b 30                	mov    (%eax),%esi
  8004d8:	85 f6                	test   %esi,%esi
  8004da:	75 05                	jne    8004e1 <vprintfmt+0x185>
				p = "(null)";
  8004dc:	be 03 12 80 00       	mov    $0x801203,%esi
			if (width > 0 && padc != '-')
  8004e1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004e5:	0f 8e 84 00 00 00    	jle    80056f <vprintfmt+0x213>
  8004eb:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004ef:	74 7e                	je     80056f <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004f5:	89 34 24             	mov    %esi,(%esp)
  8004f8:	e8 5d 02 00 00       	call   80075a <strnlen>
  8004fd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800500:	29 c2                	sub    %eax,%edx
  800502:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800505:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800509:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80050c:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80050f:	89 de                	mov    %ebx,%esi
  800511:	89 d3                	mov    %edx,%ebx
  800513:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800515:	eb 0b                	jmp    800522 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800517:	89 74 24 04          	mov    %esi,0x4(%esp)
  80051b:	89 3c 24             	mov    %edi,(%esp)
  80051e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800521:	4b                   	dec    %ebx
  800522:	85 db                	test   %ebx,%ebx
  800524:	7f f1                	jg     800517 <vprintfmt+0x1bb>
  800526:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800529:	89 f3                	mov    %esi,%ebx
  80052b:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80052e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800531:	85 c0                	test   %eax,%eax
  800533:	79 05                	jns    80053a <vprintfmt+0x1de>
  800535:	b8 00 00 00 00       	mov    $0x0,%eax
  80053a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80053d:	29 c2                	sub    %eax,%edx
  80053f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800542:	eb 2b                	jmp    80056f <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800544:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800548:	74 18                	je     800562 <vprintfmt+0x206>
  80054a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80054d:	83 fa 5e             	cmp    $0x5e,%edx
  800550:	76 10                	jbe    800562 <vprintfmt+0x206>
					putch('?', putdat);
  800552:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800556:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80055d:	ff 55 08             	call   *0x8(%ebp)
  800560:	eb 0a                	jmp    80056c <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800562:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800566:	89 04 24             	mov    %eax,(%esp)
  800569:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056c:	ff 4d e4             	decl   -0x1c(%ebp)
  80056f:	0f be 06             	movsbl (%esi),%eax
  800572:	46                   	inc    %esi
  800573:	85 c0                	test   %eax,%eax
  800575:	74 21                	je     800598 <vprintfmt+0x23c>
  800577:	85 ff                	test   %edi,%edi
  800579:	78 c9                	js     800544 <vprintfmt+0x1e8>
  80057b:	4f                   	dec    %edi
  80057c:	79 c6                	jns    800544 <vprintfmt+0x1e8>
  80057e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800581:	89 de                	mov    %ebx,%esi
  800583:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800586:	eb 18                	jmp    8005a0 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800588:	89 74 24 04          	mov    %esi,0x4(%esp)
  80058c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800593:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800595:	4b                   	dec    %ebx
  800596:	eb 08                	jmp    8005a0 <vprintfmt+0x244>
  800598:	8b 7d 08             	mov    0x8(%ebp),%edi
  80059b:	89 de                	mov    %ebx,%esi
  80059d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005a0:	85 db                	test   %ebx,%ebx
  8005a2:	7f e4                	jg     800588 <vprintfmt+0x22c>
  8005a4:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005a7:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ac:	e9 ce fd ff ff       	jmp    80037f <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b4:	e8 2f fd ff ff       	call   8002e8 <getint>
  8005b9:	89 c6                	mov    %eax,%esi
  8005bb:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8005bd:	85 d2                	test   %edx,%edx
  8005bf:	78 07                	js     8005c8 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c1:	be 0a 00 00 00       	mov    $0xa,%esi
  8005c6:	eb 7e                	jmp    800646 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005d3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005d6:	89 f0                	mov    %esi,%eax
  8005d8:	89 fa                	mov    %edi,%edx
  8005da:	f7 d8                	neg    %eax
  8005dc:	83 d2 00             	adc    $0x0,%edx
  8005df:	f7 da                	neg    %edx
			}
			base = 10;
  8005e1:	be 0a 00 00 00       	mov    $0xa,%esi
  8005e6:	eb 5e                	jmp    800646 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005eb:	e8 be fc ff ff       	call   8002ae <getuint>
			base = 10;
  8005f0:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8005f5:	eb 4f                	jmp    800646 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fa:	e8 af fc ff ff       	call   8002ae <getuint>
			base = 8;
  8005ff:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800604:	eb 40                	jmp    800646 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  800606:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800611:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800614:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800618:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80061f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 50 04             	lea    0x4(%eax),%edx
  800628:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80062b:	8b 00                	mov    (%eax),%eax
  80062d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800632:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800637:	eb 0d                	jmp    800646 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800639:	8d 45 14             	lea    0x14(%ebp),%eax
  80063c:	e8 6d fc ff ff       	call   8002ae <getuint>
			base = 16;
  800641:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800646:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  80064a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80064e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800651:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800655:	89 74 24 08          	mov    %esi,0x8(%esp)
  800659:	89 04 24             	mov    %eax,(%esp)
  80065c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800660:	89 da                	mov    %ebx,%edx
  800662:	8b 45 08             	mov    0x8(%ebp),%eax
  800665:	e8 7a fb ff ff       	call   8001e4 <printnum>
			break;
  80066a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80066d:	e9 0d fd ff ff       	jmp    80037f <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  800672:	8d 45 14             	lea    0x14(%ebp),%eax
  800675:	e8 6e fc ff ff       	call   8002e8 <getint>
  80067a:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  800682:	e9 f8 fc ff ff       	jmp    80037f <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800687:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068b:	89 04 24             	mov    %eax,(%esp)
  80068e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800691:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800694:	e9 e6 fc ff ff       	jmp    80037f <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800699:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006a4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a7:	eb 01                	jmp    8006aa <vprintfmt+0x34e>
  8006a9:	4e                   	dec    %esi
  8006aa:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006ae:	75 f9                	jne    8006a9 <vprintfmt+0x34d>
  8006b0:	e9 ca fc ff ff       	jmp    80037f <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006b5:	83 c4 4c             	add    $0x4c,%esp
  8006b8:	5b                   	pop    %ebx
  8006b9:	5e                   	pop    %esi
  8006ba:	5f                   	pop    %edi
  8006bb:	5d                   	pop    %ebp
  8006bc:	c3                   	ret    

008006bd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	83 ec 28             	sub    $0x28,%esp
  8006c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006cc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006da:	85 c0                	test   %eax,%eax
  8006dc:	74 30                	je     80070e <vsnprintf+0x51>
  8006de:	85 d2                	test   %edx,%edx
  8006e0:	7e 33                	jle    800715 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f7:	c7 04 24 1a 03 80 00 	movl   $0x80031a,(%esp)
  8006fe:	e8 59 fc ff ff       	call   80035c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800703:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800706:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800709:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070c:	eb 0c                	jmp    80071a <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80070e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800713:	eb 05                	jmp    80071a <vsnprintf+0x5d>
  800715:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80071a:	c9                   	leave  
  80071b:	c3                   	ret    

0080071c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800722:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800725:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800729:	8b 45 10             	mov    0x10(%ebp),%eax
  80072c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800730:	8b 45 0c             	mov    0xc(%ebp),%eax
  800733:	89 44 24 04          	mov    %eax,0x4(%esp)
  800737:	8b 45 08             	mov    0x8(%ebp),%eax
  80073a:	89 04 24             	mov    %eax,(%esp)
  80073d:	e8 7b ff ff ff       	call   8006bd <vsnprintf>
	va_end(ap);

	return rc;
}
  800742:	c9                   	leave  
  800743:	c3                   	ret    

00800744 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074a:	b8 00 00 00 00       	mov    $0x0,%eax
  80074f:	eb 01                	jmp    800752 <strlen+0xe>
		n++;
  800751:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800752:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800756:	75 f9                	jne    800751 <strlen+0xd>
		n++;
	return n;
}
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800760:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800763:	b8 00 00 00 00       	mov    $0x0,%eax
  800768:	eb 01                	jmp    80076b <strnlen+0x11>
		n++;
  80076a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076b:	39 d0                	cmp    %edx,%eax
  80076d:	74 06                	je     800775 <strnlen+0x1b>
  80076f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800773:	75 f5                	jne    80076a <strnlen+0x10>
		n++;
	return n;
}
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	53                   	push   %ebx
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
  80077e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800781:	ba 00 00 00 00       	mov    $0x0,%edx
  800786:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800789:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80078c:	42                   	inc    %edx
  80078d:	84 c9                	test   %cl,%cl
  80078f:	75 f5                	jne    800786 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800791:	5b                   	pop    %ebx
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	53                   	push   %ebx
  800798:	83 ec 08             	sub    $0x8,%esp
  80079b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079e:	89 1c 24             	mov    %ebx,(%esp)
  8007a1:	e8 9e ff ff ff       	call   800744 <strlen>
	strcpy(dst + len, src);
  8007a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ad:	01 d8                	add    %ebx,%eax
  8007af:	89 04 24             	mov    %eax,(%esp)
  8007b2:	e8 c0 ff ff ff       	call   800777 <strcpy>
	return dst;
}
  8007b7:	89 d8                	mov    %ebx,%eax
  8007b9:	83 c4 08             	add    $0x8,%esp
  8007bc:	5b                   	pop    %ebx
  8007bd:	5d                   	pop    %ebp
  8007be:	c3                   	ret    

008007bf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	56                   	push   %esi
  8007c3:	53                   	push   %ebx
  8007c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ca:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d2:	eb 0c                	jmp    8007e0 <strncpy+0x21>
		*dst++ = *src;
  8007d4:	8a 1a                	mov    (%edx),%bl
  8007d6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d9:	80 3a 01             	cmpb   $0x1,(%edx)
  8007dc:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007df:	41                   	inc    %ecx
  8007e0:	39 f1                	cmp    %esi,%ecx
  8007e2:	75 f0                	jne    8007d4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e4:	5b                   	pop    %ebx
  8007e5:	5e                   	pop    %esi
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	56                   	push   %esi
  8007ec:	53                   	push   %ebx
  8007ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	75 0a                	jne    800804 <strlcpy+0x1c>
  8007fa:	89 f0                	mov    %esi,%eax
  8007fc:	eb 1a                	jmp    800818 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fe:	88 18                	mov    %bl,(%eax)
  800800:	40                   	inc    %eax
  800801:	41                   	inc    %ecx
  800802:	eb 02                	jmp    800806 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800804:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800806:	4a                   	dec    %edx
  800807:	74 0a                	je     800813 <strlcpy+0x2b>
  800809:	8a 19                	mov    (%ecx),%bl
  80080b:	84 db                	test   %bl,%bl
  80080d:	75 ef                	jne    8007fe <strlcpy+0x16>
  80080f:	89 c2                	mov    %eax,%edx
  800811:	eb 02                	jmp    800815 <strlcpy+0x2d>
  800813:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800815:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800818:	29 f0                	sub    %esi,%eax
}
  80081a:	5b                   	pop    %ebx
  80081b:	5e                   	pop    %esi
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800824:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800827:	eb 02                	jmp    80082b <strcmp+0xd>
		p++, q++;
  800829:	41                   	inc    %ecx
  80082a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80082b:	8a 01                	mov    (%ecx),%al
  80082d:	84 c0                	test   %al,%al
  80082f:	74 04                	je     800835 <strcmp+0x17>
  800831:	3a 02                	cmp    (%edx),%al
  800833:	74 f4                	je     800829 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800835:	0f b6 c0             	movzbl %al,%eax
  800838:	0f b6 12             	movzbl (%edx),%edx
  80083b:	29 d0                	sub    %edx,%eax
}
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	53                   	push   %ebx
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800849:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80084c:	eb 03                	jmp    800851 <strncmp+0x12>
		n--, p++, q++;
  80084e:	4a                   	dec    %edx
  80084f:	40                   	inc    %eax
  800850:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800851:	85 d2                	test   %edx,%edx
  800853:	74 14                	je     800869 <strncmp+0x2a>
  800855:	8a 18                	mov    (%eax),%bl
  800857:	84 db                	test   %bl,%bl
  800859:	74 04                	je     80085f <strncmp+0x20>
  80085b:	3a 19                	cmp    (%ecx),%bl
  80085d:	74 ef                	je     80084e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80085f:	0f b6 00             	movzbl (%eax),%eax
  800862:	0f b6 11             	movzbl (%ecx),%edx
  800865:	29 d0                	sub    %edx,%eax
  800867:	eb 05                	jmp    80086e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800869:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80086e:	5b                   	pop    %ebx
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80087a:	eb 05                	jmp    800881 <strchr+0x10>
		if (*s == c)
  80087c:	38 ca                	cmp    %cl,%dl
  80087e:	74 0c                	je     80088c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800880:	40                   	inc    %eax
  800881:	8a 10                	mov    (%eax),%dl
  800883:	84 d2                	test   %dl,%dl
  800885:	75 f5                	jne    80087c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800887:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
  800894:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800897:	eb 05                	jmp    80089e <strfind+0x10>
		if (*s == c)
  800899:	38 ca                	cmp    %cl,%dl
  80089b:	74 07                	je     8008a4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80089d:	40                   	inc    %eax
  80089e:	8a 10                	mov    (%eax),%dl
  8008a0:	84 d2                	test   %dl,%dl
  8008a2:	75 f5                	jne    800899 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	57                   	push   %edi
  8008aa:	56                   	push   %esi
  8008ab:	53                   	push   %ebx
  8008ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008b5:	85 c9                	test   %ecx,%ecx
  8008b7:	74 30                	je     8008e9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008bf:	75 25                	jne    8008e6 <memset+0x40>
  8008c1:	f6 c1 03             	test   $0x3,%cl
  8008c4:	75 20                	jne    8008e6 <memset+0x40>
		c &= 0xFF;
  8008c6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c9:	89 d3                	mov    %edx,%ebx
  8008cb:	c1 e3 08             	shl    $0x8,%ebx
  8008ce:	89 d6                	mov    %edx,%esi
  8008d0:	c1 e6 18             	shl    $0x18,%esi
  8008d3:	89 d0                	mov    %edx,%eax
  8008d5:	c1 e0 10             	shl    $0x10,%eax
  8008d8:	09 f0                	or     %esi,%eax
  8008da:	09 d0                	or     %edx,%eax
  8008dc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008de:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008e1:	fc                   	cld    
  8008e2:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e4:	eb 03                	jmp    8008e9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e6:	fc                   	cld    
  8008e7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e9:	89 f8                	mov    %edi,%eax
  8008eb:	5b                   	pop    %ebx
  8008ec:	5e                   	pop    %esi
  8008ed:	5f                   	pop    %edi
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	57                   	push   %edi
  8008f4:	56                   	push   %esi
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008fe:	39 c6                	cmp    %eax,%esi
  800900:	73 34                	jae    800936 <memmove+0x46>
  800902:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800905:	39 d0                	cmp    %edx,%eax
  800907:	73 2d                	jae    800936 <memmove+0x46>
		s += n;
		d += n;
  800909:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090c:	f6 c2 03             	test   $0x3,%dl
  80090f:	75 1b                	jne    80092c <memmove+0x3c>
  800911:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800917:	75 13                	jne    80092c <memmove+0x3c>
  800919:	f6 c1 03             	test   $0x3,%cl
  80091c:	75 0e                	jne    80092c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80091e:	83 ef 04             	sub    $0x4,%edi
  800921:	8d 72 fc             	lea    -0x4(%edx),%esi
  800924:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800927:	fd                   	std    
  800928:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092a:	eb 07                	jmp    800933 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80092c:	4f                   	dec    %edi
  80092d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800930:	fd                   	std    
  800931:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800933:	fc                   	cld    
  800934:	eb 20                	jmp    800956 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800936:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093c:	75 13                	jne    800951 <memmove+0x61>
  80093e:	a8 03                	test   $0x3,%al
  800940:	75 0f                	jne    800951 <memmove+0x61>
  800942:	f6 c1 03             	test   $0x3,%cl
  800945:	75 0a                	jne    800951 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800947:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80094a:	89 c7                	mov    %eax,%edi
  80094c:	fc                   	cld    
  80094d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094f:	eb 05                	jmp    800956 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800951:	89 c7                	mov    %eax,%edi
  800953:	fc                   	cld    
  800954:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800956:	5e                   	pop    %esi
  800957:	5f                   	pop    %edi
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800960:	8b 45 10             	mov    0x10(%ebp),%eax
  800963:	89 44 24 08          	mov    %eax,0x8(%esp)
  800967:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	89 04 24             	mov    %eax,(%esp)
  800974:	e8 77 ff ff ff       	call   8008f0 <memmove>
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	57                   	push   %edi
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	8b 7d 08             	mov    0x8(%ebp),%edi
  800984:	8b 75 0c             	mov    0xc(%ebp),%esi
  800987:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098a:	ba 00 00 00 00       	mov    $0x0,%edx
  80098f:	eb 16                	jmp    8009a7 <memcmp+0x2c>
		if (*s1 != *s2)
  800991:	8a 04 17             	mov    (%edi,%edx,1),%al
  800994:	42                   	inc    %edx
  800995:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800999:	38 c8                	cmp    %cl,%al
  80099b:	74 0a                	je     8009a7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  80099d:	0f b6 c0             	movzbl %al,%eax
  8009a0:	0f b6 c9             	movzbl %cl,%ecx
  8009a3:	29 c8                	sub    %ecx,%eax
  8009a5:	eb 09                	jmp    8009b0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a7:	39 da                	cmp    %ebx,%edx
  8009a9:	75 e6                	jne    800991 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b0:	5b                   	pop    %ebx
  8009b1:	5e                   	pop    %esi
  8009b2:	5f                   	pop    %edi
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009be:	89 c2                	mov    %eax,%edx
  8009c0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c3:	eb 05                	jmp    8009ca <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c5:	38 08                	cmp    %cl,(%eax)
  8009c7:	74 05                	je     8009ce <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c9:	40                   	inc    %eax
  8009ca:	39 d0                	cmp    %edx,%eax
  8009cc:	72 f7                	jb     8009c5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	57                   	push   %edi
  8009d4:	56                   	push   %esi
  8009d5:	53                   	push   %ebx
  8009d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009dc:	eb 01                	jmp    8009df <strtol+0xf>
		s++;
  8009de:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009df:	8a 02                	mov    (%edx),%al
  8009e1:	3c 20                	cmp    $0x20,%al
  8009e3:	74 f9                	je     8009de <strtol+0xe>
  8009e5:	3c 09                	cmp    $0x9,%al
  8009e7:	74 f5                	je     8009de <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009e9:	3c 2b                	cmp    $0x2b,%al
  8009eb:	75 08                	jne    8009f5 <strtol+0x25>
		s++;
  8009ed:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ee:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f3:	eb 13                	jmp    800a08 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f5:	3c 2d                	cmp    $0x2d,%al
  8009f7:	75 0a                	jne    800a03 <strtol+0x33>
		s++, neg = 1;
  8009f9:	8d 52 01             	lea    0x1(%edx),%edx
  8009fc:	bf 01 00 00 00       	mov    $0x1,%edi
  800a01:	eb 05                	jmp    800a08 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a03:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a08:	85 db                	test   %ebx,%ebx
  800a0a:	74 05                	je     800a11 <strtol+0x41>
  800a0c:	83 fb 10             	cmp    $0x10,%ebx
  800a0f:	75 28                	jne    800a39 <strtol+0x69>
  800a11:	8a 02                	mov    (%edx),%al
  800a13:	3c 30                	cmp    $0x30,%al
  800a15:	75 10                	jne    800a27 <strtol+0x57>
  800a17:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a1b:	75 0a                	jne    800a27 <strtol+0x57>
		s += 2, base = 16;
  800a1d:	83 c2 02             	add    $0x2,%edx
  800a20:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a25:	eb 12                	jmp    800a39 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a27:	85 db                	test   %ebx,%ebx
  800a29:	75 0e                	jne    800a39 <strtol+0x69>
  800a2b:	3c 30                	cmp    $0x30,%al
  800a2d:	75 05                	jne    800a34 <strtol+0x64>
		s++, base = 8;
  800a2f:	42                   	inc    %edx
  800a30:	b3 08                	mov    $0x8,%bl
  800a32:	eb 05                	jmp    800a39 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a34:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a39:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a40:	8a 0a                	mov    (%edx),%cl
  800a42:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a45:	80 fb 09             	cmp    $0x9,%bl
  800a48:	77 08                	ja     800a52 <strtol+0x82>
			dig = *s - '0';
  800a4a:	0f be c9             	movsbl %cl,%ecx
  800a4d:	83 e9 30             	sub    $0x30,%ecx
  800a50:	eb 1e                	jmp    800a70 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a52:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a55:	80 fb 19             	cmp    $0x19,%bl
  800a58:	77 08                	ja     800a62 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a5a:	0f be c9             	movsbl %cl,%ecx
  800a5d:	83 e9 57             	sub    $0x57,%ecx
  800a60:	eb 0e                	jmp    800a70 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a62:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a65:	80 fb 19             	cmp    $0x19,%bl
  800a68:	77 12                	ja     800a7c <strtol+0xac>
			dig = *s - 'A' + 10;
  800a6a:	0f be c9             	movsbl %cl,%ecx
  800a6d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a70:	39 f1                	cmp    %esi,%ecx
  800a72:	7d 0c                	jge    800a80 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a74:	42                   	inc    %edx
  800a75:	0f af c6             	imul   %esi,%eax
  800a78:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a7a:	eb c4                	jmp    800a40 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a7c:	89 c1                	mov    %eax,%ecx
  800a7e:	eb 02                	jmp    800a82 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a80:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a82:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a86:	74 05                	je     800a8d <strtol+0xbd>
		*endptr = (char *) s;
  800a88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a8b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a8d:	85 ff                	test   %edi,%edi
  800a8f:	74 04                	je     800a95 <strtol+0xc5>
  800a91:	89 c8                	mov    %ecx,%eax
  800a93:	f7 d8                	neg    %eax
}
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5f                   	pop    %edi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    
	...

00800a9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	57                   	push   %edi
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa2:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aaa:	8b 55 08             	mov    0x8(%ebp),%edx
  800aad:	89 c3                	mov    %eax,%ebx
  800aaf:	89 c7                	mov    %eax,%edi
  800ab1:	89 c6                	mov    %eax,%esi
  800ab3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <sys_cgetc>:

int
sys_cgetc(void)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aca:	89 d1                	mov    %edx,%ecx
  800acc:	89 d3                	mov    %edx,%ebx
  800ace:	89 d7                	mov    %edx,%edi
  800ad0:	89 d6                	mov    %edx,%esi
  800ad2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5f                   	pop    %edi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	57                   	push   %edi
  800add:	56                   	push   %esi
  800ade:	53                   	push   %ebx
  800adf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae7:	b8 03 00 00 00       	mov    $0x3,%eax
  800aec:	8b 55 08             	mov    0x8(%ebp),%edx
  800aef:	89 cb                	mov    %ecx,%ebx
  800af1:	89 cf                	mov    %ecx,%edi
  800af3:	89 ce                	mov    %ecx,%esi
  800af5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800af7:	85 c0                	test   %eax,%eax
  800af9:	7e 28                	jle    800b23 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800aff:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b06:	00 
  800b07:	c7 44 24 08 48 14 80 	movl   $0x801448,0x8(%esp)
  800b0e:	00 
  800b0f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b16:	00 
  800b17:	c7 04 24 65 14 80 00 	movl   $0x801465,(%esp)
  800b1e:	e8 e9 03 00 00       	call   800f0c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b23:	83 c4 2c             	add    $0x2c,%esp
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b31:	ba 00 00 00 00       	mov    $0x0,%edx
  800b36:	b8 02 00 00 00       	mov    $0x2,%eax
  800b3b:	89 d1                	mov    %edx,%ecx
  800b3d:	89 d3                	mov    %edx,%ebx
  800b3f:	89 d7                	mov    %edx,%edi
  800b41:	89 d6                	mov    %edx,%esi
  800b43:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <sys_yield>:

void
sys_yield(void)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b50:	ba 00 00 00 00       	mov    $0x0,%edx
  800b55:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b5a:	89 d1                	mov    %edx,%ecx
  800b5c:	89 d3                	mov    %edx,%ebx
  800b5e:	89 d7                	mov    %edx,%edi
  800b60:	89 d6                	mov    %edx,%esi
  800b62:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b72:	be 00 00 00 00       	mov    $0x0,%esi
  800b77:	b8 04 00 00 00       	mov    $0x4,%eax
  800b7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b82:	8b 55 08             	mov    0x8(%ebp),%edx
  800b85:	89 f7                	mov    %esi,%edi
  800b87:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b89:	85 c0                	test   %eax,%eax
  800b8b:	7e 28                	jle    800bb5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b91:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b98:	00 
  800b99:	c7 44 24 08 48 14 80 	movl   $0x801448,0x8(%esp)
  800ba0:	00 
  800ba1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ba8:	00 
  800ba9:	c7 04 24 65 14 80 00 	movl   $0x801465,(%esp)
  800bb0:	e8 57 03 00 00       	call   800f0c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb5:	83 c4 2c             	add    $0x2c,%esp
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bce:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	7e 28                	jle    800c08 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800be4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800beb:	00 
  800bec:	c7 44 24 08 48 14 80 	movl   $0x801448,0x8(%esp)
  800bf3:	00 
  800bf4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bfb:	00 
  800bfc:	c7 04 24 65 14 80 00 	movl   $0x801465,(%esp)
  800c03:	e8 04 03 00 00       	call   800f0c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c08:	83 c4 2c             	add    $0x2c,%esp
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	8b 55 08             	mov    0x8(%ebp),%edx
  800c29:	89 df                	mov    %ebx,%edi
  800c2b:	89 de                	mov    %ebx,%esi
  800c2d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2f:	85 c0                	test   %eax,%eax
  800c31:	7e 28                	jle    800c5b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c37:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c3e:	00 
  800c3f:	c7 44 24 08 48 14 80 	movl   $0x801448,0x8(%esp)
  800c46:	00 
  800c47:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c4e:	00 
  800c4f:	c7 04 24 65 14 80 00 	movl   $0x801465,(%esp)
  800c56:	e8 b1 02 00 00       	call   800f0c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5b:	83 c4 2c             	add    $0x2c,%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c71:	b8 08 00 00 00       	mov    $0x8,%eax
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7c:	89 df                	mov    %ebx,%edi
  800c7e:	89 de                	mov    %ebx,%esi
  800c80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c82:	85 c0                	test   %eax,%eax
  800c84:	7e 28                	jle    800cae <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c86:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c8a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c91:	00 
  800c92:	c7 44 24 08 48 14 80 	movl   $0x801448,0x8(%esp)
  800c99:	00 
  800c9a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca1:	00 
  800ca2:	c7 04 24 65 14 80 00 	movl   $0x801465,(%esp)
  800ca9:	e8 5e 02 00 00       	call   800f0c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cae:	83 c4 2c             	add    $0x2c,%esp
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc4:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccf:	89 df                	mov    %ebx,%edi
  800cd1:	89 de                	mov    %ebx,%esi
  800cd3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd5:	85 c0                	test   %eax,%eax
  800cd7:	7e 28                	jle    800d01 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ce4:	00 
  800ce5:	c7 44 24 08 48 14 80 	movl   $0x801448,0x8(%esp)
  800cec:	00 
  800ced:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf4:	00 
  800cf5:	c7 04 24 65 14 80 00 	movl   $0x801465,(%esp)
  800cfc:	e8 0b 02 00 00       	call   800f0c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d01:	83 c4 2c             	add    $0x2c,%esp
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	be 00 00 00 00       	mov    $0x0,%esi
  800d14:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d19:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d42:	89 cb                	mov    %ecx,%ebx
  800d44:	89 cf                	mov    %ecx,%edi
  800d46:	89 ce                	mov    %ecx,%esi
  800d48:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	7e 28                	jle    800d76 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d52:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d59:	00 
  800d5a:	c7 44 24 08 48 14 80 	movl   $0x801448,0x8(%esp)
  800d61:	00 
  800d62:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d69:	00 
  800d6a:	c7 04 24 65 14 80 00 	movl   $0x801465,(%esp)
  800d71:	e8 96 01 00 00       	call   800f0c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d76:	83 c4 2c             	add    $0x2c,%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	89 df                	mov    %ebx,%edi
  800d99:	89 de                	mov    %ebx,%esi
  800d9b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	7e 28                	jle    800dc9 <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800dac:	00 
  800dad:	c7 44 24 08 48 14 80 	movl   $0x801448,0x8(%esp)
  800db4:	00 
  800db5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbc:	00 
  800dbd:	c7 04 24 65 14 80 00 	movl   $0x801465,(%esp)
  800dc4:	e8 43 01 00 00       	call   800f0c <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800dc9:	83 c4 2c             	add    $0x2c,%esp
  800dcc:	5b                   	pop    %ebx
  800dcd:	5e                   	pop    %esi
  800dce:	5f                   	pop    %edi
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    
  800dd1:	00 00                	add    %al,(%eax)
	...

00800dd4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
  800dd9:	83 ec 10             	sub    $0x10,%esp
  800ddc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ddf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	// -1 must be an invalid address.
	if (!pg) pg = (void *)-1;
  800de5:	85 c0                	test   %eax,%eax
  800de7:	75 05                	jne    800dee <ipc_recv+0x1a>
  800de9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	if ((r = sys_ipc_recv(pg)) < 0) {
  800dee:	89 04 24             	mov    %eax,(%esp)
  800df1:	e8 36 ff ff ff       	call   800d2c <sys_ipc_recv>
  800df6:	85 c0                	test   %eax,%eax
  800df8:	79 16                	jns    800e10 <ipc_recv+0x3c>
		if (from_env_store) *from_env_store = 0;
  800dfa:	85 db                	test   %ebx,%ebx
  800dfc:	74 06                	je     800e04 <ipc_recv+0x30>
  800dfe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  800e04:	85 f6                	test   %esi,%esi
  800e06:	74 2c                	je     800e34 <ipc_recv+0x60>
  800e08:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800e0e:	eb 24                	jmp    800e34 <ipc_recv+0x60>
		return r;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  800e10:	85 db                	test   %ebx,%ebx
  800e12:	74 0a                	je     800e1e <ipc_recv+0x4a>
  800e14:	a1 08 20 80 00       	mov    0x802008,%eax
  800e19:	8b 40 78             	mov    0x78(%eax),%eax
  800e1c:	89 03                	mov    %eax,(%ebx)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  800e1e:	85 f6                	test   %esi,%esi
  800e20:	74 0a                	je     800e2c <ipc_recv+0x58>
  800e22:	a1 08 20 80 00       	mov    0x802008,%eax
  800e27:	8b 40 7c             	mov    0x7c(%eax),%eax
  800e2a:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  800e2c:	a1 08 20 80 00       	mov    0x802008,%eax
  800e31:	8b 40 74             	mov    0x74(%eax),%eax
}
  800e34:	83 c4 10             	add    $0x10,%esp
  800e37:	5b                   	pop    %ebx
  800e38:	5e                   	pop    %esi
  800e39:	5d                   	pop    %ebp
  800e3a:	c3                   	ret    

00800e3b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	57                   	push   %edi
  800e3f:	56                   	push   %esi
  800e40:	53                   	push   %ebx
  800e41:	83 ec 1c             	sub    $0x1c,%esp
  800e44:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e47:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	int retry_times = 0;
	if (!pg) pg = (void *)-1;
  800e4a:	85 db                	test   %ebx,%ebx
  800e4c:	75 05                	jne    800e53 <ipc_send+0x18>
  800e4e:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  800e53:	be 03 00 00 00       	mov    $0x3,%esi
  800e58:	eb 49                	jmp    800ea3 <ipc_send+0x68>
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  800e5a:	83 f8 f8             	cmp    $0xfffffff8,%eax
  800e5d:	74 20                	je     800e7f <ipc_send+0x44>
			panic("ipc_send: %e", r);
  800e5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e63:	c7 44 24 08 73 14 80 	movl   $0x801473,0x8(%esp)
  800e6a:	00 
  800e6b:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  800e72:	00 
  800e73:	c7 04 24 80 14 80 00 	movl   $0x801480,(%esp)
  800e7a:	e8 8d 00 00 00       	call   800f0c <_panic>
		retry_times++;
		if (retry_times > 2) panic("Retry times out!");
  800e7f:	4e                   	dec    %esi
  800e80:	75 1c                	jne    800e9e <ipc_send+0x63>
  800e82:	c7 44 24 08 8a 14 80 	movl   $0x80148a,0x8(%esp)
  800e89:	00 
  800e8a:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  800e91:	00 
  800e92:	c7 04 24 80 14 80 00 	movl   $0x801480,(%esp)
  800e99:	e8 6e 00 00 00       	call   800f0c <_panic>
		sys_yield();
  800e9e:	e8 a7 fc ff ff       	call   800b4a <sys_yield>
{
	// LAB 4: Your code here.
	int r;
	int retry_times = 0;
	if (!pg) pg = (void *)-1;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  800ea3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800ea7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800eab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb5:	89 04 24             	mov    %eax,(%esp)
  800eb8:	e8 4c fe ff ff       	call   800d09 <sys_ipc_try_send>
  800ebd:	85 c0                	test   %eax,%eax
  800ebf:	78 99                	js     800e5a <ipc_send+0x1f>
			panic("ipc_send: %e", r);
		retry_times++;
		if (retry_times > 2) panic("Retry times out!");
		sys_yield();
	}
}
  800ec1:	83 c4 1c             	add    $0x1c,%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    

00800ec9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800ecf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800ed4:	8d 14 80             	lea    (%eax,%eax,4),%edx
  800ed7:	8d 14 50             	lea    (%eax,%edx,2),%edx
  800eda:	c1 e2 04             	shl    $0x4,%edx
  800edd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800ee3:	8b 52 50             	mov    0x50(%edx),%edx
  800ee6:	39 ca                	cmp    %ecx,%edx
  800ee8:	75 13                	jne    800efd <ipc_find_env+0x34>
			return envs[i].env_id;
  800eea:	8d 14 80             	lea    (%eax,%eax,4),%edx
  800eed:	8d 04 50             	lea    (%eax,%edx,2),%eax
  800ef0:	c1 e0 04             	shl    $0x4,%eax
  800ef3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800ef8:	8b 40 40             	mov    0x40(%eax),%eax
  800efb:	eb 0c                	jmp    800f09 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800efd:	40                   	inc    %eax
  800efe:	3d 00 04 00 00       	cmp    $0x400,%eax
  800f03:	75 cf                	jne    800ed4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800f05:	66 b8 00 00          	mov    $0x0,%ax
}
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    
	...

00800f0c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	56                   	push   %esi
  800f10:	53                   	push   %ebx
  800f11:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800f14:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f17:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800f1d:	e8 09 fc ff ff       	call   800b2b <sys_getenvid>
  800f22:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f25:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f29:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f30:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f34:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f38:	c7 04 24 9c 14 80 00 	movl   $0x80149c,(%esp)
  800f3f:	e8 84 f2 ff ff       	call   8001c8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f44:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f48:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4b:	89 04 24             	mov    %eax,(%esp)
  800f4e:	e8 14 f2 ff ff       	call   800167 <vcprintf>
	cprintf("\n");
  800f53:	c7 04 24 cf 11 80 00 	movl   $0x8011cf,(%esp)
  800f5a:	e8 69 f2 ff ff       	call   8001c8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f5f:	cc                   	int3   
  800f60:	eb fd                	jmp    800f5f <_panic+0x53>
	...

00800f64 <__udivdi3>:
  800f64:	55                   	push   %ebp
  800f65:	57                   	push   %edi
  800f66:	56                   	push   %esi
  800f67:	83 ec 10             	sub    $0x10,%esp
  800f6a:	8b 74 24 20          	mov    0x20(%esp),%esi
  800f6e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f72:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f76:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800f7a:	89 cd                	mov    %ecx,%ebp
  800f7c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800f80:	85 c0                	test   %eax,%eax
  800f82:	75 2c                	jne    800fb0 <__udivdi3+0x4c>
  800f84:	39 f9                	cmp    %edi,%ecx
  800f86:	77 68                	ja     800ff0 <__udivdi3+0x8c>
  800f88:	85 c9                	test   %ecx,%ecx
  800f8a:	75 0b                	jne    800f97 <__udivdi3+0x33>
  800f8c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f91:	31 d2                	xor    %edx,%edx
  800f93:	f7 f1                	div    %ecx
  800f95:	89 c1                	mov    %eax,%ecx
  800f97:	31 d2                	xor    %edx,%edx
  800f99:	89 f8                	mov    %edi,%eax
  800f9b:	f7 f1                	div    %ecx
  800f9d:	89 c7                	mov    %eax,%edi
  800f9f:	89 f0                	mov    %esi,%eax
  800fa1:	f7 f1                	div    %ecx
  800fa3:	89 c6                	mov    %eax,%esi
  800fa5:	89 f0                	mov    %esi,%eax
  800fa7:	89 fa                	mov    %edi,%edx
  800fa9:	83 c4 10             	add    $0x10,%esp
  800fac:	5e                   	pop    %esi
  800fad:	5f                   	pop    %edi
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    
  800fb0:	39 f8                	cmp    %edi,%eax
  800fb2:	77 2c                	ja     800fe0 <__udivdi3+0x7c>
  800fb4:	0f bd f0             	bsr    %eax,%esi
  800fb7:	83 f6 1f             	xor    $0x1f,%esi
  800fba:	75 4c                	jne    801008 <__udivdi3+0xa4>
  800fbc:	39 f8                	cmp    %edi,%eax
  800fbe:	bf 00 00 00 00       	mov    $0x0,%edi
  800fc3:	72 0a                	jb     800fcf <__udivdi3+0x6b>
  800fc5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800fc9:	0f 87 ad 00 00 00    	ja     80107c <__udivdi3+0x118>
  800fcf:	be 01 00 00 00       	mov    $0x1,%esi
  800fd4:	89 f0                	mov    %esi,%eax
  800fd6:	89 fa                	mov    %edi,%edx
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	5e                   	pop    %esi
  800fdc:	5f                   	pop    %edi
  800fdd:	5d                   	pop    %ebp
  800fde:	c3                   	ret    
  800fdf:	90                   	nop
  800fe0:	31 ff                	xor    %edi,%edi
  800fe2:	31 f6                	xor    %esi,%esi
  800fe4:	89 f0                	mov    %esi,%eax
  800fe6:	89 fa                	mov    %edi,%edx
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	5e                   	pop    %esi
  800fec:	5f                   	pop    %edi
  800fed:	5d                   	pop    %ebp
  800fee:	c3                   	ret    
  800fef:	90                   	nop
  800ff0:	89 fa                	mov    %edi,%edx
  800ff2:	89 f0                	mov    %esi,%eax
  800ff4:	f7 f1                	div    %ecx
  800ff6:	89 c6                	mov    %eax,%esi
  800ff8:	31 ff                	xor    %edi,%edi
  800ffa:	89 f0                	mov    %esi,%eax
  800ffc:	89 fa                	mov    %edi,%edx
  800ffe:	83 c4 10             	add    $0x10,%esp
  801001:	5e                   	pop    %esi
  801002:	5f                   	pop    %edi
  801003:	5d                   	pop    %ebp
  801004:	c3                   	ret    
  801005:	8d 76 00             	lea    0x0(%esi),%esi
  801008:	89 f1                	mov    %esi,%ecx
  80100a:	d3 e0                	shl    %cl,%eax
  80100c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801010:	b8 20 00 00 00       	mov    $0x20,%eax
  801015:	29 f0                	sub    %esi,%eax
  801017:	89 ea                	mov    %ebp,%edx
  801019:	88 c1                	mov    %al,%cl
  80101b:	d3 ea                	shr    %cl,%edx
  80101d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801021:	09 ca                	or     %ecx,%edx
  801023:	89 54 24 08          	mov    %edx,0x8(%esp)
  801027:	89 f1                	mov    %esi,%ecx
  801029:	d3 e5                	shl    %cl,%ebp
  80102b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80102f:	89 fd                	mov    %edi,%ebp
  801031:	88 c1                	mov    %al,%cl
  801033:	d3 ed                	shr    %cl,%ebp
  801035:	89 fa                	mov    %edi,%edx
  801037:	89 f1                	mov    %esi,%ecx
  801039:	d3 e2                	shl    %cl,%edx
  80103b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80103f:	88 c1                	mov    %al,%cl
  801041:	d3 ef                	shr    %cl,%edi
  801043:	09 d7                	or     %edx,%edi
  801045:	89 f8                	mov    %edi,%eax
  801047:	89 ea                	mov    %ebp,%edx
  801049:	f7 74 24 08          	divl   0x8(%esp)
  80104d:	89 d1                	mov    %edx,%ecx
  80104f:	89 c7                	mov    %eax,%edi
  801051:	f7 64 24 0c          	mull   0xc(%esp)
  801055:	39 d1                	cmp    %edx,%ecx
  801057:	72 17                	jb     801070 <__udivdi3+0x10c>
  801059:	74 09                	je     801064 <__udivdi3+0x100>
  80105b:	89 fe                	mov    %edi,%esi
  80105d:	31 ff                	xor    %edi,%edi
  80105f:	e9 41 ff ff ff       	jmp    800fa5 <__udivdi3+0x41>
  801064:	8b 54 24 04          	mov    0x4(%esp),%edx
  801068:	89 f1                	mov    %esi,%ecx
  80106a:	d3 e2                	shl    %cl,%edx
  80106c:	39 c2                	cmp    %eax,%edx
  80106e:	73 eb                	jae    80105b <__udivdi3+0xf7>
  801070:	8d 77 ff             	lea    -0x1(%edi),%esi
  801073:	31 ff                	xor    %edi,%edi
  801075:	e9 2b ff ff ff       	jmp    800fa5 <__udivdi3+0x41>
  80107a:	66 90                	xchg   %ax,%ax
  80107c:	31 f6                	xor    %esi,%esi
  80107e:	e9 22 ff ff ff       	jmp    800fa5 <__udivdi3+0x41>
	...

00801084 <__umoddi3>:
  801084:	55                   	push   %ebp
  801085:	57                   	push   %edi
  801086:	56                   	push   %esi
  801087:	83 ec 20             	sub    $0x20,%esp
  80108a:	8b 44 24 30          	mov    0x30(%esp),%eax
  80108e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801092:	89 44 24 14          	mov    %eax,0x14(%esp)
  801096:	8b 74 24 34          	mov    0x34(%esp),%esi
  80109a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80109e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8010a2:	89 c7                	mov    %eax,%edi
  8010a4:	89 f2                	mov    %esi,%edx
  8010a6:	85 ed                	test   %ebp,%ebp
  8010a8:	75 16                	jne    8010c0 <__umoddi3+0x3c>
  8010aa:	39 f1                	cmp    %esi,%ecx
  8010ac:	0f 86 a6 00 00 00    	jbe    801158 <__umoddi3+0xd4>
  8010b2:	f7 f1                	div    %ecx
  8010b4:	89 d0                	mov    %edx,%eax
  8010b6:	31 d2                	xor    %edx,%edx
  8010b8:	83 c4 20             	add    $0x20,%esp
  8010bb:	5e                   	pop    %esi
  8010bc:	5f                   	pop    %edi
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    
  8010bf:	90                   	nop
  8010c0:	39 f5                	cmp    %esi,%ebp
  8010c2:	0f 87 ac 00 00 00    	ja     801174 <__umoddi3+0xf0>
  8010c8:	0f bd c5             	bsr    %ebp,%eax
  8010cb:	83 f0 1f             	xor    $0x1f,%eax
  8010ce:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010d2:	0f 84 a8 00 00 00    	je     801180 <__umoddi3+0xfc>
  8010d8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010dc:	d3 e5                	shl    %cl,%ebp
  8010de:	bf 20 00 00 00       	mov    $0x20,%edi
  8010e3:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8010e7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8010eb:	89 f9                	mov    %edi,%ecx
  8010ed:	d3 e8                	shr    %cl,%eax
  8010ef:	09 e8                	or     %ebp,%eax
  8010f1:	89 44 24 18          	mov    %eax,0x18(%esp)
  8010f5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8010f9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010fd:	d3 e0                	shl    %cl,%eax
  8010ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801103:	89 f2                	mov    %esi,%edx
  801105:	d3 e2                	shl    %cl,%edx
  801107:	8b 44 24 14          	mov    0x14(%esp),%eax
  80110b:	d3 e0                	shl    %cl,%eax
  80110d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801111:	8b 44 24 14          	mov    0x14(%esp),%eax
  801115:	89 f9                	mov    %edi,%ecx
  801117:	d3 e8                	shr    %cl,%eax
  801119:	09 d0                	or     %edx,%eax
  80111b:	d3 ee                	shr    %cl,%esi
  80111d:	89 f2                	mov    %esi,%edx
  80111f:	f7 74 24 18          	divl   0x18(%esp)
  801123:	89 d6                	mov    %edx,%esi
  801125:	f7 64 24 0c          	mull   0xc(%esp)
  801129:	89 c5                	mov    %eax,%ebp
  80112b:	89 d1                	mov    %edx,%ecx
  80112d:	39 d6                	cmp    %edx,%esi
  80112f:	72 67                	jb     801198 <__umoddi3+0x114>
  801131:	74 75                	je     8011a8 <__umoddi3+0x124>
  801133:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801137:	29 e8                	sub    %ebp,%eax
  801139:	19 ce                	sbb    %ecx,%esi
  80113b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80113f:	d3 e8                	shr    %cl,%eax
  801141:	89 f2                	mov    %esi,%edx
  801143:	89 f9                	mov    %edi,%ecx
  801145:	d3 e2                	shl    %cl,%edx
  801147:	09 d0                	or     %edx,%eax
  801149:	89 f2                	mov    %esi,%edx
  80114b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80114f:	d3 ea                	shr    %cl,%edx
  801151:	83 c4 20             	add    $0x20,%esp
  801154:	5e                   	pop    %esi
  801155:	5f                   	pop    %edi
  801156:	5d                   	pop    %ebp
  801157:	c3                   	ret    
  801158:	85 c9                	test   %ecx,%ecx
  80115a:	75 0b                	jne    801167 <__umoddi3+0xe3>
  80115c:	b8 01 00 00 00       	mov    $0x1,%eax
  801161:	31 d2                	xor    %edx,%edx
  801163:	f7 f1                	div    %ecx
  801165:	89 c1                	mov    %eax,%ecx
  801167:	89 f0                	mov    %esi,%eax
  801169:	31 d2                	xor    %edx,%edx
  80116b:	f7 f1                	div    %ecx
  80116d:	89 f8                	mov    %edi,%eax
  80116f:	e9 3e ff ff ff       	jmp    8010b2 <__umoddi3+0x2e>
  801174:	89 f2                	mov    %esi,%edx
  801176:	83 c4 20             	add    $0x20,%esp
  801179:	5e                   	pop    %esi
  80117a:	5f                   	pop    %edi
  80117b:	5d                   	pop    %ebp
  80117c:	c3                   	ret    
  80117d:	8d 76 00             	lea    0x0(%esi),%esi
  801180:	39 f5                	cmp    %esi,%ebp
  801182:	72 04                	jb     801188 <__umoddi3+0x104>
  801184:	39 f9                	cmp    %edi,%ecx
  801186:	77 06                	ja     80118e <__umoddi3+0x10a>
  801188:	89 f2                	mov    %esi,%edx
  80118a:	29 cf                	sub    %ecx,%edi
  80118c:	19 ea                	sbb    %ebp,%edx
  80118e:	89 f8                	mov    %edi,%eax
  801190:	83 c4 20             	add    $0x20,%esp
  801193:	5e                   	pop    %esi
  801194:	5f                   	pop    %edi
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    
  801197:	90                   	nop
  801198:	89 d1                	mov    %edx,%ecx
  80119a:	89 c5                	mov    %eax,%ebp
  80119c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8011a0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8011a4:	eb 8d                	jmp    801133 <__umoddi3+0xaf>
  8011a6:	66 90                	xchg   %ax,%ax
  8011a8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8011ac:	72 ea                	jb     801198 <__umoddi3+0x114>
  8011ae:	89 f1                	mov    %esi,%ecx
  8011b0:	eb 81                	jmp    801133 <__umoddi3+0xaf>
