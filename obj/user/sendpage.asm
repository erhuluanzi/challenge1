
obj/user/sendpage:     file format elf32-i386


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
  80002c:	e8 af 01 00 00       	call   8001e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 28             	sub    $0x28,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  80003a:	e8 24 15 00 00       	call   801563 <fork>
  80003f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800042:	85 c0                	test   %eax,%eax
  800044:	0f 85 bb 00 00 00    	jne    800105 <umain+0xd1>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  80004a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800051:	00 
  800052:	c7 44 24 04 00 00 b0 	movl   $0xb00000,0x4(%esp)
  800059:	00 
  80005a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80005d:	89 04 24             	mov    %eax,(%esp)
  800060:	e8 bf 16 00 00       	call   801724 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800065:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  80006c:	00 
  80006d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800070:	89 44 24 04          	mov    %eax,0x4(%esp)
  800074:	c7 04 24 e0 1b 80 00 	movl   $0x801be0,(%esp)
  80007b:	e8 64 02 00 00       	call   8002e4 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800080:	a1 04 30 80 00       	mov    0x803004,%eax
  800085:	89 04 24             	mov    %eax,(%esp)
  800088:	e8 d3 07 00 00       	call   800860 <strlen>
  80008d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800091:	a1 04 30 80 00       	mov    0x803004,%eax
  800096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009a:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a1:	e8 b5 08 00 00       	call   80095b <strncmp>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 0c                	jne    8000b6 <umain+0x82>
			cprintf("child received correct message\n");
  8000aa:	c7 04 24 f4 1b 80 00 	movl   $0x801bf4,(%esp)
  8000b1:	e8 2e 02 00 00       	call   8002e4 <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000b6:	a1 00 30 80 00       	mov    0x803000,%eax
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 9d 07 00 00       	call   800860 <strlen>
  8000c3:	40                   	inc    %eax
  8000c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c8:	a1 00 30 80 00       	mov    0x803000,%eax
  8000cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d1:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000d8:	e8 99 09 00 00       	call   800a76 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000dd:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000f4:	00 
  8000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000f8:	89 04 24             	mov    %eax,(%esp)
  8000fb:	e8 94 16 00 00       	call   801794 <ipc_send>
		return;
  800100:	e9 d6 00 00 00       	jmp    8001db <umain+0x1a7>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800105:	a1 10 30 80 00       	mov    0x803010,%eax
  80010a:	8b 40 48             	mov    0x48(%eax),%eax
  80010d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800114:	00 
  800115:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80011c:	00 
  80011d:	89 04 24             	mov    %eax,(%esp)
  800120:	e8 60 0b 00 00       	call   800c85 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800125:	a1 04 30 80 00       	mov    0x803004,%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 2e 07 00 00       	call   800860 <strlen>
  800132:	40                   	inc    %eax
  800133:	89 44 24 08          	mov    %eax,0x8(%esp)
  800137:	a1 04 30 80 00       	mov    0x803004,%eax
  80013c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800140:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  800147:	e8 2a 09 00 00       	call   800a76 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80014c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800153:	00 
  800154:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80015b:	00 
  80015c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800163:	00 
  800164:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800167:	89 04 24             	mov    %eax,(%esp)
  80016a:	e8 25 16 00 00       	call   801794 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  80016f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800176:	00 
  800177:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80017e:	00 
  80017f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800182:	89 04 24             	mov    %eax,(%esp)
  800185:	e8 9a 15 00 00       	call   801724 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80018a:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  800191:	00 
  800192:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	c7 04 24 e0 1b 80 00 	movl   $0x801be0,(%esp)
  8001a0:	e8 3f 01 00 00       	call   8002e4 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001a5:	a1 00 30 80 00       	mov    0x803000,%eax
  8001aa:	89 04 24             	mov    %eax,(%esp)
  8001ad:	e8 ae 06 00 00       	call   800860 <strlen>
  8001b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b6:	a1 00 30 80 00       	mov    0x803000,%eax
  8001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bf:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001c6:	e8 90 07 00 00       	call   80095b <strncmp>
  8001cb:	85 c0                	test   %eax,%eax
  8001cd:	75 0c                	jne    8001db <umain+0x1a7>
		cprintf("parent received correct message\n");
  8001cf:	c7 04 24 14 1c 80 00 	movl   $0x801c14,(%esp)
  8001d6:	e8 09 01 00 00       	call   8002e4 <cprintf>
	return;
}
  8001db:	c9                   	leave  
  8001dc:	c3                   	ret    
  8001dd:	00 00                	add    %al,(%eax)
	...

008001e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 10             	sub    $0x10,%esp
  8001e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8001eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8001ee:	e8 54 0a 00 00       	call   800c47 <sys_getenvid>
  8001f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f8:	8d 04 40             	lea    (%eax,%eax,2),%eax
  8001fb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8001fe:	c1 e0 04             	shl    $0x4,%eax
  800201:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800206:	a3 10 30 80 00       	mov    %eax,0x803010

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020b:	85 f6                	test   %esi,%esi
  80020d:	7e 07                	jle    800216 <libmain+0x36>
		binaryname = argv[0];
  80020f:	8b 03                	mov    (%ebx),%eax
  800211:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  800216:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80021a:	89 34 24             	mov    %esi,(%esp)
  80021d:	e8 12 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800222:	e8 09 00 00 00       	call   800230 <exit>
}
  800227:	83 c4 10             	add    $0x10,%esp
  80022a:	5b                   	pop    %ebx
  80022b:	5e                   	pop    %esi
  80022c:	5d                   	pop    %ebp
  80022d:	c3                   	ret    
	...

00800230 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800236:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80023d:	e8 b3 09 00 00       	call   800bf5 <sys_env_destroy>
}
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	53                   	push   %ebx
  800248:	83 ec 14             	sub    $0x14,%esp
  80024b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80024e:	8b 03                	mov    (%ebx),%eax
  800250:	8b 55 08             	mov    0x8(%ebp),%edx
  800253:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800257:	40                   	inc    %eax
  800258:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80025a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80025f:	75 19                	jne    80027a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800261:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800268:	00 
  800269:	8d 43 08             	lea    0x8(%ebx),%eax
  80026c:	89 04 24             	mov    %eax,(%esp)
  80026f:	e8 44 09 00 00       	call   800bb8 <sys_cputs>
		b->idx = 0;
  800274:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80027a:	ff 43 04             	incl   0x4(%ebx)
}
  80027d:	83 c4 14             	add    $0x14,%esp
  800280:	5b                   	pop    %ebx
  800281:	5d                   	pop    %ebp
  800282:	c3                   	ret    

00800283 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80028c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800293:	00 00 00 
	b.cnt = 0;
  800296:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80029d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ae:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b8:	c7 04 24 44 02 80 00 	movl   $0x800244,(%esp)
  8002bf:	e8 b4 01 00 00       	call   800478 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002c4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ce:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002d4:	89 04 24             	mov    %eax,(%esp)
  8002d7:	e8 dc 08 00 00       	call   800bb8 <sys_cputs>

	return b.cnt;
}
  8002dc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002e2:	c9                   	leave  
  8002e3:	c3                   	ret    

008002e4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ea:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f4:	89 04 24             	mov    %eax,(%esp)
  8002f7:	e8 87 ff ff ff       	call   800283 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002fc:	c9                   	leave  
  8002fd:	c3                   	ret    
	...

00800300 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	57                   	push   %edi
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
  800306:	83 ec 3c             	sub    $0x3c,%esp
  800309:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030c:	89 d7                	mov    %edx,%edi
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800314:	8b 45 0c             	mov    0xc(%ebp),%eax
  800317:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80031a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80031d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800320:	85 c0                	test   %eax,%eax
  800322:	75 08                	jne    80032c <printnum+0x2c>
  800324:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800327:	39 45 10             	cmp    %eax,0x10(%ebp)
  80032a:	77 57                	ja     800383 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80032c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800330:	4b                   	dec    %ebx
  800331:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800335:	8b 45 10             	mov    0x10(%ebp),%eax
  800338:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800340:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800344:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80034b:	00 
  80034c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80034f:	89 04 24             	mov    %eax,(%esp)
  800352:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800355:	89 44 24 04          	mov    %eax,0x4(%esp)
  800359:	e8 1a 16 00 00       	call   801978 <__udivdi3>
  80035e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800362:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800366:	89 04 24             	mov    %eax,(%esp)
  800369:	89 54 24 04          	mov    %edx,0x4(%esp)
  80036d:	89 fa                	mov    %edi,%edx
  80036f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800372:	e8 89 ff ff ff       	call   800300 <printnum>
  800377:	eb 0f                	jmp    800388 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800379:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80037d:	89 34 24             	mov    %esi,(%esp)
  800380:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800383:	4b                   	dec    %ebx
  800384:	85 db                	test   %ebx,%ebx
  800386:	7f f1                	jg     800379 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800388:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80038c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800390:	8b 45 10             	mov    0x10(%ebp),%eax
  800393:	89 44 24 08          	mov    %eax,0x8(%esp)
  800397:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80039e:	00 
  80039f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003a2:	89 04 24             	mov    %eax,(%esp)
  8003a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ac:	e8 e7 16 00 00       	call   801a98 <__umoddi3>
  8003b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b5:	0f be 80 8c 1c 80 00 	movsbl 0x801c8c(%eax),%eax
  8003bc:	89 04 24             	mov    %eax,(%esp)
  8003bf:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003c2:	83 c4 3c             	add    $0x3c,%esp
  8003c5:	5b                   	pop    %ebx
  8003c6:	5e                   	pop    %esi
  8003c7:	5f                   	pop    %edi
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003cd:	83 fa 01             	cmp    $0x1,%edx
  8003d0:	7e 0e                	jle    8003e0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d2:	8b 10                	mov    (%eax),%edx
  8003d4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d7:	89 08                	mov    %ecx,(%eax)
  8003d9:	8b 02                	mov    (%edx),%eax
  8003db:	8b 52 04             	mov    0x4(%edx),%edx
  8003de:	eb 22                	jmp    800402 <getuint+0x38>
	else if (lflag)
  8003e0:	85 d2                	test   %edx,%edx
  8003e2:	74 10                	je     8003f4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e4:	8b 10                	mov    (%eax),%edx
  8003e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e9:	89 08                	mov    %ecx,(%eax)
  8003eb:	8b 02                	mov    (%edx),%eax
  8003ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f2:	eb 0e                	jmp    800402 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f4:	8b 10                	mov    (%eax),%edx
  8003f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f9:	89 08                	mov    %ecx,(%eax)
  8003fb:	8b 02                	mov    (%edx),%eax
  8003fd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800402:	5d                   	pop    %ebp
  800403:	c3                   	ret    

00800404 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800407:	83 fa 01             	cmp    $0x1,%edx
  80040a:	7e 0e                	jle    80041a <getint+0x16>
		return va_arg(*ap, long long);
  80040c:	8b 10                	mov    (%eax),%edx
  80040e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800411:	89 08                	mov    %ecx,(%eax)
  800413:	8b 02                	mov    (%edx),%eax
  800415:	8b 52 04             	mov    0x4(%edx),%edx
  800418:	eb 1a                	jmp    800434 <getint+0x30>
	else if (lflag)
  80041a:	85 d2                	test   %edx,%edx
  80041c:	74 0c                	je     80042a <getint+0x26>
		return va_arg(*ap, long);
  80041e:	8b 10                	mov    (%eax),%edx
  800420:	8d 4a 04             	lea    0x4(%edx),%ecx
  800423:	89 08                	mov    %ecx,(%eax)
  800425:	8b 02                	mov    (%edx),%eax
  800427:	99                   	cltd   
  800428:	eb 0a                	jmp    800434 <getint+0x30>
	else
		return va_arg(*ap, int);
  80042a:	8b 10                	mov    (%eax),%edx
  80042c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80042f:	89 08                	mov    %ecx,(%eax)
  800431:	8b 02                	mov    (%edx),%eax
  800433:	99                   	cltd   
}
  800434:	5d                   	pop    %ebp
  800435:	c3                   	ret    

