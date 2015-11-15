
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 00 16 80 00 	movl   $0x801600,(%esp)
  800041:	e8 12 02 00 00       	call   800258 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	74 20                	je     800075 <umain+0x41>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800059:	c7 44 24 08 7b 16 80 	movl   $0x80167b,0x8(%esp)
  800060:	00 
  800061:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 98 16 80 00 	movl   $0x801698,(%esp)
  800070:	e8 eb 00 00 00       	call   800160 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800075:	40                   	inc    %eax
  800076:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80007b:	75 ce                	jne    80004b <umain+0x17>
  80007d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800082:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  800089:	40                   	inc    %eax
  80008a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008f:	75 f1                	jne    800082 <umain+0x4e>
  800091:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  800096:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  80009d:	74 20                	je     8000bf <umain+0x8b>
			panic("bigarray[%d] didn't hold its value!\n", i);
  80009f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a3:	c7 44 24 08 20 16 80 	movl   $0x801620,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 98 16 80 00 	movl   $0x801698,(%esp)
  8000ba:	e8 a1 00 00 00       	call   800160 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000bf:	40                   	inc    %eax
  8000c0:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000c5:	75 cf                	jne    800096 <umain+0x62>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000c7:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  8000ce:	e8 85 01 00 00       	call   800258 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d3:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000da:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000dd:	c7 44 24 08 a7 16 80 	movl   $0x8016a7,0x8(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8000ec:	00 
  8000ed:	c7 04 24 98 16 80 00 	movl   $0x801698,(%esp)
  8000f4:	e8 67 00 00 00       	call   800160 <_panic>
  8000f9:	00 00                	add    %al,(%eax)
	...

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	56                   	push   %esi
  800100:	53                   	push   %ebx
  800101:	83 ec 10             	sub    $0x10,%esp
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80010a:	e8 ac 0a 00 00       	call   800bbb <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800117:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80011a:	c1 e0 04             	shl    $0x4,%eax
  80011d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800122:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800127:	85 f6                	test   %esi,%esi
  800129:	7e 07                	jle    800132 <libmain+0x36>
		binaryname = argv[0];
  80012b:	8b 03                	mov    (%ebx),%eax
  80012d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800132:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 f6 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80013e:	e8 09 00 00 00       	call   80014c <exit>
}
  800143:	83 c4 10             	add    $0x10,%esp
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5d                   	pop    %ebp
  800149:	c3                   	ret    
	...

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800152:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800159:	e8 0b 0a 00 00       	call   800b69 <sys_env_destroy>
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800168:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800171:	e8 45 0a 00 00       	call   800bbb <sys_getenvid>
  800176:	8b 55 0c             	mov    0xc(%ebp),%edx
  800179:	89 54 24 10          	mov    %edx,0x10(%esp)
  80017d:	8b 55 08             	mov    0x8(%ebp),%edx
  800180:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800184:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800188:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018c:	c7 04 24 c8 16 80 00 	movl   $0x8016c8,(%esp)
  800193:	e8 c0 00 00 00       	call   800258 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800198:	89 74 24 04          	mov    %esi,0x4(%esp)
  80019c:	8b 45 10             	mov    0x10(%ebp),%eax
  80019f:	89 04 24             	mov    %eax,(%esp)
  8001a2:	e8 50 00 00 00       	call   8001f7 <vcprintf>
	cprintf("\n");
  8001a7:	c7 04 24 96 16 80 00 	movl   $0x801696,(%esp)
  8001ae:	e8 a5 00 00 00       	call   800258 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b3:	cc                   	int3   
  8001b4:	eb fd                	jmp    8001b3 <_panic+0x53>
	...

008001b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 14             	sub    $0x14,%esp
  8001bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c2:	8b 03                	mov    (%ebx),%eax
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001cb:	40                   	inc    %eax
  8001cc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d3:	75 19                	jne    8001ee <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001d5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001dc:	00 
  8001dd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e0:	89 04 24             	mov    %eax,(%esp)
  8001e3:	e8 44 09 00 00       	call   800b2c <sys_cputs>
		b->idx = 0;
  8001e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ee:	ff 43 04             	incl   0x4(%ebx)
}
  8001f1:	83 c4 14             	add    $0x14,%esp
  8001f4:	5b                   	pop    %ebx
  8001f5:	5d                   	pop    %ebp
  8001f6:	c3                   	ret    

008001f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800200:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800207:	00 00 00 
	b.cnt = 0;
  80020a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800211:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800214:	8b 45 0c             	mov    0xc(%ebp),%eax
  800217:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021b:	8b 45 08             	mov    0x8(%ebp),%eax
  80021e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800222:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800228:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022c:	c7 04 24 b8 01 80 00 	movl   $0x8001b8,(%esp)
  800233:	e8 b4 01 00 00       	call   8003ec <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800238:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80023e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800242:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	e8 dc 08 00 00       	call   800b2c <sys_cputs>

	return b.cnt;
}
  800250:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800256:	c9                   	leave  
  800257:	c3                   	ret    

00800258 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800261:	89 44 24 04          	mov    %eax,0x4(%esp)
  800265:	8b 45 08             	mov    0x8(%ebp),%eax
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	e8 87 ff ff ff       	call   8001f7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800270:	c9                   	leave  
  800271:	c3                   	ret    
	...

00800274 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	57                   	push   %edi
  800278:	56                   	push   %esi
  800279:	53                   	push   %ebx
  80027a:	83 ec 3c             	sub    $0x3c,%esp
  80027d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800280:	89 d7                	mov    %edx,%edi
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800288:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80028e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800291:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800294:	85 c0                	test   %eax,%eax
  800296:	75 08                	jne    8002a0 <printnum+0x2c>
  800298:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80029b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80029e:	77 57                	ja     8002f7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002a4:	4b                   	dec    %ebx
  8002a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002b4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002bf:	00 
  8002c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c3:	89 04 24             	mov    %eax,(%esp)
  8002c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cd:	e8 c2 10 00 00       	call   801394 <__udivdi3>
  8002d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002da:	89 04 24             	mov    %eax,(%esp)
  8002dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e1:	89 fa                	mov    %edi,%edx
  8002e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002e6:	e8 89 ff ff ff       	call   800274 <printnum>
  8002eb:	eb 0f                	jmp    8002fc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f1:	89 34 24             	mov    %esi,(%esp)
  8002f4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f7:	4b                   	dec    %ebx
  8002f8:	85 db                	test   %ebx,%ebx
  8002fa:	7f f1                	jg     8002ed <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800300:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800304:	8b 45 10             	mov    0x10(%ebp),%eax
  800307:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800312:	00 
  800313:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800316:	89 04 24             	mov    %eax,(%esp)
  800319:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80031c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800320:	e8 8f 11 00 00       	call   8014b4 <__umoddi3>
  800325:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800329:	0f be 80 ec 16 80 00 	movsbl 0x8016ec(%eax),%eax
  800330:	89 04 24             	mov    %eax,(%esp)
  800333:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800336:	83 c4 3c             	add    $0x3c,%esp
  800339:	5b                   	pop    %ebx
  80033a:	5e                   	pop    %esi
  80033b:	5f                   	pop    %edi
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800341:	83 fa 01             	cmp    $0x1,%edx
  800344:	7e 0e                	jle    800354 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800346:	8b 10                	mov    (%eax),%edx
  800348:	8d 4a 08             	lea    0x8(%edx),%ecx
  80034b:	89 08                	mov    %ecx,(%eax)
  80034d:	8b 02                	mov    (%edx),%eax
  80034f:	8b 52 04             	mov    0x4(%edx),%edx
  800352:	eb 22                	jmp    800376 <getuint+0x38>
	else if (lflag)
  800354:	85 d2                	test   %edx,%edx
  800356:	74 10                	je     800368 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800358:	8b 10                	mov    (%eax),%edx
  80035a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035d:	89 08                	mov    %ecx,(%eax)
  80035f:	8b 02                	mov    (%edx),%eax
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
  800366:	eb 0e                	jmp    800376 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 02                	mov    (%edx),%eax
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80037b:	83 fa 01             	cmp    $0x1,%edx
  80037e:	7e 0e                	jle    80038e <getint+0x16>
		return va_arg(*ap, long long);
  800380:	8b 10                	mov    (%eax),%edx
  800382:	8d 4a 08             	lea    0x8(%edx),%ecx
  800385:	89 08                	mov    %ecx,(%eax)
  800387:	8b 02                	mov    (%edx),%eax
  800389:	8b 52 04             	mov    0x4(%edx),%edx
  80038c:	eb 1a                	jmp    8003a8 <getint+0x30>
	else if (lflag)
  80038e:	85 d2                	test   %edx,%edx
  800390:	74 0c                	je     80039e <getint+0x26>
		return va_arg(*ap, long);
  800392:	8b 10                	mov    (%eax),%edx
  800394:	8d 4a 04             	lea    0x4(%edx),%ecx
  800397:	89 08                	mov    %ecx,(%eax)
  800399:	8b 02                	mov    (%edx),%eax
  80039b:	99                   	cltd   
  80039c:	eb 0a                	jmp    8003a8 <getint+0x30>
	else
		return va_arg(*ap, int);
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 02                	mov    (%edx),%eax
  8003a7:	99                   	cltd   
}
  8003a8:	5d                   	pop    %ebp
  8003a9:	c3                   	ret    

