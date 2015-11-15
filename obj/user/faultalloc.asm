
obj/user/faultalloc:     file format elf32-i386


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

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800040:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800044:	c7 04 24 80 11 80 00 	movl   $0x801180,(%esp)
  80004b:	e8 04 02 00 00       	call   800254 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 86 0b 00 00       	call   800bf5 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 a0 11 80 	movl   $0x8011a0,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 8a 11 80 00 	movl   $0x80118a,(%esp)
  800092:	e8 c5 00 00 00       	call   80015c <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 cc 11 80 	movl   $0x8011cc,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 f5 06 00 00       	call   8007a8 <snprintf>
}
  8000b3:	83 c4 24             	add    $0x24,%esp
  8000b6:	5b                   	pop    %ebx
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <umain>:

void
umain(int argc, char **argv)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000bf:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  8000c6:	e8 95 0d 00 00       	call   800e60 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000cb:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000d2:	de 
  8000d3:	c7 04 24 9c 11 80 00 	movl   $0x80119c,(%esp)
  8000da:	e8 75 01 00 00       	call   800254 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000df:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000e6:	ca 
  8000e7:	c7 04 24 9c 11 80 00 	movl   $0x80119c,(%esp)
  8000ee:	e8 61 01 00 00       	call   800254 <cprintf>
}
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
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
  800106:	e8 ac 0a 00 00       	call   800bb7 <sys_getenvid>
  80010b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800110:	8d 14 80             	lea    (%eax,%eax,4),%edx
  800113:	8d 04 50             	lea    (%eax,%edx,2),%eax
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
  800135:	e8 7f ff ff ff       	call   8000b9 <umain>

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
  800155:	e8 0b 0a 00 00       	call   800b65 <sys_env_destroy>
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800164:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800167:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80016d:	e8 45 0a 00 00       	call   800bb7 <sys_getenvid>
  800172:	8b 55 0c             	mov    0xc(%ebp),%edx
  800175:	89 54 24 10          	mov    %edx,0x10(%esp)
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800180:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800184:	89 44 24 04          	mov    %eax,0x4(%esp)
  800188:	c7 04 24 f8 11 80 00 	movl   $0x8011f8,(%esp)
  80018f:	e8 c0 00 00 00       	call   800254 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800194:	89 74 24 04          	mov    %esi,0x4(%esp)
  800198:	8b 45 10             	mov    0x10(%ebp),%eax
  80019b:	89 04 24             	mov    %eax,(%esp)
  80019e:	e8 50 00 00 00       	call   8001f3 <vcprintf>
	cprintf("\n");
  8001a3:	c7 04 24 9e 11 80 00 	movl   $0x80119e,(%esp)
  8001aa:	e8 a5 00 00 00       	call   800254 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001af:	cc                   	int3   
  8001b0:	eb fd                	jmp    8001af <_panic+0x53>
	...

008001b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	53                   	push   %ebx
  8001b8:	83 ec 14             	sub    $0x14,%esp
  8001bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001be:	8b 03                	mov    (%ebx),%eax
  8001c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001c7:	40                   	inc    %eax
  8001c8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ca:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001cf:	75 19                	jne    8001ea <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001d1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d8:	00 
  8001d9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001dc:	89 04 24             	mov    %eax,(%esp)
  8001df:	e8 44 09 00 00       	call   800b28 <sys_cputs>
		b->idx = 0;
  8001e4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ea:	ff 43 04             	incl   0x4(%ebx)
}
  8001ed:	83 c4 14             	add    $0x14,%esp
  8001f0:	5b                   	pop    %ebx
  8001f1:	5d                   	pop    %ebp
  8001f2:	c3                   	ret    

008001f3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f3:	55                   	push   %ebp
  8001f4:	89 e5                	mov    %esp,%ebp
  8001f6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001fc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800203:	00 00 00 
	b.cnt = 0;
  800206:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80020d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800210:	8b 45 0c             	mov    0xc(%ebp),%eax
  800213:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800217:	8b 45 08             	mov    0x8(%ebp),%eax
  80021a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800224:	89 44 24 04          	mov    %eax,0x4(%esp)
  800228:	c7 04 24 b4 01 80 00 	movl   $0x8001b4,(%esp)
  80022f:	e8 b4 01 00 00       	call   8003e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800234:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80023a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800244:	89 04 24             	mov    %eax,(%esp)
  800247:	e8 dc 08 00 00       	call   800b28 <sys_cputs>

	return b.cnt;
}
  80024c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800252:	c9                   	leave  
  800253:	c3                   	ret    

00800254 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80025d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800261:	8b 45 08             	mov    0x8(%ebp),%eax
  800264:	89 04 24             	mov    %eax,(%esp)
  800267:	e8 87 ff ff ff       	call   8001f3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80026c:	c9                   	leave  
  80026d:	c3                   	ret    
	...

00800270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 3c             	sub    $0x3c,%esp
  800279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027c:	89 d7                	mov    %edx,%edi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800284:	8b 45 0c             	mov    0xc(%ebp),%eax
  800287:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80028a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80028d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800290:	85 c0                	test   %eax,%eax
  800292:	75 08                	jne    80029c <printnum+0x2c>
  800294:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800297:	39 45 10             	cmp    %eax,0x10(%ebp)
  80029a:	77 57                	ja     8002f3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80029c:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002a0:	4b                   	dec    %ebx
  8002a1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ac:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002b0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002b4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002bb:	00 
  8002bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002bf:	89 04 24             	mov    %eax,(%esp)
  8002c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c9:	e8 4e 0c 00 00       	call   800f1c <__udivdi3>
  8002ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002d2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d6:	89 04 24             	mov    %eax,(%esp)
  8002d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002dd:	89 fa                	mov    %edi,%edx
  8002df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002e2:	e8 89 ff ff ff       	call   800270 <printnum>
  8002e7:	eb 0f                	jmp    8002f8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ed:	89 34 24             	mov    %esi,(%esp)
  8002f0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f3:	4b                   	dec    %ebx
  8002f4:	85 db                	test   %ebx,%ebx
  8002f6:	7f f1                	jg     8002e9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002fc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800300:	8b 45 10             	mov    0x10(%ebp),%eax
  800303:	89 44 24 08          	mov    %eax,0x8(%esp)
  800307:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80030e:	00 
  80030f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800312:	89 04 24             	mov    %eax,(%esp)
  800315:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800318:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031c:	e8 1b 0d 00 00       	call   80103c <__umoddi3>
  800321:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800325:	0f be 80 1b 12 80 00 	movsbl 0x80121b(%eax),%eax
  80032c:	89 04 24             	mov    %eax,(%esp)
  80032f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800332:	83 c4 3c             	add    $0x3c,%esp
  800335:	5b                   	pop    %ebx
  800336:	5e                   	pop    %esi
  800337:	5f                   	pop    %edi
  800338:	5d                   	pop    %ebp
  800339:	c3                   	ret    

