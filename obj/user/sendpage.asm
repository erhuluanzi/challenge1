
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
  80003a:	e8 f4 0f 00 00       	call   801033 <fork>
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
  800060:	e8 8f 11 00 00       	call   8011f4 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800065:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  80006c:	00 
  80006d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800070:	89 44 24 04          	mov    %eax,0x4(%esp)
  800074:	c7 04 24 a0 16 80 00 	movl   $0x8016a0,(%esp)
  80007b:	e8 64 02 00 00       	call   8002e4 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800080:	a1 04 20 80 00       	mov    0x802004,%eax
  800085:	89 04 24             	mov    %eax,(%esp)
  800088:	e8 d3 07 00 00       	call   800860 <strlen>
  80008d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800091:	a1 04 20 80 00       	mov    0x802004,%eax
  800096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009a:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a1:	e8 b5 08 00 00       	call   80095b <strncmp>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 0c                	jne    8000b6 <umain+0x82>
			cprintf("child received correct message\n");
  8000aa:	c7 04 24 b4 16 80 00 	movl   $0x8016b4,(%esp)
  8000b1:	e8 2e 02 00 00       	call   8002e4 <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000b6:	a1 00 20 80 00       	mov    0x802000,%eax
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 9d 07 00 00       	call   800860 <strlen>
  8000c3:	40                   	inc    %eax
  8000c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c8:	a1 00 20 80 00       	mov    0x802000,%eax
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
  8000fb:	e8 5b 11 00 00       	call   80125b <ipc_send>
		return;
  800100:	e9 d6 00 00 00       	jmp    8001db <umain+0x1a7>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800105:	a1 10 20 80 00       	mov    0x802010,%eax
  80010a:	8b 40 48             	mov    0x48(%eax),%eax
  80010d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800114:	00 
  800115:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80011c:	00 
  80011d:	89 04 24             	mov    %eax,(%esp)
  800120:	e8 60 0b 00 00       	call   800c85 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800125:	a1 04 20 80 00       	mov    0x802004,%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 2e 07 00 00       	call   800860 <strlen>
  800132:	40                   	inc    %eax
  800133:	89 44 24 08          	mov    %eax,0x8(%esp)
  800137:	a1 04 20 80 00       	mov    0x802004,%eax
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
  80016a:	e8 ec 10 00 00       	call   80125b <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  80016f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800176:	00 
  800177:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80017e:	00 
  80017f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800182:	89 04 24             	mov    %eax,(%esp)
  800185:	e8 6a 10 00 00       	call   8011f4 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80018a:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  800191:	00 
  800192:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	c7 04 24 a0 16 80 00 	movl   $0x8016a0,(%esp)
  8001a0:	e8 3f 01 00 00       	call   8002e4 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001a5:	a1 00 20 80 00       	mov    0x802000,%eax
  8001aa:	89 04 24             	mov    %eax,(%esp)
  8001ad:	e8 ae 06 00 00       	call   800860 <strlen>
  8001b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b6:	a1 00 20 80 00       	mov    0x802000,%eax
  8001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bf:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001c6:	e8 90 07 00 00       	call   80095b <strncmp>
  8001cb:	85 c0                	test   %eax,%eax
  8001cd:	75 0c                	jne    8001db <umain+0x1a7>
		cprintf("parent received correct message\n");
  8001cf:	c7 04 24 d4 16 80 00 	movl   $0x8016d4,(%esp)
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
  8001f8:	8d 14 80             	lea    (%eax,%eax,4),%edx
  8001fb:	8d 04 50             	lea    (%eax,%edx,2),%eax
  8001fe:	c1 e0 04             	shl    $0x4,%eax
  800201:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800206:	a3 10 20 80 00       	mov    %eax,0x802010

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020b:	85 f6                	test   %esi,%esi
  80020d:	7e 07                	jle    800216 <libmain+0x36>
		binaryname = argv[0];
  80020f:	8b 03                	mov    (%ebx),%eax
  800211:	a3 08 20 80 00       	mov    %eax,0x802008

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
  800359:	e8 e2 10 00 00       	call   801440 <__udivdi3>
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
  8003ac:	e8 af 11 00 00       	call   801560 <__umoddi3>
  8003b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b5:	0f be 80 4c 17 80 00 	movsbl 0x80174c(%eax),%eax
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
  800502:	ff 24 8d 20 18 80 00 	jmp    *0x801820(,%ecx,4)
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
  800590:	8b 04 85 80 19 80 00 	mov    0x801980(,%eax,4),%eax
  800597:	85 c0                	test   %eax,%eax
  800599:	75 23                	jne    8005be <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80059b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80059f:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
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
  8005c2:	c7 44 24 08 6d 17 80 	movl   $0x80176d,0x8(%esp)
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
  8005f8:	be 5d 17 80 00       	mov    $0x80175d,%esi
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
  800796:	a3 0c 20 80 00       	mov    %eax,0x80200c
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
  800c23:	c7 44 24 08 a8 19 80 	movl   $0x8019a8,0x8(%esp)
  800c2a:	00 
  800c2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c32:	00 
  800c33:	c7 04 24 c5 19 80 00 	movl   $0x8019c5,(%esp)
  800c3a:	e8 ed 06 00 00       	call   80132c <_panic>

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
  800cb5:	c7 44 24 08 a8 19 80 	movl   $0x8019a8,0x8(%esp)
  800cbc:	00 
  800cbd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc4:	00 
  800cc5:	c7 04 24 c5 19 80 00 	movl   $0x8019c5,(%esp)
  800ccc:	e8 5b 06 00 00       	call   80132c <_panic>

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
  800d08:	c7 44 24 08 a8 19 80 	movl   $0x8019a8,0x8(%esp)
  800d0f:	00 
  800d10:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d17:	00 
  800d18:	c7 04 24 c5 19 80 00 	movl   $0x8019c5,(%esp)
  800d1f:	e8 08 06 00 00       	call   80132c <_panic>

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
  800d5b:	c7 44 24 08 a8 19 80 	movl   $0x8019a8,0x8(%esp)
  800d62:	00 
  800d63:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6a:	00 
  800d6b:	c7 04 24 c5 19 80 00 	movl   $0x8019c5,(%esp)
  800d72:	e8 b5 05 00 00       	call   80132c <_panic>

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
  800dae:	c7 44 24 08 a8 19 80 	movl   $0x8019a8,0x8(%esp)
  800db5:	00 
  800db6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbd:	00 
  800dbe:	c7 04 24 c5 19 80 00 	movl   $0x8019c5,(%esp)
  800dc5:	e8 62 05 00 00       	call   80132c <_panic>

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
  800e01:	c7 44 24 08 a8 19 80 	movl   $0x8019a8,0x8(%esp)
  800e08:	00 
  800e09:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e10:	00 
  800e11:	c7 04 24 c5 19 80 00 	movl   $0x8019c5,(%esp)
  800e18:	e8 0f 05 00 00       	call   80132c <_panic>

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
  800e76:	c7 44 24 08 a8 19 80 	movl   $0x8019a8,0x8(%esp)
  800e7d:	00 
  800e7e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e85:	00 
  800e86:	c7 04 24 c5 19 80 00 	movl   $0x8019c5,(%esp)
  800e8d:	e8 9a 04 00 00       	call   80132c <_panic>

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
  800ec9:	c7 44 24 08 a8 19 80 	movl   $0x8019a8,0x8(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed8:	00 
  800ed9:	c7 04 24 c5 19 80 00 	movl   $0x8019c5,(%esp)
  800ee0:	e8 47 04 00 00       	call   80132c <_panic>
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
  800eed:	00 00                	add    %al,(%eax)
	...

00800ef0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 24             	sub    $0x24,%esp
  800ef7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800efa:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800efc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f00:	74 2d                	je     800f2f <pgfault+0x3f>
  800f02:	89 d8                	mov    %ebx,%eax
  800f04:	c1 e8 16             	shr    $0x16,%eax
  800f07:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f0e:	a8 01                	test   $0x1,%al
  800f10:	74 1d                	je     800f2f <pgfault+0x3f>
		(uvpt[PGNUM(addr)] & PTE_P) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800f12:	89 d8                	mov    %ebx,%eax
  800f14:	c1 e8 0c             	shr    $0xc,%eax
  800f17:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800f1e:	f6 c2 01             	test   $0x1,%dl
  800f21:	74 0c                	je     800f2f <pgfault+0x3f>
		(uvpt[PGNUM(addr)] & PTE_P) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800f23:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f2a:	f6 c4 08             	test   $0x8,%ah
  800f2d:	75 1c                	jne    800f4b <pgfault+0x5b>
		panic("pgfault: not a write or a copy on write page fault!");
  800f2f:	c7 44 24 08 d4 19 80 	movl   $0x8019d4,0x8(%esp)
  800f36:	00 
  800f37:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800f3e:	00 
  800f3f:	c7 04 24 08 1a 80 00 	movl   $0x801a08,(%esp)
  800f46:	e8 e1 03 00 00       	call   80132c <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	// we need to make addr page-aligned
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)) < 0)
  800f4b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f52:	00 
  800f53:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f5a:	00 
  800f5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f62:	e8 1e fd ff ff       	call   800c85 <sys_page_alloc>
  800f67:	85 c0                	test   %eax,%eax
  800f69:	79 20                	jns    800f8b <pgfault+0x9b>
		panic("pgfault: sys_page_alloc: %e", r);
  800f6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f6f:	c7 44 24 08 13 1a 80 	movl   $0x801a13,0x8(%esp)
  800f76:	00 
  800f77:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800f7e:	00 
  800f7f:	c7 04 24 08 1a 80 00 	movl   $0x801a08,(%esp)
  800f86:	e8 a1 03 00 00       	call   80132c <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// we need to make addr page-aligned
	addr = ROUNDDOWN(addr, PGSIZE);
  800f8b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)) < 0)
		panic("pgfault: sys_page_alloc: %e", r);
	memcpy(PFTEMP, addr, PGSIZE);
  800f91:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f98:	00 
  800f99:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f9d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800fa4:	e8 cd fa ff ff       	call   800a76 <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P)) < 0)
  800fa9:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800fb0:	00 
  800fb1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fb5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fbc:	00 
  800fbd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fc4:	00 
  800fc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fcc:	e8 08 fd ff ff       	call   800cd9 <sys_page_map>
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	79 20                	jns    800ff5 <pgfault+0x105>
		panic("pgfault: sys_page_map: %e", r);
  800fd5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fd9:	c7 44 24 08 2f 1a 80 	movl   $0x801a2f,0x8(%esp)
  800fe0:	00 
  800fe1:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800fe8:	00 
  800fe9:	c7 04 24 08 1a 80 00 	movl   $0x801a08,(%esp)
  800ff0:	e8 37 03 00 00       	call   80132c <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800ff5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ffc:	00 
  800ffd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801004:	e8 23 fd ff ff       	call   800d2c <sys_page_unmap>
  801009:	85 c0                	test   %eax,%eax
  80100b:	79 20                	jns    80102d <pgfault+0x13d>
		panic("pgfault: sys_page_unmap: %e", r);
  80100d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801011:	c7 44 24 08 49 1a 80 	movl   $0x801a49,0x8(%esp)
  801018:	00 
  801019:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801020:	00 
  801021:	c7 04 24 08 1a 80 00 	movl   $0x801a08,(%esp)
  801028:	e8 ff 02 00 00       	call   80132c <_panic>
}
  80102d:	83 c4 24             	add    $0x24,%esp
  801030:	5b                   	pop    %ebx
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	57                   	push   %edi
  801037:	56                   	push   %esi
  801038:	53                   	push   %ebx
  801039:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80103c:	c7 04 24 f0 0e 80 00 	movl   $0x800ef0,(%esp)
  801043:	e8 3c 03 00 00       	call   801384 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801048:	ba 07 00 00 00       	mov    $0x7,%edx
  80104d:	89 d0                	mov    %edx,%eax
  80104f:	cd 30                	int    $0x30
  801051:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801054:	89 c7                	mov    %eax,%edi
	envid_t envid;
	uint8_t *addr;
	int r;
	extern unsigned char end[];
	envid = sys_exofork();
	if (envid < 0)
  801056:	85 c0                	test   %eax,%eax
  801058:	79 20                	jns    80107a <fork+0x47>
		panic("sys_exofork: %e", envid);
  80105a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80105e:	c7 44 24 08 65 1a 80 	movl   $0x801a65,0x8(%esp)
  801065:	00 
  801066:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  80106d:	00 
  80106e:	c7 04 24 08 1a 80 00 	movl   $0x801a08,(%esp)
  801075:	e8 b2 02 00 00       	call   80132c <_panic>
	if (envid == 0) {
  80107a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80107e:	75 27                	jne    8010a7 <fork+0x74>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  801080:	e8 c2 fb ff ff       	call   800c47 <sys_getenvid>
  801085:	25 ff 03 00 00       	and    $0x3ff,%eax
  80108a:	8d 14 80             	lea    (%eax,%eax,4),%edx
  80108d:	8d 04 50             	lea    (%eax,%edx,2),%eax
  801090:	c1 e0 04             	shl    $0x4,%eax
  801093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801098:	a3 10 20 80 00       	mov    %eax,0x802010
		return 0;
  80109d:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a2:	e9 23 01 00 00       	jmp    8011ca <fork+0x197>
	int r;
	extern unsigned char end[];
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8010a7:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	}

	// We're the parent.
	for (addr = 0; addr < (uint8_t *)USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  8010ac:	89 d8                	mov    %ebx,%eax
  8010ae:	c1 e8 16             	shr    $0x16,%eax
  8010b1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b8:	a8 01                	test   $0x1,%al
  8010ba:	0f 84 ac 00 00 00    	je     80116c <fork+0x139>
  8010c0:	89 d8                	mov    %ebx,%eax
  8010c2:	c1 e8 0c             	shr    $0xc,%eax
  8010c5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010cc:	f6 c2 01             	test   $0x1,%dl
  8010cf:	0f 84 97 00 00 00    	je     80116c <fork+0x139>
			&& (uvpt[PGNUM(addr)] & PTE_U))
  8010d5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010dc:	f6 c2 04             	test   $0x4,%dl
  8010df:	0f 84 87 00 00 00    	je     80116c <fork+0x139>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	void *va = (void *)(pn * PGSIZE);
  8010e5:	89 c6                	mov    %eax,%esi
  8010e7:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  8010ea:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f1:	f6 c2 02             	test   $0x2,%dl
  8010f4:	75 0c                	jne    801102 <fork+0xcf>
  8010f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010fd:	f6 c4 08             	test   $0x8,%ah
  801100:	74 4a                	je     80114c <fork+0x119>
		if ((r = sys_page_map(0, va, envid, va, PTE_COW|PTE_U|PTE_P)) < 0)
  801102:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801109:	00 
  80110a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80110e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801112:	89 74 24 04          	mov    %esi,0x4(%esp)
  801116:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80111d:	e8 b7 fb ff ff       	call   800cd9 <sys_page_map>
  801122:	85 c0                	test   %eax,%eax
  801124:	78 46                	js     80116c <fork+0x139>
			return r;
		if ((r = sys_page_map(0, va, 0, va, PTE_COW|PTE_U|PTE_P)) < 0)
  801126:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80112d:	00 
  80112e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801132:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801139:	00 
  80113a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80113e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801145:	e8 8f fb ff ff       	call   800cd9 <sys_page_map>
  80114a:	eb 20                	jmp    80116c <fork+0x139>
			return r;
	}
	else {
		if ((r = sys_page_map(0, va, envid, va, PTE_U|PTE_P)) < 0)
  80114c:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801153:	00 
  801154:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801158:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80115c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801160:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801167:	e8 6d fb ff ff       	call   800cd9 <sys_page_map>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	// We're the parent.
	for (addr = 0; addr < (uint8_t *)USTACKTOP; addr += PGSIZE)
  80116c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801172:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801178:	0f 85 2e ff ff ff    	jne    8010ac <fork+0x79>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
			&& (uvpt[PGNUM(addr)] & PTE_U))
			duppage(envid, PGNUM(addr));

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  80117e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801185:	00 
  801186:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80118d:	ee 
  80118e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801191:	89 04 24             	mov    %eax,(%esp)
  801194:	e8 ec fa ff ff       	call   800c85 <sys_page_alloc>
  801199:	85 c0                	test   %eax,%eax
  80119b:	78 2d                	js     8011ca <fork+0x197>
		return r;
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80119d:	c7 44 24 04 18 14 80 	movl   $0x801418,0x4(%esp)
  8011a4:	00 
  8011a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011a8:	89 04 24             	mov    %eax,(%esp)
  8011ab:	e8 22 fc ff ff       	call   800dd2 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8011b0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011b7:	00 
  8011b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011bb:	89 04 24             	mov    %eax,(%esp)
  8011be:	e8 bc fb ff ff       	call   800d7f <sys_env_set_status>
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	78 03                	js     8011ca <fork+0x197>
		return r;

	return envid;
  8011c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8011ca:	83 c4 3c             	add    $0x3c,%esp
  8011cd:	5b                   	pop    %ebx
  8011ce:	5e                   	pop    %esi
  8011cf:	5f                   	pop    %edi
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <sfork>:

