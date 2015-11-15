
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 d3 00 00 00       	call   800104 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  80003c:	e8 82 0b 00 00       	call   800bc3 <sys_getenvid>
  800041:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800043:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800048:	e8 62 0f 00 00       	call   800faf <fork>
  80004d:	85 c0                	test   %eax,%eax
  80004f:	74 08                	je     800059 <umain+0x25>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  800051:	43                   	inc    %ebx
  800052:	83 fb 14             	cmp    $0x14,%ebx
  800055:	75 f1                	jne    800048 <umain+0x14>
  800057:	eb 05                	jmp    80005e <umain+0x2a>
		if (fork() == 0)
			break;
	if (i == 20) {
  800059:	83 fb 14             	cmp    $0x14,%ebx
  80005c:	75 0e                	jne    80006c <umain+0x38>
		sys_yield();
  80005e:	e8 7f 0b 00 00       	call   800be2 <sys_yield>
		return;
  800063:	e9 92 00 00 00       	jmp    8000fa <umain+0xc6>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800068:	f3 90                	pause  
  80006a:	eb 15                	jmp    800081 <umain+0x4d>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800072:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800075:	8d 14 46             	lea    (%esi,%eax,2),%edx
  800078:	c1 e2 04             	shl    $0x4,%edx
  80007b:	81 c2 04 00 c0 ee    	add    $0xeec00004,%edx
  800081:	8b 42 50             	mov    0x50(%edx),%eax
  800084:	85 c0                	test   %eax,%eax
  800086:	75 e0                	jne    800068 <umain+0x34>
  800088:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  80008d:	e8 50 0b 00 00       	call   800be2 <sys_yield>
  800092:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  800097:	8b 15 08 20 80 00    	mov    0x802008,%edx
  80009d:	42                   	inc    %edx
  80009e:	89 15 08 20 80 00    	mov    %edx,0x802008
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000a4:	48                   	dec    %eax
  8000a5:	75 f0                	jne    800097 <umain+0x63>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a7:	4b                   	dec    %ebx
  8000a8:	75 e3                	jne    80008d <umain+0x59>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000aa:	a1 08 20 80 00       	mov    0x802008,%eax
  8000af:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b4:	74 25                	je     8000db <umain+0xa7>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b6:	a1 08 20 80 00       	mov    0x802008,%eax
  8000bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000bf:	c7 44 24 08 80 14 80 	movl   $0x801480,0x8(%esp)
  8000c6:	00 
  8000c7:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000ce:	00 
  8000cf:	c7 04 24 a8 14 80 00 	movl   $0x8014a8,(%esp)
  8000d6:	e8 8d 00 00 00       	call   800168 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000db:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8000e0:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000e3:	8b 40 48             	mov    0x48(%eax),%eax
  8000e6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ee:	c7 04 24 bb 14 80 00 	movl   $0x8014bb,(%esp)
  8000f5:	e8 66 01 00 00       	call   800260 <cprintf>

}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    
  800101:	00 00                	add    %al,(%eax)
	...

00800104 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	56                   	push   %esi
  800108:	53                   	push   %ebx
  800109:	83 ec 10             	sub    $0x10,%esp
  80010c:	8b 75 08             	mov    0x8(%ebp),%esi
  80010f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800112:	e8 ac 0a 00 00       	call   800bc3 <sys_getenvid>
  800117:	25 ff 03 00 00       	and    $0x3ff,%eax
  80011c:	8d 14 80             	lea    (%eax,%eax,4),%edx
  80011f:	8d 04 50             	lea    (%eax,%edx,2),%eax
  800122:	c1 e0 04             	shl    $0x4,%eax
  800125:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012a:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012f:	85 f6                	test   %esi,%esi
  800131:	7e 07                	jle    80013a <libmain+0x36>
		binaryname = argv[0];
  800133:	8b 03                	mov    (%ebx),%eax
  800135:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80013a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013e:	89 34 24             	mov    %esi,(%esp)
  800141:	e8 ee fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800146:	e8 09 00 00 00       	call   800154 <exit>
}
  80014b:	83 c4 10             	add    $0x10,%esp
  80014e:	5b                   	pop    %ebx
  80014f:	5e                   	pop    %esi
  800150:	5d                   	pop    %ebp
  800151:	c3                   	ret    
	...

00800154 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80015a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800161:	e8 0b 0a 00 00       	call   800b71 <sys_env_destroy>
}
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800170:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800173:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800179:	e8 45 0a 00 00       	call   800bc3 <sys_getenvid>
  80017e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800181:	89 54 24 10          	mov    %edx,0x10(%esp)
  800185:	8b 55 08             	mov    0x8(%ebp),%edx
  800188:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80018c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800190:	89 44 24 04          	mov    %eax,0x4(%esp)
  800194:	c7 04 24 e4 14 80 00 	movl   $0x8014e4,(%esp)
  80019b:	e8 c0 00 00 00       	call   800260 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a7:	89 04 24             	mov    %eax,(%esp)
  8001aa:	e8 50 00 00 00       	call   8001ff <vcprintf>
	cprintf("\n");
  8001af:	c7 04 24 d7 14 80 00 	movl   $0x8014d7,(%esp)
  8001b6:	e8 a5 00 00 00       	call   800260 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bb:	cc                   	int3   
  8001bc:	eb fd                	jmp    8001bb <_panic+0x53>
	...

008001c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	53                   	push   %ebx
  8001c4:	83 ec 14             	sub    $0x14,%esp
  8001c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ca:	8b 03                	mov    (%ebx),%eax
  8001cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001d3:	40                   	inc    %eax
  8001d4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001db:	75 19                	jne    8001f6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001dd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001e4:	00 
  8001e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	e8 44 09 00 00       	call   800b34 <sys_cputs>
		b->idx = 0;
  8001f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001f6:	ff 43 04             	incl   0x4(%ebx)
}
  8001f9:	83 c4 14             	add    $0x14,%esp
  8001fc:	5b                   	pop    %ebx
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    

008001ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800208:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020f:	00 00 00 
	b.cnt = 0;
  800212:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800219:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80021c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800223:	8b 45 08             	mov    0x8(%ebp),%eax
  800226:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800230:	89 44 24 04          	mov    %eax,0x4(%esp)
  800234:	c7 04 24 c0 01 80 00 	movl   $0x8001c0,(%esp)
  80023b:	e8 b4 01 00 00       	call   8003f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800240:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800246:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	e8 dc 08 00 00       	call   800b34 <sys_cputs>

	return b.cnt;
}
  800258:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800266:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800269:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026d:	8b 45 08             	mov    0x8(%ebp),%eax
  800270:	89 04 24             	mov    %eax,(%esp)
  800273:	e8 87 ff ff ff       	call   8001ff <vcprintf>
	va_end(ap);

	return cnt;
}
  800278:	c9                   	leave  
  800279:	c3                   	ret    
	...