0080033a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80033d:	83 fa 01             	cmp    $0x1,%edx
  800340:	7e 0e                	jle    800350 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800342:	8b 10                	mov    (%eax),%edx
  800344:	8d 4a 08             	lea    0x8(%edx),%ecx
  800347:	89 08                	mov    %ecx,(%eax)
  800349:	8b 02                	mov    (%edx),%eax
  80034b:	8b 52 04             	mov    0x4(%edx),%edx
  80034e:	eb 22                	jmp    800372 <getuint+0x38>
	else if (lflag)
  800350:	85 d2                	test   %edx,%edx
  800352:	74 10                	je     800364 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800354:	8b 10                	mov    (%eax),%edx
  800356:	8d 4a 04             	lea    0x4(%edx),%ecx
  800359:	89 08                	mov    %ecx,(%eax)
  80035b:	8b 02                	mov    (%edx),%eax
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
  800362:	eb 0e                	jmp    800372 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800364:	8b 10                	mov    (%eax),%edx
  800366:	8d 4a 04             	lea    0x4(%edx),%ecx
  800369:	89 08                	mov    %ecx,(%eax)
  80036b:	8b 02                	mov    (%edx),%eax
  80036d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800377:	83 fa 01             	cmp    $0x1,%edx
  80037a:	7e 0e                	jle    80038a <getint+0x16>
		return va_arg(*ap, long long);
  80037c:	8b 10                	mov    (%eax),%edx
  80037e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800381:	89 08                	mov    %ecx,(%eax)
  800383:	8b 02                	mov    (%edx),%eax
  800385:	8b 52 04             	mov    0x4(%edx),%edx
  800388:	eb 1a                	jmp    8003a4 <getint+0x30>
	else if (lflag)
  80038a:	85 d2                	test   %edx,%edx
  80038c:	74 0c                	je     80039a <getint+0x26>
		return va_arg(*ap, long);
  80038e:	8b 10                	mov    (%eax),%edx
  800390:	8d 4a 04             	lea    0x4(%edx),%ecx
  800393:	89 08                	mov    %ecx,(%eax)
  800395:	8b 02                	mov    (%edx),%eax
  800397:	99                   	cltd   
  800398:	eb 0a                	jmp    8003a4 <getint+0x30>
	else
		return va_arg(*ap, int);
  80039a:	8b 10                	mov    (%eax),%edx
  80039c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039f:	89 08                	mov    %ecx,(%eax)
  8003a1:	8b 02                	mov    (%edx),%eax
  8003a3:	99                   	cltd   
}
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ac:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003af:	8b 10                	mov    (%eax),%edx
  8003b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8003b4:	73 08                	jae    8003be <sprintputch+0x18>
		*b->buf++ = ch;
  8003b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b9:	88 0a                	mov    %cl,(%edx)
  8003bb:	42                   	inc    %edx
  8003bc:	89 10                	mov    %edx,(%eax)
}
  8003be:	5d                   	pop    %ebp
  8003bf:	c3                   	ret    

008003c0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003c6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003db:	8b 45 08             	mov    0x8(%ebp),%eax
  8003de:	89 04 24             	mov    %eax,(%esp)
  8003e1:	e8 02 00 00 00       	call   8003e8 <vprintfmt>
	va_end(ap);
}
  8003e6:	c9                   	leave  
  8003e7:	c3                   	ret    