00800436 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
  800439:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80043c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80043f:	8b 10                	mov    (%eax),%edx
  800441:	3b 50 04             	cmp    0x4(%eax),%edx
  800444:	73 08                	jae    80044e <sprintputch+0x18>
		*b->buf++ = ch;
  800446:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800449:	88 0a                	mov    %cl,(%edx)
  80044b:	42                   	inc    %edx
  80044c:	89 10                	mov    %edx,(%eax)
}
  80044e:	5d                   	pop    %ebp
  80044f:	c3                   	ret    

00800450 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800456:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800459:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80045d:	8b 45 10             	mov    0x10(%ebp),%eax
  800460:	89 44 24 08          	mov    %eax,0x8(%esp)
  800464:	8b 45 0c             	mov    0xc(%ebp),%eax
  800467:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046b:	8b 45 08             	mov    0x8(%ebp),%eax
  80046e:	89 04 24             	mov    %eax,(%esp)
  800471:	e8 02 00 00 00       	call   800478 <vprintfmt>
	va_end(ap);
}
  800476:	c9                   	leave  
  800477:	c3                   	ret    

00800478 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	57                   	push   %edi
  80047c:	56                   	push   %esi
  80047d:	53                   	push   %ebx
  80047e:	83 ec 4c             	sub    $0x4c,%esp
  800481:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800484:	8b 75 10             	mov    0x10(%ebp),%esi
  800487:	eb 12                	jmp    80049b <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800489:	85 c0                	test   %eax,%eax
  80048b:	0f 84 40 03 00 00    	je     8007d1 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
  800491:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800495:	89 04 24             	mov    %eax,(%esp)
  800498:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80049b:	0f b6 06             	movzbl (%esi),%eax
  80049e:	46                   	inc    %esi
  80049f:	83 f8 25             	cmp    $0x25,%eax
  8004a2:	75 e5                	jne    800489 <vprintfmt+0x11>
  8004a4:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004a8:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004af:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004b4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c0:	eb 26                	jmp    8004e8 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004c5:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004c9:	eb 1d                	jmp    8004e8 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004ce:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004d2:	eb 14                	jmp    8004e8 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004d7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004de:	eb 08                	jmp    8004e8 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004e0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004e3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e8:	0f b6 06             	movzbl (%esi),%eax
  8004eb:	8d 4e 01             	lea    0x1(%esi),%ecx
  8004ee:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004f1:	8a 0e                	mov    (%esi),%cl
  8004f3:	83 e9 23             	sub    $0x23,%ecx
  8004f6:	80 f9 55             	cmp    $0x55,%cl
  8004f9:	0f 87 b6 02 00 00    	ja     8007b5 <vprintfmt+0x33d>
  8004ff:	0f b6 c9             	movzbl %cl,%ecx
  800502:	ff 24 8d 60 1d 80 00 	jmp    *0x801d60(,%ecx,4)
  800509:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80050c:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800511:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
  800514:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
  800518:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80051b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80051e:	83 f9 09             	cmp    $0x9,%ecx
  800521:	77 2a                	ja     80054d <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800523:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800524:	eb eb                	jmp    800511 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8d 48 04             	lea    0x4(%eax),%ecx
  80052c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80052f:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800531:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800534:	eb 17                	jmp    80054d <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800536:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80053a:	78 98                	js     8004d4 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80053f:	eb a7                	jmp    8004e8 <vprintfmt+0x70>
  800541:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800544:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80054b:	eb 9b                	jmp    8004e8 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80054d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800551:	79 95                	jns    8004e8 <vprintfmt+0x70>
  800553:	eb 8b                	jmp    8004e0 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800555:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800559:	eb 8d                	jmp    8004e8 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	8d 50 04             	lea    0x4(%eax),%edx
  800561:	89 55 14             	mov    %edx,0x14(%ebp)
  800564:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800568:	8b 00                	mov    (%eax),%eax
  80056a:	89 04 24             	mov    %eax,(%esp)
  80056d:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800570:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800573:	e9 23 ff ff ff       	jmp    80049b <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8d 50 04             	lea    0x4(%eax),%edx
  80057e:	89 55 14             	mov    %edx,0x14(%ebp)
  800581:	8b 00                	mov    (%eax),%eax
  800583:	85 c0                	test   %eax,%eax
  800585:	79 02                	jns    800589 <vprintfmt+0x111>
  800587:	f7 d8                	neg    %eax
  800589:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80058b:	83 f8 09             	cmp    $0x9,%eax
  80058e:	7f 0b                	jg     80059b <vprintfmt+0x123>
  800590:	8b 04 85 c0 1e 80 00 	mov    0x801ec0(,%eax,4),%eax
  800597:	85 c0                	test   %eax,%eax
  800599:	75 23                	jne    8005be <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80059b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80059f:	c7 44 24 08 a4 1c 80 	movl   $0x801ca4,0x8(%esp)
  8005a6:	00 
  8005a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ae:	89 04 24             	mov    %eax,(%esp)
  8005b1:	e8 9a fe ff ff       	call   800450 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005b9:	e9 dd fe ff ff       	jmp    80049b <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c2:	c7 44 24 08 ad 1c 80 	movl   $0x801cad,0x8(%esp)
  8005c9:	00 
  8005ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8005d1:	89 14 24             	mov    %edx,(%esp)
  8005d4:	e8 77 fe ff ff       	call   800450 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005dc:	e9 ba fe ff ff       	jmp    80049b <vprintfmt+0x23>
  8005e1:	89 f9                	mov    %edi,%ecx
  8005e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8d 50 04             	lea    0x4(%eax),%edx
  8005ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f2:	8b 30                	mov    (%eax),%esi
  8005f4:	85 f6                	test   %esi,%esi
  8005f6:	75 05                	jne    8005fd <vprintfmt+0x185>
				p = "(null)";
  8005f8:	be 9d 1c 80 00       	mov    $0x801c9d,%esi
			if (width > 0 && padc != '-')
  8005fd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800601:	0f 8e 84 00 00 00    	jle    80068b <vprintfmt+0x213>
  800607:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80060b:	74 7e                	je     80068b <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80060d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800611:	89 34 24             	mov    %esi,(%esp)
  800614:	e8 5d 02 00 00       	call   800876 <strnlen>
  800619:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80061c:	29 c2                	sub    %eax,%edx
  80061e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800621:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800625:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800628:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80062b:	89 de                	mov    %ebx,%esi
  80062d:	89 d3                	mov    %edx,%ebx
  80062f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800631:	eb 0b                	jmp    80063e <vprintfmt+0x1c6>
					putch(padc, putdat);
  800633:	89 74 24 04          	mov    %esi,0x4(%esp)
  800637:	89 3c 24             	mov    %edi,(%esp)
  80063a:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80063d:	4b                   	dec    %ebx
  80063e:	85 db                	test   %ebx,%ebx
  800640:	7f f1                	jg     800633 <vprintfmt+0x1bb>
  800642:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800645:	89 f3                	mov    %esi,%ebx
  800647:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80064a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80064d:	85 c0                	test   %eax,%eax
  80064f:	79 05                	jns    800656 <vprintfmt+0x1de>
  800651:	b8 00 00 00 00       	mov    $0x0,%eax
  800656:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800659:	29 c2                	sub    %eax,%edx
  80065b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80065e:	eb 2b                	jmp    80068b <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800660:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800664:	74 18                	je     80067e <vprintfmt+0x206>
  800666:	8d 50 e0             	lea    -0x20(%eax),%edx
  800669:	83 fa 5e             	cmp    $0x5e,%edx
  80066c:	76 10                	jbe    80067e <vprintfmt+0x206>
					putch('?', putdat);
  80066e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800672:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800679:	ff 55 08             	call   *0x8(%ebp)
  80067c:	eb 0a                	jmp    800688 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80067e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800682:	89 04 24             	mov    %eax,(%esp)
  800685:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800688:	ff 4d e4             	decl   -0x1c(%ebp)
  80068b:	0f be 06             	movsbl (%esi),%eax
  80068e:	46                   	inc    %esi
  80068f:	85 c0                	test   %eax,%eax
  800691:	74 21                	je     8006b4 <vprintfmt+0x23c>
  800693:	85 ff                	test   %edi,%edi
  800695:	78 c9                	js     800660 <vprintfmt+0x1e8>
  800697:	4f                   	dec    %edi
  800698:	79 c6                	jns    800660 <vprintfmt+0x1e8>
  80069a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80069d:	89 de                	mov    %ebx,%esi
  80069f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006a2:	eb 18                	jmp    8006bc <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006af:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b1:	4b                   	dec    %ebx
  8006b2:	eb 08                	jmp    8006bc <vprintfmt+0x244>
  8006b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b7:	89 de                	mov    %ebx,%esi
  8006b9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006bc:	85 db                	test   %ebx,%ebx
  8006be:	7f e4                	jg     8006a4 <vprintfmt+0x22c>
  8006c0:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006c3:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006c8:	e9 ce fd ff ff       	jmp    80049b <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006cd:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d0:	e8 2f fd ff ff       	call   800404 <getint>
  8006d5:	89 c6                	mov    %eax,%esi
  8006d7:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8006d9:	85 d2                	test   %edx,%edx
  8006db:	78 07                	js     8006e4 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006dd:	be 0a 00 00 00       	mov    $0xa,%esi
  8006e2:	eb 7e                	jmp    800762 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006ef:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006f2:	89 f0                	mov    %esi,%eax
  8006f4:	89 fa                	mov    %edi,%edx
  8006f6:	f7 d8                	neg    %eax
  8006f8:	83 d2 00             	adc    $0x0,%edx
  8006fb:	f7 da                	neg    %edx
			}
			base = 10;
  8006fd:	be 0a 00 00 00       	mov    $0xa,%esi
  800702:	eb 5e                	jmp    800762 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800704:	8d 45 14             	lea    0x14(%ebp),%eax
  800707:	e8 be fc ff ff       	call   8003ca <getuint>
			base = 10;
  80070c:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800711:	eb 4f                	jmp    800762 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800713:	8d 45 14             	lea    0x14(%ebp),%eax
  800716:	e8 af fc ff ff       	call   8003ca <getuint>
			base = 8;
  80071b:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800720:	eb 40                	jmp    800762 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
  800722:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800726:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80072d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800730:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800734:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80073b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80073e:	8b 45 14             	mov    0x14(%ebp),%eax
  800741:	8d 50 04             	lea    0x4(%eax),%edx
  800744:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800747:	8b 00                	mov    (%eax),%eax
  800749:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80074e:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800753:	eb 0d                	jmp    800762 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800755:	8d 45 14             	lea    0x14(%ebp),%eax
  800758:	e8 6d fc ff ff       	call   8003ca <getuint>
			base = 16;
  80075d:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800762:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800766:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80076a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80076d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800771:	89 74 24 08          	mov    %esi,0x8(%esp)
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	89 54 24 04          	mov    %edx,0x4(%esp)
  80077c:	89 da                	mov    %ebx,%edx
  80077e:	8b 45 08             	mov    0x8(%ebp),%eax
  800781:	e8 7a fb ff ff       	call   800300 <printnum>
			break;
  800786:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800789:	e9 0d fd ff ff       	jmp    80049b <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
  80078e:	8d 45 14             	lea    0x14(%ebp),%eax
  800791:	e8 6e fc ff ff       	call   800404 <getint>
  800796:	a3 0c 30 80 00       	mov    %eax,0x80300c
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
  80079e:	e9 f8 fc ff ff       	jmp    80049b <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a7:	89 04 24             	mov    %eax,(%esp)
  8007aa:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ad:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007b0:	e9 e6 fc ff ff       	jmp    80049b <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007c0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c3:	eb 01                	jmp    8007c6 <vprintfmt+0x34e>
  8007c5:	4e                   	dec    %esi
  8007c6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007ca:	75 f9                	jne    8007c5 <vprintfmt+0x34d>
  8007cc:	e9 ca fc ff ff       	jmp    80049b <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007d1:	83 c4 4c             	add    $0x4c,%esp
  8007d4:	5b                   	pop    %ebx
  8007d5:	5e                   	pop    %esi
  8007d6:	5f                   	pop    %edi
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	83 ec 28             	sub    $0x28,%esp
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ec:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	74 30                	je     80082a <vsnprintf+0x51>
  8007fa:	85 d2                	test   %edx,%edx
  8007fc:	7e 33                	jle    800831 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800801:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800805:	8b 45 10             	mov    0x10(%ebp),%eax
  800808:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80080f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800813:	c7 04 24 36 04 80 00 	movl   $0x800436,(%esp)
  80081a:	e8 59 fc ff ff       	call   800478 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80081f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800822:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800825:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800828:	eb 0c                	jmp    800836 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80082a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082f:	eb 05                	jmp    800836 <vsnprintf+0x5d>
  800831:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800836:	c9                   	leave  
  800837:	c3                   	ret    