0080027c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	57                   	push   %edi
  800280:	56                   	push   %esi
  800281:	53                   	push   %ebx
  800282:	83 ec 3c             	sub    $0x3c,%esp
  800285:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800288:	89 d7                	mov    %edx,%edi
  80028a:	8b 45 08             	mov    0x8(%ebp),%eax
  80028d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800290:	8b 45 0c             	mov    0xc(%ebp),%eax
  800293:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800296:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800299:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029c:	85 c0                	test   %eax,%eax
  80029e:	75 08                	jne    8002a8 <printnum+0x2c>
  8002a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002a6:	77 57                	ja     8002ff <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002ac:	4b                   	dec    %ebx
  8002ad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002bc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c7:	00 
  8002c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002cb:	89 04 24             	mov    %eax,(%esp)
  8002ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d5:	e8 52 0f 00 00       	call   80122c <__udivdi3>
  8002da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002de:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002e2:	89 04 24             	mov    %eax,(%esp)
  8002e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e9:	89 fa                	mov    %edi,%edx
  8002eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ee:	e8 89 ff ff ff       	call   80027c <printnum>
  8002f3:	eb 0f                	jmp    800304 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f9:	89 34 24             	mov    %esi,(%esp)
  8002fc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ff:	4b                   	dec    %ebx
  800300:	85 db                	test   %ebx,%ebx
  800302:	7f f1                	jg     8002f5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800304:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800308:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80030c:	8b 45 10             	mov    0x10(%ebp),%eax
  80030f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800313:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031a:	00 
  80031b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80031e:	89 04 24             	mov    %eax,(%esp)
  800321:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800324:	89 44 24 04          	mov    %eax,0x4(%esp)
  800328:	e8 1f 10 00 00       	call   80134c <__umoddi3>
  80032d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800331:	0f be 80 07 15 80 00 	movsbl 0x801507(%eax),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80033e:	83 c4 3c             	add    $0x3c,%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800349:	83 fa 01             	cmp    $0x1,%edx
  80034c:	7e 0e                	jle    80035c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034e:	8b 10                	mov    (%eax),%edx
  800350:	8d 4a 08             	lea    0x8(%edx),%ecx
  800353:	89 08                	mov    %ecx,(%eax)
  800355:	8b 02                	mov    (%edx),%eax
  800357:	8b 52 04             	mov    0x4(%edx),%edx
  80035a:	eb 22                	jmp    80037e <getuint+0x38>
	else if (lflag)
  80035c:	85 d2                	test   %edx,%edx
  80035e:	74 10                	je     800370 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800360:	8b 10                	mov    (%eax),%edx
  800362:	8d 4a 04             	lea    0x4(%edx),%ecx
  800365:	89 08                	mov    %ecx,(%eax)
  800367:	8b 02                	mov    (%edx),%eax
  800369:	ba 00 00 00 00       	mov    $0x0,%edx
  80036e:	eb 0e                	jmp    80037e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800370:	8b 10                	mov    (%eax),%edx
  800372:	8d 4a 04             	lea    0x4(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 02                	mov    (%edx),%eax
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800383:	83 fa 01             	cmp    $0x1,%edx
  800386:	7e 0e                	jle    800396 <getint+0x16>
		return va_arg(*ap, long long);
  800388:	8b 10                	mov    (%eax),%edx
  80038a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80038d:	89 08                	mov    %ecx,(%eax)
  80038f:	8b 02                	mov    (%edx),%eax
  800391:	8b 52 04             	mov    0x4(%edx),%edx
  800394:	eb 1a                	jmp    8003b0 <getint+0x30>
	else if (lflag)
  800396:	85 d2                	test   %edx,%edx
  800398:	74 0c                	je     8003a6 <getint+0x26>
		return va_arg(*ap, long);
  80039a:	8b 10                	mov    (%eax),%edx
  80039c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039f:	89 08                	mov    %ecx,(%eax)
  8003a1:	8b 02                	mov    (%edx),%eax
  8003a3:	99                   	cltd   
  8003a4:	eb 0a                	jmp    8003b0 <getint+0x30>
	else
		return va_arg(*ap, int);
  8003a6:	8b 10                	mov    (%eax),%edx
  8003a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ab:	89 08                	mov    %ecx,(%eax)
  8003ad:	8b 02                	mov    (%edx),%eax
  8003af:	99                   	cltd   
}
  8003b0:	5d                   	pop    %ebp
  8003b1:	c3                   	ret    

008003b2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003bb:	8b 10                	mov    (%eax),%edx
  8003bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c0:	73 08                	jae    8003ca <sprintputch+0x18>
		*b->buf++ = ch;
  8003c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c5:	88 0a                	mov    %cl,(%edx)
  8003c7:	42                   	inc    %edx
  8003c8:	89 10                	mov    %edx,(%eax)
}
  8003ca:	5d                   	pop    %ebp
  8003cb:	c3                   	ret    

008003cc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ea:	89 04 24             	mov    %eax,(%esp)
  8003ed:	e8 02 00 00 00       	call   8003f4 <vprintfmt>
	va_end(ap);
}
  8003f2:	c9                   	leave  
  8003f3:	c3                   	ret    