// Challenge!
int
sfork(void)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8011d8:	c7 44 24 08 75 1a 80 	movl   $0x801a75,0x8(%esp)
  8011df:	00 
  8011e0:	c7 44 24 04 8d 00 00 	movl   $0x8d,0x4(%esp)
  8011e7:	00 
  8011e8:	c7 04 24 08 1a 80 00 	movl   $0x801a08,(%esp)
  8011ef:	e8 38 01 00 00       	call   80132c <_panic>

008011f4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	56                   	push   %esi
  8011f8:	53                   	push   %ebx
  8011f9:	83 ec 10             	sub    $0x10,%esp
  8011fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801202:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	// -1 must be an invalid address.
	if (!pg) pg = (void *)-1;
  801205:	85 c0                	test   %eax,%eax
  801207:	75 05                	jne    80120e <ipc_recv+0x1a>
  801209:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	if ((r = sys_ipc_recv(pg)) < 0) {
  80120e:	89 04 24             	mov    %eax,(%esp)
  801211:	e8 32 fc ff ff       	call   800e48 <sys_ipc_recv>
  801216:	85 c0                	test   %eax,%eax
  801218:	79 16                	jns    801230 <ipc_recv+0x3c>
		if (from_env_store) *from_env_store = 0;
  80121a:	85 db                	test   %ebx,%ebx
  80121c:	74 06                	je     801224 <ipc_recv+0x30>
  80121e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  801224:	85 f6                	test   %esi,%esi
  801226:	74 2c                	je     801254 <ipc_recv+0x60>
  801228:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80122e:	eb 24                	jmp    801254 <ipc_recv+0x60>
		return r;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801230:	85 db                	test   %ebx,%ebx
  801232:	74 0a                	je     80123e <ipc_recv+0x4a>
  801234:	a1 10 20 80 00       	mov    0x802010,%eax
  801239:	8b 40 78             	mov    0x78(%eax),%eax
  80123c:	89 03                	mov    %eax,(%ebx)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  80123e:	85 f6                	test   %esi,%esi
  801240:	74 0a                	je     80124c <ipc_recv+0x58>
  801242:	a1 10 20 80 00       	mov    0x802010,%eax
  801247:	8b 40 7c             	mov    0x7c(%eax),%eax
  80124a:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  80124c:	a1 10 20 80 00       	mov    0x802010,%eax
  801251:	8b 40 74             	mov    0x74(%eax),%eax
}
  801254:	83 c4 10             	add    $0x10,%esp
  801257:	5b                   	pop    %ebx
  801258:	5e                   	pop    %esi
  801259:	5d                   	pop    %ebp
  80125a:	c3                   	ret    