00800838 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800841:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800845:	8b 45 10             	mov    0x10(%ebp),%eax
  800848:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800853:	8b 45 08             	mov    0x8(%ebp),%eax
  800856:	89 04 24             	mov    %eax,(%esp)
  800859:	e8 7b ff ff ff       	call   8007d9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80085e:	c9                   	leave  
  80085f:	c3                   	ret    

00800860 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	eb 01                	jmp    80086e <strlen+0xe>
		n++;
  80086d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80086e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800872:	75 f9                	jne    80086d <strlen+0xd>
		n++;
	return n;
}
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087f:	b8 00 00 00 00       	mov    $0x0,%eax
  800884:	eb 01                	jmp    800887 <strnlen+0x11>
		n++;
  800886:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800887:	39 d0                	cmp    %edx,%eax
  800889:	74 06                	je     800891 <strnlen+0x1b>
  80088b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80088f:	75 f5                	jne    800886 <strnlen+0x10>
		n++;
	return n;
}
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	53                   	push   %ebx
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089d:	ba 00 00 00 00       	mov    $0x0,%edx
  8008a2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008a5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008a8:	42                   	inc    %edx
  8008a9:	84 c9                	test   %cl,%cl
  8008ab:	75 f5                	jne    8008a2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008ad:	5b                   	pop    %ebx
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	53                   	push   %ebx
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008ba:	89 1c 24             	mov    %ebx,(%esp)
  8008bd:	e8 9e ff ff ff       	call   800860 <strlen>
	strcpy(dst + len, src);
  8008c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c9:	01 d8                	add    %ebx,%eax
  8008cb:	89 04 24             	mov    %eax,(%esp)
  8008ce:	e8 c0 ff ff ff       	call   800893 <strcpy>
	return dst;
}
  8008d3:	89 d8                	mov    %ebx,%eax
  8008d5:	83 c4 08             	add    $0x8,%esp
  8008d8:	5b                   	pop    %ebx
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ee:	eb 0c                	jmp    8008fc <strncpy+0x21>
		*dst++ = *src;
  8008f0:	8a 1a                	mov    (%edx),%bl
  8008f2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f5:	80 3a 01             	cmpb   $0x1,(%edx)
  8008f8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fb:	41                   	inc    %ecx
  8008fc:	39 f1                	cmp    %esi,%ecx
  8008fe:	75 f0                	jne    8008f0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	56                   	push   %esi
  800908:	53                   	push   %ebx
  800909:	8b 75 08             	mov    0x8(%ebp),%esi
  80090c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800912:	85 d2                	test   %edx,%edx
  800914:	75 0a                	jne    800920 <strlcpy+0x1c>
  800916:	89 f0                	mov    %esi,%eax
  800918:	eb 1a                	jmp    800934 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80091a:	88 18                	mov    %bl,(%eax)
  80091c:	40                   	inc    %eax
  80091d:	41                   	inc    %ecx
  80091e:	eb 02                	jmp    800922 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800920:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800922:	4a                   	dec    %edx
  800923:	74 0a                	je     80092f <strlcpy+0x2b>
  800925:	8a 19                	mov    (%ecx),%bl
  800927:	84 db                	test   %bl,%bl
  800929:	75 ef                	jne    80091a <strlcpy+0x16>
  80092b:	89 c2                	mov    %eax,%edx
  80092d:	eb 02                	jmp    800931 <strlcpy+0x2d>
  80092f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800931:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800934:	29 f0                	sub    %esi,%eax
}
  800936:	5b                   	pop    %ebx
  800937:	5e                   	pop    %esi
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800940:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800943:	eb 02                	jmp    800947 <strcmp+0xd>
		p++, q++;
  800945:	41                   	inc    %ecx
  800946:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800947:	8a 01                	mov    (%ecx),%al
  800949:	84 c0                	test   %al,%al
  80094b:	74 04                	je     800951 <strcmp+0x17>
  80094d:	3a 02                	cmp    (%edx),%al
  80094f:	74 f4                	je     800945 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800951:	0f b6 c0             	movzbl %al,%eax
  800954:	0f b6 12             	movzbl (%edx),%edx
  800957:	29 d0                	sub    %edx,%eax
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	53                   	push   %ebx
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800965:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800968:	eb 03                	jmp    80096d <strncmp+0x12>
		n--, p++, q++;
  80096a:	4a                   	dec    %edx
  80096b:	40                   	inc    %eax
  80096c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80096d:	85 d2                	test   %edx,%edx
  80096f:	74 14                	je     800985 <strncmp+0x2a>
  800971:	8a 18                	mov    (%eax),%bl
  800973:	84 db                	test   %bl,%bl
  800975:	74 04                	je     80097b <strncmp+0x20>
  800977:	3a 19                	cmp    (%ecx),%bl
  800979:	74 ef                	je     80096a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80097b:	0f b6 00             	movzbl (%eax),%eax
  80097e:	0f b6 11             	movzbl (%ecx),%edx
  800981:	29 d0                	sub    %edx,%eax
  800983:	eb 05                	jmp    80098a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800985:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80098a:	5b                   	pop    %ebx
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800996:	eb 05                	jmp    80099d <strchr+0x10>
		if (*s == c)
  800998:	38 ca                	cmp    %cl,%dl
  80099a:	74 0c                	je     8009a8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80099c:	40                   	inc    %eax
  80099d:	8a 10                	mov    (%eax),%dl
  80099f:	84 d2                	test   %dl,%dl
  8009a1:	75 f5                	jne    800998 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009b3:	eb 05                	jmp    8009ba <strfind+0x10>
		if (*s == c)
  8009b5:	38 ca                	cmp    %cl,%dl
  8009b7:	74 07                	je     8009c0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009b9:	40                   	inc    %eax
  8009ba:	8a 10                	mov    (%eax),%dl
  8009bc:	84 d2                	test   %dl,%dl
  8009be:	75 f5                	jne    8009b5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	57                   	push   %edi
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d1:	85 c9                	test   %ecx,%ecx
  8009d3:	74 30                	je     800a05 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009db:	75 25                	jne    800a02 <memset+0x40>
  8009dd:	f6 c1 03             	test   $0x3,%cl
  8009e0:	75 20                	jne    800a02 <memset+0x40>
		c &= 0xFF;
  8009e2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e5:	89 d3                	mov    %edx,%ebx
  8009e7:	c1 e3 08             	shl    $0x8,%ebx
  8009ea:	89 d6                	mov    %edx,%esi
  8009ec:	c1 e6 18             	shl    $0x18,%esi
  8009ef:	89 d0                	mov    %edx,%eax
  8009f1:	c1 e0 10             	shl    $0x10,%eax
  8009f4:	09 f0                	or     %esi,%eax
  8009f6:	09 d0                	or     %edx,%eax
  8009f8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009fa:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009fd:	fc                   	cld    
  8009fe:	f3 ab                	rep stos %eax,%es:(%edi)
  800a00:	eb 03                	jmp    800a05 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a02:	fc                   	cld    
  800a03:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a05:	89 f8                	mov    %edi,%eax
  800a07:	5b                   	pop    %ebx
  800a08:	5e                   	pop    %esi
  800a09:	5f                   	pop    %edi
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	57                   	push   %edi
  800a10:	56                   	push   %esi
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a17:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a1a:	39 c6                	cmp    %eax,%esi
  800a1c:	73 34                	jae    800a52 <memmove+0x46>
  800a1e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a21:	39 d0                	cmp    %edx,%eax
  800a23:	73 2d                	jae    800a52 <memmove+0x46>
		s += n;
		d += n;
  800a25:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a28:	f6 c2 03             	test   $0x3,%dl
  800a2b:	75 1b                	jne    800a48 <memmove+0x3c>
  800a2d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a33:	75 13                	jne    800a48 <memmove+0x3c>
  800a35:	f6 c1 03             	test   $0x3,%cl
  800a38:	75 0e                	jne    800a48 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a3a:	83 ef 04             	sub    $0x4,%edi
  800a3d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a40:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a43:	fd                   	std    
  800a44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a46:	eb 07                	jmp    800a4f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a48:	4f                   	dec    %edi
  800a49:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a4c:	fd                   	std    
  800a4d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4f:	fc                   	cld    
  800a50:	eb 20                	jmp    800a72 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a52:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a58:	75 13                	jne    800a6d <memmove+0x61>
  800a5a:	a8 03                	test   $0x3,%al
  800a5c:	75 0f                	jne    800a6d <memmove+0x61>
  800a5e:	f6 c1 03             	test   $0x3,%cl
  800a61:	75 0a                	jne    800a6d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a63:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a66:	89 c7                	mov    %eax,%edi
  800a68:	fc                   	cld    
  800a69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6b:	eb 05                	jmp    800a72 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a6d:	89 c7                	mov    %eax,%edi
  800a6f:	fc                   	cld    
  800a70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a72:	5e                   	pop    %esi
  800a73:	5f                   	pop    %edi
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	89 04 24             	mov    %eax,(%esp)
  800a90:	e8 77 ff ff ff       	call   800a0c <memmove>
}
  800a95:	c9                   	leave  
  800a96:	c3                   	ret    