008003f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	57                   	push   %edi
  8003f8:	56                   	push   %esi
  8003f9:	53                   	push   %ebx
  8003fa:	83 ec 4c             	sub    $0x4c,%esp
  8003fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800400:	8b 75 10             	mov    0x10(%ebp),%esi
  800403:	eb 12                	jmp    800417 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800405:	85 c0                	test   %eax,%eax
  800407:	0f 84 40 03 00 00    	je     80074d <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  80040d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800411:	89 04 24             	mov    %eax,(%esp)
  800414:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800417:	0f b6 06             	movzbl (%esi),%eax
  80041a:	46                   	inc    %esi
  80041b:	83 f8 25             	cmp    $0x25,%eax
  80041e:	75 e5                	jne    800405 <vprintfmt+0x11>
  800420:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800424:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80042b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800430:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800437:	ba 00 00 00 00       	mov    $0x0,%edx
  80043c:	eb 26                	jmp    800464 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800441:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800445:	eb 1d                	jmp    800464 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80044a:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80044e:	eb 14                	jmp    800464 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800453:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80045a:	eb 08                	jmp    800464 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80045c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80045f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	0f b6 06             	movzbl (%esi),%eax
  800467:	8d 4e 01             	lea    0x1(%esi),%ecx
  80046a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80046d:	8a 0e                	mov    (%esi),%cl
  80046f:	83 e9 23             	sub    $0x23,%ecx
  800472:	80 f9 55             	cmp    $0x55,%cl
  800475:	0f 87 b6 02 00 00    	ja     800731 <vprintfmt+0x33d>
  80047b:	0f b6 c9             	movzbl %cl,%ecx
  80047e:	ff 24 8d c0 15 80 00 	jmp    *0x8015c0(,%ecx,4)
  800485:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800488:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80048d:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800490:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  800494:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800497:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80049a:	83 f9 09             	cmp    $0x9,%ecx
  80049d:	77 2a                	ja     8004c9 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80049f:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004a0:	eb eb                	jmp    80048d <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a5:	8d 48 04             	lea    0x4(%eax),%ecx
  8004a8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ab:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004b0:	eb 17                	jmp    8004c9 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b6:	78 98                	js     800450 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004bb:	eb a7                	jmp    800464 <vprintfmt+0x70>
  8004bd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004c7:	eb 9b                	jmp    800464 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004c9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004cd:	79 95                	jns    800464 <vprintfmt+0x70>
  8004cf:	eb 8b                	jmp    80045c <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d1:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004d5:	eb 8d                	jmp    800464 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004da:	8d 50 04             	lea    0x4(%eax),%edx
  8004dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e4:	8b 00                	mov    (%eax),%eax
  8004e6:	89 04 24             	mov    %eax,(%esp)
  8004e9:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004ef:	e9 23 ff ff ff       	jmp    800417 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f7:	8d 50 04             	lea    0x4(%eax),%edx
  8004fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fd:	8b 00                	mov    (%eax),%eax
  8004ff:	85 c0                	test   %eax,%eax
  800501:	79 02                	jns    800505 <vprintfmt+0x111>
  800503:	f7 d8                	neg    %eax
  800505:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800507:	83 f8 09             	cmp    $0x9,%eax
  80050a:	7f 0b                	jg     800517 <vprintfmt+0x123>
  80050c:	8b 04 85 20 17 80 00 	mov    0x801720(,%eax,4),%eax
  800513:	85 c0                	test   %eax,%eax
  800515:	75 23                	jne    80053a <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800517:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80051b:	c7 44 24 08 1f 15 80 	movl   $0x80151f,0x8(%esp)
  800522:	00 
  800523:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800527:	8b 45 08             	mov    0x8(%ebp),%eax
  80052a:	89 04 24             	mov    %eax,(%esp)
  80052d:	e8 9a fe ff ff       	call   8003cc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800535:	e9 dd fe ff ff       	jmp    800417 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80053a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80053e:	c7 44 24 08 28 15 80 	movl   $0x801528,0x8(%esp)
  800545:	00 
  800546:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80054a:	8b 55 08             	mov    0x8(%ebp),%edx
  80054d:	89 14 24             	mov    %edx,(%esp)
  800550:	e8 77 fe ff ff       	call   8003cc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800555:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800558:	e9 ba fe ff ff       	jmp    800417 <vprintfmt+0x23>
  80055d:	89 f9                	mov    %edi,%ecx
  80055f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800562:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8d 50 04             	lea    0x4(%eax),%edx
  80056b:	89 55 14             	mov    %edx,0x14(%ebp)
  80056e:	8b 30                	mov    (%eax),%esi
  800570:	85 f6                	test   %esi,%esi
  800572:	75 05                	jne    800579 <vprintfmt+0x185>
				p = "(null)";
  800574:	be 18 15 80 00       	mov    $0x801518,%esi
			if (width > 0 && padc != '-')
  800579:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80057d:	0f 8e 84 00 00 00    	jle    800607 <vprintfmt+0x213>
  800583:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800587:	74 7e                	je     800607 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800589:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80058d:	89 34 24             	mov    %esi,(%esp)
  800590:	e8 5d 02 00 00       	call   8007f2 <strnlen>
  800595:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800598:	29 c2                	sub    %eax,%edx
  80059a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80059d:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8005a1:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005a4:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005a7:	89 de                	mov    %ebx,%esi
  8005a9:	89 d3                	mov    %edx,%ebx
  8005ab:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ad:	eb 0b                	jmp    8005ba <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005b3:	89 3c 24             	mov    %edi,(%esp)
  8005b6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b9:	4b                   	dec    %ebx
  8005ba:	85 db                	test   %ebx,%ebx
  8005bc:	7f f1                	jg     8005af <vprintfmt+0x1bb>
  8005be:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005c1:	89 f3                	mov    %esi,%ebx
  8005c3:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005c9:	85 c0                	test   %eax,%eax
  8005cb:	79 05                	jns    8005d2 <vprintfmt+0x1de>
  8005cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d5:	29 c2                	sub    %eax,%edx
  8005d7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005da:	eb 2b                	jmp    800607 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005dc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005e0:	74 18                	je     8005fa <vprintfmt+0x206>
  8005e2:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005e5:	83 fa 5e             	cmp    $0x5e,%edx
  8005e8:	76 10                	jbe    8005fa <vprintfmt+0x206>
					putch('?', putdat);
  8005ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ee:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005f5:	ff 55 08             	call   *0x8(%ebp)
  8005f8:	eb 0a                	jmp    800604 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fe:	89 04 24             	mov    %eax,(%esp)
  800601:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800604:	ff 4d e4             	decl   -0x1c(%ebp)
  800607:	0f be 06             	movsbl (%esi),%eax
  80060a:	46                   	inc    %esi
  80060b:	85 c0                	test   %eax,%eax
  80060d:	74 21                	je     800630 <vprintfmt+0x23c>
  80060f:	85 ff                	test   %edi,%edi
  800611:	78 c9                	js     8005dc <vprintfmt+0x1e8>
  800613:	4f                   	dec    %edi
  800614:	79 c6                	jns    8005dc <vprintfmt+0x1e8>
  800616:	8b 7d 08             	mov    0x8(%ebp),%edi
  800619:	89 de                	mov    %ebx,%esi
  80061b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80061e:	eb 18                	jmp    800638 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800620:	89 74 24 04          	mov    %esi,0x4(%esp)
  800624:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80062b:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062d:	4b                   	dec    %ebx
  80062e:	eb 08                	jmp    800638 <vprintfmt+0x244>
  800630:	8b 7d 08             	mov    0x8(%ebp),%edi
  800633:	89 de                	mov    %ebx,%esi
  800635:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800638:	85 db                	test   %ebx,%ebx
  80063a:	7f e4                	jg     800620 <vprintfmt+0x22c>
  80063c:	89 7d 08             	mov    %edi,0x8(%ebp)
  80063f:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800641:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800644:	e9 ce fd ff ff       	jmp    800417 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800649:	8d 45 14             	lea    0x14(%ebp),%eax
  80064c:	e8 2f fd ff ff       	call   800380 <getint>
  800651:	89 c6                	mov    %eax,%esi
  800653:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800655:	85 d2                	test   %edx,%edx
  800657:	78 07                	js     800660 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800659:	be 0a 00 00 00       	mov    $0xa,%esi
  80065e:	eb 7e                	jmp    8006de <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800660:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800664:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80066b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80066e:	89 f0                	mov    %esi,%eax
  800670:	89 fa                	mov    %edi,%edx
  800672:	f7 d8                	neg    %eax
  800674:	83 d2 00             	adc    $0x0,%edx
  800677:	f7 da                	neg    %edx
			}
			base = 10;
  800679:	be 0a 00 00 00       	mov    $0xa,%esi
  80067e:	eb 5e                	jmp    8006de <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800680:	8d 45 14             	lea    0x14(%ebp),%eax
  800683:	e8 be fc ff ff       	call   800346 <getuint>
			base = 10;
  800688:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80068d:	eb 4f                	jmp    8006de <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80068f:	8d 45 14             	lea    0x14(%ebp),%eax
  800692:	e8 af fc ff ff       	call   800346 <getuint>
			base = 8;
  800697:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80069c:	eb 40                	jmp    8006de <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  80069e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006a9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006b7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8d 50 04             	lea    0x4(%eax),%edx
  8006c0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006c3:	8b 00                	mov    (%eax),%eax
  8006c5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ca:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8006cf:	eb 0d                	jmp    8006de <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d4:	e8 6d fc ff ff       	call   800346 <getuint>
			base = 16;
  8006d9:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006de:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8006e2:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8006e6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8006ed:	89 74 24 08          	mov    %esi,0x8(%esp)
  8006f1:	89 04 24             	mov    %eax,(%esp)
  8006f4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006f8:	89 da                	mov    %ebx,%edx
  8006fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fd:	e8 7a fb ff ff       	call   80027c <printnum>
			break;
  800702:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800705:	e9 0d fd ff ff       	jmp    800417 <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  80070a:	8d 45 14             	lea    0x14(%ebp),%eax
  80070d:	e8 6e fc ff ff       	call   800380 <getint>
  800712:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800717:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  80071a:	e9 f8 fc ff ff       	jmp    800417 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800723:	89 04 24             	mov    %eax,(%esp)
  800726:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800729:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80072c:	e9 e6 fc ff ff       	jmp    800417 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800731:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800735:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80073c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073f:	eb 01                	jmp    800742 <vprintfmt+0x34e>
  800741:	4e                   	dec    %esi
  800742:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800746:	75 f9                	jne    800741 <vprintfmt+0x34d>
  800748:	e9 ca fc ff ff       	jmp    800417 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80074d:	83 c4 4c             	add    $0x4c,%esp
  800750:	5b                   	pop    %ebx
  800751:	5e                   	pop    %esi
  800752:	5f                   	pop    %edi
  800753:	5d                   	pop    %ebp
  800754:	c3                   	ret    