0080125b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	57                   	push   %edi
  80125f:	56                   	push   %esi
  801260:	53                   	push   %ebx
  801261:	83 ec 1c             	sub    $0x1c,%esp
  801264:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801267:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	int retry_times = 0;
	if (!pg) pg = (void *)-1;
  80126a:	85 db                	test   %ebx,%ebx
  80126c:	75 05                	jne    801273 <ipc_send+0x18>
  80126e:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  801273:	be 03 00 00 00       	mov    $0x3,%esi
  801278:	eb 49                	jmp    8012c3 <ipc_send+0x68>
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  80127a:	83 f8 f8             	cmp    $0xfffffff8,%eax
  80127d:	74 20                	je     80129f <ipc_send+0x44>
			panic("ipc_send: %e", r);
  80127f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801283:	c7 44 24 08 8b 1a 80 	movl   $0x801a8b,0x8(%esp)
  80128a:	00 
  80128b:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  801292:	00 
  801293:	c7 04 24 98 1a 80 00 	movl   $0x801a98,(%esp)
  80129a:	e8 8d 00 00 00       	call   80132c <_panic>
		retry_times++;
		if (retry_times > 2) panic("Retry times out!");
  80129f:	4e                   	dec    %esi
  8012a0:	75 1c                	jne    8012be <ipc_send+0x63>
  8012a2:	c7 44 24 08 a2 1a 80 	movl   $0x801aa2,0x8(%esp)
  8012a9:	00 
  8012aa:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8012b1:	00 
  8012b2:	c7 04 24 98 1a 80 00 	movl   $0x801a98,(%esp)
  8012b9:	e8 6e 00 00 00       	call   80132c <_panic>
		sys_yield();
  8012be:	e8 a3 f9 ff ff       	call   800c66 <sys_yield>
{
	// LAB 4: Your code here.
	int r;
	int retry_times = 0;
	if (!pg) pg = (void *)-1;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8012c3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012c7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d5:	89 04 24             	mov    %eax,(%esp)
  8012d8:	e8 48 fb ff ff       	call   800e25 <sys_ipc_try_send>
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	78 99                	js     80127a <ipc_send+0x1f>
			panic("ipc_send: %e", r);
		retry_times++;
		if (retry_times > 2) panic("Retry times out!");
		sys_yield();
	}
}
  8012e1:	83 c4 1c             	add    $0x1c,%esp
  8012e4:	5b                   	pop    %ebx
  8012e5:	5e                   	pop    %esi
  8012e6:	5f                   	pop    %edi
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    

