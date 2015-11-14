
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 17 01 00 00       	call   800148 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 34 24             	mov    %esi,(%esp)
  800053:	e8 0c 11 00 00       	call   801164 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 08 20 80 00       	mov    0x802008,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 c0 15 80 00 	movl   $0x8015c0,(%esp)
  800071:	e8 2e 02 00 00       	call   8002a4 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 24 0f 00 00       	call   800f9f <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 0c 19 80 	movl   $0x80190c,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 cc 15 80 00 	movl   $0x8015cc,(%esp)
  80009c:	e8 0b 01 00 00       	call   8001ac <_panic>
	if (id == 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	74 9b                	je     800040 <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a5:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 34 24             	mov    %esi,(%esp)
  8000bb:	e8 a4 10 00 00       	call   801164 <ipc_recv>
  8000c0:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c2:	99                   	cltd   
  8000c3:	f7 fb                	idiv   %ebx
  8000c5:	85 d2                	test   %edx,%edx
  8000c7:	74 df                	je     8000a8 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000c9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d0:	00 
  8000d1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d8:	00 
  8000d9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000dd:	89 3c 24             	mov    %edi,(%esp)
  8000e0:	e8 e6 10 00 00       	call   8011cb <ipc_send>
  8000e5:	eb c1                	jmp    8000a8 <primeproc+0x74>

008000e7 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
  8000ec:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ef:	e8 ab 0e 00 00       	call   800f9f <fork>
  8000f4:	89 c6                	mov    %eax,%esi
  8000f6:	85 c0                	test   %eax,%eax
  8000f8:	79 20                	jns    80011a <umain+0x33>
		panic("fork: %e", id);
  8000fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fe:	c7 44 24 08 0c 19 80 	movl   $0x80190c,0x8(%esp)
  800105:	00 
  800106:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80010d:	00 
  80010e:	c7 04 24 cc 15 80 00 	movl   $0x8015cc,(%esp)
  800115:	e8 92 00 00 00       	call   8001ac <_panic>
	if (id == 0)
  80011a:	bb 02 00 00 00       	mov    $0x2,%ebx
  80011f:	85 c0                	test   %eax,%eax
  800121:	75 05                	jne    800128 <umain+0x41>
		primeproc();
  800123:	e8 0c ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  800128:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80012f:	00 
  800130:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800137:	00 
  800138:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013c:	89 34 24             	mov    %esi,(%esp)
  80013f:	e8 87 10 00 00       	call   8011cb <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800144:	43                   	inc    %ebx
  800145:	eb e1                	jmp    800128 <umain+0x41>
	...

00800148 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 10             	sub    $0x10,%esp
  800150:	8b 75 08             	mov    0x8(%ebp),%esi
  800153:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800156:	e8 ac 0a 00 00       	call   800c07 <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	8d 14 80             	lea    (%eax,%eax,4),%edx
  800163:	8d 14 90             	lea    (%eax,%edx,4),%edx
  800166:	8d 04 50             	lea    (%eax,%edx,2),%eax
  800169:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  800170:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800175:	85 f6                	test   %esi,%esi
  800177:	7e 07                	jle    800180 <libmain+0x38>
		binaryname = argv[0];
  800179:	8b 03                	mov    (%ebx),%eax
  80017b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800180:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800184:	89 34 24             	mov    %esi,(%esp)
  800187:	e8 5b ff ff ff       	call   8000e7 <umain>

	// exit gracefully
	exit();
  80018c:	e8 07 00 00 00       	call   800198 <exit>
}
  800191:	83 c4 10             	add    $0x10,%esp
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80019e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a5:	e8 0b 0a 00 00       	call   800bb5 <sys_env_destroy>
}
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001b4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001b7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001bd:	e8 45 0a 00 00       	call   800c07 <sys_getenvid>
  8001c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001d0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d8:	c7 04 24 e4 15 80 00 	movl   $0x8015e4,(%esp)
  8001df:	e8 c0 00 00 00       	call   8002a4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001eb:	89 04 24             	mov    %eax,(%esp)
  8001ee:	e8 50 00 00 00       	call   800243 <vcprintf>
	cprintf("\n");
  8001f3:	c7 04 24 07 16 80 00 	movl   $0x801607,(%esp)
  8001fa:	e8 a5 00 00 00       	call   8002a4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ff:	cc                   	int3   
  800200:	eb fd                	jmp    8001ff <_panic+0x53>
	...

00800204 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	53                   	push   %ebx
  800208:	83 ec 14             	sub    $0x14,%esp
  80020b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80020e:	8b 03                	mov    (%ebx),%eax
  800210:	8b 55 08             	mov    0x8(%ebp),%edx
  800213:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800217:	40                   	inc    %eax
  800218:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80021a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80021f:	75 19                	jne    80023a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800221:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800228:	00 
  800229:	8d 43 08             	lea    0x8(%ebx),%eax
  80022c:	89 04 24             	mov    %eax,(%esp)
  80022f:	e8 44 09 00 00       	call   800b78 <sys_cputs>
		b->idx = 0;
  800234:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80023a:	ff 43 04             	incl   0x4(%ebx)
}
  80023d:	83 c4 14             	add    $0x14,%esp
  800240:	5b                   	pop    %ebx
  800241:	5d                   	pop    %ebp
  800242:	c3                   	ret    

00800243 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80024c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800253:	00 00 00 
	b.cnt = 0;
  800256:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800260:	8b 45 0c             	mov    0xc(%ebp),%eax
  800263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800267:	8b 45 08             	mov    0x8(%ebp),%eax
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800274:	89 44 24 04          	mov    %eax,0x4(%esp)
  800278:	c7 04 24 04 02 80 00 	movl   $0x800204,(%esp)
  80027f:	e8 b4 01 00 00       	call   800438 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800284:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80028a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800294:	89 04 24             	mov    %eax,(%esp)
  800297:	e8 dc 08 00 00       	call   800b78 <sys_cputs>

	return b.cnt;
}
  80029c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002aa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b4:	89 04 24             	mov    %eax,(%esp)
  8002b7:	e8 87 ff ff ff       	call   800243 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    
	...

008002c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 3c             	sub    $0x3c,%esp
  8002c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002cc:	89 d7                	mov    %edx,%edi
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002da:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002dd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e0:	85 c0                	test   %eax,%eax
  8002e2:	75 08                	jne    8002ec <printnum+0x2c>
  8002e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ea:	77 57                	ja     800343 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ec:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002f0:	4b                   	dec    %ebx
  8002f1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800300:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800304:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80030b:	00 
  80030c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030f:	89 04 24             	mov    %eax,(%esp)
  800312:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800315:	89 44 24 04          	mov    %eax,0x4(%esp)
  800319:	e8 3e 10 00 00       	call   80135c <__udivdi3>
  80031e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800322:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800326:	89 04 24             	mov    %eax,(%esp)
  800329:	89 54 24 04          	mov    %edx,0x4(%esp)
  80032d:	89 fa                	mov    %edi,%edx
  80032f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800332:	e8 89 ff ff ff       	call   8002c0 <printnum>
  800337:	eb 0f                	jmp    800348 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800339:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80033d:	89 34 24             	mov    %esi,(%esp)
  800340:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800343:	4b                   	dec    %ebx
  800344:	85 db                	test   %ebx,%ebx
  800346:	7f f1                	jg     800339 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800348:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80034c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800350:	8b 45 10             	mov    0x10(%ebp),%eax
  800353:	89 44 24 08          	mov    %eax,0x8(%esp)
  800357:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80035e:	00 
  80035f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800362:	89 04 24             	mov    %eax,(%esp)
  800365:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800368:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036c:	e8 0b 11 00 00       	call   80147c <__umoddi3>
  800371:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800375:	0f be 80 09 16 80 00 	movsbl 0x801609(%eax),%eax
  80037c:	89 04 24             	mov    %eax,(%esp)
  80037f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800382:	83 c4 3c             	add    $0x3c,%esp
  800385:	5b                   	pop    %ebx
  800386:	5e                   	pop    %esi
  800387:	5f                   	pop    %edi
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    

0080038a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80038d:	83 fa 01             	cmp    $0x1,%edx
  800390:	7e 0e                	jle    8003a0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800392:	8b 10                	mov    (%eax),%edx
  800394:	8d 4a 08             	lea    0x8(%edx),%ecx
  800397:	89 08                	mov    %ecx,(%eax)
  800399:	8b 02                	mov    (%edx),%eax
  80039b:	8b 52 04             	mov    0x4(%edx),%edx
  80039e:	eb 22                	jmp    8003c2 <getuint+0x38>
	else if (lflag)
  8003a0:	85 d2                	test   %edx,%edx
  8003a2:	74 10                	je     8003b4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a4:	8b 10                	mov    (%eax),%edx
  8003a6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a9:	89 08                	mov    %ecx,(%eax)
  8003ab:	8b 02                	mov    (%edx),%eax
  8003ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b2:	eb 0e                	jmp    8003c2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b4:	8b 10                	mov    (%eax),%edx
  8003b6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b9:	89 08                	mov    %ecx,(%eax)
  8003bb:	8b 02                	mov    (%edx),%eax
  8003bd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c2:	5d                   	pop    %ebp
  8003c3:	c3                   	ret    