00800a97 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	57                   	push   %edi
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa6:	ba 00 00 00 00       	mov    $0x0,%edx
  800aab:	eb 16                	jmp    800ac3 <memcmp+0x2c>
		if (*s1 != *s2)
  800aad:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ab0:	42                   	inc    %edx
  800ab1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800ab5:	38 c8                	cmp    %cl,%al
  800ab7:	74 0a                	je     800ac3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ab9:	0f b6 c0             	movzbl %al,%eax
  800abc:	0f b6 c9             	movzbl %cl,%ecx
  800abf:	29 c8                	sub    %ecx,%eax
  800ac1:	eb 09                	jmp    800acc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac3:	39 da                	cmp    %ebx,%edx
  800ac5:	75 e6                	jne    800aad <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ac7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ada:	89 c2                	mov    %eax,%edx
  800adc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800adf:	eb 05                	jmp    800ae6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae1:	38 08                	cmp    %cl,(%eax)
  800ae3:	74 05                	je     800aea <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae5:	40                   	inc    %eax
  800ae6:	39 d0                	cmp    %edx,%eax
  800ae8:	72 f7                	jb     800ae1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	8b 55 08             	mov    0x8(%ebp),%edx
  800af5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af8:	eb 01                	jmp    800afb <strtol+0xf>
		s++;
  800afa:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800afb:	8a 02                	mov    (%edx),%al
  800afd:	3c 20                	cmp    $0x20,%al
  800aff:	74 f9                	je     800afa <strtol+0xe>
  800b01:	3c 09                	cmp    $0x9,%al
  800b03:	74 f5                	je     800afa <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b05:	3c 2b                	cmp    $0x2b,%al
  800b07:	75 08                	jne    800b11 <strtol+0x25>
		s++;
  800b09:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b0a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0f:	eb 13                	jmp    800b24 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b11:	3c 2d                	cmp    $0x2d,%al
  800b13:	75 0a                	jne    800b1f <strtol+0x33>
		s++, neg = 1;
  800b15:	8d 52 01             	lea    0x1(%edx),%edx
  800b18:	bf 01 00 00 00       	mov    $0x1,%edi
  800b1d:	eb 05                	jmp    800b24 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b1f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b24:	85 db                	test   %ebx,%ebx
  800b26:	74 05                	je     800b2d <strtol+0x41>
  800b28:	83 fb 10             	cmp    $0x10,%ebx
  800b2b:	75 28                	jne    800b55 <strtol+0x69>
  800b2d:	8a 02                	mov    (%edx),%al
  800b2f:	3c 30                	cmp    $0x30,%al
  800b31:	75 10                	jne    800b43 <strtol+0x57>
  800b33:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b37:	75 0a                	jne    800b43 <strtol+0x57>
		s += 2, base = 16;
  800b39:	83 c2 02             	add    $0x2,%edx
  800b3c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b41:	eb 12                	jmp    800b55 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b43:	85 db                	test   %ebx,%ebx
  800b45:	75 0e                	jne    800b55 <strtol+0x69>
  800b47:	3c 30                	cmp    $0x30,%al
  800b49:	75 05                	jne    800b50 <strtol+0x64>
		s++, base = 8;
  800b4b:	42                   	inc    %edx
  800b4c:	b3 08                	mov    $0x8,%bl
  800b4e:	eb 05                	jmp    800b55 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b50:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b55:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b5c:	8a 0a                	mov    (%edx),%cl
  800b5e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b61:	80 fb 09             	cmp    $0x9,%bl
  800b64:	77 08                	ja     800b6e <strtol+0x82>
			dig = *s - '0';
  800b66:	0f be c9             	movsbl %cl,%ecx
  800b69:	83 e9 30             	sub    $0x30,%ecx
  800b6c:	eb 1e                	jmp    800b8c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b6e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b71:	80 fb 19             	cmp    $0x19,%bl
  800b74:	77 08                	ja     800b7e <strtol+0x92>
			dig = *s - 'a' + 10;
  800b76:	0f be c9             	movsbl %cl,%ecx
  800b79:	83 e9 57             	sub    $0x57,%ecx
  800b7c:	eb 0e                	jmp    800b8c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b7e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b81:	80 fb 19             	cmp    $0x19,%bl
  800b84:	77 12                	ja     800b98 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b86:	0f be c9             	movsbl %cl,%ecx
  800b89:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b8c:	39 f1                	cmp    %esi,%ecx
  800b8e:	7d 0c                	jge    800b9c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b90:	42                   	inc    %edx
  800b91:	0f af c6             	imul   %esi,%eax
  800b94:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b96:	eb c4                	jmp    800b5c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b98:	89 c1                	mov    %eax,%ecx
  800b9a:	eb 02                	jmp    800b9e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b9c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b9e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba2:	74 05                	je     800ba9 <strtol+0xbd>
		*endptr = (char *) s;
  800ba4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ba7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ba9:	85 ff                	test   %edi,%edi
  800bab:	74 04                	je     800bb1 <strtol+0xc5>
  800bad:	89 c8                	mov    %ecx,%eax
  800baf:	f7 d8                	neg    %eax
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    
	...

00800bb8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	89 c3                	mov    %eax,%ebx
  800bcb:	89 c7                	mov    %eax,%edi
  800bcd:	89 c6                	mov    %eax,%esi
  800bcf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_cgetc>:

int
sys_cgetc(void)
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
  800be1:	b8 01 00 00 00       	mov    $0x1,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800bfe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c03:	b8 03 00 00 00       	mov    $0x3,%eax
  800c08:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0b:	89 cb                	mov    %ecx,%ebx
  800c0d:	89 cf                	mov    %ecx,%edi
  800c0f:	89 ce                	mov    %ecx,%esi
  800c11:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c13:	85 c0                	test   %eax,%eax
  800c15:	7e 28                	jle    800c3f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c1b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c22:	00 
  800c23:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  800c2a:	00 
  800c2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c32:	00 
  800c33:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  800c3a:	e8 25 0c 00 00       	call   801864 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c3f:	83 c4 2c             	add    $0x2c,%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c52:	b8 02 00 00 00       	mov    $0x2,%eax
  800c57:	89 d1                	mov    %edx,%ecx
  800c59:	89 d3                	mov    %edx,%ebx
  800c5b:	89 d7                	mov    %edx,%edi
  800c5d:	89 d6                	mov    %edx,%esi
  800c5f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <sys_yield>:

void
sys_yield(void)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c71:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c76:	89 d1                	mov    %edx,%ecx
  800c78:	89 d3                	mov    %edx,%ebx
  800c7a:	89 d7                	mov    %edx,%edi
  800c7c:	89 d6                	mov    %edx,%esi
  800c7e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	be 00 00 00 00       	mov    $0x0,%esi
  800c93:	b8 04 00 00 00       	mov    $0x4,%eax
  800c98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	89 f7                	mov    %esi,%edi
  800ca3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	7e 28                	jle    800cd1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cad:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cb4:	00 
  800cb5:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  800cbc:	00 
  800cbd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc4:	00 
  800cc5:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  800ccc:	e8 93 0b 00 00       	call   801864 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd1:	83 c4 2c             	add    $0x2c,%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce2:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce7:	8b 75 18             	mov    0x18(%ebp),%esi
  800cea:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ced:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	7e 28                	jle    800d24 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d00:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d07:	00 
  800d08:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  800d0f:	00 
  800d10:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d17:	00 
  800d18:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  800d1f:	e8 40 0b 00 00       	call   801864 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d24:	83 c4 2c             	add    $0x2c,%esp
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800d35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	89 df                	mov    %ebx,%edi
  800d47:	89 de                	mov    %ebx,%esi
  800d49:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	7e 28                	jle    800d77 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d53:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d5a:	00 
  800d5b:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  800d62:	00 
  800d63:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6a:	00 
  800d6b:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  800d72:	e8 ed 0a 00 00       	call   801864 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d77:	83 c4 2c             	add    $0x2c,%esp
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	57                   	push   %edi
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
  800d85:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	8b 55 08             	mov    0x8(%ebp),%edx
  800d98:	89 df                	mov    %ebx,%edi
  800d9a:	89 de                	mov    %ebx,%esi
  800d9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	7e 28                	jle    800dca <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dad:	00 
  800dae:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  800db5:	00 
  800db6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbd:	00 
  800dbe:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  800dc5:	e8 9a 0a 00 00       	call   801864 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dca:	83 c4 2c             	add    $0x2c,%esp
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de0:	b8 09 00 00 00       	mov    $0x9,%eax
  800de5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de8:	8b 55 08             	mov    0x8(%ebp),%edx
  800deb:	89 df                	mov    %ebx,%edi
  800ded:	89 de                	mov    %ebx,%esi
  800def:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df1:	85 c0                	test   %eax,%eax
  800df3:	7e 28                	jle    800e1d <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e00:	00 
  800e01:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  800e08:	00 
  800e09:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e10:	00 
  800e11:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  800e18:	e8 47 0a 00 00       	call   801864 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e1d:	83 c4 2c             	add    $0x2c,%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2b:	be 00 00 00 00       	mov    $0x0,%esi
  800e30:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e35:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e41:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	57                   	push   %edi
  800e4c:	56                   	push   %esi
  800e4d:	53                   	push   %ebx
  800e4e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e51:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e56:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5e:	89 cb                	mov    %ecx,%ebx
  800e60:	89 cf                	mov    %ecx,%edi
  800e62:	89 ce                	mov    %ecx,%esi
  800e64:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e66:	85 c0                	test   %eax,%eax
  800e68:	7e 28                	jle    800e92 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e75:	00 
  800e76:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  800e7d:	00 
  800e7e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e85:	00 
  800e86:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  800e8d:	e8 d2 09 00 00       	call   801864 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e92:	83 c4 2c             	add    $0x2c,%esp
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5f                   	pop    %edi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <sys_env_set_divzero_upcall>:

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	57                   	push   %edi
  800e9e:	56                   	push   %esi
  800e9f:	53                   	push   %ebx
  800ea0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ead:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb3:	89 df                	mov    %ebx,%edi
  800eb5:	89 de                	mov    %ebx,%esi
  800eb7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	7e 28                	jle    800ee5 <sys_env_set_divzero_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed8:	00 
  800ed9:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  800ee0:	e8 7f 09 00 00       	call   801864 <_panic>
}

int
sys_env_set_divzero_upcall(envid_t envid, void *upcall) {
	return syscall(SYS_env_set_divzero_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800ee5:	83 c4 2c             	add    $0x2c,%esp
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	5f                   	pop    %edi
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <sys_env_set_debug_upcall>:

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	57                   	push   %edi
  800ef1:	56                   	push   %esi
  800ef2:	53                   	push   %ebx
  800ef3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efb:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f03:	8b 55 08             	mov    0x8(%ebp),%edx
  800f06:	89 df                	mov    %ebx,%edi
  800f08:	89 de                	mov    %ebx,%esi
  800f0a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	7e 28                	jle    800f38 <sys_env_set_debug_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f14:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800f1b:	00 
  800f1c:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  800f23:	00 
  800f24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2b:	00 
  800f2c:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  800f33:	e8 2c 09 00 00       	call   801864 <_panic>
}

int
sys_env_set_debug_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_debug_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800f38:	83 c4 2c             	add    $0x2c,%esp
  800f3b:	5b                   	pop    %ebx
  800f3c:	5e                   	pop    %esi
  800f3d:	5f                   	pop    %edi
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <sys_env_set_nmskint_upcall>:

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
  800f46:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f4e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f56:	8b 55 08             	mov    0x8(%ebp),%edx
  800f59:	89 df                	mov    %ebx,%edi
  800f5b:	89 de                	mov    %ebx,%esi
  800f5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	7e 28                	jle    800f8b <sys_env_set_nmskint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f63:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f67:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800f6e:	00 
  800f6f:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  800f76:	00 
  800f77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7e:	00 
  800f7f:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  800f86:	e8 d9 08 00 00       	call   801864 <_panic>
}

int
sys_env_set_nmskint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_nmskint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800f8b:	83 c4 2c             	add    $0x2c,%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5f                   	pop    %edi
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <sys_env_set_bpoint_upcall>:

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	57                   	push   %edi
  800f97:	56                   	push   %esi
  800f98:	53                   	push   %ebx
  800f99:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa1:	b8 10 00 00 00       	mov    $0x10,%eax
  800fa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fac:	89 df                	mov    %ebx,%edi
  800fae:	89 de                	mov    %ebx,%esi
  800fb0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	7e 28                	jle    800fde <sys_env_set_bpoint_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fba:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800fc1:	00 
  800fc2:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  800fc9:	00 
  800fca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd1:	00 
  800fd2:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  800fd9:	e8 86 08 00 00       	call   801864 <_panic>
}

int
sys_env_set_bpoint_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bpoint_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800fde:	83 c4 2c             	add    $0x2c,%esp
  800fe1:	5b                   	pop    %ebx
  800fe2:	5e                   	pop    %esi
  800fe3:	5f                   	pop    %edi
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    

00800fe6 <sys_env_set_oflow_upcall>:

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	57                   	push   %edi
  800fea:	56                   	push   %esi
  800feb:	53                   	push   %ebx
  800fec:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fef:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff4:	b8 11 00 00 00       	mov    $0x11,%eax
  800ff9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fff:	89 df                	mov    %ebx,%edi
  801001:	89 de                	mov    %ebx,%esi
  801003:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801005:	85 c0                	test   %eax,%eax
  801007:	7e 28                	jle    801031 <sys_env_set_oflow_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801009:	89 44 24 10          	mov    %eax,0x10(%esp)
  80100d:	c7 44 24 0c 11 00 00 	movl   $0x11,0xc(%esp)
  801014:	00 
  801015:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  80101c:	00 
  80101d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801024:	00 
  801025:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  80102c:	e8 33 08 00 00       	call   801864 <_panic>
}