008003aa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003b3:	8b 10                	mov    (%eax),%edx
  8003b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003b8:	73 08                	jae    8003c2 <sprintputch+0x18>
		*b->buf++ = ch;
  8003ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003bd:	88 0a                	mov    %cl,(%edx)
  8003bf:	42                   	inc    %edx
  8003c0:	89 10                	mov    %edx,(%eax)
}
  8003c2:	5d                   	pop    %ebp
  8003c3:	c3                   	ret    

008003c4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ca:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003df:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e2:	89 04 24             	mov    %eax,(%esp)
  8003e5:	e8 02 00 00 00       	call   8003ec <vprintfmt>
	va_end(ap);
}
  8003ea:	c9                   	leave  
  8003eb:	c3                   	ret    

008003ec <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	57                   	push   %edi
  8003f0:	56                   	push   %esi
  8003f1:	53                   	push   %ebx
  8003f2:	83 ec 4c             	sub    $0x4c,%esp
  8003f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f8:	8b 75 10             	mov    0x10(%ebp),%esi
  8003fb:	eb 12                	jmp    80040f <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003fd:	85 c0                	test   %eax,%eax
  8003ff:	0f 84 40 03 00 00    	je     800745 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800405:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800409:	89 04 24             	mov    %eax,(%esp)
  80040c:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040f:	0f b6 06             	movzbl (%esi),%eax
  800412:	46                   	inc    %esi
  800413:	83 f8 25             	cmp    $0x25,%eax
  800416:	75 e5                	jne    8003fd <vprintfmt+0x11>
  800418:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80041c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800423:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800428:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80042f:	ba 00 00 00 00       	mov    $0x0,%edx
  800434:	eb 26                	jmp    80045c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800439:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80043d:	eb 1d                	jmp    80045c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800442:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800446:	eb 14                	jmp    80045c <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80044b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800452:	eb 08                	jmp    80045c <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800454:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800457:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	0f b6 06             	movzbl (%esi),%eax
  80045f:	8d 4e 01             	lea    0x1(%esi),%ecx
  800462:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800465:	8a 0e                	mov    (%esi),%cl
  800467:	83 e9 23             	sub    $0x23,%ecx
  80046a:	80 f9 55             	cmp    $0x55,%cl
  80046d:	0f 87 b6 02 00 00    	ja     800729 <vprintfmt+0x33d>
  800473:	0f b6 c9             	movzbl %cl,%ecx
  800476:	ff 24 8d c0 17 80 00 	jmp    *0x8017c0(,%ecx,4)
  80047d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800480:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800485:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800488:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  80048c:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80048f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800492:	83 f9 09             	cmp    $0x9,%ecx
  800495:	77 2a                	ja     8004c1 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800497:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800498:	eb eb                	jmp    800485 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 48 04             	lea    0x4(%eax),%ecx
  8004a0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004a3:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004a8:	eb 17                	jmp    8004c1 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004aa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ae:	78 98                	js     800448 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004b3:	eb a7                	jmp    80045c <vprintfmt+0x70>
  8004b5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b8:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004bf:	eb 9b                	jmp    80045c <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004c1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c5:	79 95                	jns    80045c <vprintfmt+0x70>
  8004c7:	eb 8b                	jmp    800454 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c9:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004cd:	eb 8d                	jmp    80045c <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8d 50 04             	lea    0x4(%eax),%edx
  8004d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004dc:	8b 00                	mov    (%eax),%eax
  8004de:	89 04 24             	mov    %eax,(%esp)
  8004e1:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004e7:	e9 23 ff ff ff       	jmp    80040f <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ef:	8d 50 04             	lea    0x4(%eax),%edx
  8004f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f5:	8b 00                	mov    (%eax),%eax
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	79 02                	jns    8004fd <vprintfmt+0x111>
  8004fb:	f7 d8                	neg    %eax
  8004fd:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ff:	83 f8 09             	cmp    $0x9,%eax
  800502:	7f 0b                	jg     80050f <vprintfmt+0x123>
  800504:	8b 04 85 20 19 80 00 	mov    0x801920(,%eax,4),%eax
  80050b:	85 c0                	test   %eax,%eax
  80050d:	75 23                	jne    800532 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80050f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800513:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  80051a:	00 
  80051b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051f:	8b 45 08             	mov    0x8(%ebp),%eax
  800522:	89 04 24             	mov    %eax,(%esp)
  800525:	e8 9a fe ff ff       	call   8003c4 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052a:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80052d:	e9 dd fe ff ff       	jmp    80040f <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800532:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800536:	c7 44 24 08 0d 17 80 	movl   $0x80170d,0x8(%esp)
  80053d:	00 
  80053e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800542:	8b 55 08             	mov    0x8(%ebp),%edx
  800545:	89 14 24             	mov    %edx,(%esp)
  800548:	e8 77 fe ff ff       	call   8003c4 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800550:	e9 ba fe ff ff       	jmp    80040f <vprintfmt+0x23>
  800555:	89 f9                	mov    %edi,%ecx
  800557:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80055a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8d 50 04             	lea    0x4(%eax),%edx
  800563:	89 55 14             	mov    %edx,0x14(%ebp)
  800566:	8b 30                	mov    (%eax),%esi
  800568:	85 f6                	test   %esi,%esi
  80056a:	75 05                	jne    800571 <vprintfmt+0x185>
				p = "(null)";
  80056c:	be fd 16 80 00       	mov    $0x8016fd,%esi
			if (width > 0 && padc != '-')
  800571:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800575:	0f 8e 84 00 00 00    	jle    8005ff <vprintfmt+0x213>
  80057b:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80057f:	74 7e                	je     8005ff <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800581:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800585:	89 34 24             	mov    %esi,(%esp)
  800588:	e8 5d 02 00 00       	call   8007ea <strnlen>
  80058d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800590:	29 c2                	sub    %eax,%edx
  800592:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800595:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800599:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80059c:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80059f:	89 de                	mov    %ebx,%esi
  8005a1:	89 d3                	mov    %edx,%ebx
  8005a3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a5:	eb 0b                	jmp    8005b2 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ab:	89 3c 24             	mov    %edi,(%esp)
  8005ae:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b1:	4b                   	dec    %ebx
  8005b2:	85 db                	test   %ebx,%ebx
  8005b4:	7f f1                	jg     8005a7 <vprintfmt+0x1bb>
  8005b6:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005b9:	89 f3                	mov    %esi,%ebx
  8005bb:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005c1:	85 c0                	test   %eax,%eax
  8005c3:	79 05                	jns    8005ca <vprintfmt+0x1de>
  8005c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005cd:	29 c2                	sub    %eax,%edx
  8005cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005d2:	eb 2b                	jmp    8005ff <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005d4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005d8:	74 18                	je     8005f2 <vprintfmt+0x206>
  8005da:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005dd:	83 fa 5e             	cmp    $0x5e,%edx
  8005e0:	76 10                	jbe    8005f2 <vprintfmt+0x206>
					putch('?', putdat);
  8005e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005ed:	ff 55 08             	call   *0x8(%ebp)
  8005f0:	eb 0a                	jmp    8005fc <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f6:	89 04 24             	mov    %eax,(%esp)
  8005f9:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fc:	ff 4d e4             	decl   -0x1c(%ebp)
  8005ff:	0f be 06             	movsbl (%esi),%eax
  800602:	46                   	inc    %esi
  800603:	85 c0                	test   %eax,%eax
  800605:	74 21                	je     800628 <vprintfmt+0x23c>
  800607:	85 ff                	test   %edi,%edi
  800609:	78 c9                	js     8005d4 <vprintfmt+0x1e8>
  80060b:	4f                   	dec    %edi
  80060c:	79 c6                	jns    8005d4 <vprintfmt+0x1e8>
  80060e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800611:	89 de                	mov    %ebx,%esi
  800613:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800616:	eb 18                	jmp    800630 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800618:	89 74 24 04          	mov    %esi,0x4(%esp)
  80061c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800623:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800625:	4b                   	dec    %ebx
  800626:	eb 08                	jmp    800630 <vprintfmt+0x244>
  800628:	8b 7d 08             	mov    0x8(%ebp),%edi
  80062b:	89 de                	mov    %ebx,%esi
  80062d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800630:	85 db                	test   %ebx,%ebx
  800632:	7f e4                	jg     800618 <vprintfmt+0x22c>
  800634:	89 7d 08             	mov    %edi,0x8(%ebp)
  800637:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800639:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80063c:	e9 ce fd ff ff       	jmp    80040f <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800641:	8d 45 14             	lea    0x14(%ebp),%eax
  800644:	e8 2f fd ff ff       	call   800378 <getint>
  800649:	89 c6                	mov    %eax,%esi
  80064b:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  80064d:	85 d2                	test   %edx,%edx
  80064f:	78 07                	js     800658 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800651:	be 0a 00 00 00       	mov    $0xa,%esi
  800656:	eb 7e                	jmp    8006d6 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800658:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800663:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800666:	89 f0                	mov    %esi,%eax
  800668:	89 fa                	mov    %edi,%edx
  80066a:	f7 d8                	neg    %eax
  80066c:	83 d2 00             	adc    $0x0,%edx
  80066f:	f7 da                	neg    %edx
			}
			base = 10;
  800671:	be 0a 00 00 00       	mov    $0xa,%esi
  800676:	eb 5e                	jmp    8006d6 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800678:	8d 45 14             	lea    0x14(%ebp),%eax
  80067b:	e8 be fc ff ff       	call   80033e <getuint>
			base = 10;
  800680:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800685:	eb 4f                	jmp    8006d6 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800687:	8d 45 14             	lea    0x14(%ebp),%eax
  80068a:	e8 af fc ff ff       	call   80033e <getuint>
			base = 8;
  80068f:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800694:	eb 40                	jmp    8006d6 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  800696:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006a1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006af:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8d 50 04             	lea    0x4(%eax),%edx
  8006b8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006bb:	8b 00                	mov    (%eax),%eax
  8006bd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006c2:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8006c7:	eb 0d                	jmp    8006d6 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006cc:	e8 6d fc ff ff       	call   80033e <getuint>
			base = 16;
  8006d1:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d6:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8006da:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8006de:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006e1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8006e5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8006e9:	89 04 24             	mov    %eax,(%esp)
  8006ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006f0:	89 da                	mov    %ebx,%edx
  8006f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f5:	e8 7a fb ff ff       	call   800274 <printnum>
			break;
  8006fa:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006fd:	e9 0d fd ff ff       	jmp    80040f <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  800702:	8d 45 14             	lea    0x14(%ebp),%eax
  800705:	e8 6e fc ff ff       	call   800378 <getint>
  80070a:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  800712:	e9 f8 fc ff ff       	jmp    80040f <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800717:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071b:	89 04 24             	mov    %eax,(%esp)
  80071e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800721:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800724:	e9 e6 fc ff ff       	jmp    80040f <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800729:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800734:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800737:	eb 01                	jmp    80073a <vprintfmt+0x34e>
  800739:	4e                   	dec    %esi
  80073a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80073e:	75 f9                	jne    800739 <vprintfmt+0x34d>
  800740:	e9 ca fc ff ff       	jmp    80040f <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800745:	83 c4 4c             	add    $0x4c,%esp
  800748:	5b                   	pop    %ebx
  800749:	5e                   	pop    %esi
  80074a:	5f                   	pop    %edi
  80074b:	5d                   	pop    %ebp
  80074c:	c3                   	ret    