008003c4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c7:	83 fa 01             	cmp    $0x1,%edx
  8003ca:	7e 0e                	jle    8003da <getint+0x16>
		return va_arg(*ap, long long);
  8003cc:	8b 10                	mov    (%eax),%edx
  8003ce:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d1:	89 08                	mov    %ecx,(%eax)
  8003d3:	8b 02                	mov    (%edx),%eax
  8003d5:	8b 52 04             	mov    0x4(%edx),%edx
  8003d8:	eb 1a                	jmp    8003f4 <getint+0x30>
	else if (lflag)
  8003da:	85 d2                	test   %edx,%edx
  8003dc:	74 0c                	je     8003ea <getint+0x26>
		return va_arg(*ap, long);
  8003de:	8b 10                	mov    (%eax),%edx
  8003e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e3:	89 08                	mov    %ecx,(%eax)
  8003e5:	8b 02                	mov    (%edx),%eax
  8003e7:	99                   	cltd   
  8003e8:	eb 0a                	jmp    8003f4 <getint+0x30>
	else
		return va_arg(*ap, int);
  8003ea:	8b 10                	mov    (%eax),%edx
  8003ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ef:	89 08                	mov    %ecx,(%eax)
  8003f1:	8b 02                	mov    (%edx),%eax
  8003f3:	99                   	cltd   
}
  8003f4:	5d                   	pop    %ebp
  8003f5:	c3                   	ret    

008003f6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003f6:	55                   	push   %ebp
  8003f7:	89 e5                	mov    %esp,%ebp
  8003f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003fc:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003ff:	8b 10                	mov    (%eax),%edx
  800401:	3b 50 04             	cmp    0x4(%eax),%edx
  800404:	73 08                	jae    80040e <sprintputch+0x18>
		*b->buf++ = ch;
  800406:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800409:	88 0a                	mov    %cl,(%edx)
  80040b:	42                   	inc    %edx
  80040c:	89 10                	mov    %edx,(%eax)
}
  80040e:	5d                   	pop    %ebp
  80040f:	c3                   	ret    

00800410 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800416:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800419:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80041d:	8b 45 10             	mov    0x10(%ebp),%eax
  800420:	89 44 24 08          	mov    %eax,0x8(%esp)
  800424:	8b 45 0c             	mov    0xc(%ebp),%eax
  800427:	89 44 24 04          	mov    %eax,0x4(%esp)
  80042b:	8b 45 08             	mov    0x8(%ebp),%eax
  80042e:	89 04 24             	mov    %eax,(%esp)
  800431:	e8 02 00 00 00       	call   800438 <vprintfmt>
	va_end(ap);
}
  800436:	c9                   	leave  
  800437:	c3                   	ret    

00800438 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	57                   	push   %edi
  80043c:	56                   	push   %esi
  80043d:	53                   	push   %ebx
  80043e:	83 ec 4c             	sub    $0x4c,%esp
  800441:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800444:	8b 75 10             	mov    0x10(%ebp),%esi
  800447:	eb 12                	jmp    80045b <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800449:	85 c0                	test   %eax,%eax
  80044b:	0f 84 40 03 00 00    	je     800791 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800451:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800455:	89 04 24             	mov    %eax,(%esp)
  800458:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80045b:	0f b6 06             	movzbl (%esi),%eax
  80045e:	46                   	inc    %esi
  80045f:	83 f8 25             	cmp    $0x25,%eax
  800462:	75 e5                	jne    800449 <vprintfmt+0x11>
  800464:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800468:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80046f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800474:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80047b:	ba 00 00 00 00       	mov    $0x0,%edx
  800480:	eb 26                	jmp    8004a8 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800485:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800489:	eb 1d                	jmp    8004a8 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80048e:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800492:	eb 14                	jmp    8004a8 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800497:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80049e:	eb 08                	jmp    8004a8 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004a0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004a3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	0f b6 06             	movzbl (%esi),%eax
  8004ab:	8d 4e 01             	lea    0x1(%esi),%ecx
  8004ae:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004b1:	8a 0e                	mov    (%esi),%cl
  8004b3:	83 e9 23             	sub    $0x23,%ecx
  8004b6:	80 f9 55             	cmp    $0x55,%cl
  8004b9:	0f 87 b6 02 00 00    	ja     800775 <vprintfmt+0x33d>
  8004bf:	0f b6 c9             	movzbl %cl,%ecx
  8004c2:	ff 24 8d c0 16 80 00 	jmp    *0x8016c0(,%ecx,4)
  8004c9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004cc:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d1:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  8004d4:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  8004d8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004db:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004de:	83 f9 09             	cmp    $0x9,%ecx
  8004e1:	77 2a                	ja     80050d <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e3:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004e4:	eb eb                	jmp    8004d1 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e9:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ec:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ef:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004f4:	eb 17                	jmp    80050d <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004f6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004fa:	78 98                	js     800494 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ff:	eb a7                	jmp    8004a8 <vprintfmt+0x70>
  800501:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800504:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80050b:	eb 9b                	jmp    8004a8 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80050d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800511:	79 95                	jns    8004a8 <vprintfmt+0x70>
  800513:	eb 8b                	jmp    8004a0 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800515:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800516:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800519:	eb 8d                	jmp    8004a8 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 50 04             	lea    0x4(%eax),%edx
  800521:	89 55 14             	mov    %edx,0x14(%ebp)
  800524:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800528:	8b 00                	mov    (%eax),%eax
  80052a:	89 04 24             	mov    %eax,(%esp)
  80052d:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800533:	e9 23 ff ff ff       	jmp    80045b <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 50 04             	lea    0x4(%eax),%edx
  80053e:	89 55 14             	mov    %edx,0x14(%ebp)
  800541:	8b 00                	mov    (%eax),%eax
  800543:	85 c0                	test   %eax,%eax
  800545:	79 02                	jns    800549 <vprintfmt+0x111>
  800547:	f7 d8                	neg    %eax
  800549:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054b:	83 f8 09             	cmp    $0x9,%eax
  80054e:	7f 0b                	jg     80055b <vprintfmt+0x123>
  800550:	8b 04 85 20 18 80 00 	mov    0x801820(,%eax,4),%eax
  800557:	85 c0                	test   %eax,%eax
  800559:	75 23                	jne    80057e <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80055b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80055f:	c7 44 24 08 21 16 80 	movl   $0x801621,0x8(%esp)
  800566:	00 
  800567:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80056b:	8b 45 08             	mov    0x8(%ebp),%eax
  80056e:	89 04 24             	mov    %eax,(%esp)
  800571:	e8 9a fe ff ff       	call   800410 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800576:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800579:	e9 dd fe ff ff       	jmp    80045b <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80057e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800582:	c7 44 24 08 2a 16 80 	movl   $0x80162a,0x8(%esp)
  800589:	00 
  80058a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80058e:	8b 55 08             	mov    0x8(%ebp),%edx
  800591:	89 14 24             	mov    %edx,(%esp)
  800594:	e8 77 fe ff ff       	call   800410 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800599:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80059c:	e9 ba fe ff ff       	jmp    80045b <vprintfmt+0x23>
  8005a1:	89 f9                	mov    %edi,%ecx
  8005a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 50 04             	lea    0x4(%eax),%edx
  8005af:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b2:	8b 30                	mov    (%eax),%esi
  8005b4:	85 f6                	test   %esi,%esi
  8005b6:	75 05                	jne    8005bd <vprintfmt+0x185>
				p = "(null)";
  8005b8:	be 1a 16 80 00       	mov    $0x80161a,%esi
			if (width > 0 && padc != '-')
  8005bd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005c1:	0f 8e 84 00 00 00    	jle    80064b <vprintfmt+0x213>
  8005c7:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005cb:	74 7e                	je     80064b <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005d1:	89 34 24             	mov    %esi,(%esp)
  8005d4:	e8 5d 02 00 00       	call   800836 <strnlen>
  8005d9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005dc:	29 c2                	sub    %eax,%edx
  8005de:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005e1:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8005e5:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005e8:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005eb:	89 de                	mov    %ebx,%esi
  8005ed:	89 d3                	mov    %edx,%ebx
  8005ef:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f1:	eb 0b                	jmp    8005fe <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f7:	89 3c 24             	mov    %edi,(%esp)
  8005fa:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fd:	4b                   	dec    %ebx
  8005fe:	85 db                	test   %ebx,%ebx
  800600:	7f f1                	jg     8005f3 <vprintfmt+0x1bb>
  800602:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800605:	89 f3                	mov    %esi,%ebx
  800607:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80060a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80060d:	85 c0                	test   %eax,%eax
  80060f:	79 05                	jns    800616 <vprintfmt+0x1de>
  800611:	b8 00 00 00 00       	mov    $0x0,%eax
  800616:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800619:	29 c2                	sub    %eax,%edx
  80061b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80061e:	eb 2b                	jmp    80064b <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800620:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800624:	74 18                	je     80063e <vprintfmt+0x206>
  800626:	8d 50 e0             	lea    -0x20(%eax),%edx
  800629:	83 fa 5e             	cmp    $0x5e,%edx
  80062c:	76 10                	jbe    80063e <vprintfmt+0x206>
					putch('?', putdat);
  80062e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800632:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800639:	ff 55 08             	call   *0x8(%ebp)
  80063c:	eb 0a                	jmp    800648 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80063e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800642:	89 04 24             	mov    %eax,(%esp)
  800645:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800648:	ff 4d e4             	decl   -0x1c(%ebp)
  80064b:	0f be 06             	movsbl (%esi),%eax
  80064e:	46                   	inc    %esi
  80064f:	85 c0                	test   %eax,%eax
  800651:	74 21                	je     800674 <vprintfmt+0x23c>
  800653:	85 ff                	test   %edi,%edi
  800655:	78 c9                	js     800620 <vprintfmt+0x1e8>
  800657:	4f                   	dec    %edi
  800658:	79 c6                	jns    800620 <vprintfmt+0x1e8>
  80065a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80065d:	89 de                	mov    %ebx,%esi
  80065f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800662:	eb 18                	jmp    80067c <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800664:	89 74 24 04          	mov    %esi,0x4(%esp)
  800668:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80066f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800671:	4b                   	dec    %ebx
  800672:	eb 08                	jmp    80067c <vprintfmt+0x244>
  800674:	8b 7d 08             	mov    0x8(%ebp),%edi
  800677:	89 de                	mov    %ebx,%esi
  800679:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80067c:	85 db                	test   %ebx,%ebx
  80067e:	7f e4                	jg     800664 <vprintfmt+0x22c>
  800680:	89 7d 08             	mov    %edi,0x8(%ebp)
  800683:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800685:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800688:	e9 ce fd ff ff       	jmp    80045b <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80068d:	8d 45 14             	lea    0x14(%ebp),%eax
  800690:	e8 2f fd ff ff       	call   8003c4 <getint>
  800695:	89 c6                	mov    %eax,%esi
  800697:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800699:	85 d2                	test   %edx,%edx
  80069b:	78 07                	js     8006a4 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80069d:	be 0a 00 00 00       	mov    $0xa,%esi
  8006a2:	eb 7e                	jmp    800722 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006af:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006b2:	89 f0                	mov    %esi,%eax
  8006b4:	89 fa                	mov    %edi,%edx
  8006b6:	f7 d8                	neg    %eax
  8006b8:	83 d2 00             	adc    $0x0,%edx
  8006bb:	f7 da                	neg    %edx
			}
			base = 10;
  8006bd:	be 0a 00 00 00       	mov    $0xa,%esi
  8006c2:	eb 5e                	jmp    800722 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c7:	e8 be fc ff ff       	call   80038a <getuint>
			base = 10;
  8006cc:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8006d1:	eb 4f                	jmp    800722 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8006d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d6:	e8 af fc ff ff       	call   80038a <getuint>
			base = 8;
  8006db:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8006e0:	eb 40                	jmp    800722 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  8006e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006ed:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006fb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8d 50 04             	lea    0x4(%eax),%edx
  800704:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800707:	8b 00                	mov    (%eax),%eax
  800709:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80070e:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800713:	eb 0d                	jmp    800722 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800715:	8d 45 14             	lea    0x14(%ebp),%eax
  800718:	e8 6d fc ff ff       	call   80038a <getuint>
			base = 16;
  80071d:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800722:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800726:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80072a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80072d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800731:	89 74 24 08          	mov    %esi,0x8(%esp)
  800735:	89 04 24             	mov    %eax,(%esp)
  800738:	89 54 24 04          	mov    %edx,0x4(%esp)
  80073c:	89 da                	mov    %ebx,%edx
  80073e:	8b 45 08             	mov    0x8(%ebp),%eax
  800741:	e8 7a fb ff ff       	call   8002c0 <printnum>
			break;
  800746:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800749:	e9 0d fd ff ff       	jmp    80045b <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  80074e:	8d 45 14             	lea    0x14(%ebp),%eax
  800751:	e8 6e fc ff ff       	call   8003c4 <getint>
  800756:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  80075e:	e9 f8 fc ff ff       	jmp    80045b <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800763:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800767:	89 04 24             	mov    %eax,(%esp)
  80076a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800770:	e9 e6 fc ff ff       	jmp    80045b <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800775:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800779:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800780:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800783:	eb 01                	jmp    800786 <vprintfmt+0x34e>
  800785:	4e                   	dec    %esi
  800786:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80078a:	75 f9                	jne    800785 <vprintfmt+0x34d>
  80078c:	e9 ca fc ff ff       	jmp    80045b <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800791:	83 c4 4c             	add    $0x4c,%esp
  800794:	5b                   	pop    %ebx
  800795:	5e                   	pop    %esi
  800796:	5f                   	pop    %edi
  800797:	5d                   	pop    %ebp
  800798:	c3                   	ret    