00800755 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	83 ec 28             	sub    $0x28,%esp
  80075b:	8b 45 08             	mov    0x8(%ebp),%eax
  80075e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800761:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800764:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800768:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800772:	85 c0                	test   %eax,%eax
  800774:	74 30                	je     8007a6 <vsnprintf+0x51>
  800776:	85 d2                	test   %edx,%edx
  800778:	7e 33                	jle    8007ad <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800781:	8b 45 10             	mov    0x10(%ebp),%eax
  800784:	89 44 24 08          	mov    %eax,0x8(%esp)
  800788:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078f:	c7 04 24 b2 03 80 00 	movl   $0x8003b2,(%esp)
  800796:	e8 59 fc ff ff       	call   8003f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a4:	eb 0c                	jmp    8007b2 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ab:	eb 05                	jmp    8007b2 <vsnprintf+0x5d>
  8007ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ba:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d2:	89 04 24             	mov    %eax,(%esp)
  8007d5:	e8 7b ff ff ff       	call   800755 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e7:	eb 01                	jmp    8007ea <strlen+0xe>
		n++;
  8007e9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ee:	75 f9                	jne    8007e9 <strlen+0xd>
		n++;
	return n;
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800800:	eb 01                	jmp    800803 <strnlen+0x11>
		n++;
  800802:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800803:	39 d0                	cmp    %edx,%eax
  800805:	74 06                	je     80080d <strnlen+0x1b>
  800807:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80080b:	75 f5                	jne    800802 <strnlen+0x10>
		n++;
	return n;
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800819:	ba 00 00 00 00       	mov    $0x0,%edx
  80081e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800821:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800824:	42                   	inc    %edx
  800825:	84 c9                	test   %cl,%cl
  800827:	75 f5                	jne    80081e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800829:	5b                   	pop    %ebx
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	53                   	push   %ebx
  800830:	83 ec 08             	sub    $0x8,%esp
  800833:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800836:	89 1c 24             	mov    %ebx,(%esp)
  800839:	e8 9e ff ff ff       	call   8007dc <strlen>
	strcpy(dst + len, src);
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800841:	89 54 24 04          	mov    %edx,0x4(%esp)
  800845:	01 d8                	add    %ebx,%eax
  800847:	89 04 24             	mov    %eax,(%esp)
  80084a:	e8 c0 ff ff ff       	call   80080f <strcpy>
	return dst;
}
  80084f:	89 d8                	mov    %ebx,%eax
  800851:	83 c4 08             	add    $0x8,%esp
  800854:	5b                   	pop    %ebx
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800862:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800865:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086a:	eb 0c                	jmp    800878 <strncpy+0x21>
		*dst++ = *src;
  80086c:	8a 1a                	mov    (%edx),%bl
  80086e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800871:	80 3a 01             	cmpb   $0x1,(%edx)
  800874:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800877:	41                   	inc    %ecx
  800878:	39 f1                	cmp    %esi,%ecx
  80087a:	75 f0                	jne    80086c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087c:	5b                   	pop    %ebx
  80087d:	5e                   	pop    %esi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	56                   	push   %esi
  800884:	53                   	push   %ebx
  800885:	8b 75 08             	mov    0x8(%ebp),%esi
  800888:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088e:	85 d2                	test   %edx,%edx
  800890:	75 0a                	jne    80089c <strlcpy+0x1c>
  800892:	89 f0                	mov    %esi,%eax
  800894:	eb 1a                	jmp    8008b0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800896:	88 18                	mov    %bl,(%eax)
  800898:	40                   	inc    %eax
  800899:	41                   	inc    %ecx
  80089a:	eb 02                	jmp    80089e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80089e:	4a                   	dec    %edx
  80089f:	74 0a                	je     8008ab <strlcpy+0x2b>
  8008a1:	8a 19                	mov    (%ecx),%bl
  8008a3:	84 db                	test   %bl,%bl
  8008a5:	75 ef                	jne    800896 <strlcpy+0x16>
  8008a7:	89 c2                	mov    %eax,%edx
  8008a9:	eb 02                	jmp    8008ad <strlcpy+0x2d>
  8008ab:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008ad:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008b0:	29 f0                	sub    %esi,%eax
}
  8008b2:	5b                   	pop    %ebx
  8008b3:	5e                   	pop    %esi
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008bf:	eb 02                	jmp    8008c3 <strcmp+0xd>
		p++, q++;
  8008c1:	41                   	inc    %ecx
  8008c2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c3:	8a 01                	mov    (%ecx),%al
  8008c5:	84 c0                	test   %al,%al
  8008c7:	74 04                	je     8008cd <strcmp+0x17>
  8008c9:	3a 02                	cmp    (%edx),%al
  8008cb:	74 f4                	je     8008c1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cd:	0f b6 c0             	movzbl %al,%eax
  8008d0:	0f b6 12             	movzbl (%edx),%edx
  8008d3:	29 d0                	sub    %edx,%eax
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008e4:	eb 03                	jmp    8008e9 <strncmp+0x12>
		n--, p++, q++;
  8008e6:	4a                   	dec    %edx
  8008e7:	40                   	inc    %eax
  8008e8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e9:	85 d2                	test   %edx,%edx
  8008eb:	74 14                	je     800901 <strncmp+0x2a>
  8008ed:	8a 18                	mov    (%eax),%bl
  8008ef:	84 db                	test   %bl,%bl
  8008f1:	74 04                	je     8008f7 <strncmp+0x20>
  8008f3:	3a 19                	cmp    (%ecx),%bl
  8008f5:	74 ef                	je     8008e6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f7:	0f b6 00             	movzbl (%eax),%eax
  8008fa:	0f b6 11             	movzbl (%ecx),%edx
  8008fd:	29 d0                	sub    %edx,%eax
  8008ff:	eb 05                	jmp    800906 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800901:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800906:	5b                   	pop    %ebx
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800912:	eb 05                	jmp    800919 <strchr+0x10>
		if (*s == c)
  800914:	38 ca                	cmp    %cl,%dl
  800916:	74 0c                	je     800924 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800918:	40                   	inc    %eax
  800919:	8a 10                	mov    (%eax),%dl
  80091b:	84 d2                	test   %dl,%dl
  80091d:	75 f5                	jne    800914 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80091f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80092f:	eb 05                	jmp    800936 <strfind+0x10>
		if (*s == c)
  800931:	38 ca                	cmp    %cl,%dl
  800933:	74 07                	je     80093c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800935:	40                   	inc    %eax
  800936:	8a 10                	mov    (%eax),%dl
  800938:	84 d2                	test   %dl,%dl
  80093a:	75 f5                	jne    800931 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	57                   	push   %edi
  800942:	56                   	push   %esi
  800943:	53                   	push   %ebx
  800944:	8b 7d 08             	mov    0x8(%ebp),%edi
  800947:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094d:	85 c9                	test   %ecx,%ecx
  80094f:	74 30                	je     800981 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800951:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800957:	75 25                	jne    80097e <memset+0x40>
  800959:	f6 c1 03             	test   $0x3,%cl
  80095c:	75 20                	jne    80097e <memset+0x40>
		c &= 0xFF;
  80095e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800961:	89 d3                	mov    %edx,%ebx
  800963:	c1 e3 08             	shl    $0x8,%ebx
  800966:	89 d6                	mov    %edx,%esi
  800968:	c1 e6 18             	shl    $0x18,%esi
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	c1 e0 10             	shl    $0x10,%eax
  800970:	09 f0                	or     %esi,%eax
  800972:	09 d0                	or     %edx,%eax
  800974:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800976:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800979:	fc                   	cld    
  80097a:	f3 ab                	rep stos %eax,%es:(%edi)
  80097c:	eb 03                	jmp    800981 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097e:	fc                   	cld    
  80097f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800981:	89 f8                	mov    %edi,%eax
  800983:	5b                   	pop    %ebx
  800984:	5e                   	pop    %esi
  800985:	5f                   	pop    %edi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	57                   	push   %edi
  80098c:	56                   	push   %esi
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 75 0c             	mov    0xc(%ebp),%esi
  800993:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800996:	39 c6                	cmp    %eax,%esi
  800998:	73 34                	jae    8009ce <memmove+0x46>
  80099a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099d:	39 d0                	cmp    %edx,%eax
  80099f:	73 2d                	jae    8009ce <memmove+0x46>
		s += n;
		d += n;
  8009a1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	f6 c2 03             	test   $0x3,%dl
  8009a7:	75 1b                	jne    8009c4 <memmove+0x3c>
  8009a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009af:	75 13                	jne    8009c4 <memmove+0x3c>
  8009b1:	f6 c1 03             	test   $0x3,%cl
  8009b4:	75 0e                	jne    8009c4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b6:	83 ef 04             	sub    $0x4,%edi
  8009b9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009bf:	fd                   	std    
  8009c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c2:	eb 07                	jmp    8009cb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c4:	4f                   	dec    %edi
  8009c5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c8:	fd                   	std    
  8009c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cb:	fc                   	cld    
  8009cc:	eb 20                	jmp    8009ee <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ce:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d4:	75 13                	jne    8009e9 <memmove+0x61>
  8009d6:	a8 03                	test   $0x3,%al
  8009d8:	75 0f                	jne    8009e9 <memmove+0x61>
  8009da:	f6 c1 03             	test   $0x3,%cl
  8009dd:	75 0a                	jne    8009e9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009df:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009e2:	89 c7                	mov    %eax,%edi
  8009e4:	fc                   	cld    
  8009e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e7:	eb 05                	jmp    8009ee <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e9:	89 c7                	mov    %eax,%edi
  8009eb:	fc                   	cld    
  8009ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ee:	5e                   	pop    %esi
  8009ef:	5f                   	pop    %edi
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	89 04 24             	mov    %eax,(%esp)
  800a0c:	e8 77 ff ff ff       	call   800988 <memmove>
}
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a22:	ba 00 00 00 00       	mov    $0x0,%edx
  800a27:	eb 16                	jmp    800a3f <memcmp+0x2c>
		if (*s1 != *s2)
  800a29:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a2c:	42                   	inc    %edx
  800a2d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a31:	38 c8                	cmp    %cl,%al
  800a33:	74 0a                	je     800a3f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a35:	0f b6 c0             	movzbl %al,%eax
  800a38:	0f b6 c9             	movzbl %cl,%ecx
  800a3b:	29 c8                	sub    %ecx,%eax
  800a3d:	eb 09                	jmp    800a48 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3f:	39 da                	cmp    %ebx,%edx
  800a41:	75 e6                	jne    800a29 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a48:	5b                   	pop    %ebx
  800a49:	5e                   	pop    %esi
  800a4a:	5f                   	pop    %edi
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a56:	89 c2                	mov    %eax,%edx
  800a58:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5b:	eb 05                	jmp    800a62 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5d:	38 08                	cmp    %cl,(%eax)
  800a5f:	74 05                	je     800a66 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a61:	40                   	inc    %eax
  800a62:	39 d0                	cmp    %edx,%eax
  800a64:	72 f7                	jb     800a5d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
  800a6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a71:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a74:	eb 01                	jmp    800a77 <strtol+0xf>
		s++;
  800a76:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a77:	8a 02                	mov    (%edx),%al
  800a79:	3c 20                	cmp    $0x20,%al
  800a7b:	74 f9                	je     800a76 <strtol+0xe>
  800a7d:	3c 09                	cmp    $0x9,%al
  800a7f:	74 f5                	je     800a76 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a81:	3c 2b                	cmp    $0x2b,%al
  800a83:	75 08                	jne    800a8d <strtol+0x25>
		s++;
  800a85:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a86:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8b:	eb 13                	jmp    800aa0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8d:	3c 2d                	cmp    $0x2d,%al
  800a8f:	75 0a                	jne    800a9b <strtol+0x33>
		s++, neg = 1;
  800a91:	8d 52 01             	lea    0x1(%edx),%edx
  800a94:	bf 01 00 00 00       	mov    $0x1,%edi
  800a99:	eb 05                	jmp    800aa0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa0:	85 db                	test   %ebx,%ebx
  800aa2:	74 05                	je     800aa9 <strtol+0x41>
  800aa4:	83 fb 10             	cmp    $0x10,%ebx
  800aa7:	75 28                	jne    800ad1 <strtol+0x69>
  800aa9:	8a 02                	mov    (%edx),%al
  800aab:	3c 30                	cmp    $0x30,%al
  800aad:	75 10                	jne    800abf <strtol+0x57>
  800aaf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab3:	75 0a                	jne    800abf <strtol+0x57>
		s += 2, base = 16;
  800ab5:	83 c2 02             	add    $0x2,%edx
  800ab8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abd:	eb 12                	jmp    800ad1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800abf:	85 db                	test   %ebx,%ebx
  800ac1:	75 0e                	jne    800ad1 <strtol+0x69>
  800ac3:	3c 30                	cmp    $0x30,%al
  800ac5:	75 05                	jne    800acc <strtol+0x64>
		s++, base = 8;
  800ac7:	42                   	inc    %edx
  800ac8:	b3 08                	mov    $0x8,%bl
  800aca:	eb 05                	jmp    800ad1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800acc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad8:	8a 0a                	mov    (%edx),%cl
  800ada:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800add:	80 fb 09             	cmp    $0x9,%bl
  800ae0:	77 08                	ja     800aea <strtol+0x82>
			dig = *s - '0';
  800ae2:	0f be c9             	movsbl %cl,%ecx
  800ae5:	83 e9 30             	sub    $0x30,%ecx
  800ae8:	eb 1e                	jmp    800b08 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aea:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aed:	80 fb 19             	cmp    $0x19,%bl
  800af0:	77 08                	ja     800afa <strtol+0x92>
			dig = *s - 'a' + 10;
  800af2:	0f be c9             	movsbl %cl,%ecx
  800af5:	83 e9 57             	sub    $0x57,%ecx
  800af8:	eb 0e                	jmp    800b08 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800afa:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800afd:	80 fb 19             	cmp    $0x19,%bl
  800b00:	77 12                	ja     800b14 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b02:	0f be c9             	movsbl %cl,%ecx
  800b05:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b08:	39 f1                	cmp    %esi,%ecx
  800b0a:	7d 0c                	jge    800b18 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b0c:	42                   	inc    %edx
  800b0d:	0f af c6             	imul   %esi,%eax
  800b10:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b12:	eb c4                	jmp    800ad8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b14:	89 c1                	mov    %eax,%ecx
  800b16:	eb 02                	jmp    800b1a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b18:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1e:	74 05                	je     800b25 <strtol+0xbd>
		*endptr = (char *) s;
  800b20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b23:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b25:	85 ff                	test   %edi,%edi
  800b27:	74 04                	je     800b2d <strtol+0xc5>
  800b29:	89 c8                	mov    %ecx,%eax
  800b2b:	f7 d8                	neg    %eax
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    
	...