int
sys_env_set_oflow_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_oflow_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801031:	83 c4 2c             	add    $0x2c,%esp
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <sys_env_set_bdschk_upcall>:

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	57                   	push   %edi
  80103d:	56                   	push   %esi
  80103e:	53                   	push   %ebx
  80103f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801042:	bb 00 00 00 00       	mov    $0x0,%ebx
  801047:	b8 12 00 00 00       	mov    $0x12,%eax
  80104c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104f:	8b 55 08             	mov    0x8(%ebp),%edx
  801052:	89 df                	mov    %ebx,%edi
  801054:	89 de                	mov    %ebx,%esi
  801056:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801058:	85 c0                	test   %eax,%eax
  80105a:	7e 28                	jle    801084 <sys_env_set_bdschk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80105c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801060:	c7 44 24 0c 12 00 00 	movl   $0x12,0xc(%esp)
  801067:	00 
  801068:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  80106f:	00 
  801070:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801077:	00 
  801078:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  80107f:	e8 e0 07 00 00       	call   801864 <_panic>
}

int
sys_env_set_bdschk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_bdschk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801084:	83 c4 2c             	add    $0x2c,%esp
  801087:	5b                   	pop    %ebx
  801088:	5e                   	pop    %esi
  801089:	5f                   	pop    %edi
  80108a:	5d                   	pop    %ebp
  80108b:	c3                   	ret    

0080108c <sys_env_set_illopcd_upcall>:

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	57                   	push   %edi
  801090:	56                   	push   %esi
  801091:	53                   	push   %ebx
  801092:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801095:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109a:	b8 13 00 00 00       	mov    $0x13,%eax
  80109f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a5:	89 df                	mov    %ebx,%edi
  8010a7:	89 de                	mov    %ebx,%esi
  8010a9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	7e 28                	jle    8010d7 <sys_env_set_illopcd_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010af:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b3:	c7 44 24 0c 13 00 00 	movl   $0x13,0xc(%esp)
  8010ba:	00 
  8010bb:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  8010c2:	00 
  8010c3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010ca:	00 
  8010cb:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  8010d2:	e8 8d 07 00 00       	call   801864 <_panic>
}

int
sys_env_set_illopcd_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_illopcd_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8010d7:	83 c4 2c             	add    $0x2c,%esp
  8010da:	5b                   	pop    %ebx
  8010db:	5e                   	pop    %esi
  8010dc:	5f                   	pop    %edi
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <sys_env_set_dvcntavl_upcall>:

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	57                   	push   %edi
  8010e3:	56                   	push   %esi
  8010e4:	53                   	push   %ebx
  8010e5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ed:	b8 14 00 00 00       	mov    $0x14,%eax
  8010f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f8:	89 df                	mov    %ebx,%edi
  8010fa:	89 de                	mov    %ebx,%esi
  8010fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010fe:	85 c0                	test   %eax,%eax
  801100:	7e 28                	jle    80112a <sys_env_set_dvcntavl_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801102:	89 44 24 10          	mov    %eax,0x10(%esp)
  801106:	c7 44 24 0c 14 00 00 	movl   $0x14,0xc(%esp)
  80110d:	00 
  80110e:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  801115:	00 
  801116:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80111d:	00 
  80111e:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  801125:	e8 3a 07 00 00       	call   801864 <_panic>
}

int
sys_env_set_dvcntavl_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dvcntavl_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80112a:	83 c4 2c             	add    $0x2c,%esp
  80112d:	5b                   	pop    %ebx
  80112e:	5e                   	pop    %esi
  80112f:	5f                   	pop    %edi
  801130:	5d                   	pop    %ebp
  801131:	c3                   	ret    

00801132 <sys_env_set_dbfault_upcall>:

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	57                   	push   %edi
  801136:	56                   	push   %esi
  801137:	53                   	push   %ebx
  801138:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801140:	b8 15 00 00 00       	mov    $0x15,%eax
  801145:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801148:	8b 55 08             	mov    0x8(%ebp),%edx
  80114b:	89 df                	mov    %ebx,%edi
  80114d:	89 de                	mov    %ebx,%esi
  80114f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801151:	85 c0                	test   %eax,%eax
  801153:	7e 28                	jle    80117d <sys_env_set_dbfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801155:	89 44 24 10          	mov    %eax,0x10(%esp)
  801159:	c7 44 24 0c 15 00 00 	movl   $0x15,0xc(%esp)
  801160:	00 
  801161:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  801168:	00 
  801169:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801170:	00 
  801171:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  801178:	e8 e7 06 00 00       	call   801864 <_panic>
}

int
sys_env_set_dbfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_dbfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80117d:	83 c4 2c             	add    $0x2c,%esp
  801180:	5b                   	pop    %ebx
  801181:	5e                   	pop    %esi
  801182:	5f                   	pop    %edi
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    

00801185 <sys_env_set_ivldtss_upcall>:

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	57                   	push   %edi
  801189:	56                   	push   %esi
  80118a:	53                   	push   %ebx
  80118b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80118e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801193:	b8 16 00 00 00       	mov    $0x16,%eax
  801198:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119b:	8b 55 08             	mov    0x8(%ebp),%edx
  80119e:	89 df                	mov    %ebx,%edi
  8011a0:	89 de                	mov    %ebx,%esi
  8011a2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	7e 28                	jle    8011d0 <sys_env_set_ivldtss_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ac:	c7 44 24 0c 16 00 00 	movl   $0x16,0xc(%esp)
  8011b3:	00 
  8011b4:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  8011bb:	00 
  8011bc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c3:	00 
  8011c4:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  8011cb:	e8 94 06 00 00       	call   801864 <_panic>
}

int
sys_env_set_ivldtss_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_ivldtss_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8011d0:	83 c4 2c             	add    $0x2c,%esp
  8011d3:	5b                   	pop    %ebx
  8011d4:	5e                   	pop    %esi
  8011d5:	5f                   	pop    %edi
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    

008011d8 <sys_env_set_segntprst_upcall>:

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	57                   	push   %edi
  8011dc:	56                   	push   %esi
  8011dd:	53                   	push   %ebx
  8011de:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e6:	b8 17 00 00 00       	mov    $0x17,%eax
  8011eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f1:	89 df                	mov    %ebx,%edi
  8011f3:	89 de                	mov    %ebx,%esi
  8011f5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	7e 28                	jle    801223 <sys_env_set_segntprst_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011fb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ff:	c7 44 24 0c 17 00 00 	movl   $0x17,0xc(%esp)
  801206:	00 
  801207:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  80120e:	00 
  80120f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801216:	00 
  801217:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  80121e:	e8 41 06 00 00       	call   801864 <_panic>
}

int
sys_env_set_segntprst_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_segntprst_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801223:	83 c4 2c             	add    $0x2c,%esp
  801226:	5b                   	pop    %ebx
  801227:	5e                   	pop    %esi
  801228:	5f                   	pop    %edi
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    

0080122b <sys_env_set_stkexception_upcall>:

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	57                   	push   %edi
  80122f:	56                   	push   %esi
  801230:	53                   	push   %ebx
  801231:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801234:	bb 00 00 00 00       	mov    $0x0,%ebx
  801239:	b8 18 00 00 00       	mov    $0x18,%eax
  80123e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801241:	8b 55 08             	mov    0x8(%ebp),%edx
  801244:	89 df                	mov    %ebx,%edi
  801246:	89 de                	mov    %ebx,%esi
  801248:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80124a:	85 c0                	test   %eax,%eax
  80124c:	7e 28                	jle    801276 <sys_env_set_stkexception_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80124e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801252:	c7 44 24 0c 18 00 00 	movl   $0x18,0xc(%esp)
  801259:	00 
  80125a:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  801261:	00 
  801262:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801269:	00 
  80126a:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  801271:	e8 ee 05 00 00       	call   801864 <_panic>
}

int
sys_env_set_stkexception_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_stkexception_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801276:	83 c4 2c             	add    $0x2c,%esp
  801279:	5b                   	pop    %ebx
  80127a:	5e                   	pop    %esi
  80127b:	5f                   	pop    %edi
  80127c:	5d                   	pop    %ebp
  80127d:	c3                   	ret    

0080127e <sys_env_set_gpfault_upcall>:

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	57                   	push   %edi
  801282:	56                   	push   %esi
  801283:	53                   	push   %ebx
  801284:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801287:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128c:	b8 19 00 00 00       	mov    $0x19,%eax
  801291:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801294:	8b 55 08             	mov    0x8(%ebp),%edx
  801297:	89 df                	mov    %ebx,%edi
  801299:	89 de                	mov    %ebx,%esi
  80129b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80129d:	85 c0                	test   %eax,%eax
  80129f:	7e 28                	jle    8012c9 <sys_env_set_gpfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012a5:	c7 44 24 0c 19 00 00 	movl   $0x19,0xc(%esp)
  8012ac:	00 
  8012ad:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  8012b4:	00 
  8012b5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012bc:	00 
  8012bd:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  8012c4:	e8 9b 05 00 00       	call   801864 <_panic>
}

int
sys_env_set_gpfault_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_gpfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8012c9:	83 c4 2c             	add    $0x2c,%esp
  8012cc:	5b                   	pop    %ebx
  8012cd:	5e                   	pop    %esi
  8012ce:	5f                   	pop    %edi
  8012cf:	5d                   	pop    %ebp
  8012d0:	c3                   	ret    

008012d1 <sys_env_set_fperror_upcall>:

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
  8012d1:	55                   	push   %ebp
  8012d2:	89 e5                	mov    %esp,%ebp
  8012d4:	57                   	push   %edi
  8012d5:	56                   	push   %esi
  8012d6:	53                   	push   %ebx
  8012d7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012df:	b8 1a 00 00 00       	mov    $0x1a,%eax
  8012e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ea:	89 df                	mov    %ebx,%edi
  8012ec:	89 de                	mov    %ebx,%esi
  8012ee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	7e 28                	jle    80131c <sys_env_set_fperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012f8:	c7 44 24 0c 1a 00 00 	movl   $0x1a,0xc(%esp)
  8012ff:	00 
  801300:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  801307:	00 
  801308:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80130f:	00 
  801310:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  801317:	e8 48 05 00 00       	call   801864 <_panic>
}

int
sys_env_set_fperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_fperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80131c:	83 c4 2c             	add    $0x2c,%esp
  80131f:	5b                   	pop    %ebx
  801320:	5e                   	pop    %esi
  801321:	5f                   	pop    %edi
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    

00801324 <sys_env_set_algchk_upcall>:

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	57                   	push   %edi
  801328:	56                   	push   %esi
  801329:	53                   	push   %ebx
  80132a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80132d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801332:	b8 1b 00 00 00       	mov    $0x1b,%eax
  801337:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133a:	8b 55 08             	mov    0x8(%ebp),%edx
  80133d:	89 df                	mov    %ebx,%edi
  80133f:	89 de                	mov    %ebx,%esi
  801341:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801343:	85 c0                	test   %eax,%eax
  801345:	7e 28                	jle    80136f <sys_env_set_algchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801347:	89 44 24 10          	mov    %eax,0x10(%esp)
  80134b:	c7 44 24 0c 1b 00 00 	movl   $0x1b,0xc(%esp)
  801352:	00 
  801353:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  80135a:	00 
  80135b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801362:	00 
  801363:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  80136a:	e8 f5 04 00 00       	call   801864 <_panic>
}

int
sys_env_set_algchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_algchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80136f:	83 c4 2c             	add    $0x2c,%esp
  801372:	5b                   	pop    %ebx
  801373:	5e                   	pop    %esi
  801374:	5f                   	pop    %edi
  801375:	5d                   	pop    %ebp
  801376:	c3                   	ret    