00800799 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 28             	sub    $0x28,%esp
  80079f:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ac:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b6:	85 c0                	test   %eax,%eax
  8007b8:	74 30                	je     8007ea <vsnprintf+0x51>
  8007ba:	85 d2                	test   %edx,%edx
  8007bc:	7e 33                	jle    8007f1 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007be:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007cc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d3:	c7 04 24 f6 03 80 00 	movl   $0x8003f6,(%esp)
  8007da:	e8 59 fc ff ff       	call   800438 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007df:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e8:	eb 0c                	jmp    8007f6 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ef:	eb 05                	jmp    8007f6 <vsnprintf+0x5d>
  8007f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    

008007f8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007fe:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800801:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800805:	8b 45 10             	mov    0x10(%ebp),%eax
  800808:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80080f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	89 04 24             	mov    %eax,(%esp)
  800819:	e8 7b ff ff ff       	call   800799 <vsnprintf>
	va_end(ap);

	return rc;
}
  80081e:	c9                   	leave  
  80081f:	c3                   	ret    

00800820 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
  80082b:	eb 01                	jmp    80082e <strlen+0xe>
		n++;
  80082d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80082e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800832:	75 f9                	jne    80082d <strlen+0xd>
		n++;
	return n;
}
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80083c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083f:	b8 00 00 00 00       	mov    $0x0,%eax
  800844:	eb 01                	jmp    800847 <strnlen+0x11>
		n++;
  800846:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800847:	39 d0                	cmp    %edx,%eax
  800849:	74 06                	je     800851 <strnlen+0x1b>
  80084b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80084f:	75 f5                	jne    800846 <strnlen+0x10>
		n++;
	return n;
}
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	53                   	push   %ebx
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085d:	ba 00 00 00 00       	mov    $0x0,%edx
  800862:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800865:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800868:	42                   	inc    %edx
  800869:	84 c9                	test   %cl,%cl
  80086b:	75 f5                	jne    800862 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80086d:	5b                   	pop    %ebx
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    