008012e9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012ef:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012f4:	8d 14 80             	lea    (%eax,%eax,4),%edx
  8012f7:	8d 14 50             	lea    (%eax,%edx,2),%edx
  8012fa:	c1 e2 04             	shl    $0x4,%edx
  8012fd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801303:	8b 52 50             	mov    0x50(%edx),%edx
  801306:	39 ca                	cmp    %ecx,%edx
  801308:	75 13                	jne    80131d <ipc_find_env+0x34>
			return envs[i].env_id;
  80130a:	8d 14 80             	lea    (%eax,%eax,4),%edx
  80130d:	8d 04 50             	lea    (%eax,%edx,2),%eax
  801310:	c1 e0 04             	shl    $0x4,%eax
  801313:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801318:	8b 40 40             	mov    0x40(%eax),%eax
  80131b:	eb 0c                	jmp    801329 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80131d:	40                   	inc    %eax
  80131e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801323:	75 cf                	jne    8012f4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801325:	66 b8 00 00          	mov    $0x0,%ax
}
  801329:	5d                   	pop    %ebp
  80132a:	c3                   	ret    
	...

0080132c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	56                   	push   %esi
  801330:	53                   	push   %ebx
  801331:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801334:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801337:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80133d:	e8 05 f9 ff ff       	call   800c47 <sys_getenvid>
  801342:	8b 55 0c             	mov    0xc(%ebp),%edx
  801345:	89 54 24 10          	mov    %edx,0x10(%esp)
  801349:	8b 55 08             	mov    0x8(%ebp),%edx
  80134c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801350:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801354:	89 44 24 04          	mov    %eax,0x4(%esp)
  801358:	c7 04 24 b4 1a 80 00 	movl   $0x801ab4,(%esp)
  80135f:	e8 80 ef ff ff       	call   8002e4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801364:	89 74 24 04          	mov    %esi,0x4(%esp)
  801368:	8b 45 10             	mov    0x10(%ebp),%eax
  80136b:	89 04 24             	mov    %eax,(%esp)
  80136e:	e8 10 ef ff ff       	call   800283 <vcprintf>
	cprintf("\n");
  801373:	c7 04 24 b2 16 80 00 	movl   $0x8016b2,(%esp)
  80137a:	e8 65 ef ff ff       	call   8002e4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80137f:	cc                   	int3   
  801380:	eb fd                	jmp    80137f <_panic+0x53>
	...