0080074d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	83 ec 28             	sub    $0x28,%esp
  800753:	8b 45 08             	mov    0x8(%ebp),%eax
  800756:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800759:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800760:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800763:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076a:	85 c0                	test   %eax,%eax
  80076c:	74 30                	je     80079e <vsnprintf+0x51>
  80076e:	85 d2                	test   %edx,%edx
  800770:	7e 33                	jle    8007a5 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800779:	8b 45 10             	mov    0x10(%ebp),%eax
  80077c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800780:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800783:	89 44 24 04          	mov    %eax,0x4(%esp)
  800787:	c7 04 24 aa 03 80 00 	movl   $0x8003aa,(%esp)
  80078e:	e8 59 fc ff ff       	call   8003ec <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800793:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800796:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800799:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079c:	eb 0c                	jmp    8007aa <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80079e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a3:	eb 05                	jmp    8007aa <vsnprintf+0x5d>
  8007a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007aa:	c9                   	leave  
  8007ab:	c3                   	ret    

008007ac <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8007bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ca:	89 04 24             	mov    %eax,(%esp)
  8007cd:	e8 7b ff ff ff       	call   80074d <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d2:	c9                   	leave  
  8007d3:	c3                   	ret    

008007d4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007da:	b8 00 00 00 00       	mov    $0x0,%eax
  8007df:	eb 01                	jmp    8007e2 <strlen+0xe>
		n++;
  8007e1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e6:	75 f9                	jne    8007e1 <strlen+0xd>
		n++;
	return n;
}
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007f0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f8:	eb 01                	jmp    8007fb <strnlen+0x11>
		n++;
  8007fa:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fb:	39 d0                	cmp    %edx,%eax
  8007fd:	74 06                	je     800805 <strnlen+0x1b>
  8007ff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800803:	75 f5                	jne    8007fa <strnlen+0x10>
		n++;
	return n;
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800811:	ba 00 00 00 00       	mov    $0x0,%edx
  800816:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800819:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80081c:	42                   	inc    %edx
  80081d:	84 c9                	test   %cl,%cl
  80081f:	75 f5                	jne    800816 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800821:	5b                   	pop    %ebx
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	53                   	push   %ebx
  800828:	83 ec 08             	sub    $0x8,%esp
  80082b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082e:	89 1c 24             	mov    %ebx,(%esp)
  800831:	e8 9e ff ff ff       	call   8007d4 <strlen>
	strcpy(dst + len, src);
  800836:	8b 55 0c             	mov    0xc(%ebp),%edx
  800839:	89 54 24 04          	mov    %edx,0x4(%esp)
  80083d:	01 d8                	add    %ebx,%eax
  80083f:	89 04 24             	mov    %eax,(%esp)
  800842:	e8 c0 ff ff ff       	call   800807 <strcpy>
	return dst;
}
  800847:	89 d8                	mov    %ebx,%eax
  800849:	83 c4 08             	add    $0x8,%esp
  80084c:	5b                   	pop    %ebx
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	56                   	push   %esi
  800853:	53                   	push   %ebx
  800854:	8b 45 08             	mov    0x8(%ebp),%eax
  800857:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800862:	eb 0c                	jmp    800870 <strncpy+0x21>
		*dst++ = *src;
  800864:	8a 1a                	mov    (%edx),%bl
  800866:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800869:	80 3a 01             	cmpb   $0x1,(%edx)
  80086c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086f:	41                   	inc    %ecx
  800870:	39 f1                	cmp    %esi,%ecx
  800872:	75 f0                	jne    800864 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800874:	5b                   	pop    %ebx
  800875:	5e                   	pop    %esi
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	56                   	push   %esi
  80087c:	53                   	push   %ebx
  80087d:	8b 75 08             	mov    0x8(%ebp),%esi
  800880:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800883:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800886:	85 d2                	test   %edx,%edx
  800888:	75 0a                	jne    800894 <strlcpy+0x1c>
  80088a:	89 f0                	mov    %esi,%eax
  80088c:	eb 1a                	jmp    8008a8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088e:	88 18                	mov    %bl,(%eax)
  800890:	40                   	inc    %eax
  800891:	41                   	inc    %ecx
  800892:	eb 02                	jmp    800896 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800894:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800896:	4a                   	dec    %edx
  800897:	74 0a                	je     8008a3 <strlcpy+0x2b>
  800899:	8a 19                	mov    (%ecx),%bl
  80089b:	84 db                	test   %bl,%bl
  80089d:	75 ef                	jne    80088e <strlcpy+0x16>
  80089f:	89 c2                	mov    %eax,%edx
  8008a1:	eb 02                	jmp    8008a5 <strlcpy+0x2d>
  8008a3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008a5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008a8:	29 f0                	sub    %esi,%eax
}
  8008aa:	5b                   	pop    %ebx
  8008ab:	5e                   	pop    %esi
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b7:	eb 02                	jmp    8008bb <strcmp+0xd>
		p++, q++;
  8008b9:	41                   	inc    %ecx
  8008ba:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008bb:	8a 01                	mov    (%ecx),%al
  8008bd:	84 c0                	test   %al,%al
  8008bf:	74 04                	je     8008c5 <strcmp+0x17>
  8008c1:	3a 02                	cmp    (%edx),%al
  8008c3:	74 f4                	je     8008b9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c5:	0f b6 c0             	movzbl %al,%eax
  8008c8:	0f b6 12             	movzbl (%edx),%edx
  8008cb:	29 d0                	sub    %edx,%eax
}
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	53                   	push   %ebx
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008dc:	eb 03                	jmp    8008e1 <strncmp+0x12>
		n--, p++, q++;
  8008de:	4a                   	dec    %edx
  8008df:	40                   	inc    %eax
  8008e0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e1:	85 d2                	test   %edx,%edx
  8008e3:	74 14                	je     8008f9 <strncmp+0x2a>
  8008e5:	8a 18                	mov    (%eax),%bl
  8008e7:	84 db                	test   %bl,%bl
  8008e9:	74 04                	je     8008ef <strncmp+0x20>
  8008eb:	3a 19                	cmp    (%ecx),%bl
  8008ed:	74 ef                	je     8008de <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ef:	0f b6 00             	movzbl (%eax),%eax
  8008f2:	0f b6 11             	movzbl (%ecx),%edx
  8008f5:	29 d0                	sub    %edx,%eax
  8008f7:	eb 05                	jmp    8008fe <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008fe:	5b                   	pop    %ebx
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80090a:	eb 05                	jmp    800911 <strchr+0x10>
		if (*s == c)
  80090c:	38 ca                	cmp    %cl,%dl
  80090e:	74 0c                	je     80091c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800910:	40                   	inc    %eax
  800911:	8a 10                	mov    (%eax),%dl
  800913:	84 d2                	test   %dl,%dl
  800915:	75 f5                	jne    80090c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800917:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800927:	eb 05                	jmp    80092e <strfind+0x10>
		if (*s == c)
  800929:	38 ca                	cmp    %cl,%dl
  80092b:	74 07                	je     800934 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80092d:	40                   	inc    %eax
  80092e:	8a 10                	mov    (%eax),%dl
  800930:	84 d2                	test   %dl,%dl
  800932:	75 f5                	jne    800929 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	57                   	push   %edi
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800942:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800945:	85 c9                	test   %ecx,%ecx
  800947:	74 30                	je     800979 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800949:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094f:	75 25                	jne    800976 <memset+0x40>
  800951:	f6 c1 03             	test   $0x3,%cl
  800954:	75 20                	jne    800976 <memset+0x40>
		c &= 0xFF;
  800956:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800959:	89 d3                	mov    %edx,%ebx
  80095b:	c1 e3 08             	shl    $0x8,%ebx
  80095e:	89 d6                	mov    %edx,%esi
  800960:	c1 e6 18             	shl    $0x18,%esi
  800963:	89 d0                	mov    %edx,%eax
  800965:	c1 e0 10             	shl    $0x10,%eax
  800968:	09 f0                	or     %esi,%eax
  80096a:	09 d0                	or     %edx,%eax
  80096c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80096e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800971:	fc                   	cld    
  800972:	f3 ab                	rep stos %eax,%es:(%edi)
  800974:	eb 03                	jmp    800979 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800976:	fc                   	cld    
  800977:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800979:	89 f8                	mov    %edi,%eax
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5f                   	pop    %edi
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	57                   	push   %edi
  800984:	56                   	push   %esi
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098e:	39 c6                	cmp    %eax,%esi
  800990:	73 34                	jae    8009c6 <memmove+0x46>
  800992:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800995:	39 d0                	cmp    %edx,%eax
  800997:	73 2d                	jae    8009c6 <memmove+0x46>
		s += n;
		d += n;
  800999:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099c:	f6 c2 03             	test   $0x3,%dl
  80099f:	75 1b                	jne    8009bc <memmove+0x3c>
  8009a1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a7:	75 13                	jne    8009bc <memmove+0x3c>
  8009a9:	f6 c1 03             	test   $0x3,%cl
  8009ac:	75 0e                	jne    8009bc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ae:	83 ef 04             	sub    $0x4,%edi
  8009b1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009b7:	fd                   	std    
  8009b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ba:	eb 07                	jmp    8009c3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009bc:	4f                   	dec    %edi
  8009bd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c0:	fd                   	std    
  8009c1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c3:	fc                   	cld    
  8009c4:	eb 20                	jmp    8009e6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009cc:	75 13                	jne    8009e1 <memmove+0x61>
  8009ce:	a8 03                	test   $0x3,%al
  8009d0:	75 0f                	jne    8009e1 <memmove+0x61>
  8009d2:	f6 c1 03             	test   $0x3,%cl
  8009d5:	75 0a                	jne    8009e1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009da:	89 c7                	mov    %eax,%edi
  8009dc:	fc                   	cld    
  8009dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009df:	eb 05                	jmp    8009e6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e1:	89 c7                	mov    %eax,%edi
  8009e3:	fc                   	cld    
  8009e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e6:	5e                   	pop    %esi
  8009e7:	5f                   	pop    %edi
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	89 04 24             	mov    %eax,(%esp)
  800a04:	e8 77 ff ff ff       	call   800980 <memmove>
}
  800a09:	c9                   	leave  
  800a0a:	c3                   	ret    