00801377 <sys_env_set_mchchk_upcall>:

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	57                   	push   %edi
  80137b:	56                   	push   %esi
  80137c:	53                   	push   %ebx
  80137d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801380:	bb 00 00 00 00       	mov    $0x0,%ebx
  801385:	b8 1c 00 00 00       	mov    $0x1c,%eax
  80138a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80138d:	8b 55 08             	mov    0x8(%ebp),%edx
  801390:	89 df                	mov    %ebx,%edi
  801392:	89 de                	mov    %ebx,%esi
  801394:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801396:	85 c0                	test   %eax,%eax
  801398:	7e 28                	jle    8013c2 <sys_env_set_mchchk_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80139a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80139e:	c7 44 24 0c 1c 00 00 	movl   $0x1c,0xc(%esp)
  8013a5:	00 
  8013a6:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  8013ad:	00 
  8013ae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013b5:	00 
  8013b6:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  8013bd:	e8 a2 04 00 00       	call   801864 <_panic>
}

int
sys_env_set_mchchk_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_mchchk_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8013c2:	83 c4 2c             	add    $0x2c,%esp
  8013c5:	5b                   	pop    %ebx
  8013c6:	5e                   	pop    %esi
  8013c7:	5f                   	pop    %edi
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    

008013ca <sys_env_set_SIMDfperror_upcall>:

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	57                   	push   %edi
  8013ce:	56                   	push   %esi
  8013cf:	53                   	push   %ebx
  8013d0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d8:	b8 1d 00 00 00       	mov    $0x1d,%eax
  8013dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8013e3:	89 df                	mov    %ebx,%edi
  8013e5:	89 de                	mov    %ebx,%esi
  8013e7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	7e 28                	jle    801415 <sys_env_set_SIMDfperror_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013f1:	c7 44 24 0c 1d 00 00 	movl   $0x1d,0xc(%esp)
  8013f8:	00 
  8013f9:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  801400:	00 
  801401:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801408:	00 
  801409:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  801410:	e8 4f 04 00 00       	call   801864 <_panic>
}

int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *upcall) {
    return syscall(SYS_env_set_SIMDfperror_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  801415:	83 c4 2c             	add    $0x2c,%esp
  801418:	5b                   	pop    %ebx
  801419:	5e                   	pop    %esi
  80141a:	5f                   	pop    %edi
  80141b:	5d                   	pop    %ebp
  80141c:	c3                   	ret    
  80141d:	00 00                	add    %al,(%eax)
	...

00801420 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	53                   	push   %ebx
  801424:	83 ec 24             	sub    $0x24,%esp
  801427:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80142a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  80142c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801430:	74 2d                	je     80145f <pgfault+0x3f>
  801432:	89 d8                	mov    %ebx,%eax
  801434:	c1 e8 16             	shr    $0x16,%eax
  801437:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80143e:	a8 01                	test   $0x1,%al
  801440:	74 1d                	je     80145f <pgfault+0x3f>
		(uvpt[PGNUM(addr)] & PTE_P) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  801442:	89 d8                	mov    %ebx,%eax
  801444:	c1 e8 0c             	shr    $0xc,%eax
  801447:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  80144e:	f6 c2 01             	test   $0x1,%dl
  801451:	74 0c                	je     80145f <pgfault+0x3f>
		(uvpt[PGNUM(addr)] & PTE_P) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  801453:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80145a:	f6 c4 08             	test   $0x8,%ah
  80145d:	75 1c                	jne    80147b <pgfault+0x5b>
		panic("pgfault: not a write or a copy on write page fault!");
  80145f:	c7 44 24 08 14 1f 80 	movl   $0x801f14,0x8(%esp)
  801466:	00 
  801467:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  80146e:	00 
  80146f:	c7 04 24 48 1f 80 00 	movl   $0x801f48,(%esp)
  801476:	e8 e9 03 00 00       	call   801864 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	// we need to make addr page-aligned
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)) < 0)
  80147b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801482:	00 
  801483:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80148a:	00 
  80148b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801492:	e8 ee f7 ff ff       	call   800c85 <sys_page_alloc>
  801497:	85 c0                	test   %eax,%eax
  801499:	79 20                	jns    8014bb <pgfault+0x9b>
		panic("pgfault: sys_page_alloc: %e", r);
  80149b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80149f:	c7 44 24 08 53 1f 80 	movl   $0x801f53,0x8(%esp)
  8014a6:	00 
  8014a7:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8014ae:	00 
  8014af:	c7 04 24 48 1f 80 00 	movl   $0x801f48,(%esp)
  8014b6:	e8 a9 03 00 00       	call   801864 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// we need to make addr page-aligned
	addr = ROUNDDOWN(addr, PGSIZE);
  8014bb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)) < 0)
		panic("pgfault: sys_page_alloc: %e", r);
	memcpy(PFTEMP, addr, PGSIZE);
  8014c1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8014c8:	00 
  8014c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014cd:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8014d4:	e8 9d f5 ff ff       	call   800a76 <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P)) < 0)
  8014d9:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8014e0:	00 
  8014e1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8014e5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014ec:	00 
  8014ed:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014f4:	00 
  8014f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014fc:	e8 d8 f7 ff ff       	call   800cd9 <sys_page_map>
  801501:	85 c0                	test   %eax,%eax
  801503:	79 20                	jns    801525 <pgfault+0x105>
		panic("pgfault: sys_page_map: %e", r);
  801505:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801509:	c7 44 24 08 6f 1f 80 	movl   $0x801f6f,0x8(%esp)
  801510:	00 
  801511:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801518:	00 
  801519:	c7 04 24 48 1f 80 00 	movl   $0x801f48,(%esp)
  801520:	e8 3f 03 00 00       	call   801864 <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801525:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80152c:	00 
  80152d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801534:	e8 f3 f7 ff ff       	call   800d2c <sys_page_unmap>
  801539:	85 c0                	test   %eax,%eax
  80153b:	79 20                	jns    80155d <pgfault+0x13d>
		panic("pgfault: sys_page_unmap: %e", r);
  80153d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801541:	c7 44 24 08 89 1f 80 	movl   $0x801f89,0x8(%esp)
  801548:	00 
  801549:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801550:	00 
  801551:	c7 04 24 48 1f 80 00 	movl   $0x801f48,(%esp)
  801558:	e8 07 03 00 00       	call   801864 <_panic>
}
  80155d:	83 c4 24             	add    $0x24,%esp
  801560:	5b                   	pop    %ebx
  801561:	5d                   	pop    %ebp
  801562:	c3                   	ret    

00801563 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	57                   	push   %edi
  801567:	56                   	push   %esi
  801568:	53                   	push   %ebx
  801569:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80156c:	c7 04 24 20 14 80 00 	movl   $0x801420,(%esp)
  801573:	e8 44 03 00 00       	call   8018bc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801578:	ba 07 00 00 00       	mov    $0x7,%edx
  80157d:	89 d0                	mov    %edx,%eax
  80157f:	cd 30                	int    $0x30
  801581:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801584:	89 c7                	mov    %eax,%edi
	envid_t envid;
	uint8_t *addr;
	int r;
	extern unsigned char end[];
	envid = sys_exofork();
	if (envid < 0)
  801586:	85 c0                	test   %eax,%eax
  801588:	79 20                	jns    8015aa <fork+0x47>
		panic("sys_exofork: %e", envid);
  80158a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80158e:	c7 44 24 08 a5 1f 80 	movl   $0x801fa5,0x8(%esp)
  801595:	00 
  801596:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  80159d:	00 
  80159e:	c7 04 24 48 1f 80 00 	movl   $0x801f48,(%esp)
  8015a5:	e8 ba 02 00 00       	call   801864 <_panic>
	if (envid == 0) {
  8015aa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8015ae:	75 27                	jne    8015d7 <fork+0x74>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8015b0:	e8 92 f6 ff ff       	call   800c47 <sys_getenvid>
  8015b5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015ba:	8d 04 40             	lea    (%eax,%eax,2),%eax
  8015bd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8015c0:	c1 e0 04             	shl    $0x4,%eax
  8015c3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8015c8:	a3 10 30 80 00       	mov    %eax,0x803010
		return 0;
  8015cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d2:	e9 23 01 00 00       	jmp    8016fa <fork+0x197>
	int r;
	extern unsigned char end[];
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8015d7:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	}

	// We're the parent.
	for (addr = 0; addr < (uint8_t *)USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  8015dc:	89 d8                	mov    %ebx,%eax
  8015de:	c1 e8 16             	shr    $0x16,%eax
  8015e1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015e8:	a8 01                	test   $0x1,%al
  8015ea:	0f 84 ac 00 00 00    	je     80169c <fork+0x139>
  8015f0:	89 d8                	mov    %ebx,%eax
  8015f2:	c1 e8 0c             	shr    $0xc,%eax
  8015f5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015fc:	f6 c2 01             	test   $0x1,%dl
  8015ff:	0f 84 97 00 00 00    	je     80169c <fork+0x139>
			&& (uvpt[PGNUM(addr)] & PTE_U))
  801605:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80160c:	f6 c2 04             	test   $0x4,%dl
  80160f:	0f 84 87 00 00 00    	je     80169c <fork+0x139>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	void *va = (void *)(pn * PGSIZE);
  801615:	89 c6                	mov    %eax,%esi
  801617:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  80161a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801621:	f6 c2 02             	test   $0x2,%dl
  801624:	75 0c                	jne    801632 <fork+0xcf>
  801626:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80162d:	f6 c4 08             	test   $0x8,%ah
  801630:	74 4a                	je     80167c <fork+0x119>
		if ((r = sys_page_map(0, va, envid, va, PTE_COW|PTE_U|PTE_P)) < 0)
  801632:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801639:	00 
  80163a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80163e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801642:	89 74 24 04          	mov    %esi,0x4(%esp)
  801646:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80164d:	e8 87 f6 ff ff       	call   800cd9 <sys_page_map>
  801652:	85 c0                	test   %eax,%eax
  801654:	78 46                	js     80169c <fork+0x139>
			return r;
		if ((r = sys_page_map(0, va, 0, va, PTE_COW|PTE_U|PTE_P)) < 0)
  801656:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80165d:	00 
  80165e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801662:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801669:	00 
  80166a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80166e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801675:	e8 5f f6 ff ff       	call   800cd9 <sys_page_map>
  80167a:	eb 20                	jmp    80169c <fork+0x139>
			return r;
	}
	else {
		if ((r = sys_page_map(0, va, envid, va, PTE_U|PTE_P)) < 0)
  80167c:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801683:	00 
  801684:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801688:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80168c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801690:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801697:	e8 3d f6 ff ff       	call   800cd9 <sys_page_map>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	// We're the parent.
	for (addr = 0; addr < (uint8_t *)USTACKTOP; addr += PGSIZE)
  80169c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8016a2:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8016a8:	0f 85 2e ff ff ff    	jne    8015dc <fork+0x79>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
			&& (uvpt[PGNUM(addr)] & PTE_U))
			duppage(envid, PGNUM(addr));

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  8016ae:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8016b5:	00 
  8016b6:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8016bd:	ee 
  8016be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016c1:	89 04 24             	mov    %eax,(%esp)
  8016c4:	e8 bc f5 ff ff       	call   800c85 <sys_page_alloc>
  8016c9:	85 c0                	test   %eax,%eax
  8016cb:	78 2d                	js     8016fa <fork+0x197>
		return r;
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8016cd:	c7 44 24 04 50 19 80 	movl   $0x801950,0x4(%esp)
  8016d4:	00 
  8016d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016d8:	89 04 24             	mov    %eax,(%esp)
  8016db:	e8 f2 f6 ff ff       	call   800dd2 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8016e0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8016e7:	00 
  8016e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016eb:	89 04 24             	mov    %eax,(%esp)
  8016ee:	e8 8c f6 ff ff       	call   800d7f <sys_env_set_status>
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	78 03                	js     8016fa <fork+0x197>
		return r;

	return envid;
  8016f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8016fa:	83 c4 3c             	add    $0x3c,%esp
  8016fd:	5b                   	pop    %ebx
  8016fe:	5e                   	pop    %esi
  8016ff:	5f                   	pop    %edi
  801700:	5d                   	pop    %ebp
  801701:	c3                   	ret    