008003e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	57                   	push   %edi
  8003ec:	56                   	push   %esi
  8003ed:	53                   	push   %ebx
  8003ee:	83 ec 4c             	sub    $0x4c,%esp
  8003f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f4:	8b 75 10             	mov    0x10(%ebp),%esi
  8003f7:	eb 12                	jmp    80040b <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003f9:	85 c0                	test   %eax,%eax
  8003fb:	0f 84 40 03 00 00    	je     800741 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800401:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800405:	89 04 24             	mov    %eax,(%esp)
  800408:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040b:	0f b6 06             	movzbl (%esi),%eax
  80040e:	46                   	inc    %esi
  80040f:	83 f8 25             	cmp    $0x25,%eax
  800412:	75 e5                	jne    8003f9 <vprintfmt+0x11>
  800414:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800418:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80041f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800424:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80042b:	ba 00 00 00 00       	mov    $0x0,%edx
  800430:	eb 26                	jmp    800458 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800435:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800439:	eb 1d                	jmp    800458 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80043e:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800442:	eb 14                	jmp    800458 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800447:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80044e:	eb 08                	jmp    800458 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800450:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800453:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	0f b6 06             	movzbl (%esi),%eax
  80045b:	8d 4e 01             	lea    0x1(%esi),%ecx
  80045e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800461:	8a 0e                	mov    (%esi),%cl
  800463:	83 e9 23             	sub    $0x23,%ecx
  800466:	80 f9 55             	cmp    $0x55,%cl
  800469:	0f 87 b6 02 00 00    	ja     800725 <vprintfmt+0x33d>
  80046f:	0f b6 c9             	movzbl %cl,%ecx
  800472:	ff 24 8d e0 12 80 00 	jmp    *0x8012e0(,%ecx,4)
  800479:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80047c:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800481:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800484:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  800488:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80048b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80048e:	83 f9 09             	cmp    $0x9,%ecx
  800491:	77 2a                	ja     8004bd <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800493:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800494:	eb eb                	jmp    800481 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800496:	8b 45 14             	mov    0x14(%ebp),%eax
  800499:	8d 48 04             	lea    0x4(%eax),%ecx
  80049c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80049f:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004a4:	eb 17                	jmp    8004bd <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004a6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004aa:	78 98                	js     800444 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004af:	eb a7                	jmp    800458 <vprintfmt+0x70>
  8004b1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b4:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004bb:	eb 9b                	jmp    800458 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004bd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c1:	79 95                	jns    800458 <vprintfmt+0x70>
  8004c3:	eb 8b                	jmp    800450 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c5:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c9:	eb 8d                	jmp    800458 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ce:	8d 50 04             	lea    0x4(%eax),%edx
  8004d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d8:	8b 00                	mov    (%eax),%eax
  8004da:	89 04 24             	mov    %eax,(%esp)
  8004dd:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004e3:	e9 23 ff ff ff       	jmp    80040b <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004eb:	8d 50 04             	lea    0x4(%eax),%edx
  8004ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f1:	8b 00                	mov    (%eax),%eax
  8004f3:	85 c0                	test   %eax,%eax
  8004f5:	79 02                	jns    8004f9 <vprintfmt+0x111>
  8004f7:	f7 d8                	neg    %eax
  8004f9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004fb:	83 f8 09             	cmp    $0x9,%eax
  8004fe:	7f 0b                	jg     80050b <vprintfmt+0x123>
  800500:	8b 04 85 40 14 80 00 	mov    0x801440(,%eax,4),%eax
  800507:	85 c0                	test   %eax,%eax
  800509:	75 23                	jne    80052e <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80050b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80050f:	c7 44 24 08 33 12 80 	movl   $0x801233,0x8(%esp)
  800516:	00 
  800517:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051b:	8b 45 08             	mov    0x8(%ebp),%eax
  80051e:	89 04 24             	mov    %eax,(%esp)
  800521:	e8 9a fe ff ff       	call   8003c0 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800529:	e9 dd fe ff ff       	jmp    80040b <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80052e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800532:	c7 44 24 08 3c 12 80 	movl   $0x80123c,0x8(%esp)
  800539:	00 
  80053a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80053e:	8b 55 08             	mov    0x8(%ebp),%edx
  800541:	89 14 24             	mov    %edx,(%esp)
  800544:	e8 77 fe ff ff       	call   8003c0 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800549:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80054c:	e9 ba fe ff ff       	jmp    80040b <vprintfmt+0x23>
  800551:	89 f9                	mov    %edi,%ecx
  800553:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800556:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8d 50 04             	lea    0x4(%eax),%edx
  80055f:	89 55 14             	mov    %edx,0x14(%ebp)
  800562:	8b 30                	mov    (%eax),%esi
  800564:	85 f6                	test   %esi,%esi
  800566:	75 05                	jne    80056d <vprintfmt+0x185>
				p = "(null)";
  800568:	be 2c 12 80 00       	mov    $0x80122c,%esi
			if (width > 0 && padc != '-')
  80056d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800571:	0f 8e 84 00 00 00    	jle    8005fb <vprintfmt+0x213>
  800577:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80057b:	74 7e                	je     8005fb <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80057d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800581:	89 34 24             	mov    %esi,(%esp)
  800584:	e8 5d 02 00 00       	call   8007e6 <strnlen>
  800589:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80058c:	29 c2                	sub    %eax,%edx
  80058e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800591:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800595:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800598:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80059b:	89 de                	mov    %ebx,%esi
  80059d:	89 d3                	mov    %edx,%ebx
  80059f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a1:	eb 0b                	jmp    8005ae <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005a7:	89 3c 24             	mov    %edi,(%esp)
  8005aa:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ad:	4b                   	dec    %ebx
  8005ae:	85 db                	test   %ebx,%ebx
  8005b0:	7f f1                	jg     8005a3 <vprintfmt+0x1bb>
  8005b2:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005b5:	89 f3                	mov    %esi,%ebx
  8005b7:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005bd:	85 c0                	test   %eax,%eax
  8005bf:	79 05                	jns    8005c6 <vprintfmt+0x1de>
  8005c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005c9:	29 c2                	sub    %eax,%edx
  8005cb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005ce:	eb 2b                	jmp    8005fb <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005d0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005d4:	74 18                	je     8005ee <vprintfmt+0x206>
  8005d6:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005d9:	83 fa 5e             	cmp    $0x5e,%edx
  8005dc:	76 10                	jbe    8005ee <vprintfmt+0x206>
					putch('?', putdat);
  8005de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e2:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005e9:	ff 55 08             	call   *0x8(%ebp)
  8005ec:	eb 0a                	jmp    8005f8 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f2:	89 04 24             	mov    %eax,(%esp)
  8005f5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f8:	ff 4d e4             	decl   -0x1c(%ebp)
  8005fb:	0f be 06             	movsbl (%esi),%eax
  8005fe:	46                   	inc    %esi
  8005ff:	85 c0                	test   %eax,%eax
  800601:	74 21                	je     800624 <vprintfmt+0x23c>
  800603:	85 ff                	test   %edi,%edi
  800605:	78 c9                	js     8005d0 <vprintfmt+0x1e8>
  800607:	4f                   	dec    %edi
  800608:	79 c6                	jns    8005d0 <vprintfmt+0x1e8>
  80060a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80060d:	89 de                	mov    %ebx,%esi
  80060f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800612:	eb 18                	jmp    80062c <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800614:	89 74 24 04          	mov    %esi,0x4(%esp)
  800618:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80061f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800621:	4b                   	dec    %ebx
  800622:	eb 08                	jmp    80062c <vprintfmt+0x244>
  800624:	8b 7d 08             	mov    0x8(%ebp),%edi
  800627:	89 de                	mov    %ebx,%esi
  800629:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80062c:	85 db                	test   %ebx,%ebx
  80062e:	7f e4                	jg     800614 <vprintfmt+0x22c>
  800630:	89 7d 08             	mov    %edi,0x8(%ebp)
  800633:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800635:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800638:	e9 ce fd ff ff       	jmp    80040b <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80063d:	8d 45 14             	lea    0x14(%ebp),%eax
  800640:	e8 2f fd ff ff       	call   800374 <getint>
  800645:	89 c6                	mov    %eax,%esi
  800647:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800649:	85 d2                	test   %edx,%edx
  80064b:	78 07                	js     800654 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80064d:	be 0a 00 00 00       	mov    $0xa,%esi
  800652:	eb 7e                	jmp    8006d2 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800654:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800658:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80065f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800662:	89 f0                	mov    %esi,%eax
  800664:	89 fa                	mov    %edi,%edx
  800666:	f7 d8                	neg    %eax
  800668:	83 d2 00             	adc    $0x0,%edx
  80066b:	f7 da                	neg    %edx
			}
			base = 10;
  80066d:	be 0a 00 00 00       	mov    $0xa,%esi
  800672:	eb 5e                	jmp    8006d2 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800674:	8d 45 14             	lea    0x14(%ebp),%eax
  800677:	e8 be fc ff ff       	call   80033a <getuint>
			base = 10;
  80067c:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800681:	eb 4f                	jmp    8006d2 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
  800686:	e8 af fc ff ff       	call   80033a <getuint>
			base = 8;
  80068b:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800690:	eb 40                	jmp    8006d2 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  800692:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800696:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80069d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006ab:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8d 50 04             	lea    0x4(%eax),%edx
  8006b4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006b7:	8b 00                	mov    (%eax),%eax
  8006b9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006be:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8006c3:	eb 0d                	jmp    8006d2 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c8:	e8 6d fc ff ff       	call   80033a <getuint>
			base = 16;
  8006cd:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d2:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  8006d6:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8006da:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006dd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8006e1:	89 74 24 08          	mov    %esi,0x8(%esp)
  8006e5:	89 04 24             	mov    %eax,(%esp)
  8006e8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006ec:	89 da                	mov    %ebx,%edx
  8006ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f1:	e8 7a fb ff ff       	call   800270 <printnum>
			break;
  8006f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006f9:	e9 0d fd ff ff       	jmp    80040b <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  8006fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800701:	e8 6e fc ff ff       	call   800374 <getint>
  800706:	a3 04 20 80 00       	mov    %eax,0x802004
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  80070e:	e9 f8 fc ff ff       	jmp    80040b <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800713:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800717:	89 04 24             	mov    %eax,(%esp)
  80071a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800720:	e9 e6 fc ff ff       	jmp    80040b <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800725:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800729:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800730:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800733:	eb 01                	jmp    800736 <vprintfmt+0x34e>
  800735:	4e                   	dec    %esi
  800736:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80073a:	75 f9                	jne    800735 <vprintfmt+0x34d>
  80073c:	e9 ca fc ff ff       	jmp    80040b <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800741:	83 c4 4c             	add    $0x4c,%esp
  800744:	5b                   	pop    %ebx
  800745:	5e                   	pop    %esi
  800746:	5f                   	pop    %edi
  800747:	5d                   	pop    %ebp
  800748:	c3                   	ret    

00800749 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	83 ec 28             	sub    $0x28,%esp
  80074f:	8b 45 08             	mov    0x8(%ebp),%eax
  800752:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800755:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800758:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80075c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800766:	85 c0                	test   %eax,%eax
  800768:	74 30                	je     80079a <vsnprintf+0x51>
  80076a:	85 d2                	test   %edx,%edx
  80076c:	7e 33                	jle    8007a1 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076e:	8b 45 14             	mov    0x14(%ebp),%eax
  800771:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800775:	8b 45 10             	mov    0x10(%ebp),%eax
  800778:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800783:	c7 04 24 a6 03 80 00 	movl   $0x8003a6,(%esp)
  80078a:	e8 59 fc ff ff       	call   8003e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800792:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800795:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800798:	eb 0c                	jmp    8007a6 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80079a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079f:	eb 05                	jmp    8007a6 <vsnprintf+0x5d>
  8007a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ae:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c6:	89 04 24             	mov    %eax,(%esp)
  8007c9:	e8 7b ff ff ff       	call   800749 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ce:	c9                   	leave  
  8007cf:	c3                   	ret    