00800a0b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	57                   	push   %edi
  800a0f:	56                   	push   %esi
  800a10:	53                   	push   %ebx
  800a11:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1f:	eb 16                	jmp    800a37 <memcmp+0x2c>
		if (*s1 != *s2)
  800a21:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a24:	42                   	inc    %edx
  800a25:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a29:	38 c8                	cmp    %cl,%al
  800a2b:	74 0a                	je     800a37 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a2d:	0f b6 c0             	movzbl %al,%eax
  800a30:	0f b6 c9             	movzbl %cl,%ecx
  800a33:	29 c8                	sub    %ecx,%eax
  800a35:	eb 09                	jmp    800a40 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a37:	39 da                	cmp    %ebx,%edx
  800a39:	75 e6                	jne    800a21 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a40:	5b                   	pop    %ebx
  800a41:	5e                   	pop    %esi
  800a42:	5f                   	pop    %edi
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a4e:	89 c2                	mov    %eax,%edx
  800a50:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a53:	eb 05                	jmp    800a5a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a55:	38 08                	cmp    %cl,(%eax)
  800a57:	74 05                	je     800a5e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a59:	40                   	inc    %eax
  800a5a:	39 d0                	cmp    %edx,%eax
  800a5c:	72 f7                	jb     800a55 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	57                   	push   %edi
  800a64:	56                   	push   %esi
  800a65:	53                   	push   %ebx
  800a66:	8b 55 08             	mov    0x8(%ebp),%edx
  800a69:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6c:	eb 01                	jmp    800a6f <strtol+0xf>
		s++;
  800a6e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6f:	8a 02                	mov    (%edx),%al
  800a71:	3c 20                	cmp    $0x20,%al
  800a73:	74 f9                	je     800a6e <strtol+0xe>
  800a75:	3c 09                	cmp    $0x9,%al
  800a77:	74 f5                	je     800a6e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a79:	3c 2b                	cmp    $0x2b,%al
  800a7b:	75 08                	jne    800a85 <strtol+0x25>
		s++;
  800a7d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a83:	eb 13                	jmp    800a98 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a85:	3c 2d                	cmp    $0x2d,%al
  800a87:	75 0a                	jne    800a93 <strtol+0x33>
		s++, neg = 1;
  800a89:	8d 52 01             	lea    0x1(%edx),%edx
  800a8c:	bf 01 00 00 00       	mov    $0x1,%edi
  800a91:	eb 05                	jmp    800a98 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a93:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a98:	85 db                	test   %ebx,%ebx
  800a9a:	74 05                	je     800aa1 <strtol+0x41>
  800a9c:	83 fb 10             	cmp    $0x10,%ebx
  800a9f:	75 28                	jne    800ac9 <strtol+0x69>
  800aa1:	8a 02                	mov    (%edx),%al
  800aa3:	3c 30                	cmp    $0x30,%al
  800aa5:	75 10                	jne    800ab7 <strtol+0x57>
  800aa7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aab:	75 0a                	jne    800ab7 <strtol+0x57>
		s += 2, base = 16;
  800aad:	83 c2 02             	add    $0x2,%edx
  800ab0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab5:	eb 12                	jmp    800ac9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ab7:	85 db                	test   %ebx,%ebx
  800ab9:	75 0e                	jne    800ac9 <strtol+0x69>
  800abb:	3c 30                	cmp    $0x30,%al
  800abd:	75 05                	jne    800ac4 <strtol+0x64>
		s++, base = 8;
  800abf:	42                   	inc    %edx
  800ac0:	b3 08                	mov    $0x8,%bl
  800ac2:	eb 05                	jmp    800ac9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ac4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ac9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ace:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad0:	8a 0a                	mov    (%edx),%cl
  800ad2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ad5:	80 fb 09             	cmp    $0x9,%bl
  800ad8:	77 08                	ja     800ae2 <strtol+0x82>
			dig = *s - '0';
  800ada:	0f be c9             	movsbl %cl,%ecx
  800add:	83 e9 30             	sub    $0x30,%ecx
  800ae0:	eb 1e                	jmp    800b00 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ae2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ae5:	80 fb 19             	cmp    $0x19,%bl
  800ae8:	77 08                	ja     800af2 <strtol+0x92>
			dig = *s - 'a' + 10;
  800aea:	0f be c9             	movsbl %cl,%ecx
  800aed:	83 e9 57             	sub    $0x57,%ecx
  800af0:	eb 0e                	jmp    800b00 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800af2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800af5:	80 fb 19             	cmp    $0x19,%bl
  800af8:	77 12                	ja     800b0c <strtol+0xac>
			dig = *s - 'A' + 10;
  800afa:	0f be c9             	movsbl %cl,%ecx
  800afd:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b00:	39 f1                	cmp    %esi,%ecx
  800b02:	7d 0c                	jge    800b10 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b04:	42                   	inc    %edx
  800b05:	0f af c6             	imul   %esi,%eax
  800b08:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b0a:	eb c4                	jmp    800ad0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b0c:	89 c1                	mov    %eax,%ecx
  800b0e:	eb 02                	jmp    800b12 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b10:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b12:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b16:	74 05                	je     800b1d <strtol+0xbd>
		*endptr = (char *) s;
  800b18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b1b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b1d:	85 ff                	test   %edi,%edi
  800b1f:	74 04                	je     800b25 <strtol+0xc5>
  800b21:	89 c8                	mov    %ecx,%eax
  800b23:	f7 d8                	neg    %eax
}
  800b25:	5b                   	pop    %ebx
  800b26:	5e                   	pop    %esi
  800b27:	5f                   	pop    %edi
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    
	...