00800870 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	53                   	push   %ebx
  800874:	83 ec 08             	sub    $0x8,%esp
  800877:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80087a:	89 1c 24             	mov    %ebx,(%esp)
  80087d:	e8 9e ff ff ff       	call   800820 <strlen>
	strcpy(dst + len, src);
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
  800885:	89 54 24 04          	mov    %edx,0x4(%esp)
  800889:	01 d8                	add    %ebx,%eax
  80088b:	89 04 24             	mov    %eax,(%esp)
  80088e:	e8 c0 ff ff ff       	call   800853 <strcpy>
	return dst;
}
  800893:	89 d8                	mov    %ebx,%eax
  800895:	83 c4 08             	add    $0x8,%esp
  800898:	5b                   	pop    %ebx
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	56                   	push   %esi
  80089f:	53                   	push   %ebx
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ae:	eb 0c                	jmp    8008bc <strncpy+0x21>
		*dst++ = *src;
  8008b0:	8a 1a                	mov    (%edx),%bl
  8008b2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b5:	80 3a 01             	cmpb   $0x1,(%edx)
  8008b8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008bb:	41                   	inc    %ecx
  8008bc:	39 f1                	cmp    %esi,%ecx
  8008be:	75 f0                	jne    8008b0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008c0:	5b                   	pop    %ebx
  8008c1:	5e                   	pop    %esi
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	56                   	push   %esi
  8008c8:	53                   	push   %ebx
  8008c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cf:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d2:	85 d2                	test   %edx,%edx
  8008d4:	75 0a                	jne    8008e0 <strlcpy+0x1c>
  8008d6:	89 f0                	mov    %esi,%eax
  8008d8:	eb 1a                	jmp    8008f4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008da:	88 18                	mov    %bl,(%eax)
  8008dc:	40                   	inc    %eax
  8008dd:	41                   	inc    %ecx
  8008de:	eb 02                	jmp    8008e2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008e2:	4a                   	dec    %edx
  8008e3:	74 0a                	je     8008ef <strlcpy+0x2b>
  8008e5:	8a 19                	mov    (%ecx),%bl
  8008e7:	84 db                	test   %bl,%bl
  8008e9:	75 ef                	jne    8008da <strlcpy+0x16>
  8008eb:	89 c2                	mov    %eax,%edx
  8008ed:	eb 02                	jmp    8008f1 <strlcpy+0x2d>
  8008ef:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008f1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008f4:	29 f0                	sub    %esi,%eax
}
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800900:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800903:	eb 02                	jmp    800907 <strcmp+0xd>
		p++, q++;
  800905:	41                   	inc    %ecx
  800906:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800907:	8a 01                	mov    (%ecx),%al
  800909:	84 c0                	test   %al,%al
  80090b:	74 04                	je     800911 <strcmp+0x17>
  80090d:	3a 02                	cmp    (%edx),%al
  80090f:	74 f4                	je     800905 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800911:	0f b6 c0             	movzbl %al,%eax
  800914:	0f b6 12             	movzbl (%edx),%edx
  800917:	29 d0                	sub    %edx,%eax
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	53                   	push   %ebx
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800925:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800928:	eb 03                	jmp    80092d <strncmp+0x12>
		n--, p++, q++;
  80092a:	4a                   	dec    %edx
  80092b:	40                   	inc    %eax
  80092c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80092d:	85 d2                	test   %edx,%edx
  80092f:	74 14                	je     800945 <strncmp+0x2a>
  800931:	8a 18                	mov    (%eax),%bl
  800933:	84 db                	test   %bl,%bl
  800935:	74 04                	je     80093b <strncmp+0x20>
  800937:	3a 19                	cmp    (%ecx),%bl
  800939:	74 ef                	je     80092a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80093b:	0f b6 00             	movzbl (%eax),%eax
  80093e:	0f b6 11             	movzbl (%ecx),%edx
  800941:	29 d0                	sub    %edx,%eax
  800943:	eb 05                	jmp    80094a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800945:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80094a:	5b                   	pop    %ebx
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800956:	eb 05                	jmp    80095d <strchr+0x10>
		if (*s == c)
  800958:	38 ca                	cmp    %cl,%dl
  80095a:	74 0c                	je     800968 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80095c:	40                   	inc    %eax
  80095d:	8a 10                	mov    (%eax),%dl
  80095f:	84 d2                	test   %dl,%dl
  800961:	75 f5                	jne    800958 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800963:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800973:	eb 05                	jmp    80097a <strfind+0x10>
		if (*s == c)
  800975:	38 ca                	cmp    %cl,%dl
  800977:	74 07                	je     800980 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800979:	40                   	inc    %eax
  80097a:	8a 10                	mov    (%eax),%dl
  80097c:	84 d2                	test   %dl,%dl
  80097e:	75 f5                	jne    800975 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	57                   	push   %edi
  800986:	56                   	push   %esi
  800987:	53                   	push   %ebx
  800988:	8b 7d 08             	mov    0x8(%ebp),%edi
  80098b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800991:	85 c9                	test   %ecx,%ecx
  800993:	74 30                	je     8009c5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800995:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099b:	75 25                	jne    8009c2 <memset+0x40>
  80099d:	f6 c1 03             	test   $0x3,%cl
  8009a0:	75 20                	jne    8009c2 <memset+0x40>
		c &= 0xFF;
  8009a2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a5:	89 d3                	mov    %edx,%ebx
  8009a7:	c1 e3 08             	shl    $0x8,%ebx
  8009aa:	89 d6                	mov    %edx,%esi
  8009ac:	c1 e6 18             	shl    $0x18,%esi
  8009af:	89 d0                	mov    %edx,%eax
  8009b1:	c1 e0 10             	shl    $0x10,%eax
  8009b4:	09 f0                	or     %esi,%eax
  8009b6:	09 d0                	or     %edx,%eax
  8009b8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ba:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009bd:	fc                   	cld    
  8009be:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c0:	eb 03                	jmp    8009c5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c2:	fc                   	cld    
  8009c3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c5:	89 f8                	mov    %edi,%eax
  8009c7:	5b                   	pop    %ebx
  8009c8:	5e                   	pop    %esi
  8009c9:	5f                   	pop    %edi
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	57                   	push   %edi
  8009d0:	56                   	push   %esi
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009da:	39 c6                	cmp    %eax,%esi
  8009dc:	73 34                	jae    800a12 <memmove+0x46>
  8009de:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e1:	39 d0                	cmp    %edx,%eax
  8009e3:	73 2d                	jae    800a12 <memmove+0x46>
		s += n;
		d += n;
  8009e5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e8:	f6 c2 03             	test   $0x3,%dl
  8009eb:	75 1b                	jne    800a08 <memmove+0x3c>
  8009ed:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f3:	75 13                	jne    800a08 <memmove+0x3c>
  8009f5:	f6 c1 03             	test   $0x3,%cl
  8009f8:	75 0e                	jne    800a08 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009fa:	83 ef 04             	sub    $0x4,%edi
  8009fd:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a00:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a03:	fd                   	std    
  800a04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a06:	eb 07                	jmp    800a0f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a08:	4f                   	dec    %edi
  800a09:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a0c:	fd                   	std    
  800a0d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0f:	fc                   	cld    
  800a10:	eb 20                	jmp    800a32 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a12:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a18:	75 13                	jne    800a2d <memmove+0x61>
  800a1a:	a8 03                	test   $0x3,%al
  800a1c:	75 0f                	jne    800a2d <memmove+0x61>
  800a1e:	f6 c1 03             	test   $0x3,%cl
  800a21:	75 0a                	jne    800a2d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a23:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a26:	89 c7                	mov    %eax,%edi
  800a28:	fc                   	cld    
  800a29:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2b:	eb 05                	jmp    800a32 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a2d:	89 c7                	mov    %eax,%edi
  800a2f:	fc                   	cld    
  800a30:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a32:	5e                   	pop    %esi
  800a33:	5f                   	pop    %edi
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a3c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a3f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a46:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	89 04 24             	mov    %eax,(%esp)
  800a50:	e8 77 ff ff ff       	call   8009cc <memmove>
}
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    

00800a57 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	57                   	push   %edi
  800a5b:	56                   	push   %esi
  800a5c:	53                   	push   %ebx
  800a5d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a60:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a66:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6b:	eb 16                	jmp    800a83 <memcmp+0x2c>
		if (*s1 != *s2)
  800a6d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a70:	42                   	inc    %edx
  800a71:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a75:	38 c8                	cmp    %cl,%al
  800a77:	74 0a                	je     800a83 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a79:	0f b6 c0             	movzbl %al,%eax
  800a7c:	0f b6 c9             	movzbl %cl,%ecx
  800a7f:	29 c8                	sub    %ecx,%eax
  800a81:	eb 09                	jmp    800a8c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a83:	39 da                	cmp    %ebx,%edx
  800a85:	75 e6                	jne    800a6d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5f                   	pop    %edi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	8b 45 08             	mov    0x8(%ebp),%eax
  800a97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a9a:	89 c2                	mov    %eax,%edx
  800a9c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a9f:	eb 05                	jmp    800aa6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa1:	38 08                	cmp    %cl,(%eax)
  800aa3:	74 05                	je     800aaa <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aa5:	40                   	inc    %eax
  800aa6:	39 d0                	cmp    %edx,%eax
  800aa8:	72 f7                	jb     800aa1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	57                   	push   %edi
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
  800ab2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab8:	eb 01                	jmp    800abb <strtol+0xf>
		s++;
  800aba:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abb:	8a 02                	mov    (%edx),%al
  800abd:	3c 20                	cmp    $0x20,%al
  800abf:	74 f9                	je     800aba <strtol+0xe>
  800ac1:	3c 09                	cmp    $0x9,%al
  800ac3:	74 f5                	je     800aba <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ac5:	3c 2b                	cmp    $0x2b,%al
  800ac7:	75 08                	jne    800ad1 <strtol+0x25>
		s++;
  800ac9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aca:	bf 00 00 00 00       	mov    $0x0,%edi
  800acf:	eb 13                	jmp    800ae4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ad1:	3c 2d                	cmp    $0x2d,%al
  800ad3:	75 0a                	jne    800adf <strtol+0x33>
		s++, neg = 1;
  800ad5:	8d 52 01             	lea    0x1(%edx),%edx
  800ad8:	bf 01 00 00 00       	mov    $0x1,%edi
  800add:	eb 05                	jmp    800ae4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800adf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae4:	85 db                	test   %ebx,%ebx
  800ae6:	74 05                	je     800aed <strtol+0x41>
  800ae8:	83 fb 10             	cmp    $0x10,%ebx
  800aeb:	75 28                	jne    800b15 <strtol+0x69>
  800aed:	8a 02                	mov    (%edx),%al
  800aef:	3c 30                	cmp    $0x30,%al
  800af1:	75 10                	jne    800b03 <strtol+0x57>
  800af3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800af7:	75 0a                	jne    800b03 <strtol+0x57>
		s += 2, base = 16;
  800af9:	83 c2 02             	add    $0x2,%edx
  800afc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b01:	eb 12                	jmp    800b15 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b03:	85 db                	test   %ebx,%ebx
  800b05:	75 0e                	jne    800b15 <strtol+0x69>
  800b07:	3c 30                	cmp    $0x30,%al
  800b09:	75 05                	jne    800b10 <strtol+0x64>
		s++, base = 8;
  800b0b:	42                   	inc    %edx
  800b0c:	b3 08                	mov    $0x8,%bl
  800b0e:	eb 05                	jmp    800b15 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b10:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b15:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b1c:	8a 0a                	mov    (%edx),%cl
  800b1e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b21:	80 fb 09             	cmp    $0x9,%bl
  800b24:	77 08                	ja     800b2e <strtol+0x82>
			dig = *s - '0';
  800b26:	0f be c9             	movsbl %cl,%ecx
  800b29:	83 e9 30             	sub    $0x30,%ecx
  800b2c:	eb 1e                	jmp    800b4c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b2e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b31:	80 fb 19             	cmp    $0x19,%bl
  800b34:	77 08                	ja     800b3e <strtol+0x92>
			dig = *s - 'a' + 10;
  800b36:	0f be c9             	movsbl %cl,%ecx
  800b39:	83 e9 57             	sub    $0x57,%ecx
  800b3c:	eb 0e                	jmp    800b4c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b3e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b41:	80 fb 19             	cmp    $0x19,%bl
  800b44:	77 12                	ja     800b58 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b46:	0f be c9             	movsbl %cl,%ecx
  800b49:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b4c:	39 f1                	cmp    %esi,%ecx
  800b4e:	7d 0c                	jge    800b5c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b50:	42                   	inc    %edx
  800b51:	0f af c6             	imul   %esi,%eax
  800b54:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b56:	eb c4                	jmp    800b1c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b58:	89 c1                	mov    %eax,%ecx
  800b5a:	eb 02                	jmp    800b5e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b5c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b5e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b62:	74 05                	je     800b69 <strtol+0xbd>
		*endptr = (char *) s;
  800b64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b67:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b69:	85 ff                	test   %edi,%edi
  800b6b:	74 04                	je     800b71 <strtol+0xc5>
  800b6d:	89 c8                	mov    %ecx,%eax
  800b6f:	f7 d8                	neg    %eax
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    
	...