00801384 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801384:	55                   	push   %ebp
  801385:	89 e5                	mov    %esp,%ebp
  801387:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80138a:	83 3d 14 20 80 00 00 	cmpl   $0x0,0x802014
  801391:	75 40                	jne    8013d3 <set_pgfault_handler+0x4f>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P)) < 0)
  801393:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80139a:	00 
  80139b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013a2:	ee 
  8013a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013aa:	e8 d6 f8 ff ff       	call   800c85 <sys_page_alloc>
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	79 20                	jns    8013d3 <set_pgfault_handler+0x4f>
            panic("set_pgfault_handler: sys_page_alloc: %e", r);
  8013b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013b7:	c7 44 24 08 d8 1a 80 	movl   $0x801ad8,0x8(%esp)
  8013be:	00 
  8013bf:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8013c6:	00 
  8013c7:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  8013ce:	e8 59 ff ff ff       	call   80132c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8013d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d6:	a3 14 20 80 00       	mov    %eax,0x802014
    if ((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0 )
  8013db:	c7 44 24 04 18 14 80 	movl   $0x801418,0x4(%esp)
  8013e2:	00 
  8013e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013ea:	e8 e3 f9 ff ff       	call   800dd2 <sys_env_set_pgfault_upcall>
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	79 20                	jns    801413 <set_pgfault_handler+0x8f>
        panic("set_pgfault_handler: sys_env_set_pgfault_upcall: %e", r);
  8013f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013f7:	c7 44 24 08 00 1b 80 	movl   $0x801b00,0x8(%esp)
  8013fe:	00 
  8013ff:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  801406:	00 
  801407:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  80140e:	e8 19 ff ff ff       	call   80132c <_panic>
}
  801413:	c9                   	leave  
  801414:	c3                   	ret    
  801415:	00 00                	add    %al,(%eax)
	...