008007d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007db:	eb 01                	jmp    8007de <strlen+0xe>
		n++;
  8007dd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007de:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e2:	75 f9                	jne    8007dd <strlen+0xd>
		n++;
	return n;
}
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007ec:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f4:	eb 01                	jmp    8007f7 <strnlen+0x11>
		n++;
  8007f6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f7:	39 d0                	cmp    %edx,%eax
  8007f9:	74 06                	je     800801 <strnlen+0x1b>
  8007fb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ff:	75 f5                	jne    8007f6 <strnlen+0x10>
		n++;
	return n;
}
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	53                   	push   %ebx
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80080d:	ba 00 00 00 00       	mov    $0x0,%edx
  800812:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800815:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800818:	42                   	inc    %edx
  800819:	84 c9                	test   %cl,%cl
  80081b:	75 f5                	jne    800812 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80081d:	5b                   	pop    %ebx
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	53                   	push   %ebx
  800824:	83 ec 08             	sub    $0x8,%esp
  800827:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082a:	89 1c 24             	mov    %ebx,(%esp)
  80082d:	e8 9e ff ff ff       	call   8007d0 <strlen>
	strcpy(dst + len, src);
  800832:	8b 55 0c             	mov    0xc(%ebp),%edx
  800835:	89 54 24 04          	mov    %edx,0x4(%esp)
  800839:	01 d8                	add    %ebx,%eax
  80083b:	89 04 24             	mov    %eax,(%esp)
  80083e:	e8 c0 ff ff ff       	call   800803 <strcpy>
	return dst;
}
  800843:	89 d8                	mov    %ebx,%eax
  800845:	83 c4 08             	add    $0x8,%esp
  800848:	5b                   	pop    %ebx
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	56                   	push   %esi
  80084f:	53                   	push   %ebx
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	8b 55 0c             	mov    0xc(%ebp),%edx
  800856:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800859:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085e:	eb 0c                	jmp    80086c <strncpy+0x21>
		*dst++ = *src;
  800860:	8a 1a                	mov    (%edx),%bl
  800862:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800865:	80 3a 01             	cmpb   $0x1,(%edx)
  800868:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086b:	41                   	inc    %ecx
  80086c:	39 f1                	cmp    %esi,%ecx
  80086e:	75 f0                	jne    800860 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800870:	5b                   	pop    %ebx
  800871:	5e                   	pop    %esi
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	56                   	push   %esi
  800878:	53                   	push   %ebx
  800879:	8b 75 08             	mov    0x8(%ebp),%esi
  80087c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800882:	85 d2                	test   %edx,%edx
  800884:	75 0a                	jne    800890 <strlcpy+0x1c>
  800886:	89 f0                	mov    %esi,%eax
  800888:	eb 1a                	jmp    8008a4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088a:	88 18                	mov    %bl,(%eax)
  80088c:	40                   	inc    %eax
  80088d:	41                   	inc    %ecx
  80088e:	eb 02                	jmp    800892 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800890:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800892:	4a                   	dec    %edx
  800893:	74 0a                	je     80089f <strlcpy+0x2b>
  800895:	8a 19                	mov    (%ecx),%bl
  800897:	84 db                	test   %bl,%bl
  800899:	75 ef                	jne    80088a <strlcpy+0x16>
  80089b:	89 c2                	mov    %eax,%edx
  80089d:	eb 02                	jmp    8008a1 <strlcpy+0x2d>
  80089f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008a1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008a4:	29 f0                	sub    %esi,%eax
}
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b3:	eb 02                	jmp    8008b7 <strcmp+0xd>
		p++, q++;
  8008b5:	41                   	inc    %ecx
  8008b6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b7:	8a 01                	mov    (%ecx),%al
  8008b9:	84 c0                	test   %al,%al
  8008bb:	74 04                	je     8008c1 <strcmp+0x17>
  8008bd:	3a 02                	cmp    (%edx),%al
  8008bf:	74 f4                	je     8008b5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c1:	0f b6 c0             	movzbl %al,%eax
  8008c4:	0f b6 12             	movzbl (%edx),%edx
  8008c7:	29 d0                	sub    %edx,%eax
}
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008d8:	eb 03                	jmp    8008dd <strncmp+0x12>
		n--, p++, q++;
  8008da:	4a                   	dec    %edx
  8008db:	40                   	inc    %eax
  8008dc:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008dd:	85 d2                	test   %edx,%edx
  8008df:	74 14                	je     8008f5 <strncmp+0x2a>
  8008e1:	8a 18                	mov    (%eax),%bl
  8008e3:	84 db                	test   %bl,%bl
  8008e5:	74 04                	je     8008eb <strncmp+0x20>
  8008e7:	3a 19                	cmp    (%ecx),%bl
  8008e9:	74 ef                	je     8008da <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008eb:	0f b6 00             	movzbl (%eax),%eax
  8008ee:	0f b6 11             	movzbl (%ecx),%edx
  8008f1:	29 d0                	sub    %edx,%eax
  8008f3:	eb 05                	jmp    8008fa <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008fa:	5b                   	pop    %ebx
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800906:	eb 05                	jmp    80090d <strchr+0x10>
		if (*s == c)
  800908:	38 ca                	cmp    %cl,%dl
  80090a:	74 0c                	je     800918 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090c:	40                   	inc    %eax
  80090d:	8a 10                	mov    (%eax),%dl
  80090f:	84 d2                	test   %dl,%dl
  800911:	75 f5                	jne    800908 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800923:	eb 05                	jmp    80092a <strfind+0x10>
		if (*s == c)
  800925:	38 ca                	cmp    %cl,%dl
  800927:	74 07                	je     800930 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800929:	40                   	inc    %eax
  80092a:	8a 10                	mov    (%eax),%dl
  80092c:	84 d2                	test   %dl,%dl
  80092e:	75 f5                	jne    800925 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	57                   	push   %edi
  800936:	56                   	push   %esi
  800937:	53                   	push   %ebx
  800938:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800941:	85 c9                	test   %ecx,%ecx
  800943:	74 30                	je     800975 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800945:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094b:	75 25                	jne    800972 <memset+0x40>
  80094d:	f6 c1 03             	test   $0x3,%cl
  800950:	75 20                	jne    800972 <memset+0x40>
		c &= 0xFF;
  800952:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800955:	89 d3                	mov    %edx,%ebx
  800957:	c1 e3 08             	shl    $0x8,%ebx
  80095a:	89 d6                	mov    %edx,%esi
  80095c:	c1 e6 18             	shl    $0x18,%esi
  80095f:	89 d0                	mov    %edx,%eax
  800961:	c1 e0 10             	shl    $0x10,%eax
  800964:	09 f0                	or     %esi,%eax
  800966:	09 d0                	or     %edx,%eax
  800968:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80096a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80096d:	fc                   	cld    
  80096e:	f3 ab                	rep stos %eax,%es:(%edi)
  800970:	eb 03                	jmp    800975 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800972:	fc                   	cld    
  800973:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800975:	89 f8                	mov    %edi,%eax
  800977:	5b                   	pop    %ebx
  800978:	5e                   	pop    %esi
  800979:	5f                   	pop    %edi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	57                   	push   %edi
  800980:	56                   	push   %esi
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 75 0c             	mov    0xc(%ebp),%esi
  800987:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098a:	39 c6                	cmp    %eax,%esi
  80098c:	73 34                	jae    8009c2 <memmove+0x46>
  80098e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800991:	39 d0                	cmp    %edx,%eax
  800993:	73 2d                	jae    8009c2 <memmove+0x46>
		s += n;
		d += n;
  800995:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800998:	f6 c2 03             	test   $0x3,%dl
  80099b:	75 1b                	jne    8009b8 <memmove+0x3c>
  80099d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a3:	75 13                	jne    8009b8 <memmove+0x3c>
  8009a5:	f6 c1 03             	test   $0x3,%cl
  8009a8:	75 0e                	jne    8009b8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009aa:	83 ef 04             	sub    $0x4,%edi
  8009ad:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009b3:	fd                   	std    
  8009b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b6:	eb 07                	jmp    8009bf <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b8:	4f                   	dec    %edi
  8009b9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009bc:	fd                   	std    
  8009bd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009bf:	fc                   	cld    
  8009c0:	eb 20                	jmp    8009e2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c8:	75 13                	jne    8009dd <memmove+0x61>
  8009ca:	a8 03                	test   $0x3,%al
  8009cc:	75 0f                	jne    8009dd <memmove+0x61>
  8009ce:	f6 c1 03             	test   $0x3,%cl
  8009d1:	75 0a                	jne    8009dd <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009d6:	89 c7                	mov    %eax,%edi
  8009d8:	fc                   	cld    
  8009d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009db:	eb 05                	jmp    8009e2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009dd:	89 c7                	mov    %eax,%edi
  8009df:	fc                   	cld    
  8009e0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e2:	5e                   	pop    %esi
  8009e3:	5f                   	pop    %edi
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	89 04 24             	mov    %eax,(%esp)
  800a00:	e8 77 ff ff ff       	call   80097c <memmove>
}
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    