00800b78 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
  800b89:	89 c3                	mov    %eax,%ebx
  800b8b:	89 c7                	mov    %eax,%edi
  800b8d:	89 c6                	mov    %eax,%esi
  800b8f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5f                   	pop    %edi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	57                   	push   %edi
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba6:	89 d1                	mov    %edx,%ecx
  800ba8:	89 d3                	mov    %edx,%ebx
  800baa:	89 d7                	mov    %edx,%edi
  800bac:	89 d6                	mov    %edx,%esi
  800bae:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	57                   	push   %edi
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
  800bbb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc3:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcb:	89 cb                	mov    %ecx,%ebx
  800bcd:	89 cf                	mov    %ecx,%edi
  800bcf:	89 ce                	mov    %ecx,%esi
  800bd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd3:	85 c0                	test   %eax,%eax
  800bd5:	7e 28                	jle    800bff <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bdb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800be2:	00 
  800be3:	c7 44 24 08 48 18 80 	movl   $0x801848,0x8(%esp)
  800bea:	00 
  800beb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bf2:	00 
  800bf3:	c7 04 24 65 18 80 00 	movl   $0x801865,(%esp)
  800bfa:	e8 ad f5 ff ff       	call   8001ac <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bff:	83 c4 2c             	add    $0x2c,%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c12:	b8 02 00 00 00       	mov    $0x2,%eax
  800c17:	89 d1                	mov    %edx,%ecx
  800c19:	89 d3                	mov    %edx,%ebx
  800c1b:	89 d7                	mov    %edx,%edi
  800c1d:	89 d6                	mov    %edx,%esi
  800c1f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_yield>:

void
sys_yield(void)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c31:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c36:	89 d1                	mov    %edx,%ecx
  800c38:	89 d3                	mov    %edx,%ebx
  800c3a:	89 d7                	mov    %edx,%edi
  800c3c:	89 d6                	mov    %edx,%esi
  800c3e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4e:	be 00 00 00 00       	mov    $0x0,%esi
  800c53:	b8 04 00 00 00       	mov    $0x4,%eax
  800c58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	89 f7                	mov    %esi,%edi
  800c63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 28                	jle    800c91 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c69:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c74:	00 
  800c75:	c7 44 24 08 48 18 80 	movl   $0x801848,0x8(%esp)
  800c7c:	00 
  800c7d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c84:	00 
  800c85:	c7 04 24 65 18 80 00 	movl   $0x801865,(%esp)
  800c8c:	e8 1b f5 ff ff       	call   8001ac <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c91:	83 c4 2c             	add    $0x2c,%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca2:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca7:	8b 75 18             	mov    0x18(%ebp),%esi
  800caa:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	7e 28                	jle    800ce4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cc7:	00 
  800cc8:	c7 44 24 08 48 18 80 	movl   $0x801848,0x8(%esp)
  800ccf:	00 
  800cd0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd7:	00 
  800cd8:	c7 04 24 65 18 80 00 	movl   $0x801865,(%esp)
  800cdf:	e8 c8 f4 ff ff       	call   8001ac <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ce4:	83 c4 2c             	add    $0x2c,%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
  800cf2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfa:	b8 06 00 00 00       	mov    $0x6,%eax
  800cff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d02:	8b 55 08             	mov    0x8(%ebp),%edx
  800d05:	89 df                	mov    %ebx,%edi
  800d07:	89 de                	mov    %ebx,%esi
  800d09:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	7e 28                	jle    800d37 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d13:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d1a:	00 
  800d1b:	c7 44 24 08 48 18 80 	movl   $0x801848,0x8(%esp)
  800d22:	00 
  800d23:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2a:	00 
  800d2b:	c7 04 24 65 18 80 00 	movl   $0x801865,(%esp)
  800d32:	e8 75 f4 ff ff       	call   8001ac <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d37:	83 c4 2c             	add    $0x2c,%esp
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	57                   	push   %edi
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
  800d45:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	89 df                	mov    %ebx,%edi
  800d5a:	89 de                	mov    %ebx,%esi
  800d5c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	7e 28                	jle    800d8a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d62:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d66:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d6d:	00 
  800d6e:	c7 44 24 08 48 18 80 	movl   $0x801848,0x8(%esp)
  800d75:	00 
  800d76:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d7d:	00 
  800d7e:	c7 04 24 65 18 80 00 	movl   $0x801865,(%esp)
  800d85:	e8 22 f4 ff ff       	call   8001ac <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d8a:	83 c4 2c             	add    $0x2c,%esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	57                   	push   %edi
  800d96:	56                   	push   %esi
  800d97:	53                   	push   %ebx
  800d98:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da0:	b8 09 00 00 00       	mov    $0x9,%eax
  800da5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dab:	89 df                	mov    %ebx,%edi
  800dad:	89 de                	mov    %ebx,%esi
  800daf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db1:	85 c0                	test   %eax,%eax
  800db3:	7e 28                	jle    800ddd <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dc0:	00 
  800dc1:	c7 44 24 08 48 18 80 	movl   $0x801848,0x8(%esp)
  800dc8:	00 
  800dc9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd0:	00 
  800dd1:	c7 04 24 65 18 80 00 	movl   $0x801865,(%esp)
  800dd8:	e8 cf f3 ff ff       	call   8001ac <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ddd:	83 c4 2c             	add    $0x2c,%esp
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	57                   	push   %edi
  800de9:	56                   	push   %esi
  800dea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	be 00 00 00 00       	mov    $0x0,%esi
  800df0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800df5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    

00800e08 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	57                   	push   %edi
  800e0c:	56                   	push   %esi
  800e0d:	53                   	push   %ebx
  800e0e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e16:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1e:	89 cb                	mov    %ecx,%ebx
  800e20:	89 cf                	mov    %ecx,%edi
  800e22:	89 ce                	mov    %ecx,%esi
  800e24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e26:	85 c0                	test   %eax,%eax
  800e28:	7e 28                	jle    800e52 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e35:	00 
  800e36:	c7 44 24 08 48 18 80 	movl   $0x801848,0x8(%esp)
  800e3d:	00 
  800e3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e45:	00 
  800e46:	c7 04 24 65 18 80 00 	movl   $0x801865,(%esp)
  800e4d:	e8 5a f3 ff ff       	call   8001ac <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e52:	83 c4 2c             	add    $0x2c,%esp
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    
	...

00800e5c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	53                   	push   %ebx
  800e60:	83 ec 24             	sub    $0x24,%esp
  800e63:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e66:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800e68:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e6c:	74 2d                	je     800e9b <pgfault+0x3f>
  800e6e:	89 d8                	mov    %ebx,%eax
  800e70:	c1 e8 16             	shr    $0x16,%eax
  800e73:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e7a:	a8 01                	test   $0x1,%al
  800e7c:	74 1d                	je     800e9b <pgfault+0x3f>
		(uvpt[PGNUM(addr)] & PTE_P) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800e7e:	89 d8                	mov    %ebx,%eax
  800e80:	c1 e8 0c             	shr    $0xc,%eax
  800e83:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800e8a:	f6 c2 01             	test   $0x1,%dl
  800e8d:	74 0c                	je     800e9b <pgfault+0x3f>
		(uvpt[PGNUM(addr)] & PTE_P) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800e8f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e96:	f6 c4 08             	test   $0x8,%ah
  800e99:	75 1c                	jne    800eb7 <pgfault+0x5b>
		panic("pgfault: not a write or a copy on write page fault!");
  800e9b:	c7 44 24 08 74 18 80 	movl   $0x801874,0x8(%esp)
  800ea2:	00 
  800ea3:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800eaa:	00 
  800eab:	c7 04 24 a8 18 80 00 	movl   $0x8018a8,(%esp)
  800eb2:	e8 f5 f2 ff ff       	call   8001ac <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	// we need to make addr page-aligned
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)) < 0)
  800eb7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ebe:	00 
  800ebf:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ec6:	00 
  800ec7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ece:	e8 72 fd ff ff       	call   800c45 <sys_page_alloc>
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	79 20                	jns    800ef7 <pgfault+0x9b>
		panic("pgfault: sys_page_alloc: %e", r);
  800ed7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800edb:	c7 44 24 08 b3 18 80 	movl   $0x8018b3,0x8(%esp)
  800ee2:	00 
  800ee3:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800eea:	00 
  800eeb:	c7 04 24 a8 18 80 00 	movl   $0x8018a8,(%esp)
  800ef2:	e8 b5 f2 ff ff       	call   8001ac <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// we need to make addr page-aligned
	addr = ROUNDDOWN(addr, PGSIZE);
  800ef7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)) < 0)
		panic("pgfault: sys_page_alloc: %e", r);
	memcpy(PFTEMP, addr, PGSIZE);
  800efd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f04:	00 
  800f05:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f09:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f10:	e8 21 fb ff ff       	call   800a36 <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P)) < 0)
  800f15:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f1c:	00 
  800f1d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f21:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f28:	00 
  800f29:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f30:	00 
  800f31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f38:	e8 5c fd ff ff       	call   800c99 <sys_page_map>
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	79 20                	jns    800f61 <pgfault+0x105>
		panic("pgfault: sys_page_map: %e", r);
  800f41:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f45:	c7 44 24 08 cf 18 80 	movl   $0x8018cf,0x8(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800f54:	00 
  800f55:	c7 04 24 a8 18 80 00 	movl   $0x8018a8,(%esp)
  800f5c:	e8 4b f2 ff ff       	call   8001ac <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f61:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f68:	00 
  800f69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f70:	e8 77 fd ff ff       	call   800cec <sys_page_unmap>
  800f75:	85 c0                	test   %eax,%eax
  800f77:	79 20                	jns    800f99 <pgfault+0x13d>
		panic("pgfault: sys_page_unmap: %e", r);
  800f79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f7d:	c7 44 24 08 e9 18 80 	movl   $0x8018e9,0x8(%esp)
  800f84:	00 
  800f85:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800f8c:	00 
  800f8d:	c7 04 24 a8 18 80 00 	movl   $0x8018a8,(%esp)
  800f94:	e8 13 f2 ff ff       	call   8001ac <_panic>
}
  800f99:	83 c4 24             	add    $0x24,%esp
  800f9c:	5b                   	pop    %ebx
  800f9d:	5d                   	pop    %ebp
  800f9e:	c3                   	ret    