00801702 <sfork>:

// Challenge!
int
sfork(void)
{
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801708:	c7 44 24 08 b5 1f 80 	movl   $0x801fb5,0x8(%esp)
  80170f:	00 
  801710:	c7 44 24 04 8d 00 00 	movl   $0x8d,0x4(%esp)
  801717:	00 
  801718:	c7 04 24 48 1f 80 00 	movl   $0x801f48,(%esp)
  80171f:	e8 40 01 00 00       	call   801864 <_panic>

00801724 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	56                   	push   %esi
  801728:	53                   	push   %ebx
  801729:	83 ec 10             	sub    $0x10,%esp
  80172c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80172f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801732:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	// -1 must be an invalid address.
	if (!pg) pg = (void *)-1;
  801735:	85 c0                	test   %eax,%eax
  801737:	75 05                	jne    80173e <ipc_recv+0x1a>
  801739:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	if ((r = sys_ipc_recv(pg)) < 0) {
  80173e:	89 04 24             	mov    %eax,(%esp)
  801741:	e8 02 f7 ff ff       	call   800e48 <sys_ipc_recv>
  801746:	85 c0                	test   %eax,%eax
  801748:	79 16                	jns    801760 <ipc_recv+0x3c>
		if (from_env_store) *from_env_store = 0;
  80174a:	85 db                	test   %ebx,%ebx
  80174c:	74 06                	je     801754 <ipc_recv+0x30>
  80174e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  801754:	85 f6                	test   %esi,%esi
  801756:	74 35                	je     80178d <ipc_recv+0x69>
  801758:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80175e:	eb 2d                	jmp    80178d <ipc_recv+0x69>
		return r;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801760:	85 db                	test   %ebx,%ebx
  801762:	74 0d                	je     801771 <ipc_recv+0x4d>
  801764:	a1 10 30 80 00       	mov    0x803010,%eax
  801769:	8b 80 b8 00 00 00    	mov    0xb8(%eax),%eax
  80176f:	89 03                	mov    %eax,(%ebx)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801771:	85 f6                	test   %esi,%esi
  801773:	74 0d                	je     801782 <ipc_recv+0x5e>
  801775:	a1 10 30 80 00       	mov    0x803010,%eax
  80177a:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  801780:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  801782:	a1 10 30 80 00       	mov    0x803010,%eax
  801787:	8b 80 b4 00 00 00    	mov    0xb4(%eax),%eax
}
  80178d:	83 c4 10             	add    $0x10,%esp
  801790:	5b                   	pop    %ebx
  801791:	5e                   	pop    %esi
  801792:	5d                   	pop    %ebp
  801793:	c3                   	ret    

00801794 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	57                   	push   %edi
  801798:	56                   	push   %esi
  801799:	53                   	push   %ebx
  80179a:	83 ec 1c             	sub    $0x1c,%esp
  80179d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8017a0:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	int retry_times = 0;
	if (!pg) pg = (void *)-1;
  8017a3:	85 db                	test   %ebx,%ebx
  8017a5:	75 05                	jne    8017ac <ipc_send+0x18>
  8017a7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8017ac:	be 03 00 00 00       	mov    $0x3,%esi
  8017b1:	eb 49                	jmp    8017fc <ipc_send+0x68>
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  8017b3:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8017b6:	74 20                	je     8017d8 <ipc_send+0x44>
			panic("ipc_send: %e", r);
  8017b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017bc:	c7 44 24 08 cb 1f 80 	movl   $0x801fcb,0x8(%esp)
  8017c3:	00 
  8017c4:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  8017cb:	00 
  8017cc:	c7 04 24 d8 1f 80 00 	movl   $0x801fd8,(%esp)
  8017d3:	e8 8c 00 00 00       	call   801864 <_panic>
		retry_times++;
		if (retry_times > 2) panic("Retry times out!");
  8017d8:	4e                   	dec    %esi
  8017d9:	75 1c                	jne    8017f7 <ipc_send+0x63>
  8017db:	c7 44 24 08 e2 1f 80 	movl   $0x801fe2,0x8(%esp)
  8017e2:	00 
  8017e3:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8017ea:	00 
  8017eb:	c7 04 24 d8 1f 80 00 	movl   $0x801fd8,(%esp)
  8017f2:	e8 6d 00 00 00       	call   801864 <_panic>
		sys_yield();
  8017f7:	e8 6a f4 ff ff       	call   800c66 <sys_yield>
{
	// LAB 4: Your code here.
	int r;
	int retry_times = 0;
	if (!pg) pg = (void *)-1;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8017fc:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801800:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801804:	8b 45 0c             	mov    0xc(%ebp),%eax
  801807:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180b:	8b 45 08             	mov    0x8(%ebp),%eax
  80180e:	89 04 24             	mov    %eax,(%esp)
  801811:	e8 0f f6 ff ff       	call   800e25 <sys_ipc_try_send>
  801816:	85 c0                	test   %eax,%eax
  801818:	78 99                	js     8017b3 <ipc_send+0x1f>
			panic("ipc_send: %e", r);
		retry_times++;
		if (retry_times > 2) panic("Retry times out!");
		sys_yield();
	}
}
  80181a:	83 c4 1c             	add    $0x1c,%esp
  80181d:	5b                   	pop    %ebx
  80181e:	5e                   	pop    %esi
  80181f:	5f                   	pop    %edi
  801820:	5d                   	pop    %ebp
  801821:	c3                   	ret    

00801822 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801828:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80182d:	8d 14 40             	lea    (%eax,%eax,2),%edx
  801830:	8d 14 92             	lea    (%edx,%edx,4),%edx
  801833:	c1 e2 04             	shl    $0x4,%edx
  801836:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80183c:	8b 52 50             	mov    0x50(%edx),%edx
  80183f:	39 ca                	cmp    %ecx,%edx
  801841:	75 13                	jne    801856 <ipc_find_env+0x34>
			return envs[i].env_id;
  801843:	8d 04 40             	lea    (%eax,%eax,2),%eax
  801846:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801849:	c1 e0 04             	shl    $0x4,%eax
  80184c:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801851:	8b 40 40             	mov    0x40(%eax),%eax
  801854:	eb 0c                	jmp    801862 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801856:	40                   	inc    %eax
  801857:	3d 00 04 00 00       	cmp    $0x400,%eax
  80185c:	75 cf                	jne    80182d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80185e:	66 b8 00 00          	mov    $0x0,%ax
}
  801862:	5d                   	pop    %ebp
  801863:	c3                   	ret    

00801864 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	56                   	push   %esi
  801868:	53                   	push   %ebx
  801869:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80186c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80186f:	8b 1d 08 30 80 00    	mov    0x803008,%ebx
  801875:	e8 cd f3 ff ff       	call   800c47 <sys_getenvid>
  80187a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80187d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801881:	8b 55 08             	mov    0x8(%ebp),%edx
  801884:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801888:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80188c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801890:	c7 04 24 f4 1f 80 00 	movl   $0x801ff4,(%esp)
  801897:	e8 48 ea ff ff       	call   8002e4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80189c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8018a3:	89 04 24             	mov    %eax,(%esp)
  8018a6:	e8 d8 e9 ff ff       	call   800283 <vcprintf>
	cprintf("\n");
  8018ab:	c7 04 24 f2 1b 80 00 	movl   $0x801bf2,(%esp)
  8018b2:	e8 2d ea ff ff       	call   8002e4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8018b7:	cc                   	int3   
  8018b8:	eb fd                	jmp    8018b7 <_panic+0x53>
	...

008018bc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8018c2:	83 3d 14 30 80 00 00 	cmpl   $0x0,0x803014
  8018c9:	75 40                	jne    80190b <set_pgfault_handler+0x4f>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
  8018cb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8018d2:	00 
  8018d3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8018da:	ee 
  8018db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e2:	e8 9e f3 ff ff       	call   800c85 <sys_page_alloc>
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	79 20                	jns    80190b <set_pgfault_handler+0x4f>
            panic("set_pgfault_handler: sys_page_alloc: %e", r);
  8018eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018ef:	c7 44 24 08 18 20 80 	movl   $0x802018,0x8(%esp)
  8018f6:	00 
  8018f7:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8018fe:	00 
  8018ff:	c7 04 24 74 20 80 00 	movl   $0x802074,(%esp)
  801906:	e8 59 ff ff ff       	call   801864 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80190b:	8b 45 08             	mov    0x8(%ebp),%eax
  80190e:	a3 14 30 80 00       	mov    %eax,0x803014
    if ((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0 )
  801913:	c7 44 24 04 50 19 80 	movl   $0x801950,0x4(%esp)
  80191a:	00 
  80191b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801922:	e8 ab f4 ff ff       	call   800dd2 <sys_env_set_pgfault_upcall>
  801927:	85 c0                	test   %eax,%eax
  801929:	79 20                	jns    80194b <set_pgfault_handler+0x8f>
        panic("set_pgfault_handler: sys_env_set_pgfault_upcall: %e", r);
  80192b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80192f:	c7 44 24 08 40 20 80 	movl   $0x802040,0x8(%esp)
  801936:	00 
  801937:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80193e:	00 
  80193f:	c7 04 24 74 20 80 00 	movl   $0x802074,(%esp)
  801946:	e8 19 ff ff ff       	call   801864 <_panic>
}
  80194b:	c9                   	leave  
  80194c:	c3                   	ret    
  80194d:	00 00                	add    %al,(%eax)
	...

00801950 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801950:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801951:	a1 14 30 80 00       	mov    0x803014,%eax
	call *%eax
  801956:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801958:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// sub 4 from old esp
	movl 0x30(%esp), %eax
  80195b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80195f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801962:	89 44 24 30          	mov    %eax,0x30(%esp)
	// put old eip into the pre-reserved 4-byte space
	movl 0x28(%esp), %ebx
  801966:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80196a:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  80196c:	83 c4 08             	add    $0x8,%esp
	popal
  80196f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  801970:	83 c4 04             	add    $0x4,%esp
	popfl
  801973:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801974:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801975:	c3                   	ret    
	...