00800b2c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b32:	b8 00 00 00 00       	mov    $0x0,%eax
  800b37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3d:	89 c3                	mov    %eax,%ebx
  800b3f:	89 c7                	mov    %eax,%edi
  800b41:	89 c6                	mov    %eax,%esi
  800b43:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <sys_cgetc>:

int
sys_cgetc(void)
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
  800b55:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5a:	89 d1                	mov    %edx,%ecx
  800b5c:	89 d3                	mov    %edx,%ebx
  800b5e:	89 d7                	mov    %edx,%edi
  800b60:	89 d6                	mov    %edx,%esi
  800b62:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800b72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b77:	b8 03 00 00 00       	mov    $0x3,%eax
  800b7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7f:	89 cb                	mov    %ecx,%ebx
  800b81:	89 cf                	mov    %ecx,%edi
  800b83:	89 ce                	mov    %ecx,%esi
  800b85:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b87:	85 c0                	test   %eax,%eax
  800b89:	7e 28                	jle    800bb3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b8f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b96:	00 
  800b97:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800b9e:	00 
  800b9f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ba6:	00 
  800ba7:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  800bae:	e8 ad f5 ff ff       	call   800160 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb3:	83 c4 2c             	add    $0x2c,%esp
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc6:	b8 02 00 00 00       	mov    $0x2,%eax
  800bcb:	89 d1                	mov    %edx,%ecx
  800bcd:	89 d3                	mov    %edx,%ebx
  800bcf:	89 d7                	mov    %edx,%edi
  800bd1:	89 d6                	mov    %edx,%esi
  800bd3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <sys_yield>:

void
sys_yield(void)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be0:	ba 00 00 00 00       	mov    $0x0,%edx
  800be5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bea:	89 d1                	mov    %edx,%ecx
  800bec:	89 d3                	mov    %edx,%ebx
  800bee:	89 d7                	mov    %edx,%edi
  800bf0:	89 d6                	mov    %edx,%esi
  800bf2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c02:	be 00 00 00 00       	mov    $0x0,%esi
  800c07:	b8 04 00 00 00       	mov    $0x4,%eax
  800c0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	89 f7                	mov    %esi,%edi
  800c17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c19:	85 c0                	test   %eax,%eax
  800c1b:	7e 28                	jle    800c45 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c21:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c28:	00 
  800c29:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800c30:	00 
  800c31:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c38:	00 
  800c39:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  800c40:	e8 1b f5 ff ff       	call   800160 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c45:	83 c4 2c             	add    $0x2c,%esp
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	57                   	push   %edi
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
  800c53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c56:	b8 05 00 00 00       	mov    $0x5,%eax
  800c5b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c5e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	7e 28                	jle    800c98 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c70:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c74:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c7b:	00 
  800c7c:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800c83:	00 
  800c84:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8b:	00 
  800c8c:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  800c93:	e8 c8 f4 ff ff       	call   800160 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c98:	83 c4 2c             	add    $0x2c,%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
  800ca6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cae:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb9:	89 df                	mov    %ebx,%edi
  800cbb:	89 de                	mov    %ebx,%esi
  800cbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cbf:	85 c0                	test   %eax,%eax
  800cc1:	7e 28                	jle    800ceb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cce:	00 
  800ccf:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800cd6:	00 
  800cd7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cde:	00 
  800cdf:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  800ce6:	e8 75 f4 ff ff       	call   800160 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ceb:	83 c4 2c             	add    $0x2c,%esp
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	57                   	push   %edi
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
  800cf9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d01:	b8 08 00 00 00       	mov    $0x8,%eax
  800d06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d09:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0c:	89 df                	mov    %ebx,%edi
  800d0e:	89 de                	mov    %ebx,%esi
  800d10:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d12:	85 c0                	test   %eax,%eax
  800d14:	7e 28                	jle    800d3e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d16:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d21:	00 
  800d22:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800d29:	00 
  800d2a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d31:	00 
  800d32:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  800d39:	e8 22 f4 ff ff       	call   800160 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d3e:	83 c4 2c             	add    $0x2c,%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	57                   	push   %edi
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
  800d4c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d54:	b8 09 00 00 00       	mov    $0x9,%eax
  800d59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5f:	89 df                	mov    %ebx,%edi
  800d61:	89 de                	mov    %ebx,%esi
  800d63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d65:	85 c0                	test   %eax,%eax
  800d67:	7e 28                	jle    800d91 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d69:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d74:	00 
  800d75:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800d7c:	00 
  800d7d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d84:	00 
  800d85:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  800d8c:	e8 cf f3 ff ff       	call   800160 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d91:	83 c4 2c             	add    $0x2c,%esp
  800d94:	5b                   	pop    %ebx
  800d95:	5e                   	pop    %esi
  800d96:	5f                   	pop    %edi
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    

00800d99 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	57                   	push   %edi
  800d9d:	56                   	push   %esi
  800d9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9f:	be 00 00 00 00       	mov    $0x0,%esi
  800da4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800da9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	57                   	push   %edi
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
  800dc2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dca:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd2:	89 cb                	mov    %ecx,%ebx
  800dd4:	89 cf                	mov    %ecx,%edi
  800dd6:	89 ce                	mov    %ecx,%esi
  800dd8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	7e 28                	jle    800e06 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dde:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de2:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800de9:	00 
  800dea:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800df1:	00 
  800df2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df9:	00 
  800dfa:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  800e01:	e8 5a f3 ff ff       	call   800160 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e06:	83 c4 2c             	add    $0x2c,%esp
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e24:	8b 55 08             	mov    0x8(%ebp),%edx
  800e27:	89 df                	mov    %ebx,%edi
  800e29:	89 de                	mov    %ebx,%esi
  800e2b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	7e 28                	jle    800e59 <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e31:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e35:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e3c:	00 
  800e3d:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800e44:	00 
  800e45:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4c:	00 
  800e4d:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  800e54:	e8 07 f3 ff ff       	call   800160 <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800e59:	83 c4 2c             	add    $0x2c,%esp
  800e5c:	5b                   	pop    %ebx
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <sys_env_set_debug_upcall>:

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	57                   	push   %edi
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
  800e67:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e77:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7a:	89 df                	mov    %ebx,%edi
  800e7c:	89 de                	mov    %ebx,%esi
  800e7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e80:	85 c0                	test   %eax,%eax
  800e82:	7e 28                	jle    800eac <sys_env_set_debug_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e84:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e88:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800e8f:	00 
  800e90:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800e97:	00 
  800e98:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9f:	00 
  800ea0:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  800ea7:	e8 b4 f2 ff ff       	call   800160 <_panic>
}

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_debug_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800eac:	83 c4 2c             	add    $0x2c,%esp
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <sys_env_set_nmskint_upcall>:

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	57                   	push   %edi
  800eb8:	56                   	push   %esi
  800eb9:	53                   	push   %ebx
  800eba:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec2:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ec7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecd:	89 df                	mov    %ebx,%edi
  800ecf:	89 de                	mov    %ebx,%esi
  800ed1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	7e 28                	jle    800eff <sys_env_set_nmskint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800edb:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800ee2:	00 
  800ee3:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800eea:	00 
  800eeb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef2:	00 
  800ef3:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  800efa:	e8 61 f2 ff ff       	call   800160 <_panic>
}

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_nmskint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800eff:	83 c4 2c             	add    $0x2c,%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_env_set_bpoint_upcall>:

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	57                   	push   %edi
  800f0b:	56                   	push   %esi
  800f0c:	53                   	push   %ebx
  800f0d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f15:	b8 10 00 00 00       	mov    $0x10,%eax
  800f1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f20:	89 df                	mov    %ebx,%edi
  800f22:	89 de                	mov    %ebx,%esi
  800f24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f26:	85 c0                	test   %eax,%eax
  800f28:	7e 28                	jle    800f52 <sys_env_set_bpoint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800f35:	00 
  800f36:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800f3d:	00 
  800f3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f45:	00 
  800f46:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  800f4d:	e8 0e f2 ff ff       	call   800160 <_panic>
}

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bpoint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800f52:	83 c4 2c             	add    $0x2c,%esp
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5f                   	pop    %edi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    

00800f5a <sys_env_set_oflow_upcall>:

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	57                   	push   %edi
  800f5e:	56                   	push   %esi
  800f5f:	53                   	push   %ebx
  800f60:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f68:	b8 11 00 00 00       	mov    $0x11,%eax
  800f6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f70:	8b 55 08             	mov    0x8(%ebp),%edx
  800f73:	89 df                	mov    %ebx,%edi
  800f75:	89 de                	mov    %ebx,%esi
  800f77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	7e 28                	jle    800fa5 <sys_env_set_oflow_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f81:	c7 44 24 0c 11 00 00 	movl   $0x11,0xc(%esp)
  800f88:	00 
  800f89:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800f90:	00 
  800f91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f98:	00 
  800f99:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  800fa0:	e8 bb f1 ff ff       	call   800160 <_panic>
}

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_oflow_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800fa5:	83 c4 2c             	add    $0x2c,%esp
  800fa8:	5b                   	pop    %ebx
  800fa9:	5e                   	pop    %esi
  800faa:	5f                   	pop    %edi
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    