00800f9f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	57                   	push   %edi
  800fa3:	56                   	push   %esi
  800fa4:	53                   	push   %ebx
  800fa5:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800fa8:	c7 04 24 5c 0e 80 00 	movl   $0x800e5c,(%esp)
  800faf:	e8 ec 02 00 00       	call   8012a0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fb4:	ba 07 00 00 00       	mov    $0x7,%edx
  800fb9:	89 d0                	mov    %edx,%eax
  800fbb:	cd 30                	int    $0x30
  800fbd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fc0:	89 c7                	mov    %eax,%edi
	envid_t envid;
	uint8_t *addr;
	int r;
	extern unsigned char end[];
	envid = sys_exofork();
	if (envid < 0)
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	79 20                	jns    800fe6 <fork+0x47>
		panic("sys_exofork: %e", envid);
  800fc6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fca:	c7 44 24 08 05 19 80 	movl   $0x801905,0x8(%esp)
  800fd1:	00 
  800fd2:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  800fd9:	00 
  800fda:	c7 04 24 a8 18 80 00 	movl   $0x8018a8,(%esp)
  800fe1:	e8 c6 f1 ff ff       	call   8001ac <_panic>
	if (envid == 0) {
  800fe6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fea:	75 29                	jne    801015 <fork+0x76>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800fec:	e8 16 fc ff ff       	call   800c07 <sys_getenvid>
  800ff1:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ff6:	8d 14 80             	lea    (%eax,%eax,4),%edx
  800ff9:	8d 14 90             	lea    (%eax,%edx,4),%edx
  800ffc:	8d 04 50             	lea    (%eax,%edx,2),%eax
  800fff:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  801006:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  80100b:	b8 00 00 00 00       	mov    $0x0,%eax
  801010:	e9 23 01 00 00       	jmp    801138 <fork+0x199>
	int r;
	extern unsigned char end[];
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  801015:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	}

	// We're the parent.
	for (addr = 0; addr < (uint8_t *)USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  80101a:	89 d8                	mov    %ebx,%eax
  80101c:	c1 e8 16             	shr    $0x16,%eax
  80101f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801026:	a8 01                	test   $0x1,%al
  801028:	0f 84 ac 00 00 00    	je     8010da <fork+0x13b>
  80102e:	89 d8                	mov    %ebx,%eax
  801030:	c1 e8 0c             	shr    $0xc,%eax
  801033:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80103a:	f6 c2 01             	test   $0x1,%dl
  80103d:	0f 84 97 00 00 00    	je     8010da <fork+0x13b>
			&& (uvpt[PGNUM(addr)] & PTE_U))
  801043:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80104a:	f6 c2 04             	test   $0x4,%dl
  80104d:	0f 84 87 00 00 00    	je     8010da <fork+0x13b>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	void *va = (void *)(pn * PGSIZE);
  801053:	89 c6                	mov    %eax,%esi
  801055:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  801058:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80105f:	f6 c2 02             	test   $0x2,%dl
  801062:	75 0c                	jne    801070 <fork+0xd1>
  801064:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106b:	f6 c4 08             	test   $0x8,%ah
  80106e:	74 4a                	je     8010ba <fork+0x11b>
		if ((r = sys_page_map(0, va, envid, va, PTE_COW|PTE_U|PTE_P)) < 0)
  801070:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801077:	00 
  801078:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80107c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801080:	89 74 24 04          	mov    %esi,0x4(%esp)
  801084:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80108b:	e8 09 fc ff ff       	call   800c99 <sys_page_map>
  801090:	85 c0                	test   %eax,%eax
  801092:	78 46                	js     8010da <fork+0x13b>
			return r;
		if ((r = sys_page_map(0, va, 0, va, PTE_COW|PTE_U|PTE_P)) < 0)
  801094:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80109b:	00 
  80109c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010a7:	00 
  8010a8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b3:	e8 e1 fb ff ff       	call   800c99 <sys_page_map>
  8010b8:	eb 20                	jmp    8010da <fork+0x13b>
			return r;
	}
	else {
		if ((r = sys_page_map(0, va, envid, va, PTE_U|PTE_P)) < 0)
  8010ba:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8010c1:	00 
  8010c2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010c6:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010ca:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d5:	e8 bf fb ff ff       	call   800c99 <sys_page_map>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	// We're the parent.
	for (addr = 0; addr < (uint8_t *)USTACKTOP; addr += PGSIZE)
  8010da:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010e0:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010e6:	0f 85 2e ff ff ff    	jne    80101a <fork+0x7b>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
			&& (uvpt[PGNUM(addr)] & PTE_U))
			duppage(envid, PGNUM(addr));

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  8010ec:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010f3:	00 
  8010f4:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010fb:	ee 
  8010fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010ff:	89 04 24             	mov    %eax,(%esp)
  801102:	e8 3e fb ff ff       	call   800c45 <sys_page_alloc>
  801107:	85 c0                	test   %eax,%eax
  801109:	78 2d                	js     801138 <fork+0x199>
		return r;
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80110b:	c7 44 24 04 34 13 80 	movl   $0x801334,0x4(%esp)
  801112:	00 
  801113:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801116:	89 04 24             	mov    %eax,(%esp)
  801119:	e8 74 fc ff ff       	call   800d92 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80111e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801125:	00 
  801126:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801129:	89 04 24             	mov    %eax,(%esp)
  80112c:	e8 0e fc ff ff       	call   800d3f <sys_env_set_status>
  801131:	85 c0                	test   %eax,%eax
  801133:	78 03                	js     801138 <fork+0x199>
		return r;

	return envid;
  801135:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801138:	83 c4 3c             	add    $0x3c,%esp
  80113b:	5b                   	pop    %ebx
  80113c:	5e                   	pop    %esi
  80113d:	5f                   	pop    %edi
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    

00801140 <sfork>:

// Challenge!
int
sfork(void)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801146:	c7 44 24 08 15 19 80 	movl   $0x801915,0x8(%esp)
  80114d:	00 
  80114e:	c7 44 24 04 8d 00 00 	movl   $0x8d,0x4(%esp)
  801155:	00 
  801156:	c7 04 24 a8 18 80 00 	movl   $0x8018a8,(%esp)
  80115d:	e8 4a f0 ff ff       	call   8001ac <_panic>
	...

00801164 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	56                   	push   %esi
  801168:	53                   	push   %ebx
  801169:	83 ec 10             	sub    $0x10,%esp
  80116c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80116f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801172:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	// -1 must be an invalid address.
	if (!pg) pg = (void *)-1;
  801175:	85 c0                	test   %eax,%eax
  801177:	75 05                	jne    80117e <ipc_recv+0x1a>
  801179:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	if ((r = sys_ipc_recv(pg)) < 0) {
  80117e:	89 04 24             	mov    %eax,(%esp)
  801181:	e8 82 fc ff ff       	call   800e08 <sys_ipc_recv>
  801186:	85 c0                	test   %eax,%eax
  801188:	79 16                	jns    8011a0 <ipc_recv+0x3c>
		if (from_env_store) *from_env_store = 0;
  80118a:	85 db                	test   %ebx,%ebx
  80118c:	74 06                	je     801194 <ipc_recv+0x30>
  80118e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  801194:	85 f6                	test   %esi,%esi
  801196:	74 2c                	je     8011c4 <ipc_recv+0x60>
  801198:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80119e:	eb 24                	jmp    8011c4 <ipc_recv+0x60>
		return r;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  8011a0:	85 db                	test   %ebx,%ebx
  8011a2:	74 0a                	je     8011ae <ipc_recv+0x4a>
  8011a4:	a1 08 20 80 00       	mov    0x802008,%eax
  8011a9:	8b 40 74             	mov    0x74(%eax),%eax
  8011ac:	89 03                	mov    %eax,(%ebx)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  8011ae:	85 f6                	test   %esi,%esi
  8011b0:	74 0a                	je     8011bc <ipc_recv+0x58>
  8011b2:	a1 08 20 80 00       	mov    0x802008,%eax
  8011b7:	8b 40 78             	mov    0x78(%eax),%eax
  8011ba:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  8011bc:	a1 08 20 80 00       	mov    0x802008,%eax
  8011c1:	8b 40 70             	mov    0x70(%eax),%eax
}
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	5b                   	pop    %ebx
  8011c8:	5e                   	pop    %esi
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    