00800a07 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	57                   	push   %edi
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a16:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1b:	eb 16                	jmp    800a33 <memcmp+0x2c>
		if (*s1 != *s2)
  800a1d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a20:	42                   	inc    %edx
  800a21:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a25:	38 c8                	cmp    %cl,%al
  800a27:	74 0a                	je     800a33 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a29:	0f b6 c0             	movzbl %al,%eax
  800a2c:	0f b6 c9             	movzbl %cl,%ecx
  800a2f:	29 c8                	sub    %ecx,%eax
  800a31:	eb 09                	jmp    800a3c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a33:	39 da                	cmp    %ebx,%edx
  800a35:	75 e6                	jne    800a1d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3c:	5b                   	pop    %ebx
  800a3d:	5e                   	pop    %esi
  800a3e:	5f                   	pop    %edi
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a4a:	89 c2                	mov    %eax,%edx
  800a4c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a4f:	eb 05                	jmp    800a56 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a51:	38 08                	cmp    %cl,(%eax)
  800a53:	74 05                	je     800a5a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a55:	40                   	inc    %eax
  800a56:	39 d0                	cmp    %edx,%eax
  800a58:	72 f7                	jb     800a51 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	57                   	push   %edi
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
  800a62:	8b 55 08             	mov    0x8(%ebp),%edx
  800a65:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a68:	eb 01                	jmp    800a6b <strtol+0xf>
		s++;
  800a6a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6b:	8a 02                	mov    (%edx),%al
  800a6d:	3c 20                	cmp    $0x20,%al
  800a6f:	74 f9                	je     800a6a <strtol+0xe>
  800a71:	3c 09                	cmp    $0x9,%al
  800a73:	74 f5                	je     800a6a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a75:	3c 2b                	cmp    $0x2b,%al
  800a77:	75 08                	jne    800a81 <strtol+0x25>
		s++;
  800a79:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7f:	eb 13                	jmp    800a94 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a81:	3c 2d                	cmp    $0x2d,%al
  800a83:	75 0a                	jne    800a8f <strtol+0x33>
		s++, neg = 1;
  800a85:	8d 52 01             	lea    0x1(%edx),%edx
  800a88:	bf 01 00 00 00       	mov    $0x1,%edi
  800a8d:	eb 05                	jmp    800a94 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a94:	85 db                	test   %ebx,%ebx
  800a96:	74 05                	je     800a9d <strtol+0x41>
  800a98:	83 fb 10             	cmp    $0x10,%ebx
  800a9b:	75 28                	jne    800ac5 <strtol+0x69>
  800a9d:	8a 02                	mov    (%edx),%al
  800a9f:	3c 30                	cmp    $0x30,%al
  800aa1:	75 10                	jne    800ab3 <strtol+0x57>
  800aa3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aa7:	75 0a                	jne    800ab3 <strtol+0x57>
		s += 2, base = 16;
  800aa9:	83 c2 02             	add    $0x2,%edx
  800aac:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab1:	eb 12                	jmp    800ac5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ab3:	85 db                	test   %ebx,%ebx
  800ab5:	75 0e                	jne    800ac5 <strtol+0x69>
  800ab7:	3c 30                	cmp    $0x30,%al
  800ab9:	75 05                	jne    800ac0 <strtol+0x64>
		s++, base = 8;
  800abb:	42                   	inc    %edx
  800abc:	b3 08                	mov    $0x8,%bl
  800abe:	eb 05                	jmp    800ac5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ac0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ac5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aca:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800acc:	8a 0a                	mov    (%edx),%cl
  800ace:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ad1:	80 fb 09             	cmp    $0x9,%bl
  800ad4:	77 08                	ja     800ade <strtol+0x82>
			dig = *s - '0';
  800ad6:	0f be c9             	movsbl %cl,%ecx
  800ad9:	83 e9 30             	sub    $0x30,%ecx
  800adc:	eb 1e                	jmp    800afc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ade:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ae1:	80 fb 19             	cmp    $0x19,%bl
  800ae4:	77 08                	ja     800aee <strtol+0x92>
			dig = *s - 'a' + 10;
  800ae6:	0f be c9             	movsbl %cl,%ecx
  800ae9:	83 e9 57             	sub    $0x57,%ecx
  800aec:	eb 0e                	jmp    800afc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800aee:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800af1:	80 fb 19             	cmp    $0x19,%bl
  800af4:	77 12                	ja     800b08 <strtol+0xac>
			dig = *s - 'A' + 10;
  800af6:	0f be c9             	movsbl %cl,%ecx
  800af9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800afc:	39 f1                	cmp    %esi,%ecx
  800afe:	7d 0c                	jge    800b0c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b00:	42                   	inc    %edx
  800b01:	0f af c6             	imul   %esi,%eax
  800b04:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b06:	eb c4                	jmp    800acc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b08:	89 c1                	mov    %eax,%ecx
  800b0a:	eb 02                	jmp    800b0e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b0c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b0e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b12:	74 05                	je     800b19 <strtol+0xbd>
		*endptr = (char *) s;
  800b14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b17:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b19:	85 ff                	test   %edi,%edi
  800b1b:	74 04                	je     800b21 <strtol+0xc5>
  800b1d:	89 c8                	mov    %ecx,%eax
  800b1f:	f7 d8                	neg    %eax
}
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    
	...