00800fad <sys_env_set_bdschk_upcall>:

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	57                   	push   %edi
  800fb1:	56                   	push   %esi
  800fb2:	53                   	push   %ebx
  800fb3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fbb:	b8 12 00 00 00       	mov    $0x12,%eax
  800fc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc6:	89 df                	mov    %ebx,%edi
  800fc8:	89 de                	mov    %ebx,%esi
  800fca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	7e 28                	jle    800ff8 <sys_env_set_bdschk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd4:	c7 44 24 0c 12 00 00 	movl   $0x12,0xc(%esp)
  800fdb:	00 
  800fdc:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800fe3:	00 
  800fe4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800feb:	00 
  800fec:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  800ff3:	e8 68 f1 ff ff       	call   800160 <_panic>
}

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bdschk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800ff8:	83 c4 2c             	add    $0x2c,%esp
  800ffb:	5b                   	pop    %ebx
  800ffc:	5e                   	pop    %esi
  800ffd:	5f                   	pop    %edi
  800ffe:	5d                   	pop    %ebp
  800fff:	c3                   	ret    

00801000 <sys_env_set_illopcd_upcall>:

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	57                   	push   %edi
  801004:	56                   	push   %esi
  801005:	53                   	push   %ebx
  801006:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801009:	bb 00 00 00 00       	mov    $0x0,%ebx
  80100e:	b8 13 00 00 00       	mov    $0x13,%eax
  801013:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801016:	8b 55 08             	mov    0x8(%ebp),%edx
  801019:	89 df                	mov    %ebx,%edi
  80101b:	89 de                	mov    %ebx,%esi
  80101d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80101f:	85 c0                	test   %eax,%eax
  801021:	7e 28                	jle    80104b <sys_env_set_illopcd_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801023:	89 44 24 10          	mov    %eax,0x10(%esp)
  801027:	c7 44 24 0c 13 00 00 	movl   $0x13,0xc(%esp)
  80102e:	00 
  80102f:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  801036:	00 
  801037:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80103e:	00 
  80103f:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  801046:	e8 15 f1 ff ff       	call   800160 <_panic>
}

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_illopcd_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80104b:	83 c4 2c             	add    $0x2c,%esp
  80104e:	5b                   	pop    %ebx
  80104f:	5e                   	pop    %esi
  801050:	5f                   	pop    %edi
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <sys_env_set_dvcntavl_upcall>:

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	57                   	push   %edi
  801057:	56                   	push   %esi
  801058:	53                   	push   %ebx
  801059:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801061:	b8 14 00 00 00       	mov    $0x14,%eax
  801066:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801069:	8b 55 08             	mov    0x8(%ebp),%edx
  80106c:	89 df                	mov    %ebx,%edi
  80106e:	89 de                	mov    %ebx,%esi
  801070:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801072:	85 c0                	test   %eax,%eax
  801074:	7e 28                	jle    80109e <sys_env_set_dvcntavl_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801076:	89 44 24 10          	mov    %eax,0x10(%esp)
  80107a:	c7 44 24 0c 14 00 00 	movl   $0x14,0xc(%esp)
  801081:	00 
  801082:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  801089:	00 
  80108a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801091:	00 
  801092:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  801099:	e8 c2 f0 ff ff       	call   800160 <_panic>
}

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dvcntavl_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80109e:	83 c4 2c             	add    $0x2c,%esp
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5f                   	pop    %edi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <sys_env_set_dbfault_upcall>:

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	57                   	push   %edi
  8010aa:	56                   	push   %esi
  8010ab:	53                   	push   %ebx
  8010ac:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b4:	b8 15 00 00 00       	mov    $0x15,%eax
  8010b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bf:	89 df                	mov    %ebx,%edi
  8010c1:	89 de                	mov    %ebx,%esi
  8010c3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	7e 28                	jle    8010f1 <sys_env_set_dbfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010cd:	c7 44 24 0c 15 00 00 	movl   $0x15,0xc(%esp)
  8010d4:	00 
  8010d5:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  8010dc:	00 
  8010dd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010e4:	00 
  8010e5:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  8010ec:	e8 6f f0 ff ff       	call   800160 <_panic>
}

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dbfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8010f1:	83 c4 2c             	add    $0x2c,%esp
  8010f4:	5b                   	pop    %ebx
  8010f5:	5e                   	pop    %esi
  8010f6:	5f                   	pop    %edi
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    

008010f9 <sys_env_set_ivldtss_upcall>:

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	57                   	push   %edi
  8010fd:	56                   	push   %esi
  8010fe:	53                   	push   %ebx
  8010ff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801102:	bb 00 00 00 00       	mov    $0x0,%ebx
  801107:	b8 16 00 00 00       	mov    $0x16,%eax
  80110c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80110f:	8b 55 08             	mov    0x8(%ebp),%edx
  801112:	89 df                	mov    %ebx,%edi
  801114:	89 de                	mov    %ebx,%esi
  801116:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801118:	85 c0                	test   %eax,%eax
  80111a:	7e 28                	jle    801144 <sys_env_set_ivldtss_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80111c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801120:	c7 44 24 0c 16 00 00 	movl   $0x16,0xc(%esp)
  801127:	00 
  801128:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  80112f:	00 
  801130:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801137:	00 
  801138:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  80113f:	e8 1c f0 ff ff       	call   800160 <_panic>
}

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_ivldtss_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801144:	83 c4 2c             	add    $0x2c,%esp
  801147:	5b                   	pop    %ebx
  801148:	5e                   	pop    %esi
  801149:	5f                   	pop    %edi
  80114a:	5d                   	pop    %ebp
  80114b:	c3                   	ret    

0080114c <sys_env_set_segntprst_upcall>:

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
  80114f:	57                   	push   %edi
  801150:	56                   	push   %esi
  801151:	53                   	push   %ebx
  801152:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801155:	bb 00 00 00 00       	mov    $0x0,%ebx
  80115a:	b8 17 00 00 00       	mov    $0x17,%eax
  80115f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801162:	8b 55 08             	mov    0x8(%ebp),%edx
  801165:	89 df                	mov    %ebx,%edi
  801167:	89 de                	mov    %ebx,%esi
  801169:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80116b:	85 c0                	test   %eax,%eax
  80116d:	7e 28                	jle    801197 <sys_env_set_segntprst_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80116f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801173:	c7 44 24 0c 17 00 00 	movl   $0x17,0xc(%esp)
  80117a:	00 
  80117b:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  801182:	00 
  801183:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80118a:	00 
  80118b:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  801192:	e8 c9 ef ff ff       	call   800160 <_panic>
}

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_segntprst_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801197:	83 c4 2c             	add    $0x2c,%esp
  80119a:	5b                   	pop    %ebx
  80119b:	5e                   	pop    %esi
  80119c:	5f                   	pop    %edi
  80119d:	5d                   	pop    %ebp
  80119e:	c3                   	ret    

0080119f <sys_env_set_stkexception_upcall>:

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	57                   	push   %edi
  8011a3:	56                   	push   %esi
  8011a4:	53                   	push   %ebx
  8011a5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ad:	b8 18 00 00 00       	mov    $0x18,%eax
  8011b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b8:	89 df                	mov    %ebx,%edi
  8011ba:	89 de                	mov    %ebx,%esi
  8011bc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	7e 28                	jle    8011ea <sys_env_set_stkexception_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c6:	c7 44 24 0c 18 00 00 	movl   $0x18,0xc(%esp)
  8011cd:	00 
  8011ce:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  8011d5:	00 
  8011d6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011dd:	00 
  8011de:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  8011e5:	e8 76 ef ff ff       	call   800160 <_panic>
}

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_stkexception_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8011ea:	83 c4 2c             	add    $0x2c,%esp
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5f                   	pop    %edi
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <sys_env_set_gpfault_upcall>:

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	57                   	push   %edi
  8011f6:	56                   	push   %esi
  8011f7:	53                   	push   %ebx
  8011f8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801200:	b8 19 00 00 00       	mov    $0x19,%eax
  801205:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801208:	8b 55 08             	mov    0x8(%ebp),%edx
  80120b:	89 df                	mov    %ebx,%edi
  80120d:	89 de                	mov    %ebx,%esi
  80120f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801211:	85 c0                	test   %eax,%eax
  801213:	7e 28                	jle    80123d <sys_env_set_gpfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801215:	89 44 24 10          	mov    %eax,0x10(%esp)
  801219:	c7 44 24 0c 19 00 00 	movl   $0x19,0xc(%esp)
  801220:	00 
  801221:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  801228:	00 
  801229:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801230:	00 
  801231:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  801238:	e8 23 ef ff ff       	call   800160 <_panic>
}

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_gpfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80123d:	83 c4 2c             	add    $0x2c,%esp
  801240:	5b                   	pop    %ebx
  801241:	5e                   	pop    %esi
  801242:	5f                   	pop    %edi
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    