00801418 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801418:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801419:	a1 14 20 80 00       	mov    0x802014,%eax
	call *%eax
  80141e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801420:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// sub 4 from old esp
	movl 0x30(%esp), %eax
  801423:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801427:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80142a:	89 44 24 30          	mov    %eax,0x30(%esp)
	// put old eip into the pre-reserved 4-byte space
	movl 0x28(%esp), %ebx
  80142e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801432:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  801434:	83 c4 08             	add    $0x8,%esp
	popal
  801437:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  801438:	83 c4 04             	add    $0x4,%esp
	popfl
  80143b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80143c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80143d:	c3                   	ret    
	...

00801440 <__udivdi3>:
  801440:	55                   	push   %ebp
  801441:	57                   	push   %edi
  801442:	56                   	push   %esi
  801443:	83 ec 10             	sub    $0x10,%esp
  801446:	8b 74 24 20          	mov    0x20(%esp),%esi
  80144a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80144e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801452:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801456:	89 cd                	mov    %ecx,%ebp
  801458:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  80145c:	85 c0                	test   %eax,%eax
  80145e:	75 2c                	jne    80148c <__udivdi3+0x4c>
  801460:	39 f9                	cmp    %edi,%ecx
  801462:	77 68                	ja     8014cc <__udivdi3+0x8c>
  801464:	85 c9                	test   %ecx,%ecx
  801466:	75 0b                	jne    801473 <__udivdi3+0x33>
  801468:	b8 01 00 00 00       	mov    $0x1,%eax
  80146d:	31 d2                	xor    %edx,%edx
  80146f:	f7 f1                	div    %ecx
  801471:	89 c1                	mov    %eax,%ecx
  801473:	31 d2                	xor    %edx,%edx
  801475:	89 f8                	mov    %edi,%eax
  801477:	f7 f1                	div    %ecx
  801479:	89 c7                	mov    %eax,%edi
  80147b:	89 f0                	mov    %esi,%eax
  80147d:	f7 f1                	div    %ecx
  80147f:	89 c6                	mov    %eax,%esi
  801481:	89 f0                	mov    %esi,%eax
  801483:	89 fa                	mov    %edi,%edx
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	5e                   	pop    %esi
  801489:	5f                   	pop    %edi
  80148a:	5d                   	pop    %ebp
  80148b:	c3                   	ret    
  80148c:	39 f8                	cmp    %edi,%eax
  80148e:	77 2c                	ja     8014bc <__udivdi3+0x7c>
  801490:	0f bd f0             	bsr    %eax,%esi
  801493:	83 f6 1f             	xor    $0x1f,%esi
  801496:	75 4c                	jne    8014e4 <__udivdi3+0xa4>
  801498:	39 f8                	cmp    %edi,%eax
  80149a:	bf 00 00 00 00       	mov    $0x0,%edi
  80149f:	72 0a                	jb     8014ab <__udivdi3+0x6b>
  8014a1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8014a5:	0f 87 ad 00 00 00    	ja     801558 <__udivdi3+0x118>
  8014ab:	be 01 00 00 00       	mov    $0x1,%esi
  8014b0:	89 f0                	mov    %esi,%eax
  8014b2:	89 fa                	mov    %edi,%edx
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	5e                   	pop    %esi
  8014b8:	5f                   	pop    %edi
  8014b9:	5d                   	pop    %ebp
  8014ba:	c3                   	ret    
  8014bb:	90                   	nop
  8014bc:	31 ff                	xor    %edi,%edi
  8014be:	31 f6                	xor    %esi,%esi
  8014c0:	89 f0                	mov    %esi,%eax
  8014c2:	89 fa                	mov    %edi,%edx
  8014c4:	83 c4 10             	add    $0x10,%esp
  8014c7:	5e                   	pop    %esi
  8014c8:	5f                   	pop    %edi
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    
  8014cb:	90                   	nop
  8014cc:	89 fa                	mov    %edi,%edx
  8014ce:	89 f0                	mov    %esi,%eax
  8014d0:	f7 f1                	div    %ecx
  8014d2:	89 c6                	mov    %eax,%esi
  8014d4:	31 ff                	xor    %edi,%edi
  8014d6:	89 f0                	mov    %esi,%eax
  8014d8:	89 fa                	mov    %edi,%edx
  8014da:	83 c4 10             	add    $0x10,%esp
  8014dd:	5e                   	pop    %esi
  8014de:	5f                   	pop    %edi
  8014df:	5d                   	pop    %ebp
  8014e0:	c3                   	ret    
  8014e1:	8d 76 00             	lea    0x0(%esi),%esi
  8014e4:	89 f1                	mov    %esi,%ecx
  8014e6:	d3 e0                	shl    %cl,%eax
  8014e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ec:	b8 20 00 00 00       	mov    $0x20,%eax
  8014f1:	29 f0                	sub    %esi,%eax
  8014f3:	89 ea                	mov    %ebp,%edx
  8014f5:	88 c1                	mov    %al,%cl
  8014f7:	d3 ea                	shr    %cl,%edx
  8014f9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8014fd:	09 ca                	or     %ecx,%edx
  8014ff:	89 54 24 08          	mov    %edx,0x8(%esp)
  801503:	89 f1                	mov    %esi,%ecx
  801505:	d3 e5                	shl    %cl,%ebp
  801507:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80150b:	89 fd                	mov    %edi,%ebp
  80150d:	88 c1                	mov    %al,%cl
  80150f:	d3 ed                	shr    %cl,%ebp
  801511:	89 fa                	mov    %edi,%edx
  801513:	89 f1                	mov    %esi,%ecx
  801515:	d3 e2                	shl    %cl,%edx
  801517:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80151b:	88 c1                	mov    %al,%cl
  80151d:	d3 ef                	shr    %cl,%edi
  80151f:	09 d7                	or     %edx,%edi
  801521:	89 f8                	mov    %edi,%eax
  801523:	89 ea                	mov    %ebp,%edx
  801525:	f7 74 24 08          	divl   0x8(%esp)
  801529:	89 d1                	mov    %edx,%ecx
  80152b:	89 c7                	mov    %eax,%edi
  80152d:	f7 64 24 0c          	mull   0xc(%esp)
  801531:	39 d1                	cmp    %edx,%ecx
  801533:	72 17                	jb     80154c <__udivdi3+0x10c>
  801535:	74 09                	je     801540 <__udivdi3+0x100>
  801537:	89 fe                	mov    %edi,%esi
  801539:	31 ff                	xor    %edi,%edi
  80153b:	e9 41 ff ff ff       	jmp    801481 <__udivdi3+0x41>
  801540:	8b 54 24 04          	mov    0x4(%esp),%edx
  801544:	89 f1                	mov    %esi,%ecx
  801546:	d3 e2                	shl    %cl,%edx
  801548:	39 c2                	cmp    %eax,%edx
  80154a:	73 eb                	jae    801537 <__udivdi3+0xf7>
  80154c:	8d 77 ff             	lea    -0x1(%edi),%esi
  80154f:	31 ff                	xor    %edi,%edi
  801551:	e9 2b ff ff ff       	jmp    801481 <__udivdi3+0x41>
  801556:	66 90                	xchg   %ax,%ax
  801558:	31 f6                	xor    %esi,%esi
  80155a:	e9 22 ff ff ff       	jmp    801481 <__udivdi3+0x41>
	...