00800b28 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b36:	8b 55 08             	mov    0x8(%ebp),%edx
  800b39:	89 c3                	mov    %eax,%ebx
  800b3b:	89 c7                	mov    %eax,%edi
  800b3d:	89 c6                	mov    %eax,%esi
  800b3f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b51:	b8 01 00 00 00       	mov    $0x1,%eax
  800b56:	89 d1                	mov    %edx,%ecx
  800b58:	89 d3                	mov    %edx,%ebx
  800b5a:	89 d7                	mov    %edx,%edi
  800b5c:	89 d6                	mov    %edx,%esi
  800b5e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  800b6b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b73:	b8 03 00 00 00       	mov    $0x3,%eax
  800b78:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7b:	89 cb                	mov    %ecx,%ebx
  800b7d:	89 cf                	mov    %ecx,%edi
  800b7f:	89 ce                	mov    %ecx,%esi
  800b81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b83:	85 c0                	test   %eax,%eax
  800b85:	7e 28                	jle    800baf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b8b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b92:	00 
  800b93:	c7 44 24 08 68 14 80 	movl   $0x801468,0x8(%esp)
  800b9a:	00 
  800b9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ba2:	00 
  800ba3:	c7 04 24 85 14 80 00 	movl   $0x801485,(%esp)
  800baa:	e8 ad f5 ff ff       	call   80015c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800baf:	83 c4 2c             	add    $0x2c,%esp
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc2:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc7:	89 d1                	mov    %edx,%ecx
  800bc9:	89 d3                	mov    %edx,%ebx
  800bcb:	89 d7                	mov    %edx,%edi
  800bcd:	89 d6                	mov    %edx,%esi
  800bcf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_yield>:

void
sys_yield(void)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	be 00 00 00 00       	mov    $0x0,%esi
  800c03:	b8 04 00 00 00       	mov    $0x4,%eax
  800c08:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c11:	89 f7                	mov    %esi,%edi
  800c13:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c15:	85 c0                	test   %eax,%eax
  800c17:	7e 28                	jle    800c41 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c19:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c1d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c24:	00 
  800c25:	c7 44 24 08 68 14 80 	movl   $0x801468,0x8(%esp)
  800c2c:	00 
  800c2d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c34:	00 
  800c35:	c7 04 24 85 14 80 00 	movl   $0x801485,(%esp)
  800c3c:	e8 1b f5 ff ff       	call   80015c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c41:	83 c4 2c             	add    $0x2c,%esp
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c52:	b8 05 00 00 00       	mov    $0x5,%eax
  800c57:	8b 75 18             	mov    0x18(%ebp),%esi
  800c5a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c63:	8b 55 08             	mov    0x8(%ebp),%edx
  800c66:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c68:	85 c0                	test   %eax,%eax
  800c6a:	7e 28                	jle    800c94 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c70:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c77:	00 
  800c78:	c7 44 24 08 68 14 80 	movl   $0x801468,0x8(%esp)
  800c7f:	00 
  800c80:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c87:	00 
  800c88:	c7 04 24 85 14 80 00 	movl   $0x801485,(%esp)
  800c8f:	e8 c8 f4 ff ff       	call   80015c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c94:	83 c4 2c             	add    $0x2c,%esp
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800caa:	b8 06 00 00 00       	mov    $0x6,%eax
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	89 df                	mov    %ebx,%edi
  800cb7:	89 de                	mov    %ebx,%esi
  800cb9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cbb:	85 c0                	test   %eax,%eax
  800cbd:	7e 28                	jle    800ce7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cca:	00 
  800ccb:	c7 44 24 08 68 14 80 	movl   $0x801468,0x8(%esp)
  800cd2:	00 
  800cd3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cda:	00 
  800cdb:	c7 04 24 85 14 80 00 	movl   $0x801485,(%esp)
  800ce2:	e8 75 f4 ff ff       	call   80015c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ce7:	83 c4 2c             	add    $0x2c,%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
  800cf5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfd:	b8 08 00 00 00       	mov    $0x8,%eax
  800d02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d05:	8b 55 08             	mov    0x8(%ebp),%edx
  800d08:	89 df                	mov    %ebx,%edi
  800d0a:	89 de                	mov    %ebx,%esi
  800d0c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	7e 28                	jle    800d3a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d12:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d16:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d1d:	00 
  800d1e:	c7 44 24 08 68 14 80 	movl   $0x801468,0x8(%esp)
  800d25:	00 
  800d26:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2d:	00 
  800d2e:	c7 04 24 85 14 80 00 	movl   $0x801485,(%esp)
  800d35:	e8 22 f4 ff ff       	call   80015c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d3a:	83 c4 2c             	add    $0x2c,%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d50:	b8 09 00 00 00       	mov    $0x9,%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	89 df                	mov    %ebx,%edi
  800d5d:	89 de                	mov    %ebx,%esi
  800d5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7e 28                	jle    800d8d <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d65:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d69:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d70:	00 
  800d71:	c7 44 24 08 68 14 80 	movl   $0x801468,0x8(%esp)
  800d78:	00 
  800d79:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d80:	00 
  800d81:	c7 04 24 85 14 80 00 	movl   $0x801485,(%esp)
  800d88:	e8 cf f3 ff ff       	call   80015c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d8d:	83 c4 2c             	add    $0x2c,%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9b:	be 00 00 00 00       	mov    $0x0,%esi
  800da0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800da5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dae:	8b 55 08             	mov    0x8(%ebp),%edx
  800db1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    

00800db8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	57                   	push   %edi
  800dbc:	56                   	push   %esi
  800dbd:	53                   	push   %ebx
  800dbe:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dce:	89 cb                	mov    %ecx,%ebx
  800dd0:	89 cf                	mov    %ecx,%edi
  800dd2:	89 ce                	mov    %ecx,%esi
  800dd4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	7e 28                	jle    800e02 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dda:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dde:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800de5:	00 
  800de6:	c7 44 24 08 68 14 80 	movl   $0x801468,0x8(%esp)
  800ded:	00 
  800dee:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df5:	00 
  800df6:	c7 04 24 85 14 80 00 	movl   $0x801485,(%esp)
  800dfd:	e8 5a f3 ff ff       	call   80015c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e02:	83 c4 2c             	add    $0x2c,%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	89 df                	mov    %ebx,%edi
  800e25:	89 de                	mov    %ebx,%esi
  800e27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 28                	jle    800e55 <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e31:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e38:	00 
  800e39:	c7 44 24 08 68 14 80 	movl   $0x801468,0x8(%esp)
  800e40:	00 
  800e41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e48:	00 
  800e49:	c7 04 24 85 14 80 00 	movl   $0x801485,(%esp)
  800e50:	e8 07 f3 ff ff       	call   80015c <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800e55:	83 c4 2c             	add    $0x2c,%esp
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    
  800e5d:	00 00                	add    %al,(%eax)
	...