008011cb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	57                   	push   %edi
  8011cf:	56                   	push   %esi
  8011d0:	53                   	push   %ebx
  8011d1:	83 ec 1c             	sub    $0x1c,%esp
  8011d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011d7:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	int retry_times = 0;
	if (!pg) pg = (void *)-1;
  8011da:	85 db                	test   %ebx,%ebx
  8011dc:	75 05                	jne    8011e3 <ipc_send+0x18>
  8011de:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8011e3:	be 03 00 00 00       	mov    $0x3,%esi
  8011e8:	eb 49                	jmp    801233 <ipc_send+0x68>
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  8011ea:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8011ed:	74 20                	je     80120f <ipc_send+0x44>
			panic("ipc_send: %e", r);
  8011ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011f3:	c7 44 24 08 2b 19 80 	movl   $0x80192b,0x8(%esp)
  8011fa:	00 
  8011fb:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  801202:	00 
  801203:	c7 04 24 38 19 80 00 	movl   $0x801938,(%esp)
  80120a:	e8 9d ef ff ff       	call   8001ac <_panic>
		retry_times++;
		if (retry_times > 2) panic("Retry times out!");
  80120f:	4e                   	dec    %esi
  801210:	75 1c                	jne    80122e <ipc_send+0x63>
  801212:	c7 44 24 08 42 19 80 	movl   $0x801942,0x8(%esp)
  801219:	00 
  80121a:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801221:	00 
  801222:	c7 04 24 38 19 80 00 	movl   $0x801938,(%esp)
  801229:	e8 7e ef ff ff       	call   8001ac <_panic>
		sys_yield();
  80122e:	e8 f3 f9 ff ff       	call   800c26 <sys_yield>
{
	// LAB 4: Your code here.
	int r;
	int retry_times = 0;
	if (!pg) pg = (void *)-1;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801233:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801237:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80123b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801242:	8b 45 08             	mov    0x8(%ebp),%eax
  801245:	89 04 24             	mov    %eax,(%esp)
  801248:	e8 98 fb ff ff       	call   800de5 <sys_ipc_try_send>
  80124d:	85 c0                	test   %eax,%eax
  80124f:	78 99                	js     8011ea <ipc_send+0x1f>
			panic("ipc_send: %e", r);
		retry_times++;
		if (retry_times > 2) panic("Retry times out!");
		sys_yield();
	}
}
  801251:	83 c4 1c             	add    $0x1c,%esp
  801254:	5b                   	pop    %ebx
  801255:	5e                   	pop    %esi
  801256:	5f                   	pop    %edi
  801257:	5d                   	pop    %ebp
  801258:	c3                   	ret    

00801259 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80125f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801264:	8d 14 80             	lea    (%eax,%eax,4),%edx
  801267:	8d 14 90             	lea    (%eax,%edx,4),%edx
  80126a:	8d 14 50             	lea    (%eax,%edx,2),%edx
  80126d:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  801274:	8b 52 50             	mov    0x50(%edx),%edx
  801277:	39 ca                	cmp    %ecx,%edx
  801279:	75 15                	jne    801290 <ipc_find_env+0x37>
			return envs[i].env_id;
  80127b:	8d 14 80             	lea    (%eax,%eax,4),%edx
  80127e:	8d 14 90             	lea    (%eax,%edx,4),%edx
  801281:	8d 04 50             	lea    (%eax,%edx,2),%eax
  801284:	8d 04 85 08 00 c0 ee 	lea    -0x113ffff8(,%eax,4),%eax
  80128b:	8b 40 40             	mov    0x40(%eax),%eax
  80128e:	eb 0c                	jmp    80129c <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801290:	40                   	inc    %eax
  801291:	3d 00 04 00 00       	cmp    $0x400,%eax
  801296:	75 cc                	jne    801264 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801298:	66 b8 00 00          	mov    $0x0,%ax
}
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    
	...

008012a0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012a6:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8012ad:	75 40                	jne    8012ef <set_pgfault_handler+0x4f>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
  8012af:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012b6:	00 
  8012b7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012be:	ee 
  8012bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012c6:	e8 7a f9 ff ff       	call   800c45 <sys_page_alloc>
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	79 20                	jns    8012ef <set_pgfault_handler+0x4f>
            panic("set_pgfault_handler: sys_page_alloc: %e", r);
  8012cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012d3:	c7 44 24 08 54 19 80 	movl   $0x801954,0x8(%esp)
  8012da:	00 
  8012db:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8012e2:	00 
  8012e3:	c7 04 24 b0 19 80 00 	movl   $0x8019b0,(%esp)
  8012ea:	e8 bd ee ff ff       	call   8001ac <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f2:	a3 0c 20 80 00       	mov    %eax,0x80200c
    if ((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0 )
  8012f7:	c7 44 24 04 34 13 80 	movl   $0x801334,0x4(%esp)
  8012fe:	00 
  8012ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801306:	e8 87 fa ff ff       	call   800d92 <sys_env_set_pgfault_upcall>
  80130b:	85 c0                	test   %eax,%eax
  80130d:	79 20                	jns    80132f <set_pgfault_handler+0x8f>
        panic("set_pgfault_handler: sys_env_set_pgfault_upcall: %e", r);
  80130f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801313:	c7 44 24 08 7c 19 80 	movl   $0x80197c,0x8(%esp)
  80131a:	00 
  80131b:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  801322:	00 
  801323:	c7 04 24 b0 19 80 00 	movl   $0x8019b0,(%esp)
  80132a:	e8 7d ee ff ff       	call   8001ac <_panic>
}
  80132f:	c9                   	leave  
  801330:	c3                   	ret    
  801331:	00 00                	add    %al,(%eax)
	...

00801334 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801334:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801335:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80133a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80133c:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// sub 4 from old esp
	movl 0x30(%esp), %eax
  80133f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801343:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801346:	89 44 24 30          	mov    %eax,0x30(%esp)
	// put old eip into the pre-reserved 4-byte space
	movl 0x28(%esp), %ebx
  80134a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80134e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  801350:	83 c4 08             	add    $0x8,%esp
	popal
  801353:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  801354:	83 c4 04             	add    $0x4,%esp
	popfl
  801357:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801358:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801359:	c3                   	ret    
	...

0080135c <__udivdi3>:
  80135c:	55                   	push   %ebp
  80135d:	57                   	push   %edi
  80135e:	56                   	push   %esi
  80135f:	83 ec 10             	sub    $0x10,%esp
  801362:	8b 74 24 20          	mov    0x20(%esp),%esi
  801366:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80136a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80136e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801372:	89 cd                	mov    %ecx,%ebp
  801374:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801378:	85 c0                	test   %eax,%eax
  80137a:	75 2c                	jne    8013a8 <__udivdi3+0x4c>
  80137c:	39 f9                	cmp    %edi,%ecx
  80137e:	77 68                	ja     8013e8 <__udivdi3+0x8c>
  801380:	85 c9                	test   %ecx,%ecx
  801382:	75 0b                	jne    80138f <__udivdi3+0x33>
  801384:	b8 01 00 00 00       	mov    $0x1,%eax
  801389:	31 d2                	xor    %edx,%edx
  80138b:	f7 f1                	div    %ecx
  80138d:	89 c1                	mov    %eax,%ecx
  80138f:	31 d2                	xor    %edx,%edx
  801391:	89 f8                	mov    %edi,%eax
  801393:	f7 f1                	div    %ecx
  801395:	89 c7                	mov    %eax,%edi
  801397:	89 f0                	mov    %esi,%eax
  801399:	f7 f1                	div    %ecx
  80139b:	89 c6                	mov    %eax,%esi
  80139d:	89 f0                	mov    %esi,%eax
  80139f:	89 fa                	mov    %edi,%edx
  8013a1:	83 c4 10             	add    $0x10,%esp
  8013a4:	5e                   	pop    %esi
  8013a5:	5f                   	pop    %edi
  8013a6:	5d                   	pop    %ebp
  8013a7:	c3                   	ret    
  8013a8:	39 f8                	cmp    %edi,%eax
  8013aa:	77 2c                	ja     8013d8 <__udivdi3+0x7c>
  8013ac:	0f bd f0             	bsr    %eax,%esi
  8013af:	83 f6 1f             	xor    $0x1f,%esi
  8013b2:	75 4c                	jne    801400 <__udivdi3+0xa4>
  8013b4:	39 f8                	cmp    %edi,%eax
  8013b6:	bf 00 00 00 00       	mov    $0x0,%edi
  8013bb:	72 0a                	jb     8013c7 <__udivdi3+0x6b>
  8013bd:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8013c1:	0f 87 ad 00 00 00    	ja     801474 <__udivdi3+0x118>
  8013c7:	be 01 00 00 00       	mov    $0x1,%esi
  8013cc:	89 f0                	mov    %esi,%eax
  8013ce:	89 fa                	mov    %edi,%edx
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	5e                   	pop    %esi
  8013d4:	5f                   	pop    %edi
  8013d5:	5d                   	pop    %ebp
  8013d6:	c3                   	ret    
  8013d7:	90                   	nop
  8013d8:	31 ff                	xor    %edi,%edi
  8013da:	31 f6                	xor    %esi,%esi
  8013dc:	89 f0                	mov    %esi,%eax
  8013de:	89 fa                	mov    %edi,%edx
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	5e                   	pop    %esi
  8013e4:	5f                   	pop    %edi
  8013e5:	5d                   	pop    %ebp
  8013e6:	c3                   	ret    
  8013e7:	90                   	nop
  8013e8:	89 fa                	mov    %edi,%edx
  8013ea:	89 f0                	mov    %esi,%eax
  8013ec:	f7 f1                	div    %ecx
  8013ee:	89 c6                	mov    %eax,%esi
  8013f0:	31 ff                	xor    %edi,%edi
  8013f2:	89 f0                	mov    %esi,%eax
  8013f4:	89 fa                	mov    %edi,%edx
  8013f6:	83 c4 10             	add    $0x10,%esp
  8013f9:	5e                   	pop    %esi
  8013fa:	5f                   	pop    %edi
  8013fb:	5d                   	pop    %ebp
  8013fc:	c3                   	ret    
  8013fd:	8d 76 00             	lea    0x0(%esi),%esi
  801400:	89 f1                	mov    %esi,%ecx
  801402:	d3 e0                	shl    %cl,%eax
  801404:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801408:	b8 20 00 00 00       	mov    $0x20,%eax
  80140d:	29 f0                	sub    %esi,%eax
  80140f:	89 ea                	mov    %ebp,%edx
  801411:	88 c1                	mov    %al,%cl
  801413:	d3 ea                	shr    %cl,%edx
  801415:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801419:	09 ca                	or     %ecx,%edx
  80141b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80141f:	89 f1                	mov    %esi,%ecx
  801421:	d3 e5                	shl    %cl,%ebp
  801423:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801427:	89 fd                	mov    %edi,%ebp
  801429:	88 c1                	mov    %al,%cl
  80142b:	d3 ed                	shr    %cl,%ebp
  80142d:	89 fa                	mov    %edi,%edx
  80142f:	89 f1                	mov    %esi,%ecx
  801431:	d3 e2                	shl    %cl,%edx
  801433:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801437:	88 c1                	mov    %al,%cl
  801439:	d3 ef                	shr    %cl,%edi
  80143b:	09 d7                	or     %edx,%edi
  80143d:	89 f8                	mov    %edi,%eax
  80143f:	89 ea                	mov    %ebp,%edx
  801441:	f7 74 24 08          	divl   0x8(%esp)
  801445:	89 d1                	mov    %edx,%ecx
  801447:	89 c7                	mov    %eax,%edi
  801449:	f7 64 24 0c          	mull   0xc(%esp)
  80144d:	39 d1                	cmp    %edx,%ecx
  80144f:	72 17                	jb     801468 <__udivdi3+0x10c>
  801451:	74 09                	je     80145c <__udivdi3+0x100>
  801453:	89 fe                	mov    %edi,%esi
  801455:	31 ff                	xor    %edi,%edi
  801457:	e9 41 ff ff ff       	jmp    80139d <__udivdi3+0x41>
  80145c:	8b 54 24 04          	mov    0x4(%esp),%edx
  801460:	89 f1                	mov    %esi,%ecx
  801462:	d3 e2                	shl    %cl,%edx
  801464:	39 c2                	cmp    %eax,%edx
  801466:	73 eb                	jae    801453 <__udivdi3+0xf7>
  801468:	8d 77 ff             	lea    -0x1(%edi),%esi
  80146b:	31 ff                	xor    %edi,%edi
  80146d:	e9 2b ff ff ff       	jmp    80139d <__udivdi3+0x41>
  801472:	66 90                	xchg   %ax,%ax
  801474:	31 f6                	xor    %esi,%esi
  801476:	e9 22 ff ff ff       	jmp    80139d <__udivdi3+0x41>
	...