00800b34 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b42:	8b 55 08             	mov    0x8(%ebp),%edx
  800b45:	89 c3                	mov    %eax,%ebx
  800b47:	89 c7                	mov    %eax,%edi
  800b49:	89 c6                	mov    %eax,%esi
  800b4b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b58:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b62:	89 d1                	mov    %edx,%ecx
  800b64:	89 d3                	mov    %edx,%ebx
  800b66:	89 d7                	mov    %edx,%edi
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	89 cb                	mov    %ecx,%ebx
  800b89:	89 cf                	mov    %ecx,%edi
  800b8b:	89 ce                	mov    %ecx,%esi
  800b8d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	7e 28                	jle    800bbb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b97:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b9e:	00 
  800b9f:	c7 44 24 08 48 17 80 	movl   $0x801748,0x8(%esp)
  800ba6:	00 
  800ba7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bae:	00 
  800baf:	c7 04 24 65 17 80 00 	movl   $0x801765,(%esp)
  800bb6:	e8 ad f5 ff ff       	call   800168 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbb:	83 c4 2c             	add    $0x2c,%esp
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bce:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd3:	89 d1                	mov    %edx,%ecx
  800bd5:	89 d3                	mov    %edx,%ebx
  800bd7:	89 d7                	mov    %edx,%edi
  800bd9:	89 d6                	mov    %edx,%esi
  800bdb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_yield>:

void
sys_yield(void)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bed:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bf2:	89 d1                	mov    %edx,%ecx
  800bf4:	89 d3                	mov    %edx,%ebx
  800bf6:	89 d7                	mov    %edx,%edi
  800bf8:	89 d6                	mov    %edx,%esi
  800bfa:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	be 00 00 00 00       	mov    $0x0,%esi
  800c0f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 f7                	mov    %esi,%edi
  800c1f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c21:	85 c0                	test   %eax,%eax
  800c23:	7e 28                	jle    800c4d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c29:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c30:	00 
  800c31:	c7 44 24 08 48 17 80 	movl   $0x801748,0x8(%esp)
  800c38:	00 
  800c39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c40:	00 
  800c41:	c7 04 24 65 17 80 00 	movl   $0x801765,(%esp)
  800c48:	e8 1b f5 ff ff       	call   800168 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4d:	83 c4 2c             	add    $0x2c,%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c63:	8b 75 18             	mov    0x18(%ebp),%esi
  800c66:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c72:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	7e 28                	jle    800ca0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c78:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c83:	00 
  800c84:	c7 44 24 08 48 17 80 	movl   $0x801748,0x8(%esp)
  800c8b:	00 
  800c8c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c93:	00 
  800c94:	c7 04 24 65 17 80 00 	movl   $0x801765,(%esp)
  800c9b:	e8 c8 f4 ff ff       	call   800168 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca0:	83 c4 2c             	add    $0x2c,%esp
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
  800cae:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb6:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	89 df                	mov    %ebx,%edi
  800cc3:	89 de                	mov    %ebx,%esi
  800cc5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	7e 28                	jle    800cf3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ccf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cd6:	00 
  800cd7:	c7 44 24 08 48 17 80 	movl   $0x801748,0x8(%esp)
  800cde:	00 
  800cdf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce6:	00 
  800ce7:	c7 04 24 65 17 80 00 	movl   $0x801765,(%esp)
  800cee:	e8 75 f4 ff ff       	call   800168 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf3:	83 c4 2c             	add    $0x2c,%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d09:	b8 08 00 00 00       	mov    $0x8,%eax
  800d0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d11:	8b 55 08             	mov    0x8(%ebp),%edx
  800d14:	89 df                	mov    %ebx,%edi
  800d16:	89 de                	mov    %ebx,%esi
  800d18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	7e 28                	jle    800d46 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d22:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d29:	00 
  800d2a:	c7 44 24 08 48 17 80 	movl   $0x801748,0x8(%esp)
  800d31:	00 
  800d32:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d39:	00 
  800d3a:	c7 04 24 65 17 80 00 	movl   $0x801765,(%esp)
  800d41:	e8 22 f4 ff ff       	call   800168 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d46:	83 c4 2c             	add    $0x2c,%esp
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	89 df                	mov    %ebx,%edi
  800d69:	89 de                	mov    %ebx,%esi
  800d6b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	7e 28                	jle    800d99 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d75:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d7c:	00 
  800d7d:	c7 44 24 08 48 17 80 	movl   $0x801748,0x8(%esp)
  800d84:	00 
  800d85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8c:	00 
  800d8d:	c7 04 24 65 17 80 00 	movl   $0x801765,(%esp)
  800d94:	e8 cf f3 ff ff       	call   800168 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d99:	83 c4 2c             	add    $0x2c,%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da7:	be 00 00 00 00       	mov    $0x0,%esi
  800dac:	b8 0b 00 00 00       	mov    $0xb,%eax
  800db1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dba:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dda:	89 cb                	mov    %ecx,%ebx
  800ddc:	89 cf                	mov    %ecx,%edi
  800dde:	89 ce                	mov    %ecx,%esi
  800de0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 28                	jle    800e0e <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dea:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800df1:	00 
  800df2:	c7 44 24 08 48 17 80 	movl   $0x801748,0x8(%esp)
  800df9:	00 
  800dfa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e01:	00 
  800e02:	c7 04 24 65 17 80 00 	movl   $0x801765,(%esp)
  800e09:	e8 5a f3 ff ff       	call   800168 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e0e:	83 c4 2c             	add    $0x2c,%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	57                   	push   %edi
  800e1a:	56                   	push   %esi
  800e1b:	53                   	push   %ebx
  800e1c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e24:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2f:	89 df                	mov    %ebx,%edi
  800e31:	89 de                	mov    %ebx,%esi
  800e33:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e35:	85 c0                	test   %eax,%eax
  800e37:	7e 28                	jle    800e61 <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e44:	00 
  800e45:	c7 44 24 08 48 17 80 	movl   $0x801748,0x8(%esp)
  800e4c:	00 
  800e4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e54:	00 
  800e55:	c7 04 24 65 17 80 00 	movl   $0x801765,(%esp)
  800e5c:	e8 07 f3 ff ff       	call   800168 <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800e61:	83 c4 2c             	add    $0x2c,%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    
  800e69:	00 00                	add    %al,(%eax)
	...