00801245 <sys_env_set_fperror_upcall>:

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	57                   	push   %edi
  801249:	56                   	push   %esi
  80124a:	53                   	push   %ebx
  80124b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80124e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801253:	b8 1a 00 00 00       	mov    $0x1a,%eax
  801258:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80125b:	8b 55 08             	mov    0x8(%ebp),%edx
  80125e:	89 df                	mov    %ebx,%edi
  801260:	89 de                	mov    %ebx,%esi
  801262:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801264:	85 c0                	test   %eax,%eax
  801266:	7e 28                	jle    801290 <sys_env_set_fperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801268:	89 44 24 10          	mov    %eax,0x10(%esp)
  80126c:	c7 44 24 0c 1a 00 00 	movl   $0x1a,0xc(%esp)
  801273:	00 
  801274:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  80127b:	00 
  80127c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801283:	00 
  801284:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  80128b:	e8 d0 ee ff ff       	call   800160 <_panic>
}

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_fperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801290:	83 c4 2c             	add    $0x2c,%esp
  801293:	5b                   	pop    %ebx
  801294:	5e                   	pop    %esi
  801295:	5f                   	pop    %edi
  801296:	5d                   	pop    %ebp
  801297:	c3                   	ret    

00801298 <sys_env_set_algchk_upcall>:

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	57                   	push   %edi
  80129c:	56                   	push   %esi
  80129d:	53                   	push   %ebx
  80129e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012a6:	b8 1b 00 00 00       	mov    $0x1b,%eax
  8012ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b1:	89 df                	mov    %ebx,%edi
  8012b3:	89 de                	mov    %ebx,%esi
  8012b5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	7e 28                	jle    8012e3 <sys_env_set_algchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012bb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012bf:	c7 44 24 0c 1b 00 00 	movl   $0x1b,0xc(%esp)
  8012c6:	00 
  8012c7:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  8012ce:	00 
  8012cf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012d6:	00 
  8012d7:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  8012de:	e8 7d ee ff ff       	call   800160 <_panic>
}

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_algchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8012e3:	83 c4 2c             	add    $0x2c,%esp
  8012e6:	5b                   	pop    %ebx
  8012e7:	5e                   	pop    %esi
  8012e8:	5f                   	pop    %edi
  8012e9:	5d                   	pop    %ebp
  8012ea:	c3                   	ret    

008012eb <sys_env_set_mchchk_upcall>:

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
  8012eb:	55                   	push   %ebp
  8012ec:	89 e5                	mov    %esp,%ebp
  8012ee:	57                   	push   %edi
  8012ef:	56                   	push   %esi
  8012f0:	53                   	push   %ebx
  8012f1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012f9:	b8 1c 00 00 00       	mov    $0x1c,%eax
  8012fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801301:	8b 55 08             	mov    0x8(%ebp),%edx
  801304:	89 df                	mov    %ebx,%edi
  801306:	89 de                	mov    %ebx,%esi
  801308:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80130a:	85 c0                	test   %eax,%eax
  80130c:	7e 28                	jle    801336 <sys_env_set_mchchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80130e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801312:	c7 44 24 0c 1c 00 00 	movl   $0x1c,0xc(%esp)
  801319:	00 
  80131a:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  801321:	00 
  801322:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801329:	00 
  80132a:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  801331:	e8 2a ee ff ff       	call   800160 <_panic>
}

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_mchchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801336:	83 c4 2c             	add    $0x2c,%esp
  801339:	5b                   	pop    %ebx
  80133a:	5e                   	pop    %esi
  80133b:	5f                   	pop    %edi
  80133c:	5d                   	pop    %ebp
  80133d:	c3                   	ret    

0080133e <sys_env_set_SIMDfperror_upcall>:

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	57                   	push   %edi
  801342:	56                   	push   %esi
  801343:	53                   	push   %ebx
  801344:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801347:	bb 00 00 00 00       	mov    $0x0,%ebx
  80134c:	b8 1d 00 00 00       	mov    $0x1d,%eax
  801351:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801354:	8b 55 08             	mov    0x8(%ebp),%edx
  801357:	89 df                	mov    %ebx,%edi
  801359:	89 de                	mov    %ebx,%esi
  80135b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80135d:	85 c0                	test   %eax,%eax
  80135f:	7e 28                	jle    801389 <sys_env_set_SIMDfperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801361:	89 44 24 10          	mov    %eax,0x10(%esp)
  801365:	c7 44 24 0c 1d 00 00 	movl   $0x1d,0xc(%esp)
  80136c:	00 
  80136d:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  801374:	00 
  801375:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80137c:	00 
  80137d:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  801384:	e8 d7 ed ff ff       	call   800160 <_panic>
}

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_SIMDfperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801389:	83 c4 2c             	add    $0x2c,%esp
  80138c:	5b                   	pop    %ebx
  80138d:	5e                   	pop    %esi
  80138e:	5f                   	pop    %edi
  80138f:	5d                   	pop    %ebp
  801390:	c3                   	ret    
  801391:	00 00                	add    %al,(%eax)
	...

00801394 <__udivdi3>:
  801394:	55                   	push   %ebp
  801395:	57                   	push   %edi
  801396:	56                   	push   %esi
  801397:	83 ec 10             	sub    $0x10,%esp
  80139a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80139e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8013a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013a6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8013aa:	89 cd                	mov    %ecx,%ebp
  8013ac:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	75 2c                	jne    8013e0 <__udivdi3+0x4c>
  8013b4:	39 f9                	cmp    %edi,%ecx
  8013b6:	77 68                	ja     801420 <__udivdi3+0x8c>
  8013b8:	85 c9                	test   %ecx,%ecx
  8013ba:	75 0b                	jne    8013c7 <__udivdi3+0x33>
  8013bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8013c1:	31 d2                	xor    %edx,%edx
  8013c3:	f7 f1                	div    %ecx
  8013c5:	89 c1                	mov    %eax,%ecx
  8013c7:	31 d2                	xor    %edx,%edx
  8013c9:	89 f8                	mov    %edi,%eax
  8013cb:	f7 f1                	div    %ecx
  8013cd:	89 c7                	mov    %eax,%edi
  8013cf:	89 f0                	mov    %esi,%eax
  8013d1:	f7 f1                	div    %ecx
  8013d3:	89 c6                	mov    %eax,%esi
  8013d5:	89 f0                	mov    %esi,%eax
  8013d7:	89 fa                	mov    %edi,%edx
  8013d9:	83 c4 10             	add    $0x10,%esp
  8013dc:	5e                   	pop    %esi
  8013dd:	5f                   	pop    %edi
  8013de:	5d                   	pop    %ebp
  8013df:	c3                   	ret    
  8013e0:	39 f8                	cmp    %edi,%eax
  8013e2:	77 2c                	ja     801410 <__udivdi3+0x7c>
  8013e4:	0f bd f0             	bsr    %eax,%esi
  8013e7:	83 f6 1f             	xor    $0x1f,%esi
  8013ea:	75 4c                	jne    801438 <__udivdi3+0xa4>
  8013ec:	39 f8                	cmp    %edi,%eax
  8013ee:	bf 00 00 00 00       	mov    $0x0,%edi
  8013f3:	72 0a                	jb     8013ff <__udivdi3+0x6b>
  8013f5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8013f9:	0f 87 ad 00 00 00    	ja     8014ac <__udivdi3+0x118>
  8013ff:	be 01 00 00 00       	mov    $0x1,%esi
  801404:	89 f0                	mov    %esi,%eax
  801406:	89 fa                	mov    %edi,%edx
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	5e                   	pop    %esi
  80140c:	5f                   	pop    %edi
  80140d:	5d                   	pop    %ebp
  80140e:	c3                   	ret    
  80140f:	90                   	nop
  801410:	31 ff                	xor    %edi,%edi
  801412:	31 f6                	xor    %esi,%esi
  801414:	89 f0                	mov    %esi,%eax
  801416:	89 fa                	mov    %edi,%edx
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	5e                   	pop    %esi
  80141c:	5f                   	pop    %edi
  80141d:	5d                   	pop    %ebp
  80141e:	c3                   	ret    
  80141f:	90                   	nop
  801420:	89 fa                	mov    %edi,%edx
  801422:	89 f0                	mov    %esi,%eax
  801424:	f7 f1                	div    %ecx
  801426:	89 c6                	mov    %eax,%esi
  801428:	31 ff                	xor    %edi,%edi
  80142a:	89 f0                	mov    %esi,%eax
  80142c:	89 fa                	mov    %edi,%edx
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	5e                   	pop    %esi
  801432:	5f                   	pop    %edi
  801433:	5d                   	pop    %ebp
  801434:	c3                   	ret    
  801435:	8d 76 00             	lea    0x0(%esi),%esi
  801438:	89 f1                	mov    %esi,%ecx
  80143a:	d3 e0                	shl    %cl,%eax
  80143c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801440:	b8 20 00 00 00       	mov    $0x20,%eax
  801445:	29 f0                	sub    %esi,%eax
  801447:	89 ea                	mov    %ebp,%edx
  801449:	88 c1                	mov    %al,%cl
  80144b:	d3 ea                	shr    %cl,%edx
  80144d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801451:	09 ca                	or     %ecx,%edx
  801453:	89 54 24 08          	mov    %edx,0x8(%esp)
  801457:	89 f1                	mov    %esi,%ecx
  801459:	d3 e5                	shl    %cl,%ebp
  80145b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80145f:	89 fd                	mov    %edi,%ebp
  801461:	88 c1                	mov    %al,%cl
  801463:	d3 ed                	shr    %cl,%ebp
  801465:	89 fa                	mov    %edi,%edx
  801467:	89 f1                	mov    %esi,%ecx
  801469:	d3 e2                	shl    %cl,%edx
  80146b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80146f:	88 c1                	mov    %al,%cl
  801471:	d3 ef                	shr    %cl,%edi
  801473:	09 d7                	or     %edx,%edi
  801475:	89 f8                	mov    %edi,%eax
  801477:	89 ea                	mov    %ebp,%edx
  801479:	f7 74 24 08          	divl   0x8(%esp)
  80147d:	89 d1                	mov    %edx,%ecx
  80147f:	89 c7                	mov    %eax,%edi
  801481:	f7 64 24 0c          	mull   0xc(%esp)
  801485:	39 d1                	cmp    %edx,%ecx
  801487:	72 17                	jb     8014a0 <__udivdi3+0x10c>
  801489:	74 09                	je     801494 <__udivdi3+0x100>
  80148b:	89 fe                	mov    %edi,%esi
  80148d:	31 ff                	xor    %edi,%edi
  80148f:	e9 41 ff ff ff       	jmp    8013d5 <__udivdi3+0x41>
  801494:	8b 54 24 04          	mov    0x4(%esp),%edx
  801498:	89 f1                	mov    %esi,%ecx
  80149a:	d3 e2                	shl    %cl,%edx
  80149c:	39 c2                	cmp    %eax,%edx
  80149e:	73 eb                	jae    80148b <__udivdi3+0xf7>
  8014a0:	8d 77 ff             	lea    -0x1(%edi),%esi
  8014a3:	31 ff                	xor    %edi,%edi
  8014a5:	e9 2b ff ff ff       	jmp    8013d5 <__udivdi3+0x41>
  8014aa:	66 90                	xchg   %ax,%ax
  8014ac:	31 f6                	xor    %esi,%esi
  8014ae:	e9 22 ff ff ff       	jmp    8013d5 <__udivdi3+0x41>
	...