00800e60 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e66:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800e6d:	75 40                	jne    800eaf <set_pgfault_handler+0x4f>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
  800e6f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e76:	00 
  800e77:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800e7e:	ee 
  800e7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e86:	e8 6a fd ff ff       	call   800bf5 <sys_page_alloc>
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	79 20                	jns    800eaf <set_pgfault_handler+0x4f>
            panic("set_pgfault_handler: sys_page_alloc: %e", r);
  800e8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e93:	c7 44 24 08 94 14 80 	movl   $0x801494,0x8(%esp)
  800e9a:	00 
  800e9b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800ea2:	00 
  800ea3:	c7 04 24 f0 14 80 00 	movl   $0x8014f0,(%esp)
  800eaa:	e8 ad f2 ff ff       	call   80015c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800eaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb2:	a3 0c 20 80 00       	mov    %eax,0x80200c
    if ((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0 )
  800eb7:	c7 44 24 04 f4 0e 80 	movl   $0x800ef4,0x4(%esp)
  800ebe:	00 
  800ebf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ec6:	e8 77 fe ff ff       	call   800d42 <sys_env_set_pgfault_upcall>
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	79 20                	jns    800eef <set_pgfault_handler+0x8f>
        panic("set_pgfault_handler: sys_env_set_pgfault_upcall: %e", r);
  800ecf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ed3:	c7 44 24 08 bc 14 80 	movl   $0x8014bc,0x8(%esp)
  800eda:	00 
  800edb:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800ee2:	00 
  800ee3:	c7 04 24 f0 14 80 00 	movl   $0x8014f0,(%esp)
  800eea:	e8 6d f2 ff ff       	call   80015c <_panic>
}
  800eef:	c9                   	leave  
  800ef0:	c3                   	ret    
  800ef1:	00 00                	add    %al,(%eax)
	...

00800ef4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ef4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ef5:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  800efa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800efc:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// sub 4 from old esp
	movl 0x30(%esp), %eax
  800eff:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  800f03:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  800f06:	89 44 24 30          	mov    %eax,0x30(%esp)
	// put old eip into the pre-reserved 4-byte space
	movl 0x28(%esp), %ebx
  800f0a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800f0e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  800f10:	83 c4 08             	add    $0x8,%esp
	popal
  800f13:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  800f14:	83 c4 04             	add    $0x4,%esp
	popfl
  800f17:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800f18:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800f19:	c3                   	ret    
	...

00800f1c <__udivdi3>:
  800f1c:	55                   	push   %ebp
  800f1d:	57                   	push   %edi
  800f1e:	56                   	push   %esi
  800f1f:	83 ec 10             	sub    $0x10,%esp
  800f22:	8b 74 24 20          	mov    0x20(%esp),%esi
  800f26:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f2a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f2e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800f32:	89 cd                	mov    %ecx,%ebp
  800f34:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	75 2c                	jne    800f68 <__udivdi3+0x4c>
  800f3c:	39 f9                	cmp    %edi,%ecx
  800f3e:	77 68                	ja     800fa8 <__udivdi3+0x8c>
  800f40:	85 c9                	test   %ecx,%ecx
  800f42:	75 0b                	jne    800f4f <__udivdi3+0x33>
  800f44:	b8 01 00 00 00       	mov    $0x1,%eax
  800f49:	31 d2                	xor    %edx,%edx
  800f4b:	f7 f1                	div    %ecx
  800f4d:	89 c1                	mov    %eax,%ecx
  800f4f:	31 d2                	xor    %edx,%edx
  800f51:	89 f8                	mov    %edi,%eax
  800f53:	f7 f1                	div    %ecx
  800f55:	89 c7                	mov    %eax,%edi
  800f57:	89 f0                	mov    %esi,%eax
  800f59:	f7 f1                	div    %ecx
  800f5b:	89 c6                	mov    %eax,%esi
  800f5d:	89 f0                	mov    %esi,%eax
  800f5f:	89 fa                	mov    %edi,%edx
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	5e                   	pop    %esi
  800f65:	5f                   	pop    %edi
  800f66:	5d                   	pop    %ebp
  800f67:	c3                   	ret    
  800f68:	39 f8                	cmp    %edi,%eax
  800f6a:	77 2c                	ja     800f98 <__udivdi3+0x7c>
  800f6c:	0f bd f0             	bsr    %eax,%esi
  800f6f:	83 f6 1f             	xor    $0x1f,%esi
  800f72:	75 4c                	jne    800fc0 <__udivdi3+0xa4>
  800f74:	39 f8                	cmp    %edi,%eax
  800f76:	bf 00 00 00 00       	mov    $0x0,%edi
  800f7b:	72 0a                	jb     800f87 <__udivdi3+0x6b>
  800f7d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800f81:	0f 87 ad 00 00 00    	ja     801034 <__udivdi3+0x118>
  800f87:	be 01 00 00 00       	mov    $0x1,%esi
  800f8c:	89 f0                	mov    %esi,%eax
  800f8e:	89 fa                	mov    %edi,%edx
  800f90:	83 c4 10             	add    $0x10,%esp
  800f93:	5e                   	pop    %esi
  800f94:	5f                   	pop    %edi
  800f95:	5d                   	pop    %ebp
  800f96:	c3                   	ret    
  800f97:	90                   	nop
  800f98:	31 ff                	xor    %edi,%edi
  800f9a:	31 f6                	xor    %esi,%esi
  800f9c:	89 f0                	mov    %esi,%eax
  800f9e:	89 fa                	mov    %edi,%edx
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	5e                   	pop    %esi
  800fa4:	5f                   	pop    %edi
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    
  800fa7:	90                   	nop
  800fa8:	89 fa                	mov    %edi,%edx
  800faa:	89 f0                	mov    %esi,%eax
  800fac:	f7 f1                	div    %ecx
  800fae:	89 c6                	mov    %eax,%esi
  800fb0:	31 ff                	xor    %edi,%edi
  800fb2:	89 f0                	mov    %esi,%eax
  800fb4:	89 fa                	mov    %edi,%edx
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	5e                   	pop    %esi
  800fba:	5f                   	pop    %edi
  800fbb:	5d                   	pop    %ebp
  800fbc:	c3                   	ret    
  800fbd:	8d 76 00             	lea    0x0(%esi),%esi
  800fc0:	89 f1                	mov    %esi,%ecx
  800fc2:	d3 e0                	shl    %cl,%eax
  800fc4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fc8:	b8 20 00 00 00       	mov    $0x20,%eax
  800fcd:	29 f0                	sub    %esi,%eax
  800fcf:	89 ea                	mov    %ebp,%edx
  800fd1:	88 c1                	mov    %al,%cl
  800fd3:	d3 ea                	shr    %cl,%edx
  800fd5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800fd9:	09 ca                	or     %ecx,%edx
  800fdb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fdf:	89 f1                	mov    %esi,%ecx
  800fe1:	d3 e5                	shl    %cl,%ebp
  800fe3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800fe7:	89 fd                	mov    %edi,%ebp
  800fe9:	88 c1                	mov    %al,%cl
  800feb:	d3 ed                	shr    %cl,%ebp
  800fed:	89 fa                	mov    %edi,%edx
  800fef:	89 f1                	mov    %esi,%ecx
  800ff1:	d3 e2                	shl    %cl,%edx
  800ff3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ff7:	88 c1                	mov    %al,%cl
  800ff9:	d3 ef                	shr    %cl,%edi
  800ffb:	09 d7                	or     %edx,%edi
  800ffd:	89 f8                	mov    %edi,%eax
  800fff:	89 ea                	mov    %ebp,%edx
  801001:	f7 74 24 08          	divl   0x8(%esp)
  801005:	89 d1                	mov    %edx,%ecx
  801007:	89 c7                	mov    %eax,%edi
  801009:	f7 64 24 0c          	mull   0xc(%esp)
  80100d:	39 d1                	cmp    %edx,%ecx
  80100f:	72 17                	jb     801028 <__udivdi3+0x10c>
  801011:	74 09                	je     80101c <__udivdi3+0x100>
  801013:	89 fe                	mov    %edi,%esi
  801015:	31 ff                	xor    %edi,%edi
  801017:	e9 41 ff ff ff       	jmp    800f5d <__udivdi3+0x41>
  80101c:	8b 54 24 04          	mov    0x4(%esp),%edx
  801020:	89 f1                	mov    %esi,%ecx
  801022:	d3 e2                	shl    %cl,%edx
  801024:	39 c2                	cmp    %eax,%edx
  801026:	73 eb                	jae    801013 <__udivdi3+0xf7>
  801028:	8d 77 ff             	lea    -0x1(%edi),%esi
  80102b:	31 ff                	xor    %edi,%edi
  80102d:	e9 2b ff ff ff       	jmp    800f5d <__udivdi3+0x41>
  801032:	66 90                	xchg   %ax,%ax
  801034:	31 f6                	xor    %esi,%esi
  801036:	e9 22 ff ff ff       	jmp    800f5d <__udivdi3+0x41>
	...