00800e6c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 24             	sub    $0x24,%esp
  800e73:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e76:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800e78:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e7c:	74 2d                	je     800eab <pgfault+0x3f>
  800e7e:	89 d8                	mov    %ebx,%eax
  800e80:	c1 e8 16             	shr    $0x16,%eax
  800e83:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e8a:	a8 01                	test   $0x1,%al
  800e8c:	74 1d                	je     800eab <pgfault+0x3f>
		(uvpt[PGNUM(addr)] & PTE_P) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800e8e:	89 d8                	mov    %ebx,%eax
  800e90:	c1 e8 0c             	shr    $0xc,%eax
  800e93:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800e9a:	f6 c2 01             	test   $0x1,%dl
  800e9d:	74 0c                	je     800eab <pgfault+0x3f>
		(uvpt[PGNUM(addr)] & PTE_P) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800e9f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ea6:	f6 c4 08             	test   $0x8,%ah
  800ea9:	75 1c                	jne    800ec7 <pgfault+0x5b>
		panic("pgfault: not a write or a copy on write page fault!");
  800eab:	c7 44 24 08 74 17 80 	movl   $0x801774,0x8(%esp)
  800eb2:	00 
  800eb3:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800eba:	00 
  800ebb:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  800ec2:	e8 a1 f2 ff ff       	call   800168 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	// we need to make addr page-aligned
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)) < 0)
  800ec7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ece:	00 
  800ecf:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ed6:	00 
  800ed7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ede:	e8 1e fd ff ff       	call   800c01 <sys_page_alloc>
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	79 20                	jns    800f07 <pgfault+0x9b>
		panic("pgfault: sys_page_alloc: %e", r);
  800ee7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eeb:	c7 44 24 08 b3 17 80 	movl   $0x8017b3,0x8(%esp)
  800ef2:	00 
  800ef3:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800efa:	00 
  800efb:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  800f02:	e8 61 f2 ff ff       	call   800168 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// we need to make addr page-aligned
	addr = ROUNDDOWN(addr, PGSIZE);
  800f07:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)) < 0)
		panic("pgfault: sys_page_alloc: %e", r);
	memcpy(PFTEMP, addr, PGSIZE);
  800f0d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f14:	00 
  800f15:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f19:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f20:	e8 cd fa ff ff       	call   8009f2 <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P)) < 0)
  800f25:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f2c:	00 
  800f2d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f31:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f38:	00 
  800f39:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f40:	00 
  800f41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f48:	e8 08 fd ff ff       	call   800c55 <sys_page_map>
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	79 20                	jns    800f71 <pgfault+0x105>
		panic("pgfault: sys_page_map: %e", r);
  800f51:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f55:	c7 44 24 08 cf 17 80 	movl   $0x8017cf,0x8(%esp)
  800f5c:	00 
  800f5d:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800f64:	00 
  800f65:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  800f6c:	e8 f7 f1 ff ff       	call   800168 <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f71:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f78:	00 
  800f79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f80:	e8 23 fd ff ff       	call   800ca8 <sys_page_unmap>
  800f85:	85 c0                	test   %eax,%eax
  800f87:	79 20                	jns    800fa9 <pgfault+0x13d>
		panic("pgfault: sys_page_unmap: %e", r);
  800f89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f8d:	c7 44 24 08 e9 17 80 	movl   $0x8017e9,0x8(%esp)
  800f94:	00 
  800f95:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800f9c:	00 
  800f9d:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  800fa4:	e8 bf f1 ff ff       	call   800168 <_panic>
}
  800fa9:	83 c4 24             	add    $0x24,%esp
  800fac:	5b                   	pop    %ebx
  800fad:	5d                   	pop    %ebp
  800fae:	c3                   	ret    

00800faf <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	57                   	push   %edi
  800fb3:	56                   	push   %esi
  800fb4:	53                   	push   %ebx
  800fb5:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800fb8:	c7 04 24 6c 0e 80 00 	movl   $0x800e6c,(%esp)
  800fbf:	e8 ac 01 00 00       	call   801170 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fc4:	ba 07 00 00 00       	mov    $0x7,%edx
  800fc9:	89 d0                	mov    %edx,%eax
  800fcb:	cd 30                	int    $0x30
  800fcd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fd0:	89 c7                	mov    %eax,%edi
	envid_t envid;
	uint8_t *addr;
	int r;
	extern unsigned char end[];
	envid = sys_exofork();
	if (envid < 0)
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	79 20                	jns    800ff6 <fork+0x47>
		panic("sys_exofork: %e", envid);
  800fd6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fda:	c7 44 24 08 05 18 80 	movl   $0x801805,0x8(%esp)
  800fe1:	00 
  800fe2:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  800fe9:	00 
  800fea:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  800ff1:	e8 72 f1 ff ff       	call   800168 <_panic>
	if (envid == 0) {
  800ff6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ffa:	75 27                	jne    801023 <fork+0x74>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800ffc:	e8 c2 fb ff ff       	call   800bc3 <sys_getenvid>
  801001:	25 ff 03 00 00       	and    $0x3ff,%eax
  801006:	8d 14 80             	lea    (%eax,%eax,4),%edx
  801009:	8d 04 50             	lea    (%eax,%edx,2),%eax
  80100c:	c1 e0 04             	shl    $0x4,%eax
  80100f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801014:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return 0;
  801019:	b8 00 00 00 00       	mov    $0x0,%eax
  80101e:	e9 23 01 00 00       	jmp    801146 <fork+0x197>
	int r;
	extern unsigned char end[];
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  801023:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	}

	// We're the parent.
	for (addr = 0; addr < (uint8_t *)USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  801028:	89 d8                	mov    %ebx,%eax
  80102a:	c1 e8 16             	shr    $0x16,%eax
  80102d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801034:	a8 01                	test   $0x1,%al
  801036:	0f 84 ac 00 00 00    	je     8010e8 <fork+0x139>
  80103c:	89 d8                	mov    %ebx,%eax
  80103e:	c1 e8 0c             	shr    $0xc,%eax
  801041:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801048:	f6 c2 01             	test   $0x1,%dl
  80104b:	0f 84 97 00 00 00    	je     8010e8 <fork+0x139>
			&& (uvpt[PGNUM(addr)] & PTE_U))
  801051:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801058:	f6 c2 04             	test   $0x4,%dl
  80105b:	0f 84 87 00 00 00    	je     8010e8 <fork+0x139>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	void *va = (void *)(pn * PGSIZE);
  801061:	89 c6                	mov    %eax,%esi
  801063:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  801066:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80106d:	f6 c2 02             	test   $0x2,%dl
  801070:	75 0c                	jne    80107e <fork+0xcf>
  801072:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801079:	f6 c4 08             	test   $0x8,%ah
  80107c:	74 4a                	je     8010c8 <fork+0x119>
		if ((r = sys_page_map(0, va, envid, va, PTE_COW|PTE_U|PTE_P)) < 0)
  80107e:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801085:	00 
  801086:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80108a:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80108e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801092:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801099:	e8 b7 fb ff ff       	call   800c55 <sys_page_map>
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	78 46                	js     8010e8 <fork+0x139>
			return r;
		if ((r = sys_page_map(0, va, 0, va, PTE_COW|PTE_U|PTE_P)) < 0)
  8010a2:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8010a9:	00 
  8010aa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010ae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010b5:	00 
  8010b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010c1:	e8 8f fb ff ff       	call   800c55 <sys_page_map>
  8010c6:	eb 20                	jmp    8010e8 <fork+0x139>
			return r;
	}
	else {
		if ((r = sys_page_map(0, va, envid, va, PTE_U|PTE_P)) < 0)
  8010c8:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8010cf:	00 
  8010d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010d4:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010e3:	e8 6d fb ff ff       	call   800c55 <sys_page_map>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	// We're the parent.
	for (addr = 0; addr < (uint8_t *)USTACKTOP; addr += PGSIZE)
  8010e8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010ee:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010f4:	0f 85 2e ff ff ff    	jne    801028 <fork+0x79>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
			&& (uvpt[PGNUM(addr)] & PTE_U))
			duppage(envid, PGNUM(addr));

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  8010fa:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801101:	00 
  801102:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801109:	ee 
  80110a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80110d:	89 04 24             	mov    %eax,(%esp)
  801110:	e8 ec fa ff ff       	call   800c01 <sys_page_alloc>
  801115:	85 c0                	test   %eax,%eax
  801117:	78 2d                	js     801146 <fork+0x197>
		return r;
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801119:	c7 44 24 04 04 12 80 	movl   $0x801204,0x4(%esp)
  801120:	00 
  801121:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801124:	89 04 24             	mov    %eax,(%esp)
  801127:	e8 22 fc ff ff       	call   800d4e <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80112c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801133:	00 
  801134:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801137:	89 04 24             	mov    %eax,(%esp)
  80113a:	e8 bc fb ff ff       	call   800cfb <sys_env_set_status>
  80113f:	85 c0                	test   %eax,%eax
  801141:	78 03                	js     801146 <fork+0x197>
		return r;

	return envid;
  801143:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801146:	83 c4 3c             	add    $0x3c,%esp
  801149:	5b                   	pop    %ebx
  80114a:	5e                   	pop    %esi
  80114b:	5f                   	pop    %edi
  80114c:	5d                   	pop    %ebp
  80114d:	c3                   	ret    