008014b4 <__umoddi3>:
  8014b4:	55                   	push   %ebp
  8014b5:	57                   	push   %edi
  8014b6:	56                   	push   %esi
  8014b7:	83 ec 20             	sub    $0x20,%esp
  8014ba:	8b 44 24 30          	mov    0x30(%esp),%eax
  8014be:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8014c2:	89 44 24 14          	mov    %eax,0x14(%esp)
  8014c6:	8b 74 24 34          	mov    0x34(%esp),%esi
  8014ca:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8014ce:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8014d2:	89 c7                	mov    %eax,%edi
  8014d4:	89 f2                	mov    %esi,%edx
  8014d6:	85 ed                	test   %ebp,%ebp
  8014d8:	75 16                	jne    8014f0 <__umoddi3+0x3c>
  8014da:	39 f1                	cmp    %esi,%ecx
  8014dc:	0f 86 a6 00 00 00    	jbe    801588 <__umoddi3+0xd4>
  8014e2:	f7 f1                	div    %ecx
  8014e4:	89 d0                	mov    %edx,%eax
  8014e6:	31 d2                	xor    %edx,%edx
  8014e8:	83 c4 20             	add    $0x20,%esp
  8014eb:	5e                   	pop    %esi
  8014ec:	5f                   	pop    %edi
  8014ed:	5d                   	pop    %ebp
  8014ee:	c3                   	ret    
  8014ef:	90                   	nop
  8014f0:	39 f5                	cmp    %esi,%ebp
  8014f2:	0f 87 ac 00 00 00    	ja     8015a4 <__umoddi3+0xf0>
  8014f8:	0f bd c5             	bsr    %ebp,%eax
  8014fb:	83 f0 1f             	xor    $0x1f,%eax
  8014fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  801502:	0f 84 a8 00 00 00    	je     8015b0 <__umoddi3+0xfc>
  801508:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80150c:	d3 e5                	shl    %cl,%ebp
  80150e:	bf 20 00 00 00       	mov    $0x20,%edi
  801513:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801517:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80151b:	89 f9                	mov    %edi,%ecx
  80151d:	d3 e8                	shr    %cl,%eax
  80151f:	09 e8                	or     %ebp,%eax
  801521:	89 44 24 18          	mov    %eax,0x18(%esp)
  801525:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801529:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80152d:	d3 e0                	shl    %cl,%eax
  80152f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801533:	89 f2                	mov    %esi,%edx
  801535:	d3 e2                	shl    %cl,%edx
  801537:	8b 44 24 14          	mov    0x14(%esp),%eax
  80153b:	d3 e0                	shl    %cl,%eax
  80153d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801541:	8b 44 24 14          	mov    0x14(%esp),%eax
  801545:	89 f9                	mov    %edi,%ecx
  801547:	d3 e8                	shr    %cl,%eax
  801549:	09 d0                	or     %edx,%eax
  80154b:	d3 ee                	shr    %cl,%esi
  80154d:	89 f2                	mov    %esi,%edx
  80154f:	f7 74 24 18          	divl   0x18(%esp)
  801553:	89 d6                	mov    %edx,%esi
  801555:	f7 64 24 0c          	mull   0xc(%esp)
  801559:	89 c5                	mov    %eax,%ebp
  80155b:	89 d1                	mov    %edx,%ecx
  80155d:	39 d6                	cmp    %edx,%esi
  80155f:	72 67                	jb     8015c8 <__umoddi3+0x114>
  801561:	74 75                	je     8015d8 <__umoddi3+0x124>
  801563:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801567:	29 e8                	sub    %ebp,%eax
  801569:	19 ce                	sbb    %ecx,%esi
  80156b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80156f:	d3 e8                	shr    %cl,%eax
  801571:	89 f2                	mov    %esi,%edx
  801573:	89 f9                	mov    %edi,%ecx
  801575:	d3 e2                	shl    %cl,%edx
  801577:	09 d0                	or     %edx,%eax
  801579:	89 f2                	mov    %esi,%edx
  80157b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80157f:	d3 ea                	shr    %cl,%edx
  801581:	83 c4 20             	add    $0x20,%esp
  801584:	5e                   	pop    %esi
  801585:	5f                   	pop    %edi
  801586:	5d                   	pop    %ebp
  801587:	c3                   	ret    
  801588:	85 c9                	test   %ecx,%ecx
  80158a:	75 0b                	jne    801597 <__umoddi3+0xe3>
  80158c:	b8 01 00 00 00       	mov    $0x1,%eax
  801591:	31 d2                	xor    %edx,%edx
  801593:	f7 f1                	div    %ecx
  801595:	89 c1                	mov    %eax,%ecx
  801597:	89 f0                	mov    %esi,%eax
  801599:	31 d2                	xor    %edx,%edx
  80159b:	f7 f1                	div    %ecx
  80159d:	89 f8                	mov    %edi,%eax
  80159f:	e9 3e ff ff ff       	jmp    8014e2 <__umoddi3+0x2e>
  8015a4:	89 f2                	mov    %esi,%edx
  8015a6:	83 c4 20             	add    $0x20,%esp
  8015a9:	5e                   	pop    %esi
  8015aa:	5f                   	pop    %edi
  8015ab:	5d                   	pop    %ebp
  8015ac:	c3                   	ret    
  8015ad:	8d 76 00             	lea    0x0(%esi),%esi
  8015b0:	39 f5                	cmp    %esi,%ebp
  8015b2:	72 04                	jb     8015b8 <__umoddi3+0x104>
  8015b4:	39 f9                	cmp    %edi,%ecx
  8015b6:	77 06                	ja     8015be <__umoddi3+0x10a>
  8015b8:	89 f2                	mov    %esi,%edx
  8015ba:	29 cf                	sub    %ecx,%edi
  8015bc:	19 ea                	sbb    %ebp,%edx
  8015be:	89 f8                	mov    %edi,%eax
  8015c0:	83 c4 20             	add    $0x20,%esp
  8015c3:	5e                   	pop    %esi
  8015c4:	5f                   	pop    %edi
  8015c5:	5d                   	pop    %ebp
  8015c6:	c3                   	ret    
  8015c7:	90                   	nop
  8015c8:	89 d1                	mov    %edx,%ecx
  8015ca:	89 c5                	mov    %eax,%ebp
  8015cc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8015d0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8015d4:	eb 8d                	jmp    801563 <__umoddi3+0xaf>
  8015d6:	66 90                	xchg   %ax,%ax
  8015d8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8015dc:	72 ea                	jb     8015c8 <__umoddi3+0x114>
  8015de:	89 f1                	mov    %esi,%ecx
  8015e0:	eb 81                	jmp    801563 <__umoddi3+0xaf>