00801560 <__umoddi3>:
  801560:	55                   	push   %ebp
  801561:	57                   	push   %edi
  801562:	56                   	push   %esi
  801563:	83 ec 20             	sub    $0x20,%esp
  801566:	8b 44 24 30          	mov    0x30(%esp),%eax
  80156a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80156e:	89 44 24 14          	mov    %eax,0x14(%esp)
  801572:	8b 74 24 34          	mov    0x34(%esp),%esi
  801576:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80157a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80157e:	89 c7                	mov    %eax,%edi
  801580:	89 f2                	mov    %esi,%edx
  801582:	85 ed                	test   %ebp,%ebp
  801584:	75 16                	jne    80159c <__umoddi3+0x3c>
  801586:	39 f1                	cmp    %esi,%ecx
  801588:	0f 86 a6 00 00 00    	jbe    801634 <__umoddi3+0xd4>
  80158e:	f7 f1                	div    %ecx
  801590:	89 d0                	mov    %edx,%eax
  801592:	31 d2                	xor    %edx,%edx
  801594:	83 c4 20             	add    $0x20,%esp
  801597:	5e                   	pop    %esi
  801598:	5f                   	pop    %edi
  801599:	5d                   	pop    %ebp
  80159a:	c3                   	ret    
  80159b:	90                   	nop
  80159c:	39 f5                	cmp    %esi,%ebp
  80159e:	0f 87 ac 00 00 00    	ja     801650 <__umoddi3+0xf0>
  8015a4:	0f bd c5             	bsr    %ebp,%eax
  8015a7:	83 f0 1f             	xor    $0x1f,%eax
  8015aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015ae:	0f 84 a8 00 00 00    	je     80165c <__umoddi3+0xfc>
  8015b4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015b8:	d3 e5                	shl    %cl,%ebp
  8015ba:	bf 20 00 00 00       	mov    $0x20,%edi
  8015bf:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8015c3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015c7:	89 f9                	mov    %edi,%ecx
  8015c9:	d3 e8                	shr    %cl,%eax
  8015cb:	09 e8                	or     %ebp,%eax
  8015cd:	89 44 24 18          	mov    %eax,0x18(%esp)
  8015d1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015d5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015d9:	d3 e0                	shl    %cl,%eax
  8015db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015df:	89 f2                	mov    %esi,%edx
  8015e1:	d3 e2                	shl    %cl,%edx
  8015e3:	8b 44 24 14          	mov    0x14(%esp),%eax
  8015e7:	d3 e0                	shl    %cl,%eax
  8015e9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8015ed:	8b 44 24 14          	mov    0x14(%esp),%eax
  8015f1:	89 f9                	mov    %edi,%ecx
  8015f3:	d3 e8                	shr    %cl,%eax
  8015f5:	09 d0                	or     %edx,%eax
  8015f7:	d3 ee                	shr    %cl,%esi
  8015f9:	89 f2                	mov    %esi,%edx
  8015fb:	f7 74 24 18          	divl   0x18(%esp)
  8015ff:	89 d6                	mov    %edx,%esi
  801601:	f7 64 24 0c          	mull   0xc(%esp)
  801605:	89 c5                	mov    %eax,%ebp
  801607:	89 d1                	mov    %edx,%ecx
  801609:	39 d6                	cmp    %edx,%esi
  80160b:	72 67                	jb     801674 <__umoddi3+0x114>
  80160d:	74 75                	je     801684 <__umoddi3+0x124>
  80160f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801613:	29 e8                	sub    %ebp,%eax
  801615:	19 ce                	sbb    %ecx,%esi
  801617:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80161b:	d3 e8                	shr    %cl,%eax
  80161d:	89 f2                	mov    %esi,%edx
  80161f:	89 f9                	mov    %edi,%ecx
  801621:	d3 e2                	shl    %cl,%edx
  801623:	09 d0                	or     %edx,%eax
  801625:	89 f2                	mov    %esi,%edx
  801627:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80162b:	d3 ea                	shr    %cl,%edx
  80162d:	83 c4 20             	add    $0x20,%esp
  801630:	5e                   	pop    %esi
  801631:	5f                   	pop    %edi
  801632:	5d                   	pop    %ebp
  801633:	c3                   	ret    
  801634:	85 c9                	test   %ecx,%ecx
  801636:	75 0b                	jne    801643 <__umoddi3+0xe3>
  801638:	b8 01 00 00 00       	mov    $0x1,%eax
  80163d:	31 d2                	xor    %edx,%edx
  80163f:	f7 f1                	div    %ecx
  801641:	89 c1                	mov    %eax,%ecx
  801643:	89 f0                	mov    %esi,%eax
  801645:	31 d2                	xor    %edx,%edx
  801647:	f7 f1                	div    %ecx
  801649:	89 f8                	mov    %edi,%eax
  80164b:	e9 3e ff ff ff       	jmp    80158e <__umoddi3+0x2e>
  801650:	89 f2                	mov    %esi,%edx
  801652:	83 c4 20             	add    $0x20,%esp
  801655:	5e                   	pop    %esi
  801656:	5f                   	pop    %edi
  801657:	5d                   	pop    %ebp
  801658:	c3                   	ret    
  801659:	8d 76 00             	lea    0x0(%esi),%esi
  80165c:	39 f5                	cmp    %esi,%ebp
  80165e:	72 04                	jb     801664 <__umoddi3+0x104>
  801660:	39 f9                	cmp    %edi,%ecx
  801662:	77 06                	ja     80166a <__umoddi3+0x10a>
  801664:	89 f2                	mov    %esi,%edx
  801666:	29 cf                	sub    %ecx,%edi
  801668:	19 ea                	sbb    %ebp,%edx
  80166a:	89 f8                	mov    %edi,%eax
  80166c:	83 c4 20             	add    $0x20,%esp
  80166f:	5e                   	pop    %esi
  801670:	5f                   	pop    %edi
  801671:	5d                   	pop    %ebp
  801672:	c3                   	ret    
  801673:	90                   	nop
  801674:	89 d1                	mov    %edx,%ecx
  801676:	89 c5                	mov    %eax,%ebp
  801678:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80167c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801680:	eb 8d                	jmp    80160f <__umoddi3+0xaf>
  801682:	66 90                	xchg   %ax,%ax
  801684:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801688:	72 ea                	jb     801674 <__umoddi3+0x114>
  80168a:	89 f1                	mov    %esi,%ecx
  80168c:	eb 81                	jmp    80160f <__umoddi3+0xaf>