0080114e <sfork>:

// Challenge!
int
sfork(void)
{
  80114e:	55                   	push   %ebp
  80114f:	89 e5                	mov    %esp,%ebp
  801151:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801154:	c7 44 24 08 15 18 80 	movl   $0x801815,0x8(%esp)
  80115b:	00 
  80115c:	c7 44 24 04 8d 00 00 	movl   $0x8d,0x4(%esp)
  801163:	00 
  801164:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  80116b:	e8 f8 ef ff ff       	call   800168 <_panic>

00801170 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801176:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  80117d:	75 40                	jne    8011bf <set_pgfault_handler+0x4f>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
  80117f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801186:	00 
  801187:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80118e:	ee 
  80118f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801196:	e8 66 fa ff ff       	call   800c01 <sys_page_alloc>
  80119b:	85 c0                	test   %eax,%eax
  80119d:	79 20                	jns    8011bf <set_pgfault_handler+0x4f>
            panic("set_pgfault_handler: sys_page_alloc: %e", r);
  80119f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011a3:	c7 44 24 08 2c 18 80 	movl   $0x80182c,0x8(%esp)
  8011aa:	00 
  8011ab:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8011b2:	00 
  8011b3:	c7 04 24 88 18 80 00 	movl   $0x801888,(%esp)
  8011ba:	e8 a9 ef ff ff       	call   800168 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c2:	a3 10 20 80 00       	mov    %eax,0x802010
    if ((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0 )
  8011c7:	c7 44 24 04 04 12 80 	movl   $0x801204,0x4(%esp)
  8011ce:	00 
  8011cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d6:	e8 73 fb ff ff       	call   800d4e <sys_env_set_pgfault_upcall>
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	79 20                	jns    8011ff <set_pgfault_handler+0x8f>
        panic("set_pgfault_handler: sys_env_set_pgfault_upcall: %e", r);
  8011df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011e3:	c7 44 24 08 54 18 80 	movl   $0x801854,0x8(%esp)
  8011ea:	00 
  8011eb:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8011f2:	00 
  8011f3:	c7 04 24 88 18 80 00 	movl   $0x801888,(%esp)
  8011fa:	e8 69 ef ff ff       	call   800168 <_panic>
}
  8011ff:	c9                   	leave  
  801200:	c3                   	ret    
  801201:	00 00                	add    %al,(%eax)
	...

00801204 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801204:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801205:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  80120a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80120c:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// sub 4 from old esp
	movl 0x30(%esp), %eax
  80120f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801213:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801216:	89 44 24 30          	mov    %eax,0x30(%esp)
	// put old eip into the pre-reserved 4-byte space
	movl 0x28(%esp), %ebx
  80121a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80121e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  801220:	83 c4 08             	add    $0x8,%esp
	popal
  801223:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  801224:	83 c4 04             	add    $0x4,%esp
	popfl
  801227:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801228:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801229:	c3                   	ret    
	...

0080122c <__udivdi3>:
  80122c:	55                   	push   %ebp
  80122d:	57                   	push   %edi
  80122e:	56                   	push   %esi
  80122f:	83 ec 10             	sub    $0x10,%esp
  801232:	8b 74 24 20          	mov    0x20(%esp),%esi
  801236:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80123a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80123e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801242:	89 cd                	mov    %ecx,%ebp
  801244:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801248:	85 c0                	test   %eax,%eax
  80124a:	75 2c                	jne    801278 <__udivdi3+0x4c>
  80124c:	39 f9                	cmp    %edi,%ecx
  80124e:	77 68                	ja     8012b8 <__udivdi3+0x8c>
  801250:	85 c9                	test   %ecx,%ecx
  801252:	75 0b                	jne    80125f <__udivdi3+0x33>
  801254:	b8 01 00 00 00       	mov    $0x1,%eax
  801259:	31 d2                	xor    %edx,%edx
  80125b:	f7 f1                	div    %ecx
  80125d:	89 c1                	mov    %eax,%ecx
  80125f:	31 d2                	xor    %edx,%edx
  801261:	89 f8                	mov    %edi,%eax
  801263:	f7 f1                	div    %ecx
  801265:	89 c7                	mov    %eax,%edi
  801267:	89 f0                	mov    %esi,%eax
  801269:	f7 f1                	div    %ecx
  80126b:	89 c6                	mov    %eax,%esi
  80126d:	89 f0                	mov    %esi,%eax
  80126f:	89 fa                	mov    %edi,%edx
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	5e                   	pop    %esi
  801275:	5f                   	pop    %edi
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    
  801278:	39 f8                	cmp    %edi,%eax
  80127a:	77 2c                	ja     8012a8 <__udivdi3+0x7c>
  80127c:	0f bd f0             	bsr    %eax,%esi
  80127f:	83 f6 1f             	xor    $0x1f,%esi
  801282:	75 4c                	jne    8012d0 <__udivdi3+0xa4>
  801284:	39 f8                	cmp    %edi,%eax
  801286:	bf 00 00 00 00       	mov    $0x0,%edi
  80128b:	72 0a                	jb     801297 <__udivdi3+0x6b>
  80128d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801291:	0f 87 ad 00 00 00    	ja     801344 <__udivdi3+0x118>
  801297:	be 01 00 00 00       	mov    $0x1,%esi
  80129c:	89 f0                	mov    %esi,%eax
  80129e:	89 fa                	mov    %edi,%edx
  8012a0:	83 c4 10             	add    $0x10,%esp
  8012a3:	5e                   	pop    %esi
  8012a4:	5f                   	pop    %edi
  8012a5:	5d                   	pop    %ebp
  8012a6:	c3                   	ret    
  8012a7:	90                   	nop
  8012a8:	31 ff                	xor    %edi,%edi
  8012aa:	31 f6                	xor    %esi,%esi
  8012ac:	89 f0                	mov    %esi,%eax
  8012ae:	89 fa                	mov    %edi,%edx
  8012b0:	83 c4 10             	add    $0x10,%esp
  8012b3:	5e                   	pop    %esi
  8012b4:	5f                   	pop    %edi
  8012b5:	5d                   	pop    %ebp
  8012b6:	c3                   	ret    
  8012b7:	90                   	nop
  8012b8:	89 fa                	mov    %edi,%edx
  8012ba:	89 f0                	mov    %esi,%eax
  8012bc:	f7 f1                	div    %ecx
  8012be:	89 c6                	mov    %eax,%esi
  8012c0:	31 ff                	xor    %edi,%edi
  8012c2:	89 f0                	mov    %esi,%eax
  8012c4:	89 fa                	mov    %edi,%edx
  8012c6:	83 c4 10             	add    $0x10,%esp
  8012c9:	5e                   	pop    %esi
  8012ca:	5f                   	pop    %edi
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    
  8012cd:	8d 76 00             	lea    0x0(%esi),%esi
  8012d0:	89 f1                	mov    %esi,%ecx
  8012d2:	d3 e0                	shl    %cl,%eax
  8012d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012d8:	b8 20 00 00 00       	mov    $0x20,%eax
  8012dd:	29 f0                	sub    %esi,%eax
  8012df:	89 ea                	mov    %ebp,%edx
  8012e1:	88 c1                	mov    %al,%cl
  8012e3:	d3 ea                	shr    %cl,%edx
  8012e5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8012e9:	09 ca                	or     %ecx,%edx
  8012eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012ef:	89 f1                	mov    %esi,%ecx
  8012f1:	d3 e5                	shl    %cl,%ebp
  8012f3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8012f7:	89 fd                	mov    %edi,%ebp
  8012f9:	88 c1                	mov    %al,%cl
  8012fb:	d3 ed                	shr    %cl,%ebp
  8012fd:	89 fa                	mov    %edi,%edx
  8012ff:	89 f1                	mov    %esi,%ecx
  801301:	d3 e2                	shl    %cl,%edx
  801303:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801307:	88 c1                	mov    %al,%cl
  801309:	d3 ef                	shr    %cl,%edi
  80130b:	09 d7                	or     %edx,%edi
  80130d:	89 f8                	mov    %edi,%eax
  80130f:	89 ea                	mov    %ebp,%edx
  801311:	f7 74 24 08          	divl   0x8(%esp)
  801315:	89 d1                	mov    %edx,%ecx
  801317:	89 c7                	mov    %eax,%edi
  801319:	f7 64 24 0c          	mull   0xc(%esp)
  80131d:	39 d1                	cmp    %edx,%ecx
  80131f:	72 17                	jb     801338 <__udivdi3+0x10c>
  801321:	74 09                	je     80132c <__udivdi3+0x100>
  801323:	89 fe                	mov    %edi,%esi
  801325:	31 ff                	xor    %edi,%edi
  801327:	e9 41 ff ff ff       	jmp    80126d <__udivdi3+0x41>
  80132c:	8b 54 24 04          	mov    0x4(%esp),%edx
  801330:	89 f1                	mov    %esi,%ecx
  801332:	d3 e2                	shl    %cl,%edx
  801334:	39 c2                	cmp    %eax,%edx
  801336:	73 eb                	jae    801323 <__udivdi3+0xf7>
  801338:	8d 77 ff             	lea    -0x1(%edi),%esi
  80133b:	31 ff                	xor    %edi,%edi
  80133d:	e9 2b ff ff ff       	jmp    80126d <__udivdi3+0x41>
  801342:	66 90                	xchg   %ax,%ax
  801344:	31 f6                	xor    %esi,%esi
  801346:	e9 22 ff ff ff       	jmp    80126d <__udivdi3+0x41>
	...

0080134c <__umoddi3>:
  80134c:	55                   	push   %ebp
  80134d:	57                   	push   %edi
  80134e:	56                   	push   %esi
  80134f:	83 ec 20             	sub    $0x20,%esp
  801352:	8b 44 24 30          	mov    0x30(%esp),%eax
  801356:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80135a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80135e:	8b 74 24 34          	mov    0x34(%esp),%esi
  801362:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801366:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80136a:	89 c7                	mov    %eax,%edi
  80136c:	89 f2                	mov    %esi,%edx
  80136e:	85 ed                	test   %ebp,%ebp
  801370:	75 16                	jne    801388 <__umoddi3+0x3c>
  801372:	39 f1                	cmp    %esi,%ecx
  801374:	0f 86 a6 00 00 00    	jbe    801420 <__umoddi3+0xd4>
  80137a:	f7 f1                	div    %ecx
  80137c:	89 d0                	mov    %edx,%eax
  80137e:	31 d2                	xor    %edx,%edx
  801380:	83 c4 20             	add    $0x20,%esp
  801383:	5e                   	pop    %esi
  801384:	5f                   	pop    %edi
  801385:	5d                   	pop    %ebp
  801386:	c3                   	ret    
  801387:	90                   	nop
  801388:	39 f5                	cmp    %esi,%ebp
  80138a:	0f 87 ac 00 00 00    	ja     80143c <__umoddi3+0xf0>
  801390:	0f bd c5             	bsr    %ebp,%eax
  801393:	83 f0 1f             	xor    $0x1f,%eax
  801396:	89 44 24 10          	mov    %eax,0x10(%esp)
  80139a:	0f 84 a8 00 00 00    	je     801448 <__umoddi3+0xfc>
  8013a0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8013a4:	d3 e5                	shl    %cl,%ebp
  8013a6:	bf 20 00 00 00       	mov    $0x20,%edi
  8013ab:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8013af:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8013b3:	89 f9                	mov    %edi,%ecx
  8013b5:	d3 e8                	shr    %cl,%eax
  8013b7:	09 e8                	or     %ebp,%eax
  8013b9:	89 44 24 18          	mov    %eax,0x18(%esp)
  8013bd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8013c1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8013c5:	d3 e0                	shl    %cl,%eax
  8013c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013cb:	89 f2                	mov    %esi,%edx
  8013cd:	d3 e2                	shl    %cl,%edx
  8013cf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8013d3:	d3 e0                	shl    %cl,%eax
  8013d5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8013d9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8013dd:	89 f9                	mov    %edi,%ecx
  8013df:	d3 e8                	shr    %cl,%eax
  8013e1:	09 d0                	or     %edx,%eax
  8013e3:	d3 ee                	shr    %cl,%esi
  8013e5:	89 f2                	mov    %esi,%edx
  8013e7:	f7 74 24 18          	divl   0x18(%esp)
  8013eb:	89 d6                	mov    %edx,%esi
  8013ed:	f7 64 24 0c          	mull   0xc(%esp)
  8013f1:	89 c5                	mov    %eax,%ebp
  8013f3:	89 d1                	mov    %edx,%ecx
  8013f5:	39 d6                	cmp    %edx,%esi
  8013f7:	72 67                	jb     801460 <__umoddi3+0x114>
  8013f9:	74 75                	je     801470 <__umoddi3+0x124>
  8013fb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8013ff:	29 e8                	sub    %ebp,%eax
  801401:	19 ce                	sbb    %ecx,%esi
  801403:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801407:	d3 e8                	shr    %cl,%eax
  801409:	89 f2                	mov    %esi,%edx
  80140b:	89 f9                	mov    %edi,%ecx
  80140d:	d3 e2                	shl    %cl,%edx
  80140f:	09 d0                	or     %edx,%eax
  801411:	89 f2                	mov    %esi,%edx
  801413:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801417:	d3 ea                	shr    %cl,%edx
  801419:	83 c4 20             	add    $0x20,%esp
  80141c:	5e                   	pop    %esi
  80141d:	5f                   	pop    %edi
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    
  801420:	85 c9                	test   %ecx,%ecx
  801422:	75 0b                	jne    80142f <__umoddi3+0xe3>
  801424:	b8 01 00 00 00       	mov    $0x1,%eax
  801429:	31 d2                	xor    %edx,%edx
  80142b:	f7 f1                	div    %ecx
  80142d:	89 c1                	mov    %eax,%ecx
  80142f:	89 f0                	mov    %esi,%eax
  801431:	31 d2                	xor    %edx,%edx
  801433:	f7 f1                	div    %ecx
  801435:	89 f8                	mov    %edi,%eax
  801437:	e9 3e ff ff ff       	jmp    80137a <__umoddi3+0x2e>
  80143c:	89 f2                	mov    %esi,%edx
  80143e:	83 c4 20             	add    $0x20,%esp
  801441:	5e                   	pop    %esi
  801442:	5f                   	pop    %edi
  801443:	5d                   	pop    %ebp
  801444:	c3                   	ret    
  801445:	8d 76 00             	lea    0x0(%esi),%esi
  801448:	39 f5                	cmp    %esi,%ebp
  80144a:	72 04                	jb     801450 <__umoddi3+0x104>
  80144c:	39 f9                	cmp    %edi,%ecx
  80144e:	77 06                	ja     801456 <__umoddi3+0x10a>
  801450:	89 f2                	mov    %esi,%edx
  801452:	29 cf                	sub    %ecx,%edi
  801454:	19 ea                	sbb    %ebp,%edx
  801456:	89 f8                	mov    %edi,%eax
  801458:	83 c4 20             	add    $0x20,%esp
  80145b:	5e                   	pop    %esi
  80145c:	5f                   	pop    %edi
  80145d:	5d                   	pop    %ebp
  80145e:	c3                   	ret    
  80145f:	90                   	nop
  801460:	89 d1                	mov    %edx,%ecx
  801462:	89 c5                	mov    %eax,%ebp
  801464:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801468:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80146c:	eb 8d                	jmp    8013fb <__umoddi3+0xaf>
  80146e:	66 90                	xchg   %ax,%ax
  801470:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801474:	72 ea                	jb     801460 <__umoddi3+0x114>
  801476:	89 f1                	mov    %esi,%ecx
  801478:	eb 81                	jmp    8013fb <__umoddi3+0xaf>