0080103c <__umoddi3>:
  80103c:	55                   	push   %ebp
  80103d:	57                   	push   %edi
  80103e:	56                   	push   %esi
  80103f:	83 ec 20             	sub    $0x20,%esp
  801042:	8b 44 24 30          	mov    0x30(%esp),%eax
  801046:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80104a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80104e:	8b 74 24 34          	mov    0x34(%esp),%esi
  801052:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801056:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80105a:	89 c7                	mov    %eax,%edi
  80105c:	89 f2                	mov    %esi,%edx
  80105e:	85 ed                	test   %ebp,%ebp
  801060:	75 16                	jne    801078 <__umoddi3+0x3c>
  801062:	39 f1                	cmp    %esi,%ecx
  801064:	0f 86 a6 00 00 00    	jbe    801110 <__umoddi3+0xd4>
  80106a:	f7 f1                	div    %ecx
  80106c:	89 d0                	mov    %edx,%eax
  80106e:	31 d2                	xor    %edx,%edx
  801070:	83 c4 20             	add    $0x20,%esp
  801073:	5e                   	pop    %esi
  801074:	5f                   	pop    %edi
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    
  801077:	90                   	nop
  801078:	39 f5                	cmp    %esi,%ebp
  80107a:	0f 87 ac 00 00 00    	ja     80112c <__umoddi3+0xf0>
  801080:	0f bd c5             	bsr    %ebp,%eax
  801083:	83 f0 1f             	xor    $0x1f,%eax
  801086:	89 44 24 10          	mov    %eax,0x10(%esp)
  80108a:	0f 84 a8 00 00 00    	je     801138 <__umoddi3+0xfc>
  801090:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801094:	d3 e5                	shl    %cl,%ebp
  801096:	bf 20 00 00 00       	mov    $0x20,%edi
  80109b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80109f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8010a3:	89 f9                	mov    %edi,%ecx
  8010a5:	d3 e8                	shr    %cl,%eax
  8010a7:	09 e8                	or     %ebp,%eax
  8010a9:	89 44 24 18          	mov    %eax,0x18(%esp)
  8010ad:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8010b1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010b5:	d3 e0                	shl    %cl,%eax
  8010b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010bb:	89 f2                	mov    %esi,%edx
  8010bd:	d3 e2                	shl    %cl,%edx
  8010bf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8010c3:	d3 e0                	shl    %cl,%eax
  8010c5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8010c9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8010cd:	89 f9                	mov    %edi,%ecx
  8010cf:	d3 e8                	shr    %cl,%eax
  8010d1:	09 d0                	or     %edx,%eax
  8010d3:	d3 ee                	shr    %cl,%esi
  8010d5:	89 f2                	mov    %esi,%edx
  8010d7:	f7 74 24 18          	divl   0x18(%esp)
  8010db:	89 d6                	mov    %edx,%esi
  8010dd:	f7 64 24 0c          	mull   0xc(%esp)
  8010e1:	89 c5                	mov    %eax,%ebp
  8010e3:	89 d1                	mov    %edx,%ecx
  8010e5:	39 d6                	cmp    %edx,%esi
  8010e7:	72 67                	jb     801150 <__umoddi3+0x114>
  8010e9:	74 75                	je     801160 <__umoddi3+0x124>
  8010eb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8010ef:	29 e8                	sub    %ebp,%eax
  8010f1:	19 ce                	sbb    %ecx,%esi
  8010f3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010f7:	d3 e8                	shr    %cl,%eax
  8010f9:	89 f2                	mov    %esi,%edx
  8010fb:	89 f9                	mov    %edi,%ecx
  8010fd:	d3 e2                	shl    %cl,%edx
  8010ff:	09 d0                	or     %edx,%eax
  801101:	89 f2                	mov    %esi,%edx
  801103:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801107:	d3 ea                	shr    %cl,%edx
  801109:	83 c4 20             	add    $0x20,%esp
  80110c:	5e                   	pop    %esi
  80110d:	5f                   	pop    %edi
  80110e:	5d                   	pop    %ebp
  80110f:	c3                   	ret    
  801110:	85 c9                	test   %ecx,%ecx
  801112:	75 0b                	jne    80111f <__umoddi3+0xe3>
  801114:	b8 01 00 00 00       	mov    $0x1,%eax
  801119:	31 d2                	xor    %edx,%edx
  80111b:	f7 f1                	div    %ecx
  80111d:	89 c1                	mov    %eax,%ecx
  80111f:	89 f0                	mov    %esi,%eax
  801121:	31 d2                	xor    %edx,%edx
  801123:	f7 f1                	div    %ecx
  801125:	89 f8                	mov    %edi,%eax
  801127:	e9 3e ff ff ff       	jmp    80106a <__umoddi3+0x2e>
  80112c:	89 f2                	mov    %esi,%edx
  80112e:	83 c4 20             	add    $0x20,%esp
  801131:	5e                   	pop    %esi
  801132:	5f                   	pop    %edi
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    
  801135:	8d 76 00             	lea    0x0(%esi),%esi
  801138:	39 f5                	cmp    %esi,%ebp
  80113a:	72 04                	jb     801140 <__umoddi3+0x104>
  80113c:	39 f9                	cmp    %edi,%ecx
  80113e:	77 06                	ja     801146 <__umoddi3+0x10a>
  801140:	89 f2                	mov    %esi,%edx
  801142:	29 cf                	sub    %ecx,%edi
  801144:	19 ea                	sbb    %ebp,%edx
  801146:	89 f8                	mov    %edi,%eax
  801148:	83 c4 20             	add    $0x20,%esp
  80114b:	5e                   	pop    %esi
  80114c:	5f                   	pop    %edi
  80114d:	5d                   	pop    %ebp
  80114e:	c3                   	ret    
  80114f:	90                   	nop
  801150:	89 d1                	mov    %edx,%ecx
  801152:	89 c5                	mov    %eax,%ebp
  801154:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801158:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80115c:	eb 8d                	jmp    8010eb <__umoddi3+0xaf>
  80115e:	66 90                	xchg   %ax,%ax
  801160:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801164:	72 ea                	jb     801150 <__umoddi3+0x114>
  801166:	89 f1                	mov    %esi,%ecx
  801168:	eb 81                	jmp    8010eb <__umoddi3+0xaf>