00801978 <__udivdi3>:
  801978:	55                   	push   %ebp
  801979:	57                   	push   %edi
  80197a:	56                   	push   %esi
  80197b:	83 ec 10             	sub    $0x10,%esp
  80197e:	8b 74 24 20          	mov    0x20(%esp),%esi
  801982:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801986:	89 74 24 04          	mov    %esi,0x4(%esp)
  80198a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80198e:	89 cd                	mov    %ecx,%ebp
  801990:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801994:	85 c0                	test   %eax,%eax
  801996:	75 2c                	jne    8019c4 <__udivdi3+0x4c>
  801998:	39 f9                	cmp    %edi,%ecx
  80199a:	77 68                	ja     801a04 <__udivdi3+0x8c>
  80199c:	85 c9                	test   %ecx,%ecx
  80199e:	75 0b                	jne    8019ab <__udivdi3+0x33>
  8019a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8019a5:	31 d2                	xor    %edx,%edx
  8019a7:	f7 f1                	div    %ecx
  8019a9:	89 c1                	mov    %eax,%ecx
  8019ab:	31 d2                	xor    %edx,%edx
  8019ad:	89 f8                	mov    %edi,%eax
  8019af:	f7 f1                	div    %ecx
  8019b1:	89 c7                	mov    %eax,%edi
  8019b3:	89 f0                	mov    %esi,%eax
  8019b5:	f7 f1                	div    %ecx
  8019b7:	89 c6                	mov    %eax,%esi
  8019b9:	89 f0                	mov    %esi,%eax
  8019bb:	89 fa                	mov    %edi,%edx
  8019bd:	83 c4 10             	add    $0x10,%esp
  8019c0:	5e                   	pop    %esi
  8019c1:	5f                   	pop    %edi
  8019c2:	5d                   	pop    %ebp
  8019c3:	c3                   	ret    
  8019c4:	39 f8                	cmp    %edi,%eax
  8019c6:	77 2c                	ja     8019f4 <__udivdi3+0x7c>
  8019c8:	0f bd f0             	bsr    %eax,%esi
  8019cb:	83 f6 1f             	xor    $0x1f,%esi
  8019ce:	75 4c                	jne    801a1c <__udivdi3+0xa4>
  8019d0:	39 f8                	cmp    %edi,%eax
  8019d2:	bf 00 00 00 00       	mov    $0x0,%edi
  8019d7:	72 0a                	jb     8019e3 <__udivdi3+0x6b>
  8019d9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8019dd:	0f 87 ad 00 00 00    	ja     801a90 <__udivdi3+0x118>
  8019e3:	be 01 00 00 00       	mov    $0x1,%esi
  8019e8:	89 f0                	mov    %esi,%eax
  8019ea:	89 fa                	mov    %edi,%edx
  8019ec:	83 c4 10             	add    $0x10,%esp
  8019ef:	5e                   	pop    %esi
  8019f0:	5f                   	pop    %edi
  8019f1:	5d                   	pop    %ebp
  8019f2:	c3                   	ret    
  8019f3:	90                   	nop
  8019f4:	31 ff                	xor    %edi,%edi
  8019f6:	31 f6                	xor    %esi,%esi
  8019f8:	89 f0                	mov    %esi,%eax
  8019fa:	89 fa                	mov    %edi,%edx
  8019fc:	83 c4 10             	add    $0x10,%esp
  8019ff:	5e                   	pop    %esi
  801a00:	5f                   	pop    %edi
  801a01:	5d                   	pop    %ebp
  801a02:	c3                   	ret    
  801a03:	90                   	nop
  801a04:	89 fa                	mov    %edi,%edx
  801a06:	89 f0                	mov    %esi,%eax
  801a08:	f7 f1                	div    %ecx
  801a0a:	89 c6                	mov    %eax,%esi
  801a0c:	31 ff                	xor    %edi,%edi
  801a0e:	89 f0                	mov    %esi,%eax
  801a10:	89 fa                	mov    %edi,%edx
  801a12:	83 c4 10             	add    $0x10,%esp
  801a15:	5e                   	pop    %esi
  801a16:	5f                   	pop    %edi
  801a17:	5d                   	pop    %ebp
  801a18:	c3                   	ret    
  801a19:	8d 76 00             	lea    0x0(%esi),%esi
  801a1c:	89 f1                	mov    %esi,%ecx
  801a1e:	d3 e0                	shl    %cl,%eax
  801a20:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a24:	b8 20 00 00 00       	mov    $0x20,%eax
  801a29:	29 f0                	sub    %esi,%eax
  801a2b:	89 ea                	mov    %ebp,%edx
  801a2d:	88 c1                	mov    %al,%cl
  801a2f:	d3 ea                	shr    %cl,%edx
  801a31:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801a35:	09 ca                	or     %ecx,%edx
  801a37:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a3b:	89 f1                	mov    %esi,%ecx
  801a3d:	d3 e5                	shl    %cl,%ebp
  801a3f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801a43:	89 fd                	mov    %edi,%ebp
  801a45:	88 c1                	mov    %al,%cl
  801a47:	d3 ed                	shr    %cl,%ebp
  801a49:	89 fa                	mov    %edi,%edx
  801a4b:	89 f1                	mov    %esi,%ecx
  801a4d:	d3 e2                	shl    %cl,%edx
  801a4f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801a53:	88 c1                	mov    %al,%cl
  801a55:	d3 ef                	shr    %cl,%edi
  801a57:	09 d7                	or     %edx,%edi
  801a59:	89 f8                	mov    %edi,%eax
  801a5b:	89 ea                	mov    %ebp,%edx
  801a5d:	f7 74 24 08          	divl   0x8(%esp)
  801a61:	89 d1                	mov    %edx,%ecx
  801a63:	89 c7                	mov    %eax,%edi
  801a65:	f7 64 24 0c          	mull   0xc(%esp)
  801a69:	39 d1                	cmp    %edx,%ecx
  801a6b:	72 17                	jb     801a84 <__udivdi3+0x10c>
  801a6d:	74 09                	je     801a78 <__udivdi3+0x100>
  801a6f:	89 fe                	mov    %edi,%esi
  801a71:	31 ff                	xor    %edi,%edi
  801a73:	e9 41 ff ff ff       	jmp    8019b9 <__udivdi3+0x41>
  801a78:	8b 54 24 04          	mov    0x4(%esp),%edx
  801a7c:	89 f1                	mov    %esi,%ecx
  801a7e:	d3 e2                	shl    %cl,%edx
  801a80:	39 c2                	cmp    %eax,%edx
  801a82:	73 eb                	jae    801a6f <__udivdi3+0xf7>
  801a84:	8d 77 ff             	lea    -0x1(%edi),%esi
  801a87:	31 ff                	xor    %edi,%edi
  801a89:	e9 2b ff ff ff       	jmp    8019b9 <__udivdi3+0x41>
  801a8e:	66 90                	xchg   %ax,%ax
  801a90:	31 f6                	xor    %esi,%esi
  801a92:	e9 22 ff ff ff       	jmp    8019b9 <__udivdi3+0x41>
	...

00801a98 <__umoddi3>:
  801a98:	55                   	push   %ebp
  801a99:	57                   	push   %edi
  801a9a:	56                   	push   %esi
  801a9b:	83 ec 20             	sub    $0x20,%esp
  801a9e:	8b 44 24 30          	mov    0x30(%esp),%eax
  801aa2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801aa6:	89 44 24 14          	mov    %eax,0x14(%esp)
  801aaa:	8b 74 24 34          	mov    0x34(%esp),%esi
  801aae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ab2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801ab6:	89 c7                	mov    %eax,%edi
  801ab8:	89 f2                	mov    %esi,%edx
  801aba:	85 ed                	test   %ebp,%ebp
  801abc:	75 16                	jne    801ad4 <__umoddi3+0x3c>
  801abe:	39 f1                	cmp    %esi,%ecx
  801ac0:	0f 86 a6 00 00 00    	jbe    801b6c <__umoddi3+0xd4>
  801ac6:	f7 f1                	div    %ecx
  801ac8:	89 d0                	mov    %edx,%eax
  801aca:	31 d2                	xor    %edx,%edx
  801acc:	83 c4 20             	add    $0x20,%esp
  801acf:	5e                   	pop    %esi
  801ad0:	5f                   	pop    %edi
  801ad1:	5d                   	pop    %ebp
  801ad2:	c3                   	ret    
  801ad3:	90                   	nop
  801ad4:	39 f5                	cmp    %esi,%ebp
  801ad6:	0f 87 ac 00 00 00    	ja     801b88 <__umoddi3+0xf0>
  801adc:	0f bd c5             	bsr    %ebp,%eax
  801adf:	83 f0 1f             	xor    $0x1f,%eax
  801ae2:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ae6:	0f 84 a8 00 00 00    	je     801b94 <__umoddi3+0xfc>
  801aec:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801af0:	d3 e5                	shl    %cl,%ebp
  801af2:	bf 20 00 00 00       	mov    $0x20,%edi
  801af7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801afb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801aff:	89 f9                	mov    %edi,%ecx
  801b01:	d3 e8                	shr    %cl,%eax
  801b03:	09 e8                	or     %ebp,%eax
  801b05:	89 44 24 18          	mov    %eax,0x18(%esp)
  801b09:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801b0d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801b11:	d3 e0                	shl    %cl,%eax
  801b13:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b17:	89 f2                	mov    %esi,%edx
  801b19:	d3 e2                	shl    %cl,%edx
  801b1b:	8b 44 24 14          	mov    0x14(%esp),%eax
  801b1f:	d3 e0                	shl    %cl,%eax
  801b21:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801b25:	8b 44 24 14          	mov    0x14(%esp),%eax
  801b29:	89 f9                	mov    %edi,%ecx
  801b2b:	d3 e8                	shr    %cl,%eax
  801b2d:	09 d0                	or     %edx,%eax
  801b2f:	d3 ee                	shr    %cl,%esi
  801b31:	89 f2                	mov    %esi,%edx
  801b33:	f7 74 24 18          	divl   0x18(%esp)
  801b37:	89 d6                	mov    %edx,%esi
  801b39:	f7 64 24 0c          	mull   0xc(%esp)
  801b3d:	89 c5                	mov    %eax,%ebp
  801b3f:	89 d1                	mov    %edx,%ecx
  801b41:	39 d6                	cmp    %edx,%esi
  801b43:	72 67                	jb     801bac <__umoddi3+0x114>
  801b45:	74 75                	je     801bbc <__umoddi3+0x124>
  801b47:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801b4b:	29 e8                	sub    %ebp,%eax
  801b4d:	19 ce                	sbb    %ecx,%esi
  801b4f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801b53:	d3 e8                	shr    %cl,%eax
  801b55:	89 f2                	mov    %esi,%edx
  801b57:	89 f9                	mov    %edi,%ecx
  801b59:	d3 e2                	shl    %cl,%edx
  801b5b:	09 d0                	or     %edx,%eax
  801b5d:	89 f2                	mov    %esi,%edx
  801b5f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801b63:	d3 ea                	shr    %cl,%edx
  801b65:	83 c4 20             	add    $0x20,%esp
  801b68:	5e                   	pop    %esi
  801b69:	5f                   	pop    %edi
  801b6a:	5d                   	pop    %ebp
  801b6b:	c3                   	ret    
  801b6c:	85 c9                	test   %ecx,%ecx
  801b6e:	75 0b                	jne    801b7b <__umoddi3+0xe3>
  801b70:	b8 01 00 00 00       	mov    $0x1,%eax
  801b75:	31 d2                	xor    %edx,%edx
  801b77:	f7 f1                	div    %ecx
  801b79:	89 c1                	mov    %eax,%ecx
  801b7b:	89 f0                	mov    %esi,%eax
  801b7d:	31 d2                	xor    %edx,%edx
  801b7f:	f7 f1                	div    %ecx
  801b81:	89 f8                	mov    %edi,%eax
  801b83:	e9 3e ff ff ff       	jmp    801ac6 <__umoddi3+0x2e>
  801b88:	89 f2                	mov    %esi,%edx
  801b8a:	83 c4 20             	add    $0x20,%esp
  801b8d:	5e                   	pop    %esi
  801b8e:	5f                   	pop    %edi
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    
  801b91:	8d 76 00             	lea    0x0(%esi),%esi
  801b94:	39 f5                	cmp    %esi,%ebp
  801b96:	72 04                	jb     801b9c <__umoddi3+0x104>
  801b98:	39 f9                	cmp    %edi,%ecx
  801b9a:	77 06                	ja     801ba2 <__umoddi3+0x10a>
  801b9c:	89 f2                	mov    %esi,%edx
  801b9e:	29 cf                	sub    %ecx,%edi
  801ba0:	19 ea                	sbb    %ebp,%edx
  801ba2:	89 f8                	mov    %edi,%eax
  801ba4:	83 c4 20             	add    $0x20,%esp
  801ba7:	5e                   	pop    %esi
  801ba8:	5f                   	pop    %edi
  801ba9:	5d                   	pop    %ebp
  801baa:	c3                   	ret    
  801bab:	90                   	nop
  801bac:	89 d1                	mov    %edx,%ecx
  801bae:	89 c5                	mov    %eax,%ebp
  801bb0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801bb4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801bb8:	eb 8d                	jmp    801b47 <__umoddi3+0xaf>
  801bba:	66 90                	xchg   %ax,%ax
  801bbc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801bc0:	72 ea                	jb     801bac <__umoddi3+0x114>
  801bc2:	89 f1                	mov    %esi,%ecx
  801bc4:	eb 81                	jmp    801b47 <__umoddi3+0xaf>