0080147c <__umoddi3>:
  80147c:	55                   	push   %ebp
  80147d:	57                   	push   %edi
  80147e:	56                   	push   %esi
  80147f:	83 ec 20             	sub    $0x20,%esp
  801482:	8b 44 24 30          	mov    0x30(%esp),%eax
  801486:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80148a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80148e:	8b 74 24 34          	mov    0x34(%esp),%esi
  801492:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801496:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80149a:	89 c7                	mov    %eax,%edi
  80149c:	89 f2                	mov    %esi,%edx
  80149e:	85 ed                	test   %ebp,%ebp
  8014a0:	75 16                	jne    8014b8 <__umoddi3+0x3c>
  8014a2:	39 f1                	cmp    %esi,%ecx
  8014a4:	0f 86 a6 00 00 00    	jbe    801550 <__umoddi3+0xd4>
  8014aa:	f7 f1                	div    %ecx
  8014ac:	89 d0                	mov    %edx,%eax
  8014ae:	31 d2                	xor    %edx,%edx
  8014b0:	83 c4 20             	add    $0x20,%esp
  8014b3:	5e                   	pop    %esi
  8014b4:	5f                   	pop    %edi
  8014b5:	5d                   	pop    %ebp
  8014b6:	c3                   	ret    
  8014b7:	90                   	nop
  8014b8:	39 f5                	cmp    %esi,%ebp
  8014ba:	0f 87 ac 00 00 00    	ja     80156c <__umoddi3+0xf0>
  8014c0:	0f bd c5             	bsr    %ebp,%eax
  8014c3:	83 f0 1f             	xor    $0x1f,%eax
  8014c6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014ca:	0f 84 a8 00 00 00    	je     801578 <__umoddi3+0xfc>
  8014d0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014d4:	d3 e5                	shl    %cl,%ebp
  8014d6:	bf 20 00 00 00       	mov    $0x20,%edi
  8014db:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8014df:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014e3:	89 f9                	mov    %edi,%ecx
  8014e5:	d3 e8                	shr    %cl,%eax
  8014e7:	09 e8                	or     %ebp,%eax
  8014e9:	89 44 24 18          	mov    %eax,0x18(%esp)
  8014ed:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014f1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014f5:	d3 e0                	shl    %cl,%eax
  8014f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014fb:	89 f2                	mov    %esi,%edx
  8014fd:	d3 e2                	shl    %cl,%edx
  8014ff:	8b 44 24 14          	mov    0x14(%esp),%eax
  801503:	d3 e0                	shl    %cl,%eax
  801505:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801509:	8b 44 24 14          	mov    0x14(%esp),%eax
  80150d:	89 f9                	mov    %edi,%ecx
  80150f:	d3 e8                	shr    %cl,%eax
  801511:	09 d0                	or     %edx,%eax
  801513:	d3 ee                	shr    %cl,%esi
  801515:	89 f2                	mov    %esi,%edx
  801517:	f7 74 24 18          	divl   0x18(%esp)
  80151b:	89 d6                	mov    %edx,%esi
  80151d:	f7 64 24 0c          	mull   0xc(%esp)
  801521:	89 c5                	mov    %eax,%ebp
  801523:	89 d1                	mov    %edx,%ecx
  801525:	39 d6                	cmp    %edx,%esi
  801527:	72 67                	jb     801590 <__umoddi3+0x114>
  801529:	74 75                	je     8015a0 <__umoddi3+0x124>
  80152b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80152f:	29 e8                	sub    %ebp,%eax
  801531:	19 ce                	sbb    %ecx,%esi
  801533:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801537:	d3 e8                	shr    %cl,%eax
  801539:	89 f2                	mov    %esi,%edx
  80153b:	89 f9                	mov    %edi,%ecx
  80153d:	d3 e2                	shl    %cl,%edx
  80153f:	09 d0                	or     %edx,%eax
  801541:	89 f2                	mov    %esi,%edx
  801543:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801547:	d3 ea                	shr    %cl,%edx
  801549:	83 c4 20             	add    $0x20,%esp
  80154c:	5e                   	pop    %esi
  80154d:	5f                   	pop    %edi
  80154e:	5d                   	pop    %ebp
  80154f:	c3                   	ret    
  801550:	85 c9                	test   %ecx,%ecx
  801552:	75 0b                	jne    80155f <__umoddi3+0xe3>
  801554:	b8 01 00 00 00       	mov    $0x1,%eax
  801559:	31 d2                	xor    %edx,%edx
  80155b:	f7 f1                	div    %ecx
  80155d:	89 c1                	mov    %eax,%ecx
  80155f:	89 f0                	mov    %esi,%eax
  801561:	31 d2                	xor    %edx,%edx
  801563:	f7 f1                	div    %ecx
  801565:	89 f8                	mov    %edi,%eax
  801567:	e9 3e ff ff ff       	jmp    8014aa <__umoddi3+0x2e>
  80156c:	89 f2                	mov    %esi,%edx
  80156e:	83 c4 20             	add    $0x20,%esp
  801571:	5e                   	pop    %esi
  801572:	5f                   	pop    %edi
  801573:	5d                   	pop    %ebp
  801574:	c3                   	ret    
  801575:	8d 76 00             	lea    0x0(%esi),%esi
  801578:	39 f5                	cmp    %esi,%ebp
  80157a:	72 04                	jb     801580 <__umoddi3+0x104>
  80157c:	39 f9                	cmp    %edi,%ecx
  80157e:	77 06                	ja     801586 <__umoddi3+0x10a>
  801580:	89 f2                	mov    %esi,%edx
  801582:	29 cf                	sub    %ecx,%edi
  801584:	19 ea                	sbb    %ebp,%edx
  801586:	89 f8                	mov    %edi,%eax
  801588:	83 c4 20             	add    $0x20,%esp
  80158b:	5e                   	pop    %esi
  80158c:	5f                   	pop    %edi
  80158d:	5d                   	pop    %ebp
  80158e:	c3                   	ret    
  80158f:	90                   	nop
  801590:	89 d1                	mov    %edx,%ecx
  801592:	89 c5                	mov    %eax,%ebp
  801594:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801598:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80159c:	eb 8d                	jmp    80152b <__umoddi3+0xaf>
  80159e:	66 90                	xchg   %ax,%ax
  8015a0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8015a4:	72 ea                	jb     801590 <__umoddi3+0x114>
  8015a6:	89 f1                	mov    %esi,%ecx
  8015a8:	eb 81                	jmp    80152b <__umoddi3+0xaf>
