
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 c0 12 00       	mov    $0x12c000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 c0 12 f0       	mov    $0xf012c000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 f0 00 00 00       	call   f010012e <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004b:	83 3d 80 8e 35 f0 00 	cmpl   $0x0,0xf0358e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 8e 35 f0    	mov    %esi,0xf0358e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 b4 83 00 00       	call   f0108418 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 e0 8a 10 f0 	movl   $0xf0108ae0,(%esp)
f010007d:	e8 08 42 00 00       	call   f010428a <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 c9 41 00 00       	call   f0104257 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 55 9f 10 f0 	movl   $0xf0109f55,(%esp)
f0100095:	e8 f0 41 00 00       	call   f010428a <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 88 0b 00 00       	call   f0100c2e <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir
	lcr3(PADDR(kern_pgdir));
f01000ae:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 04 8b 10 	movl   $0xf0108b04,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 4b 8b 10 f0 	movl   $0xf0108b4b,(%esp)
f01000d5:	e8 66 ff ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01000da:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01000df:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01000e2:	e8 31 83 00 00       	call   f0108418 <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 57 8b 10 f0 	movl   $0xf0108b57,(%esp)
f01000f2:	e8 93 41 00 00       	call   f010428a <cprintf>

	lapic_init();
f01000f7:	e8 37 83 00 00       	call   f0108433 <lapic_init>
	env_init_percpu();
f01000fc:	e8 1d 38 00 00       	call   f010391e <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 9e 41 00 00       	call   f01042a4 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 0d 83 00 00       	call   f0108418 <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 90 35 f0    	add    $0xf0359020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100114:	b8 01 00 00 00       	mov    $0x1,%eax
f0100119:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010011d:	c7 04 24 60 e4 12 f0 	movl   $0xf012e460,(%esp)
f0100124:	e8 ae 85 00 00       	call   f01086d7 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100129:	e8 1b 64 00 00       	call   f0106549 <sched_yield>

f010012e <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010012e:	55                   	push   %ebp
f010012f:	89 e5                	mov    %esp,%ebp
f0100131:	53                   	push   %ebx
f0100132:	83 ec 14             	sub    $0x14,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100135:	b8 08 a0 39 f0       	mov    $0xf039a008,%eax
f010013a:	2d 43 71 35 f0       	sub    $0xf0357143,%eax
f010013f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010014a:	00 
f010014b:	c7 04 24 43 71 35 f0 	movl   $0xf0357143,(%esp)
f0100152:	e8 93 7c 00 00       	call   f0107dea <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100157:	e8 6b 05 00 00       	call   f01006c7 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010015c:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100163:	00 
f0100164:	c7 04 24 6d 8b 10 f0 	movl   $0xf0108b6d,(%esp)
f010016b:	e8 1a 41 00 00       	call   f010428a <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100170:	e8 2e 15 00 00       	call   f01016a3 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100175:	e8 ce 37 00 00       	call   f0103948 <env_init>
	trap_init();
f010017a:	e8 22 42 00 00       	call   f01043a1 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010017f:	e8 ac 7f 00 00       	call   f0108130 <mp_init>
	lapic_init();
f0100184:	e8 aa 82 00 00       	call   f0108433 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100189:	e8 52 40 00 00       	call   f01041e0 <pic_init>
f010018e:	c7 04 24 60 e4 12 f0 	movl   $0xf012e460,(%esp)
f0100195:	e8 3d 85 00 00       	call   f01086d7 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010019a:	83 3d 88 8e 35 f0 07 	cmpl   $0x7,0xf0358e88
f01001a1:	77 24                	ja     f01001c7 <i386_init+0x99>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001a3:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001aa:	00 
f01001ab:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f01001b2:	f0 
f01001b3:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01001ba:	00 
f01001bb:	c7 04 24 4b 8b 10 f0 	movl   $0xf0108b4b,(%esp)
f01001c2:	e8 79 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001c7:	b8 5a 80 10 f0       	mov    $0xf010805a,%eax
f01001cc:	2d e0 7f 10 f0       	sub    $0xf0107fe0,%eax
f01001d1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001d5:	c7 44 24 04 e0 7f 10 	movl   $0xf0107fe0,0x4(%esp)
f01001dc:	f0 
f01001dd:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001e4:	e8 4b 7c 00 00       	call   f0107e34 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001e9:	bb 20 90 35 f0       	mov    $0xf0359020,%ebx
f01001ee:	eb 6f                	jmp    f010025f <i386_init+0x131>
		if (c == cpus + cpunum())  // We've started already.
f01001f0:	e8 23 82 00 00       	call   f0108418 <cpunum>
f01001f5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01001fc:	29 c2                	sub    %eax,%edx
f01001fe:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100201:	8d 04 85 20 90 35 f0 	lea    -0xfca6fe0(,%eax,4),%eax
f0100208:	39 c3                	cmp    %eax,%ebx
f010020a:	74 50                	je     f010025c <i386_init+0x12e>

static void boot_aps(void);


void
i386_init(void)
f010020c:	89 d8                	mov    %ebx,%eax
f010020e:	2d 20 90 35 f0       	sub    $0xf0359020,%eax
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
			continue;

		// Tell mpentry.S what stack to use
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100213:	c1 f8 02             	sar    $0x2,%eax
f0100216:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0100219:	8d 14 d0             	lea    (%eax,%edx,8),%edx
f010021c:	89 d1                	mov    %edx,%ecx
f010021e:	c1 e1 05             	shl    $0x5,%ecx
f0100221:	29 d1                	sub    %edx,%ecx
f0100223:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f0100226:	89 d1                	mov    %edx,%ecx
f0100228:	c1 e1 0e             	shl    $0xe,%ecx
f010022b:	29 d1                	sub    %edx,%ecx
f010022d:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f0100230:	8d 44 90 01          	lea    0x1(%eax,%edx,4),%eax
f0100234:	c1 e0 0f             	shl    $0xf,%eax
f0100237:	05 00 a0 35 f0       	add    $0xf035a000,%eax
f010023c:	a3 84 8e 35 f0       	mov    %eax,0xf0358e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100241:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100248:	00 
f0100249:	0f b6 03             	movzbl (%ebx),%eax
f010024c:	89 04 24             	mov    %eax,(%esp)
f010024f:	e8 38 83 00 00       	call   f010858c <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100254:	8b 43 04             	mov    0x4(%ebx),%eax
f0100257:	83 f8 01             	cmp    $0x1,%eax
f010025a:	75 f8                	jne    f0100254 <i386_init+0x126>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010025c:	83 c3 74             	add    $0x74,%ebx
f010025f:	a1 c4 93 35 f0       	mov    0xf03593c4,%eax
f0100264:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010026b:	29 c2                	sub    %eax,%edx
f010026d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100270:	8d 04 85 20 90 35 f0 	lea    -0xfca6fe0(,%eax,4),%eax
f0100277:	39 c3                	cmp    %eax,%ebx
f0100279:	0f 82 71 ff ff ff    	jb     f01001f0 <i386_init+0xc2>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_fairness, ENV_TYPE_USER);
f010027f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100286:	00 
f0100287:	c7 04 24 77 fb 30 f0 	movl   $0xf030fb77,(%esp)
f010028e:	e8 70 39 00 00       	call   f0103c03 <env_create>
	ENV_CREATE(user_fairness, ENV_TYPE_USER);
f0100293:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010029a:	00 
f010029b:	c7 04 24 77 fb 30 f0 	movl   $0xf030fb77,(%esp)
f01002a2:	e8 5c 39 00 00       	call   f0103c03 <env_create>
	ENV_CREATE(user_fairness, ENV_TYPE_USER);
f01002a7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01002ae:	00 
f01002af:	c7 04 24 77 fb 30 f0 	movl   $0xf030fb77,(%esp)
f01002b6:	e8 48 39 00 00       	call   f0103c03 <env_create>
	ENV_CREATE(user_fairness, ENV_TYPE_USER);
f01002bb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01002c2:	00 
f01002c3:	c7 04 24 77 fb 30 f0 	movl   $0xf030fb77,(%esp)
f01002ca:	e8 34 39 00 00       	call   f0103c03 <env_create>
	ENV_CREATE(user_fairness, ENV_TYPE_USER);
f01002cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01002d6:	00 
f01002d7:	c7 04 24 77 fb 30 f0 	movl   $0xf030fb77,(%esp)
f01002de:	e8 20 39 00 00       	call   f0103c03 <env_create>
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01002e3:	e8 61 62 00 00       	call   f0106549 <sched_yield>

f01002e8 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01002e8:	55                   	push   %ebp
f01002e9:	89 e5                	mov    %esp,%ebp
f01002eb:	53                   	push   %ebx
f01002ec:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f01002ef:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002f2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01002f5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01002f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01002fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100300:	c7 04 24 88 8b 10 f0 	movl   $0xf0108b88,(%esp)
f0100307:	e8 7e 3f 00 00       	call   f010428a <cprintf>
	vcprintf(fmt, ap);
f010030c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100310:	8b 45 10             	mov    0x10(%ebp),%eax
f0100313:	89 04 24             	mov    %eax,(%esp)
f0100316:	e8 3c 3f 00 00       	call   f0104257 <vcprintf>
	cprintf("\n");
f010031b:	c7 04 24 55 9f 10 f0 	movl   $0xf0109f55,(%esp)
f0100322:	e8 63 3f 00 00       	call   f010428a <cprintf>
	va_end(ap);
}
f0100327:	83 c4 14             	add    $0x14,%esp
f010032a:	5b                   	pop    %ebx
f010032b:	5d                   	pop    %ebp
f010032c:	c3                   	ret    
f010032d:	00 00                	add    %al,(%eax)
	...

f0100330 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100330:	55                   	push   %ebp
f0100331:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100333:	ba 84 00 00 00       	mov    $0x84,%edx
f0100338:	ec                   	in     (%dx),%al
f0100339:	ec                   	in     (%dx),%al
f010033a:	ec                   	in     (%dx),%al
f010033b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010033c:	5d                   	pop    %ebp
f010033d:	c3                   	ret    

f010033e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010033e:	55                   	push   %ebp
f010033f:	89 e5                	mov    %esp,%ebp
f0100341:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100346:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100347:	a8 01                	test   $0x1,%al
f0100349:	74 08                	je     f0100353 <serial_proc_data+0x15>
f010034b:	b2 f8                	mov    $0xf8,%dl
f010034d:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010034e:	0f b6 c0             	movzbl %al,%eax
f0100351:	eb 05                	jmp    f0100358 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100353:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100358:	5d                   	pop    %ebp
f0100359:	c3                   	ret    

f010035a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010035a:	55                   	push   %ebp
f010035b:	89 e5                	mov    %esp,%ebp
f010035d:	53                   	push   %ebx
f010035e:	83 ec 04             	sub    $0x4,%esp
f0100361:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100363:	eb 29                	jmp    f010038e <cons_intr+0x34>
		if (c == 0)
f0100365:	85 c0                	test   %eax,%eax
f0100367:	74 25                	je     f010038e <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f0100369:	8b 15 24 82 35 f0    	mov    0xf0358224,%edx
f010036f:	88 82 20 80 35 f0    	mov    %al,-0xfca7fe0(%edx)
f0100375:	8d 42 01             	lea    0x1(%edx),%eax
f0100378:	a3 24 82 35 f0       	mov    %eax,0xf0358224
		if (cons.wpos == CONSBUFSIZE)
f010037d:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100382:	75 0a                	jne    f010038e <cons_intr+0x34>
			cons.wpos = 0;
f0100384:	c7 05 24 82 35 f0 00 	movl   $0x0,0xf0358224
f010038b:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010038e:	ff d3                	call   *%ebx
f0100390:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100393:	75 d0                	jne    f0100365 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100395:	83 c4 04             	add    $0x4,%esp
f0100398:	5b                   	pop    %ebx
f0100399:	5d                   	pop    %ebp
f010039a:	c3                   	ret    

f010039b <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010039b:	55                   	push   %ebp
f010039c:	89 e5                	mov    %esp,%ebp
f010039e:	57                   	push   %edi
f010039f:	56                   	push   %esi
f01003a0:	53                   	push   %ebx
f01003a1:	83 ec 2c             	sub    $0x2c,%esp
f01003a4:	89 c6                	mov    %eax,%esi
f01003a6:	bb 01 32 00 00       	mov    $0x3201,%ebx
f01003ab:	bf fd 03 00 00       	mov    $0x3fd,%edi
f01003b0:	eb 05                	jmp    f01003b7 <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01003b2:	e8 79 ff ff ff       	call   f0100330 <delay>
f01003b7:	89 fa                	mov    %edi,%edx
f01003b9:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003ba:	a8 20                	test   $0x20,%al
f01003bc:	75 03                	jne    f01003c1 <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003be:	4b                   	dec    %ebx
f01003bf:	75 f1                	jne    f01003b2 <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01003c1:	89 f2                	mov    %esi,%edx
f01003c3:	89 f0                	mov    %esi,%eax
f01003c5:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003c8:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003cd:	ee                   	out    %al,(%dx)
f01003ce:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003d3:	bf 79 03 00 00       	mov    $0x379,%edi
f01003d8:	eb 05                	jmp    f01003df <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f01003da:	e8 51 ff ff ff       	call   f0100330 <delay>
f01003df:	89 fa                	mov    %edi,%edx
f01003e1:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003e2:	84 c0                	test   %al,%al
f01003e4:	78 03                	js     f01003e9 <cons_putc+0x4e>
f01003e6:	4b                   	dec    %ebx
f01003e7:	75 f1                	jne    f01003da <cons_putc+0x3f>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003e9:	ba 78 03 00 00       	mov    $0x378,%edx
f01003ee:	8a 45 e7             	mov    -0x19(%ebp),%al
f01003f1:	ee                   	out    %al,(%dx)
f01003f2:	b2 7a                	mov    $0x7a,%dl
f01003f4:	b0 0d                	mov    $0xd,%al
f01003f6:	ee                   	out    %al,(%dx)
f01003f7:	b0 08                	mov    $0x8,%al
f01003f9:	ee                   	out    %al,(%dx)
extern unsigned int console_color;
static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01003fa:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f0100400:	75 0a                	jne    f010040c <cons_putc+0x71>
		c |= console_color << 8;
f0100402:	a1 48 e4 12 f0       	mov    0xf012e448,%eax
f0100407:	c1 e0 08             	shl    $0x8,%eax
f010040a:	09 c6                	or     %eax,%esi

	switch (c & 0xff) {
f010040c:	89 f0                	mov    %esi,%eax
f010040e:	25 ff 00 00 00       	and    $0xff,%eax
f0100413:	83 f8 09             	cmp    $0x9,%eax
f0100416:	74 78                	je     f0100490 <cons_putc+0xf5>
f0100418:	83 f8 09             	cmp    $0x9,%eax
f010041b:	7f 0b                	jg     f0100428 <cons_putc+0x8d>
f010041d:	83 f8 08             	cmp    $0x8,%eax
f0100420:	0f 85 9e 00 00 00    	jne    f01004c4 <cons_putc+0x129>
f0100426:	eb 10                	jmp    f0100438 <cons_putc+0x9d>
f0100428:	83 f8 0a             	cmp    $0xa,%eax
f010042b:	74 39                	je     f0100466 <cons_putc+0xcb>
f010042d:	83 f8 0d             	cmp    $0xd,%eax
f0100430:	0f 85 8e 00 00 00    	jne    f01004c4 <cons_putc+0x129>
f0100436:	eb 36                	jmp    f010046e <cons_putc+0xd3>
	case '\b':
		if (crt_pos > 0) {
f0100438:	66 a1 34 82 35 f0    	mov    0xf0358234,%ax
f010043e:	66 85 c0             	test   %ax,%ax
f0100441:	0f 84 e2 00 00 00    	je     f0100529 <cons_putc+0x18e>
			crt_pos--;
f0100447:	48                   	dec    %eax
f0100448:	66 a3 34 82 35 f0    	mov    %ax,0xf0358234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010044e:	0f b7 c0             	movzwl %ax,%eax
f0100451:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100457:	83 ce 20             	or     $0x20,%esi
f010045a:	8b 15 30 82 35 f0    	mov    0xf0358230,%edx
f0100460:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100464:	eb 78                	jmp    f01004de <cons_putc+0x143>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100466:	66 83 05 34 82 35 f0 	addw   $0x50,0xf0358234
f010046d:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010046e:	66 8b 0d 34 82 35 f0 	mov    0xf0358234,%cx
f0100475:	bb 50 00 00 00       	mov    $0x50,%ebx
f010047a:	89 c8                	mov    %ecx,%eax
f010047c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100481:	66 f7 f3             	div    %bx
f0100484:	66 29 d1             	sub    %dx,%cx
f0100487:	66 89 0d 34 82 35 f0 	mov    %cx,0xf0358234
f010048e:	eb 4e                	jmp    f01004de <cons_putc+0x143>
		break;
	case '\t':
		cons_putc(' ');
f0100490:	b8 20 00 00 00       	mov    $0x20,%eax
f0100495:	e8 01 ff ff ff       	call   f010039b <cons_putc>
		cons_putc(' ');
f010049a:	b8 20 00 00 00       	mov    $0x20,%eax
f010049f:	e8 f7 fe ff ff       	call   f010039b <cons_putc>
		cons_putc(' ');
f01004a4:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a9:	e8 ed fe ff ff       	call   f010039b <cons_putc>
		cons_putc(' ');
f01004ae:	b8 20 00 00 00       	mov    $0x20,%eax
f01004b3:	e8 e3 fe ff ff       	call   f010039b <cons_putc>
		cons_putc(' ');
f01004b8:	b8 20 00 00 00       	mov    $0x20,%eax
f01004bd:	e8 d9 fe ff ff       	call   f010039b <cons_putc>
f01004c2:	eb 1a                	jmp    f01004de <cons_putc+0x143>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01004c4:	66 a1 34 82 35 f0    	mov    0xf0358234,%ax
f01004ca:	0f b7 c8             	movzwl %ax,%ecx
f01004cd:	8b 15 30 82 35 f0    	mov    0xf0358230,%edx
f01004d3:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01004d7:	40                   	inc    %eax
f01004d8:	66 a3 34 82 35 f0    	mov    %ax,0xf0358234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01004de:	66 81 3d 34 82 35 f0 	cmpw   $0x7cf,0xf0358234
f01004e5:	cf 07 
f01004e7:	76 40                	jbe    f0100529 <cons_putc+0x18e>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004e9:	a1 30 82 35 f0       	mov    0xf0358230,%eax
f01004ee:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01004f5:	00 
f01004f6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004fc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100500:	89 04 24             	mov    %eax,(%esp)
f0100503:	e8 2c 79 00 00       	call   f0107e34 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100508:	8b 15 30 82 35 f0    	mov    0xf0358230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010050e:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100513:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100519:	40                   	inc    %eax
f010051a:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010051f:	75 f2                	jne    f0100513 <cons_putc+0x178>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100521:	66 83 2d 34 82 35 f0 	subw   $0x50,0xf0358234
f0100528:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100529:	8b 0d 2c 82 35 f0    	mov    0xf035822c,%ecx
f010052f:	b0 0e                	mov    $0xe,%al
f0100531:	89 ca                	mov    %ecx,%edx
f0100533:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100534:	66 8b 35 34 82 35 f0 	mov    0xf0358234,%si
f010053b:	8d 59 01             	lea    0x1(%ecx),%ebx
f010053e:	89 f0                	mov    %esi,%eax
f0100540:	66 c1 e8 08          	shr    $0x8,%ax
f0100544:	89 da                	mov    %ebx,%edx
f0100546:	ee                   	out    %al,(%dx)
f0100547:	b0 0f                	mov    $0xf,%al
f0100549:	89 ca                	mov    %ecx,%edx
f010054b:	ee                   	out    %al,(%dx)
f010054c:	89 f0                	mov    %esi,%eax
f010054e:	89 da                	mov    %ebx,%edx
f0100550:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100551:	83 c4 2c             	add    $0x2c,%esp
f0100554:	5b                   	pop    %ebx
f0100555:	5e                   	pop    %esi
f0100556:	5f                   	pop    %edi
f0100557:	5d                   	pop    %ebp
f0100558:	c3                   	ret    

f0100559 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100559:	55                   	push   %ebp
f010055a:	89 e5                	mov    %esp,%ebp
f010055c:	53                   	push   %ebx
f010055d:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100560:	ba 64 00 00 00       	mov    $0x64,%edx
f0100565:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100566:	a8 01                	test   $0x1,%al
f0100568:	0f 84 d8 00 00 00    	je     f0100646 <kbd_proc_data+0xed>
f010056e:	b2 60                	mov    $0x60,%dl
f0100570:	ec                   	in     (%dx),%al
f0100571:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100573:	3c e0                	cmp    $0xe0,%al
f0100575:	75 11                	jne    f0100588 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f0100577:	83 0d 28 82 35 f0 40 	orl    $0x40,0xf0358228
		return 0;
f010057e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100583:	e9 c3 00 00 00       	jmp    f010064b <kbd_proc_data+0xf2>
	} else if (data & 0x80) {
f0100588:	84 c0                	test   %al,%al
f010058a:	79 33                	jns    f01005bf <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010058c:	8b 0d 28 82 35 f0    	mov    0xf0358228,%ecx
f0100592:	f6 c1 40             	test   $0x40,%cl
f0100595:	75 05                	jne    f010059c <kbd_proc_data+0x43>
f0100597:	88 c2                	mov    %al,%dl
f0100599:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010059c:	0f b6 d2             	movzbl %dl,%edx
f010059f:	8a 82 e0 8b 10 f0    	mov    -0xfef7420(%edx),%al
f01005a5:	83 c8 40             	or     $0x40,%eax
f01005a8:	0f b6 c0             	movzbl %al,%eax
f01005ab:	f7 d0                	not    %eax
f01005ad:	21 c1                	and    %eax,%ecx
f01005af:	89 0d 28 82 35 f0    	mov    %ecx,0xf0358228
		return 0;
f01005b5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01005ba:	e9 8c 00 00 00       	jmp    f010064b <kbd_proc_data+0xf2>
	} else if (shift & E0ESC) {
f01005bf:	8b 0d 28 82 35 f0    	mov    0xf0358228,%ecx
f01005c5:	f6 c1 40             	test   $0x40,%cl
f01005c8:	74 0e                	je     f01005d8 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01005ca:	88 c2                	mov    %al,%dl
f01005cc:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01005cf:	83 e1 bf             	and    $0xffffffbf,%ecx
f01005d2:	89 0d 28 82 35 f0    	mov    %ecx,0xf0358228
	}

	shift |= shiftcode[data];
f01005d8:	0f b6 d2             	movzbl %dl,%edx
f01005db:	0f b6 82 e0 8b 10 f0 	movzbl -0xfef7420(%edx),%eax
f01005e2:	0b 05 28 82 35 f0    	or     0xf0358228,%eax
	shift ^= togglecode[data];
f01005e8:	0f b6 8a e0 8c 10 f0 	movzbl -0xfef7320(%edx),%ecx
f01005ef:	31 c8                	xor    %ecx,%eax
f01005f1:	a3 28 82 35 f0       	mov    %eax,0xf0358228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005f6:	89 c1                	mov    %eax,%ecx
f01005f8:	83 e1 03             	and    $0x3,%ecx
f01005fb:	8b 0c 8d e0 8d 10 f0 	mov    -0xfef7220(,%ecx,4),%ecx
f0100602:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100606:	a8 08                	test   $0x8,%al
f0100608:	74 18                	je     f0100622 <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f010060a:	8d 53 9f             	lea    -0x61(%ebx),%edx
f010060d:	83 fa 19             	cmp    $0x19,%edx
f0100610:	77 05                	ja     f0100617 <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f0100612:	83 eb 20             	sub    $0x20,%ebx
f0100615:	eb 0b                	jmp    f0100622 <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f0100617:	8d 53 bf             	lea    -0x41(%ebx),%edx
f010061a:	83 fa 19             	cmp    $0x19,%edx
f010061d:	77 03                	ja     f0100622 <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f010061f:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100622:	f7 d0                	not    %eax
f0100624:	a8 06                	test   $0x6,%al
f0100626:	75 23                	jne    f010064b <kbd_proc_data+0xf2>
f0100628:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010062e:	75 1b                	jne    f010064b <kbd_proc_data+0xf2>
		cprintf("Rebooting!\n");
f0100630:	c7 04 24 a2 8b 10 f0 	movl   $0xf0108ba2,(%esp)
f0100637:	e8 4e 3c 00 00       	call   f010428a <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010063c:	ba 92 00 00 00       	mov    $0x92,%edx
f0100641:	b0 03                	mov    $0x3,%al
f0100643:	ee                   	out    %al,(%dx)
f0100644:	eb 05                	jmp    f010064b <kbd_proc_data+0xf2>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100646:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010064b:	89 d8                	mov    %ebx,%eax
f010064d:	83 c4 14             	add    $0x14,%esp
f0100650:	5b                   	pop    %ebx
f0100651:	5d                   	pop    %ebp
f0100652:	c3                   	ret    

f0100653 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100653:	55                   	push   %ebp
f0100654:	89 e5                	mov    %esp,%ebp
f0100656:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100659:	80 3d 00 80 35 f0 00 	cmpb   $0x0,0xf0358000
f0100660:	74 0a                	je     f010066c <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100662:	b8 3e 03 10 f0       	mov    $0xf010033e,%eax
f0100667:	e8 ee fc ff ff       	call   f010035a <cons_intr>
}
f010066c:	c9                   	leave  
f010066d:	c3                   	ret    

f010066e <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010066e:	55                   	push   %ebp
f010066f:	89 e5                	mov    %esp,%ebp
f0100671:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100674:	b8 59 05 10 f0       	mov    $0xf0100559,%eax
f0100679:	e8 dc fc ff ff       	call   f010035a <cons_intr>
}
f010067e:	c9                   	leave  
f010067f:	c3                   	ret    

f0100680 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100680:	55                   	push   %ebp
f0100681:	89 e5                	mov    %esp,%ebp
f0100683:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100686:	e8 c8 ff ff ff       	call   f0100653 <serial_intr>
	kbd_intr();
f010068b:	e8 de ff ff ff       	call   f010066e <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100690:	8b 15 20 82 35 f0    	mov    0xf0358220,%edx
f0100696:	3b 15 24 82 35 f0    	cmp    0xf0358224,%edx
f010069c:	74 22                	je     f01006c0 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f010069e:	0f b6 82 20 80 35 f0 	movzbl -0xfca7fe0(%edx),%eax
f01006a5:	42                   	inc    %edx
f01006a6:	89 15 20 82 35 f0    	mov    %edx,0xf0358220
		if (cons.rpos == CONSBUFSIZE)
f01006ac:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01006b2:	75 11                	jne    f01006c5 <cons_getc+0x45>
			cons.rpos = 0;
f01006b4:	c7 05 20 82 35 f0 00 	movl   $0x0,0xf0358220
f01006bb:	00 00 00 
f01006be:	eb 05                	jmp    f01006c5 <cons_getc+0x45>
		return c;
	}
	return 0;
f01006c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01006c5:	c9                   	leave  
f01006c6:	c3                   	ret    

f01006c7 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01006c7:	55                   	push   %ebp
f01006c8:	89 e5                	mov    %esp,%ebp
f01006ca:	57                   	push   %edi
f01006cb:	56                   	push   %esi
f01006cc:	53                   	push   %ebx
f01006cd:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01006d0:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f01006d7:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006de:	5a a5 
	if (*cp != 0xA55A) {
f01006e0:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f01006e6:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006ea:	74 11                	je     f01006fd <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006ec:	c7 05 2c 82 35 f0 b4 	movl   $0x3b4,0xf035822c
f01006f3:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006f6:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006fb:	eb 16                	jmp    f0100713 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006fd:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100704:	c7 05 2c 82 35 f0 d4 	movl   $0x3d4,0xf035822c
f010070b:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010070e:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100713:	8b 0d 2c 82 35 f0    	mov    0xf035822c,%ecx
f0100719:	b0 0e                	mov    $0xe,%al
f010071b:	89 ca                	mov    %ecx,%edx
f010071d:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010071e:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100721:	89 da                	mov    %ebx,%edx
f0100723:	ec                   	in     (%dx),%al
f0100724:	0f b6 f8             	movzbl %al,%edi
f0100727:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010072a:	b0 0f                	mov    $0xf,%al
f010072c:	89 ca                	mov    %ecx,%edx
f010072e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010072f:	89 da                	mov    %ebx,%edx
f0100731:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100732:	89 35 30 82 35 f0    	mov    %esi,0xf0358230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100738:	0f b6 d8             	movzbl %al,%ebx
f010073b:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010073d:	66 89 3d 34 82 35 f0 	mov    %di,0xf0358234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f0100744:	e8 25 ff ff ff       	call   f010066e <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100749:	0f b7 05 a8 e3 12 f0 	movzwl 0xf012e3a8,%eax
f0100750:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100755:	89 04 24             	mov    %eax,(%esp)
f0100758:	e8 0f 3a 00 00       	call   f010416c <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010075d:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100762:	b0 00                	mov    $0x0,%al
f0100764:	89 da                	mov    %ebx,%edx
f0100766:	ee                   	out    %al,(%dx)
f0100767:	b2 fb                	mov    $0xfb,%dl
f0100769:	b0 80                	mov    $0x80,%al
f010076b:	ee                   	out    %al,(%dx)
f010076c:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100771:	b0 0c                	mov    $0xc,%al
f0100773:	89 ca                	mov    %ecx,%edx
f0100775:	ee                   	out    %al,(%dx)
f0100776:	b2 f9                	mov    $0xf9,%dl
f0100778:	b0 00                	mov    $0x0,%al
f010077a:	ee                   	out    %al,(%dx)
f010077b:	b2 fb                	mov    $0xfb,%dl
f010077d:	b0 03                	mov    $0x3,%al
f010077f:	ee                   	out    %al,(%dx)
f0100780:	b2 fc                	mov    $0xfc,%dl
f0100782:	b0 00                	mov    $0x0,%al
f0100784:	ee                   	out    %al,(%dx)
f0100785:	b2 f9                	mov    $0xf9,%dl
f0100787:	b0 01                	mov    $0x1,%al
f0100789:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010078a:	b2 fd                	mov    $0xfd,%dl
f010078c:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010078d:	3c ff                	cmp    $0xff,%al
f010078f:	0f 95 45 e7          	setne  -0x19(%ebp)
f0100793:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100796:	a2 00 80 35 f0       	mov    %al,0xf0358000
f010079b:	89 da                	mov    %ebx,%edx
f010079d:	ec                   	in     (%dx),%al
f010079e:	89 ca                	mov    %ecx,%edx
f01007a0:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007a1:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f01007a5:	75 0c                	jne    f01007b3 <cons_init+0xec>
		cprintf("Serial port does not exist!\n");
f01007a7:	c7 04 24 ae 8b 10 f0 	movl   $0xf0108bae,(%esp)
f01007ae:	e8 d7 3a 00 00       	call   f010428a <cprintf>
}
f01007b3:	83 c4 2c             	add    $0x2c,%esp
f01007b6:	5b                   	pop    %ebx
f01007b7:	5e                   	pop    %esi
f01007b8:	5f                   	pop    %edi
f01007b9:	5d                   	pop    %ebp
f01007ba:	c3                   	ret    

f01007bb <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007bb:	55                   	push   %ebp
f01007bc:	89 e5                	mov    %esp,%ebp
f01007be:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007c1:	8b 45 08             	mov    0x8(%ebp),%eax
f01007c4:	e8 d2 fb ff ff       	call   f010039b <cons_putc>
}
f01007c9:	c9                   	leave  
f01007ca:	c3                   	ret    

f01007cb <getchar>:

int
getchar(void)
{
f01007cb:	55                   	push   %ebp
f01007cc:	89 e5                	mov    %esp,%ebp
f01007ce:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007d1:	e8 aa fe ff ff       	call   f0100680 <cons_getc>
f01007d6:	85 c0                	test   %eax,%eax
f01007d8:	74 f7                	je     f01007d1 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007da:	c9                   	leave  
f01007db:	c3                   	ret    

f01007dc <iscons>:

int
iscons(int fdnum)
{
f01007dc:	55                   	push   %ebp
f01007dd:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007df:	b8 01 00 00 00       	mov    $0x1,%eax
f01007e4:	5d                   	pop    %ebp
f01007e5:	c3                   	ret    
	...

f01007e8 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007e8:	55                   	push   %ebp
f01007e9:	89 e5                	mov    %esp,%ebp
f01007eb:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007ee:	c7 04 24 f0 8d 10 f0 	movl   $0xf0108df0,(%esp)
f01007f5:	e8 90 3a 00 00       	call   f010428a <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007fa:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100801:	00 
f0100802:	c7 04 24 4c 8f 10 f0 	movl   $0xf0108f4c,(%esp)
f0100809:	e8 7c 3a 00 00       	call   f010428a <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010080e:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100815:	00 
f0100816:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010081d:	f0 
f010081e:	c7 04 24 74 8f 10 f0 	movl   $0xf0108f74,(%esp)
f0100825:	e8 60 3a 00 00       	call   f010428a <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010082a:	c7 44 24 08 d6 8a 10 	movl   $0x108ad6,0x8(%esp)
f0100831:	00 
f0100832:	c7 44 24 04 d6 8a 10 	movl   $0xf0108ad6,0x4(%esp)
f0100839:	f0 
f010083a:	c7 04 24 98 8f 10 f0 	movl   $0xf0108f98,(%esp)
f0100841:	e8 44 3a 00 00       	call   f010428a <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100846:	c7 44 24 08 43 71 35 	movl   $0x357143,0x8(%esp)
f010084d:	00 
f010084e:	c7 44 24 04 43 71 35 	movl   $0xf0357143,0x4(%esp)
f0100855:	f0 
f0100856:	c7 04 24 bc 8f 10 f0 	movl   $0xf0108fbc,(%esp)
f010085d:	e8 28 3a 00 00       	call   f010428a <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100862:	c7 44 24 08 08 a0 39 	movl   $0x39a008,0x8(%esp)
f0100869:	00 
f010086a:	c7 44 24 04 08 a0 39 	movl   $0xf039a008,0x4(%esp)
f0100871:	f0 
f0100872:	c7 04 24 e0 8f 10 f0 	movl   $0xf0108fe0,(%esp)
f0100879:	e8 0c 3a 00 00       	call   f010428a <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010087e:	b8 07 a4 39 f0       	mov    $0xf039a407,%eax
f0100883:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100888:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010088d:	89 c2                	mov    %eax,%edx
f010088f:	85 c0                	test   %eax,%eax
f0100891:	79 06                	jns    f0100899 <mon_kerninfo+0xb1>
f0100893:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100899:	c1 fa 0a             	sar    $0xa,%edx
f010089c:	89 54 24 04          	mov    %edx,0x4(%esp)
f01008a0:	c7 04 24 04 90 10 f0 	movl   $0xf0109004,(%esp)
f01008a7:	e8 de 39 00 00       	call   f010428a <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b1:	c9                   	leave  
f01008b2:	c3                   	ret    

f01008b3 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01008b3:	55                   	push   %ebp
f01008b4:	89 e5                	mov    %esp,%ebp
f01008b6:	53                   	push   %ebx
f01008b7:	83 ec 14             	sub    $0x14,%esp
f01008ba:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01008bf:	8b 83 a4 92 10 f0    	mov    -0xfef6d5c(%ebx),%eax
f01008c5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008c9:	8b 83 a0 92 10 f0    	mov    -0xfef6d60(%ebx),%eax
f01008cf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008d3:	c7 04 24 09 8e 10 f0 	movl   $0xf0108e09,(%esp)
f01008da:	e8 ab 39 00 00       	call   f010428a <cprintf>
f01008df:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01008e2:	83 fb 3c             	cmp    $0x3c,%ebx
f01008e5:	75 d8                	jne    f01008bf <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01008e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ec:	83 c4 14             	add    $0x14,%esp
f01008ef:	5b                   	pop    %ebx
f01008f0:	5d                   	pop    %ebp
f01008f1:	c3                   	ret    

f01008f2 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008f2:	55                   	push   %ebp
f01008f3:	89 e5                	mov    %esp,%ebp
f01008f5:	57                   	push   %edi
f01008f6:	56                   	push   %esi
f01008f7:	53                   	push   %ebx
f01008f8:	83 ec 4c             	sub    $0x4c,%esp
	// Your code here.
	unsigned int *ebp = (unsigned int*) read_ebp();
f01008fb:	89 ee                	mov    %ebp,%esi
	int i;
	cprintf("Stack backtrace:\n");
f01008fd:	c7 04 24 12 8e 10 f0 	movl   $0xf0108e12,(%esp)
f0100904:	e8 81 39 00 00       	call   f010428a <cprintf>
	while (ebp != 0) {
f0100909:	e9 a2 00 00 00       	jmp    f01009b0 <mon_backtrace+0xbe>
		unsigned int eip = *(ebp + 1);
f010090e:	8b 7e 04             	mov    0x4(%esi),%edi
		cprintf("  %rebp %08x  %reip %08x  %rargs", 0x0c, ebp, 0x0a, eip, 0x09);
f0100911:	c7 44 24 14 09 00 00 	movl   $0x9,0x14(%esp)
f0100918:	00 
f0100919:	89 7c 24 10          	mov    %edi,0x10(%esp)
f010091d:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
f0100924:	00 
f0100925:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100929:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
f0100930:	00 
f0100931:	c7 04 24 30 90 10 f0 	movl   $0xf0109030,(%esp)
f0100938:	e8 4d 39 00 00       	call   f010428a <cprintf>
		for (i = 0; i < 5; i++) {
f010093d:	bb 00 00 00 00       	mov    $0x0,%ebx
			cprintf(" %08x", *(ebp + i + 2));
f0100942:	8b 44 9e 08          	mov    0x8(%esi,%ebx,4),%eax
f0100946:	89 44 24 04          	mov    %eax,0x4(%esp)
f010094a:	c7 04 24 24 8e 10 f0 	movl   $0xf0108e24,(%esp)
f0100951:	e8 34 39 00 00       	call   f010428a <cprintf>
	int i;
	cprintf("Stack backtrace:\n");
	while (ebp != 0) {
		unsigned int eip = *(ebp + 1);
		cprintf("  %rebp %08x  %reip %08x  %rargs", 0x0c, ebp, 0x0a, eip, 0x09);
		for (i = 0; i < 5; i++) {
f0100956:	43                   	inc    %ebx
f0100957:	83 fb 05             	cmp    $0x5,%ebx
f010095a:	75 e6                	jne    f0100942 <mon_backtrace+0x50>
			cprintf(" %08x", *(ebp + i + 2));
		}
		cprintf("%r\n", 0x07);
f010095c:	c7 44 24 04 07 00 00 	movl   $0x7,0x4(%esp)
f0100963:	00 
f0100964:	c7 04 24 2a 8e 10 f0 	movl   $0xf0108e2a,(%esp)
f010096b:	e8 1a 39 00 00       	call   f010428a <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
f0100970:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100973:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100977:	89 3c 24             	mov    %edi,(%esp)
f010097a:	e8 a2 69 00 00       	call   f0107321 <debuginfo_eip>
		cprintf("         %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
f010097f:	2b 7d e0             	sub    -0x20(%ebp),%edi
f0100982:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0100986:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100989:	89 44 24 10          	mov    %eax,0x10(%esp)
f010098d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100990:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100994:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100997:	89 44 24 08          	mov    %eax,0x8(%esp)
f010099b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010099e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009a2:	c7 04 24 2e 8e 10 f0 	movl   $0xf0108e2e,(%esp)
f01009a9:	e8 dc 38 00 00       	call   f010428a <cprintf>
		ebp = (unsigned int*)*ebp;
f01009ae:	8b 36                	mov    (%esi),%esi
{
	// Your code here.
	unsigned int *ebp = (unsigned int*) read_ebp();
	int i;
	cprintf("Stack backtrace:\n");
	while (ebp != 0) {
f01009b0:	85 f6                	test   %esi,%esi
f01009b2:	0f 85 56 ff ff ff    	jne    f010090e <mon_backtrace+0x1c>
		debuginfo_eip(eip, &info);
		cprintf("         %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
		ebp = (unsigned int*)*ebp;
	}
	return 0;
}
f01009b8:	b8 00 00 00 00       	mov    $0x0,%eax
f01009bd:	83 c4 4c             	add    $0x4c,%esp
f01009c0:	5b                   	pop    %ebx
f01009c1:	5e                   	pop    %esi
f01009c2:	5f                   	pop    %edi
f01009c3:	5d                   	pop    %ebp
f01009c4:	c3                   	ret    

f01009c5 <xtoi>:

uint32_t xtoi(char *s) {
f01009c5:	55                   	push   %ebp
f01009c6:	89 e5                	mov    %esp,%ebp
f01009c8:	56                   	push   %esi
f01009c9:	53                   	push   %ebx
f01009ca:	83 ec 10             	sub    $0x10,%esp
f01009cd:	8b 75 08             	mov    0x8(%ebp),%esi
	uint32_t result = 0;
f01009d0:	89 f1                	mov    %esi,%ecx
f01009d2:	b8 00 00 00 00       	mov    $0x0,%eax
	int i;
	for (i = 2; s[i] != '\0'; i++) {
f01009d7:	eb 5d                	jmp    f0100a36 <xtoi+0x71>
		if (s[i] >= '0' && s[i] <= '9') result = result * 16 + s[i] - '0';
f01009d9:	8d 5a d0             	lea    -0x30(%edx),%ebx
f01009dc:	80 fb 09             	cmp    $0x9,%bl
f01009df:	77 0c                	ja     f01009ed <xtoi+0x28>
f01009e1:	c1 e0 04             	shl    $0x4,%eax
f01009e4:	0f be d2             	movsbl %dl,%edx
f01009e7:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
f01009eb:	eb 48                	jmp    f0100a35 <xtoi+0x70>
		else if (s[i] >= 'a' && s[i] <= 'f') result = result * 16 + s[i] - 'a' + 10;
f01009ed:	8d 5a 9f             	lea    -0x61(%edx),%ebx
f01009f0:	80 fb 05             	cmp    $0x5,%bl
f01009f3:	77 0c                	ja     f0100a01 <xtoi+0x3c>
f01009f5:	c1 e0 04             	shl    $0x4,%eax
f01009f8:	0f be d2             	movsbl %dl,%edx
f01009fb:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
f01009ff:	eb 34                	jmp    f0100a35 <xtoi+0x70>
		else if (s[i] >= 'A' && s[i] <= 'F') result = result * 16 + s[i] - 'A' + 10;
f0100a01:	8d 5a bf             	lea    -0x41(%edx),%ebx
f0100a04:	80 fb 05             	cmp    $0x5,%bl
f0100a07:	77 0c                	ja     f0100a15 <xtoi+0x50>
f0100a09:	c1 e0 04             	shl    $0x4,%eax
f0100a0c:	0f be d2             	movsbl %dl,%edx
f0100a0f:	8d 44 10 c9          	lea    -0x37(%eax,%edx,1),%eax
f0100a13:	eb 20                	jmp    f0100a35 <xtoi+0x70>
		else panic("xtoi: invalid string %s!", s);
f0100a15:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100a19:	c7 44 24 08 47 8e 10 	movl   $0xf0108e47,0x8(%esp)
f0100a20:	f0 
f0100a21:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f0100a28:	00 
f0100a29:	c7 04 24 60 8e 10 f0 	movl   $0xf0108e60,(%esp)
f0100a30:	e8 0b f6 ff ff       	call   f0100040 <_panic>
f0100a35:	41                   	inc    %ecx
}

uint32_t xtoi(char *s) {
	uint32_t result = 0;
	int i;
	for (i = 2; s[i] != '\0'; i++) {
f0100a36:	8a 51 02             	mov    0x2(%ecx),%dl
f0100a39:	84 d2                	test   %dl,%dl
f0100a3b:	75 9c                	jne    f01009d9 <xtoi+0x14>
		else if (s[i] >= 'a' && s[i] <= 'f') result = result * 16 + s[i] - 'a' + 10;
		else if (s[i] >= 'A' && s[i] <= 'F') result = result * 16 + s[i] - 'A' + 10;
		else panic("xtoi: invalid string %s!", s);
	}
	return result;
}
f0100a3d:	83 c4 10             	add    $0x10,%esp
f0100a40:	5b                   	pop    %ebx
f0100a41:	5e                   	pop    %esi
f0100a42:	5d                   	pop    %ebp
f0100a43:	c3                   	ret    

f0100a44 <print_pte_info>:

void print_pte_info(pte_t *ppte) {
f0100a44:	55                   	push   %ebp
f0100a45:	89 e5                	mov    %esp,%ebp
f0100a47:	83 ec 28             	sub    $0x28,%esp
	cprintf("Phys memory: 0x%08x, PTE_P: %x, PTE_W: %x, PTE_U: %x\n", PTE_ADDR(*ppte), *ppte & PTE_P, *ppte & PTE_W, *ppte & PTE_U);
f0100a4a:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a4d:	8b 00                	mov    (%eax),%eax
f0100a4f:	89 c2                	mov    %eax,%edx
f0100a51:	83 e2 04             	and    $0x4,%edx
f0100a54:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100a58:	89 c2                	mov    %eax,%edx
f0100a5a:	83 e2 02             	and    $0x2,%edx
f0100a5d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100a61:	89 c2                	mov    %eax,%edx
f0100a63:	83 e2 01             	and    $0x1,%edx
f0100a66:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100a6a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a6f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a73:	c7 04 24 54 90 10 f0 	movl   $0xf0109054,(%esp)
f0100a7a:	e8 0b 38 00 00       	call   f010428a <cprintf>
}
f0100a7f:	c9                   	leave  
f0100a80:	c3                   	ret    

f0100a81 <setperm>:
		} else cprintf("page not exist: %x\n", va);
	}
	return 0;
}

int setperm(int argc, char **argv, struct Trapframe *tf) {
f0100a81:	55                   	push   %ebp
f0100a82:	89 e5                	mov    %esp,%ebp
f0100a84:	57                   	push   %edi
f0100a85:	56                   	push   %esi
f0100a86:	53                   	push   %ebx
f0100a87:	83 ec 1c             	sub    $0x1c,%esp
f0100a8a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (argc == 1) {
f0100a8d:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100a91:	75 11                	jne    f0100aa4 <setperm+0x23>
		cprintf("Usage: setperm 0xaddr [(clear | set) [P | W | U] | change 0x<perm> ]\n");
f0100a93:	c7 04 24 8c 90 10 f0 	movl   $0xf010908c,(%esp)
f0100a9a:	e8 eb 37 00 00       	call   f010428a <cprintf>
		return 0;
f0100a9f:	e9 a9 00 00 00       	jmp    f0100b4d <setperm+0xcc>
	}
	uint32_t addr = xtoi(argv[1]);
f0100aa4:	8b 43 04             	mov    0x4(%ebx),%eax
f0100aa7:	89 04 24             	mov    %eax,(%esp)
f0100aaa:	e8 16 ff ff ff       	call   f01009c5 <xtoi>
f0100aaf:	89 c7                	mov    %eax,%edi
	pte_t *ppte = pgdir_walk(kern_pgdir, (void *)addr, 1);
f0100ab1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100ab8:	00 
f0100ab9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100abd:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0100ac2:	89 04 24             	mov    %eax,(%esp)
f0100ac5:	e8 bf 08 00 00       	call   f0101389 <pgdir_walk>
f0100aca:	89 c6                	mov    %eax,%esi
	uint32_t perm = 0;
	if (argv[2][1] == 'h') { //for change
f0100acc:	8b 43 08             	mov    0x8(%ebx),%eax
f0100acf:	8a 40 01             	mov    0x1(%eax),%al
f0100ad2:	3c 68                	cmp    $0x68,%al
f0100ad4:	75 19                	jne    f0100aef <setperm+0x6e>
		perm = xtoi(argv[3]);
f0100ad6:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100ad9:	89 04 24             	mov    %eax,(%esp)
f0100adc:	e8 e4 fe ff ff       	call   f01009c5 <xtoi>
		*ppte = (*ppte & 0xfff8) | perm;
f0100ae1:	8b 16                	mov    (%esi),%edx
f0100ae3:	81 e2 f8 ff 00 00    	and    $0xfff8,%edx
f0100ae9:	09 d0                	or     %edx,%eax
f0100aeb:	89 06                	mov    %eax,(%esi)
f0100aed:	eb 46                	jmp    f0100b35 <setperm+0xb4>
	}
	else {
		if (argv[3][0] == 'P') perm = PTE_P;
f0100aef:	8b 53 0c             	mov    0xc(%ebx),%edx
f0100af2:	8a 12                	mov    (%edx),%dl
		if (argv[3][0] == 'W') perm = PTE_W;
f0100af4:	80 fa 57             	cmp    $0x57,%dl
f0100af7:	74 10                	je     f0100b09 <setperm+0x88>
		if (argv[3][0] == 'U') perm = PTE_U;
f0100af9:	80 fa 55             	cmp    $0x55,%dl
f0100afc:	74 12                	je     f0100b10 <setperm+0x8f>
		cprintf("Usage: setperm 0xaddr [(clear | set) [P | W | U] | change 0x<perm> ]\n");
		return 0;
	}
	uint32_t addr = xtoi(argv[1]);
	pte_t *ppte = pgdir_walk(kern_pgdir, (void *)addr, 1);
	uint32_t perm = 0;
f0100afe:	80 fa 50             	cmp    $0x50,%dl
f0100b01:	0f 94 c2             	sete   %dl
f0100b04:	0f b6 d2             	movzbl %dl,%edx
f0100b07:	eb 0c                	jmp    f0100b15 <setperm+0x94>
		perm = xtoi(argv[3]);
		*ppte = (*ppte & 0xfff8) | perm;
	}
	else {
		if (argv[3][0] == 'P') perm = PTE_P;
		if (argv[3][0] == 'W') perm = PTE_W;
f0100b09:	ba 02 00 00 00       	mov    $0x2,%edx
f0100b0e:	eb 05                	jmp    f0100b15 <setperm+0x94>
		if (argv[3][0] == 'U') perm = PTE_U;
f0100b10:	ba 04 00 00 00       	mov    $0x4,%edx
		if (argv[2][1] == 'l') *ppte = *ppte & ~perm; // for clear
f0100b15:	3c 6c                	cmp    $0x6c,%al
f0100b17:	75 06                	jne    f0100b1f <setperm+0x9e>
f0100b19:	f7 d2                	not    %edx
f0100b1b:	21 16                	and    %edx,(%esi)
f0100b1d:	eb 16                	jmp    f0100b35 <setperm+0xb4>
		else if (argv[2][1] == 'e') *ppte = *ppte | perm; // for set
f0100b1f:	3c 65                	cmp    $0x65,%al
f0100b21:	75 04                	jne    f0100b27 <setperm+0xa6>
f0100b23:	09 16                	or     %edx,(%esi)
f0100b25:	eb 0e                	jmp    f0100b35 <setperm+0xb4>
		else {
			cprintf("Parameters error!\nUsage: setperm 0xaddr [(clear | set) [P | W | U] | change <perm> ]\n");
f0100b27:	c7 04 24 d4 90 10 f0 	movl   $0xf01090d4,(%esp)
f0100b2e:	e8 57 37 00 00       	call   f010428a <cprintf>
			return 0;
f0100b33:	eb 18                	jmp    f0100b4d <setperm+0xcc>
		}
	}
	cprintf("setperm success.\npage of 0x%x: ", addr);
f0100b35:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100b39:	c7 04 24 2c 91 10 f0 	movl   $0xf010912c,(%esp)
f0100b40:	e8 45 37 00 00       	call   f010428a <cprintf>
	print_pte_info(ppte);
f0100b45:	89 34 24             	mov    %esi,(%esp)
f0100b48:	e8 f7 fe ff ff       	call   f0100a44 <print_pte_info>
	return 0;
}
f0100b4d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b52:	83 c4 1c             	add    $0x1c,%esp
f0100b55:	5b                   	pop    %ebx
f0100b56:	5e                   	pop    %esi
f0100b57:	5f                   	pop    %edi
f0100b58:	5d                   	pop    %ebp
f0100b59:	c3                   	ret    

f0100b5a <showmappings>:
	cprintf("Phys memory: 0x%08x, PTE_P: %x, PTE_W: %x, PTE_U: %x\n", PTE_ADDR(*ppte), *ppte & PTE_P, *ppte & PTE_W, *ppte & PTE_U);
}

int
showmappings(int argc, char **argv, struct Trapframe *tf)
{
f0100b5a:	55                   	push   %ebp
f0100b5b:	89 e5                	mov    %esp,%ebp
f0100b5d:	57                   	push   %edi
f0100b5e:	56                   	push   %esi
f0100b5f:	53                   	push   %ebx
f0100b60:	83 ec 1c             	sub    $0x1c,%esp
f0100b63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (argc != 3) {
f0100b66:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100b6a:	74 11                	je     f0100b7d <showmappings+0x23>
		cprintf("Usage: showmappings 0xbegin 0xend\nshow page mappings from begin to end.\n");
f0100b6c:	c7 04 24 4c 91 10 f0 	movl   $0xf010914c,(%esp)
f0100b73:	e8 12 37 00 00       	call   f010428a <cprintf>
		return 0;
f0100b78:	e9 a4 00 00 00       	jmp    f0100c21 <showmappings+0xc7>
	}
	uint32_t va = xtoi(argv[1]), vend = xtoi(argv[2]);
f0100b7d:	8b 43 04             	mov    0x4(%ebx),%eax
f0100b80:	89 04 24             	mov    %eax,(%esp)
f0100b83:	e8 3d fe ff ff       	call   f01009c5 <xtoi>
f0100b88:	89 c6                	mov    %eax,%esi
f0100b8a:	8b 43 08             	mov    0x8(%ebx),%eax
f0100b8d:	89 04 24             	mov    %eax,(%esp)
f0100b90:	e8 30 fe ff ff       	call   f01009c5 <xtoi>
f0100b95:	89 c7                	mov    %eax,%edi
	cprintf("begin: %x, end: %x\n", va, vend);
f0100b97:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b9b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b9f:	c7 04 24 6f 8e 10 f0 	movl   $0xf0108e6f,(%esp)
f0100ba6:	e8 df 36 00 00       	call   f010428a <cprintf>
	for (; va <= vend; va += PGSIZE) {
f0100bab:	eb 70                	jmp    f0100c1d <showmappings+0xc3>
		pte_t *ppte = pgdir_walk(kern_pgdir, (void *)va, 1);
f0100bad:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100bb4:	00 
f0100bb5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100bb9:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0100bbe:	89 04 24             	mov    %eax,(%esp)
f0100bc1:	e8 c3 07 00 00       	call   f0101389 <pgdir_walk>
f0100bc6:	89 c3                	mov    %eax,%ebx
		if (!ppte) panic("showmappings: creating page error!");
f0100bc8:	85 c0                	test   %eax,%eax
f0100bca:	75 1c                	jne    f0100be8 <showmappings+0x8e>
f0100bcc:	c7 44 24 08 98 91 10 	movl   $0xf0109198,0x8(%esp)
f0100bd3:	f0 
f0100bd4:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
f0100bdb:	00 
f0100bdc:	c7 04 24 60 8e 10 f0 	movl   $0xf0108e60,(%esp)
f0100be3:	e8 58 f4 ff ff       	call   f0100040 <_panic>
		if (*ppte & PTE_P) {
f0100be8:	f6 00 01             	testb  $0x1,(%eax)
f0100beb:	74 1a                	je     f0100c07 <showmappings+0xad>
			cprintf("page of 0x%x: ", va);
f0100bed:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100bf1:	c7 04 24 83 8e 10 f0 	movl   $0xf0108e83,(%esp)
f0100bf8:	e8 8d 36 00 00       	call   f010428a <cprintf>
			print_pte_info(ppte);
f0100bfd:	89 1c 24             	mov    %ebx,(%esp)
f0100c00:	e8 3f fe ff ff       	call   f0100a44 <print_pte_info>
f0100c05:	eb 10                	jmp    f0100c17 <showmappings+0xbd>
		} else cprintf("page not exist: %x\n", va);
f0100c07:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c0b:	c7 04 24 92 8e 10 f0 	movl   $0xf0108e92,(%esp)
f0100c12:	e8 73 36 00 00       	call   f010428a <cprintf>
		cprintf("Usage: showmappings 0xbegin 0xend\nshow page mappings from begin to end.\n");
		return 0;
	}
	uint32_t va = xtoi(argv[1]), vend = xtoi(argv[2]);
	cprintf("begin: %x, end: %x\n", va, vend);
	for (; va <= vend; va += PGSIZE) {
f0100c17:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0100c1d:	39 fe                	cmp    %edi,%esi
f0100c1f:	76 8c                	jbe    f0100bad <showmappings+0x53>
			cprintf("page of 0x%x: ", va);
			print_pte_info(ppte);
		} else cprintf("page not exist: %x\n", va);
	}
	return 0;
}
f0100c21:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c26:	83 c4 1c             	add    $0x1c,%esp
f0100c29:	5b                   	pop    %ebx
f0100c2a:	5e                   	pop    %esi
f0100c2b:	5f                   	pop    %edi
f0100c2c:	5d                   	pop    %ebp
f0100c2d:	c3                   	ret    

f0100c2e <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100c2e:	55                   	push   %ebp
f0100c2f:	89 e5                	mov    %esp,%ebp
f0100c31:	57                   	push   %edi
f0100c32:	56                   	push   %esi
f0100c33:	53                   	push   %ebx
f0100c34:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100c37:	c7 04 24 bc 91 10 f0 	movl   $0xf01091bc,(%esp)
f0100c3e:	e8 47 36 00 00       	call   f010428a <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100c43:	c7 04 24 e0 91 10 f0 	movl   $0xf01091e0,(%esp)
f0100c4a:	e8 3b 36 00 00       	call   f010428a <cprintf>
	if (tf != NULL)
f0100c4f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100c53:	74 0b                	je     f0100c60 <monitor+0x32>
		print_trapframe(tf);
f0100c55:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c58:	89 04 24             	mov    %eax,(%esp)
f0100c5b:	e8 f2 38 00 00       	call   f0104552 <print_trapframe>
	while (1) {
		buf = readline("K> ");
f0100c60:	c7 04 24 a6 8e 10 f0 	movl   $0xf0108ea6,(%esp)
f0100c67:	e8 54 6f 00 00       	call   f0107bc0 <readline>
f0100c6c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100c6e:	85 c0                	test   %eax,%eax
f0100c70:	74 ee                	je     f0100c60 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100c72:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100c79:	be 00 00 00 00       	mov    $0x0,%esi
f0100c7e:	eb 04                	jmp    f0100c84 <monitor+0x56>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100c80:	c6 03 00             	movb   $0x0,(%ebx)
f0100c83:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100c84:	8a 03                	mov    (%ebx),%al
f0100c86:	84 c0                	test   %al,%al
f0100c88:	74 5e                	je     f0100ce8 <monitor+0xba>
f0100c8a:	0f be c0             	movsbl %al,%eax
f0100c8d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c91:	c7 04 24 aa 8e 10 f0 	movl   $0xf0108eaa,(%esp)
f0100c98:	e8 18 71 00 00       	call   f0107db5 <strchr>
f0100c9d:	85 c0                	test   %eax,%eax
f0100c9f:	75 df                	jne    f0100c80 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100ca1:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100ca4:	74 42                	je     f0100ce8 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100ca6:	83 fe 0f             	cmp    $0xf,%esi
f0100ca9:	75 16                	jne    f0100cc1 <monitor+0x93>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100cab:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100cb2:	00 
f0100cb3:	c7 04 24 af 8e 10 f0 	movl   $0xf0108eaf,(%esp)
f0100cba:	e8 cb 35 00 00       	call   f010428a <cprintf>
f0100cbf:	eb 9f                	jmp    f0100c60 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100cc1:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100cc5:	46                   	inc    %esi
f0100cc6:	eb 01                	jmp    f0100cc9 <monitor+0x9b>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100cc8:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100cc9:	8a 03                	mov    (%ebx),%al
f0100ccb:	84 c0                	test   %al,%al
f0100ccd:	74 b5                	je     f0100c84 <monitor+0x56>
f0100ccf:	0f be c0             	movsbl %al,%eax
f0100cd2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cd6:	c7 04 24 aa 8e 10 f0 	movl   $0xf0108eaa,(%esp)
f0100cdd:	e8 d3 70 00 00       	call   f0107db5 <strchr>
f0100ce2:	85 c0                	test   %eax,%eax
f0100ce4:	74 e2                	je     f0100cc8 <monitor+0x9a>
f0100ce6:	eb 9c                	jmp    f0100c84 <monitor+0x56>
			buf++;
	}
	argv[argc] = 0;
f0100ce8:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100cef:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100cf0:	85 f6                	test   %esi,%esi
f0100cf2:	0f 84 68 ff ff ff    	je     f0100c60 <monitor+0x32>
f0100cf8:	bb a0 92 10 f0       	mov    $0xf01092a0,%ebx
f0100cfd:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100d02:	8b 03                	mov    (%ebx),%eax
f0100d04:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d08:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100d0b:	89 04 24             	mov    %eax,(%esp)
f0100d0e:	e8 4f 70 00 00       	call   f0107d62 <strcmp>
f0100d13:	85 c0                	test   %eax,%eax
f0100d15:	75 24                	jne    f0100d3b <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f0100d17:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100d1a:	8b 55 08             	mov    0x8(%ebp),%edx
f0100d1d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100d21:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100d24:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100d28:	89 34 24             	mov    %esi,(%esp)
f0100d2b:	ff 14 85 a8 92 10 f0 	call   *-0xfef6d58(,%eax,4)
	if (tf != NULL)
		print_trapframe(tf);
	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100d32:	85 c0                	test   %eax,%eax
f0100d34:	78 26                	js     f0100d5c <monitor+0x12e>
f0100d36:	e9 25 ff ff ff       	jmp    f0100c60 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100d3b:	47                   	inc    %edi
f0100d3c:	83 c3 0c             	add    $0xc,%ebx
f0100d3f:	83 ff 05             	cmp    $0x5,%edi
f0100d42:	75 be                	jne    f0100d02 <monitor+0xd4>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100d44:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100d47:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d4b:	c7 04 24 cc 8e 10 f0 	movl   $0xf0108ecc,(%esp)
f0100d52:	e8 33 35 00 00       	call   f010428a <cprintf>
f0100d57:	e9 04 ff ff ff       	jmp    f0100c60 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100d5c:	83 c4 5c             	add    $0x5c,%esp
f0100d5f:	5b                   	pop    %ebx
f0100d60:	5e                   	pop    %esi
f0100d61:	5f                   	pop    %edi
f0100d62:	5d                   	pop    %ebp
f0100d63:	c3                   	ret    

f0100d64 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100d64:	55                   	push   %ebp
f0100d65:	89 e5                	mov    %esp,%ebp
f0100d67:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100d69:	83 3d 3c 82 35 f0 00 	cmpl   $0x0,0xf035823c
f0100d70:	75 0f                	jne    f0100d81 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100d72:	b8 07 b0 39 f0       	mov    $0xf039b007,%eax
f0100d77:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d7c:	a3 3c 82 35 f0       	mov    %eax,0xf035823c
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n != 0) {
f0100d81:	85 d2                	test   %edx,%edx
f0100d83:	74 26                	je     f0100dab <boot_alloc+0x47>
		result = ROUNDUP((char *) nextfree, PGSIZE);
f0100d85:	8b 0d 3c 82 35 f0    	mov    0xf035823c,%ecx
f0100d8b:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
f0100d91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		nextfree = ROUNDUP((char *) (nextfree + n), PGSIZE);
f0100d96:	8d 94 11 ff 0f 00 00 	lea    0xfff(%ecx,%edx,1),%edx
f0100d9d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100da3:	89 15 3c 82 35 f0    	mov    %edx,0xf035823c
		return result;
f0100da9:	eb 05                	jmp    f0100db0 <boot_alloc+0x4c>
	}
	else return nextfree;
f0100dab:	a1 3c 82 35 f0       	mov    0xf035823c,%eax
}
f0100db0:	5d                   	pop    %ebp
f0100db1:	c3                   	ret    

f0100db2 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100db2:	55                   	push   %ebp
f0100db3:	89 e5                	mov    %esp,%ebp
f0100db5:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100db8:	89 d1                	mov    %edx,%ecx
f0100dba:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100dbd:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100dc0:	a8 01                	test   $0x1,%al
f0100dc2:	74 4d                	je     f0100e11 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100dc4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dc9:	89 c1                	mov    %eax,%ecx
f0100dcb:	c1 e9 0c             	shr    $0xc,%ecx
f0100dce:	3b 0d 88 8e 35 f0    	cmp    0xf0358e88,%ecx
f0100dd4:	72 20                	jb     f0100df6 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dd6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100dda:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f0100de1:	f0 
f0100de2:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f0100de9:	00 
f0100dea:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0100df1:	e8 4a f2 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100df6:	c1 ea 0c             	shr    $0xc,%edx
f0100df9:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100dff:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100e06:	a8 01                	test   $0x1,%al
f0100e08:	74 0e                	je     f0100e18 <check_va2pa+0x66>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100e0a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e0f:	eb 0c                	jmp    f0100e1d <check_va2pa+0x6b>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100e11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e16:	eb 05                	jmp    f0100e1d <check_va2pa+0x6b>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0100e18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100e1d:	c9                   	leave  
f0100e1e:	c3                   	ret    

f0100e1f <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100e1f:	55                   	push   %ebp
f0100e20:	89 e5                	mov    %esp,%ebp
f0100e22:	56                   	push   %esi
f0100e23:	53                   	push   %ebx
f0100e24:	83 ec 10             	sub    $0x10,%esp
f0100e27:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100e29:	89 04 24             	mov    %eax,(%esp)
f0100e2c:	e8 13 33 00 00       	call   f0104144 <mc146818_read>
f0100e31:	89 c6                	mov    %eax,%esi
f0100e33:	43                   	inc    %ebx
f0100e34:	89 1c 24             	mov    %ebx,(%esp)
f0100e37:	e8 08 33 00 00       	call   f0104144 <mc146818_read>
f0100e3c:	c1 e0 08             	shl    $0x8,%eax
f0100e3f:	09 f0                	or     %esi,%eax
}
f0100e41:	83 c4 10             	add    $0x10,%esp
f0100e44:	5b                   	pop    %ebx
f0100e45:	5e                   	pop    %esi
f0100e46:	5d                   	pop    %ebp
f0100e47:	c3                   	ret    

f0100e48 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100e48:	55                   	push   %ebp
f0100e49:	89 e5                	mov    %esp,%ebp
f0100e4b:	57                   	push   %edi
f0100e4c:	56                   	push   %esi
f0100e4d:	53                   	push   %ebx
f0100e4e:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e51:	3c 01                	cmp    $0x1,%al
f0100e53:	19 f6                	sbb    %esi,%esi
f0100e55:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100e5b:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e5c:	8b 15 40 82 35 f0    	mov    0xf0358240,%edx
f0100e62:	85 d2                	test   %edx,%edx
f0100e64:	75 1c                	jne    f0100e82 <check_page_free_list+0x3a>
		panic("'page_free_list' is a null pointer!");
f0100e66:	c7 44 24 08 dc 92 10 	movl   $0xf01092dc,0x8(%esp)
f0100e6d:	f0 
f0100e6e:	c7 44 24 04 99 02 00 	movl   $0x299,0x4(%esp)
f0100e75:	00 
f0100e76:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0100e7d:	e8 be f1 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
f0100e82:	84 c0                	test   %al,%al
f0100e84:	74 4b                	je     f0100ed1 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e86:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100e89:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100e8c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100e8f:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e92:	89 d0                	mov    %edx,%eax
f0100e94:	2b 05 90 8e 35 f0    	sub    0xf0358e90,%eax
f0100e9a:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100e9d:	c1 e8 16             	shr    $0x16,%eax
f0100ea0:	39 c6                	cmp    %eax,%esi
f0100ea2:	0f 96 c0             	setbe  %al
f0100ea5:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100ea8:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f0100eac:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100eae:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100eb2:	8b 12                	mov    (%edx),%edx
f0100eb4:	85 d2                	test   %edx,%edx
f0100eb6:	75 da                	jne    f0100e92 <check_page_free_list+0x4a>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100eb8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100ebb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ec1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ec4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ec7:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100ec9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ecc:	a3 40 82 35 f0       	mov    %eax,0xf0358240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ed1:	8b 1d 40 82 35 f0    	mov    0xf0358240,%ebx
f0100ed7:	eb 63                	jmp    f0100f3c <check_page_free_list+0xf4>
f0100ed9:	89 d8                	mov    %ebx,%eax
f0100edb:	2b 05 90 8e 35 f0    	sub    0xf0358e90,%eax
f0100ee1:	c1 f8 03             	sar    $0x3,%eax
f0100ee4:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100ee7:	89 c2                	mov    %eax,%edx
f0100ee9:	c1 ea 16             	shr    $0x16,%edx
f0100eec:	39 d6                	cmp    %edx,%esi
f0100eee:	76 4a                	jbe    f0100f3a <check_page_free_list+0xf2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ef0:	89 c2                	mov    %eax,%edx
f0100ef2:	c1 ea 0c             	shr    $0xc,%edx
f0100ef5:	3b 15 88 8e 35 f0    	cmp    0xf0358e88,%edx
f0100efb:	72 20                	jb     f0100f1d <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100efd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f01:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f0100f08:	f0 
f0100f09:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100f10:	00 
f0100f11:	c7 04 24 81 9c 10 f0 	movl   $0xf0109c81,(%esp)
f0100f18:	e8 23 f1 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100f1d:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100f24:	00 
f0100f25:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100f2c:	00 
	return (void *)(pa + KERNBASE);
f0100f2d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f32:	89 04 24             	mov    %eax,(%esp)
f0100f35:	e8 b0 6e 00 00       	call   f0107dea <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f3a:	8b 1b                	mov    (%ebx),%ebx
f0100f3c:	85 db                	test   %ebx,%ebx
f0100f3e:	75 99                	jne    f0100ed9 <check_page_free_list+0x91>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100f40:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f45:	e8 1a fe ff ff       	call   f0100d64 <boot_alloc>
f0100f4a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f4d:	8b 15 40 82 35 f0    	mov    0xf0358240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100f53:	8b 0d 90 8e 35 f0    	mov    0xf0358e90,%ecx
		assert(pp < pages + npages);
f0100f59:	a1 88 8e 35 f0       	mov    0xf0358e88,%eax
f0100f5e:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100f61:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100f64:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100f67:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100f6a:	be 00 00 00 00       	mov    $0x0,%esi
f0100f6f:	89 4d c0             	mov    %ecx,-0x40(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f72:	e9 c4 01 00 00       	jmp    f010113b <check_page_free_list+0x2f3>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100f77:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0100f7a:	73 24                	jae    f0100fa0 <check_page_free_list+0x158>
f0100f7c:	c7 44 24 0c 8f 9c 10 	movl   $0xf0109c8f,0xc(%esp)
f0100f83:	f0 
f0100f84:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0100f8b:	f0 
f0100f8c:	c7 44 24 04 b3 02 00 	movl   $0x2b3,0x4(%esp)
f0100f93:	00 
f0100f94:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0100f9b:	e8 a0 f0 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100fa0:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100fa3:	72 24                	jb     f0100fc9 <check_page_free_list+0x181>
f0100fa5:	c7 44 24 0c b0 9c 10 	movl   $0xf0109cb0,0xc(%esp)
f0100fac:	f0 
f0100fad:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0100fb4:	f0 
f0100fb5:	c7 44 24 04 b4 02 00 	movl   $0x2b4,0x4(%esp)
f0100fbc:	00 
f0100fbd:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0100fc4:	e8 77 f0 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100fc9:	89 d0                	mov    %edx,%eax
f0100fcb:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100fce:	a8 07                	test   $0x7,%al
f0100fd0:	74 24                	je     f0100ff6 <check_page_free_list+0x1ae>
f0100fd2:	c7 44 24 0c 00 93 10 	movl   $0xf0109300,0xc(%esp)
f0100fd9:	f0 
f0100fda:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0100fe1:	f0 
f0100fe2:	c7 44 24 04 b5 02 00 	movl   $0x2b5,0x4(%esp)
f0100fe9:	00 
f0100fea:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0100ff1:	e8 4a f0 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ff6:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100ff9:	c1 e0 0c             	shl    $0xc,%eax
f0100ffc:	75 24                	jne    f0101022 <check_page_free_list+0x1da>
f0100ffe:	c7 44 24 0c c4 9c 10 	movl   $0xf0109cc4,0xc(%esp)
f0101005:	f0 
f0101006:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f010100d:	f0 
f010100e:	c7 44 24 04 b8 02 00 	movl   $0x2b8,0x4(%esp)
f0101015:	00 
f0101016:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f010101d:	e8 1e f0 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101022:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101027:	75 24                	jne    f010104d <check_page_free_list+0x205>
f0101029:	c7 44 24 0c d5 9c 10 	movl   $0xf0109cd5,0xc(%esp)
f0101030:	f0 
f0101031:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101038:	f0 
f0101039:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
f0101040:	00 
f0101041:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101048:	e8 f3 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010104d:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101052:	75 24                	jne    f0101078 <check_page_free_list+0x230>
f0101054:	c7 44 24 0c 34 93 10 	movl   $0xf0109334,0xc(%esp)
f010105b:	f0 
f010105c:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101063:	f0 
f0101064:	c7 44 24 04 ba 02 00 	movl   $0x2ba,0x4(%esp)
f010106b:	00 
f010106c:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101073:	e8 c8 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101078:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010107d:	75 24                	jne    f01010a3 <check_page_free_list+0x25b>
f010107f:	c7 44 24 0c ee 9c 10 	movl   $0xf0109cee,0xc(%esp)
f0101086:	f0 
f0101087:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f010108e:	f0 
f010108f:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
f0101096:	00 
f0101097:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f010109e:	e8 9d ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01010a3:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01010a8:	76 59                	jbe    f0101103 <check_page_free_list+0x2bb>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010aa:	89 c1                	mov    %eax,%ecx
f01010ac:	c1 e9 0c             	shr    $0xc,%ecx
f01010af:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01010b2:	77 20                	ja     f01010d4 <check_page_free_list+0x28c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01010b8:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f01010bf:	f0 
f01010c0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01010c7:	00 
f01010c8:	c7 04 24 81 9c 10 f0 	movl   $0xf0109c81,(%esp)
f01010cf:	e8 6c ef ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01010d4:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f01010da:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f01010dd:	76 24                	jbe    f0101103 <check_page_free_list+0x2bb>
f01010df:	c7 44 24 0c 58 93 10 	movl   $0xf0109358,0xc(%esp)
f01010e6:	f0 
f01010e7:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01010ee:	f0 
f01010ef:	c7 44 24 04 bc 02 00 	movl   $0x2bc,0x4(%esp)
f01010f6:	00 
f01010f7:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01010fe:	e8 3d ef ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101103:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101108:	75 24                	jne    f010112e <check_page_free_list+0x2e6>
f010110a:	c7 44 24 0c 08 9d 10 	movl   $0xf0109d08,0xc(%esp)
f0101111:	f0 
f0101112:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101119:	f0 
f010111a:	c7 44 24 04 be 02 00 	movl   $0x2be,0x4(%esp)
f0101121:	00 
f0101122:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101129:	e8 12 ef ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f010112e:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101133:	77 03                	ja     f0101138 <check_page_free_list+0x2f0>
			++nfree_basemem;
f0101135:	46                   	inc    %esi
f0101136:	eb 01                	jmp    f0101139 <check_page_free_list+0x2f1>
		else
			++nfree_extmem;
f0101138:	43                   	inc    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101139:	8b 12                	mov    (%edx),%edx
f010113b:	85 d2                	test   %edx,%edx
f010113d:	0f 85 34 fe ff ff    	jne    f0100f77 <check_page_free_list+0x12f>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0101143:	85 f6                	test   %esi,%esi
f0101145:	7f 24                	jg     f010116b <check_page_free_list+0x323>
f0101147:	c7 44 24 0c 25 9d 10 	movl   $0xf0109d25,0xc(%esp)
f010114e:	f0 
f010114f:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101156:	f0 
f0101157:	c7 44 24 04 c6 02 00 	movl   $0x2c6,0x4(%esp)
f010115e:	00 
f010115f:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101166:	e8 d5 ee ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f010116b:	85 db                	test   %ebx,%ebx
f010116d:	7f 24                	jg     f0101193 <check_page_free_list+0x34b>
f010116f:	c7 44 24 0c 37 9d 10 	movl   $0xf0109d37,0xc(%esp)
f0101176:	f0 
f0101177:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f010117e:	f0 
f010117f:	c7 44 24 04 c7 02 00 	movl   $0x2c7,0x4(%esp)
f0101186:	00 
f0101187:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f010118e:	e8 ad ee ff ff       	call   f0100040 <_panic>
}
f0101193:	83 c4 4c             	add    $0x4c,%esp
f0101196:	5b                   	pop    %ebx
f0101197:	5e                   	pop    %esi
f0101198:	5f                   	pop    %edi
f0101199:	5d                   	pop    %ebp
f010119a:	c3                   	ret    

f010119b <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f010119b:	55                   	push   %ebp
f010119c:	89 e5                	mov    %esp,%ebp
f010119e:	53                   	push   %ebx
f010119f:	83 ec 14             	sub    $0x14,%esp
	// 3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	//    never be allocated.
	char *first_free_page;
	first_free_page = (char *) boot_alloc(0);
	struct PageInfo *tmp = pages[PGNUM(IOPHYSMEM)].pp_link;
	for (i = PGNUM(IOPHYSMEM); i < PGNUM(PADDR(first_free_page)); i++) {
f01011a2:	8b 1d 40 82 35 f0    	mov    0xf0358240,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f01011a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01011ad:	eb 20                	jmp    f01011cf <page_init+0x34>
		pages[i].pp_ref = 0;
f01011af:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01011b6:	89 d1                	mov    %edx,%ecx
f01011b8:	03 0d 90 8e 35 f0    	add    0xf0358e90,%ecx
f01011be:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f01011c4:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f01011c6:	89 d3                	mov    %edx,%ebx
f01011c8:	03 1d 90 8e 35 f0    	add    0xf0358e90,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f01011ce:	40                   	inc    %eax
f01011cf:	3b 05 88 8e 35 f0    	cmp    0xf0358e88,%eax
f01011d5:	72 d8                	jb     f01011af <page_init+0x14>
f01011d7:	89 1d 40 82 35 f0    	mov    %ebx,0xf0358240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	uint32_t index = MPENTRY_PADDR/PGSIZE;
	pages[index].pp_ref = 1;
f01011dd:	a1 90 8e 35 f0       	mov    0xf0358e90,%eax
f01011e2:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
	pages[index].pp_link = NULL;
f01011e8:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
	pages[index + 1].pp_link = &pages[index - 1];
f01011ef:	8d 50 30             	lea    0x30(%eax),%edx
f01011f2:	89 50 40             	mov    %edx,0x40(%eax)

	// 1) Mark physical page 0 as in use.
	pages[0].pp_ref = 1;
f01011f5:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = NULL;
f01011fb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pages[1].pp_link = NULL;
f0101201:	a1 90 8e 35 f0       	mov    0xf0358e90,%eax
f0101206:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	// 3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	//    never be allocated.
	char *first_free_page;
	first_free_page = (char *) boot_alloc(0);
f010120d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101212:	e8 4d fb ff ff       	call   f0100d64 <boot_alloc>
	struct PageInfo *tmp = pages[PGNUM(IOPHYSMEM)].pp_link;
f0101217:	8b 15 90 8e 35 f0    	mov    0xf0358e90,%edx
f010121d:	8b 9a 00 05 00 00    	mov    0x500(%edx),%ebx
static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0101223:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
	for (i = PGNUM(IOPHYSMEM); i < PGNUM(PADDR(first_free_page)); i++) {
f0101229:	c1 e9 0c             	shr    $0xc,%ecx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010122c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101231:	76 23                	jbe    f0101256 <page_init+0xbb>
f0101233:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0101238:	eb 3c                	jmp    f0101276 <page_init+0xdb>
		pages[i].pp_ref = 1;
f010123a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101241:	03 15 90 8e 35 f0    	add    0xf0358e90,%edx
f0101247:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = NULL;
f010124d:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	// 3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	//    never be allocated.
	char *first_free_page;
	first_free_page = (char *) boot_alloc(0);
	struct PageInfo *tmp = pages[PGNUM(IOPHYSMEM)].pp_link;
	for (i = PGNUM(IOPHYSMEM); i < PGNUM(PADDR(first_free_page)); i++) {
f0101253:	40                   	inc    %eax
f0101254:	eb 20                	jmp    f0101276 <page_init+0xdb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101256:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010125a:	c7 44 24 08 04 8b 10 	movl   $0xf0108b04,0x8(%esp)
f0101261:	f0 
f0101262:	c7 44 24 04 4c 01 00 	movl   $0x14c,0x4(%esp)
f0101269:	00 
f010126a:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101271:	e8 ca ed ff ff       	call   f0100040 <_panic>
f0101276:	39 c8                	cmp    %ecx,%eax
f0101278:	72 c0                	jb     f010123a <page_init+0x9f>
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
	pages[i].pp_link = tmp;
f010127a:	8b 15 90 8e 35 f0    	mov    0xf0358e90,%edx
f0101280:	89 1c c2             	mov    %ebx,(%edx,%eax,8)
}
f0101283:	83 c4 14             	add    $0x14,%esp
f0101286:	5b                   	pop    %ebx
f0101287:	5d                   	pop    %ebp
f0101288:	c3                   	ret    

f0101289 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101289:	55                   	push   %ebp
f010128a:	89 e5                	mov    %esp,%ebp
f010128c:	53                   	push   %ebx
f010128d:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	if (page_free_list == NULL) return NULL;
f0101290:	8b 1d 40 82 35 f0    	mov    0xf0358240,%ebx
f0101296:	85 db                	test   %ebx,%ebx
f0101298:	74 6b                	je     f0101305 <page_alloc+0x7c>
	struct PageInfo *result;
	result = page_free_list;
	page_free_list = result->pp_link;
f010129a:	8b 03                	mov    (%ebx),%eax
f010129c:	a3 40 82 35 f0       	mov    %eax,0xf0358240
	result->pp_link = NULL;
f01012a1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) memset(page2kva(result), 0, PGSIZE);
f01012a7:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01012ab:	74 58                	je     f0101305 <page_alloc+0x7c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012ad:	89 d8                	mov    %ebx,%eax
f01012af:	2b 05 90 8e 35 f0    	sub    0xf0358e90,%eax
f01012b5:	c1 f8 03             	sar    $0x3,%eax
f01012b8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012bb:	89 c2                	mov    %eax,%edx
f01012bd:	c1 ea 0c             	shr    $0xc,%edx
f01012c0:	3b 15 88 8e 35 f0    	cmp    0xf0358e88,%edx
f01012c6:	72 20                	jb     f01012e8 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012cc:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f01012d3:	f0 
f01012d4:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01012db:	00 
f01012dc:	c7 04 24 81 9c 10 f0 	movl   $0xf0109c81,(%esp)
f01012e3:	e8 58 ed ff ff       	call   f0100040 <_panic>
f01012e8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01012ef:	00 
f01012f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01012f7:	00 
	return (void *)(pa + KERNBASE);
f01012f8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01012fd:	89 04 24             	mov    %eax,(%esp)
f0101300:	e8 e5 6a 00 00       	call   f0107dea <memset>
	return result;
}
f0101305:	89 d8                	mov    %ebx,%eax
f0101307:	83 c4 14             	add    $0x14,%esp
f010130a:	5b                   	pop    %ebx
f010130b:	5d                   	pop    %ebp
f010130c:	c3                   	ret    

f010130d <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010130d:	55                   	push   %ebp
f010130e:	89 e5                	mov    %esp,%ebp
f0101310:	83 ec 18             	sub    $0x18,%esp
f0101313:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0) panic("page_free: pp->pp_ref is nonzero!");
f0101316:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010131b:	74 1c                	je     f0101339 <page_free+0x2c>
f010131d:	c7 44 24 08 a0 93 10 	movl   $0xf01093a0,0x8(%esp)
f0101324:	f0 
f0101325:	c7 44 24 04 76 01 00 	movl   $0x176,0x4(%esp)
f010132c:	00 
f010132d:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101334:	e8 07 ed ff ff       	call   f0100040 <_panic>
	if (pp->pp_link != NULL) panic("page_free: pp->pp_link is not NULL!");
f0101339:	83 38 00             	cmpl   $0x0,(%eax)
f010133c:	74 1c                	je     f010135a <page_free+0x4d>
f010133e:	c7 44 24 08 c4 93 10 	movl   $0xf01093c4,0x8(%esp)
f0101345:	f0 
f0101346:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
f010134d:	00 
f010134e:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101355:	e8 e6 ec ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f010135a:	8b 15 40 82 35 f0    	mov    0xf0358240,%edx
f0101360:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101362:	a3 40 82 35 f0       	mov    %eax,0xf0358240
	return;
}
f0101367:	c9                   	leave  
f0101368:	c3                   	ret    

f0101369 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101369:	55                   	push   %ebp
f010136a:	89 e5                	mov    %esp,%ebp
f010136c:	83 ec 18             	sub    $0x18,%esp
f010136f:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101372:	8b 50 04             	mov    0x4(%eax),%edx
f0101375:	4a                   	dec    %edx
f0101376:	66 89 50 04          	mov    %dx,0x4(%eax)
f010137a:	66 85 d2             	test   %dx,%dx
f010137d:	75 08                	jne    f0101387 <page_decref+0x1e>
		page_free(pp);
f010137f:	89 04 24             	mov    %eax,(%esp)
f0101382:	e8 86 ff ff ff       	call   f010130d <page_free>
}
f0101387:	c9                   	leave  
f0101388:	c3                   	ret    

f0101389 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101389:	55                   	push   %ebp
f010138a:	89 e5                	mov    %esp,%ebp
f010138c:	56                   	push   %esi
f010138d:	53                   	push   %ebx
f010138e:	83 ec 10             	sub    $0x10,%esp
f0101391:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	if (!(pgdir[PDX(va)] & PTE_P)) {
f0101394:	89 f3                	mov    %esi,%ebx
f0101396:	c1 eb 16             	shr    $0x16,%ebx
f0101399:	c1 e3 02             	shl    $0x2,%ebx
f010139c:	03 5d 08             	add    0x8(%ebp),%ebx
f010139f:	f6 03 01             	testb  $0x1,(%ebx)
f01013a2:	75 2b                	jne    f01013cf <pgdir_walk+0x46>
		if (!create) return NULL;
f01013a4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01013a8:	74 6b                	je     f0101415 <pgdir_walk+0x8c>
		struct PageInfo *pp = page_alloc(1);
f01013aa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01013b1:	e8 d3 fe ff ff       	call   f0101289 <page_alloc>
		if (!pp) return NULL;
f01013b6:	85 c0                	test   %eax,%eax
f01013b8:	74 62                	je     f010141c <pgdir_walk+0x93>
		pp->pp_ref++;
f01013ba:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013be:	2b 05 90 8e 35 f0    	sub    0xf0358e90,%eax
f01013c4:	c1 f8 03             	sar    $0x3,%eax
f01013c7:	c1 e0 0c             	shl    $0xc,%eax
		pgdir[PDX(va)] = page2pa(pp) | PTE_P | PTE_W | PTE_U;
f01013ca:	83 c8 07             	or     $0x7,%eax
f01013cd:	89 03                	mov    %eax,(%ebx)
	}
	return (pte_t *)((pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va));
f01013cf:	8b 03                	mov    (%ebx),%eax
f01013d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013d6:	89 c2                	mov    %eax,%edx
f01013d8:	c1 ea 0c             	shr    $0xc,%edx
f01013db:	3b 15 88 8e 35 f0    	cmp    0xf0358e88,%edx
f01013e1:	72 20                	jb     f0101403 <pgdir_walk+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013e7:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f01013ee:	f0 
f01013ef:	c7 44 24 04 a9 01 00 	movl   $0x1a9,0x4(%esp)
f01013f6:	00 
f01013f7:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01013fe:	e8 3d ec ff ff       	call   f0100040 <_panic>
f0101403:	c1 ee 0a             	shr    $0xa,%esi
f0101406:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f010140c:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0101413:	eb 0c                	jmp    f0101421 <pgdir_walk+0x98>
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
	if (!(pgdir[PDX(va)] & PTE_P)) {
		if (!create) return NULL;
f0101415:	b8 00 00 00 00       	mov    $0x0,%eax
f010141a:	eb 05                	jmp    f0101421 <pgdir_walk+0x98>
		struct PageInfo *pp = page_alloc(1);
		if (!pp) return NULL;
f010141c:	b8 00 00 00 00       	mov    $0x0,%eax
		pp->pp_ref++;
		pgdir[PDX(va)] = page2pa(pp) | PTE_P | PTE_W | PTE_U;
	}
	return (pte_t *)((pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va));
}
f0101421:	83 c4 10             	add    $0x10,%esp
f0101424:	5b                   	pop    %ebx
f0101425:	5e                   	pop    %esi
f0101426:	5d                   	pop    %ebp
f0101427:	c3                   	ret    

f0101428 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101428:	55                   	push   %ebp
f0101429:	89 e5                	mov    %esp,%ebp
f010142b:	57                   	push   %edi
f010142c:	56                   	push   %esi
f010142d:	53                   	push   %ebx
f010142e:	83 ec 2c             	sub    $0x2c,%esp
f0101431:	89 c7                	mov    %eax,%edi
	// Fill this function in
	uintptr_t va_ptr, vend_ptr;
	physaddr_t pa_ptr;
	pte_t *ppte;
	vend_ptr = va + size;
f0101433:	8d 04 11             	lea    (%ecx,%edx,1),%eax
f0101436:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (size > (unsigned)0xffffffff - vend_ptr + 1) vend_ptr = ROUNDUP(0xfffff000, PGSIZE);
f0101439:	f7 d8                	neg    %eax
f010143b:	39 c1                	cmp    %eax,%ecx
f010143d:	76 07                	jbe    f0101446 <boot_map_region+0x1e>
f010143f:	c7 45 e4 00 f0 ff ff 	movl   $0xfffff000,-0x1c(%ebp)
	for (va_ptr = va, pa_ptr = pa; va_ptr != vend_ptr; va_ptr += PGSIZE, pa_ptr += PGSIZE) {
f0101446:	8b 75 08             	mov    0x8(%ebp),%esi
f0101449:	89 d3                	mov    %edx,%ebx
		ppte = pgdir_walk(pgdir, (void *)va_ptr, 1);
		if (!ppte) panic("boot_map_region: cannot find valid page!");
		*ppte = PTE_ADDR(pa_ptr) | perm | PTE_P;
f010144b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010144e:	83 c8 01             	or     $0x1,%eax
f0101451:	89 45 e0             	mov    %eax,-0x20(%ebp)
	uintptr_t va_ptr, vend_ptr;
	physaddr_t pa_ptr;
	pte_t *ppte;
	vend_ptr = va + size;
	if (size > (unsigned)0xffffffff - vend_ptr + 1) vend_ptr = ROUNDUP(0xfffff000, PGSIZE);
	for (va_ptr = va, pa_ptr = pa; va_ptr != vend_ptr; va_ptr += PGSIZE, pa_ptr += PGSIZE) {
f0101454:	eb 4d                	jmp    f01014a3 <boot_map_region+0x7b>
		ppte = pgdir_walk(pgdir, (void *)va_ptr, 1);
f0101456:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010145d:	00 
f010145e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101462:	89 3c 24             	mov    %edi,(%esp)
f0101465:	e8 1f ff ff ff       	call   f0101389 <pgdir_walk>
		if (!ppte) panic("boot_map_region: cannot find valid page!");
f010146a:	85 c0                	test   %eax,%eax
f010146c:	75 1c                	jne    f010148a <boot_map_region+0x62>
f010146e:	c7 44 24 08 e8 93 10 	movl   $0xf01093e8,0x8(%esp)
f0101475:	f0 
f0101476:	c7 44 24 04 c2 01 00 	movl   $0x1c2,0x4(%esp)
f010147d:	00 
f010147e:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101485:	e8 b6 eb ff ff       	call   f0100040 <_panic>
		*ppte = PTE_ADDR(pa_ptr) | perm | PTE_P;
f010148a:	89 f2                	mov    %esi,%edx
f010148c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101492:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101495:	89 10                	mov    %edx,(%eax)
	uintptr_t va_ptr, vend_ptr;
	physaddr_t pa_ptr;
	pte_t *ppte;
	vend_ptr = va + size;
	if (size > (unsigned)0xffffffff - vend_ptr + 1) vend_ptr = ROUNDUP(0xfffff000, PGSIZE);
	for (va_ptr = va, pa_ptr = pa; va_ptr != vend_ptr; va_ptr += PGSIZE, pa_ptr += PGSIZE) {
f0101497:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010149d:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01014a3:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01014a6:	75 ae                	jne    f0101456 <boot_map_region+0x2e>
		ppte = pgdir_walk(pgdir, (void *)va_ptr, 1);
		if (!ppte) panic("boot_map_region: cannot find valid page!");
		*ppte = PTE_ADDR(pa_ptr) | perm | PTE_P;
	}
	return;
}
f01014a8:	83 c4 2c             	add    $0x2c,%esp
f01014ab:	5b                   	pop    %ebx
f01014ac:	5e                   	pop    %esi
f01014ad:	5f                   	pop    %edi
f01014ae:	5d                   	pop    %ebp
f01014af:	c3                   	ret    

f01014b0 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01014b0:	55                   	push   %ebp
f01014b1:	89 e5                	mov    %esp,%ebp
f01014b3:	53                   	push   %ebx
f01014b4:	83 ec 14             	sub    $0x14,%esp
f01014b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *ppte = pgdir_walk(pgdir, va, 0);
f01014ba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01014c1:	00 
f01014c2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01014cc:	89 04 24             	mov    %eax,(%esp)
f01014cf:	e8 b5 fe ff ff       	call   f0101389 <pgdir_walk>
	if (pte_store) *pte_store = ppte;
f01014d4:	85 db                	test   %ebx,%ebx
f01014d6:	74 02                	je     f01014da <page_lookup+0x2a>
f01014d8:	89 03                	mov    %eax,(%ebx)
	if (!ppte || !(*ppte & PTE_P)) return NULL;
f01014da:	85 c0                	test   %eax,%eax
f01014dc:	74 38                	je     f0101516 <page_lookup+0x66>
f01014de:	8b 00                	mov    (%eax),%eax
f01014e0:	a8 01                	test   $0x1,%al
f01014e2:	74 39                	je     f010151d <page_lookup+0x6d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014e4:	c1 e8 0c             	shr    $0xc,%eax
f01014e7:	3b 05 88 8e 35 f0    	cmp    0xf0358e88,%eax
f01014ed:	72 1c                	jb     f010150b <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f01014ef:	c7 44 24 08 14 94 10 	movl   $0xf0109414,0x8(%esp)
f01014f6:	f0 
f01014f7:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01014fe:	00 
f01014ff:	c7 04 24 81 9c 10 f0 	movl   $0xf0109c81,(%esp)
f0101506:	e8 35 eb ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010150b:	c1 e0 03             	shl    $0x3,%eax
f010150e:	03 05 90 8e 35 f0    	add    0xf0358e90,%eax
	return pa2page(PTE_ADDR(*ppte));
f0101514:	eb 0c                	jmp    f0101522 <page_lookup+0x72>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *ppte = pgdir_walk(pgdir, va, 0);
	if (pte_store) *pte_store = ppte;
	if (!ppte || !(*ppte & PTE_P)) return NULL;
f0101516:	b8 00 00 00 00       	mov    $0x0,%eax
f010151b:	eb 05                	jmp    f0101522 <page_lookup+0x72>
f010151d:	b8 00 00 00 00       	mov    $0x0,%eax
	return pa2page(PTE_ADDR(*ppte));
}
f0101522:	83 c4 14             	add    $0x14,%esp
f0101525:	5b                   	pop    %ebx
f0101526:	5d                   	pop    %ebp
f0101527:	c3                   	ret    

f0101528 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101528:	55                   	push   %ebp
f0101529:	89 e5                	mov    %esp,%ebp
f010152b:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f010152e:	e8 e5 6e 00 00       	call   f0108418 <cpunum>
f0101533:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010153a:	29 c2                	sub    %eax,%edx
f010153c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010153f:	83 3c 85 28 90 35 f0 	cmpl   $0x0,-0xfca6fd8(,%eax,4)
f0101546:	00 
f0101547:	74 20                	je     f0101569 <tlb_invalidate+0x41>
f0101549:	e8 ca 6e 00 00       	call   f0108418 <cpunum>
f010154e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101555:	29 c2                	sub    %eax,%edx
f0101557:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010155a:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0101561:	8b 55 08             	mov    0x8(%ebp),%edx
f0101564:	39 50 60             	cmp    %edx,0x60(%eax)
f0101567:	75 06                	jne    f010156f <tlb_invalidate+0x47>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101569:	8b 45 0c             	mov    0xc(%ebp),%eax
f010156c:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f010156f:	c9                   	leave  
f0101570:	c3                   	ret    

f0101571 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101571:	55                   	push   %ebp
f0101572:	89 e5                	mov    %esp,%ebp
f0101574:	56                   	push   %esi
f0101575:	53                   	push   %ebx
f0101576:	83 ec 20             	sub    $0x20,%esp
f0101579:	8b 75 08             	mov    0x8(%ebp),%esi
f010157c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *ppte;
	struct PageInfo *pp;
	pp = page_lookup(pgdir, va, &ppte);
f010157f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101582:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101586:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010158a:	89 34 24             	mov    %esi,(%esp)
f010158d:	e8 1e ff ff ff       	call   f01014b0 <page_lookup>
	if (!pp || !(*ppte & PTE_P)) return;
f0101592:	85 c0                	test   %eax,%eax
f0101594:	74 25                	je     f01015bb <page_remove+0x4a>
f0101596:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101599:	f6 02 01             	testb  $0x1,(%edx)
f010159c:	74 1d                	je     f01015bb <page_remove+0x4a>
	page_decref(pp);
f010159e:	89 04 24             	mov    %eax,(%esp)
f01015a1:	e8 c3 fd ff ff       	call   f0101369 <page_decref>
	*ppte = 0;
f01015a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f01015af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01015b3:	89 34 24             	mov    %esi,(%esp)
f01015b6:	e8 6d ff ff ff       	call   f0101528 <tlb_invalidate>
}
f01015bb:	83 c4 20             	add    $0x20,%esp
f01015be:	5b                   	pop    %ebx
f01015bf:	5e                   	pop    %esi
f01015c0:	5d                   	pop    %ebp
f01015c1:	c3                   	ret    

f01015c2 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01015c2:	55                   	push   %ebp
f01015c3:	89 e5                	mov    %esp,%ebp
f01015c5:	57                   	push   %edi
f01015c6:	56                   	push   %esi
f01015c7:	53                   	push   %ebx
f01015c8:	83 ec 1c             	sub    $0x1c,%esp
f01015cb:	8b 75 0c             	mov    0xc(%ebp),%esi
f01015ce:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *ppte = pgdir_walk(pgdir, va, 1);
f01015d1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01015d8:	00 
f01015d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01015dd:	8b 45 08             	mov    0x8(%ebp),%eax
f01015e0:	89 04 24             	mov    %eax,(%esp)
f01015e3:	e8 a1 fd ff ff       	call   f0101389 <pgdir_walk>
f01015e8:	89 c3                	mov    %eax,%ebx
	if (!ppte) return -E_NO_MEM;
f01015ea:	85 c0                	test   %eax,%eax
f01015ec:	74 39                	je     f0101627 <page_insert+0x65>
	pp->pp_ref++;
f01015ee:	66 ff 46 04          	incw   0x4(%esi)
	if (*ppte & PTE_P) {
f01015f2:	f6 00 01             	testb  $0x1,(%eax)
f01015f5:	74 0f                	je     f0101606 <page_insert+0x44>
		page_remove(pgdir, va);
f01015f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01015fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01015fe:	89 04 24             	mov    %eax,(%esp)
f0101601:	e8 6b ff ff ff       	call   f0101571 <page_remove>
	}
	*ppte = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
f0101606:	8b 55 14             	mov    0x14(%ebp),%edx
f0101609:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010160c:	2b 35 90 8e 35 f0    	sub    0xf0358e90,%esi
f0101612:	c1 fe 03             	sar    $0x3,%esi
f0101615:	89 f0                	mov    %esi,%eax
f0101617:	c1 e0 0c             	shl    $0xc,%eax
f010161a:	89 d6                	mov    %edx,%esi
f010161c:	09 c6                	or     %eax,%esi
f010161e:	89 33                	mov    %esi,(%ebx)
	return 0;
f0101620:	b8 00 00 00 00       	mov    $0x0,%eax
f0101625:	eb 05                	jmp    f010162c <page_insert+0x6a>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t *ppte = pgdir_walk(pgdir, va, 1);
	if (!ppte) return -E_NO_MEM;
f0101627:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	if (*ppte & PTE_P) {
		page_remove(pgdir, va);
	}
	*ppte = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
	return 0;
}
f010162c:	83 c4 1c             	add    $0x1c,%esp
f010162f:	5b                   	pop    %ebx
f0101630:	5e                   	pop    %esi
f0101631:	5f                   	pop    %edi
f0101632:	5d                   	pop    %ebp
f0101633:	c3                   	ret    

f0101634 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101634:	55                   	push   %ebp
f0101635:	89 e5                	mov    %esp,%ebp
f0101637:	53                   	push   %ebx
f0101638:	83 ec 14             	sub    $0x14,%esp
f010163b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	if (base + size > MMIOLIM)
f010163e:	8b 15 00 e3 12 f0    	mov    0xf012e300,%edx
f0101644:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f0101647:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f010164c:	76 1c                	jbe    f010166a <mmio_map_region+0x36>
		panic("mmio_map_region: too big for MMIOLIM!");
f010164e:	c7 44 24 08 34 94 10 	movl   $0xf0109434,0x8(%esp)
f0101655:	f0 
f0101656:	c7 44 24 04 4d 02 00 	movl   $0x24d,0x4(%esp)
f010165d:	00 
f010165e:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101665:	e8 d6 e9 ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, base, ROUNDUP(size, PGSIZE), pa, PTE_PCD | PTE_PWT | PTE_W);
f010166a:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f0101670:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0101676:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f010167d:	00 
f010167e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101681:	89 04 24             	mov    %eax,(%esp)
f0101684:	89 d9                	mov    %ebx,%ecx
f0101686:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f010168b:	e8 98 fd ff ff       	call   f0101428 <boot_map_region>
	base += ROUNDUP(size, PGSIZE);
f0101690:	a1 00 e3 12 f0       	mov    0xf012e300,%eax
f0101695:	01 c3                	add    %eax,%ebx
f0101697:	89 1d 00 e3 12 f0    	mov    %ebx,0xf012e300
	return (void *)(base-ROUNDUP(size, PGSIZE));
}
f010169d:	83 c4 14             	add    $0x14,%esp
f01016a0:	5b                   	pop    %ebx
f01016a1:	5d                   	pop    %ebp
f01016a2:	c3                   	ret    

f01016a3 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01016a3:	55                   	push   %ebp
f01016a4:	89 e5                	mov    %esp,%ebp
f01016a6:	57                   	push   %edi
f01016a7:	56                   	push   %esi
f01016a8:	53                   	push   %ebx
f01016a9:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01016ac:	b8 15 00 00 00       	mov    $0x15,%eax
f01016b1:	e8 69 f7 ff ff       	call   f0100e1f <nvram_read>
f01016b6:	c1 e0 0a             	shl    $0xa,%eax
f01016b9:	89 c2                	mov    %eax,%edx
f01016bb:	85 c0                	test   %eax,%eax
f01016bd:	79 06                	jns    f01016c5 <mem_init+0x22>
f01016bf:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01016c5:	c1 fa 0c             	sar    $0xc,%edx
f01016c8:	89 15 38 82 35 f0    	mov    %edx,0xf0358238
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01016ce:	b8 17 00 00 00       	mov    $0x17,%eax
f01016d3:	e8 47 f7 ff ff       	call   f0100e1f <nvram_read>
f01016d8:	89 c2                	mov    %eax,%edx
f01016da:	c1 e2 0a             	shl    $0xa,%edx
f01016dd:	89 d0                	mov    %edx,%eax
f01016df:	85 d2                	test   %edx,%edx
f01016e1:	79 06                	jns    f01016e9 <mem_init+0x46>
f01016e3:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01016e9:	c1 f8 0c             	sar    $0xc,%eax
f01016ec:	74 0e                	je     f01016fc <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01016ee:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01016f4:	89 15 88 8e 35 f0    	mov    %edx,0xf0358e88
f01016fa:	eb 0c                	jmp    f0101708 <mem_init+0x65>
	else
		npages = npages_basemem;
f01016fc:	8b 15 38 82 35 f0    	mov    0xf0358238,%edx
f0101702:	89 15 88 8e 35 f0    	mov    %edx,0xf0358e88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101708:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010170b:	c1 e8 0a             	shr    $0xa,%eax
f010170e:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101712:	a1 38 82 35 f0       	mov    0xf0358238,%eax
f0101717:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010171a:	c1 e8 0a             	shr    $0xa,%eax
f010171d:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101721:	a1 88 8e 35 f0       	mov    0xf0358e88,%eax
f0101726:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101729:	c1 e8 0a             	shr    $0xa,%eax
f010172c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101730:	c7 04 24 5c 94 10 f0 	movl   $0xf010945c,(%esp)
f0101737:	e8 4e 2b 00 00       	call   f010428a <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010173c:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101741:	e8 1e f6 ff ff       	call   f0100d64 <boot_alloc>
f0101746:	a3 8c 8e 35 f0       	mov    %eax,0xf0358e8c
	memset(kern_pgdir, 0, PGSIZE);
f010174b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101752:	00 
f0101753:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010175a:	00 
f010175b:	89 04 24             	mov    %eax,(%esp)
f010175e:	e8 87 66 00 00       	call   f0107dea <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101763:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101768:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010176d:	77 20                	ja     f010178f <mem_init+0xec>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010176f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101773:	c7 44 24 08 04 8b 10 	movl   $0xf0108b04,0x8(%esp)
f010177a:	f0 
f010177b:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
f0101782:	00 
f0101783:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f010178a:	e8 b1 e8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010178f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101795:	83 ca 05             	or     $0x5,%edx
f0101798:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo) * npages);
f010179e:	a1 88 8e 35 f0       	mov    0xf0358e88,%eax
f01017a3:	c1 e0 03             	shl    $0x3,%eax
f01017a6:	e8 b9 f5 ff ff       	call   f0100d64 <boot_alloc>
f01017ab:	a3 90 8e 35 f0       	mov    %eax,0xf0358e90
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f01017b0:	8b 15 88 8e 35 f0    	mov    0xf0358e88,%edx
f01017b6:	c1 e2 03             	shl    $0x3,%edx
f01017b9:	89 54 24 08          	mov    %edx,0x8(%esp)
f01017bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01017c4:	00 
f01017c5:	89 04 24             	mov    %eax,(%esp)
f01017c8:	e8 1d 66 00 00       	call   f0107dea <memset>


	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(sizeof(struct Env) * NENV);
f01017cd:	b8 00 c0 03 00       	mov    $0x3c000,%eax
f01017d2:	e8 8d f5 ff ff       	call   f0100d64 <boot_alloc>
f01017d7:	a3 48 82 35 f0       	mov    %eax,0xf0358248
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01017dc:	e8 ba f9 ff ff       	call   f010119b <page_init>

	check_page_free_list(1);
f01017e1:	b8 01 00 00 00       	mov    $0x1,%eax
f01017e6:	e8 5d f6 ff ff       	call   f0100e48 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01017eb:	83 3d 90 8e 35 f0 00 	cmpl   $0x0,0xf0358e90
f01017f2:	75 1c                	jne    f0101810 <mem_init+0x16d>
		panic("'pages' is a null pointer!");
f01017f4:	c7 44 24 08 48 9d 10 	movl   $0xf0109d48,0x8(%esp)
f01017fb:	f0 
f01017fc:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f0101803:	00 
f0101804:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f010180b:	e8 30 e8 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101810:	a1 40 82 35 f0       	mov    0xf0358240,%eax
f0101815:	bb 00 00 00 00       	mov    $0x0,%ebx
f010181a:	eb 03                	jmp    f010181f <mem_init+0x17c>
		++nfree;
f010181c:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010181d:	8b 00                	mov    (%eax),%eax
f010181f:	85 c0                	test   %eax,%eax
f0101821:	75 f9                	jne    f010181c <mem_init+0x179>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101823:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010182a:	e8 5a fa ff ff       	call   f0101289 <page_alloc>
f010182f:	89 c6                	mov    %eax,%esi
f0101831:	85 c0                	test   %eax,%eax
f0101833:	75 24                	jne    f0101859 <mem_init+0x1b6>
f0101835:	c7 44 24 0c 63 9d 10 	movl   $0xf0109d63,0xc(%esp)
f010183c:	f0 
f010183d:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101844:	f0 
f0101845:	c7 44 24 04 e0 02 00 	movl   $0x2e0,0x4(%esp)
f010184c:	00 
f010184d:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101854:	e8 e7 e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101859:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101860:	e8 24 fa ff ff       	call   f0101289 <page_alloc>
f0101865:	89 c7                	mov    %eax,%edi
f0101867:	85 c0                	test   %eax,%eax
f0101869:	75 24                	jne    f010188f <mem_init+0x1ec>
f010186b:	c7 44 24 0c 79 9d 10 	movl   $0xf0109d79,0xc(%esp)
f0101872:	f0 
f0101873:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f010187a:	f0 
f010187b:	c7 44 24 04 e1 02 00 	movl   $0x2e1,0x4(%esp)
f0101882:	00 
f0101883:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f010188a:	e8 b1 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010188f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101896:	e8 ee f9 ff ff       	call   f0101289 <page_alloc>
f010189b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010189e:	85 c0                	test   %eax,%eax
f01018a0:	75 24                	jne    f01018c6 <mem_init+0x223>
f01018a2:	c7 44 24 0c 8f 9d 10 	movl   $0xf0109d8f,0xc(%esp)
f01018a9:	f0 
f01018aa:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01018b1:	f0 
f01018b2:	c7 44 24 04 e2 02 00 	movl   $0x2e2,0x4(%esp)
f01018b9:	00 
f01018ba:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01018c1:	e8 7a e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018c6:	39 fe                	cmp    %edi,%esi
f01018c8:	75 24                	jne    f01018ee <mem_init+0x24b>
f01018ca:	c7 44 24 0c a5 9d 10 	movl   $0xf0109da5,0xc(%esp)
f01018d1:	f0 
f01018d2:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01018d9:	f0 
f01018da:	c7 44 24 04 e5 02 00 	movl   $0x2e5,0x4(%esp)
f01018e1:	00 
f01018e2:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01018e9:	e8 52 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018ee:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01018f1:	74 05                	je     f01018f8 <mem_init+0x255>
f01018f3:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01018f6:	75 24                	jne    f010191c <mem_init+0x279>
f01018f8:	c7 44 24 0c 98 94 10 	movl   $0xf0109498,0xc(%esp)
f01018ff:	f0 
f0101900:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101907:	f0 
f0101908:	c7 44 24 04 e6 02 00 	movl   $0x2e6,0x4(%esp)
f010190f:	00 
f0101910:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101917:	e8 24 e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010191c:	8b 15 90 8e 35 f0    	mov    0xf0358e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101922:	a1 88 8e 35 f0       	mov    0xf0358e88,%eax
f0101927:	c1 e0 0c             	shl    $0xc,%eax
f010192a:	89 f1                	mov    %esi,%ecx
f010192c:	29 d1                	sub    %edx,%ecx
f010192e:	c1 f9 03             	sar    $0x3,%ecx
f0101931:	c1 e1 0c             	shl    $0xc,%ecx
f0101934:	39 c1                	cmp    %eax,%ecx
f0101936:	72 24                	jb     f010195c <mem_init+0x2b9>
f0101938:	c7 44 24 0c b7 9d 10 	movl   $0xf0109db7,0xc(%esp)
f010193f:	f0 
f0101940:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101947:	f0 
f0101948:	c7 44 24 04 e7 02 00 	movl   $0x2e7,0x4(%esp)
f010194f:	00 
f0101950:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101957:	e8 e4 e6 ff ff       	call   f0100040 <_panic>
f010195c:	89 f9                	mov    %edi,%ecx
f010195e:	29 d1                	sub    %edx,%ecx
f0101960:	c1 f9 03             	sar    $0x3,%ecx
f0101963:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101966:	39 c8                	cmp    %ecx,%eax
f0101968:	77 24                	ja     f010198e <mem_init+0x2eb>
f010196a:	c7 44 24 0c d4 9d 10 	movl   $0xf0109dd4,0xc(%esp)
f0101971:	f0 
f0101972:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101979:	f0 
f010197a:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0101981:	00 
f0101982:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101989:	e8 b2 e6 ff ff       	call   f0100040 <_panic>
f010198e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101991:	29 d1                	sub    %edx,%ecx
f0101993:	89 ca                	mov    %ecx,%edx
f0101995:	c1 fa 03             	sar    $0x3,%edx
f0101998:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010199b:	39 d0                	cmp    %edx,%eax
f010199d:	77 24                	ja     f01019c3 <mem_init+0x320>
f010199f:	c7 44 24 0c f1 9d 10 	movl   $0xf0109df1,0xc(%esp)
f01019a6:	f0 
f01019a7:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01019ae:	f0 
f01019af:	c7 44 24 04 e9 02 00 	movl   $0x2e9,0x4(%esp)
f01019b6:	00 
f01019b7:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01019be:	e8 7d e6 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01019c3:	a1 40 82 35 f0       	mov    0xf0358240,%eax
f01019c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01019cb:	c7 05 40 82 35 f0 00 	movl   $0x0,0xf0358240
f01019d2:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01019d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019dc:	e8 a8 f8 ff ff       	call   f0101289 <page_alloc>
f01019e1:	85 c0                	test   %eax,%eax
f01019e3:	74 24                	je     f0101a09 <mem_init+0x366>
f01019e5:	c7 44 24 0c 0e 9e 10 	movl   $0xf0109e0e,0xc(%esp)
f01019ec:	f0 
f01019ed:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01019f4:	f0 
f01019f5:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f01019fc:	00 
f01019fd:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101a04:	e8 37 e6 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101a09:	89 34 24             	mov    %esi,(%esp)
f0101a0c:	e8 fc f8 ff ff       	call   f010130d <page_free>
	page_free(pp1);
f0101a11:	89 3c 24             	mov    %edi,(%esp)
f0101a14:	e8 f4 f8 ff ff       	call   f010130d <page_free>
	page_free(pp2);
f0101a19:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a1c:	89 04 24             	mov    %eax,(%esp)
f0101a1f:	e8 e9 f8 ff ff       	call   f010130d <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a2b:	e8 59 f8 ff ff       	call   f0101289 <page_alloc>
f0101a30:	89 c6                	mov    %eax,%esi
f0101a32:	85 c0                	test   %eax,%eax
f0101a34:	75 24                	jne    f0101a5a <mem_init+0x3b7>
f0101a36:	c7 44 24 0c 63 9d 10 	movl   $0xf0109d63,0xc(%esp)
f0101a3d:	f0 
f0101a3e:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101a45:	f0 
f0101a46:	c7 44 24 04 f7 02 00 	movl   $0x2f7,0x4(%esp)
f0101a4d:	00 
f0101a4e:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101a55:	e8 e6 e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a5a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a61:	e8 23 f8 ff ff       	call   f0101289 <page_alloc>
f0101a66:	89 c7                	mov    %eax,%edi
f0101a68:	85 c0                	test   %eax,%eax
f0101a6a:	75 24                	jne    f0101a90 <mem_init+0x3ed>
f0101a6c:	c7 44 24 0c 79 9d 10 	movl   $0xf0109d79,0xc(%esp)
f0101a73:	f0 
f0101a74:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101a7b:	f0 
f0101a7c:	c7 44 24 04 f8 02 00 	movl   $0x2f8,0x4(%esp)
f0101a83:	00 
f0101a84:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101a8b:	e8 b0 e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a90:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a97:	e8 ed f7 ff ff       	call   f0101289 <page_alloc>
f0101a9c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a9f:	85 c0                	test   %eax,%eax
f0101aa1:	75 24                	jne    f0101ac7 <mem_init+0x424>
f0101aa3:	c7 44 24 0c 8f 9d 10 	movl   $0xf0109d8f,0xc(%esp)
f0101aaa:	f0 
f0101aab:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101ab2:	f0 
f0101ab3:	c7 44 24 04 f9 02 00 	movl   $0x2f9,0x4(%esp)
f0101aba:	00 
f0101abb:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101ac2:	e8 79 e5 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101ac7:	39 fe                	cmp    %edi,%esi
f0101ac9:	75 24                	jne    f0101aef <mem_init+0x44c>
f0101acb:	c7 44 24 0c a5 9d 10 	movl   $0xf0109da5,0xc(%esp)
f0101ad2:	f0 
f0101ad3:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101ada:	f0 
f0101adb:	c7 44 24 04 fb 02 00 	movl   $0x2fb,0x4(%esp)
f0101ae2:	00 
f0101ae3:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101aea:	e8 51 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101aef:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101af2:	74 05                	je     f0101af9 <mem_init+0x456>
f0101af4:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101af7:	75 24                	jne    f0101b1d <mem_init+0x47a>
f0101af9:	c7 44 24 0c 98 94 10 	movl   $0xf0109498,0xc(%esp)
f0101b00:	f0 
f0101b01:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101b08:	f0 
f0101b09:	c7 44 24 04 fc 02 00 	movl   $0x2fc,0x4(%esp)
f0101b10:	00 
f0101b11:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101b18:	e8 23 e5 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101b1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b24:	e8 60 f7 ff ff       	call   f0101289 <page_alloc>
f0101b29:	85 c0                	test   %eax,%eax
f0101b2b:	74 24                	je     f0101b51 <mem_init+0x4ae>
f0101b2d:	c7 44 24 0c 0e 9e 10 	movl   $0xf0109e0e,0xc(%esp)
f0101b34:	f0 
f0101b35:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101b3c:	f0 
f0101b3d:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f0101b44:	00 
f0101b45:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101b4c:	e8 ef e4 ff ff       	call   f0100040 <_panic>
f0101b51:	89 f0                	mov    %esi,%eax
f0101b53:	2b 05 90 8e 35 f0    	sub    0xf0358e90,%eax
f0101b59:	c1 f8 03             	sar    $0x3,%eax
f0101b5c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b5f:	89 c2                	mov    %eax,%edx
f0101b61:	c1 ea 0c             	shr    $0xc,%edx
f0101b64:	3b 15 88 8e 35 f0    	cmp    0xf0358e88,%edx
f0101b6a:	72 20                	jb     f0101b8c <mem_init+0x4e9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b6c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101b70:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f0101b77:	f0 
f0101b78:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101b7f:	00 
f0101b80:	c7 04 24 81 9c 10 f0 	movl   $0xf0109c81,(%esp)
f0101b87:	e8 b4 e4 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101b8c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101b93:	00 
f0101b94:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101b9b:	00 
	return (void *)(pa + KERNBASE);
f0101b9c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ba1:	89 04 24             	mov    %eax,(%esp)
f0101ba4:	e8 41 62 00 00       	call   f0107dea <memset>
	page_free(pp0);
f0101ba9:	89 34 24             	mov    %esi,(%esp)
f0101bac:	e8 5c f7 ff ff       	call   f010130d <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101bb1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101bb8:	e8 cc f6 ff ff       	call   f0101289 <page_alloc>
f0101bbd:	85 c0                	test   %eax,%eax
f0101bbf:	75 24                	jne    f0101be5 <mem_init+0x542>
f0101bc1:	c7 44 24 0c 1d 9e 10 	movl   $0xf0109e1d,0xc(%esp)
f0101bc8:	f0 
f0101bc9:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101bd0:	f0 
f0101bd1:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f0101bd8:	00 
f0101bd9:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101be0:	e8 5b e4 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101be5:	39 c6                	cmp    %eax,%esi
f0101be7:	74 24                	je     f0101c0d <mem_init+0x56a>
f0101be9:	c7 44 24 0c 3b 9e 10 	movl   $0xf0109e3b,0xc(%esp)
f0101bf0:	f0 
f0101bf1:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101bf8:	f0 
f0101bf9:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f0101c00:	00 
f0101c01:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101c08:	e8 33 e4 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101c0d:	89 f2                	mov    %esi,%edx
f0101c0f:	2b 15 90 8e 35 f0    	sub    0xf0358e90,%edx
f0101c15:	c1 fa 03             	sar    $0x3,%edx
f0101c18:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c1b:	89 d0                	mov    %edx,%eax
f0101c1d:	c1 e8 0c             	shr    $0xc,%eax
f0101c20:	3b 05 88 8e 35 f0    	cmp    0xf0358e88,%eax
f0101c26:	72 20                	jb     f0101c48 <mem_init+0x5a5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c28:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101c2c:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f0101c33:	f0 
f0101c34:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101c3b:	00 
f0101c3c:	c7 04 24 81 9c 10 f0 	movl   $0xf0109c81,(%esp)
f0101c43:	e8 f8 e3 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101c48:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101c4e:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101c54:	80 38 00             	cmpb   $0x0,(%eax)
f0101c57:	74 24                	je     f0101c7d <mem_init+0x5da>
f0101c59:	c7 44 24 0c 4b 9e 10 	movl   $0xf0109e4b,0xc(%esp)
f0101c60:	f0 
f0101c61:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101c68:	f0 
f0101c69:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f0101c70:	00 
f0101c71:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101c78:	e8 c3 e3 ff ff       	call   f0100040 <_panic>
f0101c7d:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101c7e:	39 d0                	cmp    %edx,%eax
f0101c80:	75 d2                	jne    f0101c54 <mem_init+0x5b1>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101c82:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101c85:	89 15 40 82 35 f0    	mov    %edx,0xf0358240

	// free the pages we took
	page_free(pp0);
f0101c8b:	89 34 24             	mov    %esi,(%esp)
f0101c8e:	e8 7a f6 ff ff       	call   f010130d <page_free>
	page_free(pp1);
f0101c93:	89 3c 24             	mov    %edi,(%esp)
f0101c96:	e8 72 f6 ff ff       	call   f010130d <page_free>
	page_free(pp2);
f0101c9b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c9e:	89 04 24             	mov    %eax,(%esp)
f0101ca1:	e8 67 f6 ff ff       	call   f010130d <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101ca6:	a1 40 82 35 f0       	mov    0xf0358240,%eax
f0101cab:	eb 03                	jmp    f0101cb0 <mem_init+0x60d>
		--nfree;
f0101cad:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101cae:	8b 00                	mov    (%eax),%eax
f0101cb0:	85 c0                	test   %eax,%eax
f0101cb2:	75 f9                	jne    f0101cad <mem_init+0x60a>
		--nfree;
	assert(nfree == 0);
f0101cb4:	85 db                	test   %ebx,%ebx
f0101cb6:	74 24                	je     f0101cdc <mem_init+0x639>
f0101cb8:	c7 44 24 0c 55 9e 10 	movl   $0xf0109e55,0xc(%esp)
f0101cbf:	f0 
f0101cc0:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101cc7:	f0 
f0101cc8:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f0101ccf:	00 
f0101cd0:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101cd7:	e8 64 e3 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101cdc:	c7 04 24 b8 94 10 f0 	movl   $0xf01094b8,(%esp)
f0101ce3:	e8 a2 25 00 00       	call   f010428a <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101ce8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cef:	e8 95 f5 ff ff       	call   f0101289 <page_alloc>
f0101cf4:	89 c7                	mov    %eax,%edi
f0101cf6:	85 c0                	test   %eax,%eax
f0101cf8:	75 24                	jne    f0101d1e <mem_init+0x67b>
f0101cfa:	c7 44 24 0c 63 9d 10 	movl   $0xf0109d63,0xc(%esp)
f0101d01:	f0 
f0101d02:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101d09:	f0 
f0101d0a:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0101d11:	00 
f0101d12:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101d19:	e8 22 e3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101d1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d25:	e8 5f f5 ff ff       	call   f0101289 <page_alloc>
f0101d2a:	89 c6                	mov    %eax,%esi
f0101d2c:	85 c0                	test   %eax,%eax
f0101d2e:	75 24                	jne    f0101d54 <mem_init+0x6b1>
f0101d30:	c7 44 24 0c 79 9d 10 	movl   $0xf0109d79,0xc(%esp)
f0101d37:	f0 
f0101d38:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101d3f:	f0 
f0101d40:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0101d47:	00 
f0101d48:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101d4f:	e8 ec e2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101d54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d5b:	e8 29 f5 ff ff       	call   f0101289 <page_alloc>
f0101d60:	89 c3                	mov    %eax,%ebx
f0101d62:	85 c0                	test   %eax,%eax
f0101d64:	75 24                	jne    f0101d8a <mem_init+0x6e7>
f0101d66:	c7 44 24 0c 8f 9d 10 	movl   $0xf0109d8f,0xc(%esp)
f0101d6d:	f0 
f0101d6e:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101d75:	f0 
f0101d76:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0101d7d:	00 
f0101d7e:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101d85:	e8 b6 e2 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101d8a:	39 f7                	cmp    %esi,%edi
f0101d8c:	75 24                	jne    f0101db2 <mem_init+0x70f>
f0101d8e:	c7 44 24 0c a5 9d 10 	movl   $0xf0109da5,0xc(%esp)
f0101d95:	f0 
f0101d96:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101d9d:	f0 
f0101d9e:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0101da5:	00 
f0101da6:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101dad:	e8 8e e2 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101db2:	39 c6                	cmp    %eax,%esi
f0101db4:	74 04                	je     f0101dba <mem_init+0x717>
f0101db6:	39 c7                	cmp    %eax,%edi
f0101db8:	75 24                	jne    f0101dde <mem_init+0x73b>
f0101dba:	c7 44 24 0c 98 94 10 	movl   $0xf0109498,0xc(%esp)
f0101dc1:	f0 
f0101dc2:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101dc9:	f0 
f0101dca:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0101dd1:	00 
f0101dd2:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101dd9:	e8 62 e2 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101dde:	8b 15 40 82 35 f0    	mov    0xf0358240,%edx
f0101de4:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101de7:	c7 05 40 82 35 f0 00 	movl   $0x0,0xf0358240
f0101dee:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101df1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101df8:	e8 8c f4 ff ff       	call   f0101289 <page_alloc>
f0101dfd:	85 c0                	test   %eax,%eax
f0101dff:	74 24                	je     f0101e25 <mem_init+0x782>
f0101e01:	c7 44 24 0c 0e 9e 10 	movl   $0xf0109e0e,0xc(%esp)
f0101e08:	f0 
f0101e09:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101e10:	f0 
f0101e11:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f0101e18:	00 
f0101e19:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101e20:	e8 1b e2 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101e25:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101e28:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101e2c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101e33:	00 
f0101e34:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0101e39:	89 04 24             	mov    %eax,(%esp)
f0101e3c:	e8 6f f6 ff ff       	call   f01014b0 <page_lookup>
f0101e41:	85 c0                	test   %eax,%eax
f0101e43:	74 24                	je     f0101e69 <mem_init+0x7c6>
f0101e45:	c7 44 24 0c d8 94 10 	movl   $0xf01094d8,0xc(%esp)
f0101e4c:	f0 
f0101e4d:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101e54:	f0 
f0101e55:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0101e5c:	00 
f0101e5d:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101e64:	e8 d7 e1 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101e69:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e70:	00 
f0101e71:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e78:	00 
f0101e79:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e7d:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0101e82:	89 04 24             	mov    %eax,(%esp)
f0101e85:	e8 38 f7 ff ff       	call   f01015c2 <page_insert>
f0101e8a:	85 c0                	test   %eax,%eax
f0101e8c:	78 24                	js     f0101eb2 <mem_init+0x80f>
f0101e8e:	c7 44 24 0c 10 95 10 	movl   $0xf0109510,0xc(%esp)
f0101e95:	f0 
f0101e96:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101e9d:	f0 
f0101e9e:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f0101ea5:	00 
f0101ea6:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101ead:	e8 8e e1 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101eb2:	89 3c 24             	mov    %edi,(%esp)
f0101eb5:	e8 53 f4 ff ff       	call   f010130d <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101eba:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ec1:	00 
f0101ec2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ec9:	00 
f0101eca:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101ece:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0101ed3:	89 04 24             	mov    %eax,(%esp)
f0101ed6:	e8 e7 f6 ff ff       	call   f01015c2 <page_insert>
f0101edb:	85 c0                	test   %eax,%eax
f0101edd:	74 24                	je     f0101f03 <mem_init+0x860>
f0101edf:	c7 44 24 0c 40 95 10 	movl   $0xf0109540,0xc(%esp)
f0101ee6:	f0 
f0101ee7:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101eee:	f0 
f0101eef:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0101ef6:	00 
f0101ef7:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101efe:	e8 3d e1 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f03:	8b 0d 8c 8e 35 f0    	mov    0xf0358e8c,%ecx
f0101f09:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f0c:	a1 90 8e 35 f0       	mov    0xf0358e90,%eax
f0101f11:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101f14:	8b 11                	mov    (%ecx),%edx
f0101f16:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101f1c:	89 f8                	mov    %edi,%eax
f0101f1e:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101f21:	c1 f8 03             	sar    $0x3,%eax
f0101f24:	c1 e0 0c             	shl    $0xc,%eax
f0101f27:	39 c2                	cmp    %eax,%edx
f0101f29:	74 24                	je     f0101f4f <mem_init+0x8ac>
f0101f2b:	c7 44 24 0c 70 95 10 	movl   $0xf0109570,0xc(%esp)
f0101f32:	f0 
f0101f33:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101f3a:	f0 
f0101f3b:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0101f42:	00 
f0101f43:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101f4a:	e8 f1 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101f4f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f54:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f57:	e8 56 ee ff ff       	call   f0100db2 <check_va2pa>
f0101f5c:	89 f2                	mov    %esi,%edx
f0101f5e:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101f61:	c1 fa 03             	sar    $0x3,%edx
f0101f64:	c1 e2 0c             	shl    $0xc,%edx
f0101f67:	39 d0                	cmp    %edx,%eax
f0101f69:	74 24                	je     f0101f8f <mem_init+0x8ec>
f0101f6b:	c7 44 24 0c 98 95 10 	movl   $0xf0109598,0xc(%esp)
f0101f72:	f0 
f0101f73:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101f7a:	f0 
f0101f7b:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0101f82:	00 
f0101f83:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101f8a:	e8 b1 e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101f8f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f94:	74 24                	je     f0101fba <mem_init+0x917>
f0101f96:	c7 44 24 0c 60 9e 10 	movl   $0xf0109e60,0xc(%esp)
f0101f9d:	f0 
f0101f9e:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101fa5:	f0 
f0101fa6:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f0101fad:	00 
f0101fae:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101fb5:	e8 86 e0 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101fba:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101fbf:	74 24                	je     f0101fe5 <mem_init+0x942>
f0101fc1:	c7 44 24 0c 71 9e 10 	movl   $0xf0109e71,0xc(%esp)
f0101fc8:	f0 
f0101fc9:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0101fd0:	f0 
f0101fd1:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0101fd8:	00 
f0101fd9:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0101fe0:	e8 5b e0 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101fe5:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101fec:	00 
f0101fed:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ff4:	00 
f0101ff5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ff9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101ffc:	89 14 24             	mov    %edx,(%esp)
f0101fff:	e8 be f5 ff ff       	call   f01015c2 <page_insert>
f0102004:	85 c0                	test   %eax,%eax
f0102006:	74 24                	je     f010202c <mem_init+0x989>
f0102008:	c7 44 24 0c c8 95 10 	movl   $0xf01095c8,0xc(%esp)
f010200f:	f0 
f0102010:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102017:	f0 
f0102018:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f010201f:	00 
f0102020:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102027:	e8 14 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010202c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102031:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0102036:	e8 77 ed ff ff       	call   f0100db2 <check_va2pa>
f010203b:	89 da                	mov    %ebx,%edx
f010203d:	2b 15 90 8e 35 f0    	sub    0xf0358e90,%edx
f0102043:	c1 fa 03             	sar    $0x3,%edx
f0102046:	c1 e2 0c             	shl    $0xc,%edx
f0102049:	39 d0                	cmp    %edx,%eax
f010204b:	74 24                	je     f0102071 <mem_init+0x9ce>
f010204d:	c7 44 24 0c 04 96 10 	movl   $0xf0109604,0xc(%esp)
f0102054:	f0 
f0102055:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f010205c:	f0 
f010205d:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f0102064:	00 
f0102065:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f010206c:	e8 cf df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102071:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102076:	74 24                	je     f010209c <mem_init+0x9f9>
f0102078:	c7 44 24 0c 82 9e 10 	movl   $0xf0109e82,0xc(%esp)
f010207f:	f0 
f0102080:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102087:	f0 
f0102088:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f010208f:	00 
f0102090:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102097:	e8 a4 df ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010209c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01020a3:	e8 e1 f1 ff ff       	call   f0101289 <page_alloc>
f01020a8:	85 c0                	test   %eax,%eax
f01020aa:	74 24                	je     f01020d0 <mem_init+0xa2d>
f01020ac:	c7 44 24 0c 0e 9e 10 	movl   $0xf0109e0e,0xc(%esp)
f01020b3:	f0 
f01020b4:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01020bb:	f0 
f01020bc:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f01020c3:	00 
f01020c4:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01020cb:	e8 70 df ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01020d0:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020d7:	00 
f01020d8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01020df:	00 
f01020e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01020e4:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f01020e9:	89 04 24             	mov    %eax,(%esp)
f01020ec:	e8 d1 f4 ff ff       	call   f01015c2 <page_insert>
f01020f1:	85 c0                	test   %eax,%eax
f01020f3:	74 24                	je     f0102119 <mem_init+0xa76>
f01020f5:	c7 44 24 0c c8 95 10 	movl   $0xf01095c8,0xc(%esp)
f01020fc:	f0 
f01020fd:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102104:	f0 
f0102105:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f010210c:	00 
f010210d:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102114:	e8 27 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102119:	ba 00 10 00 00       	mov    $0x1000,%edx
f010211e:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0102123:	e8 8a ec ff ff       	call   f0100db2 <check_va2pa>
f0102128:	89 da                	mov    %ebx,%edx
f010212a:	2b 15 90 8e 35 f0    	sub    0xf0358e90,%edx
f0102130:	c1 fa 03             	sar    $0x3,%edx
f0102133:	c1 e2 0c             	shl    $0xc,%edx
f0102136:	39 d0                	cmp    %edx,%eax
f0102138:	74 24                	je     f010215e <mem_init+0xabb>
f010213a:	c7 44 24 0c 04 96 10 	movl   $0xf0109604,0xc(%esp)
f0102141:	f0 
f0102142:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102149:	f0 
f010214a:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f0102151:	00 
f0102152:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102159:	e8 e2 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010215e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102163:	74 24                	je     f0102189 <mem_init+0xae6>
f0102165:	c7 44 24 0c 82 9e 10 	movl   $0xf0109e82,0xc(%esp)
f010216c:	f0 
f010216d:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102174:	f0 
f0102175:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f010217c:	00 
f010217d:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102184:	e8 b7 de ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102189:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102190:	e8 f4 f0 ff ff       	call   f0101289 <page_alloc>
f0102195:	85 c0                	test   %eax,%eax
f0102197:	74 24                	je     f01021bd <mem_init+0xb1a>
f0102199:	c7 44 24 0c 0e 9e 10 	movl   $0xf0109e0e,0xc(%esp)
f01021a0:	f0 
f01021a1:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01021a8:	f0 
f01021a9:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f01021b0:	00 
f01021b1:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01021b8:	e8 83 de ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01021bd:	8b 15 8c 8e 35 f0    	mov    0xf0358e8c,%edx
f01021c3:	8b 02                	mov    (%edx),%eax
f01021c5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01021ca:	89 c1                	mov    %eax,%ecx
f01021cc:	c1 e9 0c             	shr    $0xc,%ecx
f01021cf:	3b 0d 88 8e 35 f0    	cmp    0xf0358e88,%ecx
f01021d5:	72 20                	jb     f01021f7 <mem_init+0xb54>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01021db:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f01021e2:	f0 
f01021e3:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f01021ea:	00 
f01021eb:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01021f2:	e8 49 de ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01021f7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01021fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01021ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102206:	00 
f0102207:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010220e:	00 
f010220f:	89 14 24             	mov    %edx,(%esp)
f0102212:	e8 72 f1 ff ff       	call   f0101389 <pgdir_walk>
f0102217:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010221a:	83 c2 04             	add    $0x4,%edx
f010221d:	39 d0                	cmp    %edx,%eax
f010221f:	74 24                	je     f0102245 <mem_init+0xba2>
f0102221:	c7 44 24 0c 34 96 10 	movl   $0xf0109634,0xc(%esp)
f0102228:	f0 
f0102229:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102230:	f0 
f0102231:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0102238:	00 
f0102239:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102240:	e8 fb dd ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102245:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010224c:	00 
f010224d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102254:	00 
f0102255:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102259:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f010225e:	89 04 24             	mov    %eax,(%esp)
f0102261:	e8 5c f3 ff ff       	call   f01015c2 <page_insert>
f0102266:	85 c0                	test   %eax,%eax
f0102268:	74 24                	je     f010228e <mem_init+0xbeb>
f010226a:	c7 44 24 0c 74 96 10 	movl   $0xf0109674,0xc(%esp)
f0102271:	f0 
f0102272:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102279:	f0 
f010227a:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f0102281:	00 
f0102282:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102289:	e8 b2 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010228e:	8b 0d 8c 8e 35 f0    	mov    0xf0358e8c,%ecx
f0102294:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102297:	ba 00 10 00 00       	mov    $0x1000,%edx
f010229c:	89 c8                	mov    %ecx,%eax
f010229e:	e8 0f eb ff ff       	call   f0100db2 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01022a3:	89 da                	mov    %ebx,%edx
f01022a5:	2b 15 90 8e 35 f0    	sub    0xf0358e90,%edx
f01022ab:	c1 fa 03             	sar    $0x3,%edx
f01022ae:	c1 e2 0c             	shl    $0xc,%edx
f01022b1:	39 d0                	cmp    %edx,%eax
f01022b3:	74 24                	je     f01022d9 <mem_init+0xc36>
f01022b5:	c7 44 24 0c 04 96 10 	movl   $0xf0109604,0xc(%esp)
f01022bc:	f0 
f01022bd:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01022c4:	f0 
f01022c5:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f01022cc:	00 
f01022cd:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01022d4:	e8 67 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01022d9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01022de:	74 24                	je     f0102304 <mem_init+0xc61>
f01022e0:	c7 44 24 0c 82 9e 10 	movl   $0xf0109e82,0xc(%esp)
f01022e7:	f0 
f01022e8:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01022ef:	f0 
f01022f0:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f01022f7:	00 
f01022f8:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01022ff:	e8 3c dd ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102304:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010230b:	00 
f010230c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102313:	00 
f0102314:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102317:	89 04 24             	mov    %eax,(%esp)
f010231a:	e8 6a f0 ff ff       	call   f0101389 <pgdir_walk>
f010231f:	f6 00 04             	testb  $0x4,(%eax)
f0102322:	75 24                	jne    f0102348 <mem_init+0xca5>
f0102324:	c7 44 24 0c b4 96 10 	movl   $0xf01096b4,0xc(%esp)
f010232b:	f0 
f010232c:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102333:	f0 
f0102334:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f010233b:	00 
f010233c:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102343:	e8 f8 dc ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102348:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f010234d:	f6 00 04             	testb  $0x4,(%eax)
f0102350:	75 24                	jne    f0102376 <mem_init+0xcd3>
f0102352:	c7 44 24 0c 93 9e 10 	movl   $0xf0109e93,0xc(%esp)
f0102359:	f0 
f010235a:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102361:	f0 
f0102362:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0102369:	00 
f010236a:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102371:	e8 ca dc ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102376:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010237d:	00 
f010237e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102385:	00 
f0102386:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010238a:	89 04 24             	mov    %eax,(%esp)
f010238d:	e8 30 f2 ff ff       	call   f01015c2 <page_insert>
f0102392:	85 c0                	test   %eax,%eax
f0102394:	74 24                	je     f01023ba <mem_init+0xd17>
f0102396:	c7 44 24 0c c8 95 10 	movl   $0xf01095c8,0xc(%esp)
f010239d:	f0 
f010239e:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01023a5:	f0 
f01023a6:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f01023ad:	00 
f01023ae:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01023b5:	e8 86 dc ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01023ba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01023c1:	00 
f01023c2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01023c9:	00 
f01023ca:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f01023cf:	89 04 24             	mov    %eax,(%esp)
f01023d2:	e8 b2 ef ff ff       	call   f0101389 <pgdir_walk>
f01023d7:	f6 00 02             	testb  $0x2,(%eax)
f01023da:	75 24                	jne    f0102400 <mem_init+0xd5d>
f01023dc:	c7 44 24 0c e8 96 10 	movl   $0xf01096e8,0xc(%esp)
f01023e3:	f0 
f01023e4:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01023eb:	f0 
f01023ec:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f01023f3:	00 
f01023f4:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01023fb:	e8 40 dc ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102400:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102407:	00 
f0102408:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010240f:	00 
f0102410:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0102415:	89 04 24             	mov    %eax,(%esp)
f0102418:	e8 6c ef ff ff       	call   f0101389 <pgdir_walk>
f010241d:	f6 00 04             	testb  $0x4,(%eax)
f0102420:	74 24                	je     f0102446 <mem_init+0xda3>
f0102422:	c7 44 24 0c 1c 97 10 	movl   $0xf010971c,0xc(%esp)
f0102429:	f0 
f010242a:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102431:	f0 
f0102432:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f0102439:	00 
f010243a:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102441:	e8 fa db ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102446:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010244d:	00 
f010244e:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102455:	00 
f0102456:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010245a:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f010245f:	89 04 24             	mov    %eax,(%esp)
f0102462:	e8 5b f1 ff ff       	call   f01015c2 <page_insert>
f0102467:	85 c0                	test   %eax,%eax
f0102469:	78 24                	js     f010248f <mem_init+0xdec>
f010246b:	c7 44 24 0c 54 97 10 	movl   $0xf0109754,0xc(%esp)
f0102472:	f0 
f0102473:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f010247a:	f0 
f010247b:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0102482:	00 
f0102483:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f010248a:	e8 b1 db ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010248f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102496:	00 
f0102497:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010249e:	00 
f010249f:	89 74 24 04          	mov    %esi,0x4(%esp)
f01024a3:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f01024a8:	89 04 24             	mov    %eax,(%esp)
f01024ab:	e8 12 f1 ff ff       	call   f01015c2 <page_insert>
f01024b0:	85 c0                	test   %eax,%eax
f01024b2:	74 24                	je     f01024d8 <mem_init+0xe35>
f01024b4:	c7 44 24 0c 8c 97 10 	movl   $0xf010978c,0xc(%esp)
f01024bb:	f0 
f01024bc:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01024c3:	f0 
f01024c4:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f01024cb:	00 
f01024cc:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01024d3:	e8 68 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024d8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01024df:	00 
f01024e0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01024e7:	00 
f01024e8:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f01024ed:	89 04 24             	mov    %eax,(%esp)
f01024f0:	e8 94 ee ff ff       	call   f0101389 <pgdir_walk>
f01024f5:	f6 00 04             	testb  $0x4,(%eax)
f01024f8:	74 24                	je     f010251e <mem_init+0xe7b>
f01024fa:	c7 44 24 0c 1c 97 10 	movl   $0xf010971c,0xc(%esp)
f0102501:	f0 
f0102502:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102509:	f0 
f010250a:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0102511:	00 
f0102512:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102519:	e8 22 db ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010251e:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0102523:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102526:	ba 00 00 00 00       	mov    $0x0,%edx
f010252b:	e8 82 e8 ff ff       	call   f0100db2 <check_va2pa>
f0102530:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102533:	89 f0                	mov    %esi,%eax
f0102535:	2b 05 90 8e 35 f0    	sub    0xf0358e90,%eax
f010253b:	c1 f8 03             	sar    $0x3,%eax
f010253e:	c1 e0 0c             	shl    $0xc,%eax
f0102541:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102544:	74 24                	je     f010256a <mem_init+0xec7>
f0102546:	c7 44 24 0c c8 97 10 	movl   $0xf01097c8,0xc(%esp)
f010254d:	f0 
f010254e:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102555:	f0 
f0102556:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f010255d:	00 
f010255e:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102565:	e8 d6 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010256a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010256f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102572:	e8 3b e8 ff ff       	call   f0100db2 <check_va2pa>
f0102577:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010257a:	74 24                	je     f01025a0 <mem_init+0xefd>
f010257c:	c7 44 24 0c f4 97 10 	movl   $0xf01097f4,0xc(%esp)
f0102583:	f0 
f0102584:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f010258b:	f0 
f010258c:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0102593:	00 
f0102594:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f010259b:	e8 a0 da ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01025a0:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f01025a5:	74 24                	je     f01025cb <mem_init+0xf28>
f01025a7:	c7 44 24 0c a9 9e 10 	movl   $0xf0109ea9,0xc(%esp)
f01025ae:	f0 
f01025af:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01025b6:	f0 
f01025b7:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f01025be:	00 
f01025bf:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01025c6:	e8 75 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025cb:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01025d0:	74 24                	je     f01025f6 <mem_init+0xf53>
f01025d2:	c7 44 24 0c ba 9e 10 	movl   $0xf0109eba,0xc(%esp)
f01025d9:	f0 
f01025da:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01025e1:	f0 
f01025e2:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f01025e9:	00 
f01025ea:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01025f1:	e8 4a da ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01025f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01025fd:	e8 87 ec ff ff       	call   f0101289 <page_alloc>
f0102602:	85 c0                	test   %eax,%eax
f0102604:	74 04                	je     f010260a <mem_init+0xf67>
f0102606:	39 c3                	cmp    %eax,%ebx
f0102608:	74 24                	je     f010262e <mem_init+0xf8b>
f010260a:	c7 44 24 0c 24 98 10 	movl   $0xf0109824,0xc(%esp)
f0102611:	f0 
f0102612:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102619:	f0 
f010261a:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f0102621:	00 
f0102622:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102629:	e8 12 da ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010262e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102635:	00 
f0102636:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f010263b:	89 04 24             	mov    %eax,(%esp)
f010263e:	e8 2e ef ff ff       	call   f0101571 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102643:	8b 15 8c 8e 35 f0    	mov    0xf0358e8c,%edx
f0102649:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010264c:	ba 00 00 00 00       	mov    $0x0,%edx
f0102651:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102654:	e8 59 e7 ff ff       	call   f0100db2 <check_va2pa>
f0102659:	83 f8 ff             	cmp    $0xffffffff,%eax
f010265c:	74 24                	je     f0102682 <mem_init+0xfdf>
f010265e:	c7 44 24 0c 48 98 10 	movl   $0xf0109848,0xc(%esp)
f0102665:	f0 
f0102666:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f010266d:	f0 
f010266e:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f0102675:	00 
f0102676:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f010267d:	e8 be d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102682:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102687:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010268a:	e8 23 e7 ff ff       	call   f0100db2 <check_va2pa>
f010268f:	89 f2                	mov    %esi,%edx
f0102691:	2b 15 90 8e 35 f0    	sub    0xf0358e90,%edx
f0102697:	c1 fa 03             	sar    $0x3,%edx
f010269a:	c1 e2 0c             	shl    $0xc,%edx
f010269d:	39 d0                	cmp    %edx,%eax
f010269f:	74 24                	je     f01026c5 <mem_init+0x1022>
f01026a1:	c7 44 24 0c f4 97 10 	movl   $0xf01097f4,0xc(%esp)
f01026a8:	f0 
f01026a9:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01026b0:	f0 
f01026b1:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f01026b8:	00 
f01026b9:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01026c0:	e8 7b d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01026c5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01026ca:	74 24                	je     f01026f0 <mem_init+0x104d>
f01026cc:	c7 44 24 0c 60 9e 10 	movl   $0xf0109e60,0xc(%esp)
f01026d3:	f0 
f01026d4:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01026db:	f0 
f01026dc:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f01026e3:	00 
f01026e4:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01026eb:	e8 50 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01026f0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01026f5:	74 24                	je     f010271b <mem_init+0x1078>
f01026f7:	c7 44 24 0c ba 9e 10 	movl   $0xf0109eba,0xc(%esp)
f01026fe:	f0 
f01026ff:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102706:	f0 
f0102707:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f010270e:	00 
f010270f:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102716:	e8 25 d9 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010271b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102722:	00 
f0102723:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010272a:	00 
f010272b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010272f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102732:	89 0c 24             	mov    %ecx,(%esp)
f0102735:	e8 88 ee ff ff       	call   f01015c2 <page_insert>
f010273a:	85 c0                	test   %eax,%eax
f010273c:	74 24                	je     f0102762 <mem_init+0x10bf>
f010273e:	c7 44 24 0c 6c 98 10 	movl   $0xf010986c,0xc(%esp)
f0102745:	f0 
f0102746:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f010274d:	f0 
f010274e:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f0102755:	00 
f0102756:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f010275d:	e8 de d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102762:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102767:	75 24                	jne    f010278d <mem_init+0x10ea>
f0102769:	c7 44 24 0c cb 9e 10 	movl   $0xf0109ecb,0xc(%esp)
f0102770:	f0 
f0102771:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102778:	f0 
f0102779:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f0102780:	00 
f0102781:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102788:	e8 b3 d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f010278d:	83 3e 00             	cmpl   $0x0,(%esi)
f0102790:	74 24                	je     f01027b6 <mem_init+0x1113>
f0102792:	c7 44 24 0c d7 9e 10 	movl   $0xf0109ed7,0xc(%esp)
f0102799:	f0 
f010279a:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01027a1:	f0 
f01027a2:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f01027a9:	00 
f01027aa:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01027b1:	e8 8a d8 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01027b6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01027bd:	00 
f01027be:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f01027c3:	89 04 24             	mov    %eax,(%esp)
f01027c6:	e8 a6 ed ff ff       	call   f0101571 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01027cb:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f01027d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01027d3:	ba 00 00 00 00       	mov    $0x0,%edx
f01027d8:	e8 d5 e5 ff ff       	call   f0100db2 <check_va2pa>
f01027dd:	83 f8 ff             	cmp    $0xffffffff,%eax
f01027e0:	74 24                	je     f0102806 <mem_init+0x1163>
f01027e2:	c7 44 24 0c 48 98 10 	movl   $0xf0109848,0xc(%esp)
f01027e9:	f0 
f01027ea:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01027f1:	f0 
f01027f2:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f01027f9:	00 
f01027fa:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102801:	e8 3a d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102806:	ba 00 10 00 00       	mov    $0x1000,%edx
f010280b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010280e:	e8 9f e5 ff ff       	call   f0100db2 <check_va2pa>
f0102813:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102816:	74 24                	je     f010283c <mem_init+0x1199>
f0102818:	c7 44 24 0c a4 98 10 	movl   $0xf01098a4,0xc(%esp)
f010281f:	f0 
f0102820:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102827:	f0 
f0102828:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f010282f:	00 
f0102830:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102837:	e8 04 d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010283c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102841:	74 24                	je     f0102867 <mem_init+0x11c4>
f0102843:	c7 44 24 0c ec 9e 10 	movl   $0xf0109eec,0xc(%esp)
f010284a:	f0 
f010284b:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102852:	f0 
f0102853:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f010285a:	00 
f010285b:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102862:	e8 d9 d7 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102867:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010286c:	74 24                	je     f0102892 <mem_init+0x11ef>
f010286e:	c7 44 24 0c ba 9e 10 	movl   $0xf0109eba,0xc(%esp)
f0102875:	f0 
f0102876:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f010287d:	f0 
f010287e:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0102885:	00 
f0102886:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f010288d:	e8 ae d7 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102892:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102899:	e8 eb e9 ff ff       	call   f0101289 <page_alloc>
f010289e:	85 c0                	test   %eax,%eax
f01028a0:	74 04                	je     f01028a6 <mem_init+0x1203>
f01028a2:	39 c6                	cmp    %eax,%esi
f01028a4:	74 24                	je     f01028ca <mem_init+0x1227>
f01028a6:	c7 44 24 0c cc 98 10 	movl   $0xf01098cc,0xc(%esp)
f01028ad:	f0 
f01028ae:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01028b5:	f0 
f01028b6:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f01028bd:	00 
f01028be:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01028c5:	e8 76 d7 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01028ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028d1:	e8 b3 e9 ff ff       	call   f0101289 <page_alloc>
f01028d6:	85 c0                	test   %eax,%eax
f01028d8:	74 24                	je     f01028fe <mem_init+0x125b>
f01028da:	c7 44 24 0c 0e 9e 10 	movl   $0xf0109e0e,0xc(%esp)
f01028e1:	f0 
f01028e2:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01028e9:	f0 
f01028ea:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f01028f1:	00 
f01028f2:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01028f9:	e8 42 d7 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01028fe:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0102903:	8b 08                	mov    (%eax),%ecx
f0102905:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010290b:	89 fa                	mov    %edi,%edx
f010290d:	2b 15 90 8e 35 f0    	sub    0xf0358e90,%edx
f0102913:	c1 fa 03             	sar    $0x3,%edx
f0102916:	c1 e2 0c             	shl    $0xc,%edx
f0102919:	39 d1                	cmp    %edx,%ecx
f010291b:	74 24                	je     f0102941 <mem_init+0x129e>
f010291d:	c7 44 24 0c 70 95 10 	movl   $0xf0109570,0xc(%esp)
f0102924:	f0 
f0102925:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f010292c:	f0 
f010292d:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0102934:	00 
f0102935:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f010293c:	e8 ff d6 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102941:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102947:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010294c:	74 24                	je     f0102972 <mem_init+0x12cf>
f010294e:	c7 44 24 0c 71 9e 10 	movl   $0xf0109e71,0xc(%esp)
f0102955:	f0 
f0102956:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f010295d:	f0 
f010295e:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0102965:	00 
f0102966:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f010296d:	e8 ce d6 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102972:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102978:	89 3c 24             	mov    %edi,(%esp)
f010297b:	e8 8d e9 ff ff       	call   f010130d <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102980:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102987:	00 
f0102988:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f010298f:	00 
f0102990:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0102995:	89 04 24             	mov    %eax,(%esp)
f0102998:	e8 ec e9 ff ff       	call   f0101389 <pgdir_walk>
f010299d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01029a0:	8b 0d 8c 8e 35 f0    	mov    0xf0358e8c,%ecx
f01029a6:	8b 51 04             	mov    0x4(%ecx),%edx
f01029a9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01029af:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029b2:	8b 15 88 8e 35 f0    	mov    0xf0358e88,%edx
f01029b8:	89 55 c8             	mov    %edx,-0x38(%ebp)
f01029bb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01029be:	c1 ea 0c             	shr    $0xc,%edx
f01029c1:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01029c4:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01029c7:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f01029ca:	72 23                	jb     f01029ef <mem_init+0x134c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029cc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01029cf:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01029d3:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f01029da:	f0 
f01029db:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f01029e2:	00 
f01029e3:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01029ea:	e8 51 d6 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01029ef:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01029f2:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01029f8:	39 d0                	cmp    %edx,%eax
f01029fa:	74 24                	je     f0102a20 <mem_init+0x137d>
f01029fc:	c7 44 24 0c fd 9e 10 	movl   $0xf0109efd,0xc(%esp)
f0102a03:	f0 
f0102a04:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102a0b:	f0 
f0102a0c:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0102a13:	00 
f0102a14:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102a1b:	e8 20 d6 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102a20:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102a27:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a2d:	89 f8                	mov    %edi,%eax
f0102a2f:	2b 05 90 8e 35 f0    	sub    0xf0358e90,%eax
f0102a35:	c1 f8 03             	sar    $0x3,%eax
f0102a38:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a3b:	89 c1                	mov    %eax,%ecx
f0102a3d:	c1 e9 0c             	shr    $0xc,%ecx
f0102a40:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0102a43:	77 20                	ja     f0102a65 <mem_init+0x13c2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a45:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a49:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f0102a50:	f0 
f0102a51:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102a58:	00 
f0102a59:	c7 04 24 81 9c 10 f0 	movl   $0xf0109c81,(%esp)
f0102a60:	e8 db d5 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102a65:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102a6c:	00 
f0102a6d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102a74:	00 
	return (void *)(pa + KERNBASE);
f0102a75:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a7a:	89 04 24             	mov    %eax,(%esp)
f0102a7d:	e8 68 53 00 00       	call   f0107dea <memset>
	page_free(pp0);
f0102a82:	89 3c 24             	mov    %edi,(%esp)
f0102a85:	e8 83 e8 ff ff       	call   f010130d <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102a8a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102a91:	00 
f0102a92:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102a99:	00 
f0102a9a:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0102a9f:	89 04 24             	mov    %eax,(%esp)
f0102aa2:	e8 e2 e8 ff ff       	call   f0101389 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102aa7:	89 fa                	mov    %edi,%edx
f0102aa9:	2b 15 90 8e 35 f0    	sub    0xf0358e90,%edx
f0102aaf:	c1 fa 03             	sar    $0x3,%edx
f0102ab2:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ab5:	89 d0                	mov    %edx,%eax
f0102ab7:	c1 e8 0c             	shr    $0xc,%eax
f0102aba:	3b 05 88 8e 35 f0    	cmp    0xf0358e88,%eax
f0102ac0:	72 20                	jb     f0102ae2 <mem_init+0x143f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ac2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102ac6:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f0102acd:	f0 
f0102ace:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102ad5:	00 
f0102ad6:	c7 04 24 81 9c 10 f0 	movl   $0xf0109c81,(%esp)
f0102add:	e8 5e d5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102ae2:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102ae8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102aeb:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102af1:	f6 00 01             	testb  $0x1,(%eax)
f0102af4:	74 24                	je     f0102b1a <mem_init+0x1477>
f0102af6:	c7 44 24 0c 15 9f 10 	movl   $0xf0109f15,0xc(%esp)
f0102afd:	f0 
f0102afe:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102b05:	f0 
f0102b06:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0102b0d:	00 
f0102b0e:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102b15:	e8 26 d5 ff ff       	call   f0100040 <_panic>
f0102b1a:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102b1d:	39 d0                	cmp    %edx,%eax
f0102b1f:	75 d0                	jne    f0102af1 <mem_init+0x144e>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102b21:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0102b26:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102b2c:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102b32:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102b35:	89 0d 40 82 35 f0    	mov    %ecx,0xf0358240

	// free the pages we took
	page_free(pp0);
f0102b3b:	89 3c 24             	mov    %edi,(%esp)
f0102b3e:	e8 ca e7 ff ff       	call   f010130d <page_free>
	page_free(pp1);
f0102b43:	89 34 24             	mov    %esi,(%esp)
f0102b46:	e8 c2 e7 ff ff       	call   f010130d <page_free>
	page_free(pp2);
f0102b4b:	89 1c 24             	mov    %ebx,(%esp)
f0102b4e:	e8 ba e7 ff ff       	call   f010130d <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102b53:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102b5a:	00 
f0102b5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b62:	e8 cd ea ff ff       	call   f0101634 <mmio_map_region>
f0102b67:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102b69:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102b70:	00 
f0102b71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b78:	e8 b7 ea ff ff       	call   f0101634 <mmio_map_region>
f0102b7d:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102b7f:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102b85:	76 0d                	jbe    f0102b94 <mem_init+0x14f1>
f0102b87:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102b8d:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102b92:	76 24                	jbe    f0102bb8 <mem_init+0x1515>
f0102b94:	c7 44 24 0c f0 98 10 	movl   $0xf01098f0,0xc(%esp)
f0102b9b:	f0 
f0102b9c:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102ba3:	f0 
f0102ba4:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f0102bab:	00 
f0102bac:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102bb3:	e8 88 d4 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102bb8:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102bbe:	76 0e                	jbe    f0102bce <mem_init+0x152b>
f0102bc0:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102bc6:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102bcc:	76 24                	jbe    f0102bf2 <mem_init+0x154f>
f0102bce:	c7 44 24 0c 18 99 10 	movl   $0xf0109918,0xc(%esp)
f0102bd5:	f0 
f0102bd6:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102bdd:	f0 
f0102bde:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f0102be5:	00 
f0102be6:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102bed:	e8 4e d4 ff ff       	call   f0100040 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102bf2:	89 da                	mov    %ebx,%edx
f0102bf4:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102bf6:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102bfc:	74 24                	je     f0102c22 <mem_init+0x157f>
f0102bfe:	c7 44 24 0c 40 99 10 	movl   $0xf0109940,0xc(%esp)
f0102c05:	f0 
f0102c06:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102c0d:	f0 
f0102c0e:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f0102c15:	00 
f0102c16:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102c1d:	e8 1e d4 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102c22:	39 c6                	cmp    %eax,%esi
f0102c24:	73 24                	jae    f0102c4a <mem_init+0x15a7>
f0102c26:	c7 44 24 0c 2c 9f 10 	movl   $0xf0109f2c,0xc(%esp)
f0102c2d:	f0 
f0102c2e:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102c35:	f0 
f0102c36:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0102c3d:	00 
f0102c3e:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102c45:	e8 f6 d3 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102c4a:	8b 3d 8c 8e 35 f0    	mov    0xf0358e8c,%edi
f0102c50:	89 da                	mov    %ebx,%edx
f0102c52:	89 f8                	mov    %edi,%eax
f0102c54:	e8 59 e1 ff ff       	call   f0100db2 <check_va2pa>
f0102c59:	85 c0                	test   %eax,%eax
f0102c5b:	74 24                	je     f0102c81 <mem_init+0x15de>
f0102c5d:	c7 44 24 0c 68 99 10 	movl   $0xf0109968,0xc(%esp)
f0102c64:	f0 
f0102c65:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102c6c:	f0 
f0102c6d:	c7 44 24 04 0d 04 00 	movl   $0x40d,0x4(%esp)
f0102c74:	00 
f0102c75:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102c7c:	e8 bf d3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102c81:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102c87:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102c8a:	89 c2                	mov    %eax,%edx
f0102c8c:	89 f8                	mov    %edi,%eax
f0102c8e:	e8 1f e1 ff ff       	call   f0100db2 <check_va2pa>
f0102c93:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102c98:	74 24                	je     f0102cbe <mem_init+0x161b>
f0102c9a:	c7 44 24 0c 8c 99 10 	movl   $0xf010998c,0xc(%esp)
f0102ca1:	f0 
f0102ca2:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102ca9:	f0 
f0102caa:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f0102cb1:	00 
f0102cb2:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102cb9:	e8 82 d3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102cbe:	89 f2                	mov    %esi,%edx
f0102cc0:	89 f8                	mov    %edi,%eax
f0102cc2:	e8 eb e0 ff ff       	call   f0100db2 <check_va2pa>
f0102cc7:	85 c0                	test   %eax,%eax
f0102cc9:	74 24                	je     f0102cef <mem_init+0x164c>
f0102ccb:	c7 44 24 0c bc 99 10 	movl   $0xf01099bc,0xc(%esp)
f0102cd2:	f0 
f0102cd3:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102cda:	f0 
f0102cdb:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f0102ce2:	00 
f0102ce3:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102cea:	e8 51 d3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102cef:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102cf5:	89 f8                	mov    %edi,%eax
f0102cf7:	e8 b6 e0 ff ff       	call   f0100db2 <check_va2pa>
f0102cfc:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102cff:	74 24                	je     f0102d25 <mem_init+0x1682>
f0102d01:	c7 44 24 0c e0 99 10 	movl   $0xf01099e0,0xc(%esp)
f0102d08:	f0 
f0102d09:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102d10:	f0 
f0102d11:	c7 44 24 04 10 04 00 	movl   $0x410,0x4(%esp)
f0102d18:	00 
f0102d19:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102d20:	e8 1b d3 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102d25:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102d2c:	00 
f0102d2d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102d31:	89 3c 24             	mov    %edi,(%esp)
f0102d34:	e8 50 e6 ff ff       	call   f0101389 <pgdir_walk>
f0102d39:	f6 00 1a             	testb  $0x1a,(%eax)
f0102d3c:	75 24                	jne    f0102d62 <mem_init+0x16bf>
f0102d3e:	c7 44 24 0c 0c 9a 10 	movl   $0xf0109a0c,0xc(%esp)
f0102d45:	f0 
f0102d46:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102d4d:	f0 
f0102d4e:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f0102d55:	00 
f0102d56:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102d5d:	e8 de d2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102d62:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102d69:	00 
f0102d6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102d6e:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0102d73:	89 04 24             	mov    %eax,(%esp)
f0102d76:	e8 0e e6 ff ff       	call   f0101389 <pgdir_walk>
f0102d7b:	f6 00 04             	testb  $0x4,(%eax)
f0102d7e:	74 24                	je     f0102da4 <mem_init+0x1701>
f0102d80:	c7 44 24 0c 50 9a 10 	movl   $0xf0109a50,0xc(%esp)
f0102d87:	f0 
f0102d88:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0102d8f:	f0 
f0102d90:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f0102d97:	00 
f0102d98:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102d9f:	e8 9c d2 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102da4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102dab:	00 
f0102dac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102db0:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0102db5:	89 04 24             	mov    %eax,(%esp)
f0102db8:	e8 cc e5 ff ff       	call   f0101389 <pgdir_walk>
f0102dbd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102dc3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102dca:	00 
f0102dcb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102dce:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102dd2:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0102dd7:	89 04 24             	mov    %eax,(%esp)
f0102dda:	e8 aa e5 ff ff       	call   f0101389 <pgdir_walk>
f0102ddf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102de5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102dec:	00 
f0102ded:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102df1:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0102df6:	89 04 24             	mov    %eax,(%esp)
f0102df9:	e8 8b e5 ff ff       	call   f0101389 <pgdir_walk>
f0102dfe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102e04:	c7 04 24 3e 9f 10 f0 	movl   $0xf0109f3e,(%esp)
f0102e0b:	e8 7a 14 00 00       	call   f010428a <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), PADDR(pages), PTE_U);
f0102e10:	a1 90 8e 35 f0       	mov    0xf0358e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e15:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e1a:	77 20                	ja     f0102e3c <mem_init+0x1799>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e20:	c7 44 24 08 04 8b 10 	movl   $0xf0108b04,0x8(%esp)
f0102e27:	f0 
f0102e28:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
f0102e2f:	00 
f0102e30:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102e37:	e8 04 d2 ff ff       	call   f0100040 <_panic>
f0102e3c:	8b 15 88 8e 35 f0    	mov    0xf0358e88,%edx
f0102e42:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102e49:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102e4f:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102e56:	00 
	return (physaddr_t)kva - KERNBASE;
f0102e57:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e5c:	89 04 24             	mov    %eax,(%esp)
f0102e5f:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102e64:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0102e69:	e8 ba e5 ff ff       	call   f0101428 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f0102e6e:	a1 48 82 35 f0       	mov    0xf0358248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e73:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e78:	77 20                	ja     f0102e9a <mem_init+0x17f7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e7a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e7e:	c7 44 24 08 04 8b 10 	movl   $0xf0108b04,0x8(%esp)
f0102e85:	f0 
f0102e86:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
f0102e8d:	00 
f0102e8e:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102e95:	e8 a6 d1 ff ff       	call   f0100040 <_panic>
f0102e9a:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102ea1:	00 
	return (physaddr_t)kva - KERNBASE;
f0102ea2:	05 00 00 00 10       	add    $0x10000000,%eax
f0102ea7:	89 04 24             	mov    %eax,(%esp)
f0102eaa:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102eaf:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102eb4:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0102eb9:	e8 6a e5 ff ff       	call   f0101428 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ebe:	b8 00 40 12 f0       	mov    $0xf0124000,%eax
f0102ec3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ec8:	77 20                	ja     f0102eea <mem_init+0x1847>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102eca:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102ece:	c7 44 24 08 04 8b 10 	movl   $0xf0108b04,0x8(%esp)
f0102ed5:	f0 
f0102ed6:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
f0102edd:	00 
f0102ede:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102ee5:	e8 56 d1 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102eea:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102ef1:	00 
f0102ef2:	c7 04 24 00 40 12 00 	movl   $0x124000,(%esp)
f0102ef9:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102efe:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102f03:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0102f08:	e8 1b e5 ff ff       	call   f0101428 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, (unsigned)0xffffffff-KERNBASE+1, 0, PTE_W);
f0102f0d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102f14:	00 
f0102f15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102f1c:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102f21:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102f26:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0102f2b:	e8 f8 e4 ff ff       	call   f0101428 <boot_map_region>
f0102f30:	c7 45 cc 00 a0 35 f0 	movl   $0xf035a000,-0x34(%ebp)
f0102f37:	bb 00 a0 35 f0       	mov    $0xf035a000,%ebx
f0102f3c:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f41:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102f47:	77 20                	ja     f0102f69 <mem_init+0x18c6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f49:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102f4d:	c7 44 24 08 04 8b 10 	movl   $0xf0108b04,0x8(%esp)
f0102f54:	f0 
f0102f55:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
f0102f5c:	00 
f0102f5d:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102f64:	e8 d7 d0 ff ff       	call   f0100040 <_panic>
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; i++) {
		boot_map_region(kern_pgdir, KSTACKTOP - i * (KSTKSIZE + KSTKGAP) - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f0102f69:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102f70:	00 
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102f71:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; i++) {
		boot_map_region(kern_pgdir, KSTACKTOP - i * (KSTKSIZE + KSTKGAP) - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f0102f77:	89 04 24             	mov    %eax,(%esp)
f0102f7a:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102f7f:	89 f2                	mov    %esi,%edx
f0102f81:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0102f86:	e8 9d e4 ff ff       	call   f0101428 <boot_map_region>
f0102f8b:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102f91:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; i++) {
f0102f97:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0102f9d:	75 a2                	jne    f0102f41 <mem_init+0x189e>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102f9f:	8b 35 8c 8e 35 f0    	mov    0xf0358e8c,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102fa5:	8b 0d 88 8e 35 f0    	mov    0xf0358e88,%ecx
f0102fab:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102fae:	8d 3c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%edi
f0102fb5:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102fbb:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102fc0:	eb 70                	jmp    f0103032 <mem_init+0x198f>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102fc2:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102fc8:	89 f0                	mov    %esi,%eax
f0102fca:	e8 e3 dd ff ff       	call   f0100db2 <check_va2pa>
f0102fcf:	8b 15 90 8e 35 f0    	mov    0xf0358e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102fd5:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102fdb:	77 20                	ja     f0102ffd <mem_init+0x195a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fdd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102fe1:	c7 44 24 08 04 8b 10 	movl   $0xf0108b04,0x8(%esp)
f0102fe8:	f0 
f0102fe9:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f0102ff0:	00 
f0102ff1:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0102ff8:	e8 43 d0 ff ff       	call   f0100040 <_panic>
f0102ffd:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f0103004:	39 d0                	cmp    %edx,%eax
f0103006:	74 24                	je     f010302c <mem_init+0x1989>
f0103008:	c7 44 24 0c 84 9a 10 	movl   $0xf0109a84,0xc(%esp)
f010300f:	f0 
f0103010:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0103017:	f0 
f0103018:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f010301f:	00 
f0103020:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0103027:	e8 14 d0 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010302c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103032:	39 df                	cmp    %ebx,%edi
f0103034:	77 8c                	ja     f0102fc2 <mem_init+0x191f>
f0103036:	bb 00 00 00 00       	mov    $0x0,%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010303b:	8d 93 00 00 c0 ee    	lea    -0x11400000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0103041:	89 f0                	mov    %esi,%eax
f0103043:	e8 6a dd ff ff       	call   f0100db2 <check_va2pa>
f0103048:	8b 15 48 82 35 f0    	mov    0xf0358248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010304e:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103054:	77 20                	ja     f0103076 <mem_init+0x19d3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103056:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010305a:	c7 44 24 08 04 8b 10 	movl   $0xf0108b04,0x8(%esp)
f0103061:	f0 
f0103062:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f0103069:	00 
f010306a:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0103071:	e8 ca cf ff ff       	call   f0100040 <_panic>
f0103076:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f010307d:	39 d0                	cmp    %edx,%eax
f010307f:	74 24                	je     f01030a5 <mem_init+0x1a02>
f0103081:	c7 44 24 0c b8 9a 10 	movl   $0xf0109ab8,0xc(%esp)
f0103088:	f0 
f0103089:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0103090:	f0 
f0103091:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f0103098:	00 
f0103099:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01030a0:	e8 9b cf ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01030a5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01030ab:	81 fb 00 c0 03 00    	cmp    $0x3c000,%ebx
f01030b1:	75 88                	jne    f010303b <mem_init+0x1998>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01030b3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01030b6:	c1 e7 0c             	shl    $0xc,%edi
f01030b9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01030be:	eb 3b                	jmp    f01030fb <mem_init+0x1a58>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01030c0:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01030c6:	89 f0                	mov    %esi,%eax
f01030c8:	e8 e5 dc ff ff       	call   f0100db2 <check_va2pa>
f01030cd:	39 c3                	cmp    %eax,%ebx
f01030cf:	74 24                	je     f01030f5 <mem_init+0x1a52>
f01030d1:	c7 44 24 0c ec 9a 10 	movl   $0xf0109aec,0xc(%esp)
f01030d8:	f0 
f01030d9:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01030e0:	f0 
f01030e1:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f01030e8:	00 
f01030e9:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01030f0:	e8 4b cf ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01030f5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01030fb:	39 fb                	cmp    %edi,%ebx
f01030fd:	72 c1                	jb     f01030c0 <mem_init+0x1a1d>
f01030ff:	bf 00 00 ff ef       	mov    $0xefff0000,%edi
f0103104:	89 75 d4             	mov    %esi,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103107:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010310a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010310d:	8d 9f 00 80 00 00    	lea    0x8000(%edi),%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103113:	89 c6                	mov    %eax,%esi
f0103115:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f010311b:	8d 97 00 00 01 00    	lea    0x10000(%edi),%edx
f0103121:	89 55 d0             	mov    %edx,-0x30(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103124:	89 da                	mov    %ebx,%edx
f0103126:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103129:	e8 84 dc ff ff       	call   f0100db2 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010312e:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0103135:	77 23                	ja     f010315a <mem_init+0x1ab7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103137:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010313a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010313e:	c7 44 24 08 04 8b 10 	movl   $0xf0108b04,0x8(%esp)
f0103145:	f0 
f0103146:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f010314d:	00 
f010314e:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0103155:	e8 e6 ce ff ff       	call   f0100040 <_panic>
f010315a:	39 f0                	cmp    %esi,%eax
f010315c:	74 24                	je     f0103182 <mem_init+0x1adf>
f010315e:	c7 44 24 0c 14 9b 10 	movl   $0xf0109b14,0xc(%esp)
f0103165:	f0 
f0103166:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f010316d:	f0 
f010316e:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f0103175:	00 
f0103176:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f010317d:	e8 be ce ff ff       	call   f0100040 <_panic>
f0103182:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103188:	81 c6 00 10 00 00    	add    $0x1000,%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010318e:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0103191:	0f 85 55 05 00 00    	jne    f01036ec <mem_init+0x2049>
f0103197:	bb 00 00 00 00       	mov    $0x0,%ebx
f010319c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f010319f:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f01031a2:	89 f0                	mov    %esi,%eax
f01031a4:	e8 09 dc ff ff       	call   f0100db2 <check_va2pa>
f01031a9:	83 f8 ff             	cmp    $0xffffffff,%eax
f01031ac:	74 24                	je     f01031d2 <mem_init+0x1b2f>
f01031ae:	c7 44 24 0c 5c 9b 10 	movl   $0xf0109b5c,0xc(%esp)
f01031b5:	f0 
f01031b6:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01031bd:	f0 
f01031be:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f01031c5:	00 
f01031c6:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01031cd:	e8 6e ce ff ff       	call   f0100040 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01031d2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01031d8:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f01031de:	75 bf                	jne    f010319f <mem_init+0x1afc>
f01031e0:	81 ef 00 00 01 00    	sub    $0x10000,%edi
f01031e6:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01031ed:	81 ff 00 00 f7 ef    	cmp    $0xeff70000,%edi
f01031f3:	0f 85 0e ff ff ff    	jne    f0103107 <mem_init+0x1a64>
f01031f9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01031fc:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0103201:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0103207:	83 fa 04             	cmp    $0x4,%edx
f010320a:	77 2e                	ja     f010323a <mem_init+0x1b97>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010320c:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0103210:	0f 85 aa 00 00 00    	jne    f01032c0 <mem_init+0x1c1d>
f0103216:	c7 44 24 0c 57 9f 10 	movl   $0xf0109f57,0xc(%esp)
f010321d:	f0 
f010321e:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0103225:	f0 
f0103226:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f010322d:	00 
f010322e:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0103235:	e8 06 ce ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010323a:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010323f:	76 55                	jbe    f0103296 <mem_init+0x1bf3>
				assert(pgdir[i] & PTE_P);
f0103241:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0103244:	f6 c2 01             	test   $0x1,%dl
f0103247:	75 24                	jne    f010326d <mem_init+0x1bca>
f0103249:	c7 44 24 0c 57 9f 10 	movl   $0xf0109f57,0xc(%esp)
f0103250:	f0 
f0103251:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0103258:	f0 
f0103259:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0103260:	00 
f0103261:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0103268:	e8 d3 cd ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f010326d:	f6 c2 02             	test   $0x2,%dl
f0103270:	75 4e                	jne    f01032c0 <mem_init+0x1c1d>
f0103272:	c7 44 24 0c 68 9f 10 	movl   $0xf0109f68,0xc(%esp)
f0103279:	f0 
f010327a:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0103281:	f0 
f0103282:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f0103289:	00 
f010328a:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0103291:	e8 aa cd ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0103296:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f010329a:	74 24                	je     f01032c0 <mem_init+0x1c1d>
f010329c:	c7 44 24 0c 79 9f 10 	movl   $0xf0109f79,0xc(%esp)
f01032a3:	f0 
f01032a4:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01032ab:	f0 
f01032ac:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f01032b3:	00 
f01032b4:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01032bb:	e8 80 cd ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01032c0:	40                   	inc    %eax
f01032c1:	3d 00 04 00 00       	cmp    $0x400,%eax
f01032c6:	0f 85 35 ff ff ff    	jne    f0103201 <mem_init+0x1b5e>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01032cc:	c7 04 24 80 9b 10 f0 	movl   $0xf0109b80,(%esp)
f01032d3:	e8 b2 0f 00 00       	call   f010428a <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01032d8:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032dd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032e2:	77 20                	ja     f0103304 <mem_init+0x1c61>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032e8:	c7 44 24 08 04 8b 10 	movl   $0xf0108b04,0x8(%esp)
f01032ef:	f0 
f01032f0:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
f01032f7:	00 
f01032f8:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01032ff:	e8 3c cd ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103304:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103309:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010330c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103311:	e8 32 db ff ff       	call   f0100e48 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0103316:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0103319:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010331e:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103321:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103324:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010332b:	e8 59 df ff ff       	call   f0101289 <page_alloc>
f0103330:	89 c6                	mov    %eax,%esi
f0103332:	85 c0                	test   %eax,%eax
f0103334:	75 24                	jne    f010335a <mem_init+0x1cb7>
f0103336:	c7 44 24 0c 63 9d 10 	movl   $0xf0109d63,0xc(%esp)
f010333d:	f0 
f010333e:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0103345:	f0 
f0103346:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f010334d:	00 
f010334e:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0103355:	e8 e6 cc ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010335a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103361:	e8 23 df ff ff       	call   f0101289 <page_alloc>
f0103366:	89 c7                	mov    %eax,%edi
f0103368:	85 c0                	test   %eax,%eax
f010336a:	75 24                	jne    f0103390 <mem_init+0x1ced>
f010336c:	c7 44 24 0c 79 9d 10 	movl   $0xf0109d79,0xc(%esp)
f0103373:	f0 
f0103374:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f010337b:	f0 
f010337c:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f0103383:	00 
f0103384:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f010338b:	e8 b0 cc ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0103390:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103397:	e8 ed de ff ff       	call   f0101289 <page_alloc>
f010339c:	89 c3                	mov    %eax,%ebx
f010339e:	85 c0                	test   %eax,%eax
f01033a0:	75 24                	jne    f01033c6 <mem_init+0x1d23>
f01033a2:	c7 44 24 0c 8f 9d 10 	movl   $0xf0109d8f,0xc(%esp)
f01033a9:	f0 
f01033aa:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01033b1:	f0 
f01033b2:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f01033b9:	00 
f01033ba:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01033c1:	e8 7a cc ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f01033c6:	89 34 24             	mov    %esi,(%esp)
f01033c9:	e8 3f df ff ff       	call   f010130d <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01033ce:	89 f8                	mov    %edi,%eax
f01033d0:	2b 05 90 8e 35 f0    	sub    0xf0358e90,%eax
f01033d6:	c1 f8 03             	sar    $0x3,%eax
f01033d9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033dc:	89 c2                	mov    %eax,%edx
f01033de:	c1 ea 0c             	shr    $0xc,%edx
f01033e1:	3b 15 88 8e 35 f0    	cmp    0xf0358e88,%edx
f01033e7:	72 20                	jb     f0103409 <mem_init+0x1d66>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01033e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01033ed:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f01033f4:	f0 
f01033f5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01033fc:	00 
f01033fd:	c7 04 24 81 9c 10 f0 	movl   $0xf0109c81,(%esp)
f0103404:	e8 37 cc ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103409:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103410:	00 
f0103411:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103418:	00 
	return (void *)(pa + KERNBASE);
f0103419:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010341e:	89 04 24             	mov    %eax,(%esp)
f0103421:	e8 c4 49 00 00       	call   f0107dea <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103426:	89 d8                	mov    %ebx,%eax
f0103428:	2b 05 90 8e 35 f0    	sub    0xf0358e90,%eax
f010342e:	c1 f8 03             	sar    $0x3,%eax
f0103431:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103434:	89 c2                	mov    %eax,%edx
f0103436:	c1 ea 0c             	shr    $0xc,%edx
f0103439:	3b 15 88 8e 35 f0    	cmp    0xf0358e88,%edx
f010343f:	72 20                	jb     f0103461 <mem_init+0x1dbe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103441:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103445:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f010344c:	f0 
f010344d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103454:	00 
f0103455:	c7 04 24 81 9c 10 f0 	movl   $0xf0109c81,(%esp)
f010345c:	e8 df cb ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0103461:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103468:	00 
f0103469:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103470:	00 
	return (void *)(pa + KERNBASE);
f0103471:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103476:	89 04 24             	mov    %eax,(%esp)
f0103479:	e8 6c 49 00 00       	call   f0107dea <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010347e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103485:	00 
f0103486:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010348d:	00 
f010348e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103492:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0103497:	89 04 24             	mov    %eax,(%esp)
f010349a:	e8 23 e1 ff ff       	call   f01015c2 <page_insert>
	assert(pp1->pp_ref == 1);
f010349f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01034a4:	74 24                	je     f01034ca <mem_init+0x1e27>
f01034a6:	c7 44 24 0c 60 9e 10 	movl   $0xf0109e60,0xc(%esp)
f01034ad:	f0 
f01034ae:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01034b5:	f0 
f01034b6:	c7 44 24 04 2f 04 00 	movl   $0x42f,0x4(%esp)
f01034bd:	00 
f01034be:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01034c5:	e8 76 cb ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01034ca:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01034d1:	01 01 01 
f01034d4:	74 24                	je     f01034fa <mem_init+0x1e57>
f01034d6:	c7 44 24 0c a0 9b 10 	movl   $0xf0109ba0,0xc(%esp)
f01034dd:	f0 
f01034de:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01034e5:	f0 
f01034e6:	c7 44 24 04 30 04 00 	movl   $0x430,0x4(%esp)
f01034ed:	00 
f01034ee:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01034f5:	e8 46 cb ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01034fa:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103501:	00 
f0103502:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103509:	00 
f010350a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010350e:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0103513:	89 04 24             	mov    %eax,(%esp)
f0103516:	e8 a7 e0 ff ff       	call   f01015c2 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010351b:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103522:	02 02 02 
f0103525:	74 24                	je     f010354b <mem_init+0x1ea8>
f0103527:	c7 44 24 0c c4 9b 10 	movl   $0xf0109bc4,0xc(%esp)
f010352e:	f0 
f010352f:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0103536:	f0 
f0103537:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f010353e:	00 
f010353f:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0103546:	e8 f5 ca ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010354b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103550:	74 24                	je     f0103576 <mem_init+0x1ed3>
f0103552:	c7 44 24 0c 82 9e 10 	movl   $0xf0109e82,0xc(%esp)
f0103559:	f0 
f010355a:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0103561:	f0 
f0103562:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f0103569:	00 
f010356a:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0103571:	e8 ca ca ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103576:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010357b:	74 24                	je     f01035a1 <mem_init+0x1efe>
f010357d:	c7 44 24 0c ec 9e 10 	movl   $0xf0109eec,0xc(%esp)
f0103584:	f0 
f0103585:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f010358c:	f0 
f010358d:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f0103594:	00 
f0103595:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f010359c:	e8 9f ca ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01035a1:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01035a8:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01035ab:	89 d8                	mov    %ebx,%eax
f01035ad:	2b 05 90 8e 35 f0    	sub    0xf0358e90,%eax
f01035b3:	c1 f8 03             	sar    $0x3,%eax
f01035b6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01035b9:	89 c2                	mov    %eax,%edx
f01035bb:	c1 ea 0c             	shr    $0xc,%edx
f01035be:	3b 15 88 8e 35 f0    	cmp    0xf0358e88,%edx
f01035c4:	72 20                	jb     f01035e6 <mem_init+0x1f43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01035c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035ca:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f01035d1:	f0 
f01035d2:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01035d9:	00 
f01035da:	c7 04 24 81 9c 10 f0 	movl   $0xf0109c81,(%esp)
f01035e1:	e8 5a ca ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01035e6:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01035ed:	03 03 03 
f01035f0:	74 24                	je     f0103616 <mem_init+0x1f73>
f01035f2:	c7 44 24 0c e8 9b 10 	movl   $0xf0109be8,0xc(%esp)
f01035f9:	f0 
f01035fa:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0103601:	f0 
f0103602:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
f0103609:	00 
f010360a:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0103611:	e8 2a ca ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103616:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010361d:	00 
f010361e:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0103623:	89 04 24             	mov    %eax,(%esp)
f0103626:	e8 46 df ff ff       	call   f0101571 <page_remove>
	assert(pp2->pp_ref == 0);
f010362b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103630:	74 24                	je     f0103656 <mem_init+0x1fb3>
f0103632:	c7 44 24 0c ba 9e 10 	movl   $0xf0109eba,0xc(%esp)
f0103639:	f0 
f010363a:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0103641:	f0 
f0103642:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
f0103649:	00 
f010364a:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0103651:	e8 ea c9 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103656:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f010365b:	8b 08                	mov    (%eax),%ecx
f010365d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103663:	89 f2                	mov    %esi,%edx
f0103665:	2b 15 90 8e 35 f0    	sub    0xf0358e90,%edx
f010366b:	c1 fa 03             	sar    $0x3,%edx
f010366e:	c1 e2 0c             	shl    $0xc,%edx
f0103671:	39 d1                	cmp    %edx,%ecx
f0103673:	74 24                	je     f0103699 <mem_init+0x1ff6>
f0103675:	c7 44 24 0c 70 95 10 	movl   $0xf0109570,0xc(%esp)
f010367c:	f0 
f010367d:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f0103684:	f0 
f0103685:	c7 44 24 04 3b 04 00 	movl   $0x43b,0x4(%esp)
f010368c:	00 
f010368d:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f0103694:	e8 a7 c9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103699:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010369f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01036a4:	74 24                	je     f01036ca <mem_init+0x2027>
f01036a6:	c7 44 24 0c 71 9e 10 	movl   $0xf0109e71,0xc(%esp)
f01036ad:	f0 
f01036ae:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01036b5:	f0 
f01036b6:	c7 44 24 04 3d 04 00 	movl   $0x43d,0x4(%esp)
f01036bd:	00 
f01036be:	c7 04 24 75 9c 10 f0 	movl   $0xf0109c75,(%esp)
f01036c5:	e8 76 c9 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01036ca:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f01036d0:	89 34 24             	mov    %esi,(%esp)
f01036d3:	e8 35 dc ff ff       	call   f010130d <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01036d8:	c7 04 24 14 9c 10 f0 	movl   $0xf0109c14,(%esp)
f01036df:	e8 a6 0b 00 00       	call   f010428a <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f01036e4:	83 c4 3c             	add    $0x3c,%esp
f01036e7:	5b                   	pop    %ebx
f01036e8:	5e                   	pop    %esi
f01036e9:	5f                   	pop    %edi
f01036ea:	5d                   	pop    %ebp
f01036eb:	c3                   	ret    
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01036ec:	89 da                	mov    %ebx,%edx
f01036ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01036f1:	e8 bc d6 ff ff       	call   f0100db2 <check_va2pa>
f01036f6:	e9 5f fa ff ff       	jmp    f010315a <mem_init+0x1ab7>

f01036fb <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01036fb:	55                   	push   %ebp
f01036fc:	89 e5                	mov    %esp,%ebp
f01036fe:	57                   	push   %edi
f01036ff:	56                   	push   %esi
f0103700:	53                   	push   %ebx
f0103701:	83 ec 2c             	sub    $0x2c,%esp
f0103704:	8b 75 08             	mov    0x8(%ebp),%esi
f0103707:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 3: Your code here.
	const void *va_ptr = ROUNDDOWN(va, PGSIZE);
f010370a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010370d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// page alignment
	for (; va_ptr < ROUNDUP(va+len, PGSIZE); va_ptr += PGSIZE) {
f0103713:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103716:	03 45 10             	add    0x10(%ebp),%eax
f0103719:	05 ff 0f 00 00       	add    $0xfff,%eax
f010371e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103723:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103726:	eb 4b                	jmp    f0103773 <user_mem_check+0x78>
		pte_t *ppte = pgdir_walk(env->env_pgdir, va_ptr, 0);
f0103728:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010372f:	00 
f0103730:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103734:	8b 46 60             	mov    0x60(%esi),%eax
f0103737:	89 04 24             	mov    %eax,(%esp)
f010373a:	e8 4a dc ff ff       	call   f0101389 <pgdir_walk>
		if (((uintptr_t)va_ptr >= ULIM) || !ppte || !(*ppte & PTE_P) || (*ppte & perm) != perm) {
f010373f:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103745:	77 10                	ja     f0103757 <user_mem_check+0x5c>
f0103747:	85 c0                	test   %eax,%eax
f0103749:	74 0c                	je     f0103757 <user_mem_check+0x5c>
f010374b:	8b 00                	mov    (%eax),%eax
f010374d:	a8 01                	test   $0x1,%al
f010374f:	74 06                	je     f0103757 <user_mem_check+0x5c>
f0103751:	21 f8                	and    %edi,%eax
f0103753:	39 c7                	cmp    %eax,%edi
f0103755:	74 16                	je     f010376d <user_mem_check+0x72>
			user_mem_check_addr = (uintptr_t)(va_ptr < va ? va : va_ptr);
f0103757:	89 d8                	mov    %ebx,%eax
f0103759:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f010375c:	76 03                	jbe    f0103761 <user_mem_check+0x66>
f010375e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103761:	a3 44 82 35 f0       	mov    %eax,0xf0358244
			return -E_FAULT;
f0103766:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010376b:	eb 10                	jmp    f010377d <user_mem_check+0x82>
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	const void *va_ptr = ROUNDDOWN(va, PGSIZE);
	// page alignment
	for (; va_ptr < ROUNDUP(va+len, PGSIZE); va_ptr += PGSIZE) {
f010376d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103773:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0103776:	72 b0                	jb     f0103728 <user_mem_check+0x2d>
		if (((uintptr_t)va_ptr >= ULIM) || !ppte || !(*ppte & PTE_P) || (*ppte & perm) != perm) {
			user_mem_check_addr = (uintptr_t)(va_ptr < va ? va : va_ptr);
			return -E_FAULT;
		}
	}
	return 0;
f0103778:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010377d:	83 c4 2c             	add    $0x2c,%esp
f0103780:	5b                   	pop    %ebx
f0103781:	5e                   	pop    %esi
f0103782:	5f                   	pop    %edi
f0103783:	5d                   	pop    %ebp
f0103784:	c3                   	ret    

f0103785 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103785:	55                   	push   %ebp
f0103786:	89 e5                	mov    %esp,%ebp
f0103788:	53                   	push   %ebx
f0103789:	83 ec 14             	sub    $0x14,%esp
f010378c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f010378f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103792:	83 c8 04             	or     $0x4,%eax
f0103795:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103799:	8b 45 10             	mov    0x10(%ebp),%eax
f010379c:	89 44 24 08          	mov    %eax,0x8(%esp)
f01037a0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01037a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037a7:	89 1c 24             	mov    %ebx,(%esp)
f01037aa:	e8 4c ff ff ff       	call   f01036fb <user_mem_check>
f01037af:	85 c0                	test   %eax,%eax
f01037b1:	79 24                	jns    f01037d7 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f01037b3:	a1 44 82 35 f0       	mov    0xf0358244,%eax
f01037b8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01037bc:	8b 43 48             	mov    0x48(%ebx),%eax
f01037bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037c3:	c7 04 24 40 9c 10 f0 	movl   $0xf0109c40,(%esp)
f01037ca:	e8 bb 0a 00 00       	call   f010428a <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01037cf:	89 1c 24             	mov    %ebx,(%esp)
f01037d2:	e8 a5 07 00 00       	call   f0103f7c <env_destroy>
	}
}
f01037d7:	83 c4 14             	add    $0x14,%esp
f01037da:	5b                   	pop    %ebx
f01037db:	5d                   	pop    %ebp
f01037dc:	c3                   	ret    
f01037dd:	00 00                	add    %al,(%eax)
	...

f01037e0 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01037e0:	55                   	push   %ebp
f01037e1:	89 e5                	mov    %esp,%ebp
f01037e3:	57                   	push   %edi
f01037e4:	56                   	push   %esi
f01037e5:	53                   	push   %ebx
f01037e6:	83 ec 1c             	sub    $0x1c,%esp
f01037e9:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *va_ptr = ROUNDDOWN(va, PGSIZE);
f01037eb:	89 d3                	mov    %edx,%ebx
f01037ed:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// page alignment
	for (; va_ptr < ROUNDUP(va+len, PGSIZE); va_ptr += PGSIZE) {
f01037f3:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f01037fa:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0103800:	eb 4d                	jmp    f010384f <region_alloc+0x6f>
		struct PageInfo *pp = page_alloc(0);
f0103802:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103809:	e8 7b da ff ff       	call   f0101289 <page_alloc>
		// if page alloction failed
		if (!pp) panic("region_alloc: page alloc failed!");
f010380e:	85 c0                	test   %eax,%eax
f0103810:	75 1c                	jne    f010382e <region_alloc+0x4e>
f0103812:	c7 44 24 08 88 9f 10 	movl   $0xf0109f88,0x8(%esp)
f0103819:	f0 
f010381a:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
f0103821:	00 
f0103822:	c7 04 24 e1 9f 10 f0 	movl   $0xf0109fe1,(%esp)
f0103829:	e8 12 c8 ff ff       	call   f0100040 <_panic>
		page_insert(e->env_pgdir, pp, va_ptr, PTE_W | PTE_U);
f010382e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103835:	00 
f0103836:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010383a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010383e:	8b 46 60             	mov    0x60(%esi),%eax
f0103841:	89 04 24             	mov    %eax,(%esp)
f0103844:	e8 79 dd ff ff       	call   f01015c2 <page_insert>
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *va_ptr = ROUNDDOWN(va, PGSIZE);
	// page alignment
	for (; va_ptr < ROUNDUP(va+len, PGSIZE); va_ptr += PGSIZE) {
f0103849:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010384f:	39 fb                	cmp    %edi,%ebx
f0103851:	72 af                	jb     f0103802 <region_alloc+0x22>
		struct PageInfo *pp = page_alloc(0);
		// if page alloction failed
		if (!pp) panic("region_alloc: page alloc failed!");
		page_insert(e->env_pgdir, pp, va_ptr, PTE_W | PTE_U);
	}
}
f0103853:	83 c4 1c             	add    $0x1c,%esp
f0103856:	5b                   	pop    %ebx
f0103857:	5e                   	pop    %esi
f0103858:	5f                   	pop    %edi
f0103859:	5d                   	pop    %ebp
f010385a:	c3                   	ret    

f010385b <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010385b:	55                   	push   %ebp
f010385c:	89 e5                	mov    %esp,%ebp
f010385e:	57                   	push   %edi
f010385f:	56                   	push   %esi
f0103860:	53                   	push   %ebx
f0103861:	83 ec 0c             	sub    $0xc,%esp
f0103864:	8b 45 08             	mov    0x8(%ebp),%eax
f0103867:	8b 75 0c             	mov    0xc(%ebp),%esi
f010386a:	8a 4d 10             	mov    0x10(%ebp),%cl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010386d:	85 c0                	test   %eax,%eax
f010386f:	75 24                	jne    f0103895 <envid2env+0x3a>
		*env_store = curenv;
f0103871:	e8 a2 4b 00 00       	call   f0108418 <cpunum>
f0103876:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010387d:	29 c2                	sub    %eax,%edx
f010387f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103882:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0103889:	89 06                	mov    %eax,(%esi)
		return 0;
f010388b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103890:	e9 81 00 00 00       	jmp    f0103916 <envid2env+0xbb>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103895:	89 c2                	mov    %eax,%edx
f0103897:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010389d:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01038a0:	8d 1c 92             	lea    (%edx,%edx,4),%ebx
f01038a3:	c1 e3 04             	shl    $0x4,%ebx
f01038a6:	03 1d 48 82 35 f0    	add    0xf0358248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01038ac:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01038b0:	74 05                	je     f01038b7 <envid2env+0x5c>
f01038b2:	39 43 48             	cmp    %eax,0x48(%ebx)
f01038b5:	74 0d                	je     f01038c4 <envid2env+0x69>
		*env_store = 0;
f01038b7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01038bd:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01038c2:	eb 52                	jmp    f0103916 <envid2env+0xbb>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01038c4:	84 c9                	test   %cl,%cl
f01038c6:	74 47                	je     f010390f <envid2env+0xb4>
f01038c8:	e8 4b 4b 00 00       	call   f0108418 <cpunum>
f01038cd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01038d4:	29 c2                	sub    %eax,%edx
f01038d6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01038d9:	39 1c 85 28 90 35 f0 	cmp    %ebx,-0xfca6fd8(,%eax,4)
f01038e0:	74 2d                	je     f010390f <envid2env+0xb4>
f01038e2:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f01038e5:	e8 2e 4b 00 00       	call   f0108418 <cpunum>
f01038ea:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01038f1:	29 c2                	sub    %eax,%edx
f01038f3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01038f6:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f01038fd:	3b 78 48             	cmp    0x48(%eax),%edi
f0103900:	74 0d                	je     f010390f <envid2env+0xb4>
		*env_store = 0;
f0103902:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103908:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010390d:	eb 07                	jmp    f0103916 <envid2env+0xbb>
	}

	*env_store = e;
f010390f:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0103911:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103916:	83 c4 0c             	add    $0xc,%esp
f0103919:	5b                   	pop    %ebx
f010391a:	5e                   	pop    %esi
f010391b:	5f                   	pop    %edi
f010391c:	5d                   	pop    %ebp
f010391d:	c3                   	ret    

f010391e <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f010391e:	55                   	push   %ebp
f010391f:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103921:	b8 20 e3 12 f0       	mov    $0xf012e320,%eax
f0103926:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103929:	b8 23 00 00 00       	mov    $0x23,%eax
f010392e:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103930:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103932:	b0 10                	mov    $0x10,%al
f0103934:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103936:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103938:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f010393a:	ea 41 39 10 f0 08 00 	ljmp   $0x8,$0xf0103941
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103941:	b0 00                	mov    $0x0,%al
f0103943:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103946:	5d                   	pop    %ebp
f0103947:	c3                   	ret    

f0103948 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103948:	55                   	push   %ebp
f0103949:	89 e5                	mov    %esp,%ebp
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f010394b:	a1 48 82 35 f0       	mov    0xf0358248,%eax
f0103950:	05 f0 00 00 00       	add    $0xf0,%eax
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = 0; i < NENV; i++) {
f0103955:	ba 00 00 00 00       	mov    $0x0,%edx
		envs[i].env_id = 0;
f010395a:	c7 80 58 ff ff ff 00 	movl   $0x0,-0xa8(%eax)
f0103961:	00 00 00 
		envs[i].env_link = &envs[i+1];
f0103964:	89 80 54 ff ff ff    	mov    %eax,-0xac(%eax)
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = 0; i < NENV; i++) {
f010396a:	42                   	inc    %edx
f010396b:	05 f0 00 00 00       	add    $0xf0,%eax
f0103970:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0103976:	75 e2                	jne    f010395a <env_init+0x12>
		envs[i].env_id = 0;
		envs[i].env_link = &envs[i+1];
	}
	// point env_free_list to the first free env
	env_free_list = envs;
f0103978:	a1 48 82 35 f0       	mov    0xf0358248,%eax
f010397d:	a3 4c 82 35 f0       	mov    %eax,0xf035824c
	// Per-CPU part of the initialization
	env_init_percpu();
f0103982:	e8 97 ff ff ff       	call   f010391e <env_init_percpu>
}
f0103987:	5d                   	pop    %ebp
f0103988:	c3                   	ret    

f0103989 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103989:	55                   	push   %ebp
f010398a:	89 e5                	mov    %esp,%ebp
f010398c:	53                   	push   %ebx
f010398d:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103990:	8b 1d 4c 82 35 f0    	mov    0xf035824c,%ebx
f0103996:	85 db                	test   %ebx,%ebx
f0103998:	0f 84 53 02 00 00    	je     f0103bf1 <env_alloc+0x268>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010399e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01039a5:	e8 df d8 ff ff       	call   f0101289 <page_alloc>
f01039aa:	85 c0                	test   %eax,%eax
f01039ac:	0f 84 46 02 00 00    	je     f0103bf8 <env_alloc+0x26f>
f01039b2:	89 c2                	mov    %eax,%edx
f01039b4:	2b 15 90 8e 35 f0    	sub    0xf0358e90,%edx
f01039ba:	c1 fa 03             	sar    $0x3,%edx
f01039bd:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01039c0:	89 d1                	mov    %edx,%ecx
f01039c2:	c1 e9 0c             	shr    $0xc,%ecx
f01039c5:	3b 0d 88 8e 35 f0    	cmp    0xf0358e88,%ecx
f01039cb:	72 20                	jb     f01039ed <env_alloc+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01039cd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01039d1:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f01039d8:	f0 
f01039d9:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01039e0:	00 
f01039e1:	c7 04 24 81 9c 10 f0 	movl   $0xf0109c81,(%esp)
f01039e8:	e8 53 c6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01039ed:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01039f3:	89 53 60             	mov    %edx,0x60(%ebx)
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = page2kva(p);
	p->pp_ref++;
f01039f6:	66 ff 40 04          	incw   0x4(%eax)
	// use kern_pgdir as a template
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01039fa:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103a01:	00 
f0103a02:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
f0103a07:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a0b:	8b 43 60             	mov    0x60(%ebx),%eax
f0103a0e:	89 04 24             	mov    %eax,(%esp)
f0103a11:	e8 88 44 00 00       	call   f0107e9e <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103a16:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a19:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a1e:	77 20                	ja     f0103a40 <env_alloc+0xb7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a20:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a24:	c7 44 24 08 04 8b 10 	movl   $0xf0108b04,0x8(%esp)
f0103a2b:	f0 
f0103a2c:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
f0103a33:	00 
f0103a34:	c7 04 24 e1 9f 10 f0 	movl   $0xf0109fe1,(%esp)
f0103a3b:	e8 00 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a40:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103a46:	83 ca 05             	or     $0x5,%edx
f0103a49:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103a4f:	8b 43 48             	mov    0x48(%ebx),%eax
f0103a52:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103a57:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103a5c:	7f 05                	jg     f0103a63 <env_alloc+0xda>
		generation = 1 << ENVGENSHIFT;
f0103a5e:	b8 00 10 00 00       	mov    $0x1000,%eax
	e->env_id = generation | (e - envs);
f0103a63:	89 d9                	mov    %ebx,%ecx
f0103a65:	2b 0d 48 82 35 f0    	sub    0xf0358248,%ecx
f0103a6b:	c1 f9 04             	sar    $0x4,%ecx
f0103a6e:	89 ca                	mov    %ecx,%edx
f0103a70:	c1 e2 04             	shl    $0x4,%edx
f0103a73:	01 d1                	add    %edx,%ecx
f0103a75:	89 ca                	mov    %ecx,%edx
f0103a77:	c1 e2 08             	shl    $0x8,%edx
f0103a7a:	01 ca                	add    %ecx,%edx
f0103a7c:	89 d1                	mov    %edx,%ecx
f0103a7e:	c1 e1 10             	shl    $0x10,%ecx
f0103a81:	01 ca                	add    %ecx,%edx
f0103a83:	f7 da                	neg    %edx
f0103a85:	09 d0                	or     %edx,%eax
f0103a87:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103a8a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a8d:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103a90:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103a97:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103a9e:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103aa5:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103aac:	00 
f0103aad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103ab4:	00 
f0103ab5:	89 1c 24             	mov    %ebx,(%esp)
f0103ab8:	e8 2d 43 00 00       	call   f0107dea <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103abd:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103ac3:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103ac9:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103acf:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103ad6:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103adc:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103ae3:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_divzero_upcall = 0;
f0103aea:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)
	e->env_debug_upcall = 0;
f0103af1:	c7 43 6c 00 00 00 00 	movl   $0x0,0x6c(%ebx)
	e->env_nmskint_upcall = 0;
f0103af8:	c7 43 70 00 00 00 00 	movl   $0x0,0x70(%ebx)
	e->env_bpoint_upcall = 0;
f0103aff:	c7 43 74 00 00 00 00 	movl   $0x0,0x74(%ebx)
	e->env_oflow_upcall = 0;
f0103b06:	c7 43 78 00 00 00 00 	movl   $0x0,0x78(%ebx)
	e->env_bdschk_upcall = 0;
f0103b0d:	c7 43 7c 00 00 00 00 	movl   $0x0,0x7c(%ebx)
	e->env_illopcd_upcall = 0;
f0103b14:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
f0103b1b:	00 00 00 
	e->env_dvcntavl_upcall = 0;
f0103b1e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
f0103b25:	00 00 00 
	e->env_dbfault_upcall = 0;
f0103b28:	c7 83 88 00 00 00 00 	movl   $0x0,0x88(%ebx)
f0103b2f:	00 00 00 
	e->env_ivldtss_upcall = 0;
f0103b32:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
f0103b39:	00 00 00 
	e->env_segntprst_upcall = 0;
f0103b3c:	c7 83 90 00 00 00 00 	movl   $0x0,0x90(%ebx)
f0103b43:	00 00 00 
	e->env_stkexception_upcall = 0;
f0103b46:	c7 83 94 00 00 00 00 	movl   $0x0,0x94(%ebx)
f0103b4d:	00 00 00 
	e->env_gpfault_upcall = 0;
f0103b50:	c7 83 98 00 00 00 00 	movl   $0x0,0x98(%ebx)
f0103b57:	00 00 00 
	e->env_fperror_upcall = 0;
f0103b5a:	c7 83 9c 00 00 00 00 	movl   $0x0,0x9c(%ebx)
f0103b61:	00 00 00 
	e->env_algchk_upcall = 0;
f0103b64:	c7 83 a0 00 00 00 00 	movl   $0x0,0xa0(%ebx)
f0103b6b:	00 00 00 
	e->env_mchchk_upcall = 0;
f0103b6e:	c7 83 a4 00 00 00 00 	movl   $0x0,0xa4(%ebx)
f0103b75:	00 00 00 
	e->env_SIMDfperror_upcall = 0;
f0103b78:	c7 83 a8 00 00 00 00 	movl   $0x0,0xa8(%ebx)
f0103b7f:	00 00 00 

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103b82:	c6 83 ac 00 00 00 00 	movb   $0x0,0xac(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103b89:	8b 43 44             	mov    0x44(%ebx),%eax
f0103b8c:	a3 4c 82 35 f0       	mov    %eax,0xf035824c
	*newenv_store = e;
f0103b91:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b94:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103b96:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103b99:	e8 7a 48 00 00       	call   f0108418 <cpunum>
f0103b9e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ba5:	29 c2                	sub    %eax,%edx
f0103ba7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103baa:	83 3c 85 28 90 35 f0 	cmpl   $0x0,-0xfca6fd8(,%eax,4)
f0103bb1:	00 
f0103bb2:	74 1d                	je     f0103bd1 <env_alloc+0x248>
f0103bb4:	e8 5f 48 00 00       	call   f0108418 <cpunum>
f0103bb9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103bc0:	29 c2                	sub    %eax,%edx
f0103bc2:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103bc5:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0103bcc:	8b 40 48             	mov    0x48(%eax),%eax
f0103bcf:	eb 05                	jmp    f0103bd6 <env_alloc+0x24d>
f0103bd1:	b8 00 00 00 00       	mov    $0x0,%eax
f0103bd6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103bda:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bde:	c7 04 24 ec 9f 10 f0 	movl   $0xf0109fec,(%esp)
f0103be5:	e8 a0 06 00 00       	call   f010428a <cprintf>
	return 0;
f0103bea:	b8 00 00 00 00       	mov    $0x0,%eax
f0103bef:	eb 0c                	jmp    f0103bfd <env_alloc+0x274>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103bf1:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103bf6:	eb 05                	jmp    f0103bfd <env_alloc+0x274>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103bf8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103bfd:	83 c4 14             	add    $0x14,%esp
f0103c00:	5b                   	pop    %ebx
f0103c01:	5d                   	pop    %ebp
f0103c02:	c3                   	ret    

f0103c03 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103c03:	55                   	push   %ebp
f0103c04:	89 e5                	mov    %esp,%ebp
f0103c06:	57                   	push   %edi
f0103c07:	56                   	push   %esi
f0103c08:	53                   	push   %ebx
f0103c09:	83 ec 3c             	sub    $0x3c,%esp
f0103c0c:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *penv;
	// new env's parent ID is set to 0
	env_alloc(&penv, 0);
f0103c0f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103c16:	00 
f0103c17:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103c1a:	89 04 24             	mov    %eax,(%esp)
f0103c1d:	e8 67 fd ff ff       	call   f0103989 <env_alloc>
	load_icode(penv, binary);
f0103c22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103c25:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// LAB 3: Your code here.
	struct Proghdr *ph, *eph;
	struct Elf *ELFHDR = (struct Elf *)binary;

	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
f0103c28:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103c2e:	74 1c                	je     f0103c4c <env_create+0x49>
		panic("load_icode: invalid ELF file!");
f0103c30:	c7 44 24 08 01 a0 10 	movl   $0xf010a001,0x8(%esp)
f0103c37:	f0 
f0103c38:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
f0103c3f:	00 
f0103c40:	c7 04 24 e1 9f 10 f0 	movl   $0xf0109fe1,(%esp)
f0103c47:	e8 f4 c3 ff ff       	call   f0100040 <_panic>

	// load each program segment
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0103c4c:	89 fb                	mov    %edi,%ebx
f0103c4e:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f0103c51:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103c55:	c1 e6 05             	shl    $0x5,%esi
f0103c58:	01 de                	add    %ebx,%esi

	lcr3(PADDR(e->env_pgdir));
f0103c5a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103c5d:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103c60:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103c65:	77 20                	ja     f0103c87 <env_create+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c67:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c6b:	c7 44 24 08 04 8b 10 	movl   $0xf0108b04,0x8(%esp)
f0103c72:	f0 
f0103c73:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
f0103c7a:	00 
f0103c7b:	c7 04 24 e1 9f 10 f0 	movl   $0xf0109fe1,(%esp)
f0103c82:	e8 b9 c3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103c87:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103c8c:	0f 22 d8             	mov    %eax,%cr3
f0103c8f:	eb 6c                	jmp    f0103cfd <env_create+0xfa>
	for (; ph < eph; ph++) {
		if (ph->p_filesz > ph->p_memsz) panic("load_icode: ph->p_filesz is larger than ph->p_memsz!");
f0103c91:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103c94:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103c97:	76 1c                	jbe    f0103cb5 <env_create+0xb2>
f0103c99:	c7 44 24 08 ac 9f 10 	movl   $0xf0109fac,0x8(%esp)
f0103ca0:	f0 
f0103ca1:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
f0103ca8:	00 
f0103ca9:	c7 04 24 e1 9f 10 f0 	movl   $0xf0109fe1,(%esp)
f0103cb0:	e8 8b c3 ff ff       	call   f0100040 <_panic>
		if (ph->p_type == ELF_PROG_LOAD){
f0103cb5:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103cb8:	75 40                	jne    f0103cfa <env_create+0xf7>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103cba:	8b 53 08             	mov    0x8(%ebx),%edx
f0103cbd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103cc0:	e8 1b fb ff ff       	call   f01037e0 <region_alloc>
			memset((void *)ph->p_va, 0, ph->p_memsz);
f0103cc5:	8b 43 14             	mov    0x14(%ebx),%eax
f0103cc8:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103ccc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103cd3:	00 
f0103cd4:	8b 43 08             	mov    0x8(%ebx),%eax
f0103cd7:	89 04 24             	mov    %eax,(%esp)
f0103cda:	e8 0b 41 00 00       	call   f0107dea <memset>
			memcpy((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f0103cdf:	8b 43 10             	mov    0x10(%ebx),%eax
f0103ce2:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103ce6:	89 f8                	mov    %edi,%eax
f0103ce8:	03 43 04             	add    0x4(%ebx),%eax
f0103ceb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cef:	8b 43 08             	mov    0x8(%ebx),%eax
f0103cf2:	89 04 24             	mov    %eax,(%esp)
f0103cf5:	e8 a4 41 00 00       	call   f0107e9e <memcpy>
	// load each program segment
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;

	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++) {
f0103cfa:	83 c3 20             	add    $0x20,%ebx
f0103cfd:	39 de                	cmp    %ebx,%esi
f0103cff:	77 90                	ja     f0103c91 <env_create+0x8e>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
			memset((void *)ph->p_va, 0, ph->p_memsz);
			memcpy((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
		}
	}
	lcr3(PADDR(kern_pgdir));
f0103d01:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103d06:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103d0b:	77 20                	ja     f0103d2d <env_create+0x12a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d11:	c7 44 24 08 04 8b 10 	movl   $0xf0108b04,0x8(%esp)
f0103d18:	f0 
f0103d19:	c7 44 24 04 89 01 00 	movl   $0x189,0x4(%esp)
f0103d20:	00 
f0103d21:	c7 04 24 e1 9f 10 f0 	movl   $0xf0109fe1,(%esp)
f0103d28:	e8 13 c3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103d2d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103d32:	0f 22 d8             	mov    %eax,%cr3

	// set eip to the program's entry point
	e->env_tf.tf_eip = ELFHDR->e_entry;
f0103d35:	8b 47 18             	mov    0x18(%edi),%eax
f0103d38:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103d3b:	89 42 30             	mov    %eax,0x30(%edx)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103d3e:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103d43:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103d48:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103d4b:	e8 90 fa ff ff       	call   f01037e0 <region_alloc>
	// LAB 3: Your code here.
	struct Env *penv;
	// new env's parent ID is set to 0
	env_alloc(&penv, 0);
	load_icode(penv, binary);
}
f0103d50:	83 c4 3c             	add    $0x3c,%esp
f0103d53:	5b                   	pop    %ebx
f0103d54:	5e                   	pop    %esi
f0103d55:	5f                   	pop    %edi
f0103d56:	5d                   	pop    %ebp
f0103d57:	c3                   	ret    

f0103d58 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103d58:	55                   	push   %ebp
f0103d59:	89 e5                	mov    %esp,%ebp
f0103d5b:	57                   	push   %edi
f0103d5c:	56                   	push   %esi
f0103d5d:	53                   	push   %ebx
f0103d5e:	83 ec 2c             	sub    $0x2c,%esp
f0103d61:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103d64:	e8 af 46 00 00       	call   f0108418 <cpunum>
f0103d69:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d70:	29 c2                	sub    %eax,%edx
f0103d72:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d75:	39 3c 85 28 90 35 f0 	cmp    %edi,-0xfca6fd8(,%eax,4)
f0103d7c:	75 34                	jne    f0103db2 <env_free+0x5a>
		lcr3(PADDR(kern_pgdir));
f0103d7e:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103d83:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103d88:	77 20                	ja     f0103daa <env_free+0x52>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d8a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d8e:	c7 44 24 08 04 8b 10 	movl   $0xf0108b04,0x8(%esp)
f0103d95:	f0 
f0103d96:	c7 44 24 04 b4 01 00 	movl   $0x1b4,0x4(%esp)
f0103d9d:	00 
f0103d9e:	c7 04 24 e1 9f 10 f0 	movl   $0xf0109fe1,(%esp)
f0103da5:	e8 96 c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103daa:	05 00 00 00 10       	add    $0x10000000,%eax
f0103daf:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103db2:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103db5:	e8 5e 46 00 00       	call   f0108418 <cpunum>
f0103dba:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103dc1:	29 c2                	sub    %eax,%edx
f0103dc3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103dc6:	83 3c 85 28 90 35 f0 	cmpl   $0x0,-0xfca6fd8(,%eax,4)
f0103dcd:	00 
f0103dce:	74 1d                	je     f0103ded <env_free+0x95>
f0103dd0:	e8 43 46 00 00       	call   f0108418 <cpunum>
f0103dd5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ddc:	29 c2                	sub    %eax,%edx
f0103dde:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103de1:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0103de8:	8b 40 48             	mov    0x48(%eax),%eax
f0103deb:	eb 05                	jmp    f0103df2 <env_free+0x9a>
f0103ded:	b8 00 00 00 00       	mov    $0x0,%eax
f0103df2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103df6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103dfa:	c7 04 24 1f a0 10 f0 	movl   $0xf010a01f,(%esp)
f0103e01:	e8 84 04 00 00       	call   f010428a <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103e06:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103e0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103e10:	c1 e0 02             	shl    $0x2,%eax
f0103e13:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103e16:	8b 47 60             	mov    0x60(%edi),%eax
f0103e19:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103e1c:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103e1f:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103e25:	0f 84 b6 00 00 00    	je     f0103ee1 <env_free+0x189>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103e2b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103e31:	89 f0                	mov    %esi,%eax
f0103e33:	c1 e8 0c             	shr    $0xc,%eax
f0103e36:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103e39:	3b 05 88 8e 35 f0    	cmp    0xf0358e88,%eax
f0103e3f:	72 20                	jb     f0103e61 <env_free+0x109>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103e41:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103e45:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f0103e4c:	f0 
f0103e4d:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
f0103e54:	00 
f0103e55:	c7 04 24 e1 9f 10 f0 	movl   $0xf0109fe1,(%esp)
f0103e5c:	e8 df c1 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103e61:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103e64:	c1 e2 16             	shl    $0x16,%edx
f0103e67:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103e6a:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103e6f:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103e76:	01 
f0103e77:	74 17                	je     f0103e90 <env_free+0x138>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103e79:	89 d8                	mov    %ebx,%eax
f0103e7b:	c1 e0 0c             	shl    $0xc,%eax
f0103e7e:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103e81:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e85:	8b 47 60             	mov    0x60(%edi),%eax
f0103e88:	89 04 24             	mov    %eax,(%esp)
f0103e8b:	e8 e1 d6 ff ff       	call   f0101571 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103e90:	43                   	inc    %ebx
f0103e91:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103e97:	75 d6                	jne    f0103e6f <env_free+0x117>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103e99:	8b 47 60             	mov    0x60(%edi),%eax
f0103e9c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103e9f:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103ea6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103ea9:	3b 05 88 8e 35 f0    	cmp    0xf0358e88,%eax
f0103eaf:	72 1c                	jb     f0103ecd <env_free+0x175>
		panic("pa2page called with invalid pa");
f0103eb1:	c7 44 24 08 14 94 10 	movl   $0xf0109414,0x8(%esp)
f0103eb8:	f0 
f0103eb9:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103ec0:	00 
f0103ec1:	c7 04 24 81 9c 10 f0 	movl   $0xf0109c81,(%esp)
f0103ec8:	e8 73 c1 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103ecd:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103ed0:	c1 e0 03             	shl    $0x3,%eax
f0103ed3:	03 05 90 8e 35 f0    	add    0xf0358e90,%eax
		page_decref(pa2page(pa));
f0103ed9:	89 04 24             	mov    %eax,(%esp)
f0103edc:	e8 88 d4 ff ff       	call   f0101369 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103ee1:	ff 45 e0             	incl   -0x20(%ebp)
f0103ee4:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103eeb:	0f 85 1c ff ff ff    	jne    f0103e0d <env_free+0xb5>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103ef1:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ef4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ef9:	77 20                	ja     f0103f1b <env_free+0x1c3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103efb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103eff:	c7 44 24 08 04 8b 10 	movl   $0xf0108b04,0x8(%esp)
f0103f06:	f0 
f0103f07:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
f0103f0e:	00 
f0103f0f:	c7 04 24 e1 9f 10 f0 	movl   $0xf0109fe1,(%esp)
f0103f16:	e8 25 c1 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103f1b:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103f22:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103f27:	c1 e8 0c             	shr    $0xc,%eax
f0103f2a:	3b 05 88 8e 35 f0    	cmp    0xf0358e88,%eax
f0103f30:	72 1c                	jb     f0103f4e <env_free+0x1f6>
		panic("pa2page called with invalid pa");
f0103f32:	c7 44 24 08 14 94 10 	movl   $0xf0109414,0x8(%esp)
f0103f39:	f0 
f0103f3a:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103f41:	00 
f0103f42:	c7 04 24 81 9c 10 f0 	movl   $0xf0109c81,(%esp)
f0103f49:	e8 f2 c0 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103f4e:	c1 e0 03             	shl    $0x3,%eax
f0103f51:	03 05 90 8e 35 f0    	add    0xf0358e90,%eax
	page_decref(pa2page(pa));
f0103f57:	89 04 24             	mov    %eax,(%esp)
f0103f5a:	e8 0a d4 ff ff       	call   f0101369 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103f5f:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103f66:	a1 4c 82 35 f0       	mov    0xf035824c,%eax
f0103f6b:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103f6e:	89 3d 4c 82 35 f0    	mov    %edi,0xf035824c
}
f0103f74:	83 c4 2c             	add    $0x2c,%esp
f0103f77:	5b                   	pop    %ebx
f0103f78:	5e                   	pop    %esi
f0103f79:	5f                   	pop    %edi
f0103f7a:	5d                   	pop    %ebp
f0103f7b:	c3                   	ret    

f0103f7c <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103f7c:	55                   	push   %ebp
f0103f7d:	89 e5                	mov    %esp,%ebp
f0103f7f:	53                   	push   %ebx
f0103f80:	83 ec 14             	sub    $0x14,%esp
f0103f83:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103f86:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103f8a:	75 23                	jne    f0103faf <env_destroy+0x33>
f0103f8c:	e8 87 44 00 00       	call   f0108418 <cpunum>
f0103f91:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103f98:	29 c2                	sub    %eax,%edx
f0103f9a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103f9d:	39 1c 85 28 90 35 f0 	cmp    %ebx,-0xfca6fd8(,%eax,4)
f0103fa4:	74 09                	je     f0103faf <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103fa6:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103fad:	eb 39                	jmp    f0103fe8 <env_destroy+0x6c>
	}

	env_free(e);
f0103faf:	89 1c 24             	mov    %ebx,(%esp)
f0103fb2:	e8 a1 fd ff ff       	call   f0103d58 <env_free>

	if (curenv == e) {
f0103fb7:	e8 5c 44 00 00       	call   f0108418 <cpunum>
f0103fbc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103fc3:	29 c2                	sub    %eax,%edx
f0103fc5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103fc8:	39 1c 85 28 90 35 f0 	cmp    %ebx,-0xfca6fd8(,%eax,4)
f0103fcf:	75 17                	jne    f0103fe8 <env_destroy+0x6c>
		curenv = NULL;
f0103fd1:	e8 42 44 00 00       	call   f0108418 <cpunum>
f0103fd6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fd9:	c7 80 28 90 35 f0 00 	movl   $0x0,-0xfca6fd8(%eax)
f0103fe0:	00 00 00 
		sched_yield();
f0103fe3:	e8 61 25 00 00       	call   f0106549 <sched_yield>
	}
}
f0103fe8:	83 c4 14             	add    $0x14,%esp
f0103feb:	5b                   	pop    %ebx
f0103fec:	5d                   	pop    %ebp
f0103fed:	c3                   	ret    

f0103fee <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103fee:	55                   	push   %ebp
f0103fef:	89 e5                	mov    %esp,%ebp
f0103ff1:	53                   	push   %ebx
f0103ff2:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103ff5:	e8 1e 44 00 00       	call   f0108418 <cpunum>
f0103ffa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104001:	29 c2                	sub    %eax,%edx
f0104003:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104006:	8b 1c 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%ebx
f010400d:	e8 06 44 00 00       	call   f0108418 <cpunum>
f0104012:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0104015:	8b 65 08             	mov    0x8(%ebp),%esp
f0104018:	61                   	popa   
f0104019:	07                   	pop    %es
f010401a:	1f                   	pop    %ds
f010401b:	83 c4 08             	add    $0x8,%esp
f010401e:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010401f:	c7 44 24 08 35 a0 10 	movl   $0xf010a035,0x8(%esp)
f0104026:	f0 
f0104027:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
f010402e:	00 
f010402f:	c7 04 24 e1 9f 10 f0 	movl   $0xf0109fe1,(%esp)
f0104036:	e8 05 c0 ff ff       	call   f0100040 <_panic>

f010403b <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010403b:	55                   	push   %ebp
f010403c:	89 e5                	mov    %esp,%ebp
f010403e:	53                   	push   %ebx
f010403f:	83 ec 14             	sub    $0x14,%esp
f0104042:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv != e) {
f0104045:	e8 ce 43 00 00       	call   f0108418 <cpunum>
f010404a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104051:	29 c2                	sub    %eax,%edx
f0104053:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104056:	39 1c 85 28 90 35 f0 	cmp    %ebx,-0xfca6fd8(,%eax,4)
f010405d:	0f 84 c8 00 00 00    	je     f010412b <env_run+0xf0>
		if (curenv && curenv->env_status == ENV_RUNNING)
f0104063:	e8 b0 43 00 00       	call   f0108418 <cpunum>
f0104068:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010406f:	29 c2                	sub    %eax,%edx
f0104071:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104074:	83 3c 85 28 90 35 f0 	cmpl   $0x0,-0xfca6fd8(,%eax,4)
f010407b:	00 
f010407c:	74 29                	je     f01040a7 <env_run+0x6c>
f010407e:	e8 95 43 00 00       	call   f0108418 <cpunum>
f0104083:	6b c0 74             	imul   $0x74,%eax,%eax
f0104086:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f010408c:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104090:	75 15                	jne    f01040a7 <env_run+0x6c>
			curenv->env_status = ENV_RUNNABLE;
f0104092:	e8 81 43 00 00       	call   f0108418 <cpunum>
f0104097:	6b c0 74             	imul   $0x74,%eax,%eax
f010409a:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f01040a0:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		curenv = e;
f01040a7:	e8 6c 43 00 00       	call   f0108418 <cpunum>
f01040ac:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01040b3:	29 c2                	sub    %eax,%edx
f01040b5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01040b8:	89 1c 85 28 90 35 f0 	mov    %ebx,-0xfca6fd8(,%eax,4)
		curenv->env_status = ENV_RUNNING;
f01040bf:	e8 54 43 00 00       	call   f0108418 <cpunum>
f01040c4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01040cb:	29 c2                	sub    %eax,%edx
f01040cd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01040d0:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f01040d7:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs++;
f01040de:	e8 35 43 00 00       	call   f0108418 <cpunum>
f01040e3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01040ea:	29 c2                	sub    %eax,%edx
f01040ec:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01040ef:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f01040f6:	ff 40 58             	incl   0x58(%eax)
		lcr3(PADDR(e->env_pgdir));
f01040f9:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01040fc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104101:	77 20                	ja     f0104123 <env_run+0xe8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104103:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104107:	c7 44 24 08 04 8b 10 	movl   $0xf0108b04,0x8(%esp)
f010410e:	f0 
f010410f:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
f0104116:	00 
f0104117:	c7 04 24 e1 9f 10 f0 	movl   $0xf0109fe1,(%esp)
f010411e:	e8 1d bf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104123:	05 00 00 00 10       	add    $0x10000000,%eax
f0104128:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010412b:	c7 04 24 60 e4 12 f0 	movl   $0xf012e460,(%esp)
f0104132:	e8 43 46 00 00       	call   f010877a <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104137:	f3 90                	pause  
	}
	unlock_kernel();
	env_pop_tf(&e->env_tf);
f0104139:	89 1c 24             	mov    %ebx,(%esp)
f010413c:	e8 ad fe ff ff       	call   f0103fee <env_pop_tf>
f0104141:	00 00                	add    %al,(%eax)
	...

f0104144 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0104144:	55                   	push   %ebp
f0104145:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104147:	ba 70 00 00 00       	mov    $0x70,%edx
f010414c:	8b 45 08             	mov    0x8(%ebp),%eax
f010414f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0104150:	b2 71                	mov    $0x71,%dl
f0104152:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0104153:	0f b6 c0             	movzbl %al,%eax
}
f0104156:	5d                   	pop    %ebp
f0104157:	c3                   	ret    

f0104158 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0104158:	55                   	push   %ebp
f0104159:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010415b:	ba 70 00 00 00       	mov    $0x70,%edx
f0104160:	8b 45 08             	mov    0x8(%ebp),%eax
f0104163:	ee                   	out    %al,(%dx)
f0104164:	b2 71                	mov    $0x71,%dl
f0104166:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104169:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010416a:	5d                   	pop    %ebp
f010416b:	c3                   	ret    

f010416c <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010416c:	55                   	push   %ebp
f010416d:	89 e5                	mov    %esp,%ebp
f010416f:	56                   	push   %esi
f0104170:	53                   	push   %ebx
f0104171:	83 ec 10             	sub    $0x10,%esp
f0104174:	8b 45 08             	mov    0x8(%ebp),%eax
f0104177:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0104179:	66 a3 a8 e3 12 f0    	mov    %ax,0xf012e3a8
	if (!didinit)
f010417f:	80 3d 50 82 35 f0 00 	cmpb   $0x0,0xf0358250
f0104186:	74 51                	je     f01041d9 <irq_setmask_8259A+0x6d>
f0104188:	ba 21 00 00 00       	mov    $0x21,%edx
f010418d:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f010418e:	89 f0                	mov    %esi,%eax
f0104190:	66 c1 e8 08          	shr    $0x8,%ax
f0104194:	b2 a1                	mov    $0xa1,%dl
f0104196:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0104197:	c7 04 24 41 a0 10 f0 	movl   $0xf010a041,(%esp)
f010419e:	e8 e7 00 00 00       	call   f010428a <cprintf>
	for (i = 0; i < 16; i++)
f01041a3:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01041a8:	0f b7 f6             	movzwl %si,%esi
f01041ab:	f7 d6                	not    %esi
f01041ad:	89 f0                	mov    %esi,%eax
f01041af:	88 d9                	mov    %bl,%cl
f01041b1:	d3 f8                	sar    %cl,%eax
f01041b3:	a8 01                	test   $0x1,%al
f01041b5:	74 10                	je     f01041c7 <irq_setmask_8259A+0x5b>
			cprintf(" %d", i);
f01041b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01041bb:	c7 04 24 8f a9 10 f0 	movl   $0xf010a98f,(%esp)
f01041c2:	e8 c3 00 00 00       	call   f010428a <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01041c7:	43                   	inc    %ebx
f01041c8:	83 fb 10             	cmp    $0x10,%ebx
f01041cb:	75 e0                	jne    f01041ad <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01041cd:	c7 04 24 55 9f 10 f0 	movl   $0xf0109f55,(%esp)
f01041d4:	e8 b1 00 00 00       	call   f010428a <cprintf>
}
f01041d9:	83 c4 10             	add    $0x10,%esp
f01041dc:	5b                   	pop    %ebx
f01041dd:	5e                   	pop    %esi
f01041de:	5d                   	pop    %ebp
f01041df:	c3                   	ret    

f01041e0 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01041e0:	55                   	push   %ebp
f01041e1:	89 e5                	mov    %esp,%ebp
f01041e3:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f01041e6:	c6 05 50 82 35 f0 01 	movb   $0x1,0xf0358250
f01041ed:	ba 21 00 00 00       	mov    $0x21,%edx
f01041f2:	b0 ff                	mov    $0xff,%al
f01041f4:	ee                   	out    %al,(%dx)
f01041f5:	b2 a1                	mov    $0xa1,%dl
f01041f7:	ee                   	out    %al,(%dx)
f01041f8:	b2 20                	mov    $0x20,%dl
f01041fa:	b0 11                	mov    $0x11,%al
f01041fc:	ee                   	out    %al,(%dx)
f01041fd:	b2 21                	mov    $0x21,%dl
f01041ff:	b0 20                	mov    $0x20,%al
f0104201:	ee                   	out    %al,(%dx)
f0104202:	b0 04                	mov    $0x4,%al
f0104204:	ee                   	out    %al,(%dx)
f0104205:	b0 03                	mov    $0x3,%al
f0104207:	ee                   	out    %al,(%dx)
f0104208:	b2 a0                	mov    $0xa0,%dl
f010420a:	b0 11                	mov    $0x11,%al
f010420c:	ee                   	out    %al,(%dx)
f010420d:	b2 a1                	mov    $0xa1,%dl
f010420f:	b0 28                	mov    $0x28,%al
f0104211:	ee                   	out    %al,(%dx)
f0104212:	b0 02                	mov    $0x2,%al
f0104214:	ee                   	out    %al,(%dx)
f0104215:	b0 01                	mov    $0x1,%al
f0104217:	ee                   	out    %al,(%dx)
f0104218:	b2 20                	mov    $0x20,%dl
f010421a:	b0 68                	mov    $0x68,%al
f010421c:	ee                   	out    %al,(%dx)
f010421d:	b0 0a                	mov    $0xa,%al
f010421f:	ee                   	out    %al,(%dx)
f0104220:	b2 a0                	mov    $0xa0,%dl
f0104222:	b0 68                	mov    $0x68,%al
f0104224:	ee                   	out    %al,(%dx)
f0104225:	b0 0a                	mov    $0xa,%al
f0104227:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0104228:	66 a1 a8 e3 12 f0    	mov    0xf012e3a8,%ax
f010422e:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0104232:	74 0b                	je     f010423f <pic_init+0x5f>
		irq_setmask_8259A(irq_mask_8259A);
f0104234:	0f b7 c0             	movzwl %ax,%eax
f0104237:	89 04 24             	mov    %eax,(%esp)
f010423a:	e8 2d ff ff ff       	call   f010416c <irq_setmask_8259A>
}
f010423f:	c9                   	leave  
f0104240:	c3                   	ret    
f0104241:	00 00                	add    %al,(%eax)
	...

f0104244 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104244:	55                   	push   %ebp
f0104245:	89 e5                	mov    %esp,%ebp
f0104247:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010424a:	8b 45 08             	mov    0x8(%ebp),%eax
f010424d:	89 04 24             	mov    %eax,(%esp)
f0104250:	e8 66 c5 ff ff       	call   f01007bb <cputchar>
	*cnt++;
}
f0104255:	c9                   	leave  
f0104256:	c3                   	ret    

f0104257 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0104257:	55                   	push   %ebp
f0104258:	89 e5                	mov    %esp,%ebp
f010425a:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010425d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0104264:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104267:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010426b:	8b 45 08             	mov    0x8(%ebp),%eax
f010426e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104272:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104275:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104279:	c7 04 24 44 42 10 f0 	movl   $0xf0104244,(%esp)
f0104280:	e8 53 35 00 00       	call   f01077d8 <vprintfmt>
	return cnt;
}
f0104285:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104288:	c9                   	leave  
f0104289:	c3                   	ret    

f010428a <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010428a:	55                   	push   %ebp
f010428b:	89 e5                	mov    %esp,%ebp
f010428d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0104290:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0104293:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104297:	8b 45 08             	mov    0x8(%ebp),%eax
f010429a:	89 04 24             	mov    %eax,(%esp)
f010429d:	e8 b5 ff ff ff       	call   f0104257 <vcprintf>
	va_end(ap);

	return cnt;
}
f01042a2:	c9                   	leave  
f01042a3:	c3                   	ret    

f01042a4 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01042a4:	55                   	push   %ebp
f01042a5:	89 e5                	mov    %esp,%ebp
f01042a7:	57                   	push   %edi
f01042a8:	56                   	push   %esi
f01042a9:	53                   	push   %ebx
f01042aa:	83 ec 0c             	sub    $0xc,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int cid = thiscpu->cpu_id;
f01042ad:	e8 66 41 00 00       	call   f0108418 <cpunum>
f01042b2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01042b9:	29 c2                	sub    %eax,%edx
f01042bb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01042be:	0f b6 1c 85 20 90 35 	movzbl -0xfca6fe0(,%eax,4),%ebx
f01042c5:	f0 

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cid * (KSTKSIZE + KSTKGAP);
f01042c6:	e8 4d 41 00 00       	call   f0108418 <cpunum>
f01042cb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01042d2:	29 c2                	sub    %eax,%edx
f01042d4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01042d7:	89 da                	mov    %ebx,%edx
f01042d9:	f7 da                	neg    %edx
f01042db:	c1 e2 10             	shl    $0x10,%edx
f01042de:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01042e4:	89 14 85 30 90 35 f0 	mov    %edx,-0xfca6fd0(,%eax,4)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01042eb:	e8 28 41 00 00       	call   f0108418 <cpunum>
f01042f0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01042f7:	29 c2                	sub    %eax,%edx
f01042f9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01042fc:	66 c7 04 85 34 90 35 	movw   $0x10,-0xfca6fcc(,%eax,4)
f0104303:	f0 10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cid] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0104306:	83 c3 05             	add    $0x5,%ebx
f0104309:	e8 0a 41 00 00       	call   f0108418 <cpunum>
f010430e:	89 c6                	mov    %eax,%esi
f0104310:	e8 03 41 00 00       	call   f0108418 <cpunum>
f0104315:	89 c7                	mov    %eax,%edi
f0104317:	e8 fc 40 00 00       	call   f0108418 <cpunum>
f010431c:	66 c7 04 dd 40 e3 12 	movw   $0x67,-0xfed1cc0(,%ebx,8)
f0104323:	f0 67 00 
f0104326:	8d 14 f5 00 00 00 00 	lea    0x0(,%esi,8),%edx
f010432d:	29 f2                	sub    %esi,%edx
f010432f:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104332:	8d 14 95 2c 90 35 f0 	lea    -0xfca6fd4(,%edx,4),%edx
f0104339:	66 89 14 dd 42 e3 12 	mov    %dx,-0xfed1cbe(,%ebx,8)
f0104340:	f0 
f0104341:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0104348:	29 fa                	sub    %edi,%edx
f010434a:	8d 14 97             	lea    (%edi,%edx,4),%edx
f010434d:	8d 14 95 2c 90 35 f0 	lea    -0xfca6fd4(,%edx,4),%edx
f0104354:	c1 ea 10             	shr    $0x10,%edx
f0104357:	88 14 dd 44 e3 12 f0 	mov    %dl,-0xfed1cbc(,%ebx,8)
f010435e:	c6 04 dd 46 e3 12 f0 	movb   $0x40,-0xfed1cba(,%ebx,8)
f0104365:	40 
f0104366:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010436d:	29 c2                	sub    %eax,%edx
f010436f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104372:	8d 04 85 2c 90 35 f0 	lea    -0xfca6fd4(,%eax,4),%eax
f0104379:	c1 e8 18             	shr    $0x18,%eax
f010437c:	88 04 dd 47 e3 12 f0 	mov    %al,-0xfed1cb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cid].sd_s = 0;
f0104383:	c6 04 dd 45 e3 12 f0 	movb   $0x89,-0xfed1cbb(,%ebx,8)
f010438a:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + 8 * cid);
f010438b:	c1 e3 03             	shl    $0x3,%ebx
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010438e:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0104391:	b8 ac e3 12 f0       	mov    $0xf012e3ac,%eax
f0104396:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0104399:	83 c4 0c             	add    $0xc,%esp
f010439c:	5b                   	pop    %ebx
f010439d:	5e                   	pop    %esi
f010439e:	5f                   	pop    %edi
f010439f:	5d                   	pop    %ebp
f01043a0:	c3                   	ret    

f01043a1 <trap_init>:
}


void
trap_init(void)
{
f01043a1:	55                   	push   %ebp
f01043a2:	89 e5                	mov    %esp,%ebp
f01043a4:	83 ec 08             	sub    $0x8,%esp

	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall_handler, 3);
*/
	extern void (*t_handler[])();
	int i;
	for (i = 0; i < 20; i++) {
f01043a7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (i == T_BRKPT) {
f01043ac:	83 f8 03             	cmp    $0x3,%eax
f01043af:	75 33                	jne    f01043e4 <trap_init+0x43>
			SETGATE(idt[i], 0, GD_KT, t_handler[i], 3);
f01043b1:	8b 15 c0 e3 12 f0    	mov    0xf012e3c0,%edx
f01043b7:	66 89 15 78 82 35 f0 	mov    %dx,0xf0358278
f01043be:	66 c7 05 7a 82 35 f0 	movw   $0x8,0xf035827a
f01043c5:	08 00 
f01043c7:	c6 05 7c 82 35 f0 00 	movb   $0x0,0xf035827c
f01043ce:	c6 05 7d 82 35 f0 ee 	movb   $0xee,0xf035827d
f01043d5:	c1 ea 10             	shr    $0x10,%edx
f01043d8:	66 89 15 7e 82 35 f0 	mov    %dx,0xf035827e
f01043df:	e9 c1 00 00 00       	jmp    f01044a5 <trap_init+0x104>
		}
		else if (i !=9 && i != 15) {
f01043e4:	83 f8 09             	cmp    $0x9,%eax
f01043e7:	0f 84 b8 00 00 00    	je     f01044a5 <trap_init+0x104>
f01043ed:	83 f8 0f             	cmp    $0xf,%eax
f01043f0:	0f 84 af 00 00 00    	je     f01044a5 <trap_init+0x104>
			SETGATE(idt[i], 0, GD_KT, t_handler[i], 0);
f01043f6:	8b 14 85 b4 e3 12 f0 	mov    -0xfed1c4c(,%eax,4),%edx
f01043fd:	66 89 14 c5 60 82 35 	mov    %dx,-0xfca7da0(,%eax,8)
f0104404:	f0 
f0104405:	66 c7 04 c5 62 82 35 	movw   $0x8,-0xfca7d9e(,%eax,8)
f010440c:	f0 08 00 
f010440f:	c6 04 c5 64 82 35 f0 	movb   $0x0,-0xfca7d9c(,%eax,8)
f0104416:	00 
f0104417:	c6 04 c5 65 82 35 f0 	movb   $0x8e,-0xfca7d9b(,%eax,8)
f010441e:	8e 
f010441f:	c1 ea 10             	shr    $0x10,%edx
f0104422:	66 89 14 c5 66 82 35 	mov    %dx,-0xfca7d9a(,%eax,8)
f0104429:	f0 

	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall_handler, 3);
*/
	extern void (*t_handler[])();
	int i;
	for (i = 0; i < 20; i++) {
f010442a:	40                   	inc    %eax
f010442b:	83 f8 14             	cmp    $0x14,%eax
f010442e:	0f 85 78 ff ff ff    	jne    f01043ac <trap_init+0xb>
		}
		else if (i !=9 && i != 15) {
			SETGATE(idt[i], 0, GD_KT, t_handler[i], 0);
		}
	}
	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_handler[20], 3);
f0104434:	a1 04 e4 12 f0       	mov    0xf012e404,%eax
f0104439:	66 a3 e0 83 35 f0    	mov    %ax,0xf03583e0
f010443f:	66 c7 05 e2 83 35 f0 	movw   $0x8,0xf03583e2
f0104446:	08 00 
f0104448:	c6 05 e4 83 35 f0 00 	movb   $0x0,0xf03583e4
f010444f:	c6 05 e5 83 35 f0 ee 	movb   $0xee,0xf03583e5
f0104456:	c1 e8 10             	shr    $0x10,%eax
f0104459:	66 a3 e6 83 35 f0    	mov    %ax,0xf03583e6
f010445f:	b8 20 00 00 00       	mov    $0x20,%eax
	for (i = 0; i < 16; i++) {
		SETGATE(idt[IRQ_OFFSET + i], 0, GD_KT, t_handler[21 + i], 0);
f0104464:	8b 14 85 88 e3 12 f0 	mov    -0xfed1c78(,%eax,4),%edx
f010446b:	66 89 14 c5 60 82 35 	mov    %dx,-0xfca7da0(,%eax,8)
f0104472:	f0 
f0104473:	66 c7 04 c5 62 82 35 	movw   $0x8,-0xfca7d9e(,%eax,8)
f010447a:	f0 08 00 
f010447d:	c6 04 c5 64 82 35 f0 	movb   $0x0,-0xfca7d9c(,%eax,8)
f0104484:	00 
f0104485:	c6 04 c5 65 82 35 f0 	movb   $0x8e,-0xfca7d9b(,%eax,8)
f010448c:	8e 
f010448d:	c1 ea 10             	shr    $0x10,%edx
f0104490:	66 89 14 c5 66 82 35 	mov    %dx,-0xfca7d9a(,%eax,8)
f0104497:	f0 
f0104498:	40                   	inc    %eax
		else if (i !=9 && i != 15) {
			SETGATE(idt[i], 0, GD_KT, t_handler[i], 0);
		}
	}
	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_handler[20], 3);
	for (i = 0; i < 16; i++) {
f0104499:	83 f8 30             	cmp    $0x30,%eax
f010449c:	75 c6                	jne    f0104464 <trap_init+0xc3>
		SETGATE(idt[IRQ_OFFSET + i], 0, GD_KT, t_handler[21 + i], 0);
	}
	// Per-CPU setup
	trap_init_percpu();
f010449e:	e8 01 fe ff ff       	call   f01042a4 <trap_init_percpu>
}
f01044a3:	c9                   	leave  
f01044a4:	c3                   	ret    

	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall_handler, 3);
*/
	extern void (*t_handler[])();
	int i;
	for (i = 0; i < 20; i++) {
f01044a5:	40                   	inc    %eax
f01044a6:	e9 01 ff ff ff       	jmp    f01043ac <trap_init+0xb>

f01044ab <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01044ab:	55                   	push   %ebp
f01044ac:	89 e5                	mov    %esp,%ebp
f01044ae:	53                   	push   %ebx
f01044af:	83 ec 14             	sub    $0x14,%esp
f01044b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01044b5:	8b 03                	mov    (%ebx),%eax
f01044b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044bb:	c7 04 24 55 a0 10 f0 	movl   $0xf010a055,(%esp)
f01044c2:	e8 c3 fd ff ff       	call   f010428a <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01044c7:	8b 43 04             	mov    0x4(%ebx),%eax
f01044ca:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044ce:	c7 04 24 64 a0 10 f0 	movl   $0xf010a064,(%esp)
f01044d5:	e8 b0 fd ff ff       	call   f010428a <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01044da:	8b 43 08             	mov    0x8(%ebx),%eax
f01044dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044e1:	c7 04 24 73 a0 10 f0 	movl   $0xf010a073,(%esp)
f01044e8:	e8 9d fd ff ff       	call   f010428a <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01044ed:	8b 43 0c             	mov    0xc(%ebx),%eax
f01044f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044f4:	c7 04 24 82 a0 10 f0 	movl   $0xf010a082,(%esp)
f01044fb:	e8 8a fd ff ff       	call   f010428a <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104500:	8b 43 10             	mov    0x10(%ebx),%eax
f0104503:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104507:	c7 04 24 91 a0 10 f0 	movl   $0xf010a091,(%esp)
f010450e:	e8 77 fd ff ff       	call   f010428a <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104513:	8b 43 14             	mov    0x14(%ebx),%eax
f0104516:	89 44 24 04          	mov    %eax,0x4(%esp)
f010451a:	c7 04 24 a0 a0 10 f0 	movl   $0xf010a0a0,(%esp)
f0104521:	e8 64 fd ff ff       	call   f010428a <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104526:	8b 43 18             	mov    0x18(%ebx),%eax
f0104529:	89 44 24 04          	mov    %eax,0x4(%esp)
f010452d:	c7 04 24 af a0 10 f0 	movl   $0xf010a0af,(%esp)
f0104534:	e8 51 fd ff ff       	call   f010428a <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104539:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010453c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104540:	c7 04 24 be a0 10 f0 	movl   $0xf010a0be,(%esp)
f0104547:	e8 3e fd ff ff       	call   f010428a <cprintf>
}
f010454c:	83 c4 14             	add    $0x14,%esp
f010454f:	5b                   	pop    %ebx
f0104550:	5d                   	pop    %ebp
f0104551:	c3                   	ret    

f0104552 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104552:	55                   	push   %ebp
f0104553:	89 e5                	mov    %esp,%ebp
f0104555:	53                   	push   %ebx
f0104556:	83 ec 14             	sub    $0x14,%esp
f0104559:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f010455c:	e8 b7 3e 00 00       	call   f0108418 <cpunum>
f0104561:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104565:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104569:	c7 04 24 22 a1 10 f0 	movl   $0xf010a122,(%esp)
f0104570:	e8 15 fd ff ff       	call   f010428a <cprintf>
	print_regs(&tf->tf_regs);
f0104575:	89 1c 24             	mov    %ebx,(%esp)
f0104578:	e8 2e ff ff ff       	call   f01044ab <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010457d:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104581:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104585:	c7 04 24 40 a1 10 f0 	movl   $0xf010a140,(%esp)
f010458c:	e8 f9 fc ff ff       	call   f010428a <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104591:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104595:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104599:	c7 04 24 53 a1 10 f0 	movl   $0xf010a153,(%esp)
f01045a0:	e8 e5 fc ff ff       	call   f010428a <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01045a5:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01045a8:	83 f8 13             	cmp    $0x13,%eax
f01045ab:	77 09                	ja     f01045b6 <print_trapframe+0x64>
		return excnames[trapno];
f01045ad:	8b 14 85 c0 a7 10 f0 	mov    -0xfef5840(,%eax,4),%edx
f01045b4:	eb 20                	jmp    f01045d6 <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f01045b6:	83 f8 30             	cmp    $0x30,%eax
f01045b9:	74 0f                	je     f01045ca <print_trapframe+0x78>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01045bb:	8d 50 e0             	lea    -0x20(%eax),%edx
f01045be:	83 fa 0f             	cmp    $0xf,%edx
f01045c1:	77 0e                	ja     f01045d1 <print_trapframe+0x7f>
		return "Hardware Interrupt";
f01045c3:	ba d9 a0 10 f0       	mov    $0xf010a0d9,%edx
f01045c8:	eb 0c                	jmp    f01045d6 <print_trapframe+0x84>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01045ca:	ba cd a0 10 f0       	mov    $0xf010a0cd,%edx
f01045cf:	eb 05                	jmp    f01045d6 <print_trapframe+0x84>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
f01045d1:	ba ec a0 10 f0       	mov    $0xf010a0ec,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01045d6:	89 54 24 08          	mov    %edx,0x8(%esp)
f01045da:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045de:	c7 04 24 66 a1 10 f0 	movl   $0xf010a166,(%esp)
f01045e5:	e8 a0 fc ff ff       	call   f010428a <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01045ea:	3b 1d 60 8a 35 f0    	cmp    0xf0358a60,%ebx
f01045f0:	75 19                	jne    f010460b <print_trapframe+0xb9>
f01045f2:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01045f6:	75 13                	jne    f010460b <print_trapframe+0xb9>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01045f8:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01045fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045ff:	c7 04 24 78 a1 10 f0 	movl   $0xf010a178,(%esp)
f0104606:	e8 7f fc ff ff       	call   f010428a <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f010460b:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010460e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104612:	c7 04 24 87 a1 10 f0 	movl   $0xf010a187,(%esp)
f0104619:	e8 6c fc ff ff       	call   f010428a <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f010461e:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104622:	75 4d                	jne    f0104671 <print_trapframe+0x11f>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104624:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104627:	a8 01                	test   $0x1,%al
f0104629:	74 07                	je     f0104632 <print_trapframe+0xe0>
f010462b:	b9 fb a0 10 f0       	mov    $0xf010a0fb,%ecx
f0104630:	eb 05                	jmp    f0104637 <print_trapframe+0xe5>
f0104632:	b9 06 a1 10 f0       	mov    $0xf010a106,%ecx
f0104637:	a8 02                	test   $0x2,%al
f0104639:	74 07                	je     f0104642 <print_trapframe+0xf0>
f010463b:	ba 12 a1 10 f0       	mov    $0xf010a112,%edx
f0104640:	eb 05                	jmp    f0104647 <print_trapframe+0xf5>
f0104642:	ba 18 a1 10 f0       	mov    $0xf010a118,%edx
f0104647:	a8 04                	test   $0x4,%al
f0104649:	74 07                	je     f0104652 <print_trapframe+0x100>
f010464b:	b8 1d a1 10 f0       	mov    $0xf010a11d,%eax
f0104650:	eb 05                	jmp    f0104657 <print_trapframe+0x105>
f0104652:	b8 6d a2 10 f0       	mov    $0xf010a26d,%eax
f0104657:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010465b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010465f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104663:	c7 04 24 95 a1 10 f0 	movl   $0xf010a195,(%esp)
f010466a:	e8 1b fc ff ff       	call   f010428a <cprintf>
f010466f:	eb 0c                	jmp    f010467d <print_trapframe+0x12b>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104671:	c7 04 24 55 9f 10 f0 	movl   $0xf0109f55,(%esp)
f0104678:	e8 0d fc ff ff       	call   f010428a <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010467d:	8b 43 30             	mov    0x30(%ebx),%eax
f0104680:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104684:	c7 04 24 a4 a1 10 f0 	movl   $0xf010a1a4,(%esp)
f010468b:	e8 fa fb ff ff       	call   f010428a <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104690:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104694:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104698:	c7 04 24 b3 a1 10 f0 	movl   $0xf010a1b3,(%esp)
f010469f:	e8 e6 fb ff ff       	call   f010428a <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01046a4:	8b 43 38             	mov    0x38(%ebx),%eax
f01046a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046ab:	c7 04 24 c6 a1 10 f0 	movl   $0xf010a1c6,(%esp)
f01046b2:	e8 d3 fb ff ff       	call   f010428a <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01046b7:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01046bb:	74 27                	je     f01046e4 <print_trapframe+0x192>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01046bd:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01046c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046c4:	c7 04 24 d5 a1 10 f0 	movl   $0xf010a1d5,(%esp)
f01046cb:	e8 ba fb ff ff       	call   f010428a <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01046d0:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01046d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046d8:	c7 04 24 e4 a1 10 f0 	movl   $0xf010a1e4,(%esp)
f01046df:	e8 a6 fb ff ff       	call   f010428a <cprintf>
	}
}
f01046e4:	83 c4 14             	add    $0x14,%esp
f01046e7:	5b                   	pop    %ebx
f01046e8:	5d                   	pop    %ebp
f01046e9:	c3                   	ret    

f01046ea <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01046ea:	55                   	push   %ebp
f01046eb:	89 e5                	mov    %esp,%ebp
f01046ed:	57                   	push   %edi
f01046ee:	56                   	push   %esi
f01046ef:	53                   	push   %ebx
f01046f0:	83 ec 2c             	sub    $0x2c,%esp
f01046f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01046f6:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f01046f9:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01046fd:	75 1c                	jne    f010471b <page_fault_handler+0x31>
		panic("page fault in kernel mode!");
f01046ff:	c7 44 24 08 f7 a1 10 	movl   $0xf010a1f7,0x8(%esp)
f0104706:	f0 
f0104707:	c7 44 24 04 94 01 00 	movl   $0x194,0x4(%esp)
f010470e:	00 
f010470f:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f0104716:	e8 25 b9 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
f010471b:	e8 f8 3c 00 00       	call   f0108418 <cpunum>
f0104720:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104727:	29 c2                	sub    %eax,%edx
f0104729:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010472c:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0104733:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104737:	0f 84 f0 00 00 00    	je     f010482d <page_fault_handler+0x143>
		struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
f010473d:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104740:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
							(struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
f0104746:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f010474d:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104753:	77 06                	ja     f010475b <page_fault_handler+0x71>
f0104755:	83 e8 38             	sub    $0x38,%eax
f0104758:	89 45 e4             	mov    %eax,-0x1c(%ebp)
							(struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
		// this is a totally wrong statement!
		// struct UTrapframe *utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
		user_mem_assert(curenv, (void *)utf, 1, PTE_W);
f010475b:	e8 b8 3c 00 00       	call   f0108418 <cpunum>
f0104760:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104767:	00 
f0104768:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010476f:	00 
f0104770:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104773:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104777:	6b c0 74             	imul   $0x74,%eax,%eax
f010477a:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0104780:	89 04 24             	mov    %eax,(%esp)
f0104783:	e8 fd ef ff ff       	call   f0103785 <user_mem_assert>
		utf->utf_fault_va = fault_va;
f0104788:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010478b:	89 30                	mov    %esi,(%eax)
		utf->utf_err = tf->tf_err;
f010478d:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104790:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104793:	89 42 04             	mov    %eax,0x4(%edx)
		utf->utf_regs = tf->tf_regs;
f0104796:	89 d7                	mov    %edx,%edi
f0104798:	83 c7 08             	add    $0x8,%edi
f010479b:	89 de                	mov    %ebx,%esi
f010479d:	b8 20 00 00 00       	mov    $0x20,%eax
f01047a2:	f7 c7 01 00 00 00    	test   $0x1,%edi
f01047a8:	74 03                	je     f01047ad <page_fault_handler+0xc3>
f01047aa:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f01047ab:	b0 1f                	mov    $0x1f,%al
f01047ad:	f7 c7 02 00 00 00    	test   $0x2,%edi
f01047b3:	74 05                	je     f01047ba <page_fault_handler+0xd0>
f01047b5:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01047b7:	83 e8 02             	sub    $0x2,%eax
f01047ba:	89 c1                	mov    %eax,%ecx
f01047bc:	c1 e9 02             	shr    $0x2,%ecx
f01047bf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01047c1:	a8 02                	test   $0x2,%al
f01047c3:	74 02                	je     f01047c7 <page_fault_handler+0xdd>
f01047c5:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01047c7:	a8 01                	test   $0x1,%al
f01047c9:	74 01                	je     f01047cc <page_fault_handler+0xe2>
f01047cb:	a4                   	movsb  %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f01047cc:	8b 43 30             	mov    0x30(%ebx),%eax
f01047cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01047d2:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f01047d5:	8b 43 38             	mov    0x38(%ebx),%eax
f01047d8:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f01047db:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01047de:	89 42 30             	mov    %eax,0x30(%edx)
		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f01047e1:	e8 32 3c 00 00       	call   f0108418 <cpunum>
f01047e6:	6b c0 74             	imul   $0x74,%eax,%eax
f01047e9:	8b 98 28 90 35 f0    	mov    -0xfca6fd8(%eax),%ebx
f01047ef:	e8 24 3c 00 00       	call   f0108418 <cpunum>
f01047f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01047f7:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f01047fd:	8b 40 64             	mov    0x64(%eax),%eax
f0104800:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = (uintptr_t)utf;
f0104803:	e8 10 3c 00 00       	call   f0108418 <cpunum>
f0104808:	6b c0 74             	imul   $0x74,%eax,%eax
f010480b:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0104811:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104814:	89 50 3c             	mov    %edx,0x3c(%eax)
		env_run(curenv);
f0104817:	e8 fc 3b 00 00       	call   f0108418 <cpunum>
f010481c:	6b c0 74             	imul   $0x74,%eax,%eax
f010481f:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0104825:	89 04 24             	mov    %eax,(%esp)
f0104828:	e8 0e f8 ff ff       	call   f010403b <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010482d:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104830:	e8 e3 3b 00 00       	call   f0108418 <cpunum>
		curenv->env_tf.tf_esp = (uintptr_t)utf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104835:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104839:	89 74 24 08          	mov    %esi,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f010483d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104844:	29 c2                	sub    %eax,%edx
f0104846:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104849:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
		curenv->env_tf.tf_esp = (uintptr_t)utf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104850:	8b 40 48             	mov    0x48(%eax),%eax
f0104853:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104857:	c7 04 24 b8 a3 10 f0 	movl   $0xf010a3b8,(%esp)
f010485e:	e8 27 fa ff ff       	call   f010428a <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104863:	89 1c 24             	mov    %ebx,(%esp)
f0104866:	e8 e7 fc ff ff       	call   f0104552 <print_trapframe>
	env_destroy(curenv);
f010486b:	e8 a8 3b 00 00       	call   f0108418 <cpunum>
f0104870:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104877:	29 c2                	sub    %eax,%edx
f0104879:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010487c:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0104883:	89 04 24             	mov    %eax,(%esp)
f0104886:	e8 f1 f6 ff ff       	call   f0103f7c <env_destroy>
}
f010488b:	83 c4 2c             	add    $0x2c,%esp
f010488e:	5b                   	pop    %ebx
f010488f:	5e                   	pop    %esi
f0104890:	5f                   	pop    %edi
f0104891:	5d                   	pop    %ebp
f0104892:	c3                   	ret    

f0104893 <divide_zero_handler>:

void divide_zero_handler(struct Trapframe *tf) {
f0104893:	55                   	push   %ebp
f0104894:	89 e5                	mov    %esp,%ebp
f0104896:	57                   	push   %edi
f0104897:	56                   	push   %esi
f0104898:	53                   	push   %ebx
f0104899:	83 ec 2c             	sub    $0x2c,%esp
f010489c:	0f 20 d3             	mov    %cr2,%ebx
	uint32_t fault_va;
	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();
	// handle kernel mode divide zero exception
	if ((tf->tf_cs & 3) == 0)
f010489f:	8b 45 08             	mov    0x8(%ebp),%eax
f01048a2:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f01048a6:	75 1c                	jne    f01048c4 <divide_zero_handler+0x31>
		panic("divide zero exception in kernel mode!");
f01048a8:	c7 44 24 08 dc a3 10 	movl   $0xf010a3dc,0x8(%esp)
f01048af:	f0 
f01048b0:	c7 44 24 04 d5 01 00 	movl   $0x1d5,0x4(%esp)
f01048b7:	00 
f01048b8:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f01048bf:	e8 7c b7 ff ff       	call   f0100040 <_panic>
	if (curenv->env_divzero_upcall) {
f01048c4:	e8 4f 3b 00 00       	call   f0108418 <cpunum>
f01048c9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01048d0:	29 c2                	sub    %eax,%edx
f01048d2:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01048d5:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f01048dc:	83 78 68 00          	cmpl   $0x0,0x68(%eax)
f01048e0:	0f 84 06 01 00 00    	je     f01049ec <divide_zero_handler+0x159>
		struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
f01048e6:	8b 55 08             	mov    0x8(%ebp),%edx
f01048e9:	8b 42 3c             	mov    0x3c(%edx),%eax
f01048ec:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
							(struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
f01048f2:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f01048f9:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01048ff:	77 06                	ja     f0104907 <divide_zero_handler+0x74>
f0104901:	83 e8 38             	sub    $0x38,%eax
f0104904:	89 45 e4             	mov    %eax,-0x1c(%ebp)
							(struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
		// this is a totally wrong statement!
		// struct UTrapframe *utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
		user_mem_assert(curenv, (void *)utf, 1, PTE_W);
f0104907:	e8 0c 3b 00 00       	call   f0108418 <cpunum>
f010490c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104913:	00 
f0104914:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010491b:	00 
f010491c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010491f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104923:	6b c0 74             	imul   $0x74,%eax,%eax
f0104926:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f010492c:	89 04 24             	mov    %eax,(%esp)
f010492f:	e8 51 ee ff ff       	call   f0103785 <user_mem_assert>
		utf->utf_fault_va = fault_va;
f0104934:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104937:	89 18                	mov    %ebx,(%eax)
		utf->utf_err = tf->tf_err;
f0104939:	8b 55 08             	mov    0x8(%ebp),%edx
f010493c:	8b 42 2c             	mov    0x2c(%edx),%eax
f010493f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104942:	89 42 04             	mov    %eax,0x4(%edx)
		utf->utf_regs = tf->tf_regs;
f0104945:	89 d7                	mov    %edx,%edi
f0104947:	83 c7 08             	add    $0x8,%edi
f010494a:	8b 75 08             	mov    0x8(%ebp),%esi
f010494d:	b8 20 00 00 00       	mov    $0x20,%eax
f0104952:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104958:	74 03                	je     f010495d <divide_zero_handler+0xca>
f010495a:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f010495b:	b0 1f                	mov    $0x1f,%al
f010495d:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104963:	74 05                	je     f010496a <divide_zero_handler+0xd7>
f0104965:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104967:	83 e8 02             	sub    $0x2,%eax
f010496a:	89 c1                	mov    %eax,%ecx
f010496c:	c1 e9 02             	shr    $0x2,%ecx
f010496f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104971:	a8 02                	test   $0x2,%al
f0104973:	74 02                	je     f0104977 <divide_zero_handler+0xe4>
f0104975:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104977:	a8 01                	test   $0x1,%al
f0104979:	74 01                	je     f010497c <divide_zero_handler+0xe9>
f010497b:	a4                   	movsb  %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f010497c:	8b 55 08             	mov    0x8(%ebp),%edx
f010497f:	8b 42 30             	mov    0x30(%edx),%eax
f0104982:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104985:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f0104988:	8b 55 08             	mov    0x8(%ebp),%edx
f010498b:	8b 42 38             	mov    0x38(%edx),%eax
f010498e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104991:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f0104994:	8b 55 08             	mov    0x8(%ebp),%edx
f0104997:	8b 42 3c             	mov    0x3c(%edx),%eax
f010499a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010499d:	89 42 30             	mov    %eax,0x30(%edx)
		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_divzero_upcall;
f01049a0:	e8 73 3a 00 00       	call   f0108418 <cpunum>
f01049a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01049a8:	8b 98 28 90 35 f0    	mov    -0xfca6fd8(%eax),%ebx
f01049ae:	e8 65 3a 00 00       	call   f0108418 <cpunum>
f01049b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01049b6:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f01049bc:	8b 40 68             	mov    0x68(%eax),%eax
f01049bf:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = (uintptr_t)utf;
f01049c2:	e8 51 3a 00 00       	call   f0108418 <cpunum>
f01049c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01049ca:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f01049d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01049d3:	89 50 3c             	mov    %edx,0x3c(%eax)
		env_run(curenv);
f01049d6:	e8 3d 3a 00 00       	call   f0108418 <cpunum>
f01049db:	6b c0 74             	imul   $0x74,%eax,%eax
f01049de:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f01049e4:	89 04 24             	mov    %eax,(%esp)
f01049e7:	e8 4f f6 ff ff       	call   f010403b <env_run>
	// Destroy the environment that caused the fault.
	//cprintf("[%08x] user fault va %08x ip %08x\n",
	//	curenv->env_id, fault_va, tf->tf_eip);
	//print_trapframe(tf);
	//env_destroy(curenv);
}
f01049ec:	83 c4 2c             	add    $0x2c,%esp
f01049ef:	5b                   	pop    %ebx
f01049f0:	5e                   	pop    %esi
f01049f1:	5f                   	pop    %edi
f01049f2:	5d                   	pop    %ebp
f01049f3:	c3                   	ret    

f01049f4 <debug_exception_handler>:

void debug_exception_handler(struct Trapframe *tf) {
f01049f4:	55                   	push   %ebp
f01049f5:	89 e5                	mov    %esp,%ebp
f01049f7:	57                   	push   %edi
f01049f8:	56                   	push   %esi
f01049f9:	53                   	push   %ebx
f01049fa:	83 ec 2c             	sub    $0x2c,%esp
f01049fd:	0f 20 d3             	mov    %cr2,%ebx
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode debug exception exception
    if ((tf->tf_cs & 3) == 0)
f0104a00:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a03:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f0104a07:	75 1c                	jne    f0104a25 <debug_exception_handler+0x31>
        panic("debug exception exception in kernel mode!");
f0104a09:	c7 44 24 08 04 a4 10 	movl   $0xf010a404,0x8(%esp)
f0104a10:	f0 
f0104a11:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
f0104a18:	00 
f0104a19:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f0104a20:	e8 1b b6 ff ff       	call   f0100040 <_panic>
    if (curenv->env_debug_upcall) {
f0104a25:	e8 ee 39 00 00       	call   f0108418 <cpunum>
f0104a2a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104a31:	29 c2                	sub    %eax,%edx
f0104a33:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104a36:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0104a3d:	83 78 6c 00          	cmpl   $0x0,0x6c(%eax)
f0104a41:	0f 84 06 01 00 00    	je     f0104b4d <debug_exception_handler+0x159>
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
f0104a47:	8b 55 08             	mov    0x8(%ebp),%edx
f0104a4a:	8b 42 3c             	mov    0x3c(%edx),%eax
f0104a4d:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
f0104a53:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f0104a5a:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104a60:	77 06                	ja     f0104a68 <debug_exception_handler+0x74>
f0104a62:	83 e8 38             	sub    $0x38,%eax
f0104a65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
f0104a68:	e8 ab 39 00 00       	call   f0108418 <cpunum>
f0104a6d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104a74:	00 
f0104a75:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104a7c:	00 
f0104a7d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104a80:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104a84:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a87:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0104a8d:	89 04 24             	mov    %eax,(%esp)
f0104a90:	e8 f0 ec ff ff       	call   f0103785 <user_mem_assert>
        utf->utf_fault_va = fault_va;
f0104a95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a98:	89 18                	mov    %ebx,(%eax)
        utf->utf_err = tf->tf_err;
f0104a9a:	8b 55 08             	mov    0x8(%ebp),%edx
f0104a9d:	8b 42 2c             	mov    0x2c(%edx),%eax
f0104aa0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104aa3:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs = tf->tf_regs;
f0104aa6:	89 d7                	mov    %edx,%edi
f0104aa8:	83 c7 08             	add    $0x8,%edi
f0104aab:	8b 75 08             	mov    0x8(%ebp),%esi
f0104aae:	b8 20 00 00 00       	mov    $0x20,%eax
f0104ab3:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104ab9:	74 03                	je     f0104abe <debug_exception_handler+0xca>
f0104abb:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0104abc:	b0 1f                	mov    $0x1f,%al
f0104abe:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104ac4:	74 05                	je     f0104acb <debug_exception_handler+0xd7>
f0104ac6:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104ac8:	83 e8 02             	sub    $0x2,%eax
f0104acb:	89 c1                	mov    %eax,%ecx
f0104acd:	c1 e9 02             	shr    $0x2,%ecx
f0104ad0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104ad2:	a8 02                	test   $0x2,%al
f0104ad4:	74 02                	je     f0104ad8 <debug_exception_handler+0xe4>
f0104ad6:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104ad8:	a8 01                	test   $0x1,%al
f0104ada:	74 01                	je     f0104add <debug_exception_handler+0xe9>
f0104adc:	a4                   	movsb  %ds:(%esi),%es:(%edi)
        utf->utf_eip = tf->tf_eip;
f0104add:	8b 55 08             	mov    0x8(%ebp),%edx
f0104ae0:	8b 42 30             	mov    0x30(%edx),%eax
f0104ae3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ae6:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_eflags = tf->tf_eflags;
f0104ae9:	8b 55 08             	mov    0x8(%ebp),%edx
f0104aec:	8b 42 38             	mov    0x38(%edx),%eax
f0104aef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104af2:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_esp = tf->tf_esp;
f0104af5:	8b 55 08             	mov    0x8(%ebp),%edx
f0104af8:	8b 42 3c             	mov    0x3c(%edx),%eax
f0104afb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104afe:	89 42 30             	mov    %eax,0x30(%edx)
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_debug_upcall;
f0104b01:	e8 12 39 00 00       	call   f0108418 <cpunum>
f0104b06:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b09:	8b 98 28 90 35 f0    	mov    -0xfca6fd8(%eax),%ebx
f0104b0f:	e8 04 39 00 00       	call   f0108418 <cpunum>
f0104b14:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b17:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0104b1d:	8b 40 6c             	mov    0x6c(%eax),%eax
f0104b20:	89 43 30             	mov    %eax,0x30(%ebx)
        curenv->env_tf.tf_esp = (uintptr_t)utf;
f0104b23:	e8 f0 38 00 00       	call   f0108418 <cpunum>
f0104b28:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b2b:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0104b31:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b34:	89 50 3c             	mov    %edx,0x3c(%eax)
        env_run(curenv);
f0104b37:	e8 dc 38 00 00       	call   f0108418 <cpunum>
f0104b3c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b3f:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0104b45:	89 04 24             	mov    %eax,(%esp)
f0104b48:	e8 ee f4 ff ff       	call   f010403b <env_run>
    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}
f0104b4d:	83 c4 2c             	add    $0x2c,%esp
f0104b50:	5b                   	pop    %ebx
f0104b51:	5e                   	pop    %esi
f0104b52:	5f                   	pop    %edi
f0104b53:	5d                   	pop    %ebp
f0104b54:	c3                   	ret    

f0104b55 <non_maskable_interrupt_handler>:

void non_maskable_interrupt_handler(struct Trapframe *tf) {
f0104b55:	55                   	push   %ebp
f0104b56:	89 e5                	mov    %esp,%ebp
f0104b58:	57                   	push   %edi
f0104b59:	56                   	push   %esi
f0104b5a:	53                   	push   %ebx
f0104b5b:	83 ec 2c             	sub    $0x2c,%esp
f0104b5e:	0f 20 d3             	mov    %cr2,%ebx
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode non_maskable interrupt exception
    if ((tf->tf_cs & 3) == 0)
f0104b61:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b64:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f0104b68:	75 1c                	jne    f0104b86 <non_maskable_interrupt_handler+0x31>
        panic("non_maskable interrupt exception in kernel mode!");
f0104b6a:	c7 44 24 08 30 a4 10 	movl   $0xf010a430,0x8(%esp)
f0104b71:	f0 
f0104b72:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
f0104b79:	00 
f0104b7a:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f0104b81:	e8 ba b4 ff ff       	call   f0100040 <_panic>
    if (curenv->env_nmskint_upcall) {
f0104b86:	e8 8d 38 00 00       	call   f0108418 <cpunum>
f0104b8b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104b92:	29 c2                	sub    %eax,%edx
f0104b94:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b97:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0104b9e:	83 78 70 00          	cmpl   $0x0,0x70(%eax)
f0104ba2:	0f 84 06 01 00 00    	je     f0104cae <non_maskable_interrupt_handler+0x159>
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
f0104ba8:	8b 55 08             	mov    0x8(%ebp),%edx
f0104bab:	8b 42 3c             	mov    0x3c(%edx),%eax
f0104bae:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
f0104bb4:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f0104bbb:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104bc1:	77 06                	ja     f0104bc9 <non_maskable_interrupt_handler+0x74>
f0104bc3:	83 e8 38             	sub    $0x38,%eax
f0104bc6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
f0104bc9:	e8 4a 38 00 00       	call   f0108418 <cpunum>
f0104bce:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104bd5:	00 
f0104bd6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104bdd:	00 
f0104bde:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104be1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104be5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104be8:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0104bee:	89 04 24             	mov    %eax,(%esp)
f0104bf1:	e8 8f eb ff ff       	call   f0103785 <user_mem_assert>
        utf->utf_fault_va = fault_va;
f0104bf6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104bf9:	89 18                	mov    %ebx,(%eax)
        utf->utf_err = tf->tf_err;
f0104bfb:	8b 55 08             	mov    0x8(%ebp),%edx
f0104bfe:	8b 42 2c             	mov    0x2c(%edx),%eax
f0104c01:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104c04:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs = tf->tf_regs;
f0104c07:	89 d7                	mov    %edx,%edi
f0104c09:	83 c7 08             	add    $0x8,%edi
f0104c0c:	8b 75 08             	mov    0x8(%ebp),%esi
f0104c0f:	b8 20 00 00 00       	mov    $0x20,%eax
f0104c14:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104c1a:	74 03                	je     f0104c1f <non_maskable_interrupt_handler+0xca>
f0104c1c:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0104c1d:	b0 1f                	mov    $0x1f,%al
f0104c1f:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104c25:	74 05                	je     f0104c2c <non_maskable_interrupt_handler+0xd7>
f0104c27:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104c29:	83 e8 02             	sub    $0x2,%eax
f0104c2c:	89 c1                	mov    %eax,%ecx
f0104c2e:	c1 e9 02             	shr    $0x2,%ecx
f0104c31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104c33:	a8 02                	test   $0x2,%al
f0104c35:	74 02                	je     f0104c39 <non_maskable_interrupt_handler+0xe4>
f0104c37:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104c39:	a8 01                	test   $0x1,%al
f0104c3b:	74 01                	je     f0104c3e <non_maskable_interrupt_handler+0xe9>
f0104c3d:	a4                   	movsb  %ds:(%esi),%es:(%edi)
        utf->utf_eip = tf->tf_eip;
f0104c3e:	8b 55 08             	mov    0x8(%ebp),%edx
f0104c41:	8b 42 30             	mov    0x30(%edx),%eax
f0104c44:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104c47:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_eflags = tf->tf_eflags;
f0104c4a:	8b 55 08             	mov    0x8(%ebp),%edx
f0104c4d:	8b 42 38             	mov    0x38(%edx),%eax
f0104c50:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104c53:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_esp = tf->tf_esp;
f0104c56:	8b 55 08             	mov    0x8(%ebp),%edx
f0104c59:	8b 42 3c             	mov    0x3c(%edx),%eax
f0104c5c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104c5f:	89 42 30             	mov    %eax,0x30(%edx)
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_nmskint_upcall;
f0104c62:	e8 b1 37 00 00       	call   f0108418 <cpunum>
f0104c67:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c6a:	8b 98 28 90 35 f0    	mov    -0xfca6fd8(%eax),%ebx
f0104c70:	e8 a3 37 00 00       	call   f0108418 <cpunum>
f0104c75:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c78:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0104c7e:	8b 40 70             	mov    0x70(%eax),%eax
f0104c81:	89 43 30             	mov    %eax,0x30(%ebx)
        curenv->env_tf.tf_esp = (uintptr_t)utf;
f0104c84:	e8 8f 37 00 00       	call   f0108418 <cpunum>
f0104c89:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c8c:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0104c92:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104c95:	89 50 3c             	mov    %edx,0x3c(%eax)
        env_run(curenv);
f0104c98:	e8 7b 37 00 00       	call   f0108418 <cpunum>
f0104c9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ca0:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0104ca6:	89 04 24             	mov    %eax,(%esp)
f0104ca9:	e8 8d f3 ff ff       	call   f010403b <env_run>
    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}
f0104cae:	83 c4 2c             	add    $0x2c,%esp
f0104cb1:	5b                   	pop    %ebx
f0104cb2:	5e                   	pop    %esi
f0104cb3:	5f                   	pop    %edi
f0104cb4:	5d                   	pop    %ebp
f0104cb5:	c3                   	ret    

f0104cb6 <breakpoint_handler>:

void breakpoint_handler(struct Trapframe *tf) {
f0104cb6:	55                   	push   %ebp
f0104cb7:	89 e5                	mov    %esp,%ebp
f0104cb9:	57                   	push   %edi
f0104cba:	56                   	push   %esi
f0104cbb:	53                   	push   %ebx
f0104cbc:	83 ec 2c             	sub    $0x2c,%esp
f0104cbf:	0f 20 d3             	mov    %cr2,%ebx
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode breakpoint exception
    if ((tf->tf_cs & 3) == 0)
f0104cc2:	8b 45 08             	mov    0x8(%ebp),%eax
f0104cc5:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f0104cc9:	75 1c                	jne    f0104ce7 <breakpoint_handler+0x31>
        panic("breakpoint exception in kernel mode!");
f0104ccb:	c7 44 24 08 64 a4 10 	movl   $0xf010a464,0x8(%esp)
f0104cd2:	f0 
f0104cd3:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
f0104cda:	00 
f0104cdb:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f0104ce2:	e8 59 b3 ff ff       	call   f0100040 <_panic>
    if (curenv->env_bpoint_upcall) {
f0104ce7:	e8 2c 37 00 00       	call   f0108418 <cpunum>
f0104cec:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104cf3:	29 c2                	sub    %eax,%edx
f0104cf5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104cf8:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0104cff:	83 78 74 00          	cmpl   $0x0,0x74(%eax)
f0104d03:	0f 84 06 01 00 00    	je     f0104e0f <breakpoint_handler+0x159>
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
f0104d09:	8b 55 08             	mov    0x8(%ebp),%edx
f0104d0c:	8b 42 3c             	mov    0x3c(%edx),%eax
f0104d0f:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
f0104d15:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f0104d1c:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104d22:	77 06                	ja     f0104d2a <breakpoint_handler+0x74>
f0104d24:	83 e8 38             	sub    $0x38,%eax
f0104d27:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
f0104d2a:	e8 e9 36 00 00       	call   f0108418 <cpunum>
f0104d2f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104d36:	00 
f0104d37:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104d3e:	00 
f0104d3f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104d42:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104d46:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d49:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0104d4f:	89 04 24             	mov    %eax,(%esp)
f0104d52:	e8 2e ea ff ff       	call   f0103785 <user_mem_assert>
        utf->utf_fault_va = fault_va;
f0104d57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d5a:	89 18                	mov    %ebx,(%eax)
        utf->utf_err = tf->tf_err;
f0104d5c:	8b 55 08             	mov    0x8(%ebp),%edx
f0104d5f:	8b 42 2c             	mov    0x2c(%edx),%eax
f0104d62:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104d65:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs = tf->tf_regs;
f0104d68:	89 d7                	mov    %edx,%edi
f0104d6a:	83 c7 08             	add    $0x8,%edi
f0104d6d:	8b 75 08             	mov    0x8(%ebp),%esi
f0104d70:	b8 20 00 00 00       	mov    $0x20,%eax
f0104d75:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104d7b:	74 03                	je     f0104d80 <breakpoint_handler+0xca>
f0104d7d:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0104d7e:	b0 1f                	mov    $0x1f,%al
f0104d80:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104d86:	74 05                	je     f0104d8d <breakpoint_handler+0xd7>
f0104d88:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104d8a:	83 e8 02             	sub    $0x2,%eax
f0104d8d:	89 c1                	mov    %eax,%ecx
f0104d8f:	c1 e9 02             	shr    $0x2,%ecx
f0104d92:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104d94:	a8 02                	test   $0x2,%al
f0104d96:	74 02                	je     f0104d9a <breakpoint_handler+0xe4>
f0104d98:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104d9a:	a8 01                	test   $0x1,%al
f0104d9c:	74 01                	je     f0104d9f <breakpoint_handler+0xe9>
f0104d9e:	a4                   	movsb  %ds:(%esi),%es:(%edi)
        utf->utf_eip = tf->tf_eip;
f0104d9f:	8b 55 08             	mov    0x8(%ebp),%edx
f0104da2:	8b 42 30             	mov    0x30(%edx),%eax
f0104da5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104da8:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_eflags = tf->tf_eflags;
f0104dab:	8b 55 08             	mov    0x8(%ebp),%edx
f0104dae:	8b 42 38             	mov    0x38(%edx),%eax
f0104db1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104db4:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_esp = tf->tf_esp;
f0104db7:	8b 55 08             	mov    0x8(%ebp),%edx
f0104dba:	8b 42 3c             	mov    0x3c(%edx),%eax
f0104dbd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104dc0:	89 42 30             	mov    %eax,0x30(%edx)
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_bpoint_upcall;
f0104dc3:	e8 50 36 00 00       	call   f0108418 <cpunum>
f0104dc8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dcb:	8b 98 28 90 35 f0    	mov    -0xfca6fd8(%eax),%ebx
f0104dd1:	e8 42 36 00 00       	call   f0108418 <cpunum>
f0104dd6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dd9:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0104ddf:	8b 40 74             	mov    0x74(%eax),%eax
f0104de2:	89 43 30             	mov    %eax,0x30(%ebx)
        curenv->env_tf.tf_esp = (uintptr_t)utf;
f0104de5:	e8 2e 36 00 00       	call   f0108418 <cpunum>
f0104dea:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ded:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0104df3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104df6:	89 50 3c             	mov    %edx,0x3c(%eax)
        env_run(curenv);
f0104df9:	e8 1a 36 00 00       	call   f0108418 <cpunum>
f0104dfe:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e01:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0104e07:	89 04 24             	mov    %eax,(%esp)
f0104e0a:	e8 2c f2 ff ff       	call   f010403b <env_run>
    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}
f0104e0f:	83 c4 2c             	add    $0x2c,%esp
f0104e12:	5b                   	pop    %ebx
f0104e13:	5e                   	pop    %esi
f0104e14:	5f                   	pop    %edi
f0104e15:	5d                   	pop    %ebp
f0104e16:	c3                   	ret    

f0104e17 <overflow_handler>:

void overflow_handler(struct Trapframe *tf) {
f0104e17:	55                   	push   %ebp
f0104e18:	89 e5                	mov    %esp,%ebp
f0104e1a:	57                   	push   %edi
f0104e1b:	56                   	push   %esi
f0104e1c:	53                   	push   %ebx
f0104e1d:	83 ec 2c             	sub    $0x2c,%esp
f0104e20:	0f 20 d3             	mov    %cr2,%ebx
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode overflow exception
    if ((tf->tf_cs & 3) == 0)
f0104e23:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e26:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f0104e2a:	75 1c                	jne    f0104e48 <overflow_handler+0x31>
        panic("overflow exception in kernel mode!");
f0104e2c:	c7 44 24 08 8c a4 10 	movl   $0xf010a48c,0x8(%esp)
f0104e33:	f0 
f0104e34:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
f0104e3b:	00 
f0104e3c:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f0104e43:	e8 f8 b1 ff ff       	call   f0100040 <_panic>
    if (curenv->env_oflow_upcall) {
f0104e48:	e8 cb 35 00 00       	call   f0108418 <cpunum>
f0104e4d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e54:	29 c2                	sub    %eax,%edx
f0104e56:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e59:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0104e60:	83 78 78 00          	cmpl   $0x0,0x78(%eax)
f0104e64:	0f 84 06 01 00 00    	je     f0104f70 <overflow_handler+0x159>
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
f0104e6a:	8b 55 08             	mov    0x8(%ebp),%edx
f0104e6d:	8b 42 3c             	mov    0x3c(%edx),%eax
f0104e70:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
f0104e76:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f0104e7d:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104e83:	77 06                	ja     f0104e8b <overflow_handler+0x74>
f0104e85:	83 e8 38             	sub    $0x38,%eax
f0104e88:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
f0104e8b:	e8 88 35 00 00       	call   f0108418 <cpunum>
f0104e90:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104e97:	00 
f0104e98:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e9f:	00 
f0104ea0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ea3:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104ea7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104eaa:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0104eb0:	89 04 24             	mov    %eax,(%esp)
f0104eb3:	e8 cd e8 ff ff       	call   f0103785 <user_mem_assert>
        utf->utf_fault_va = fault_va;
f0104eb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ebb:	89 18                	mov    %ebx,(%eax)
        utf->utf_err = tf->tf_err;
f0104ebd:	8b 55 08             	mov    0x8(%ebp),%edx
f0104ec0:	8b 42 2c             	mov    0x2c(%edx),%eax
f0104ec3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ec6:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs = tf->tf_regs;
f0104ec9:	89 d7                	mov    %edx,%edi
f0104ecb:	83 c7 08             	add    $0x8,%edi
f0104ece:	8b 75 08             	mov    0x8(%ebp),%esi
f0104ed1:	b8 20 00 00 00       	mov    $0x20,%eax
f0104ed6:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104edc:	74 03                	je     f0104ee1 <overflow_handler+0xca>
f0104ede:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0104edf:	b0 1f                	mov    $0x1f,%al
f0104ee1:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104ee7:	74 05                	je     f0104eee <overflow_handler+0xd7>
f0104ee9:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104eeb:	83 e8 02             	sub    $0x2,%eax
f0104eee:	89 c1                	mov    %eax,%ecx
f0104ef0:	c1 e9 02             	shr    $0x2,%ecx
f0104ef3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104ef5:	a8 02                	test   $0x2,%al
f0104ef7:	74 02                	je     f0104efb <overflow_handler+0xe4>
f0104ef9:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104efb:	a8 01                	test   $0x1,%al
f0104efd:	74 01                	je     f0104f00 <overflow_handler+0xe9>
f0104eff:	a4                   	movsb  %ds:(%esi),%es:(%edi)
        utf->utf_eip = tf->tf_eip;
f0104f00:	8b 55 08             	mov    0x8(%ebp),%edx
f0104f03:	8b 42 30             	mov    0x30(%edx),%eax
f0104f06:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104f09:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_eflags = tf->tf_eflags;
f0104f0c:	8b 55 08             	mov    0x8(%ebp),%edx
f0104f0f:	8b 42 38             	mov    0x38(%edx),%eax
f0104f12:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104f15:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_esp = tf->tf_esp;
f0104f18:	8b 55 08             	mov    0x8(%ebp),%edx
f0104f1b:	8b 42 3c             	mov    0x3c(%edx),%eax
f0104f1e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104f21:	89 42 30             	mov    %eax,0x30(%edx)
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_oflow_upcall;
f0104f24:	e8 ef 34 00 00       	call   f0108418 <cpunum>
f0104f29:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f2c:	8b 98 28 90 35 f0    	mov    -0xfca6fd8(%eax),%ebx
f0104f32:	e8 e1 34 00 00       	call   f0108418 <cpunum>
f0104f37:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f3a:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0104f40:	8b 40 78             	mov    0x78(%eax),%eax
f0104f43:	89 43 30             	mov    %eax,0x30(%ebx)
        curenv->env_tf.tf_esp = (uintptr_t)utf;
f0104f46:	e8 cd 34 00 00       	call   f0108418 <cpunum>
f0104f4b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f4e:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0104f54:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104f57:	89 50 3c             	mov    %edx,0x3c(%eax)
        env_run(curenv);
f0104f5a:	e8 b9 34 00 00       	call   f0108418 <cpunum>
f0104f5f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f62:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0104f68:	89 04 24             	mov    %eax,(%esp)
f0104f6b:	e8 cb f0 ff ff       	call   f010403b <env_run>
    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}
f0104f70:	83 c4 2c             	add    $0x2c,%esp
f0104f73:	5b                   	pop    %ebx
f0104f74:	5e                   	pop    %esi
f0104f75:	5f                   	pop    %edi
f0104f76:	5d                   	pop    %ebp
f0104f77:	c3                   	ret    

f0104f78 <bounds_check_handler>:

void bounds_check_handler(struct Trapframe *tf) {
f0104f78:	55                   	push   %ebp
f0104f79:	89 e5                	mov    %esp,%ebp
f0104f7b:	57                   	push   %edi
f0104f7c:	56                   	push   %esi
f0104f7d:	53                   	push   %ebx
f0104f7e:	83 ec 2c             	sub    $0x2c,%esp
f0104f81:	0f 20 d3             	mov    %cr2,%ebx
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode bounds check exception
    if ((tf->tf_cs & 3) == 0)
f0104f84:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f87:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f0104f8b:	75 1c                	jne    f0104fa9 <bounds_check_handler+0x31>
        panic("bounds check exception in kernel mode!");
f0104f8d:	c7 44 24 08 b0 a4 10 	movl   $0xf010a4b0,0x8(%esp)
f0104f94:	f0 
f0104f95:	c7 44 24 04 6d 02 00 	movl   $0x26d,0x4(%esp)
f0104f9c:	00 
f0104f9d:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f0104fa4:	e8 97 b0 ff ff       	call   f0100040 <_panic>
    if (curenv->env_bdschk_upcall) {
f0104fa9:	e8 6a 34 00 00       	call   f0108418 <cpunum>
f0104fae:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104fb5:	29 c2                	sub    %eax,%edx
f0104fb7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104fba:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0104fc1:	83 78 7c 00          	cmpl   $0x0,0x7c(%eax)
f0104fc5:	0f 84 06 01 00 00    	je     f01050d1 <bounds_check_handler+0x159>
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
f0104fcb:	8b 55 08             	mov    0x8(%ebp),%edx
f0104fce:	8b 42 3c             	mov    0x3c(%edx),%eax
f0104fd1:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
f0104fd7:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f0104fde:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104fe4:	77 06                	ja     f0104fec <bounds_check_handler+0x74>
f0104fe6:	83 e8 38             	sub    $0x38,%eax
f0104fe9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
f0104fec:	e8 27 34 00 00       	call   f0108418 <cpunum>
f0104ff1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104ff8:	00 
f0104ff9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105000:	00 
f0105001:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105004:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105008:	6b c0 74             	imul   $0x74,%eax,%eax
f010500b:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105011:	89 04 24             	mov    %eax,(%esp)
f0105014:	e8 6c e7 ff ff       	call   f0103785 <user_mem_assert>
        utf->utf_fault_va = fault_va;
f0105019:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010501c:	89 18                	mov    %ebx,(%eax)
        utf->utf_err = tf->tf_err;
f010501e:	8b 55 08             	mov    0x8(%ebp),%edx
f0105021:	8b 42 2c             	mov    0x2c(%edx),%eax
f0105024:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105027:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs = tf->tf_regs;
f010502a:	89 d7                	mov    %edx,%edi
f010502c:	83 c7 08             	add    $0x8,%edi
f010502f:	8b 75 08             	mov    0x8(%ebp),%esi
f0105032:	b8 20 00 00 00       	mov    $0x20,%eax
f0105037:	f7 c7 01 00 00 00    	test   $0x1,%edi
f010503d:	74 03                	je     f0105042 <bounds_check_handler+0xca>
f010503f:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0105040:	b0 1f                	mov    $0x1f,%al
f0105042:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0105048:	74 05                	je     f010504f <bounds_check_handler+0xd7>
f010504a:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f010504c:	83 e8 02             	sub    $0x2,%eax
f010504f:	89 c1                	mov    %eax,%ecx
f0105051:	c1 e9 02             	shr    $0x2,%ecx
f0105054:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105056:	a8 02                	test   $0x2,%al
f0105058:	74 02                	je     f010505c <bounds_check_handler+0xe4>
f010505a:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f010505c:	a8 01                	test   $0x1,%al
f010505e:	74 01                	je     f0105061 <bounds_check_handler+0xe9>
f0105060:	a4                   	movsb  %ds:(%esi),%es:(%edi)
        utf->utf_eip = tf->tf_eip;
f0105061:	8b 55 08             	mov    0x8(%ebp),%edx
f0105064:	8b 42 30             	mov    0x30(%edx),%eax
f0105067:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010506a:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_eflags = tf->tf_eflags;
f010506d:	8b 55 08             	mov    0x8(%ebp),%edx
f0105070:	8b 42 38             	mov    0x38(%edx),%eax
f0105073:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105076:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_esp = tf->tf_esp;
f0105079:	8b 55 08             	mov    0x8(%ebp),%edx
f010507c:	8b 42 3c             	mov    0x3c(%edx),%eax
f010507f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105082:	89 42 30             	mov    %eax,0x30(%edx)
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_bdschk_upcall;
f0105085:	e8 8e 33 00 00       	call   f0108418 <cpunum>
f010508a:	6b c0 74             	imul   $0x74,%eax,%eax
f010508d:	8b 98 28 90 35 f0    	mov    -0xfca6fd8(%eax),%ebx
f0105093:	e8 80 33 00 00       	call   f0108418 <cpunum>
f0105098:	6b c0 74             	imul   $0x74,%eax,%eax
f010509b:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f01050a1:	8b 40 7c             	mov    0x7c(%eax),%eax
f01050a4:	89 43 30             	mov    %eax,0x30(%ebx)
        curenv->env_tf.tf_esp = (uintptr_t)utf;
f01050a7:	e8 6c 33 00 00       	call   f0108418 <cpunum>
f01050ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01050af:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f01050b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01050b8:	89 50 3c             	mov    %edx,0x3c(%eax)
        env_run(curenv);
f01050bb:	e8 58 33 00 00       	call   f0108418 <cpunum>
f01050c0:	6b c0 74             	imul   $0x74,%eax,%eax
f01050c3:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f01050c9:	89 04 24             	mov    %eax,(%esp)
f01050cc:	e8 6a ef ff ff       	call   f010403b <env_run>
    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}
f01050d1:	83 c4 2c             	add    $0x2c,%esp
f01050d4:	5b                   	pop    %ebx
f01050d5:	5e                   	pop    %esi
f01050d6:	5f                   	pop    %edi
f01050d7:	5d                   	pop    %ebp
f01050d8:	c3                   	ret    

f01050d9 <illegal_opcode_handler>:

void illegal_opcode_handler(struct Trapframe *tf) {
f01050d9:	55                   	push   %ebp
f01050da:	89 e5                	mov    %esp,%ebp
f01050dc:	57                   	push   %edi
f01050dd:	56                   	push   %esi
f01050de:	53                   	push   %ebx
f01050df:	83 ec 2c             	sub    $0x2c,%esp
f01050e2:	0f 20 d3             	mov    %cr2,%ebx
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode illegal opcode exception
    if ((tf->tf_cs & 3) == 0)
f01050e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01050e8:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f01050ec:	75 1c                	jne    f010510a <illegal_opcode_handler+0x31>
        panic("illegal opcode exception in kernel mode!");
f01050ee:	c7 44 24 08 d8 a4 10 	movl   $0xf010a4d8,0x8(%esp)
f01050f5:	f0 
f01050f6:	c7 44 24 04 8b 02 00 	movl   $0x28b,0x4(%esp)
f01050fd:	00 
f01050fe:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f0105105:	e8 36 af ff ff       	call   f0100040 <_panic>
    if (curenv->env_illopcd_upcall) {
f010510a:	e8 09 33 00 00       	call   f0108418 <cpunum>
f010510f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105116:	29 c2                	sub    %eax,%edx
f0105118:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010511b:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0105122:	83 b8 80 00 00 00 00 	cmpl   $0x0,0x80(%eax)
f0105129:	0f 84 09 01 00 00    	je     f0105238 <illegal_opcode_handler+0x15f>
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
f010512f:	8b 55 08             	mov    0x8(%ebp),%edx
f0105132:	8b 42 3c             	mov    0x3c(%edx),%eax
f0105135:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
f010513b:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f0105142:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0105148:	77 06                	ja     f0105150 <illegal_opcode_handler+0x77>
f010514a:	83 e8 38             	sub    $0x38,%eax
f010514d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
f0105150:	e8 c3 32 00 00       	call   f0108418 <cpunum>
f0105155:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010515c:	00 
f010515d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105164:	00 
f0105165:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105168:	89 54 24 04          	mov    %edx,0x4(%esp)
f010516c:	6b c0 74             	imul   $0x74,%eax,%eax
f010516f:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105175:	89 04 24             	mov    %eax,(%esp)
f0105178:	e8 08 e6 ff ff       	call   f0103785 <user_mem_assert>
        utf->utf_fault_va = fault_va;
f010517d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105180:	89 18                	mov    %ebx,(%eax)
        utf->utf_err = tf->tf_err;
f0105182:	8b 55 08             	mov    0x8(%ebp),%edx
f0105185:	8b 42 2c             	mov    0x2c(%edx),%eax
f0105188:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010518b:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs = tf->tf_regs;
f010518e:	89 d7                	mov    %edx,%edi
f0105190:	83 c7 08             	add    $0x8,%edi
f0105193:	8b 75 08             	mov    0x8(%ebp),%esi
f0105196:	b8 20 00 00 00       	mov    $0x20,%eax
f010519b:	f7 c7 01 00 00 00    	test   $0x1,%edi
f01051a1:	74 03                	je     f01051a6 <illegal_opcode_handler+0xcd>
f01051a3:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f01051a4:	b0 1f                	mov    $0x1f,%al
f01051a6:	f7 c7 02 00 00 00    	test   $0x2,%edi
f01051ac:	74 05                	je     f01051b3 <illegal_opcode_handler+0xda>
f01051ae:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01051b0:	83 e8 02             	sub    $0x2,%eax
f01051b3:	89 c1                	mov    %eax,%ecx
f01051b5:	c1 e9 02             	shr    $0x2,%ecx
f01051b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01051ba:	a8 02                	test   $0x2,%al
f01051bc:	74 02                	je     f01051c0 <illegal_opcode_handler+0xe7>
f01051be:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01051c0:	a8 01                	test   $0x1,%al
f01051c2:	74 01                	je     f01051c5 <illegal_opcode_handler+0xec>
f01051c4:	a4                   	movsb  %ds:(%esi),%es:(%edi)
        utf->utf_eip = tf->tf_eip;
f01051c5:	8b 55 08             	mov    0x8(%ebp),%edx
f01051c8:	8b 42 30             	mov    0x30(%edx),%eax
f01051cb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01051ce:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_eflags = tf->tf_eflags;
f01051d1:	8b 55 08             	mov    0x8(%ebp),%edx
f01051d4:	8b 42 38             	mov    0x38(%edx),%eax
f01051d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01051da:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_esp = tf->tf_esp;
f01051dd:	8b 55 08             	mov    0x8(%ebp),%edx
f01051e0:	8b 42 3c             	mov    0x3c(%edx),%eax
f01051e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01051e6:	89 42 30             	mov    %eax,0x30(%edx)
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_illopcd_upcall;
f01051e9:	e8 2a 32 00 00       	call   f0108418 <cpunum>
f01051ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01051f1:	8b 98 28 90 35 f0    	mov    -0xfca6fd8(%eax),%ebx
f01051f7:	e8 1c 32 00 00       	call   f0108418 <cpunum>
f01051fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01051ff:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105205:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
f010520b:	89 43 30             	mov    %eax,0x30(%ebx)
        curenv->env_tf.tf_esp = (uintptr_t)utf;
f010520e:	e8 05 32 00 00       	call   f0108418 <cpunum>
f0105213:	6b c0 74             	imul   $0x74,%eax,%eax
f0105216:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f010521c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010521f:	89 50 3c             	mov    %edx,0x3c(%eax)
        env_run(curenv);
f0105222:	e8 f1 31 00 00       	call   f0108418 <cpunum>
f0105227:	6b c0 74             	imul   $0x74,%eax,%eax
f010522a:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105230:	89 04 24             	mov    %eax,(%esp)
f0105233:	e8 03 ee ff ff       	call   f010403b <env_run>
    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}
f0105238:	83 c4 2c             	add    $0x2c,%esp
f010523b:	5b                   	pop    %ebx
f010523c:	5e                   	pop    %esi
f010523d:	5f                   	pop    %edi
f010523e:	5d                   	pop    %ebp
f010523f:	c3                   	ret    

f0105240 <device_not_available_handler>:

void device_not_available_handler(struct Trapframe *tf) {
f0105240:	55                   	push   %ebp
f0105241:	89 e5                	mov    %esp,%ebp
f0105243:	57                   	push   %edi
f0105244:	56                   	push   %esi
f0105245:	53                   	push   %ebx
f0105246:	83 ec 2c             	sub    $0x2c,%esp
f0105249:	0f 20 d3             	mov    %cr2,%ebx
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode device not available exception
    if ((tf->tf_cs & 3) == 0)
f010524c:	8b 45 08             	mov    0x8(%ebp),%eax
f010524f:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f0105253:	75 1c                	jne    f0105271 <device_not_available_handler+0x31>
        panic("device not available exception in kernel mode!");
f0105255:	c7 44 24 08 04 a5 10 	movl   $0xf010a504,0x8(%esp)
f010525c:	f0 
f010525d:	c7 44 24 04 a9 02 00 	movl   $0x2a9,0x4(%esp)
f0105264:	00 
f0105265:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f010526c:	e8 cf ad ff ff       	call   f0100040 <_panic>
    if (curenv->env_dvcntavl_upcall) {
f0105271:	e8 a2 31 00 00       	call   f0108418 <cpunum>
f0105276:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010527d:	29 c2                	sub    %eax,%edx
f010527f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105282:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0105289:	83 b8 84 00 00 00 00 	cmpl   $0x0,0x84(%eax)
f0105290:	0f 84 09 01 00 00    	je     f010539f <device_not_available_handler+0x15f>
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
f0105296:	8b 55 08             	mov    0x8(%ebp),%edx
f0105299:	8b 42 3c             	mov    0x3c(%edx),%eax
f010529c:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
f01052a2:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f01052a9:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01052af:	77 06                	ja     f01052b7 <device_not_available_handler+0x77>
f01052b1:	83 e8 38             	sub    $0x38,%eax
f01052b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
f01052b7:	e8 5c 31 00 00       	call   f0108418 <cpunum>
f01052bc:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01052c3:	00 
f01052c4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01052cb:	00 
f01052cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01052cf:	89 54 24 04          	mov    %edx,0x4(%esp)
f01052d3:	6b c0 74             	imul   $0x74,%eax,%eax
f01052d6:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f01052dc:	89 04 24             	mov    %eax,(%esp)
f01052df:	e8 a1 e4 ff ff       	call   f0103785 <user_mem_assert>
        utf->utf_fault_va = fault_va;
f01052e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052e7:	89 18                	mov    %ebx,(%eax)
        utf->utf_err = tf->tf_err;
f01052e9:	8b 55 08             	mov    0x8(%ebp),%edx
f01052ec:	8b 42 2c             	mov    0x2c(%edx),%eax
f01052ef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01052f2:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs = tf->tf_regs;
f01052f5:	89 d7                	mov    %edx,%edi
f01052f7:	83 c7 08             	add    $0x8,%edi
f01052fa:	8b 75 08             	mov    0x8(%ebp),%esi
f01052fd:	b8 20 00 00 00       	mov    $0x20,%eax
f0105302:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0105308:	74 03                	je     f010530d <device_not_available_handler+0xcd>
f010530a:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f010530b:	b0 1f                	mov    $0x1f,%al
f010530d:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0105313:	74 05                	je     f010531a <device_not_available_handler+0xda>
f0105315:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0105317:	83 e8 02             	sub    $0x2,%eax
f010531a:	89 c1                	mov    %eax,%ecx
f010531c:	c1 e9 02             	shr    $0x2,%ecx
f010531f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105321:	a8 02                	test   $0x2,%al
f0105323:	74 02                	je     f0105327 <device_not_available_handler+0xe7>
f0105325:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0105327:	a8 01                	test   $0x1,%al
f0105329:	74 01                	je     f010532c <device_not_available_handler+0xec>
f010532b:	a4                   	movsb  %ds:(%esi),%es:(%edi)
        utf->utf_eip = tf->tf_eip;
f010532c:	8b 55 08             	mov    0x8(%ebp),%edx
f010532f:	8b 42 30             	mov    0x30(%edx),%eax
f0105332:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105335:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_eflags = tf->tf_eflags;
f0105338:	8b 55 08             	mov    0x8(%ebp),%edx
f010533b:	8b 42 38             	mov    0x38(%edx),%eax
f010533e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105341:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_esp = tf->tf_esp;
f0105344:	8b 55 08             	mov    0x8(%ebp),%edx
f0105347:	8b 42 3c             	mov    0x3c(%edx),%eax
f010534a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010534d:	89 42 30             	mov    %eax,0x30(%edx)
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_dvcntavl_upcall;
f0105350:	e8 c3 30 00 00       	call   f0108418 <cpunum>
f0105355:	6b c0 74             	imul   $0x74,%eax,%eax
f0105358:	8b 98 28 90 35 f0    	mov    -0xfca6fd8(%eax),%ebx
f010535e:	e8 b5 30 00 00       	call   f0108418 <cpunum>
f0105363:	6b c0 74             	imul   $0x74,%eax,%eax
f0105366:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f010536c:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
f0105372:	89 43 30             	mov    %eax,0x30(%ebx)
        curenv->env_tf.tf_esp = (uintptr_t)utf;
f0105375:	e8 9e 30 00 00       	call   f0108418 <cpunum>
f010537a:	6b c0 74             	imul   $0x74,%eax,%eax
f010537d:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105383:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105386:	89 50 3c             	mov    %edx,0x3c(%eax)
        env_run(curenv);
f0105389:	e8 8a 30 00 00       	call   f0108418 <cpunum>
f010538e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105391:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105397:	89 04 24             	mov    %eax,(%esp)
f010539a:	e8 9c ec ff ff       	call   f010403b <env_run>
    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}
f010539f:	83 c4 2c             	add    $0x2c,%esp
f01053a2:	5b                   	pop    %ebx
f01053a3:	5e                   	pop    %esi
f01053a4:	5f                   	pop    %edi
f01053a5:	5d                   	pop    %ebp
f01053a6:	c3                   	ret    

f01053a7 <double_fault_handler>:

void double_fault_handler(struct Trapframe *tf) {
f01053a7:	55                   	push   %ebp
f01053a8:	89 e5                	mov    %esp,%ebp
f01053aa:	57                   	push   %edi
f01053ab:	56                   	push   %esi
f01053ac:	53                   	push   %ebx
f01053ad:	83 ec 2c             	sub    $0x2c,%esp
f01053b0:	0f 20 d3             	mov    %cr2,%ebx
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode double fault exception
    if ((tf->tf_cs & 3) == 0)
f01053b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01053b6:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f01053ba:	75 1c                	jne    f01053d8 <double_fault_handler+0x31>
        panic("double fault exception in kernel mode!");
f01053bc:	c7 44 24 08 34 a5 10 	movl   $0xf010a534,0x8(%esp)
f01053c3:	f0 
f01053c4:	c7 44 24 04 c7 02 00 	movl   $0x2c7,0x4(%esp)
f01053cb:	00 
f01053cc:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f01053d3:	e8 68 ac ff ff       	call   f0100040 <_panic>
    if (curenv->env_dbfault_upcall) {
f01053d8:	e8 3b 30 00 00       	call   f0108418 <cpunum>
f01053dd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01053e4:	29 c2                	sub    %eax,%edx
f01053e6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01053e9:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f01053f0:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
f01053f7:	0f 84 09 01 00 00    	je     f0105506 <double_fault_handler+0x15f>
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
f01053fd:	8b 55 08             	mov    0x8(%ebp),%edx
f0105400:	8b 42 3c             	mov    0x3c(%edx),%eax
f0105403:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
f0105409:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f0105410:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0105416:	77 06                	ja     f010541e <double_fault_handler+0x77>
f0105418:	83 e8 38             	sub    $0x38,%eax
f010541b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
f010541e:	e8 f5 2f 00 00       	call   f0108418 <cpunum>
f0105423:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010542a:	00 
f010542b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105432:	00 
f0105433:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105436:	89 54 24 04          	mov    %edx,0x4(%esp)
f010543a:	6b c0 74             	imul   $0x74,%eax,%eax
f010543d:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105443:	89 04 24             	mov    %eax,(%esp)
f0105446:	e8 3a e3 ff ff       	call   f0103785 <user_mem_assert>
        utf->utf_fault_va = fault_va;
f010544b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010544e:	89 18                	mov    %ebx,(%eax)
        utf->utf_err = tf->tf_err;
f0105450:	8b 55 08             	mov    0x8(%ebp),%edx
f0105453:	8b 42 2c             	mov    0x2c(%edx),%eax
f0105456:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105459:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs = tf->tf_regs;
f010545c:	89 d7                	mov    %edx,%edi
f010545e:	83 c7 08             	add    $0x8,%edi
f0105461:	8b 75 08             	mov    0x8(%ebp),%esi
f0105464:	b8 20 00 00 00       	mov    $0x20,%eax
f0105469:	f7 c7 01 00 00 00    	test   $0x1,%edi
f010546f:	74 03                	je     f0105474 <double_fault_handler+0xcd>
f0105471:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0105472:	b0 1f                	mov    $0x1f,%al
f0105474:	f7 c7 02 00 00 00    	test   $0x2,%edi
f010547a:	74 05                	je     f0105481 <double_fault_handler+0xda>
f010547c:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f010547e:	83 e8 02             	sub    $0x2,%eax
f0105481:	89 c1                	mov    %eax,%ecx
f0105483:	c1 e9 02             	shr    $0x2,%ecx
f0105486:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105488:	a8 02                	test   $0x2,%al
f010548a:	74 02                	je     f010548e <double_fault_handler+0xe7>
f010548c:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f010548e:	a8 01                	test   $0x1,%al
f0105490:	74 01                	je     f0105493 <double_fault_handler+0xec>
f0105492:	a4                   	movsb  %ds:(%esi),%es:(%edi)
        utf->utf_eip = tf->tf_eip;
f0105493:	8b 55 08             	mov    0x8(%ebp),%edx
f0105496:	8b 42 30             	mov    0x30(%edx),%eax
f0105499:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010549c:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_eflags = tf->tf_eflags;
f010549f:	8b 55 08             	mov    0x8(%ebp),%edx
f01054a2:	8b 42 38             	mov    0x38(%edx),%eax
f01054a5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01054a8:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_esp = tf->tf_esp;
f01054ab:	8b 55 08             	mov    0x8(%ebp),%edx
f01054ae:	8b 42 3c             	mov    0x3c(%edx),%eax
f01054b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01054b4:	89 42 30             	mov    %eax,0x30(%edx)
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_dbfault_upcall;
f01054b7:	e8 5c 2f 00 00       	call   f0108418 <cpunum>
f01054bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01054bf:	8b 98 28 90 35 f0    	mov    -0xfca6fd8(%eax),%ebx
f01054c5:	e8 4e 2f 00 00       	call   f0108418 <cpunum>
f01054ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01054cd:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f01054d3:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
f01054d9:	89 43 30             	mov    %eax,0x30(%ebx)
        curenv->env_tf.tf_esp = (uintptr_t)utf;
f01054dc:	e8 37 2f 00 00       	call   f0108418 <cpunum>
f01054e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01054e4:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f01054ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01054ed:	89 50 3c             	mov    %edx,0x3c(%eax)
        env_run(curenv);
f01054f0:	e8 23 2f 00 00       	call   f0108418 <cpunum>
f01054f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01054f8:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f01054fe:	89 04 24             	mov    %eax,(%esp)
f0105501:	e8 35 eb ff ff       	call   f010403b <env_run>
    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}
f0105506:	83 c4 2c             	add    $0x2c,%esp
f0105509:	5b                   	pop    %ebx
f010550a:	5e                   	pop    %esi
f010550b:	5f                   	pop    %edi
f010550c:	5d                   	pop    %ebp
f010550d:	c3                   	ret    

f010550e <invalid_task_switch_segment_handler>:

void invalid_task_switch_segment_handler(struct Trapframe *tf) {
f010550e:	55                   	push   %ebp
f010550f:	89 e5                	mov    %esp,%ebp
f0105511:	57                   	push   %edi
f0105512:	56                   	push   %esi
f0105513:	53                   	push   %ebx
f0105514:	83 ec 2c             	sub    $0x2c,%esp
f0105517:	0f 20 d3             	mov    %cr2,%ebx
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode invalid task switch segment exception
    if ((tf->tf_cs & 3) == 0)
f010551a:	8b 45 08             	mov    0x8(%ebp),%eax
f010551d:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f0105521:	75 1c                	jne    f010553f <invalid_task_switch_segment_handler+0x31>
        panic("invalid task switch segment exception in kernel mode!");
f0105523:	c7 44 24 08 5c a5 10 	movl   $0xf010a55c,0x8(%esp)
f010552a:	f0 
f010552b:	c7 44 24 04 e5 02 00 	movl   $0x2e5,0x4(%esp)
f0105532:	00 
f0105533:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f010553a:	e8 01 ab ff ff       	call   f0100040 <_panic>
    if (curenv->env_ivldtss_upcall) {
f010553f:	e8 d4 2e 00 00       	call   f0108418 <cpunum>
f0105544:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010554b:	29 c2                	sub    %eax,%edx
f010554d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105550:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0105557:	83 b8 8c 00 00 00 00 	cmpl   $0x0,0x8c(%eax)
f010555e:	0f 84 09 01 00 00    	je     f010566d <invalid_task_switch_segment_handler+0x15f>
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
f0105564:	8b 55 08             	mov    0x8(%ebp),%edx
f0105567:	8b 42 3c             	mov    0x3c(%edx),%eax
f010556a:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
f0105570:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f0105577:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010557d:	77 06                	ja     f0105585 <invalid_task_switch_segment_handler+0x77>
f010557f:	83 e8 38             	sub    $0x38,%eax
f0105582:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
f0105585:	e8 8e 2e 00 00       	call   f0108418 <cpunum>
f010558a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0105591:	00 
f0105592:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105599:	00 
f010559a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010559d:	89 54 24 04          	mov    %edx,0x4(%esp)
f01055a1:	6b c0 74             	imul   $0x74,%eax,%eax
f01055a4:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f01055aa:	89 04 24             	mov    %eax,(%esp)
f01055ad:	e8 d3 e1 ff ff       	call   f0103785 <user_mem_assert>
        utf->utf_fault_va = fault_va;
f01055b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01055b5:	89 18                	mov    %ebx,(%eax)
        utf->utf_err = tf->tf_err;
f01055b7:	8b 55 08             	mov    0x8(%ebp),%edx
f01055ba:	8b 42 2c             	mov    0x2c(%edx),%eax
f01055bd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01055c0:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs = tf->tf_regs;
f01055c3:	89 d7                	mov    %edx,%edi
f01055c5:	83 c7 08             	add    $0x8,%edi
f01055c8:	8b 75 08             	mov    0x8(%ebp),%esi
f01055cb:	b8 20 00 00 00       	mov    $0x20,%eax
f01055d0:	f7 c7 01 00 00 00    	test   $0x1,%edi
f01055d6:	74 03                	je     f01055db <invalid_task_switch_segment_handler+0xcd>
f01055d8:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f01055d9:	b0 1f                	mov    $0x1f,%al
f01055db:	f7 c7 02 00 00 00    	test   $0x2,%edi
f01055e1:	74 05                	je     f01055e8 <invalid_task_switch_segment_handler+0xda>
f01055e3:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01055e5:	83 e8 02             	sub    $0x2,%eax
f01055e8:	89 c1                	mov    %eax,%ecx
f01055ea:	c1 e9 02             	shr    $0x2,%ecx
f01055ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01055ef:	a8 02                	test   $0x2,%al
f01055f1:	74 02                	je     f01055f5 <invalid_task_switch_segment_handler+0xe7>
f01055f3:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01055f5:	a8 01                	test   $0x1,%al
f01055f7:	74 01                	je     f01055fa <invalid_task_switch_segment_handler+0xec>
f01055f9:	a4                   	movsb  %ds:(%esi),%es:(%edi)
        utf->utf_eip = tf->tf_eip;
f01055fa:	8b 55 08             	mov    0x8(%ebp),%edx
f01055fd:	8b 42 30             	mov    0x30(%edx),%eax
f0105600:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105603:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_eflags = tf->tf_eflags;
f0105606:	8b 55 08             	mov    0x8(%ebp),%edx
f0105609:	8b 42 38             	mov    0x38(%edx),%eax
f010560c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010560f:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_esp = tf->tf_esp;
f0105612:	8b 55 08             	mov    0x8(%ebp),%edx
f0105615:	8b 42 3c             	mov    0x3c(%edx),%eax
f0105618:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010561b:	89 42 30             	mov    %eax,0x30(%edx)
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_ivldtss_upcall;
f010561e:	e8 f5 2d 00 00       	call   f0108418 <cpunum>
f0105623:	6b c0 74             	imul   $0x74,%eax,%eax
f0105626:	8b 98 28 90 35 f0    	mov    -0xfca6fd8(%eax),%ebx
f010562c:	e8 e7 2d 00 00       	call   f0108418 <cpunum>
f0105631:	6b c0 74             	imul   $0x74,%eax,%eax
f0105634:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f010563a:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
f0105640:	89 43 30             	mov    %eax,0x30(%ebx)
        curenv->env_tf.tf_esp = (uintptr_t)utf;
f0105643:	e8 d0 2d 00 00       	call   f0108418 <cpunum>
f0105648:	6b c0 74             	imul   $0x74,%eax,%eax
f010564b:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105651:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105654:	89 50 3c             	mov    %edx,0x3c(%eax)
        env_run(curenv);
f0105657:	e8 bc 2d 00 00       	call   f0108418 <cpunum>
f010565c:	6b c0 74             	imul   $0x74,%eax,%eax
f010565f:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105665:	89 04 24             	mov    %eax,(%esp)
f0105668:	e8 ce e9 ff ff       	call   f010403b <env_run>
    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}
f010566d:	83 c4 2c             	add    $0x2c,%esp
f0105670:	5b                   	pop    %ebx
f0105671:	5e                   	pop    %esi
f0105672:	5f                   	pop    %edi
f0105673:	5d                   	pop    %ebp
f0105674:	c3                   	ret    

f0105675 <segment_not_present_handler>:

void segment_not_present_handler(struct Trapframe *tf) {
f0105675:	55                   	push   %ebp
f0105676:	89 e5                	mov    %esp,%ebp
f0105678:	57                   	push   %edi
f0105679:	56                   	push   %esi
f010567a:	53                   	push   %ebx
f010567b:	83 ec 2c             	sub    $0x2c,%esp
f010567e:	0f 20 d3             	mov    %cr2,%ebx
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode segment not present exception
    if ((tf->tf_cs & 3) == 0)
f0105681:	8b 45 08             	mov    0x8(%ebp),%eax
f0105684:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f0105688:	75 1c                	jne    f01056a6 <segment_not_present_handler+0x31>
        panic("segment not present exception in kernel mode!");
f010568a:	c7 44 24 08 94 a5 10 	movl   $0xf010a594,0x8(%esp)
f0105691:	f0 
f0105692:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f0105699:	00 
f010569a:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f01056a1:	e8 9a a9 ff ff       	call   f0100040 <_panic>
    if (curenv->env_segntprst_upcall) {
f01056a6:	e8 6d 2d 00 00       	call   f0108418 <cpunum>
f01056ab:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01056b2:	29 c2                	sub    %eax,%edx
f01056b4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01056b7:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f01056be:	83 b8 90 00 00 00 00 	cmpl   $0x0,0x90(%eax)
f01056c5:	0f 84 09 01 00 00    	je     f01057d4 <segment_not_present_handler+0x15f>
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
f01056cb:	8b 55 08             	mov    0x8(%ebp),%edx
f01056ce:	8b 42 3c             	mov    0x3c(%edx),%eax
f01056d1:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
f01056d7:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f01056de:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01056e4:	77 06                	ja     f01056ec <segment_not_present_handler+0x77>
f01056e6:	83 e8 38             	sub    $0x38,%eax
f01056e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
f01056ec:	e8 27 2d 00 00       	call   f0108418 <cpunum>
f01056f1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01056f8:	00 
f01056f9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105700:	00 
f0105701:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105704:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105708:	6b c0 74             	imul   $0x74,%eax,%eax
f010570b:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105711:	89 04 24             	mov    %eax,(%esp)
f0105714:	e8 6c e0 ff ff       	call   f0103785 <user_mem_assert>
        utf->utf_fault_va = fault_va;
f0105719:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010571c:	89 18                	mov    %ebx,(%eax)
        utf->utf_err = tf->tf_err;
f010571e:	8b 55 08             	mov    0x8(%ebp),%edx
f0105721:	8b 42 2c             	mov    0x2c(%edx),%eax
f0105724:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105727:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs = tf->tf_regs;
f010572a:	89 d7                	mov    %edx,%edi
f010572c:	83 c7 08             	add    $0x8,%edi
f010572f:	8b 75 08             	mov    0x8(%ebp),%esi
f0105732:	b8 20 00 00 00       	mov    $0x20,%eax
f0105737:	f7 c7 01 00 00 00    	test   $0x1,%edi
f010573d:	74 03                	je     f0105742 <segment_not_present_handler+0xcd>
f010573f:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0105740:	b0 1f                	mov    $0x1f,%al
f0105742:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0105748:	74 05                	je     f010574f <segment_not_present_handler+0xda>
f010574a:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f010574c:	83 e8 02             	sub    $0x2,%eax
f010574f:	89 c1                	mov    %eax,%ecx
f0105751:	c1 e9 02             	shr    $0x2,%ecx
f0105754:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105756:	a8 02                	test   $0x2,%al
f0105758:	74 02                	je     f010575c <segment_not_present_handler+0xe7>
f010575a:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f010575c:	a8 01                	test   $0x1,%al
f010575e:	74 01                	je     f0105761 <segment_not_present_handler+0xec>
f0105760:	a4                   	movsb  %ds:(%esi),%es:(%edi)
        utf->utf_eip = tf->tf_eip;
f0105761:	8b 55 08             	mov    0x8(%ebp),%edx
f0105764:	8b 42 30             	mov    0x30(%edx),%eax
f0105767:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010576a:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_eflags = tf->tf_eflags;
f010576d:	8b 55 08             	mov    0x8(%ebp),%edx
f0105770:	8b 42 38             	mov    0x38(%edx),%eax
f0105773:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105776:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_esp = tf->tf_esp;
f0105779:	8b 55 08             	mov    0x8(%ebp),%edx
f010577c:	8b 42 3c             	mov    0x3c(%edx),%eax
f010577f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105782:	89 42 30             	mov    %eax,0x30(%edx)
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_segntprst_upcall;
f0105785:	e8 8e 2c 00 00       	call   f0108418 <cpunum>
f010578a:	6b c0 74             	imul   $0x74,%eax,%eax
f010578d:	8b 98 28 90 35 f0    	mov    -0xfca6fd8(%eax),%ebx
f0105793:	e8 80 2c 00 00       	call   f0108418 <cpunum>
f0105798:	6b c0 74             	imul   $0x74,%eax,%eax
f010579b:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f01057a1:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
f01057a7:	89 43 30             	mov    %eax,0x30(%ebx)
        curenv->env_tf.tf_esp = (uintptr_t)utf;
f01057aa:	e8 69 2c 00 00       	call   f0108418 <cpunum>
f01057af:	6b c0 74             	imul   $0x74,%eax,%eax
f01057b2:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f01057b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01057bb:	89 50 3c             	mov    %edx,0x3c(%eax)
        env_run(curenv);
f01057be:	e8 55 2c 00 00       	call   f0108418 <cpunum>
f01057c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01057c6:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f01057cc:	89 04 24             	mov    %eax,(%esp)
f01057cf:	e8 67 e8 ff ff       	call   f010403b <env_run>
    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}
f01057d4:	83 c4 2c             	add    $0x2c,%esp
f01057d7:	5b                   	pop    %ebx
f01057d8:	5e                   	pop    %esi
f01057d9:	5f                   	pop    %edi
f01057da:	5d                   	pop    %ebp
f01057db:	c3                   	ret    

f01057dc <stack_exception_handler>:

void stack_exception_handler(struct Trapframe *tf) {
f01057dc:	55                   	push   %ebp
f01057dd:	89 e5                	mov    %esp,%ebp
f01057df:	57                   	push   %edi
f01057e0:	56                   	push   %esi
f01057e1:	53                   	push   %ebx
f01057e2:	83 ec 2c             	sub    $0x2c,%esp
f01057e5:	0f 20 d3             	mov    %cr2,%ebx
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode stack exception exception
    if ((tf->tf_cs & 3) == 0)
f01057e8:	8b 45 08             	mov    0x8(%ebp),%eax
f01057eb:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f01057ef:	75 1c                	jne    f010580d <stack_exception_handler+0x31>
        panic("stack exception exception in kernel mode!");
f01057f1:	c7 44 24 08 c4 a5 10 	movl   $0xf010a5c4,0x8(%esp)
f01057f8:	f0 
f01057f9:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f0105800:	00 
f0105801:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f0105808:	e8 33 a8 ff ff       	call   f0100040 <_panic>
    if (curenv->env_stkexception_upcall) {
f010580d:	e8 06 2c 00 00       	call   f0108418 <cpunum>
f0105812:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105819:	29 c2                	sub    %eax,%edx
f010581b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010581e:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0105825:	83 b8 94 00 00 00 00 	cmpl   $0x0,0x94(%eax)
f010582c:	0f 84 09 01 00 00    	je     f010593b <stack_exception_handler+0x15f>
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
f0105832:	8b 55 08             	mov    0x8(%ebp),%edx
f0105835:	8b 42 3c             	mov    0x3c(%edx),%eax
f0105838:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
f010583e:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f0105845:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010584b:	77 06                	ja     f0105853 <stack_exception_handler+0x77>
f010584d:	83 e8 38             	sub    $0x38,%eax
f0105850:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
f0105853:	e8 c0 2b 00 00       	call   f0108418 <cpunum>
f0105858:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010585f:	00 
f0105860:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105867:	00 
f0105868:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010586b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010586f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105872:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105878:	89 04 24             	mov    %eax,(%esp)
f010587b:	e8 05 df ff ff       	call   f0103785 <user_mem_assert>
        utf->utf_fault_va = fault_va;
f0105880:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105883:	89 18                	mov    %ebx,(%eax)
        utf->utf_err = tf->tf_err;
f0105885:	8b 55 08             	mov    0x8(%ebp),%edx
f0105888:	8b 42 2c             	mov    0x2c(%edx),%eax
f010588b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010588e:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs = tf->tf_regs;
f0105891:	89 d7                	mov    %edx,%edi
f0105893:	83 c7 08             	add    $0x8,%edi
f0105896:	8b 75 08             	mov    0x8(%ebp),%esi
f0105899:	b8 20 00 00 00       	mov    $0x20,%eax
f010589e:	f7 c7 01 00 00 00    	test   $0x1,%edi
f01058a4:	74 03                	je     f01058a9 <stack_exception_handler+0xcd>
f01058a6:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f01058a7:	b0 1f                	mov    $0x1f,%al
f01058a9:	f7 c7 02 00 00 00    	test   $0x2,%edi
f01058af:	74 05                	je     f01058b6 <stack_exception_handler+0xda>
f01058b1:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01058b3:	83 e8 02             	sub    $0x2,%eax
f01058b6:	89 c1                	mov    %eax,%ecx
f01058b8:	c1 e9 02             	shr    $0x2,%ecx
f01058bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01058bd:	a8 02                	test   $0x2,%al
f01058bf:	74 02                	je     f01058c3 <stack_exception_handler+0xe7>
f01058c1:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01058c3:	a8 01                	test   $0x1,%al
f01058c5:	74 01                	je     f01058c8 <stack_exception_handler+0xec>
f01058c7:	a4                   	movsb  %ds:(%esi),%es:(%edi)
        utf->utf_eip = tf->tf_eip;
f01058c8:	8b 55 08             	mov    0x8(%ebp),%edx
f01058cb:	8b 42 30             	mov    0x30(%edx),%eax
f01058ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01058d1:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_eflags = tf->tf_eflags;
f01058d4:	8b 55 08             	mov    0x8(%ebp),%edx
f01058d7:	8b 42 38             	mov    0x38(%edx),%eax
f01058da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01058dd:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_esp = tf->tf_esp;
f01058e0:	8b 55 08             	mov    0x8(%ebp),%edx
f01058e3:	8b 42 3c             	mov    0x3c(%edx),%eax
f01058e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01058e9:	89 42 30             	mov    %eax,0x30(%edx)
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_stkexception_upcall;
f01058ec:	e8 27 2b 00 00       	call   f0108418 <cpunum>
f01058f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01058f4:	8b 98 28 90 35 f0    	mov    -0xfca6fd8(%eax),%ebx
f01058fa:	e8 19 2b 00 00       	call   f0108418 <cpunum>
f01058ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0105902:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105908:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
f010590e:	89 43 30             	mov    %eax,0x30(%ebx)
        curenv->env_tf.tf_esp = (uintptr_t)utf;
f0105911:	e8 02 2b 00 00       	call   f0108418 <cpunum>
f0105916:	6b c0 74             	imul   $0x74,%eax,%eax
f0105919:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f010591f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105922:	89 50 3c             	mov    %edx,0x3c(%eax)
        env_run(curenv);
f0105925:	e8 ee 2a 00 00       	call   f0108418 <cpunum>
f010592a:	6b c0 74             	imul   $0x74,%eax,%eax
f010592d:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105933:	89 04 24             	mov    %eax,(%esp)
f0105936:	e8 00 e7 ff ff       	call   f010403b <env_run>
    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}
f010593b:	83 c4 2c             	add    $0x2c,%esp
f010593e:	5b                   	pop    %ebx
f010593f:	5e                   	pop    %esi
f0105940:	5f                   	pop    %edi
f0105941:	5d                   	pop    %ebp
f0105942:	c3                   	ret    

f0105943 <general_protection_fault_handler>:

void general_protection_fault_handler(struct Trapframe *tf) {
f0105943:	55                   	push   %ebp
f0105944:	89 e5                	mov    %esp,%ebp
f0105946:	57                   	push   %edi
f0105947:	56                   	push   %esi
f0105948:	53                   	push   %ebx
f0105949:	83 ec 2c             	sub    $0x2c,%esp
f010594c:	0f 20 d3             	mov    %cr2,%ebx
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode general protection fault exception
    if ((tf->tf_cs & 3) == 0)
f010594f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105952:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f0105956:	75 1c                	jne    f0105974 <general_protection_fault_handler+0x31>
        panic("general protection fault exception in kernel mode!");
f0105958:	c7 44 24 08 f0 a5 10 	movl   $0xf010a5f0,0x8(%esp)
f010595f:	f0 
f0105960:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f0105967:	00 
f0105968:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f010596f:	e8 cc a6 ff ff       	call   f0100040 <_panic>
    if (curenv->env_gpfault_upcall) {
f0105974:	e8 9f 2a 00 00       	call   f0108418 <cpunum>
f0105979:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105980:	29 c2                	sub    %eax,%edx
f0105982:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105985:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f010598c:	83 b8 98 00 00 00 00 	cmpl   $0x0,0x98(%eax)
f0105993:	0f 84 09 01 00 00    	je     f0105aa2 <general_protection_fault_handler+0x15f>
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
f0105999:	8b 55 08             	mov    0x8(%ebp),%edx
f010599c:	8b 42 3c             	mov    0x3c(%edx),%eax
f010599f:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
f01059a5:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f01059ac:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01059b2:	77 06                	ja     f01059ba <general_protection_fault_handler+0x77>
f01059b4:	83 e8 38             	sub    $0x38,%eax
f01059b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
f01059ba:	e8 59 2a 00 00       	call   f0108418 <cpunum>
f01059bf:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01059c6:	00 
f01059c7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01059ce:	00 
f01059cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01059d2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01059d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01059d9:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f01059df:	89 04 24             	mov    %eax,(%esp)
f01059e2:	e8 9e dd ff ff       	call   f0103785 <user_mem_assert>
        utf->utf_fault_va = fault_va;
f01059e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01059ea:	89 18                	mov    %ebx,(%eax)
        utf->utf_err = tf->tf_err;
f01059ec:	8b 55 08             	mov    0x8(%ebp),%edx
f01059ef:	8b 42 2c             	mov    0x2c(%edx),%eax
f01059f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01059f5:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs = tf->tf_regs;
f01059f8:	89 d7                	mov    %edx,%edi
f01059fa:	83 c7 08             	add    $0x8,%edi
f01059fd:	8b 75 08             	mov    0x8(%ebp),%esi
f0105a00:	b8 20 00 00 00       	mov    $0x20,%eax
f0105a05:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0105a0b:	74 03                	je     f0105a10 <general_protection_fault_handler+0xcd>
f0105a0d:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0105a0e:	b0 1f                	mov    $0x1f,%al
f0105a10:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0105a16:	74 05                	je     f0105a1d <general_protection_fault_handler+0xda>
f0105a18:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0105a1a:	83 e8 02             	sub    $0x2,%eax
f0105a1d:	89 c1                	mov    %eax,%ecx
f0105a1f:	c1 e9 02             	shr    $0x2,%ecx
f0105a22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105a24:	a8 02                	test   $0x2,%al
f0105a26:	74 02                	je     f0105a2a <general_protection_fault_handler+0xe7>
f0105a28:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0105a2a:	a8 01                	test   $0x1,%al
f0105a2c:	74 01                	je     f0105a2f <general_protection_fault_handler+0xec>
f0105a2e:	a4                   	movsb  %ds:(%esi),%es:(%edi)
        utf->utf_eip = tf->tf_eip;
f0105a2f:	8b 55 08             	mov    0x8(%ebp),%edx
f0105a32:	8b 42 30             	mov    0x30(%edx),%eax
f0105a35:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105a38:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_eflags = tf->tf_eflags;
f0105a3b:	8b 55 08             	mov    0x8(%ebp),%edx
f0105a3e:	8b 42 38             	mov    0x38(%edx),%eax
f0105a41:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105a44:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_esp = tf->tf_esp;
f0105a47:	8b 55 08             	mov    0x8(%ebp),%edx
f0105a4a:	8b 42 3c             	mov    0x3c(%edx),%eax
f0105a4d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105a50:	89 42 30             	mov    %eax,0x30(%edx)
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_gpfault_upcall;
f0105a53:	e8 c0 29 00 00       	call   f0108418 <cpunum>
f0105a58:	6b c0 74             	imul   $0x74,%eax,%eax
f0105a5b:	8b 98 28 90 35 f0    	mov    -0xfca6fd8(%eax),%ebx
f0105a61:	e8 b2 29 00 00       	call   f0108418 <cpunum>
f0105a66:	6b c0 74             	imul   $0x74,%eax,%eax
f0105a69:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105a6f:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
f0105a75:	89 43 30             	mov    %eax,0x30(%ebx)
        curenv->env_tf.tf_esp = (uintptr_t)utf;
f0105a78:	e8 9b 29 00 00       	call   f0108418 <cpunum>
f0105a7d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105a80:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105a86:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105a89:	89 50 3c             	mov    %edx,0x3c(%eax)
        env_run(curenv);
f0105a8c:	e8 87 29 00 00       	call   f0108418 <cpunum>
f0105a91:	6b c0 74             	imul   $0x74,%eax,%eax
f0105a94:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105a9a:	89 04 24             	mov    %eax,(%esp)
f0105a9d:	e8 99 e5 ff ff       	call   f010403b <env_run>
    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}
f0105aa2:	83 c4 2c             	add    $0x2c,%esp
f0105aa5:	5b                   	pop    %ebx
f0105aa6:	5e                   	pop    %esi
f0105aa7:	5f                   	pop    %edi
f0105aa8:	5d                   	pop    %ebp
f0105aa9:	c3                   	ret    

f0105aaa <floating_point_error_handler>:

void floating_point_error_handler(struct Trapframe *tf) {
f0105aaa:	55                   	push   %ebp
f0105aab:	89 e5                	mov    %esp,%ebp
f0105aad:	57                   	push   %edi
f0105aae:	56                   	push   %esi
f0105aaf:	53                   	push   %ebx
f0105ab0:	83 ec 2c             	sub    $0x2c,%esp
f0105ab3:	0f 20 d3             	mov    %cr2,%ebx
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode floating point error exception
    if ((tf->tf_cs & 3) == 0)
f0105ab6:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ab9:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f0105abd:	75 1c                	jne    f0105adb <floating_point_error_handler+0x31>
        panic("floating point error exception in kernel mode!");
f0105abf:	c7 44 24 08 24 a6 10 	movl   $0xf010a624,0x8(%esp)
f0105ac6:	f0 
f0105ac7:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f0105ace:	00 
f0105acf:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f0105ad6:	e8 65 a5 ff ff       	call   f0100040 <_panic>
    if (curenv->env_fperror_upcall) {
f0105adb:	e8 38 29 00 00       	call   f0108418 <cpunum>
f0105ae0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105ae7:	29 c2                	sub    %eax,%edx
f0105ae9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105aec:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0105af3:	83 b8 9c 00 00 00 00 	cmpl   $0x0,0x9c(%eax)
f0105afa:	0f 84 09 01 00 00    	je     f0105c09 <floating_point_error_handler+0x15f>
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
f0105b00:	8b 55 08             	mov    0x8(%ebp),%edx
f0105b03:	8b 42 3c             	mov    0x3c(%edx),%eax
f0105b06:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
f0105b0c:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f0105b13:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0105b19:	77 06                	ja     f0105b21 <floating_point_error_handler+0x77>
f0105b1b:	83 e8 38             	sub    $0x38,%eax
f0105b1e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
f0105b21:	e8 f2 28 00 00       	call   f0108418 <cpunum>
f0105b26:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0105b2d:	00 
f0105b2e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105b35:	00 
f0105b36:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105b39:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105b3d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b40:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105b46:	89 04 24             	mov    %eax,(%esp)
f0105b49:	e8 37 dc ff ff       	call   f0103785 <user_mem_assert>
        utf->utf_fault_va = fault_va;
f0105b4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b51:	89 18                	mov    %ebx,(%eax)
        utf->utf_err = tf->tf_err;
f0105b53:	8b 55 08             	mov    0x8(%ebp),%edx
f0105b56:	8b 42 2c             	mov    0x2c(%edx),%eax
f0105b59:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105b5c:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs = tf->tf_regs;
f0105b5f:	89 d7                	mov    %edx,%edi
f0105b61:	83 c7 08             	add    $0x8,%edi
f0105b64:	8b 75 08             	mov    0x8(%ebp),%esi
f0105b67:	b8 20 00 00 00       	mov    $0x20,%eax
f0105b6c:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0105b72:	74 03                	je     f0105b77 <floating_point_error_handler+0xcd>
f0105b74:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0105b75:	b0 1f                	mov    $0x1f,%al
f0105b77:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0105b7d:	74 05                	je     f0105b84 <floating_point_error_handler+0xda>
f0105b7f:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0105b81:	83 e8 02             	sub    $0x2,%eax
f0105b84:	89 c1                	mov    %eax,%ecx
f0105b86:	c1 e9 02             	shr    $0x2,%ecx
f0105b89:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105b8b:	a8 02                	test   $0x2,%al
f0105b8d:	74 02                	je     f0105b91 <floating_point_error_handler+0xe7>
f0105b8f:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0105b91:	a8 01                	test   $0x1,%al
f0105b93:	74 01                	je     f0105b96 <floating_point_error_handler+0xec>
f0105b95:	a4                   	movsb  %ds:(%esi),%es:(%edi)
        utf->utf_eip = tf->tf_eip;
f0105b96:	8b 55 08             	mov    0x8(%ebp),%edx
f0105b99:	8b 42 30             	mov    0x30(%edx),%eax
f0105b9c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105b9f:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_eflags = tf->tf_eflags;
f0105ba2:	8b 55 08             	mov    0x8(%ebp),%edx
f0105ba5:	8b 42 38             	mov    0x38(%edx),%eax
f0105ba8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105bab:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_esp = tf->tf_esp;
f0105bae:	8b 55 08             	mov    0x8(%ebp),%edx
f0105bb1:	8b 42 3c             	mov    0x3c(%edx),%eax
f0105bb4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105bb7:	89 42 30             	mov    %eax,0x30(%edx)
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_fperror_upcall;
f0105bba:	e8 59 28 00 00       	call   f0108418 <cpunum>
f0105bbf:	6b c0 74             	imul   $0x74,%eax,%eax
f0105bc2:	8b 98 28 90 35 f0    	mov    -0xfca6fd8(%eax),%ebx
f0105bc8:	e8 4b 28 00 00       	call   f0108418 <cpunum>
f0105bcd:	6b c0 74             	imul   $0x74,%eax,%eax
f0105bd0:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105bd6:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
f0105bdc:	89 43 30             	mov    %eax,0x30(%ebx)
        curenv->env_tf.tf_esp = (uintptr_t)utf;
f0105bdf:	e8 34 28 00 00       	call   f0108418 <cpunum>
f0105be4:	6b c0 74             	imul   $0x74,%eax,%eax
f0105be7:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105bed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105bf0:	89 50 3c             	mov    %edx,0x3c(%eax)
        env_run(curenv);
f0105bf3:	e8 20 28 00 00       	call   f0108418 <cpunum>
f0105bf8:	6b c0 74             	imul   $0x74,%eax,%eax
f0105bfb:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105c01:	89 04 24             	mov    %eax,(%esp)
f0105c04:	e8 32 e4 ff ff       	call   f010403b <env_run>
    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}
f0105c09:	83 c4 2c             	add    $0x2c,%esp
f0105c0c:	5b                   	pop    %ebx
f0105c0d:	5e                   	pop    %esi
f0105c0e:	5f                   	pop    %edi
f0105c0f:	5d                   	pop    %ebp
f0105c10:	c3                   	ret    

f0105c11 <aligment_check_handler>:

void aligment_check_handler(struct Trapframe *tf) {
f0105c11:	55                   	push   %ebp
f0105c12:	89 e5                	mov    %esp,%ebp
f0105c14:	57                   	push   %edi
f0105c15:	56                   	push   %esi
f0105c16:	53                   	push   %ebx
f0105c17:	83 ec 2c             	sub    $0x2c,%esp
f0105c1a:	0f 20 d3             	mov    %cr2,%ebx
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode aligment check exception
    if ((tf->tf_cs & 3) == 0)
f0105c1d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c20:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f0105c24:	75 1c                	jne    f0105c42 <aligment_check_handler+0x31>
        panic("aligment check exception in kernel mode!");
f0105c26:	c7 44 24 08 54 a6 10 	movl   $0xf010a654,0x8(%esp)
f0105c2d:	f0 
f0105c2e:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0105c35:	00 
f0105c36:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f0105c3d:	e8 fe a3 ff ff       	call   f0100040 <_panic>
    if (curenv->env_algchk_upcall) {
f0105c42:	e8 d1 27 00 00       	call   f0108418 <cpunum>
f0105c47:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105c4e:	29 c2                	sub    %eax,%edx
f0105c50:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105c53:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0105c5a:	83 b8 a0 00 00 00 00 	cmpl   $0x0,0xa0(%eax)
f0105c61:	0f 84 09 01 00 00    	je     f0105d70 <aligment_check_handler+0x15f>
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
f0105c67:	8b 55 08             	mov    0x8(%ebp),%edx
f0105c6a:	8b 42 3c             	mov    0x3c(%edx),%eax
f0105c6d:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
f0105c73:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f0105c7a:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0105c80:	77 06                	ja     f0105c88 <aligment_check_handler+0x77>
f0105c82:	83 e8 38             	sub    $0x38,%eax
f0105c85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
f0105c88:	e8 8b 27 00 00       	call   f0108418 <cpunum>
f0105c8d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0105c94:	00 
f0105c95:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105c9c:	00 
f0105c9d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105ca0:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105ca4:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ca7:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105cad:	89 04 24             	mov    %eax,(%esp)
f0105cb0:	e8 d0 da ff ff       	call   f0103785 <user_mem_assert>
        utf->utf_fault_va = fault_va;
f0105cb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105cb8:	89 18                	mov    %ebx,(%eax)
        utf->utf_err = tf->tf_err;
f0105cba:	8b 55 08             	mov    0x8(%ebp),%edx
f0105cbd:	8b 42 2c             	mov    0x2c(%edx),%eax
f0105cc0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105cc3:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs = tf->tf_regs;
f0105cc6:	89 d7                	mov    %edx,%edi
f0105cc8:	83 c7 08             	add    $0x8,%edi
f0105ccb:	8b 75 08             	mov    0x8(%ebp),%esi
f0105cce:	b8 20 00 00 00       	mov    $0x20,%eax
f0105cd3:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0105cd9:	74 03                	je     f0105cde <aligment_check_handler+0xcd>
f0105cdb:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0105cdc:	b0 1f                	mov    $0x1f,%al
f0105cde:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0105ce4:	74 05                	je     f0105ceb <aligment_check_handler+0xda>
f0105ce6:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0105ce8:	83 e8 02             	sub    $0x2,%eax
f0105ceb:	89 c1                	mov    %eax,%ecx
f0105ced:	c1 e9 02             	shr    $0x2,%ecx
f0105cf0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105cf2:	a8 02                	test   $0x2,%al
f0105cf4:	74 02                	je     f0105cf8 <aligment_check_handler+0xe7>
f0105cf6:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0105cf8:	a8 01                	test   $0x1,%al
f0105cfa:	74 01                	je     f0105cfd <aligment_check_handler+0xec>
f0105cfc:	a4                   	movsb  %ds:(%esi),%es:(%edi)
        utf->utf_eip = tf->tf_eip;
f0105cfd:	8b 55 08             	mov    0x8(%ebp),%edx
f0105d00:	8b 42 30             	mov    0x30(%edx),%eax
f0105d03:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105d06:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_eflags = tf->tf_eflags;
f0105d09:	8b 55 08             	mov    0x8(%ebp),%edx
f0105d0c:	8b 42 38             	mov    0x38(%edx),%eax
f0105d0f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105d12:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_esp = tf->tf_esp;
f0105d15:	8b 55 08             	mov    0x8(%ebp),%edx
f0105d18:	8b 42 3c             	mov    0x3c(%edx),%eax
f0105d1b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105d1e:	89 42 30             	mov    %eax,0x30(%edx)
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_algchk_upcall;
f0105d21:	e8 f2 26 00 00       	call   f0108418 <cpunum>
f0105d26:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d29:	8b 98 28 90 35 f0    	mov    -0xfca6fd8(%eax),%ebx
f0105d2f:	e8 e4 26 00 00       	call   f0108418 <cpunum>
f0105d34:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d37:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105d3d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
f0105d43:	89 43 30             	mov    %eax,0x30(%ebx)
        curenv->env_tf.tf_esp = (uintptr_t)utf;
f0105d46:	e8 cd 26 00 00       	call   f0108418 <cpunum>
f0105d4b:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d4e:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105d54:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105d57:	89 50 3c             	mov    %edx,0x3c(%eax)
        env_run(curenv);
f0105d5a:	e8 b9 26 00 00       	call   f0108418 <cpunum>
f0105d5f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d62:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105d68:	89 04 24             	mov    %eax,(%esp)
f0105d6b:	e8 cb e2 ff ff       	call   f010403b <env_run>
    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}
f0105d70:	83 c4 2c             	add    $0x2c,%esp
f0105d73:	5b                   	pop    %ebx
f0105d74:	5e                   	pop    %esi
f0105d75:	5f                   	pop    %edi
f0105d76:	5d                   	pop    %ebp
f0105d77:	c3                   	ret    

f0105d78 <machine_check_handler>:

void machine_check_handler(struct Trapframe *tf) {
f0105d78:	55                   	push   %ebp
f0105d79:	89 e5                	mov    %esp,%ebp
f0105d7b:	57                   	push   %edi
f0105d7c:	56                   	push   %esi
f0105d7d:	53                   	push   %ebx
f0105d7e:	83 ec 2c             	sub    $0x2c,%esp
f0105d81:	0f 20 d3             	mov    %cr2,%ebx
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode machine check exception
    if ((tf->tf_cs & 3) == 0)
f0105d84:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d87:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f0105d8b:	75 1c                	jne    f0105da9 <machine_check_handler+0x31>
        panic("machine check exception in kernel mode!");
f0105d8d:	c7 44 24 08 80 a6 10 	movl   $0xf010a680,0x8(%esp)
f0105d94:	f0 
f0105d95:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f0105d9c:	00 
f0105d9d:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f0105da4:	e8 97 a2 ff ff       	call   f0100040 <_panic>
    if (curenv->env_mchchk_upcall) {
f0105da9:	e8 6a 26 00 00       	call   f0108418 <cpunum>
f0105dae:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105db5:	29 c2                	sub    %eax,%edx
f0105db7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105dba:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0105dc1:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
f0105dc8:	0f 84 09 01 00 00    	je     f0105ed7 <machine_check_handler+0x15f>
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
f0105dce:	8b 55 08             	mov    0x8(%ebp),%edx
f0105dd1:	8b 42 3c             	mov    0x3c(%edx),%eax
f0105dd4:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
f0105dda:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f0105de1:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0105de7:	77 06                	ja     f0105def <machine_check_handler+0x77>
f0105de9:	83 e8 38             	sub    $0x38,%eax
f0105dec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
f0105def:	e8 24 26 00 00       	call   f0108418 <cpunum>
f0105df4:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0105dfb:	00 
f0105dfc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105e03:	00 
f0105e04:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105e07:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105e0b:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e0e:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105e14:	89 04 24             	mov    %eax,(%esp)
f0105e17:	e8 69 d9 ff ff       	call   f0103785 <user_mem_assert>
        utf->utf_fault_va = fault_va;
f0105e1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105e1f:	89 18                	mov    %ebx,(%eax)
        utf->utf_err = tf->tf_err;
f0105e21:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e24:	8b 42 2c             	mov    0x2c(%edx),%eax
f0105e27:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105e2a:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs = tf->tf_regs;
f0105e2d:	89 d7                	mov    %edx,%edi
f0105e2f:	83 c7 08             	add    $0x8,%edi
f0105e32:	8b 75 08             	mov    0x8(%ebp),%esi
f0105e35:	b8 20 00 00 00       	mov    $0x20,%eax
f0105e3a:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0105e40:	74 03                	je     f0105e45 <machine_check_handler+0xcd>
f0105e42:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0105e43:	b0 1f                	mov    $0x1f,%al
f0105e45:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0105e4b:	74 05                	je     f0105e52 <machine_check_handler+0xda>
f0105e4d:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0105e4f:	83 e8 02             	sub    $0x2,%eax
f0105e52:	89 c1                	mov    %eax,%ecx
f0105e54:	c1 e9 02             	shr    $0x2,%ecx
f0105e57:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105e59:	a8 02                	test   $0x2,%al
f0105e5b:	74 02                	je     f0105e5f <machine_check_handler+0xe7>
f0105e5d:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0105e5f:	a8 01                	test   $0x1,%al
f0105e61:	74 01                	je     f0105e64 <machine_check_handler+0xec>
f0105e63:	a4                   	movsb  %ds:(%esi),%es:(%edi)
        utf->utf_eip = tf->tf_eip;
f0105e64:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e67:	8b 42 30             	mov    0x30(%edx),%eax
f0105e6a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105e6d:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_eflags = tf->tf_eflags;
f0105e70:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e73:	8b 42 38             	mov    0x38(%edx),%eax
f0105e76:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105e79:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_esp = tf->tf_esp;
f0105e7c:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e7f:	8b 42 3c             	mov    0x3c(%edx),%eax
f0105e82:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105e85:	89 42 30             	mov    %eax,0x30(%edx)
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_mchchk_upcall;
f0105e88:	e8 8b 25 00 00       	call   f0108418 <cpunum>
f0105e8d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e90:	8b 98 28 90 35 f0    	mov    -0xfca6fd8(%eax),%ebx
f0105e96:	e8 7d 25 00 00       	call   f0108418 <cpunum>
f0105e9b:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e9e:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105ea4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
f0105eaa:	89 43 30             	mov    %eax,0x30(%ebx)
        curenv->env_tf.tf_esp = (uintptr_t)utf;
f0105ead:	e8 66 25 00 00       	call   f0108418 <cpunum>
f0105eb2:	6b c0 74             	imul   $0x74,%eax,%eax
f0105eb5:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105ebb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105ebe:	89 50 3c             	mov    %edx,0x3c(%eax)
        env_run(curenv);
f0105ec1:	e8 52 25 00 00       	call   f0108418 <cpunum>
f0105ec6:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ec9:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105ecf:	89 04 24             	mov    %eax,(%esp)
f0105ed2:	e8 64 e1 ff ff       	call   f010403b <env_run>
    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}
f0105ed7:	83 c4 2c             	add    $0x2c,%esp
f0105eda:	5b                   	pop    %ebx
f0105edb:	5e                   	pop    %esi
f0105edc:	5f                   	pop    %edi
f0105edd:	5d                   	pop    %ebp
f0105ede:	c3                   	ret    

f0105edf <SIMD_floating_point_error_handler>:

void SIMD_floating_point_error_handler(struct Trapframe *tf) {
f0105edf:	55                   	push   %ebp
f0105ee0:	89 e5                	mov    %esp,%ebp
f0105ee2:	57                   	push   %edi
f0105ee3:	56                   	push   %esi
f0105ee4:	53                   	push   %ebx
f0105ee5:	83 ec 2c             	sub    $0x2c,%esp
f0105ee8:	0f 20 d3             	mov    %cr2,%ebx
    uint32_t fault_va;
    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();
    // handle kernel mode SIMD floating point error exception
    if ((tf->tf_cs & 3) == 0)
f0105eeb:	8b 45 08             	mov    0x8(%ebp),%eax
f0105eee:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f0105ef2:	75 1c                	jne    f0105f10 <SIMD_floating_point_error_handler+0x31>
        panic("SIMD floating point error exception in kernel mode!");
f0105ef4:	c7 44 24 08 a8 a6 10 	movl   $0xf010a6a8,0x8(%esp)
f0105efb:	f0 
f0105efc:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0105f03:	00 
f0105f04:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f0105f0b:	e8 30 a1 ff ff       	call   f0100040 <_panic>
    if (curenv->env_SIMDfperror_upcall) {
f0105f10:	e8 03 25 00 00       	call   f0108418 <cpunum>
f0105f15:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105f1c:	29 c2                	sub    %eax,%edx
f0105f1e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105f21:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0105f28:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
f0105f2f:	0f 84 09 01 00 00    	je     f010603e <SIMD_floating_point_error_handler+0x15f>
        struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
f0105f35:	8b 55 08             	mov    0x8(%ebp),%edx
f0105f38:	8b 42 3c             	mov    0x3c(%edx),%eax
f0105f3b:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                            (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
f0105f41:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f0105f48:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0105f4e:	77 06                	ja     f0105f56 <SIMD_floating_point_error_handler+0x77>
f0105f50:	83 e8 38             	sub    $0x38,%eax
f0105f53:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                            (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
        user_mem_assert(curenv, (void *)utf, 1, PTE_W);
f0105f56:	e8 bd 24 00 00       	call   f0108418 <cpunum>
f0105f5b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0105f62:	00 
f0105f63:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105f6a:	00 
f0105f6b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105f6e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105f72:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f75:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0105f7b:	89 04 24             	mov    %eax,(%esp)
f0105f7e:	e8 02 d8 ff ff       	call   f0103785 <user_mem_assert>
        utf->utf_fault_va = fault_va;
f0105f83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105f86:	89 18                	mov    %ebx,(%eax)
        utf->utf_err = tf->tf_err;
f0105f88:	8b 55 08             	mov    0x8(%ebp),%edx
f0105f8b:	8b 42 2c             	mov    0x2c(%edx),%eax
f0105f8e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105f91:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs = tf->tf_regs;
f0105f94:	89 d7                	mov    %edx,%edi
f0105f96:	83 c7 08             	add    $0x8,%edi
f0105f99:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f9c:	b8 20 00 00 00       	mov    $0x20,%eax
f0105fa1:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0105fa7:	74 03                	je     f0105fac <SIMD_floating_point_error_handler+0xcd>
f0105fa9:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0105faa:	b0 1f                	mov    $0x1f,%al
f0105fac:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0105fb2:	74 05                	je     f0105fb9 <SIMD_floating_point_error_handler+0xda>
f0105fb4:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0105fb6:	83 e8 02             	sub    $0x2,%eax
f0105fb9:	89 c1                	mov    %eax,%ecx
f0105fbb:	c1 e9 02             	shr    $0x2,%ecx
f0105fbe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105fc0:	a8 02                	test   $0x2,%al
f0105fc2:	74 02                	je     f0105fc6 <SIMD_floating_point_error_handler+0xe7>
f0105fc4:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0105fc6:	a8 01                	test   $0x1,%al
f0105fc8:	74 01                	je     f0105fcb <SIMD_floating_point_error_handler+0xec>
f0105fca:	a4                   	movsb  %ds:(%esi),%es:(%edi)
        utf->utf_eip = tf->tf_eip;
f0105fcb:	8b 55 08             	mov    0x8(%ebp),%edx
f0105fce:	8b 42 30             	mov    0x30(%edx),%eax
f0105fd1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105fd4:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_eflags = tf->tf_eflags;
f0105fd7:	8b 55 08             	mov    0x8(%ebp),%edx
f0105fda:	8b 42 38             	mov    0x38(%edx),%eax
f0105fdd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105fe0:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_esp = tf->tf_esp;
f0105fe3:	8b 55 08             	mov    0x8(%ebp),%edx
f0105fe6:	8b 42 3c             	mov    0x3c(%edx),%eax
f0105fe9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105fec:	89 42 30             	mov    %eax,0x30(%edx)
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_SIMDfperror_upcall;
f0105fef:	e8 24 24 00 00       	call   f0108418 <cpunum>
f0105ff4:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ff7:	8b 98 28 90 35 f0    	mov    -0xfca6fd8(%eax),%ebx
f0105ffd:	e8 16 24 00 00       	call   f0108418 <cpunum>
f0106002:	6b c0 74             	imul   $0x74,%eax,%eax
f0106005:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f010600b:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
f0106011:	89 43 30             	mov    %eax,0x30(%ebx)
        curenv->env_tf.tf_esp = (uintptr_t)utf;
f0106014:	e8 ff 23 00 00       	call   f0108418 <cpunum>
f0106019:	6b c0 74             	imul   $0x74,%eax,%eax
f010601c:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0106022:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0106025:	89 50 3c             	mov    %edx,0x3c(%eax)
        env_run(curenv);
f0106028:	e8 eb 23 00 00       	call   f0108418 <cpunum>
f010602d:	6b c0 74             	imul   $0x74,%eax,%eax
f0106030:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0106036:	89 04 24             	mov    %eax,(%esp)
f0106039:	e8 fd df ff ff       	call   f010403b <env_run>
    // Destroy the environment that caused the fault.
    //cprintf("[%08x] user fault va %08x ip %08x\n",
    //  curenv->env_id, fault_va, tf->tf_eip);
    //print_trapframe(tf);
    //env_destroy(curenv);
}
f010603e:	83 c4 2c             	add    $0x2c,%esp
f0106041:	5b                   	pop    %ebx
f0106042:	5e                   	pop    %esi
f0106043:	5f                   	pop    %edi
f0106044:	5d                   	pop    %ebp
f0106045:	c3                   	ret    

f0106046 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0106046:	55                   	push   %ebp
f0106047:	89 e5                	mov    %esp,%ebp
f0106049:	57                   	push   %edi
f010604a:	56                   	push   %esi
f010604b:	83 ec 20             	sub    $0x20,%esp
f010604e:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0106051:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0106052:	83 3d 80 8e 35 f0 00 	cmpl   $0x0,0xf0358e80
f0106059:	74 01                	je     f010605c <trap+0x16>
		asm volatile("hlt");
f010605b:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010605c:	e8 b7 23 00 00       	call   f0108418 <cpunum>
f0106061:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106068:	29 c2                	sub    %eax,%edx
f010606a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010606d:	8d 14 85 20 90 35 f0 	lea    -0xfca6fe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106074:	b8 01 00 00 00       	mov    $0x1,%eax
f0106079:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010607d:	83 f8 02             	cmp    $0x2,%eax
f0106080:	75 0c                	jne    f010608e <trap+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0106082:	c7 04 24 60 e4 12 f0 	movl   $0xf012e460,(%esp)
f0106089:	e8 49 26 00 00       	call   f01086d7 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f010608e:	9c                   	pushf  
f010608f:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0106090:	f6 c4 02             	test   $0x2,%ah
f0106093:	74 24                	je     f01060b9 <trap+0x73>
f0106095:	c7 44 24 0c 1e a2 10 	movl   $0xf010a21e,0xc(%esp)
f010609c:	f0 
f010609d:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01060a4:	f0 
f01060a5:	c7 44 24 04 5e 01 00 	movl   $0x15e,0x4(%esp)
f01060ac:	00 
f01060ad:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f01060b4:	e8 87 9f ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01060b9:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01060bd:	83 e0 03             	and    $0x3,%eax
f01060c0:	83 f8 03             	cmp    $0x3,%eax
f01060c3:	0f 85 a7 00 00 00    	jne    f0106170 <trap+0x12a>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f01060c9:	e8 4a 23 00 00       	call   f0108418 <cpunum>
f01060ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01060d1:	83 b8 28 90 35 f0 00 	cmpl   $0x0,-0xfca6fd8(%eax)
f01060d8:	75 24                	jne    f01060fe <trap+0xb8>
f01060da:	c7 44 24 0c 37 a2 10 	movl   $0xf010a237,0xc(%esp)
f01060e1:	f0 
f01060e2:	c7 44 24 08 9b 9c 10 	movl   $0xf0109c9b,0x8(%esp)
f01060e9:	f0 
f01060ea:	c7 44 24 04 65 01 00 	movl   $0x165,0x4(%esp)
f01060f1:	00 
f01060f2:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f01060f9:	e8 42 9f ff ff       	call   f0100040 <_panic>
f01060fe:	c7 04 24 60 e4 12 f0 	movl   $0xf012e460,(%esp)
f0106105:	e8 cd 25 00 00       	call   f01086d7 <spin_lock>
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010610a:	e8 09 23 00 00       	call   f0108418 <cpunum>
f010610f:	6b c0 74             	imul   $0x74,%eax,%eax
f0106112:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0106118:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010611c:	75 2d                	jne    f010614b <trap+0x105>
			env_free(curenv);
f010611e:	e8 f5 22 00 00       	call   f0108418 <cpunum>
f0106123:	6b c0 74             	imul   $0x74,%eax,%eax
f0106126:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f010612c:	89 04 24             	mov    %eax,(%esp)
f010612f:	e8 24 dc ff ff       	call   f0103d58 <env_free>
			curenv = NULL;
f0106134:	e8 df 22 00 00       	call   f0108418 <cpunum>
f0106139:	6b c0 74             	imul   $0x74,%eax,%eax
f010613c:	c7 80 28 90 35 f0 00 	movl   $0x0,-0xfca6fd8(%eax)
f0106143:	00 00 00 
			sched_yield();
f0106146:	e8 fe 03 00 00       	call   f0106549 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010614b:	e8 c8 22 00 00       	call   f0108418 <cpunum>
f0106150:	6b c0 74             	imul   $0x74,%eax,%eax
f0106153:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0106159:	b9 11 00 00 00       	mov    $0x11,%ecx
f010615e:	89 c7                	mov    %eax,%edi
f0106160:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0106162:	e8 b1 22 00 00       	call   f0108418 <cpunum>
f0106167:	6b c0 74             	imul   $0x74,%eax,%eax
f010616a:	8b b0 28 90 35 f0    	mov    -0xfca6fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0106170:	89 35 60 8a 35 f0    	mov    %esi,0xf0358a60
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	switch (tf->tf_trapno) {
f0106176:	8b 46 28             	mov    0x28(%esi),%eax
f0106179:	83 f8 30             	cmp    $0x30,%eax
f010617c:	0f 87 23 01 00 00    	ja     f01062a5 <trap+0x25f>
f0106182:	ff 24 85 e0 a6 10 f0 	jmp    *-0xfef5920(,%eax,4)
	case T_DIVIDE:
		divide_zero_handler(tf);
f0106189:	89 34 24             	mov    %esi,(%esp)
f010618c:	e8 02 e7 ff ff       	call   f0104893 <divide_zero_handler>
f0106191:	e9 7a 01 00 00       	jmp    f0106310 <trap+0x2ca>
		return;
	case T_PGFLT:
		page_fault_handler(tf);
f0106196:	89 34 24             	mov    %esi,(%esp)
f0106199:	e8 4c e5 ff ff       	call   f01046ea <page_fault_handler>
f010619e:	e9 6d 01 00 00       	jmp    f0106310 <trap+0x2ca>
		return;
   case T_DEBUG:
        debug_exception_handler(tf);
f01061a3:	89 34 24             	mov    %esi,(%esp)
f01061a6:	e8 49 e8 ff ff       	call   f01049f4 <debug_exception_handler>
f01061ab:	e9 60 01 00 00       	jmp    f0106310 <trap+0x2ca>
        return;
    case T_NMI:
        non_maskable_interrupt_handler(tf);
f01061b0:	89 34 24             	mov    %esi,(%esp)
f01061b3:	e8 9d e9 ff ff       	call   f0104b55 <non_maskable_interrupt_handler>
f01061b8:	e9 53 01 00 00       	jmp    f0106310 <trap+0x2ca>
        return;
    case T_BRKPT:
        breakpoint_handler(tf);
f01061bd:	89 34 24             	mov    %esi,(%esp)
f01061c0:	e8 f1 ea ff ff       	call   f0104cb6 <breakpoint_handler>
f01061c5:	e9 46 01 00 00       	jmp    f0106310 <trap+0x2ca>
        return;
    case T_OFLOW:
        overflow_handler(tf);
f01061ca:	89 34 24             	mov    %esi,(%esp)
f01061cd:	e8 45 ec ff ff       	call   f0104e17 <overflow_handler>
f01061d2:	e9 39 01 00 00       	jmp    f0106310 <trap+0x2ca>
        return;
    case T_BOUND:
        bounds_check_handler(tf);
f01061d7:	89 34 24             	mov    %esi,(%esp)
f01061da:	e8 99 ed ff ff       	call   f0104f78 <bounds_check_handler>
f01061df:	e9 2c 01 00 00       	jmp    f0106310 <trap+0x2ca>
        return;
    case T_ILLOP:
        illegal_opcode_handler(tf);
f01061e4:	89 34 24             	mov    %esi,(%esp)
f01061e7:	e8 ed ee ff ff       	call   f01050d9 <illegal_opcode_handler>
f01061ec:	e9 1f 01 00 00       	jmp    f0106310 <trap+0x2ca>
        return;
    case T_DEVICE:
        device_not_available_handler(tf);
f01061f1:	89 34 24             	mov    %esi,(%esp)
f01061f4:	e8 47 f0 ff ff       	call   f0105240 <device_not_available_handler>
f01061f9:	e9 12 01 00 00       	jmp    f0106310 <trap+0x2ca>
        return;
    case T_DBLFLT:
        double_fault_handler(tf);
f01061fe:	89 34 24             	mov    %esi,(%esp)
f0106201:	e8 a1 f1 ff ff       	call   f01053a7 <double_fault_handler>
f0106206:	e9 05 01 00 00       	jmp    f0106310 <trap+0x2ca>
        return;
    case T_TSS:
        invalid_task_switch_segment_handler(tf);
f010620b:	89 34 24             	mov    %esi,(%esp)
f010620e:	e8 fb f2 ff ff       	call   f010550e <invalid_task_switch_segment_handler>
f0106213:	e9 f8 00 00 00       	jmp    f0106310 <trap+0x2ca>
        return;
    case T_SEGNP:
        segment_not_present_handler(tf);
f0106218:	89 34 24             	mov    %esi,(%esp)
f010621b:	e8 55 f4 ff ff       	call   f0105675 <segment_not_present_handler>
f0106220:	e9 eb 00 00 00       	jmp    f0106310 <trap+0x2ca>
        return;
    case T_STACK:
        stack_exception_handler(tf);
f0106225:	89 34 24             	mov    %esi,(%esp)
f0106228:	e8 af f5 ff ff       	call   f01057dc <stack_exception_handler>
f010622d:	e9 de 00 00 00       	jmp    f0106310 <trap+0x2ca>
        return;
    case T_GPFLT:
        general_protection_fault_handler(tf);
f0106232:	89 34 24             	mov    %esi,(%esp)
f0106235:	e8 09 f7 ff ff       	call   f0105943 <general_protection_fault_handler>
f010623a:	e9 d1 00 00 00       	jmp    f0106310 <trap+0x2ca>
        return;
    case T_FPERR:
        floating_point_error_handler(tf);
f010623f:	89 34 24             	mov    %esi,(%esp)
f0106242:	e8 63 f8 ff ff       	call   f0105aaa <floating_point_error_handler>
f0106247:	e9 c4 00 00 00       	jmp    f0106310 <trap+0x2ca>
        return;
    case T_ALIGN:
        aligment_check_handler(tf);
f010624c:	89 34 24             	mov    %esi,(%esp)
f010624f:	e8 bd f9 ff ff       	call   f0105c11 <aligment_check_handler>
f0106254:	e9 b7 00 00 00       	jmp    f0106310 <trap+0x2ca>
        return;
    case T_MCHK:
        machine_check_handler(tf);
f0106259:	89 34 24             	mov    %esi,(%esp)
f010625c:	e8 17 fb ff ff       	call   f0105d78 <machine_check_handler>
f0106261:	e9 aa 00 00 00       	jmp    f0106310 <trap+0x2ca>
        return;
    case T_SIMDERR:
        SIMD_floating_point_error_handler(tf);
f0106266:	89 34 24             	mov    %esi,(%esp)
f0106269:	e8 71 fc ff ff       	call   f0105edf <SIMD_floating_point_error_handler>
f010626e:	e9 9d 00 00 00       	jmp    f0106310 <trap+0x2ca>
	//	monitor(tf);
	//	return;
	case T_SYSCALL:
		// we should put the return value in %eax
		tf->tf_regs.reg_eax =
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0106273:	8b 46 04             	mov    0x4(%esi),%eax
f0106276:	89 44 24 14          	mov    %eax,0x14(%esp)
f010627a:	8b 06                	mov    (%esi),%eax
f010627c:	89 44 24 10          	mov    %eax,0x10(%esp)
f0106280:	8b 46 10             	mov    0x10(%esi),%eax
f0106283:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106287:	8b 46 18             	mov    0x18(%esi),%eax
f010628a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010628e:	8b 46 14             	mov    0x14(%esi),%eax
f0106291:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106295:	8b 46 1c             	mov    0x1c(%esi),%eax
f0106298:	89 04 24             	mov    %eax,(%esp)
f010629b:	e8 a3 03 00 00       	call   f0106643 <syscall>
	//case T_BRKPT:
	//	monitor(tf);
	//	return;
	case T_SYSCALL:
		// we should put the return value in %eax
		tf->tf_regs.reg_eax =
f01062a0:	89 46 1c             	mov    %eax,0x1c(%esi)
f01062a3:	eb 6b                	jmp    f0106310 <trap+0x2ca>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01062a5:	83 f8 27             	cmp    $0x27,%eax
f01062a8:	75 16                	jne    f01062c0 <trap+0x27a>
		cprintf("Spurious interrupt on irq 7\n");
f01062aa:	c7 04 24 3e a2 10 f0 	movl   $0xf010a23e,(%esp)
f01062b1:	e8 d4 df ff ff       	call   f010428a <cprintf>
		print_trapframe(tf);
f01062b6:	89 34 24             	mov    %esi,(%esp)
f01062b9:	e8 94 e2 ff ff       	call   f0104552 <print_trapframe>
f01062be:	eb 50                	jmp    f0106310 <trap+0x2ca>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f01062c0:	83 f8 20             	cmp    $0x20,%eax
f01062c3:	75 0a                	jne    f01062cf <trap+0x289>
		lapic_eoi();
f01062c5:	e8 a5 22 00 00       	call   f010856f <lapic_eoi>
		sched_yield();
f01062ca:	e8 7a 02 00 00       	call   f0106549 <sched_yield>
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01062cf:	89 34 24             	mov    %esi,(%esp)
f01062d2:	e8 7b e2 ff ff       	call   f0104552 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01062d7:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01062dc:	75 1c                	jne    f01062fa <trap+0x2b4>
		panic("unhandled trap in kernel");
f01062de:	c7 44 24 08 5b a2 10 	movl   $0xf010a25b,0x8(%esp)
f01062e5:	f0 
f01062e6:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
f01062ed:	00 
f01062ee:	c7 04 24 12 a2 10 f0 	movl   $0xf010a212,(%esp)
f01062f5:	e8 46 9d ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f01062fa:	e8 19 21 00 00       	call   f0108418 <cpunum>
f01062ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0106302:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0106308:	89 04 24             	mov    %eax,(%esp)
f010630b:	e8 6c dc ff ff       	call   f0103f7c <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0106310:	e8 03 21 00 00       	call   f0108418 <cpunum>
f0106315:	6b c0 74             	imul   $0x74,%eax,%eax
f0106318:	83 b8 28 90 35 f0 00 	cmpl   $0x0,-0xfca6fd8(%eax)
f010631f:	74 2a                	je     f010634b <trap+0x305>
f0106321:	e8 f2 20 00 00       	call   f0108418 <cpunum>
f0106326:	6b c0 74             	imul   $0x74,%eax,%eax
f0106329:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f010632f:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0106333:	75 16                	jne    f010634b <trap+0x305>
		env_run(curenv);
f0106335:	e8 de 20 00 00       	call   f0108418 <cpunum>
f010633a:	6b c0 74             	imul   $0x74,%eax,%eax
f010633d:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0106343:	89 04 24             	mov    %eax,(%esp)
f0106346:	e8 f0 dc ff ff       	call   f010403b <env_run>
	else
		sched_yield();
f010634b:	e8 f9 01 00 00       	call   f0106549 <sched_yield>

f0106350 <t_divide_handler>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC_AUTO(t_divide_handler, T_DIVIDE)
f0106350:	6a 00                	push   $0x0
f0106352:	6a 00                	push   $0x0
f0106354:	e9 e7 00 00 00       	jmp    f0106440 <_alltraps>
f0106359:	90                   	nop

f010635a <t_debug_handler>:
TRAPHANDLER_NOEC_AUTO(t_debug_handler, T_DEBUG)
f010635a:	6a 00                	push   $0x0
f010635c:	6a 01                	push   $0x1
f010635e:	e9 dd 00 00 00       	jmp    f0106440 <_alltraps>
f0106363:	90                   	nop

f0106364 <t_nmi_handler>:
TRAPHANDLER_NOEC_AUTO(t_nmi_handler, T_NMI)
f0106364:	6a 00                	push   $0x0
f0106366:	6a 02                	push   $0x2
f0106368:	e9 d3 00 00 00       	jmp    f0106440 <_alltraps>
f010636d:	90                   	nop

f010636e <t_brkpt_handler>:
TRAPHANDLER_NOEC_AUTO(t_brkpt_handler, T_BRKPT)
f010636e:	6a 00                	push   $0x0
f0106370:	6a 03                	push   $0x3
f0106372:	e9 c9 00 00 00       	jmp    f0106440 <_alltraps>
f0106377:	90                   	nop

f0106378 <t_oflow_handler>:
TRAPHANDLER_NOEC_AUTO(t_oflow_handler, T_OFLOW)
f0106378:	6a 00                	push   $0x0
f010637a:	6a 04                	push   $0x4
f010637c:	e9 bf 00 00 00       	jmp    f0106440 <_alltraps>
f0106381:	90                   	nop

f0106382 <t_bound_handler>:
TRAPHANDLER_NOEC_AUTO(t_bound_handler, T_BOUND)
f0106382:	6a 00                	push   $0x0
f0106384:	6a 05                	push   $0x5
f0106386:	e9 b5 00 00 00       	jmp    f0106440 <_alltraps>
f010638b:	90                   	nop

f010638c <t_illop_handler>:
TRAPHANDLER_NOEC_AUTO(t_illop_handler, T_ILLOP)
f010638c:	6a 00                	push   $0x0
f010638e:	6a 06                	push   $0x6
f0106390:	e9 ab 00 00 00       	jmp    f0106440 <_alltraps>
f0106395:	90                   	nop

f0106396 <t_device_handler>:
TRAPHANDLER_NOEC_AUTO(t_device_handler, T_DEVICE)
f0106396:	6a 00                	push   $0x0
f0106398:	6a 07                	push   $0x7
f010639a:	e9 a1 00 00 00       	jmp    f0106440 <_alltraps>
f010639f:	90                   	nop

f01063a0 <t_dblflt_handler>:
TRAPHANDLER_AUTO(t_dblflt_handler, T_DBLFLT)
f01063a0:	6a 08                	push   $0x8
f01063a2:	e9 99 00 00 00       	jmp    f0106440 <_alltraps>
f01063a7:	90                   	nop

f01063a8 <t_tss_handler>:
PADDING()/* #define T_COPROC  9 */	// reserved (not generated by recent processors)
TRAPHANDLER_AUTO(t_tss_handler, T_TSS)
f01063a8:	6a 0a                	push   $0xa
f01063aa:	e9 91 00 00 00       	jmp    f0106440 <_alltraps>
f01063af:	90                   	nop

f01063b0 <t_segnp_handler>:
TRAPHANDLER_AUTO(t_segnp_handler, T_SEGNP)
f01063b0:	6a 0b                	push   $0xb
f01063b2:	e9 89 00 00 00       	jmp    f0106440 <_alltraps>
f01063b7:	90                   	nop

f01063b8 <t_stack_handler>:
TRAPHANDLER_AUTO(t_stack_handler, T_STACK)
f01063b8:	6a 0c                	push   $0xc
f01063ba:	e9 81 00 00 00       	jmp    f0106440 <_alltraps>
f01063bf:	90                   	nop

f01063c0 <t_gpflt_handler>:
TRAPHANDLER_AUTO(t_gpflt_handler, T_GPFLT)
f01063c0:	6a 0d                	push   $0xd
f01063c2:	eb 7c                	jmp    f0106440 <_alltraps>

f01063c4 <t_pgflt_handler>:
TRAPHANDLER_AUTO(t_pgflt_handler, T_PGFLT)
f01063c4:	6a 0e                	push   $0xe
f01063c6:	eb 78                	jmp    f0106440 <_alltraps>

f01063c8 <t_fperr_handler>:
PADDING()/* #define T_RES    15 */	// reserved
TRAPHANDLER_NOEC_AUTO(t_fperr_handler, T_FPERR)
f01063c8:	6a 00                	push   $0x0
f01063ca:	6a 10                	push   $0x10
f01063cc:	eb 72                	jmp    f0106440 <_alltraps>

f01063ce <t_align_handler>:
TRAPHANDLER_AUTO(t_align_handler, T_ALIGN)
f01063ce:	6a 11                	push   $0x11
f01063d0:	eb 6e                	jmp    f0106440 <_alltraps>

f01063d2 <t_mchk_handler>:
TRAPHANDLER_AUTO(t_mchk_handler, T_MCHK)
f01063d2:	6a 12                	push   $0x12
f01063d4:	eb 6a                	jmp    f0106440 <_alltraps>

f01063d6 <t_simderr_handler>:
TRAPHANDLER_AUTO(t_simderr_handler, T_SIMDERR)
f01063d6:	6a 13                	push   $0x13
f01063d8:	eb 66                	jmp    f0106440 <_alltraps>

f01063da <t_syscall_handler>:
TRAPHANDLER_NOEC_AUTO(t_syscall_handler, T_SYSCALL)
f01063da:	6a 00                	push   $0x0
f01063dc:	6a 30                	push   $0x30
f01063de:	eb 60                	jmp    f0106440 <_alltraps>

f01063e0 <irq_handler_0>:

/*
 * Lab 4: For IRQs
 */

TRAPHANDLER_NOEC_AUTO(irq_handler_0, 32)
f01063e0:	6a 00                	push   $0x0
f01063e2:	6a 20                	push   $0x20
f01063e4:	eb 5a                	jmp    f0106440 <_alltraps>

f01063e6 <irq_handler_1>:
TRAPHANDLER_NOEC_AUTO(irq_handler_1, 33)
f01063e6:	6a 00                	push   $0x0
f01063e8:	6a 21                	push   $0x21
f01063ea:	eb 54                	jmp    f0106440 <_alltraps>

f01063ec <irq_handler_2>:
TRAPHANDLER_NOEC_AUTO(irq_handler_2, 34)
f01063ec:	6a 00                	push   $0x0
f01063ee:	6a 22                	push   $0x22
f01063f0:	eb 4e                	jmp    f0106440 <_alltraps>

f01063f2 <irq_handler_3>:
TRAPHANDLER_NOEC_AUTO(irq_handler_3, 35)
f01063f2:	6a 00                	push   $0x0
f01063f4:	6a 23                	push   $0x23
f01063f6:	eb 48                	jmp    f0106440 <_alltraps>

f01063f8 <irq_handler_4>:
TRAPHANDLER_NOEC_AUTO(irq_handler_4, 36)
f01063f8:	6a 00                	push   $0x0
f01063fa:	6a 24                	push   $0x24
f01063fc:	eb 42                	jmp    f0106440 <_alltraps>

f01063fe <irq_handler_5>:
TRAPHANDLER_NOEC_AUTO(irq_handler_5, 37)
f01063fe:	6a 00                	push   $0x0
f0106400:	6a 25                	push   $0x25
f0106402:	eb 3c                	jmp    f0106440 <_alltraps>

f0106404 <irq_handler_6>:
TRAPHANDLER_NOEC_AUTO(irq_handler_6, 38)
f0106404:	6a 00                	push   $0x0
f0106406:	6a 26                	push   $0x26
f0106408:	eb 36                	jmp    f0106440 <_alltraps>

f010640a <irq_handler_7>:
TRAPHANDLER_NOEC_AUTO(irq_handler_7, 39)
f010640a:	6a 00                	push   $0x0
f010640c:	6a 27                	push   $0x27
f010640e:	eb 30                	jmp    f0106440 <_alltraps>

f0106410 <irq_handler_8>:
TRAPHANDLER_NOEC_AUTO(irq_handler_8, 40)
f0106410:	6a 00                	push   $0x0
f0106412:	6a 28                	push   $0x28
f0106414:	eb 2a                	jmp    f0106440 <_alltraps>

f0106416 <irq_handler_9>:
TRAPHANDLER_NOEC_AUTO(irq_handler_9, 41)
f0106416:	6a 00                	push   $0x0
f0106418:	6a 29                	push   $0x29
f010641a:	eb 24                	jmp    f0106440 <_alltraps>

f010641c <irq_handler_10>:
TRAPHANDLER_NOEC_AUTO(irq_handler_10, 42)
f010641c:	6a 00                	push   $0x0
f010641e:	6a 2a                	push   $0x2a
f0106420:	eb 1e                	jmp    f0106440 <_alltraps>

f0106422 <irq_handler_11>:
TRAPHANDLER_NOEC_AUTO(irq_handler_11, 43)
f0106422:	6a 00                	push   $0x0
f0106424:	6a 2b                	push   $0x2b
f0106426:	eb 18                	jmp    f0106440 <_alltraps>

f0106428 <irq_handler_12>:
TRAPHANDLER_NOEC_AUTO(irq_handler_12, 44)
f0106428:	6a 00                	push   $0x0
f010642a:	6a 2c                	push   $0x2c
f010642c:	eb 12                	jmp    f0106440 <_alltraps>

f010642e <irq_handler_13>:
TRAPHANDLER_NOEC_AUTO(irq_handler_13, 45)
f010642e:	6a 00                	push   $0x0
f0106430:	6a 2d                	push   $0x2d
f0106432:	eb 0c                	jmp    f0106440 <_alltraps>

f0106434 <irq_handler_14>:
TRAPHANDLER_NOEC_AUTO(irq_handler_14, 46)
f0106434:	6a 00                	push   $0x0
f0106436:	6a 2e                	push   $0x2e
f0106438:	eb 06                	jmp    f0106440 <_alltraps>

f010643a <irq_handler_15>:
TRAPHANDLER_NOEC_AUTO(irq_handler_15, 47)
f010643a:	6a 00                	push   $0x0
f010643c:	6a 2f                	push   $0x2f
f010643e:	eb 00                	jmp    f0106440 <_alltraps>

f0106440 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushl %ds
f0106440:	1e                   	push   %ds
	pushl %es
f0106441:	06                   	push   %es
	pushal
f0106442:	60                   	pusha  
	movl $GD_KD, %eax
f0106443:	b8 10 00 00 00       	mov    $0x10,%eax
	movl %eax, %ds
f0106448:	8e d8                	mov    %eax,%ds
	movl %eax, %es
f010644a:	8e c0                	mov    %eax,%es
	pushl %esp
f010644c:	54                   	push   %esp
	call trap
f010644d:	e8 f4 fb ff ff       	call   f0106046 <trap>
	...

f0106454 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0106454:	55                   	push   %ebp
f0106455:	89 e5                	mov    %esp,%ebp
f0106457:	83 ec 18             	sub    $0x18,%esp

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f010645a:	8b 15 48 82 35 f0    	mov    0xf0358248,%edx
f0106460:	83 c2 54             	add    $0x54,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0106463:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0106468:	8b 0a                	mov    (%edx),%ecx
f010646a:	49                   	dec    %ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010646b:	83 f9 02             	cmp    $0x2,%ecx
f010646e:	76 10                	jbe    f0106480 <sched_halt+0x2c>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0106470:	40                   	inc    %eax
f0106471:	81 c2 f0 00 00 00    	add    $0xf0,%edx
f0106477:	3d 00 04 00 00       	cmp    $0x400,%eax
f010647c:	75 ea                	jne    f0106468 <sched_halt+0x14>
f010647e:	eb 07                	jmp    f0106487 <sched_halt+0x33>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0106480:	3d 00 04 00 00       	cmp    $0x400,%eax
f0106485:	75 1a                	jne    f01064a1 <sched_halt+0x4d>
		cprintf("No runnable environments in the system!\n");
f0106487:	c7 04 24 10 a8 10 f0 	movl   $0xf010a810,(%esp)
f010648e:	e8 f7 dd ff ff       	call   f010428a <cprintf>
		while (1)
			monitor(NULL);
f0106493:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010649a:	e8 8f a7 ff ff       	call   f0100c2e <monitor>
f010649f:	eb f2                	jmp    f0106493 <sched_halt+0x3f>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01064a1:	e8 72 1f 00 00       	call   f0108418 <cpunum>
f01064a6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01064ad:	29 c2                	sub    %eax,%edx
f01064af:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01064b2:	c7 04 85 28 90 35 f0 	movl   $0x0,-0xfca6fd8(,%eax,4)
f01064b9:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f01064bd:	a1 8c 8e 35 f0       	mov    0xf0358e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01064c2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01064c7:	77 20                	ja     f01064e9 <sched_halt+0x95>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01064c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01064cd:	c7 44 24 08 04 8b 10 	movl   $0xf0108b04,0x8(%esp)
f01064d4:	f0 
f01064d5:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
f01064dc:	00 
f01064dd:	c7 04 24 39 a8 10 f0 	movl   $0xf010a839,(%esp)
f01064e4:	e8 57 9b ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01064e9:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01064ee:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01064f1:	e8 22 1f 00 00       	call   f0108418 <cpunum>
f01064f6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01064fd:	29 c2                	sub    %eax,%edx
f01064ff:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106502:	8d 14 85 20 90 35 f0 	lea    -0xfca6fe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106509:	b8 02 00 00 00       	mov    $0x2,%eax
f010650e:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0106512:	c7 04 24 60 e4 12 f0 	movl   $0xf012e460,(%esp)
f0106519:	e8 5c 22 00 00       	call   f010877a <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010651e:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0106520:	e8 f3 1e 00 00       	call   f0108418 <cpunum>
f0106525:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010652c:	29 c2                	sub    %eax,%edx
f010652e:	8d 04 90             	lea    (%eax,%edx,4),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0106531:	8b 04 85 30 90 35 f0 	mov    -0xfca6fd0(,%eax,4),%eax
f0106538:	bd 00 00 00 00       	mov    $0x0,%ebp
f010653d:	89 c4                	mov    %eax,%esp
f010653f:	6a 00                	push   $0x0
f0106541:	6a 00                	push   $0x0
f0106543:	fb                   	sti    
f0106544:	f4                   	hlt    
f0106545:	eb fd                	jmp    f0106544 <sched_halt+0xf0>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0106547:	c9                   	leave  
f0106548:	c3                   	ret    

f0106549 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0106549:	55                   	push   %ebp
f010654a:	89 e5                	mov    %esp,%ebp
f010654c:	53                   	push   %ebx
f010654d:	83 ec 14             	sub    $0x14,%esp
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int offset = curenv ? ENVX(curenv->env_id) : 0;
f0106550:	e8 c3 1e 00 00       	call   f0108418 <cpunum>
f0106555:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010655c:	29 c2                	sub    %eax,%edx
f010655e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106561:	83 3c 85 28 90 35 f0 	cmpl   $0x0,-0xfca6fd8(,%eax,4)
f0106568:	00 
f0106569:	74 23                	je     f010658e <sched_yield+0x45>
f010656b:	e8 a8 1e 00 00       	call   f0108418 <cpunum>
f0106570:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106577:	29 c2                	sub    %eax,%edx
f0106579:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010657c:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0106583:	8b 58 48             	mov    0x48(%eax),%ebx
f0106586:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f010658c:	eb 05                	jmp    f0106593 <sched_yield+0x4a>
f010658e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < NENV; i++) {
		int id = (i + offset) % NENV;
		if (envs[id].env_status == ENV_RUNNABLE)
f0106593:	8b 0d 48 82 35 f0    	mov    0xf0358248,%ecx
	// below to halt the cpu.

	// LAB 4: Your code here.
	int offset = curenv ? ENVX(curenv->env_id) : 0;
	int i;
	for (i = 0; i < NENV; i++) {
f0106599:	ba 00 00 00 00       	mov    $0x0,%edx

void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
f010659e:	8d 04 1a             	lea    (%edx,%ebx,1),%eax

	// LAB 4: Your code here.
	int offset = curenv ? ENVX(curenv->env_id) : 0;
	int i;
	for (i = 0; i < NENV; i++) {
		int id = (i + offset) % NENV;
f01065a1:	25 ff 03 00 80       	and    $0x800003ff,%eax
f01065a6:	79 07                	jns    f01065af <sched_yield+0x66>
f01065a8:	48                   	dec    %eax
f01065a9:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f01065ae:	40                   	inc    %eax
		if (envs[id].env_status == ENV_RUNNABLE)
f01065af:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01065b2:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01065b5:	c1 e0 04             	shl    $0x4,%eax
f01065b8:	01 c8                	add    %ecx,%eax
f01065ba:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f01065be:	75 08                	jne    f01065c8 <sched_yield+0x7f>
			env_run(&envs[id]);
f01065c0:	89 04 24             	mov    %eax,(%esp)
f01065c3:	e8 73 da ff ff       	call   f010403b <env_run>
	// below to halt the cpu.

	// LAB 4: Your code here.
	int offset = curenv ? ENVX(curenv->env_id) : 0;
	int i;
	for (i = 0; i < NENV; i++) {
f01065c8:	42                   	inc    %edx
f01065c9:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f01065cf:	75 cd                	jne    f010659e <sched_yield+0x55>
		int id = (i + offset) % NENV;
		if (envs[id].env_status == ENV_RUNNABLE)
			env_run(&envs[id]);
	}
	if (curenv && curenv->env_status == ENV_RUNNING)
f01065d1:	e8 42 1e 00 00       	call   f0108418 <cpunum>
f01065d6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01065dd:	29 c2                	sub    %eax,%edx
f01065df:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01065e2:	83 3c 85 28 90 35 f0 	cmpl   $0x0,-0xfca6fd8(,%eax,4)
f01065e9:	00 
f01065ea:	74 3e                	je     f010662a <sched_yield+0xe1>
f01065ec:	e8 27 1e 00 00       	call   f0108418 <cpunum>
f01065f1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01065f8:	29 c2                	sub    %eax,%edx
f01065fa:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01065fd:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0106604:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0106608:	75 20                	jne    f010662a <sched_yield+0xe1>
		env_run(curenv);
f010660a:	e8 09 1e 00 00       	call   f0108418 <cpunum>
f010660f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106616:	29 c2                	sub    %eax,%edx
f0106618:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010661b:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0106622:	89 04 24             	mov    %eax,(%esp)
f0106625:	e8 11 da ff ff       	call   f010403b <env_run>

	// sched_halt never returns
	sched_halt();
f010662a:	e8 25 fe ff ff       	call   f0106454 <sched_halt>
}
f010662f:	83 c4 14             	add    $0x14,%esp
f0106632:	5b                   	pop    %ebx
f0106633:	5d                   	pop    %ebp
f0106634:	c3                   	ret    
f0106635:	00 00                	add    %al,(%eax)
	...

f0106638 <sys_yield>:
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
f0106638:	55                   	push   %ebp
f0106639:	89 e5                	mov    %esp,%ebp
f010663b:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f010663e:	e8 06 ff ff ff       	call   f0106549 <sched_yield>

f0106643 <syscall>:


// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0106643:	55                   	push   %ebp
f0106644:	89 e5                	mov    %esp,%ebp
f0106646:	57                   	push   %edi
f0106647:	56                   	push   %esi
f0106648:	53                   	push   %ebx
f0106649:	83 ec 3c             	sub    $0x3c,%esp
f010664c:	8b 45 08             	mov    0x8(%ebp),%eax
f010664f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106652:	8b 7d 10             	mov    0x10(%ebp),%edi
f0106655:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
f0106658:	83 f8 1d             	cmp    $0x1d,%eax
f010665b:	0f 87 af 0b 00 00    	ja     f0107210 <syscall+0xbcd>
f0106661:	ff 24 85 f0 a8 10 f0 	jmp    *-0xfef5710(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);
f0106668:	e8 ab 1d 00 00       	call   f0108418 <cpunum>
f010666d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0106674:	00 
f0106675:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106679:	89 74 24 04          	mov    %esi,0x4(%esp)
f010667d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106684:	29 c2                	sub    %eax,%edx
f0106686:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106689:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0106690:	89 04 24             	mov    %eax,(%esp)
f0106693:	e8 ed d0 ff ff       	call   f0103785 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0106698:	89 74 24 08          	mov    %esi,0x8(%esp)
f010669c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01066a0:	c7 04 24 46 a8 10 f0 	movl   $0xf010a846,(%esp)
f01066a7:	e8 de db ff ff       	call   f010428a <cprintf>
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *)a1, a2);
		return 0;
f01066ac:	be 00 00 00 00       	mov    $0x0,%esi
f01066b1:	e9 66 0b 00 00       	jmp    f010721c <syscall+0xbd9>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01066b6:	e8 c5 9f ff ff       	call   f0100680 <cons_getc>
f01066bb:	89 c6                	mov    %eax,%esi
	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *)a1, a2);
		return 0;
	case SYS_cgetc:
		return sys_cgetc();
f01066bd:	e9 5a 0b 00 00       	jmp    f010721c <syscall+0xbd9>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01066c2:	e8 51 1d 00 00       	call   f0108418 <cpunum>
f01066c7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01066ce:	29 c2                	sub    %eax,%edx
f01066d0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01066d3:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f01066da:	8b 70 48             	mov    0x48(%eax),%esi
		sys_cputs((char *)a1, a2);
		return 0;
	case SYS_cgetc:
		return sys_cgetc();
	case SYS_getenvid:
		return sys_getenvid();
f01066dd:	e9 3a 0b 00 00       	jmp    f010721c <syscall+0xbd9>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01066e2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01066e9:	00 
f01066ea:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01066ed:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066f1:	89 34 24             	mov    %esi,(%esp)
f01066f4:	e8 62 d1 ff ff       	call   f010385b <envid2env>
f01066f9:	85 c0                	test   %eax,%eax
f01066fb:	0f 88 16 0b 00 00    	js     f0107217 <syscall+0xbd4>
		return r;
	if (e == curenv)
f0106701:	e8 12 1d 00 00       	call   f0108418 <cpunum>
f0106706:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106709:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0106710:	29 c1                	sub    %eax,%ecx
f0106712:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f0106715:	39 14 85 28 90 35 f0 	cmp    %edx,-0xfca6fd8(,%eax,4)
f010671c:	75 2d                	jne    f010674b <syscall+0x108>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010671e:	e8 f5 1c 00 00       	call   f0108418 <cpunum>
f0106723:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010672a:	29 c2                	sub    %eax,%edx
f010672c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010672f:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0106736:	8b 40 48             	mov    0x48(%eax),%eax
f0106739:	89 44 24 04          	mov    %eax,0x4(%esp)
f010673d:	c7 04 24 4b a8 10 f0 	movl   $0xf010a84b,(%esp)
f0106744:	e8 41 db ff ff       	call   f010428a <cprintf>
f0106749:	eb 32                	jmp    f010677d <syscall+0x13a>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010674b:	8b 5a 48             	mov    0x48(%edx),%ebx
f010674e:	e8 c5 1c 00 00       	call   f0108418 <cpunum>
f0106753:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106757:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010675e:	29 c2                	sub    %eax,%edx
f0106760:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106763:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f010676a:	8b 40 48             	mov    0x48(%eax),%eax
f010676d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106771:	c7 04 24 66 a8 10 f0 	movl   $0xf010a866,(%esp)
f0106778:	e8 0d db ff ff       	call   f010428a <cprintf>
	env_destroy(e);
f010677d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106780:	89 04 24             	mov    %eax,(%esp)
f0106783:	e8 f4 d7 ff ff       	call   f0103f7c <env_destroy>
		return sys_cgetc();
	case SYS_getenvid:
		return sys_getenvid();
	case SYS_env_destroy:
		sys_env_destroy(a1);
		return 0;
f0106788:	be 00 00 00 00       	mov    $0x0,%esi
f010678d:	e9 8a 0a 00 00       	jmp    f010721c <syscall+0xbd9>
	case SYS_yield:
		sys_yield();
f0106792:	e8 a1 fe ff ff       	call   f0106638 <sys_yield>

	// LAB 4: Your code here.
	int r;
	struct Env *e;
	// catch -E_NO_FREE_ENV and -E_NO_MEM from env_alloc()
	if ((r = env_alloc(&e, curenv->env_id)) < 0)
f0106797:	e8 7c 1c 00 00       	call   f0108418 <cpunum>
f010679c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01067a3:	29 c2                	sub    %eax,%edx
f01067a5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01067a8:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f01067af:	8b 40 48             	mov    0x48(%eax),%eax
f01067b2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01067b6:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01067b9:	89 04 24             	mov    %eax,(%esp)
f01067bc:	e8 c8 d1 ff ff       	call   f0103989 <env_alloc>
f01067c1:	89 c6                	mov    %eax,%esi
f01067c3:	85 c0                	test   %eax,%eax
f01067c5:	0f 88 51 0a 00 00    	js     f010721c <syscall+0xbd9>
		return r;
	e->env_status = ENV_NOT_RUNNABLE;
f01067cb:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01067ce:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf;
f01067d5:	e8 3e 1c 00 00       	call   f0108418 <cpunum>
f01067da:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01067e1:	29 c2                	sub    %eax,%edx
f01067e3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01067e6:	8b 34 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%esi
f01067ed:	b9 11 00 00 00       	mov    $0x11,%ecx
f01067f2:	89 df                	mov    %ebx,%edi
f01067f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	// set return value for child process
	e->env_tf.tf_regs.reg_eax = 0;
f01067f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01067f9:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f0106800:	8b 70 48             	mov    0x48(%eax),%esi
		return 0;
	case SYS_yield:
		sys_yield();
		return 0;
	case SYS_exofork:
		return sys_exofork();
f0106803:	e9 14 0a 00 00       	jmp    f010721c <syscall+0xbd9>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if (!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
f0106808:	83 ff 02             	cmp    $0x2,%edi
f010680b:	74 05                	je     f0106812 <syscall+0x1cf>
f010680d:	83 ff 04             	cmp    $0x4,%edi
f0106810:	75 31                	jne    f0106843 <syscall+0x200>
		return -E_INVAL;
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 1)) < 0)
f0106812:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106819:	00 
f010681a:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010681d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106821:	89 34 24             	mov    %esi,(%esp)
f0106824:	e8 32 d0 ff ff       	call   f010385b <envid2env>
f0106829:	89 c6                	mov    %eax,%esi
f010682b:	85 c0                	test   %eax,%eax
f010682d:	0f 88 e9 09 00 00    	js     f010721c <syscall+0xbd9>
		return r;
	e->env_status = status;
f0106833:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106836:	89 78 54             	mov    %edi,0x54(%eax)
	return 0;
f0106839:	be 00 00 00 00       	mov    $0x0,%esi
f010683e:	e9 d9 09 00 00       	jmp    f010721c <syscall+0xbd9>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if (!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
		return -E_INVAL;
f0106843:	be fd ff ff ff       	mov    $0xfffffffd,%esi
		sys_yield();
		return 0;
	case SYS_exofork:
		return sys_exofork();
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
f0106848:	e9 cf 09 00 00       	jmp    f010721c <syscall+0xbd9>

	// LAB 4: Your code here.
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 1)) < 0)
f010684d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106854:	00 
f0106855:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0106858:	89 44 24 04          	mov    %eax,0x4(%esp)
f010685c:	89 34 24             	mov    %esi,(%esp)
f010685f:	e8 f7 cf ff ff       	call   f010385b <envid2env>
f0106864:	89 c6                	mov    %eax,%esi
f0106866:	85 c0                	test   %eax,%eax
f0106868:	0f 88 ae 09 00 00    	js     f010721c <syscall+0xbd9>
		return r;
	if ((uintptr_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f010686e:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0106874:	77 60                	ja     f01068d6 <syscall+0x293>
f0106876:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
f010687c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0106881:	39 c7                	cmp    %eax,%edi
f0106883:	75 5b                	jne    f01068e0 <syscall+0x29d>
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) return -E_INVAL;
f0106885:	89 d8                	mov    %ebx,%eax
f0106887:	83 e0 05             	and    $0x5,%eax
f010688a:	83 f8 05             	cmp    $0x5,%eax
f010688d:	75 5b                	jne    f01068ea <syscall+0x2a7>
	struct PageInfo *pp = page_alloc(1);
f010688f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0106896:	e8 ee a9 ff ff       	call   f0101289 <page_alloc>
f010689b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (!pp) return E_NO_MEM;
f010689e:	85 c0                	test   %eax,%eax
f01068a0:	74 52                	je     f01068f4 <syscall+0x2b1>
	pp->pp_ref++;
f01068a2:	66 ff 40 04          	incw   0x4(%eax)
	if ((r = page_insert(e->env_pgdir, pp, va, perm)) < 0) {
f01068a6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01068aa:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01068ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01068b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01068b5:	8b 40 60             	mov    0x60(%eax),%eax
f01068b8:	89 04 24             	mov    %eax,(%esp)
f01068bb:	e8 02 ad ff ff       	call   f01015c2 <page_insert>
f01068c0:	89 c6                	mov    %eax,%esi
f01068c2:	85 c0                	test   %eax,%eax
f01068c4:	79 38                	jns    f01068fe <syscall+0x2bb>
		page_free(pp);
f01068c6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01068c9:	89 04 24             	mov    %eax,(%esp)
f01068cc:	e8 3c aa ff ff       	call   f010130d <page_free>
f01068d1:	e9 46 09 00 00       	jmp    f010721c <syscall+0xbd9>
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if ((uintptr_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f01068d6:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01068db:	e9 3c 09 00 00       	jmp    f010721c <syscall+0xbd9>
f01068e0:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01068e5:	e9 32 09 00 00       	jmp    f010721c <syscall+0xbd9>
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) return -E_INVAL;
f01068ea:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01068ef:	e9 28 09 00 00       	jmp    f010721c <syscall+0xbd9>
	struct PageInfo *pp = page_alloc(1);
	if (!pp) return E_NO_MEM;
f01068f4:	be 04 00 00 00       	mov    $0x4,%esi
f01068f9:	e9 1e 09 00 00       	jmp    f010721c <syscall+0xbd9>
	pp->pp_ref++;
	if ((r = page_insert(e->env_pgdir, pp, va, perm)) < 0) {
		page_free(pp);
		return r;
	}
	return 0;
f01068fe:	be 00 00 00 00       	mov    $0x0,%esi
	case SYS_exofork:
		return sys_exofork();
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *)a2, a3);
f0106903:	e9 14 09 00 00       	jmp    f010721c <syscall+0xbd9>

	// LAB 4: Your code here.
	int r;
	struct Env *srce, *dste;
	// catch -E_BAD_ENV
	if ((r = envid2env(srcenvid, &srce, 1)) < 0)
f0106908:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010690f:	00 
f0106910:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0106913:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106917:	89 34 24             	mov    %esi,(%esp)
f010691a:	e8 3c cf ff ff       	call   f010385b <envid2env>
f010691f:	89 c6                	mov    %eax,%esi
f0106921:	85 c0                	test   %eax,%eax
f0106923:	0f 88 f3 08 00 00    	js     f010721c <syscall+0xbd9>
		return r;
	if ((r = envid2env(dstenvid, &dste, 1)) < 0)
f0106929:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106930:	00 
f0106931:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0106934:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106938:	89 1c 24             	mov    %ebx,(%esp)
f010693b:	e8 1b cf ff ff       	call   f010385b <envid2env>
f0106940:	89 c6                	mov    %eax,%esi
f0106942:	85 c0                	test   %eax,%eax
f0106944:	0f 88 d2 08 00 00    	js     f010721c <syscall+0xbd9>
		return r;
	if ((uintptr_t)srcva>=UTOP || ROUNDUP(srcva, PGSIZE) != srcva ||
f010694a:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0106950:	0f 87 8f 00 00 00    	ja     f01069e5 <syscall+0x3a2>
f0106956:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
f010695c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0106961:	39 c7                	cmp    %eax,%edi
f0106963:	0f 85 86 00 00 00    	jne    f01069ef <syscall+0x3ac>
f0106969:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0106970:	0f 87 83 00 00 00    	ja     f01069f9 <syscall+0x3b6>
		(uintptr_t)dstva>=UTOP || ROUNDUP(dstva, PGSIZE) != dstva)
f0106976:	8b 45 18             	mov    0x18(%ebp),%eax
f0106979:	05 ff 0f 00 00       	add    $0xfff,%eax
f010697e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0106983:	39 45 18             	cmp    %eax,0x18(%ebp)
f0106986:	75 7b                	jne    f0106a03 <syscall+0x3c0>
		return -E_INVAL;
	pte_t *ppte;
	struct PageInfo *pp = page_lookup(srce->env_pgdir, srcva, &ppte);
f0106988:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010698b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010698f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106993:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106996:	8b 40 60             	mov    0x60(%eax),%eax
f0106999:	89 04 24             	mov    %eax,(%esp)
f010699c:	e8 0f ab ff ff       	call   f01014b0 <page_lookup>
	if (!pp) return -E_INVAL;
f01069a1:	85 c0                	test   %eax,%eax
f01069a3:	74 68                	je     f0106a0d <syscall+0x3ca>
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) return -E_INVAL;
f01069a5:	8b 55 1c             	mov    0x1c(%ebp),%edx
f01069a8:	83 e2 05             	and    $0x5,%edx
f01069ab:	83 fa 05             	cmp    $0x5,%edx
f01069ae:	75 67                	jne    f0106a17 <syscall+0x3d4>
	if ((perm & PTE_W) && !(*ppte & PTE_W)) return -E_INVAL;
f01069b0:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01069b4:	74 08                	je     f01069be <syscall+0x37b>
f01069b6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01069b9:	f6 02 02             	testb  $0x2,(%edx)
f01069bc:	74 63                	je     f0106a21 <syscall+0x3de>
	// catch -E_NO_MEM
	return page_insert(dste->env_pgdir, pp, dstva, perm);
f01069be:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f01069c1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01069c5:	8b 5d 18             	mov    0x18(%ebp),%ebx
f01069c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01069cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01069d3:	8b 40 60             	mov    0x60(%eax),%eax
f01069d6:	89 04 24             	mov    %eax,(%esp)
f01069d9:	e8 e4 ab ff ff       	call   f01015c2 <page_insert>
f01069de:	89 c6                	mov    %eax,%esi
f01069e0:	e9 37 08 00 00       	jmp    f010721c <syscall+0xbd9>
		return r;
	if ((r = envid2env(dstenvid, &dste, 1)) < 0)
		return r;
	if ((uintptr_t)srcva>=UTOP || ROUNDUP(srcva, PGSIZE) != srcva ||
		(uintptr_t)dstva>=UTOP || ROUNDUP(dstva, PGSIZE) != dstva)
		return -E_INVAL;
f01069e5:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01069ea:	e9 2d 08 00 00       	jmp    f010721c <syscall+0xbd9>
f01069ef:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01069f4:	e9 23 08 00 00       	jmp    f010721c <syscall+0xbd9>
f01069f9:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01069fe:	e9 19 08 00 00       	jmp    f010721c <syscall+0xbd9>
f0106a03:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0106a08:	e9 0f 08 00 00       	jmp    f010721c <syscall+0xbd9>
	pte_t *ppte;
	struct PageInfo *pp = page_lookup(srce->env_pgdir, srcva, &ppte);
	if (!pp) return -E_INVAL;
f0106a0d:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0106a12:	e9 05 08 00 00       	jmp    f010721c <syscall+0xbd9>
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) return -E_INVAL;
f0106a17:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0106a1c:	e9 fb 07 00 00       	jmp    f010721c <syscall+0xbd9>
	if ((perm & PTE_W) && !(*ppte & PTE_W)) return -E_INVAL;
f0106a21:	be fd ff ff ff       	mov    $0xfffffffd,%esi
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *)a2, a3);
	case SYS_page_map:
		return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
f0106a26:	e9 f1 07 00 00       	jmp    f010721c <syscall+0xbd9>

	// LAB 4: Your code here.
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 0)) < 0)
f0106a2b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0106a32:	00 
f0106a33:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0106a36:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a3a:	89 34 24             	mov    %esi,(%esp)
f0106a3d:	e8 19 ce ff ff       	call   f010385b <envid2env>
f0106a42:	89 c6                	mov    %eax,%esi
f0106a44:	85 c0                	test   %eax,%eax
f0106a46:	0f 88 d0 07 00 00    	js     f010721c <syscall+0xbd9>
		return r;
	if ((uintptr_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0106a4c:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0106a52:	77 2b                	ja     f0106a7f <syscall+0x43c>
f0106a54:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
f0106a5a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0106a5f:	39 c7                	cmp    %eax,%edi
f0106a61:	75 26                	jne    f0106a89 <syscall+0x446>
	page_remove(e->env_pgdir, va);
f0106a63:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106a67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106a6a:	8b 40 60             	mov    0x60(%eax),%eax
f0106a6d:	89 04 24             	mov    %eax,(%esp)
f0106a70:	e8 fc aa ff ff       	call   f0101571 <page_remove>
	return 0;
f0106a75:	be 00 00 00 00       	mov    $0x0,%esi
f0106a7a:	e9 9d 07 00 00       	jmp    f010721c <syscall+0xbd9>
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 0)) < 0)
		return r;
	if ((uintptr_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0106a7f:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0106a84:	e9 93 07 00 00       	jmp    f010721c <syscall+0xbd9>
f0106a89:	be fd ff ff ff       	mov    $0xfffffffd,%esi
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *)a2, a3);
	case SYS_page_map:
		return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *)a2);
f0106a8e:	e9 89 07 00 00       	jmp    f010721c <syscall+0xbd9>
{
	// LAB 4: Your code here.
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 1)) < 0)
f0106a93:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106a9a:	00 
f0106a9b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0106a9e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106aa2:	89 34 24             	mov    %esi,(%esp)
f0106aa5:	e8 b1 cd ff ff       	call   f010385b <envid2env>
f0106aaa:	89 c6                	mov    %eax,%esi
f0106aac:	85 c0                	test   %eax,%eax
f0106aae:	0f 88 68 07 00 00    	js     f010721c <syscall+0xbd9>
		return r;
	e->env_pgfault_upcall = func;
f0106ab4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106ab7:	89 78 64             	mov    %edi,0x64(%eax)
	return 0;
f0106aba:	be 00 00 00 00       	mov    $0x0,%esi
	case SYS_page_map:
		return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *)a2);
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *)a2);
f0106abf:	e9 58 07 00 00       	jmp    f010721c <syscall+0xbd9>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uintptr_t)dstva < UTOP && ROUNDUP(dstva, PGSIZE) != dstva)
f0106ac4:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0106aca:	77 13                	ja     f0106adf <syscall+0x49c>
f0106acc:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
f0106ad2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0106ad7:	39 c6                	cmp    %eax,%esi
f0106ad9:	0f 85 67 01 00 00    	jne    f0106c46 <syscall+0x603>
		return -E_INVAL;
	curenv->env_ipc_recving = 1;
f0106adf:	e8 34 19 00 00       	call   f0108418 <cpunum>
f0106ae4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106aeb:	29 c2                	sub    %eax,%edx
f0106aed:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106af0:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0106af7:	c6 80 ac 00 00 00 01 	movb   $0x1,0xac(%eax)
	curenv->env_ipc_dstva = dstva;
f0106afe:	e8 15 19 00 00       	call   f0108418 <cpunum>
f0106b03:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106b0a:	29 c2                	sub    %eax,%edx
f0106b0c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106b0f:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0106b16:	89 b0 b0 00 00 00    	mov    %esi,0xb0(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0106b1c:	e8 f7 18 00 00       	call   f0108418 <cpunum>
f0106b21:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106b28:	29 c2                	sub    %eax,%edx
f0106b2a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106b2d:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0106b34:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	// If waiting queue is not empty, wake up one
	if (curenv->env_ipc_waiting_head != curenv->env_ipc_waiting_tail) {
f0106b3b:	e8 d8 18 00 00       	call   f0108418 <cpunum>
f0106b40:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106b47:	29 c2                	sub    %eax,%edx
f0106b49:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106b4c:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0106b53:	8b b0 c0 00 00 00    	mov    0xc0(%eax),%esi
f0106b59:	e8 ba 18 00 00       	call   f0108418 <cpunum>
f0106b5e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106b65:	29 c2                	sub    %eax,%edx
f0106b67:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106b6a:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0106b71:	3b b0 c4 00 00 00    	cmp    0xc4(%eax),%esi
f0106b77:	0f 84 c4 00 00 00    	je     f0106c41 <syscall+0x5fe>
		int r;
		struct Env *e;
		envid_t envid = curenv->env_ipc_waiting[curenv->env_ipc_waiting_head];
f0106b7d:	e8 96 18 00 00       	call   f0108418 <cpunum>
f0106b82:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106b89:	29 c2                	sub    %eax,%edx
f0106b8b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106b8e:	8b 34 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%esi
f0106b95:	e8 7e 18 00 00       	call   f0108418 <cpunum>
f0106b9a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106ba1:	29 c2                	sub    %eax,%edx
f0106ba3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106ba6:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0106bad:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
f0106bb3:	8b 9c 86 c8 00 00 00 	mov    0xc8(%esi,%eax,4),%ebx
		curenv->env_ipc_waiting_head = (curenv->env_ipc_waiting_head + 1) % MAXIPCWAITING;
f0106bba:	e8 59 18 00 00       	call   f0108418 <cpunum>
f0106bbf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106bc6:	29 c2                	sub    %eax,%edx
f0106bc8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106bcb:	8b 34 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%esi
f0106bd2:	e8 41 18 00 00       	call   f0108418 <cpunum>
f0106bd7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106bde:	29 c2                	sub    %eax,%edx
f0106be0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106be3:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0106bea:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
f0106bf0:	40                   	inc    %eax
f0106bf1:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0106bf6:	ba 00 00 00 00       	mov    $0x0,%edx
f0106bfb:	f7 f1                	div    %ecx
f0106bfd:	89 96 c0 00 00 00    	mov    %edx,0xc0(%esi)
		if ((r = envid2env(envid, &e, 0)) < 0)
f0106c03:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0106c0a:	00 
f0106c0b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0106c0e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c12:	89 1c 24             	mov    %ebx,(%esp)
f0106c15:	e8 41 cc ff ff       	call   f010385b <envid2env>
f0106c1a:	89 c6                	mov    %eax,%esi
f0106c1c:	85 c0                	test   %eax,%eax
f0106c1e:	0f 88 f8 05 00 00    	js     f010721c <syscall+0xbd9>
			return r;
		e->env_status = ENV_RUNNABLE;
f0106c24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106c27:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		cprintf("Wake up env %x.\n", e->env_id);
f0106c2e:	8b 40 48             	mov    0x48(%eax),%eax
f0106c31:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c35:	c7 04 24 7e a8 10 f0 	movl   $0xf010a87e,(%esp)
f0106c3c:	e8 49 d6 ff ff       	call   f010428a <cprintf>
	}
	sys_yield();
f0106c41:	e8 f2 f9 ff ff       	call   f0106638 <sys_yield>
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uintptr_t)dstva < UTOP && ROUNDUP(dstva, PGSIZE) != dstva)
		return -E_INVAL;
f0106c46:	be fd ff ff ff       	mov    $0xfffffffd,%esi
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *)a2);
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *)a2);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *)a1);
f0106c4b:	e9 cc 05 00 00       	jmp    f010721c <syscall+0xbd9>
{
	// LAB 4: Your code here.
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 0)) < 0)
f0106c50:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0106c57:	00 
f0106c58:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0106c5b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c5f:	89 34 24             	mov    %esi,(%esp)
f0106c62:	e8 f4 cb ff ff       	call   f010385b <envid2env>
f0106c67:	89 c6                	mov    %eax,%esi
f0106c69:	85 c0                	test   %eax,%eax
f0106c6b:	0f 88 ab 05 00 00    	js     f010721c <syscall+0xbd9>
		return r;
	if (!e->env_ipc_recving) {
f0106c71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106c74:	80 b8 ac 00 00 00 00 	cmpb   $0x0,0xac(%eax)
f0106c7b:	0f 85 0d 01 00 00    	jne    f0106d8e <syscall+0x74b>
		// If waiting queue is not full
		cprintf("env %x is busy: ", e->env_id);
f0106c81:	8b 40 48             	mov    0x48(%eax),%eax
f0106c84:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c88:	c7 04 24 8f a8 10 f0 	movl   $0xf010a88f,(%esp)
f0106c8f:	e8 f6 d5 ff ff       	call   f010428a <cprintf>
		if ((e->env_ipc_waiting_tail + 1) % MAXIPCWAITING != e->env_ipc_waiting_head) {
f0106c94:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0106c97:	8b 81 c4 00 00 00    	mov    0xc4(%ecx),%eax
f0106c9d:	40                   	inc    %eax
f0106c9e:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0106ca3:	ba 00 00 00 00       	mov    $0x0,%edx
f0106ca8:	f7 f3                	div    %ebx
f0106caa:	3b 91 c0 00 00 00    	cmp    0xc0(%ecx),%edx
f0106cb0:	74 75                	je     f0106d27 <syscall+0x6e4>
			// Block the sender
			cprintf("env %x is put in waiting queue.\n", curenv->env_id);
f0106cb2:	e8 61 17 00 00       	call   f0108418 <cpunum>
f0106cb7:	6b c0 74             	imul   $0x74,%eax,%eax
f0106cba:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0106cc0:	8b 40 48             	mov    0x48(%eax),%eax
f0106cc3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106cc7:	c7 04 24 cc a8 10 f0 	movl   $0xf010a8cc,(%esp)
f0106cce:	e8 b7 d5 ff ff       	call   f010428a <cprintf>
			curenv->env_status = ENV_NOT_RUNNABLE;
f0106cd3:	e8 40 17 00 00       	call   f0108418 <cpunum>
f0106cd8:	6b c0 74             	imul   $0x74,%eax,%eax
f0106cdb:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0106ce1:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
			e->env_ipc_waiting[e->env_ipc_waiting_tail] = curenv->env_id;
f0106ce8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0106ceb:	8b b3 c4 00 00 00    	mov    0xc4(%ebx),%esi
f0106cf1:	e8 22 17 00 00       	call   f0108418 <cpunum>
f0106cf6:	6b c0 74             	imul   $0x74,%eax,%eax
f0106cf9:	8b 80 28 90 35 f0    	mov    -0xfca6fd8(%eax),%eax
f0106cff:	8b 40 48             	mov    0x48(%eax),%eax
f0106d02:	89 84 b3 c8 00 00 00 	mov    %eax,0xc8(%ebx,%esi,4)
			e->env_ipc_waiting_tail = (e->env_ipc_waiting_tail + 1) % MAXIPCWAITING;
f0106d09:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0106d0c:	8b 81 c4 00 00 00    	mov    0xc4(%ecx),%eax
f0106d12:	40                   	inc    %eax
f0106d13:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0106d18:	ba 00 00 00 00       	mov    $0x0,%edx
f0106d1d:	f7 f3                	div    %ebx
f0106d1f:	89 91 c4 00 00 00    	mov    %edx,0xc4(%ecx)
f0106d25:	eb 0c                	jmp    f0106d33 <syscall+0x6f0>
		}
		else
			cprintf("waiting queue is full.\n");
f0106d27:	c7 04 24 a0 a8 10 f0 	movl   $0xf010a8a0,(%esp)
f0106d2e:	e8 57 d5 ff ff       	call   f010428a <cprintf>
		cprintf("Waiting envs: ");
f0106d33:	c7 04 24 b8 a8 10 f0 	movl   $0xf010a8b8,(%esp)
f0106d3a:	e8 4b d5 ff ff       	call   f010428a <cprintf>
		int i;
		for (i = 0; i < MAXIPCWAITING; i++)
f0106d3f:	bb 00 00 00 00       	mov    $0x0,%ebx
			cprintf("%x ", e->env_ipc_waiting[(i + e->env_ipc_waiting_head) % MAXIPCWAITING]);
f0106d44:	be 0a 00 00 00       	mov    $0xa,%esi
f0106d49:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0106d4c:	89 d8                	mov    %ebx,%eax
f0106d4e:	03 81 c0 00 00 00    	add    0xc0(%ecx),%eax
f0106d54:	ba 00 00 00 00       	mov    $0x0,%edx
f0106d59:	f7 f6                	div    %esi
f0106d5b:	8b 84 91 c8 00 00 00 	mov    0xc8(%ecx,%edx,4),%eax
f0106d62:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106d66:	c7 04 24 c7 a8 10 f0 	movl   $0xf010a8c7,(%esp)
f0106d6d:	e8 18 d5 ff ff       	call   f010428a <cprintf>
		}
		else
			cprintf("waiting queue is full.\n");
		cprintf("Waiting envs: ");
		int i;
		for (i = 0; i < MAXIPCWAITING; i++)
f0106d72:	43                   	inc    %ebx
f0106d73:	83 fb 0a             	cmp    $0xa,%ebx
f0106d76:	75 d1                	jne    f0106d49 <syscall+0x706>
			cprintf("%x ", e->env_ipc_waiting[(i + e->env_ipc_waiting_head) % MAXIPCWAITING]);
		cprintf("\n");
f0106d78:	c7 04 24 55 9f 10 f0 	movl   $0xf0109f55,(%esp)
f0106d7f:	e8 06 d5 ff ff       	call   f010428a <cprintf>
		return -E_IPC_NOT_RECV;
f0106d84:	be f8 ff ff ff       	mov    $0xfffffff8,%esi
f0106d89:	e9 8e 04 00 00       	jmp    f010721c <syscall+0xbd9>
	}
	if ((uintptr_t)srcva < UTOP) {
f0106d8e:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0106d94:	0f 87 ab 00 00 00    	ja     f0106e45 <syscall+0x802>
		if (ROUNDUP(srcva, PGSIZE) != srcva) return -E_INVAL;
f0106d9a:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
f0106da0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0106da5:	39 c3                	cmp    %eax,%ebx
f0106da7:	0f 85 ee 00 00 00    	jne    f0106e9b <syscall+0x858>
		pte_t *ppte;
		struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &ppte);
f0106dad:	e8 66 16 00 00       	call   f0108418 <cpunum>
f0106db2:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0106db5:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106db9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106dbd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106dc4:	29 c2                	sub    %eax,%edx
f0106dc6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106dc9:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0106dd0:	8b 40 60             	mov    0x60(%eax),%eax
f0106dd3:	89 04 24             	mov    %eax,(%esp)
f0106dd6:	e8 d5 a6 ff ff       	call   f01014b0 <page_lookup>
		//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
		//		address space.
		if (!pp) return -E_INVAL;
f0106ddb:	85 c0                	test   %eax,%eax
f0106ddd:	0f 84 c2 00 00 00    	je     f0106ea5 <syscall+0x862>
		//	-E_INVAL if srcva < UTOP and perm is inappropriate
		if ((perm & *ppte) != perm) return -E_INVAL;
f0106de3:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0106de6:	8b 12                	mov    (%edx),%edx
f0106de8:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0106deb:	21 d1                	and    %edx,%ecx
f0106ded:	39 4d 18             	cmp    %ecx,0x18(%ebp)
f0106df0:	0f 85 b9 00 00 00    	jne    f0106eaf <syscall+0x86c>
		//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
		//		current environment's address space.
		if ((perm & PTE_W) && !(*ppte & PTE_W)) return -E_INVAL;
f0106df6:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0106dfa:	74 09                	je     f0106e05 <syscall+0x7c2>
f0106dfc:	f6 c2 02             	test   $0x2,%dl
f0106dff:	0f 84 b4 00 00 00    	je     f0106eb9 <syscall+0x876>
		if ((uintptr_t)e->env_ipc_dstva < UTOP) {
f0106e05:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0106e08:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
f0106e0e:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f0106e14:	77 39                	ja     f0106e4f <syscall+0x80c>
			if ((r = page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm)) < 0)
f0106e16:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0106e19:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106e1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106e21:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106e25:	8b 42 60             	mov    0x60(%edx),%eax
f0106e28:	89 04 24             	mov    %eax,(%esp)
f0106e2b:	e8 92 a7 ff ff       	call   f01015c2 <page_insert>
f0106e30:	89 c6                	mov    %eax,%esi
f0106e32:	85 c0                	test   %eax,%eax
f0106e34:	0f 88 e2 03 00 00    	js     f010721c <syscall+0xbd9>
				return r;
			e->env_ipc_perm = perm;
f0106e3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106e3d:	89 98 bc 00 00 00    	mov    %ebx,0xbc(%eax)
f0106e43:	eb 0a                	jmp    f0106e4f <syscall+0x80c>
		}
	}
	else e->env_ipc_perm = 0;
f0106e45:	c7 80 bc 00 00 00 00 	movl   $0x0,0xbc(%eax)
f0106e4c:	00 00 00 
	e->env_ipc_recving = 0;
f0106e4f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0106e52:	c6 86 ac 00 00 00 00 	movb   $0x0,0xac(%esi)
	e->env_ipc_from = curenv->env_id;
f0106e59:	e8 ba 15 00 00       	call   f0108418 <cpunum>
f0106e5e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106e65:	29 c2                	sub    %eax,%edx
f0106e67:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106e6a:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0106e71:	8b 40 48             	mov    0x48(%eax),%eax
f0106e74:	89 86 b8 00 00 00    	mov    %eax,0xb8(%esi)
	e->env_ipc_value = value;
f0106e7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106e7d:	89 b8 b4 00 00 00    	mov    %edi,0xb4(%eax)
	e->env_status = ENV_RUNNABLE;
f0106e83:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;
f0106e8a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f0106e91:	be 00 00 00 00       	mov    $0x0,%esi
f0106e96:	e9 81 03 00 00       	jmp    f010721c <syscall+0xbd9>
			cprintf("%x ", e->env_ipc_waiting[(i + e->env_ipc_waiting_head) % MAXIPCWAITING]);
		cprintf("\n");
		return -E_IPC_NOT_RECV;
	}
	if ((uintptr_t)srcva < UTOP) {
		if (ROUNDUP(srcva, PGSIZE) != srcva) return -E_INVAL;
f0106e9b:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0106ea0:	e9 77 03 00 00       	jmp    f010721c <syscall+0xbd9>
		pte_t *ppte;
		struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &ppte);
		//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
		//		address space.
		if (!pp) return -E_INVAL;
f0106ea5:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0106eaa:	e9 6d 03 00 00       	jmp    f010721c <syscall+0xbd9>
		//	-E_INVAL if srcva < UTOP and perm is inappropriate
		if ((perm & *ppte) != perm) return -E_INVAL;
f0106eaf:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0106eb4:	e9 63 03 00 00       	jmp    f010721c <syscall+0xbd9>
		//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
		//		current environment's address space.
		if ((perm & PTE_W) && !(*ppte & PTE_W)) return -E_INVAL;
f0106eb9:	be fd ff ff ff       	mov    $0xfffffffd,%esi
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *)a2);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *)a1);
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f0106ebe:	e9 59 03 00 00       	jmp    f010721c <syscall+0xbd9>
// Returns 0 on success, < 0 on error.
static int
sys_env_set_divzero_upcall(envid_t envid, void *func) {
	int r;
	struct Env *e;
	if ((r = envid2env(envid, &e, 1)) < 0)
f0106ec3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106eca:	00 
f0106ecb:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0106ece:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ed2:	89 34 24             	mov    %esi,(%esp)
f0106ed5:	e8 81 c9 ff ff       	call   f010385b <envid2env>
f0106eda:	89 c6                	mov    %eax,%esi
f0106edc:	85 c0                	test   %eax,%eax
f0106ede:	0f 88 38 03 00 00    	js     f010721c <syscall+0xbd9>
		return r;
	e->env_divzero_upcall = func;
f0106ee4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106ee7:	89 78 68             	mov    %edi,0x68(%eax)
	return 0;
f0106eea:	be 00 00 00 00       	mov    $0x0,%esi
	case SYS_ipc_recv:
		return sys_ipc_recv((void *)a1);
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *)a3, a4);
	case SYS_env_set_divzero_upcall:
		return sys_env_set_divzero_upcall(a1, (void *)a2);
f0106eef:	e9 28 03 00 00       	jmp    f010721c <syscall+0xbd9>
// Returns 0 on success, < 0 on error.
static int
sys_env_set_debug_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
f0106ef4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106efb:	00 
f0106efc:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0106eff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f03:	89 34 24             	mov    %esi,(%esp)
f0106f06:	e8 50 c9 ff ff       	call   f010385b <envid2env>
f0106f0b:	89 c6                	mov    %eax,%esi
f0106f0d:	85 c0                	test   %eax,%eax
f0106f0f:	0f 88 07 03 00 00    	js     f010721c <syscall+0xbd9>
        return r;
    e->env_debug_upcall = func;
f0106f15:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106f18:	89 78 6c             	mov    %edi,0x6c(%eax)
    return 0;
f0106f1b:	be 00 00 00 00       	mov    $0x0,%esi
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *)a3, a4);
	case SYS_env_set_divzero_upcall:
		return sys_env_set_divzero_upcall(a1, (void *)a2);
	case SYS_env_set_debug_upcall:
        return sys_env_set_debug_upcall(a1, (void *)a2);
f0106f20:	e9 f7 02 00 00       	jmp    f010721c <syscall+0xbd9>
// Returns 0 on success, < 0 on error.
static int
sys_env_set_nmskint_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
f0106f25:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106f2c:	00 
f0106f2d:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0106f30:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f34:	89 34 24             	mov    %esi,(%esp)
f0106f37:	e8 1f c9 ff ff       	call   f010385b <envid2env>
f0106f3c:	89 c6                	mov    %eax,%esi
f0106f3e:	85 c0                	test   %eax,%eax
f0106f40:	0f 88 d6 02 00 00    	js     f010721c <syscall+0xbd9>
        return r;
    e->env_nmskint_upcall = func;
f0106f46:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106f49:	89 78 70             	mov    %edi,0x70(%eax)
    return 0;
f0106f4c:	be 00 00 00 00       	mov    $0x0,%esi
	case SYS_env_set_divzero_upcall:
		return sys_env_set_divzero_upcall(a1, (void *)a2);
	case SYS_env_set_debug_upcall:
        return sys_env_set_debug_upcall(a1, (void *)a2);
    case SYS_env_set_nmskint_upcall:
        return sys_env_set_nmskint_upcall(a1, (void *)a2);
f0106f51:	e9 c6 02 00 00       	jmp    f010721c <syscall+0xbd9>
// Returns 0 on success, < 0 on error.
static int
sys_env_set_bpoint_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
f0106f56:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106f5d:	00 
f0106f5e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0106f61:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f65:	89 34 24             	mov    %esi,(%esp)
f0106f68:	e8 ee c8 ff ff       	call   f010385b <envid2env>
f0106f6d:	89 c6                	mov    %eax,%esi
f0106f6f:	85 c0                	test   %eax,%eax
f0106f71:	0f 88 a5 02 00 00    	js     f010721c <syscall+0xbd9>
        return r;
    e->env_bpoint_upcall = func;
f0106f77:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106f7a:	89 78 74             	mov    %edi,0x74(%eax)
    return 0;
f0106f7d:	be 00 00 00 00       	mov    $0x0,%esi
	case SYS_env_set_debug_upcall:
        return sys_env_set_debug_upcall(a1, (void *)a2);
    case SYS_env_set_nmskint_upcall:
        return sys_env_set_nmskint_upcall(a1, (void *)a2);
    case SYS_env_set_bpoint_upcall:
        return sys_env_set_bpoint_upcall(a1, (void *)a2);
f0106f82:	e9 95 02 00 00       	jmp    f010721c <syscall+0xbd9>
// Returns 0 on success, < 0 on error.
static int
sys_env_set_oflow_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
f0106f87:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106f8e:	00 
f0106f8f:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0106f92:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f96:	89 34 24             	mov    %esi,(%esp)
f0106f99:	e8 bd c8 ff ff       	call   f010385b <envid2env>
f0106f9e:	89 c6                	mov    %eax,%esi
f0106fa0:	85 c0                	test   %eax,%eax
f0106fa2:	0f 88 74 02 00 00    	js     f010721c <syscall+0xbd9>
        return r;
    e->env_oflow_upcall = func;
f0106fa8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106fab:	89 78 78             	mov    %edi,0x78(%eax)
    return 0;
f0106fae:	be 00 00 00 00       	mov    $0x0,%esi
    case SYS_env_set_nmskint_upcall:
        return sys_env_set_nmskint_upcall(a1, (void *)a2);
    case SYS_env_set_bpoint_upcall:
        return sys_env_set_bpoint_upcall(a1, (void *)a2);
    case SYS_env_set_oflow_upcall:
        return sys_env_set_oflow_upcall(a1, (void *)a2);
f0106fb3:	e9 64 02 00 00       	jmp    f010721c <syscall+0xbd9>
// Returns 0 on success, < 0 on error.
static int
sys_env_set_bdschk_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
f0106fb8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106fbf:	00 
f0106fc0:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0106fc3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106fc7:	89 34 24             	mov    %esi,(%esp)
f0106fca:	e8 8c c8 ff ff       	call   f010385b <envid2env>
f0106fcf:	89 c6                	mov    %eax,%esi
f0106fd1:	85 c0                	test   %eax,%eax
f0106fd3:	0f 88 43 02 00 00    	js     f010721c <syscall+0xbd9>
        return r;
    e->env_bdschk_upcall = func;
f0106fd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106fdc:	89 78 7c             	mov    %edi,0x7c(%eax)
    return 0;
f0106fdf:	be 00 00 00 00       	mov    $0x0,%esi
    case SYS_env_set_bpoint_upcall:
        return sys_env_set_bpoint_upcall(a1, (void *)a2);
    case SYS_env_set_oflow_upcall:
        return sys_env_set_oflow_upcall(a1, (void *)a2);
    case SYS_env_set_bdschk_upcall:
        return sys_env_set_bdschk_upcall(a1, (void *)a2);
f0106fe4:	e9 33 02 00 00       	jmp    f010721c <syscall+0xbd9>
// Returns 0 on success, < 0 on error.
static int
sys_env_set_illopcd_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
f0106fe9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106ff0:	00 
f0106ff1:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0106ff4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ff8:	89 34 24             	mov    %esi,(%esp)
f0106ffb:	e8 5b c8 ff ff       	call   f010385b <envid2env>
f0107000:	89 c6                	mov    %eax,%esi
f0107002:	85 c0                	test   %eax,%eax
f0107004:	0f 88 12 02 00 00    	js     f010721c <syscall+0xbd9>
        return r;
    e->env_illopcd_upcall = func;
f010700a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010700d:	89 b8 80 00 00 00    	mov    %edi,0x80(%eax)
    return 0;
f0107013:	be 00 00 00 00       	mov    $0x0,%esi
    case SYS_env_set_oflow_upcall:
        return sys_env_set_oflow_upcall(a1, (void *)a2);
    case SYS_env_set_bdschk_upcall:
        return sys_env_set_bdschk_upcall(a1, (void *)a2);
    case SYS_env_set_illopcd_upcall:
        return sys_env_set_illopcd_upcall(a1, (void *)a2);
f0107018:	e9 ff 01 00 00       	jmp    f010721c <syscall+0xbd9>
// Returns 0 on success, < 0 on error.
static int
sys_env_set_dvcntavl_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
f010701d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0107024:	00 
f0107025:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0107028:	89 44 24 04          	mov    %eax,0x4(%esp)
f010702c:	89 34 24             	mov    %esi,(%esp)
f010702f:	e8 27 c8 ff ff       	call   f010385b <envid2env>
f0107034:	89 c6                	mov    %eax,%esi
f0107036:	85 c0                	test   %eax,%eax
f0107038:	0f 88 de 01 00 00    	js     f010721c <syscall+0xbd9>
        return r;
    e->env_dvcntavl_upcall = func;
f010703e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107041:	89 b8 84 00 00 00    	mov    %edi,0x84(%eax)
    return 0;
f0107047:	be 00 00 00 00       	mov    $0x0,%esi
    case SYS_env_set_bdschk_upcall:
        return sys_env_set_bdschk_upcall(a1, (void *)a2);
    case SYS_env_set_illopcd_upcall:
        return sys_env_set_illopcd_upcall(a1, (void *)a2);
    case SYS_env_set_dvcntavl_upcall:
        return sys_env_set_dvcntavl_upcall(a1, (void *)a2);
f010704c:	e9 cb 01 00 00       	jmp    f010721c <syscall+0xbd9>
// Returns 0 on success, < 0 on error.
static int
sys_env_set_dbfault_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
f0107051:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0107058:	00 
f0107059:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010705c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107060:	89 34 24             	mov    %esi,(%esp)
f0107063:	e8 f3 c7 ff ff       	call   f010385b <envid2env>
f0107068:	89 c6                	mov    %eax,%esi
f010706a:	85 c0                	test   %eax,%eax
f010706c:	0f 88 aa 01 00 00    	js     f010721c <syscall+0xbd9>
        return r;
    e->env_dbfault_upcall = func;
f0107072:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107075:	89 b8 88 00 00 00    	mov    %edi,0x88(%eax)
    return 0;
f010707b:	be 00 00 00 00       	mov    $0x0,%esi
    case SYS_env_set_illopcd_upcall:
        return sys_env_set_illopcd_upcall(a1, (void *)a2);
    case SYS_env_set_dvcntavl_upcall:
        return sys_env_set_dvcntavl_upcall(a1, (void *)a2);
    case SYS_env_set_dbfault_upcall:
        return sys_env_set_dbfault_upcall(a1, (void *)a2);
f0107080:	e9 97 01 00 00       	jmp    f010721c <syscall+0xbd9>
// Returns 0 on success, < 0 on error.
static int
sys_env_set_ivldtss_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
f0107085:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010708c:	00 
f010708d:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0107090:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107094:	89 34 24             	mov    %esi,(%esp)
f0107097:	e8 bf c7 ff ff       	call   f010385b <envid2env>
f010709c:	89 c6                	mov    %eax,%esi
f010709e:	85 c0                	test   %eax,%eax
f01070a0:	0f 88 76 01 00 00    	js     f010721c <syscall+0xbd9>
        return r;
    e->env_ivldtss_upcall = func;
f01070a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01070a9:	89 b8 8c 00 00 00    	mov    %edi,0x8c(%eax)
    return 0;
f01070af:	be 00 00 00 00       	mov    $0x0,%esi
    case SYS_env_set_dvcntavl_upcall:
        return sys_env_set_dvcntavl_upcall(a1, (void *)a2);
    case SYS_env_set_dbfault_upcall:
        return sys_env_set_dbfault_upcall(a1, (void *)a2);
    case SYS_env_set_ivldtss_upcall:
        return sys_env_set_ivldtss_upcall(a1, (void *)a2);
f01070b4:	e9 63 01 00 00       	jmp    f010721c <syscall+0xbd9>
// Returns 0 on success, < 0 on error.
static int
sys_env_set_segntprst_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
f01070b9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01070c0:	00 
f01070c1:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01070c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01070c8:	89 34 24             	mov    %esi,(%esp)
f01070cb:	e8 8b c7 ff ff       	call   f010385b <envid2env>
f01070d0:	89 c6                	mov    %eax,%esi
f01070d2:	85 c0                	test   %eax,%eax
f01070d4:	0f 88 42 01 00 00    	js     f010721c <syscall+0xbd9>
        return r;
    e->env_segntprst_upcall = func;
f01070da:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01070dd:	89 b8 90 00 00 00    	mov    %edi,0x90(%eax)
    return 0;
f01070e3:	be 00 00 00 00       	mov    $0x0,%esi
    case SYS_env_set_dbfault_upcall:
        return sys_env_set_dbfault_upcall(a1, (void *)a2);
    case SYS_env_set_ivldtss_upcall:
        return sys_env_set_ivldtss_upcall(a1, (void *)a2);
    case SYS_env_set_segntprst_upcall:
        return sys_env_set_segntprst_upcall(a1, (void *)a2);
f01070e8:	e9 2f 01 00 00       	jmp    f010721c <syscall+0xbd9>
// Returns 0 on success, < 0 on error.
static int
sys_env_set_stkexception_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
f01070ed:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01070f4:	00 
f01070f5:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01070f8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01070fc:	89 34 24             	mov    %esi,(%esp)
f01070ff:	e8 57 c7 ff ff       	call   f010385b <envid2env>
f0107104:	89 c6                	mov    %eax,%esi
f0107106:	85 c0                	test   %eax,%eax
f0107108:	0f 88 0e 01 00 00    	js     f010721c <syscall+0xbd9>
        return r;
    e->env_stkexception_upcall = func;
f010710e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107111:	89 b8 94 00 00 00    	mov    %edi,0x94(%eax)
    return 0;
f0107117:	be 00 00 00 00       	mov    $0x0,%esi
    case SYS_env_set_ivldtss_upcall:
        return sys_env_set_ivldtss_upcall(a1, (void *)a2);
    case SYS_env_set_segntprst_upcall:
        return sys_env_set_segntprst_upcall(a1, (void *)a2);
    case SYS_env_set_stkexception_upcall:
        return sys_env_set_stkexception_upcall(a1, (void *)a2);
f010711c:	e9 fb 00 00 00       	jmp    f010721c <syscall+0xbd9>
// Returns 0 on success, < 0 on error.
static int
sys_env_set_gpfault_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
f0107121:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0107128:	00 
f0107129:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010712c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107130:	89 34 24             	mov    %esi,(%esp)
f0107133:	e8 23 c7 ff ff       	call   f010385b <envid2env>
f0107138:	89 c6                	mov    %eax,%esi
f010713a:	85 c0                	test   %eax,%eax
f010713c:	0f 88 da 00 00 00    	js     f010721c <syscall+0xbd9>
        return r;
    e->env_gpfault_upcall = func;
f0107142:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107145:	89 b8 98 00 00 00    	mov    %edi,0x98(%eax)
    return 0;
f010714b:	be 00 00 00 00       	mov    $0x0,%esi
    case SYS_env_set_segntprst_upcall:
        return sys_env_set_segntprst_upcall(a1, (void *)a2);
    case SYS_env_set_stkexception_upcall:
        return sys_env_set_stkexception_upcall(a1, (void *)a2);
    case SYS_env_set_gpfault_upcall:
        return sys_env_set_gpfault_upcall(a1, (void *)a2);
f0107150:	e9 c7 00 00 00       	jmp    f010721c <syscall+0xbd9>
// Returns 0 on success, < 0 on error.
static int
sys_env_set_fperror_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
f0107155:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010715c:	00 
f010715d:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0107160:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107164:	89 34 24             	mov    %esi,(%esp)
f0107167:	e8 ef c6 ff ff       	call   f010385b <envid2env>
f010716c:	89 c6                	mov    %eax,%esi
f010716e:	85 c0                	test   %eax,%eax
f0107170:	0f 88 a6 00 00 00    	js     f010721c <syscall+0xbd9>
        return r;
    e->env_fperror_upcall = func;
f0107176:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107179:	89 b8 9c 00 00 00    	mov    %edi,0x9c(%eax)
    return 0;
f010717f:	be 00 00 00 00       	mov    $0x0,%esi
    case SYS_env_set_stkexception_upcall:
        return sys_env_set_stkexception_upcall(a1, (void *)a2);
    case SYS_env_set_gpfault_upcall:
        return sys_env_set_gpfault_upcall(a1, (void *)a2);
    case SYS_env_set_fperror_upcall:
        return sys_env_set_fperror_upcall(a1, (void *)a2);
f0107184:	e9 93 00 00 00       	jmp    f010721c <syscall+0xbd9>
// Returns 0 on success, < 0 on error.
static int
sys_env_set_algchk_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
f0107189:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0107190:	00 
f0107191:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0107194:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107198:	89 34 24             	mov    %esi,(%esp)
f010719b:	e8 bb c6 ff ff       	call   f010385b <envid2env>
f01071a0:	89 c6                	mov    %eax,%esi
f01071a2:	85 c0                	test   %eax,%eax
f01071a4:	78 76                	js     f010721c <syscall+0xbd9>
        return r;
    e->env_algchk_upcall = func;
f01071a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01071a9:	89 b8 a0 00 00 00    	mov    %edi,0xa0(%eax)
    return 0;
f01071af:	be 00 00 00 00       	mov    $0x0,%esi
    case SYS_env_set_gpfault_upcall:
        return sys_env_set_gpfault_upcall(a1, (void *)a2);
    case SYS_env_set_fperror_upcall:
        return sys_env_set_fperror_upcall(a1, (void *)a2);
    case SYS_env_set_algchk_upcall:
        return sys_env_set_algchk_upcall(a1, (void *)a2);
f01071b4:	eb 66                	jmp    f010721c <syscall+0xbd9>
// Returns 0 on success, < 0 on error.
static int
sys_env_set_mchchk_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
f01071b6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01071bd:	00 
f01071be:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01071c1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01071c5:	89 34 24             	mov    %esi,(%esp)
f01071c8:	e8 8e c6 ff ff       	call   f010385b <envid2env>
f01071cd:	89 c6                	mov    %eax,%esi
f01071cf:	85 c0                	test   %eax,%eax
f01071d1:	78 49                	js     f010721c <syscall+0xbd9>
        return r;
    e->env_mchchk_upcall = func;
f01071d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01071d6:	89 b8 a4 00 00 00    	mov    %edi,0xa4(%eax)
    return 0;
f01071dc:	be 00 00 00 00       	mov    $0x0,%esi
    case SYS_env_set_fperror_upcall:
        return sys_env_set_fperror_upcall(a1, (void *)a2);
    case SYS_env_set_algchk_upcall:
        return sys_env_set_algchk_upcall(a1, (void *)a2);
    case SYS_env_set_mchchk_upcall:
        return sys_env_set_mchchk_upcall(a1, (void *)a2);
f01071e1:	eb 39                	jmp    f010721c <syscall+0xbd9>
// Returns 0 on success, < 0 on error.
static int
sys_env_set_SIMDfperror_upcall(envid_t envid, void *func) {
    int r;
    struct Env *e;
    if ((r = envid2env(envid, &e, 1)) < 0)
f01071e3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01071ea:	00 
f01071eb:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01071ee:	89 44 24 04          	mov    %eax,0x4(%esp)
f01071f2:	89 34 24             	mov    %esi,(%esp)
f01071f5:	e8 61 c6 ff ff       	call   f010385b <envid2env>
f01071fa:	89 c6                	mov    %eax,%esi
f01071fc:	85 c0                	test   %eax,%eax
f01071fe:	78 1c                	js     f010721c <syscall+0xbd9>
        return r;
    e->env_SIMDfperror_upcall = func;
f0107200:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107203:	89 b8 a8 00 00 00    	mov    %edi,0xa8(%eax)
    return 0;
f0107209:	be 00 00 00 00       	mov    $0x0,%esi
    case SYS_env_set_algchk_upcall:
        return sys_env_set_algchk_upcall(a1, (void *)a2);
    case SYS_env_set_mchchk_upcall:
        return sys_env_set_mchchk_upcall(a1, (void *)a2);
    case SYS_env_set_SIMDfperror_upcall:
        return sys_env_set_SIMDfperror_upcall(a1, (void *)a2);
f010720e:	eb 0c                	jmp    f010721c <syscall+0xbd9>
	default:
		// should I change it into -E_INVAL?
		return -E_NO_SYS;
f0107210:	be f9 ff ff ff       	mov    $0xfffffff9,%esi
f0107215:	eb 05                	jmp    f010721c <syscall+0xbd9>
		return sys_cgetc();
	case SYS_getenvid:
		return sys_getenvid();
	case SYS_env_destroy:
		sys_env_destroy(a1);
		return 0;
f0107217:	be 00 00 00 00       	mov    $0x0,%esi
        return sys_env_set_SIMDfperror_upcall(a1, (void *)a2);
	default:
		// should I change it into -E_INVAL?
		return -E_NO_SYS;
	}
}
f010721c:	89 f0                	mov    %esi,%eax
f010721e:	83 c4 3c             	add    $0x3c,%esp
f0107221:	5b                   	pop    %ebx
f0107222:	5e                   	pop    %esi
f0107223:	5f                   	pop    %edi
f0107224:	5d                   	pop    %ebp
f0107225:	c3                   	ret    
	...

f0107228 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0107228:	55                   	push   %ebp
f0107229:	89 e5                	mov    %esp,%ebp
f010722b:	57                   	push   %edi
f010722c:	56                   	push   %esi
f010722d:	53                   	push   %ebx
f010722e:	83 ec 14             	sub    $0x14,%esp
f0107231:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0107234:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0107237:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010723a:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f010723d:	8b 1a                	mov    (%edx),%ebx
f010723f:	8b 01                	mov    (%ecx),%eax
f0107241:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0107244:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f010724b:	e9 83 00 00 00       	jmp    f01072d3 <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f0107250:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107253:	01 d8                	add    %ebx,%eax
f0107255:	89 c7                	mov    %eax,%edi
f0107257:	c1 ef 1f             	shr    $0x1f,%edi
f010725a:	01 c7                	add    %eax,%edi
f010725c:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010725e:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0107261:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0107264:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0107268:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010726a:	eb 01                	jmp    f010726d <stab_binsearch+0x45>
			m--;
f010726c:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010726d:	39 c3                	cmp    %eax,%ebx
f010726f:	7f 1e                	jg     f010728f <stab_binsearch+0x67>
f0107271:	0f b6 0a             	movzbl (%edx),%ecx
f0107274:	83 ea 0c             	sub    $0xc,%edx
f0107277:	39 f1                	cmp    %esi,%ecx
f0107279:	75 f1                	jne    f010726c <stab_binsearch+0x44>
f010727b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010727e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0107281:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0107284:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0107288:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010728b:	76 18                	jbe    f01072a5 <stab_binsearch+0x7d>
f010728d:	eb 05                	jmp    f0107294 <stab_binsearch+0x6c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010728f:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0107292:	eb 3f                	jmp    f01072d3 <stab_binsearch+0xab>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0107294:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0107297:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f0107299:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010729c:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01072a3:	eb 2e                	jmp    f01072d3 <stab_binsearch+0xab>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01072a5:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01072a8:	73 15                	jae    f01072bf <stab_binsearch+0x97>
			*region_right = m - 1;
f01072aa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01072ad:	49                   	dec    %ecx
f01072ae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01072b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01072b4:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01072b6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01072bd:	eb 14                	jmp    f01072d3 <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01072bf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01072c2:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01072c5:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f01072c7:	ff 45 0c             	incl   0xc(%ebp)
f01072ca:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01072cc:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01072d3:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01072d6:	0f 8e 74 ff ff ff    	jle    f0107250 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01072dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01072e0:	75 0d                	jne    f01072ef <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f01072e2:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01072e5:	8b 02                	mov    (%edx),%eax
f01072e7:	48                   	dec    %eax
f01072e8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01072eb:	89 01                	mov    %eax,(%ecx)
f01072ed:	eb 2a                	jmp    f0107319 <stab_binsearch+0xf1>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01072ef:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01072f2:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01072f4:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01072f7:	8b 0a                	mov    (%edx),%ecx
f01072f9:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01072fc:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f01072ff:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0107303:	eb 01                	jmp    f0107306 <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0107305:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0107306:	39 c8                	cmp    %ecx,%eax
f0107308:	7e 0a                	jle    f0107314 <stab_binsearch+0xec>
		     l > *region_left && stabs[l].n_type != type;
f010730a:	0f b6 1a             	movzbl (%edx),%ebx
f010730d:	83 ea 0c             	sub    $0xc,%edx
f0107310:	39 f3                	cmp    %esi,%ebx
f0107312:	75 f1                	jne    f0107305 <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f0107314:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0107317:	89 02                	mov    %eax,(%edx)
	}
}
f0107319:	83 c4 14             	add    $0x14,%esp
f010731c:	5b                   	pop    %ebx
f010731d:	5e                   	pop    %esi
f010731e:	5f                   	pop    %edi
f010731f:	5d                   	pop    %ebp
f0107320:	c3                   	ret    

f0107321 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0107321:	55                   	push   %ebp
f0107322:	89 e5                	mov    %esp,%ebp
f0107324:	57                   	push   %edi
f0107325:	56                   	push   %esi
f0107326:	53                   	push   %ebx
f0107327:	83 ec 5c             	sub    $0x5c,%esp
f010732a:	8b 75 08             	mov    0x8(%ebp),%esi
f010732d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0107330:	c7 03 68 a9 10 f0    	movl   $0xf010a968,(%ebx)
	info->eip_line = 0;
f0107336:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010733d:	c7 43 08 68 a9 10 f0 	movl   $0xf010a968,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0107344:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010734b:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010734e:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0107355:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010735b:	0f 87 e1 00 00 00    	ja     f0107442 <debuginfo_eip+0x121>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0107361:	e8 b2 10 00 00       	call   f0108418 <cpunum>
f0107366:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010736d:	00 
f010736e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0107375:	00 
f0107376:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f010737d:	00 
f010737e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0107385:	29 c2                	sub    %eax,%edx
f0107387:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010738a:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0107391:	89 04 24             	mov    %eax,(%esp)
f0107394:	e8 62 c3 ff ff       	call   f01036fb <user_mem_check>
f0107399:	85 c0                	test   %eax,%eax
f010739b:	0f 85 5d 02 00 00    	jne    f01075fe <debuginfo_eip+0x2dd>
			return -1;

		stabs = usd->stabs;
f01073a1:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f01073a7:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f01073aa:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f01073b0:	a1 08 00 20 00       	mov    0x200008,%eax
f01073b5:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f01073b8:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f01073be:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f01073c1:	e8 52 10 00 00       	call   f0108418 <cpunum>
f01073c6:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01073cd:	00 
f01073ce:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f01073d5:	00 
f01073d6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01073d9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01073dd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01073e4:	29 c2                	sub    %eax,%edx
f01073e6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01073e9:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f01073f0:	89 04 24             	mov    %eax,(%esp)
f01073f3:	e8 03 c3 ff ff       	call   f01036fb <user_mem_check>
f01073f8:	85 c0                	test   %eax,%eax
f01073fa:	0f 85 05 02 00 00    	jne    f0107605 <debuginfo_eip+0x2e4>
			return -1;
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
f0107400:	e8 13 10 00 00       	call   f0108418 <cpunum>
f0107405:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010740c:	00 
f010740d:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0107410:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0107413:	89 54 24 08          	mov    %edx,0x8(%esp)
f0107417:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010741a:	89 54 24 04          	mov    %edx,0x4(%esp)
f010741e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0107425:	29 c2                	sub    %eax,%edx
f0107427:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010742a:	8b 04 85 28 90 35 f0 	mov    -0xfca6fd8(,%eax,4),%eax
f0107431:	89 04 24             	mov    %eax,(%esp)
f0107434:	e8 c2 c2 ff ff       	call   f01036fb <user_mem_check>
f0107439:	85 c0                	test   %eax,%eax
f010743b:	74 1f                	je     f010745c <debuginfo_eip+0x13b>
f010743d:	e9 ca 01 00 00       	jmp    f010760c <debuginfo_eip+0x2eb>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0107442:	c7 45 c0 9f 3e 12 f0 	movl   $0xf0123e9f,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0107449:	c7 45 bc 29 83 11 f0 	movl   $0xf0118329,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0107450:	bf 28 83 11 f0       	mov    $0xf0118328,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0107455:	c7 45 c4 58 ae 10 f0 	movl   $0xf010ae58,-0x3c(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010745c:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010745f:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f0107462:	0f 83 ab 01 00 00    	jae    f0107613 <debuginfo_eip+0x2f2>
f0107468:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f010746c:	0f 85 a8 01 00 00    	jne    f010761a <debuginfo_eip+0x2f9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0107472:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0107479:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f010747c:	c1 ff 02             	sar    $0x2,%edi
f010747f:	8d 04 bf             	lea    (%edi,%edi,4),%eax
f0107482:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0107485:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0107488:	89 c2                	mov    %eax,%edx
f010748a:	c1 e2 08             	shl    $0x8,%edx
f010748d:	01 d0                	add    %edx,%eax
f010748f:	89 c2                	mov    %eax,%edx
f0107491:	c1 e2 10             	shl    $0x10,%edx
f0107494:	01 d0                	add    %edx,%eax
f0107496:	8d 44 47 ff          	lea    -0x1(%edi,%eax,2),%eax
f010749a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010749d:	89 74 24 04          	mov    %esi,0x4(%esp)
f01074a1:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01074a8:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01074ab:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01074ae:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01074b1:	e8 72 fd ff ff       	call   f0107228 <stab_binsearch>
	if (lfile == 0)
f01074b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01074b9:	85 c0                	test   %eax,%eax
f01074bb:	0f 84 60 01 00 00    	je     f0107621 <debuginfo_eip+0x300>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01074c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01074c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01074c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01074ca:	89 74 24 04          	mov    %esi,0x4(%esp)
f01074ce:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01074d5:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01074d8:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01074db:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01074de:	e8 45 fd ff ff       	call   f0107228 <stab_binsearch>

	if (lfun <= rfun) {
f01074e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01074e6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01074e9:	39 d0                	cmp    %edx,%eax
f01074eb:	7f 32                	jg     f010751f <debuginfo_eip+0x1fe>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01074ed:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01074f0:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01074f3:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f01074f6:	8b 39                	mov    (%ecx),%edi
f01074f8:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f01074fb:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01074fe:	2b 7d bc             	sub    -0x44(%ebp),%edi
f0107501:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0107504:	73 09                	jae    f010750f <debuginfo_eip+0x1ee>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0107506:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0107509:	03 7d bc             	add    -0x44(%ebp),%edi
f010750c:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010750f:	8b 49 08             	mov    0x8(%ecx),%ecx
f0107512:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0107515:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0107517:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010751a:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010751d:	eb 0f                	jmp    f010752e <debuginfo_eip+0x20d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010751f:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0107522:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107525:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0107528:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010752b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010752e:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0107535:	00 
f0107536:	8b 43 08             	mov    0x8(%ebx),%eax
f0107539:	89 04 24             	mov    %eax,(%esp)
f010753c:	e8 91 08 00 00       	call   f0107dd2 <strfind>
f0107541:	2b 43 08             	sub    0x8(%ebx),%eax
f0107544:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0107547:	89 74 24 04          	mov    %esi,0x4(%esp)
f010754b:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0107552:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0107555:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0107558:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010755b:	e8 c8 fc ff ff       	call   f0107228 <stab_binsearch>
	if (lline <= rline)
f0107560:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107563:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0107566:	7f 10                	jg     f0107578 <debuginfo_eip+0x257>
		info->eip_line = stabs[rline].n_desc;
f0107568:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010756b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010756e:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f0107573:	89 43 04             	mov    %eax,0x4(%ebx)
f0107576:	eb 07                	jmp    f010757f <debuginfo_eip+0x25e>
	else
		info->eip_line = -1;
f0107578:	c7 43 04 ff ff ff ff 	movl   $0xffffffff,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010757f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0107582:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0107585:	8d 14 40             	lea    (%eax,%eax,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0107588:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010758b:	8d 54 97 08          	lea    0x8(%edi,%edx,4),%edx
f010758f:	89 5d b8             	mov    %ebx,-0x48(%ebp)
f0107592:	eb 04                	jmp    f0107598 <debuginfo_eip+0x277>
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0107594:	48                   	dec    %eax
f0107595:	83 ea 0c             	sub    $0xc,%edx
f0107598:	89 c7                	mov    %eax,%edi
f010759a:	39 c6                	cmp    %eax,%esi
f010759c:	7f 28                	jg     f01075c6 <debuginfo_eip+0x2a5>
	       && stabs[lline].n_type != N_SOL
f010759e:	8a 4a fc             	mov    -0x4(%edx),%cl
f01075a1:	80 f9 84             	cmp    $0x84,%cl
f01075a4:	0f 84 92 00 00 00    	je     f010763c <debuginfo_eip+0x31b>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01075aa:	80 f9 64             	cmp    $0x64,%cl
f01075ad:	75 e5                	jne    f0107594 <debuginfo_eip+0x273>
f01075af:	83 3a 00             	cmpl   $0x0,(%edx)
f01075b2:	74 e0                	je     f0107594 <debuginfo_eip+0x273>
f01075b4:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f01075b7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01075ba:	e9 83 00 00 00       	jmp    f0107642 <debuginfo_eip+0x321>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f01075bf:	03 45 bc             	add    -0x44(%ebp),%eax
f01075c2:	89 03                	mov    %eax,(%ebx)
f01075c4:	eb 03                	jmp    f01075c9 <debuginfo_eip+0x2a8>
f01075c6:	8b 5d b8             	mov    -0x48(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01075c9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01075cc:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01075cf:	39 f2                	cmp    %esi,%edx
f01075d1:	7d 55                	jge    f0107628 <debuginfo_eip+0x307>
		for (lline = lfun + 1;
f01075d3:	42                   	inc    %edx
f01075d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01075d7:	89 d0                	mov    %edx,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01075d9:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01075dc:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01075df:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01075e3:	eb 03                	jmp    f01075e8 <debuginfo_eip+0x2c7>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01075e5:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01075e8:	39 f0                	cmp    %esi,%eax
f01075ea:	7d 43                	jge    f010762f <debuginfo_eip+0x30e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01075ec:	8a 0a                	mov    (%edx),%cl
f01075ee:	40                   	inc    %eax
f01075ef:	83 c2 0c             	add    $0xc,%edx
f01075f2:	80 f9 a0             	cmp    $0xa0,%cl
f01075f5:	74 ee                	je     f01075e5 <debuginfo_eip+0x2c4>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01075f7:	b8 00 00 00 00       	mov    $0x0,%eax
f01075fc:	eb 36                	jmp    f0107634 <debuginfo_eip+0x313>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f01075fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107603:	eb 2f                	jmp    f0107634 <debuginfo_eip+0x313>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;
f0107605:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010760a:	eb 28                	jmp    f0107634 <debuginfo_eip+0x313>
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
			return -1;
f010760c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107611:	eb 21                	jmp    f0107634 <debuginfo_eip+0x313>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0107613:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107618:	eb 1a                	jmp    f0107634 <debuginfo_eip+0x313>
f010761a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010761f:	eb 13                	jmp    f0107634 <debuginfo_eip+0x313>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0107621:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107626:	eb 0c                	jmp    f0107634 <debuginfo_eip+0x313>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0107628:	b8 00 00 00 00       	mov    $0x0,%eax
f010762d:	eb 05                	jmp    f0107634 <debuginfo_eip+0x313>
f010762f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0107634:	83 c4 5c             	add    $0x5c,%esp
f0107637:	5b                   	pop    %ebx
f0107638:	5e                   	pop    %esi
f0107639:	5f                   	pop    %edi
f010763a:	5d                   	pop    %ebp
f010763b:	c3                   	ret    
f010763c:	8b 5d b8             	mov    -0x48(%ebp),%ebx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010763f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0107642:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0107645:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0107648:	8b 04 87             	mov    (%edi,%eax,4),%eax
f010764b:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010764e:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0107651:	39 d0                	cmp    %edx,%eax
f0107653:	0f 82 66 ff ff ff    	jb     f01075bf <debuginfo_eip+0x29e>
f0107659:	e9 6b ff ff ff       	jmp    f01075c9 <debuginfo_eip+0x2a8>
	...

f0107660 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0107660:	55                   	push   %ebp
f0107661:	89 e5                	mov    %esp,%ebp
f0107663:	57                   	push   %edi
f0107664:	56                   	push   %esi
f0107665:	53                   	push   %ebx
f0107666:	83 ec 3c             	sub    $0x3c,%esp
f0107669:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010766c:	89 d7                	mov    %edx,%edi
f010766e:	8b 45 08             	mov    0x8(%ebp),%eax
f0107671:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0107674:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107677:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010767a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010767d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0107680:	85 c0                	test   %eax,%eax
f0107682:	75 08                	jne    f010768c <printnum+0x2c>
f0107684:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0107687:	39 45 10             	cmp    %eax,0x10(%ebp)
f010768a:	77 57                	ja     f01076e3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010768c:	89 74 24 10          	mov    %esi,0x10(%esp)
f0107690:	4b                   	dec    %ebx
f0107691:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0107695:	8b 45 10             	mov    0x10(%ebp),%eax
f0107698:	89 44 24 08          	mov    %eax,0x8(%esp)
f010769c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f01076a0:	8b 74 24 0c          	mov    0xc(%esp),%esi
f01076a4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01076ab:	00 
f01076ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01076af:	89 04 24             	mov    %eax,(%esp)
f01076b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01076b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01076b9:	e8 ca 11 00 00       	call   f0108888 <__udivdi3>
f01076be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01076c2:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01076c6:	89 04 24             	mov    %eax,(%esp)
f01076c9:	89 54 24 04          	mov    %edx,0x4(%esp)
f01076cd:	89 fa                	mov    %edi,%edx
f01076cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01076d2:	e8 89 ff ff ff       	call   f0107660 <printnum>
f01076d7:	eb 0f                	jmp    f01076e8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01076d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01076dd:	89 34 24             	mov    %esi,(%esp)
f01076e0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01076e3:	4b                   	dec    %ebx
f01076e4:	85 db                	test   %ebx,%ebx
f01076e6:	7f f1                	jg     f01076d9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01076e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01076ec:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01076f0:	8b 45 10             	mov    0x10(%ebp),%eax
f01076f3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01076f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01076fe:	00 
f01076ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0107702:	89 04 24             	mov    %eax,(%esp)
f0107705:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107708:	89 44 24 04          	mov    %eax,0x4(%esp)
f010770c:	e8 97 12 00 00       	call   f01089a8 <__umoddi3>
f0107711:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0107715:	0f be 80 72 a9 10 f0 	movsbl -0xfef568e(%eax),%eax
f010771c:	89 04 24             	mov    %eax,(%esp)
f010771f:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0107722:	83 c4 3c             	add    $0x3c,%esp
f0107725:	5b                   	pop    %ebx
f0107726:	5e                   	pop    %esi
f0107727:	5f                   	pop    %edi
f0107728:	5d                   	pop    %ebp
f0107729:	c3                   	ret    

f010772a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010772a:	55                   	push   %ebp
f010772b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010772d:	83 fa 01             	cmp    $0x1,%edx
f0107730:	7e 0e                	jle    f0107740 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0107732:	8b 10                	mov    (%eax),%edx
f0107734:	8d 4a 08             	lea    0x8(%edx),%ecx
f0107737:	89 08                	mov    %ecx,(%eax)
f0107739:	8b 02                	mov    (%edx),%eax
f010773b:	8b 52 04             	mov    0x4(%edx),%edx
f010773e:	eb 22                	jmp    f0107762 <getuint+0x38>
	else if (lflag)
f0107740:	85 d2                	test   %edx,%edx
f0107742:	74 10                	je     f0107754 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0107744:	8b 10                	mov    (%eax),%edx
f0107746:	8d 4a 04             	lea    0x4(%edx),%ecx
f0107749:	89 08                	mov    %ecx,(%eax)
f010774b:	8b 02                	mov    (%edx),%eax
f010774d:	ba 00 00 00 00       	mov    $0x0,%edx
f0107752:	eb 0e                	jmp    f0107762 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0107754:	8b 10                	mov    (%eax),%edx
f0107756:	8d 4a 04             	lea    0x4(%edx),%ecx
f0107759:	89 08                	mov    %ecx,(%eax)
f010775b:	8b 02                	mov    (%edx),%eax
f010775d:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0107762:	5d                   	pop    %ebp
f0107763:	c3                   	ret    

f0107764 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0107764:	55                   	push   %ebp
f0107765:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0107767:	83 fa 01             	cmp    $0x1,%edx
f010776a:	7e 0e                	jle    f010777a <getint+0x16>
		return va_arg(*ap, long long);
f010776c:	8b 10                	mov    (%eax),%edx
f010776e:	8d 4a 08             	lea    0x8(%edx),%ecx
f0107771:	89 08                	mov    %ecx,(%eax)
f0107773:	8b 02                	mov    (%edx),%eax
f0107775:	8b 52 04             	mov    0x4(%edx),%edx
f0107778:	eb 1a                	jmp    f0107794 <getint+0x30>
	else if (lflag)
f010777a:	85 d2                	test   %edx,%edx
f010777c:	74 0c                	je     f010778a <getint+0x26>
		return va_arg(*ap, long);
f010777e:	8b 10                	mov    (%eax),%edx
f0107780:	8d 4a 04             	lea    0x4(%edx),%ecx
f0107783:	89 08                	mov    %ecx,(%eax)
f0107785:	8b 02                	mov    (%edx),%eax
f0107787:	99                   	cltd   
f0107788:	eb 0a                	jmp    f0107794 <getint+0x30>
	else
		return va_arg(*ap, int);
f010778a:	8b 10                	mov    (%eax),%edx
f010778c:	8d 4a 04             	lea    0x4(%edx),%ecx
f010778f:	89 08                	mov    %ecx,(%eax)
f0107791:	8b 02                	mov    (%edx),%eax
f0107793:	99                   	cltd   
}
f0107794:	5d                   	pop    %ebp
f0107795:	c3                   	ret    

f0107796 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0107796:	55                   	push   %ebp
f0107797:	89 e5                	mov    %esp,%ebp
f0107799:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010779c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f010779f:	8b 10                	mov    (%eax),%edx
f01077a1:	3b 50 04             	cmp    0x4(%eax),%edx
f01077a4:	73 08                	jae    f01077ae <sprintputch+0x18>
		*b->buf++ = ch;
f01077a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01077a9:	88 0a                	mov    %cl,(%edx)
f01077ab:	42                   	inc    %edx
f01077ac:	89 10                	mov    %edx,(%eax)
}
f01077ae:	5d                   	pop    %ebp
f01077af:	c3                   	ret    

f01077b0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01077b0:	55                   	push   %ebp
f01077b1:	89 e5                	mov    %esp,%ebp
f01077b3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01077b6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01077b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01077bd:	8b 45 10             	mov    0x10(%ebp),%eax
f01077c0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01077c4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01077c7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01077cb:	8b 45 08             	mov    0x8(%ebp),%eax
f01077ce:	89 04 24             	mov    %eax,(%esp)
f01077d1:	e8 02 00 00 00       	call   f01077d8 <vprintfmt>
	va_end(ap);
}
f01077d6:	c9                   	leave  
f01077d7:	c3                   	ret    

f01077d8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01077d8:	55                   	push   %ebp
f01077d9:	89 e5                	mov    %esp,%ebp
f01077db:	57                   	push   %edi
f01077dc:	56                   	push   %esi
f01077dd:	53                   	push   %ebx
f01077de:	83 ec 4c             	sub    $0x4c,%esp
f01077e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01077e4:	8b 75 10             	mov    0x10(%ebp),%esi
f01077e7:	eb 12                	jmp    f01077fb <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01077e9:	85 c0                	test   %eax,%eax
f01077eb:	0f 84 40 03 00 00    	je     f0107b31 <vprintfmt+0x359>
				return;
			putch(ch, putdat);
f01077f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01077f5:	89 04 24             	mov    %eax,(%esp)
f01077f8:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01077fb:	0f b6 06             	movzbl (%esi),%eax
f01077fe:	46                   	inc    %esi
f01077ff:	83 f8 25             	cmp    $0x25,%eax
f0107802:	75 e5                	jne    f01077e9 <vprintfmt+0x11>
f0107804:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0107808:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010780f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0107814:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f010781b:	ba 00 00 00 00       	mov    $0x0,%edx
f0107820:	eb 26                	jmp    f0107848 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0107822:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0107825:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0107829:	eb 1d                	jmp    f0107848 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010782b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f010782e:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0107832:	eb 14                	jmp    f0107848 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0107834:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0107837:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010783e:	eb 08                	jmp    f0107848 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0107840:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0107843:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0107848:	0f b6 06             	movzbl (%esi),%eax
f010784b:	8d 4e 01             	lea    0x1(%esi),%ecx
f010784e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0107851:	8a 0e                	mov    (%esi),%cl
f0107853:	83 e9 23             	sub    $0x23,%ecx
f0107856:	80 f9 55             	cmp    $0x55,%cl
f0107859:	0f 87 b6 02 00 00    	ja     f0107b15 <vprintfmt+0x33d>
f010785f:	0f b6 c9             	movzbl %cl,%ecx
f0107862:	ff 24 8d 40 aa 10 f0 	jmp    *-0xfef55c0(,%ecx,4)
f0107869:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010786c:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0107871:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
f0107874:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
f0107878:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f010787b:	8d 48 d0             	lea    -0x30(%eax),%ecx
f010787e:	83 f9 09             	cmp    $0x9,%ecx
f0107881:	77 2a                	ja     f01078ad <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0107883:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0107884:	eb eb                	jmp    f0107871 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0107886:	8b 45 14             	mov    0x14(%ebp),%eax
f0107889:	8d 48 04             	lea    0x4(%eax),%ecx
f010788c:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010788f:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0107891:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0107894:	eb 17                	jmp    f01078ad <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f0107896:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010789a:	78 98                	js     f0107834 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010789c:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010789f:	eb a7                	jmp    f0107848 <vprintfmt+0x70>
f01078a1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01078a4:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f01078ab:	eb 9b                	jmp    f0107848 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f01078ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01078b1:	79 95                	jns    f0107848 <vprintfmt+0x70>
f01078b3:	eb 8b                	jmp    f0107840 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01078b5:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01078b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01078b9:	eb 8d                	jmp    f0107848 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01078bb:	8b 45 14             	mov    0x14(%ebp),%eax
f01078be:	8d 50 04             	lea    0x4(%eax),%edx
f01078c1:	89 55 14             	mov    %edx,0x14(%ebp)
f01078c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01078c8:	8b 00                	mov    (%eax),%eax
f01078ca:	89 04 24             	mov    %eax,(%esp)
f01078cd:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01078d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01078d3:	e9 23 ff ff ff       	jmp    f01077fb <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01078d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01078db:	8d 50 04             	lea    0x4(%eax),%edx
f01078de:	89 55 14             	mov    %edx,0x14(%ebp)
f01078e1:	8b 00                	mov    (%eax),%eax
f01078e3:	85 c0                	test   %eax,%eax
f01078e5:	79 02                	jns    f01078e9 <vprintfmt+0x111>
f01078e7:	f7 d8                	neg    %eax
f01078e9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01078eb:	83 f8 09             	cmp    $0x9,%eax
f01078ee:	7f 0b                	jg     f01078fb <vprintfmt+0x123>
f01078f0:	8b 04 85 a0 ab 10 f0 	mov    -0xfef5460(,%eax,4),%eax
f01078f7:	85 c0                	test   %eax,%eax
f01078f9:	75 23                	jne    f010791e <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f01078fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01078ff:	c7 44 24 08 8a a9 10 	movl   $0xf010a98a,0x8(%esp)
f0107906:	f0 
f0107907:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010790b:	8b 45 08             	mov    0x8(%ebp),%eax
f010790e:	89 04 24             	mov    %eax,(%esp)
f0107911:	e8 9a fe ff ff       	call   f01077b0 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0107916:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0107919:	e9 dd fe ff ff       	jmp    f01077fb <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f010791e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107922:	c7 44 24 08 ad 9c 10 	movl   $0xf0109cad,0x8(%esp)
f0107929:	f0 
f010792a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010792e:	8b 55 08             	mov    0x8(%ebp),%edx
f0107931:	89 14 24             	mov    %edx,(%esp)
f0107934:	e8 77 fe ff ff       	call   f01077b0 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0107939:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010793c:	e9 ba fe ff ff       	jmp    f01077fb <vprintfmt+0x23>
f0107941:	89 f9                	mov    %edi,%ecx
f0107943:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107946:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0107949:	8b 45 14             	mov    0x14(%ebp),%eax
f010794c:	8d 50 04             	lea    0x4(%eax),%edx
f010794f:	89 55 14             	mov    %edx,0x14(%ebp)
f0107952:	8b 30                	mov    (%eax),%esi
f0107954:	85 f6                	test   %esi,%esi
f0107956:	75 05                	jne    f010795d <vprintfmt+0x185>
				p = "(null)";
f0107958:	be 83 a9 10 f0       	mov    $0xf010a983,%esi
			if (width > 0 && padc != '-')
f010795d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0107961:	0f 8e 84 00 00 00    	jle    f01079eb <vprintfmt+0x213>
f0107967:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f010796b:	74 7e                	je     f01079eb <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f010796d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0107971:	89 34 24             	mov    %esi,(%esp)
f0107974:	e8 25 03 00 00       	call   f0107c9e <strnlen>
f0107979:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010797c:	29 c2                	sub    %eax,%edx
f010797e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0107981:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
f0107985:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0107988:	89 7d cc             	mov    %edi,-0x34(%ebp)
f010798b:	89 de                	mov    %ebx,%esi
f010798d:	89 d3                	mov    %edx,%ebx
f010798f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0107991:	eb 0b                	jmp    f010799e <vprintfmt+0x1c6>
					putch(padc, putdat);
f0107993:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107997:	89 3c 24             	mov    %edi,(%esp)
f010799a:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010799d:	4b                   	dec    %ebx
f010799e:	85 db                	test   %ebx,%ebx
f01079a0:	7f f1                	jg     f0107993 <vprintfmt+0x1bb>
f01079a2:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01079a5:	89 f3                	mov    %esi,%ebx
f01079a7:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f01079aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01079ad:	85 c0                	test   %eax,%eax
f01079af:	79 05                	jns    f01079b6 <vprintfmt+0x1de>
f01079b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01079b6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01079b9:	29 c2                	sub    %eax,%edx
f01079bb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01079be:	eb 2b                	jmp    f01079eb <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01079c0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01079c4:	74 18                	je     f01079de <vprintfmt+0x206>
f01079c6:	8d 50 e0             	lea    -0x20(%eax),%edx
f01079c9:	83 fa 5e             	cmp    $0x5e,%edx
f01079cc:	76 10                	jbe    f01079de <vprintfmt+0x206>
					putch('?', putdat);
f01079ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01079d2:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01079d9:	ff 55 08             	call   *0x8(%ebp)
f01079dc:	eb 0a                	jmp    f01079e8 <vprintfmt+0x210>
				else
					putch(ch, putdat);
f01079de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01079e2:	89 04 24             	mov    %eax,(%esp)
f01079e5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01079e8:	ff 4d e4             	decl   -0x1c(%ebp)
f01079eb:	0f be 06             	movsbl (%esi),%eax
f01079ee:	46                   	inc    %esi
f01079ef:	85 c0                	test   %eax,%eax
f01079f1:	74 21                	je     f0107a14 <vprintfmt+0x23c>
f01079f3:	85 ff                	test   %edi,%edi
f01079f5:	78 c9                	js     f01079c0 <vprintfmt+0x1e8>
f01079f7:	4f                   	dec    %edi
f01079f8:	79 c6                	jns    f01079c0 <vprintfmt+0x1e8>
f01079fa:	8b 7d 08             	mov    0x8(%ebp),%edi
f01079fd:	89 de                	mov    %ebx,%esi
f01079ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0107a02:	eb 18                	jmp    f0107a1c <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0107a04:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107a08:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0107a0f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0107a11:	4b                   	dec    %ebx
f0107a12:	eb 08                	jmp    f0107a1c <vprintfmt+0x244>
f0107a14:	8b 7d 08             	mov    0x8(%ebp),%edi
f0107a17:	89 de                	mov    %ebx,%esi
f0107a19:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0107a1c:	85 db                	test   %ebx,%ebx
f0107a1e:	7f e4                	jg     f0107a04 <vprintfmt+0x22c>
f0107a20:	89 7d 08             	mov    %edi,0x8(%ebp)
f0107a23:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0107a25:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0107a28:	e9 ce fd ff ff       	jmp    f01077fb <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0107a2d:	8d 45 14             	lea    0x14(%ebp),%eax
f0107a30:	e8 2f fd ff ff       	call   f0107764 <getint>
f0107a35:	89 c6                	mov    %eax,%esi
f0107a37:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
f0107a39:	85 d2                	test   %edx,%edx
f0107a3b:	78 07                	js     f0107a44 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0107a3d:	be 0a 00 00 00       	mov    $0xa,%esi
f0107a42:	eb 7e                	jmp    f0107ac2 <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0107a44:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0107a48:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0107a4f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0107a52:	89 f0                	mov    %esi,%eax
f0107a54:	89 fa                	mov    %edi,%edx
f0107a56:	f7 d8                	neg    %eax
f0107a58:	83 d2 00             	adc    $0x0,%edx
f0107a5b:	f7 da                	neg    %edx
			}
			base = 10;
f0107a5d:	be 0a 00 00 00       	mov    $0xa,%esi
f0107a62:	eb 5e                	jmp    f0107ac2 <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0107a64:	8d 45 14             	lea    0x14(%ebp),%eax
f0107a67:	e8 be fc ff ff       	call   f010772a <getuint>
			base = 10;
f0107a6c:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
f0107a71:	eb 4f                	jmp    f0107ac2 <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0107a73:	8d 45 14             	lea    0x14(%ebp),%eax
f0107a76:	e8 af fc ff ff       	call   f010772a <getuint>
			base = 8;
f0107a7b:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
f0107a80:	eb 40                	jmp    f0107ac2 <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
f0107a82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0107a86:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0107a8d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0107a90:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0107a94:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0107a9b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0107a9e:	8b 45 14             	mov    0x14(%ebp),%eax
f0107aa1:	8d 50 04             	lea    0x4(%eax),%edx
f0107aa4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0107aa7:	8b 00                	mov    (%eax),%eax
f0107aa9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0107aae:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
f0107ab3:	eb 0d                	jmp    f0107ac2 <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0107ab5:	8d 45 14             	lea    0x14(%ebp),%eax
f0107ab8:	e8 6d fc ff ff       	call   f010772a <getuint>
			base = 16;
f0107abd:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
f0107ac2:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
f0107ac6:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0107aca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0107acd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0107ad1:	89 74 24 08          	mov    %esi,0x8(%esp)
f0107ad5:	89 04 24             	mov    %eax,(%esp)
f0107ad8:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107adc:	89 da                	mov    %ebx,%edx
f0107ade:	8b 45 08             	mov    0x8(%ebp),%eax
f0107ae1:	e8 7a fb ff ff       	call   f0107660 <printnum>
			break;
f0107ae6:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0107ae9:	e9 0d fd ff ff       	jmp    f01077fb <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
f0107aee:	8d 45 14             	lea    0x14(%ebp),%eax
f0107af1:	e8 6e fc ff ff       	call   f0107764 <getint>
f0107af6:	a3 48 e4 12 f0       	mov    %eax,0xf012e448
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0107afb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
f0107afe:	e9 f8 fc ff ff       	jmp    f01077fb <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0107b03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0107b07:	89 04 24             	mov    %eax,(%esp)
f0107b0a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0107b0d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0107b10:	e9 e6 fc ff ff       	jmp    f01077fb <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0107b15:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0107b19:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0107b20:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0107b23:	eb 01                	jmp    f0107b26 <vprintfmt+0x34e>
f0107b25:	4e                   	dec    %esi
f0107b26:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0107b2a:	75 f9                	jne    f0107b25 <vprintfmt+0x34d>
f0107b2c:	e9 ca fc ff ff       	jmp    f01077fb <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0107b31:	83 c4 4c             	add    $0x4c,%esp
f0107b34:	5b                   	pop    %ebx
f0107b35:	5e                   	pop    %esi
f0107b36:	5f                   	pop    %edi
f0107b37:	5d                   	pop    %ebp
f0107b38:	c3                   	ret    

f0107b39 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0107b39:	55                   	push   %ebp
f0107b3a:	89 e5                	mov    %esp,%ebp
f0107b3c:	83 ec 28             	sub    $0x28,%esp
f0107b3f:	8b 45 08             	mov    0x8(%ebp),%eax
f0107b42:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0107b45:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0107b48:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0107b4c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0107b4f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0107b56:	85 c0                	test   %eax,%eax
f0107b58:	74 30                	je     f0107b8a <vsnprintf+0x51>
f0107b5a:	85 d2                	test   %edx,%edx
f0107b5c:	7e 33                	jle    f0107b91 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0107b5e:	8b 45 14             	mov    0x14(%ebp),%eax
f0107b61:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107b65:	8b 45 10             	mov    0x10(%ebp),%eax
f0107b68:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107b6c:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0107b6f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107b73:	c7 04 24 96 77 10 f0 	movl   $0xf0107796,(%esp)
f0107b7a:	e8 59 fc ff ff       	call   f01077d8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0107b7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107b82:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0107b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107b88:	eb 0c                	jmp    f0107b96 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0107b8a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0107b8f:	eb 05                	jmp    f0107b96 <vsnprintf+0x5d>
f0107b91:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0107b96:	c9                   	leave  
f0107b97:	c3                   	ret    

f0107b98 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0107b98:	55                   	push   %ebp
f0107b99:	89 e5                	mov    %esp,%ebp
f0107b9b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0107b9e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0107ba1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107ba5:	8b 45 10             	mov    0x10(%ebp),%eax
f0107ba8:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107bac:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107baf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107bb3:	8b 45 08             	mov    0x8(%ebp),%eax
f0107bb6:	89 04 24             	mov    %eax,(%esp)
f0107bb9:	e8 7b ff ff ff       	call   f0107b39 <vsnprintf>
	va_end(ap);

	return rc;
}
f0107bbe:	c9                   	leave  
f0107bbf:	c3                   	ret    

f0107bc0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0107bc0:	55                   	push   %ebp
f0107bc1:	89 e5                	mov    %esp,%ebp
f0107bc3:	57                   	push   %edi
f0107bc4:	56                   	push   %esi
f0107bc5:	53                   	push   %ebx
f0107bc6:	83 ec 1c             	sub    $0x1c,%esp
f0107bc9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0107bcc:	85 c0                	test   %eax,%eax
f0107bce:	74 10                	je     f0107be0 <readline+0x20>
		cprintf("%s", prompt);
f0107bd0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107bd4:	c7 04 24 ad 9c 10 f0 	movl   $0xf0109cad,(%esp)
f0107bdb:	e8 aa c6 ff ff       	call   f010428a <cprintf>

	i = 0;
	echoing = iscons(0);
f0107be0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0107be7:	e8 f0 8b ff ff       	call   f01007dc <iscons>
f0107bec:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0107bee:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0107bf3:	e8 d3 8b ff ff       	call   f01007cb <getchar>
f0107bf8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0107bfa:	85 c0                	test   %eax,%eax
f0107bfc:	79 17                	jns    f0107c15 <readline+0x55>
			cprintf("read error: %e\n", c);
f0107bfe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107c02:	c7 04 24 c8 ab 10 f0 	movl   $0xf010abc8,(%esp)
f0107c09:	e8 7c c6 ff ff       	call   f010428a <cprintf>
			return NULL;
f0107c0e:	b8 00 00 00 00       	mov    $0x0,%eax
f0107c13:	eb 69                	jmp    f0107c7e <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0107c15:	83 f8 08             	cmp    $0x8,%eax
f0107c18:	74 05                	je     f0107c1f <readline+0x5f>
f0107c1a:	83 f8 7f             	cmp    $0x7f,%eax
f0107c1d:	75 17                	jne    f0107c36 <readline+0x76>
f0107c1f:	85 f6                	test   %esi,%esi
f0107c21:	7e 13                	jle    f0107c36 <readline+0x76>
			if (echoing)
f0107c23:	85 ff                	test   %edi,%edi
f0107c25:	74 0c                	je     f0107c33 <readline+0x73>
				cputchar('\b');
f0107c27:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0107c2e:	e8 88 8b ff ff       	call   f01007bb <cputchar>
			i--;
f0107c33:	4e                   	dec    %esi
f0107c34:	eb bd                	jmp    f0107bf3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0107c36:	83 fb 1f             	cmp    $0x1f,%ebx
f0107c39:	7e 1d                	jle    f0107c58 <readline+0x98>
f0107c3b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0107c41:	7f 15                	jg     f0107c58 <readline+0x98>
			if (echoing)
f0107c43:	85 ff                	test   %edi,%edi
f0107c45:	74 08                	je     f0107c4f <readline+0x8f>
				cputchar(c);
f0107c47:	89 1c 24             	mov    %ebx,(%esp)
f0107c4a:	e8 6c 8b ff ff       	call   f01007bb <cputchar>
			buf[i++] = c;
f0107c4f:	88 9e 80 8a 35 f0    	mov    %bl,-0xfca7580(%esi)
f0107c55:	46                   	inc    %esi
f0107c56:	eb 9b                	jmp    f0107bf3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0107c58:	83 fb 0a             	cmp    $0xa,%ebx
f0107c5b:	74 05                	je     f0107c62 <readline+0xa2>
f0107c5d:	83 fb 0d             	cmp    $0xd,%ebx
f0107c60:	75 91                	jne    f0107bf3 <readline+0x33>
			if (echoing)
f0107c62:	85 ff                	test   %edi,%edi
f0107c64:	74 0c                	je     f0107c72 <readline+0xb2>
				cputchar('\n');
f0107c66:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0107c6d:	e8 49 8b ff ff       	call   f01007bb <cputchar>
			buf[i] = 0;
f0107c72:	c6 86 80 8a 35 f0 00 	movb   $0x0,-0xfca7580(%esi)
			return buf;
f0107c79:	b8 80 8a 35 f0       	mov    $0xf0358a80,%eax
		}
	}
}
f0107c7e:	83 c4 1c             	add    $0x1c,%esp
f0107c81:	5b                   	pop    %ebx
f0107c82:	5e                   	pop    %esi
f0107c83:	5f                   	pop    %edi
f0107c84:	5d                   	pop    %ebp
f0107c85:	c3                   	ret    
	...

f0107c88 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0107c88:	55                   	push   %ebp
f0107c89:	89 e5                	mov    %esp,%ebp
f0107c8b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0107c8e:	b8 00 00 00 00       	mov    $0x0,%eax
f0107c93:	eb 01                	jmp    f0107c96 <strlen+0xe>
		n++;
f0107c95:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0107c96:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0107c9a:	75 f9                	jne    f0107c95 <strlen+0xd>
		n++;
	return n;
}
f0107c9c:	5d                   	pop    %ebp
f0107c9d:	c3                   	ret    

f0107c9e <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0107c9e:	55                   	push   %ebp
f0107c9f:	89 e5                	mov    %esp,%ebp
f0107ca1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f0107ca4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0107ca7:	b8 00 00 00 00       	mov    $0x0,%eax
f0107cac:	eb 01                	jmp    f0107caf <strnlen+0x11>
		n++;
f0107cae:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0107caf:	39 d0                	cmp    %edx,%eax
f0107cb1:	74 06                	je     f0107cb9 <strnlen+0x1b>
f0107cb3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0107cb7:	75 f5                	jne    f0107cae <strnlen+0x10>
		n++;
	return n;
}
f0107cb9:	5d                   	pop    %ebp
f0107cba:	c3                   	ret    

f0107cbb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0107cbb:	55                   	push   %ebp
f0107cbc:	89 e5                	mov    %esp,%ebp
f0107cbe:	53                   	push   %ebx
f0107cbf:	8b 45 08             	mov    0x8(%ebp),%eax
f0107cc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0107cc5:	ba 00 00 00 00       	mov    $0x0,%edx
f0107cca:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0107ccd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0107cd0:	42                   	inc    %edx
f0107cd1:	84 c9                	test   %cl,%cl
f0107cd3:	75 f5                	jne    f0107cca <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0107cd5:	5b                   	pop    %ebx
f0107cd6:	5d                   	pop    %ebp
f0107cd7:	c3                   	ret    

f0107cd8 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0107cd8:	55                   	push   %ebp
f0107cd9:	89 e5                	mov    %esp,%ebp
f0107cdb:	53                   	push   %ebx
f0107cdc:	83 ec 08             	sub    $0x8,%esp
f0107cdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0107ce2:	89 1c 24             	mov    %ebx,(%esp)
f0107ce5:	e8 9e ff ff ff       	call   f0107c88 <strlen>
	strcpy(dst + len, src);
f0107cea:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107ced:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107cf1:	01 d8                	add    %ebx,%eax
f0107cf3:	89 04 24             	mov    %eax,(%esp)
f0107cf6:	e8 c0 ff ff ff       	call   f0107cbb <strcpy>
	return dst;
}
f0107cfb:	89 d8                	mov    %ebx,%eax
f0107cfd:	83 c4 08             	add    $0x8,%esp
f0107d00:	5b                   	pop    %ebx
f0107d01:	5d                   	pop    %ebp
f0107d02:	c3                   	ret    

f0107d03 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0107d03:	55                   	push   %ebp
f0107d04:	89 e5                	mov    %esp,%ebp
f0107d06:	56                   	push   %esi
f0107d07:	53                   	push   %ebx
f0107d08:	8b 45 08             	mov    0x8(%ebp),%eax
f0107d0b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107d0e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0107d11:	b9 00 00 00 00       	mov    $0x0,%ecx
f0107d16:	eb 0c                	jmp    f0107d24 <strncpy+0x21>
		*dst++ = *src;
f0107d18:	8a 1a                	mov    (%edx),%bl
f0107d1a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0107d1d:	80 3a 01             	cmpb   $0x1,(%edx)
f0107d20:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0107d23:	41                   	inc    %ecx
f0107d24:	39 f1                	cmp    %esi,%ecx
f0107d26:	75 f0                	jne    f0107d18 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0107d28:	5b                   	pop    %ebx
f0107d29:	5e                   	pop    %esi
f0107d2a:	5d                   	pop    %ebp
f0107d2b:	c3                   	ret    

f0107d2c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0107d2c:	55                   	push   %ebp
f0107d2d:	89 e5                	mov    %esp,%ebp
f0107d2f:	56                   	push   %esi
f0107d30:	53                   	push   %ebx
f0107d31:	8b 75 08             	mov    0x8(%ebp),%esi
f0107d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0107d37:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0107d3a:	85 d2                	test   %edx,%edx
f0107d3c:	75 0a                	jne    f0107d48 <strlcpy+0x1c>
f0107d3e:	89 f0                	mov    %esi,%eax
f0107d40:	eb 1a                	jmp    f0107d5c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0107d42:	88 18                	mov    %bl,(%eax)
f0107d44:	40                   	inc    %eax
f0107d45:	41                   	inc    %ecx
f0107d46:	eb 02                	jmp    f0107d4a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0107d48:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f0107d4a:	4a                   	dec    %edx
f0107d4b:	74 0a                	je     f0107d57 <strlcpy+0x2b>
f0107d4d:	8a 19                	mov    (%ecx),%bl
f0107d4f:	84 db                	test   %bl,%bl
f0107d51:	75 ef                	jne    f0107d42 <strlcpy+0x16>
f0107d53:	89 c2                	mov    %eax,%edx
f0107d55:	eb 02                	jmp    f0107d59 <strlcpy+0x2d>
f0107d57:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0107d59:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0107d5c:	29 f0                	sub    %esi,%eax
}
f0107d5e:	5b                   	pop    %ebx
f0107d5f:	5e                   	pop    %esi
f0107d60:	5d                   	pop    %ebp
f0107d61:	c3                   	ret    

f0107d62 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0107d62:	55                   	push   %ebp
f0107d63:	89 e5                	mov    %esp,%ebp
f0107d65:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0107d68:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0107d6b:	eb 02                	jmp    f0107d6f <strcmp+0xd>
		p++, q++;
f0107d6d:	41                   	inc    %ecx
f0107d6e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0107d6f:	8a 01                	mov    (%ecx),%al
f0107d71:	84 c0                	test   %al,%al
f0107d73:	74 04                	je     f0107d79 <strcmp+0x17>
f0107d75:	3a 02                	cmp    (%edx),%al
f0107d77:	74 f4                	je     f0107d6d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0107d79:	0f b6 c0             	movzbl %al,%eax
f0107d7c:	0f b6 12             	movzbl (%edx),%edx
f0107d7f:	29 d0                	sub    %edx,%eax
}
f0107d81:	5d                   	pop    %ebp
f0107d82:	c3                   	ret    

f0107d83 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0107d83:	55                   	push   %ebp
f0107d84:	89 e5                	mov    %esp,%ebp
f0107d86:	53                   	push   %ebx
f0107d87:	8b 45 08             	mov    0x8(%ebp),%eax
f0107d8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0107d8d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0107d90:	eb 03                	jmp    f0107d95 <strncmp+0x12>
		n--, p++, q++;
f0107d92:	4a                   	dec    %edx
f0107d93:	40                   	inc    %eax
f0107d94:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0107d95:	85 d2                	test   %edx,%edx
f0107d97:	74 14                	je     f0107dad <strncmp+0x2a>
f0107d99:	8a 18                	mov    (%eax),%bl
f0107d9b:	84 db                	test   %bl,%bl
f0107d9d:	74 04                	je     f0107da3 <strncmp+0x20>
f0107d9f:	3a 19                	cmp    (%ecx),%bl
f0107da1:	74 ef                	je     f0107d92 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0107da3:	0f b6 00             	movzbl (%eax),%eax
f0107da6:	0f b6 11             	movzbl (%ecx),%edx
f0107da9:	29 d0                	sub    %edx,%eax
f0107dab:	eb 05                	jmp    f0107db2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0107dad:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0107db2:	5b                   	pop    %ebx
f0107db3:	5d                   	pop    %ebp
f0107db4:	c3                   	ret    

f0107db5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0107db5:	55                   	push   %ebp
f0107db6:	89 e5                	mov    %esp,%ebp
f0107db8:	8b 45 08             	mov    0x8(%ebp),%eax
f0107dbb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0107dbe:	eb 05                	jmp    f0107dc5 <strchr+0x10>
		if (*s == c)
f0107dc0:	38 ca                	cmp    %cl,%dl
f0107dc2:	74 0c                	je     f0107dd0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0107dc4:	40                   	inc    %eax
f0107dc5:	8a 10                	mov    (%eax),%dl
f0107dc7:	84 d2                	test   %dl,%dl
f0107dc9:	75 f5                	jne    f0107dc0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f0107dcb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0107dd0:	5d                   	pop    %ebp
f0107dd1:	c3                   	ret    

f0107dd2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0107dd2:	55                   	push   %ebp
f0107dd3:	89 e5                	mov    %esp,%ebp
f0107dd5:	8b 45 08             	mov    0x8(%ebp),%eax
f0107dd8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0107ddb:	eb 05                	jmp    f0107de2 <strfind+0x10>
		if (*s == c)
f0107ddd:	38 ca                	cmp    %cl,%dl
f0107ddf:	74 07                	je     f0107de8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0107de1:	40                   	inc    %eax
f0107de2:	8a 10                	mov    (%eax),%dl
f0107de4:	84 d2                	test   %dl,%dl
f0107de6:	75 f5                	jne    f0107ddd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f0107de8:	5d                   	pop    %ebp
f0107de9:	c3                   	ret    

f0107dea <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0107dea:	55                   	push   %ebp
f0107deb:	89 e5                	mov    %esp,%ebp
f0107ded:	57                   	push   %edi
f0107dee:	56                   	push   %esi
f0107def:	53                   	push   %ebx
f0107df0:	8b 7d 08             	mov    0x8(%ebp),%edi
f0107df3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107df6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0107df9:	85 c9                	test   %ecx,%ecx
f0107dfb:	74 30                	je     f0107e2d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0107dfd:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0107e03:	75 25                	jne    f0107e2a <memset+0x40>
f0107e05:	f6 c1 03             	test   $0x3,%cl
f0107e08:	75 20                	jne    f0107e2a <memset+0x40>
		c &= 0xFF;
f0107e0a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0107e0d:	89 d3                	mov    %edx,%ebx
f0107e0f:	c1 e3 08             	shl    $0x8,%ebx
f0107e12:	89 d6                	mov    %edx,%esi
f0107e14:	c1 e6 18             	shl    $0x18,%esi
f0107e17:	89 d0                	mov    %edx,%eax
f0107e19:	c1 e0 10             	shl    $0x10,%eax
f0107e1c:	09 f0                	or     %esi,%eax
f0107e1e:	09 d0                	or     %edx,%eax
f0107e20:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0107e22:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0107e25:	fc                   	cld    
f0107e26:	f3 ab                	rep stos %eax,%es:(%edi)
f0107e28:	eb 03                	jmp    f0107e2d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0107e2a:	fc                   	cld    
f0107e2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0107e2d:	89 f8                	mov    %edi,%eax
f0107e2f:	5b                   	pop    %ebx
f0107e30:	5e                   	pop    %esi
f0107e31:	5f                   	pop    %edi
f0107e32:	5d                   	pop    %ebp
f0107e33:	c3                   	ret    

f0107e34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0107e34:	55                   	push   %ebp
f0107e35:	89 e5                	mov    %esp,%ebp
f0107e37:	57                   	push   %edi
f0107e38:	56                   	push   %esi
f0107e39:	8b 45 08             	mov    0x8(%ebp),%eax
f0107e3c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0107e3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0107e42:	39 c6                	cmp    %eax,%esi
f0107e44:	73 34                	jae    f0107e7a <memmove+0x46>
f0107e46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0107e49:	39 d0                	cmp    %edx,%eax
f0107e4b:	73 2d                	jae    f0107e7a <memmove+0x46>
		s += n;
		d += n;
f0107e4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0107e50:	f6 c2 03             	test   $0x3,%dl
f0107e53:	75 1b                	jne    f0107e70 <memmove+0x3c>
f0107e55:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0107e5b:	75 13                	jne    f0107e70 <memmove+0x3c>
f0107e5d:	f6 c1 03             	test   $0x3,%cl
f0107e60:	75 0e                	jne    f0107e70 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0107e62:	83 ef 04             	sub    $0x4,%edi
f0107e65:	8d 72 fc             	lea    -0x4(%edx),%esi
f0107e68:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0107e6b:	fd                   	std    
f0107e6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0107e6e:	eb 07                	jmp    f0107e77 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0107e70:	4f                   	dec    %edi
f0107e71:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0107e74:	fd                   	std    
f0107e75:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0107e77:	fc                   	cld    
f0107e78:	eb 20                	jmp    f0107e9a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0107e7a:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0107e80:	75 13                	jne    f0107e95 <memmove+0x61>
f0107e82:	a8 03                	test   $0x3,%al
f0107e84:	75 0f                	jne    f0107e95 <memmove+0x61>
f0107e86:	f6 c1 03             	test   $0x3,%cl
f0107e89:	75 0a                	jne    f0107e95 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0107e8b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0107e8e:	89 c7                	mov    %eax,%edi
f0107e90:	fc                   	cld    
f0107e91:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0107e93:	eb 05                	jmp    f0107e9a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0107e95:	89 c7                	mov    %eax,%edi
f0107e97:	fc                   	cld    
f0107e98:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0107e9a:	5e                   	pop    %esi
f0107e9b:	5f                   	pop    %edi
f0107e9c:	5d                   	pop    %ebp
f0107e9d:	c3                   	ret    

f0107e9e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0107e9e:	55                   	push   %ebp
f0107e9f:	89 e5                	mov    %esp,%ebp
f0107ea1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0107ea4:	8b 45 10             	mov    0x10(%ebp),%eax
f0107ea7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107eab:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107eae:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107eb2:	8b 45 08             	mov    0x8(%ebp),%eax
f0107eb5:	89 04 24             	mov    %eax,(%esp)
f0107eb8:	e8 77 ff ff ff       	call   f0107e34 <memmove>
}
f0107ebd:	c9                   	leave  
f0107ebe:	c3                   	ret    

f0107ebf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0107ebf:	55                   	push   %ebp
f0107ec0:	89 e5                	mov    %esp,%ebp
f0107ec2:	57                   	push   %edi
f0107ec3:	56                   	push   %esi
f0107ec4:	53                   	push   %ebx
f0107ec5:	8b 7d 08             	mov    0x8(%ebp),%edi
f0107ec8:	8b 75 0c             	mov    0xc(%ebp),%esi
f0107ecb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0107ece:	ba 00 00 00 00       	mov    $0x0,%edx
f0107ed3:	eb 16                	jmp    f0107eeb <memcmp+0x2c>
		if (*s1 != *s2)
f0107ed5:	8a 04 17             	mov    (%edi,%edx,1),%al
f0107ed8:	42                   	inc    %edx
f0107ed9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f0107edd:	38 c8                	cmp    %cl,%al
f0107edf:	74 0a                	je     f0107eeb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f0107ee1:	0f b6 c0             	movzbl %al,%eax
f0107ee4:	0f b6 c9             	movzbl %cl,%ecx
f0107ee7:	29 c8                	sub    %ecx,%eax
f0107ee9:	eb 09                	jmp    f0107ef4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0107eeb:	39 da                	cmp    %ebx,%edx
f0107eed:	75 e6                	jne    f0107ed5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0107eef:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0107ef4:	5b                   	pop    %ebx
f0107ef5:	5e                   	pop    %esi
f0107ef6:	5f                   	pop    %edi
f0107ef7:	5d                   	pop    %ebp
f0107ef8:	c3                   	ret    

f0107ef9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0107ef9:	55                   	push   %ebp
f0107efa:	89 e5                	mov    %esp,%ebp
f0107efc:	8b 45 08             	mov    0x8(%ebp),%eax
f0107eff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0107f02:	89 c2                	mov    %eax,%edx
f0107f04:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0107f07:	eb 05                	jmp    f0107f0e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0107f09:	38 08                	cmp    %cl,(%eax)
f0107f0b:	74 05                	je     f0107f12 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0107f0d:	40                   	inc    %eax
f0107f0e:	39 d0                	cmp    %edx,%eax
f0107f10:	72 f7                	jb     f0107f09 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0107f12:	5d                   	pop    %ebp
f0107f13:	c3                   	ret    

f0107f14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0107f14:	55                   	push   %ebp
f0107f15:	89 e5                	mov    %esp,%ebp
f0107f17:	57                   	push   %edi
f0107f18:	56                   	push   %esi
f0107f19:	53                   	push   %ebx
f0107f1a:	8b 55 08             	mov    0x8(%ebp),%edx
f0107f1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0107f20:	eb 01                	jmp    f0107f23 <strtol+0xf>
		s++;
f0107f22:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0107f23:	8a 02                	mov    (%edx),%al
f0107f25:	3c 20                	cmp    $0x20,%al
f0107f27:	74 f9                	je     f0107f22 <strtol+0xe>
f0107f29:	3c 09                	cmp    $0x9,%al
f0107f2b:	74 f5                	je     f0107f22 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0107f2d:	3c 2b                	cmp    $0x2b,%al
f0107f2f:	75 08                	jne    f0107f39 <strtol+0x25>
		s++;
f0107f31:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0107f32:	bf 00 00 00 00       	mov    $0x0,%edi
f0107f37:	eb 13                	jmp    f0107f4c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0107f39:	3c 2d                	cmp    $0x2d,%al
f0107f3b:	75 0a                	jne    f0107f47 <strtol+0x33>
		s++, neg = 1;
f0107f3d:	8d 52 01             	lea    0x1(%edx),%edx
f0107f40:	bf 01 00 00 00       	mov    $0x1,%edi
f0107f45:	eb 05                	jmp    f0107f4c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0107f47:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0107f4c:	85 db                	test   %ebx,%ebx
f0107f4e:	74 05                	je     f0107f55 <strtol+0x41>
f0107f50:	83 fb 10             	cmp    $0x10,%ebx
f0107f53:	75 28                	jne    f0107f7d <strtol+0x69>
f0107f55:	8a 02                	mov    (%edx),%al
f0107f57:	3c 30                	cmp    $0x30,%al
f0107f59:	75 10                	jne    f0107f6b <strtol+0x57>
f0107f5b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0107f5f:	75 0a                	jne    f0107f6b <strtol+0x57>
		s += 2, base = 16;
f0107f61:	83 c2 02             	add    $0x2,%edx
f0107f64:	bb 10 00 00 00       	mov    $0x10,%ebx
f0107f69:	eb 12                	jmp    f0107f7d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0107f6b:	85 db                	test   %ebx,%ebx
f0107f6d:	75 0e                	jne    f0107f7d <strtol+0x69>
f0107f6f:	3c 30                	cmp    $0x30,%al
f0107f71:	75 05                	jne    f0107f78 <strtol+0x64>
		s++, base = 8;
f0107f73:	42                   	inc    %edx
f0107f74:	b3 08                	mov    $0x8,%bl
f0107f76:	eb 05                	jmp    f0107f7d <strtol+0x69>
	else if (base == 0)
		base = 10;
f0107f78:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0107f7d:	b8 00 00 00 00       	mov    $0x0,%eax
f0107f82:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0107f84:	8a 0a                	mov    (%edx),%cl
f0107f86:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0107f89:	80 fb 09             	cmp    $0x9,%bl
f0107f8c:	77 08                	ja     f0107f96 <strtol+0x82>
			dig = *s - '0';
f0107f8e:	0f be c9             	movsbl %cl,%ecx
f0107f91:	83 e9 30             	sub    $0x30,%ecx
f0107f94:	eb 1e                	jmp    f0107fb4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0107f96:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0107f99:	80 fb 19             	cmp    $0x19,%bl
f0107f9c:	77 08                	ja     f0107fa6 <strtol+0x92>
			dig = *s - 'a' + 10;
f0107f9e:	0f be c9             	movsbl %cl,%ecx
f0107fa1:	83 e9 57             	sub    $0x57,%ecx
f0107fa4:	eb 0e                	jmp    f0107fb4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0107fa6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0107fa9:	80 fb 19             	cmp    $0x19,%bl
f0107fac:	77 12                	ja     f0107fc0 <strtol+0xac>
			dig = *s - 'A' + 10;
f0107fae:	0f be c9             	movsbl %cl,%ecx
f0107fb1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0107fb4:	39 f1                	cmp    %esi,%ecx
f0107fb6:	7d 0c                	jge    f0107fc4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0107fb8:	42                   	inc    %edx
f0107fb9:	0f af c6             	imul   %esi,%eax
f0107fbc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0107fbe:	eb c4                	jmp    f0107f84 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0107fc0:	89 c1                	mov    %eax,%ecx
f0107fc2:	eb 02                	jmp    f0107fc6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0107fc4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0107fc6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0107fca:	74 05                	je     f0107fd1 <strtol+0xbd>
		*endptr = (char *) s;
f0107fcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0107fcf:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0107fd1:	85 ff                	test   %edi,%edi
f0107fd3:	74 04                	je     f0107fd9 <strtol+0xc5>
f0107fd5:	89 c8                	mov    %ecx,%eax
f0107fd7:	f7 d8                	neg    %eax
}
f0107fd9:	5b                   	pop    %ebx
f0107fda:	5e                   	pop    %esi
f0107fdb:	5f                   	pop    %edi
f0107fdc:	5d                   	pop    %ebp
f0107fdd:	c3                   	ret    
	...

f0107fe0 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0107fe0:	fa                   	cli    

	xorw    %ax, %ax
f0107fe1:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0107fe3:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0107fe5:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0107fe7:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0107fe9:	0f 01 16             	lgdtl  (%esi)
f0107fec:	74 70                	je     f010805e <sum+0x2>
	movl    %cr0, %eax
f0107fee:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0107ff1:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0107ff5:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0107ff8:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0107ffe:	08 00                	or     %al,(%eax)

f0108000 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0108000:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0108004:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0108006:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0108008:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010800a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010800e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0108010:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0108012:	b8 00 c0 12 00       	mov    $0x12c000,%eax
	movl    %eax, %cr3
f0108017:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010801a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f010801d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0108022:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0108025:	8b 25 84 8e 35 f0    	mov    0xf0358e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010802b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0108030:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f0108035:	ff d0                	call   *%eax

f0108037 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0108037:	eb fe                	jmp    f0108037 <spin>
f0108039:	8d 76 00             	lea    0x0(%esi),%esi

f010803c <gdt>:
	...
f0108044:	ff                   	(bad)  
f0108045:	ff 00                	incl   (%eax)
f0108047:	00 00                	add    %al,(%eax)
f0108049:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0108050:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0108054 <gdtdesc>:
f0108054:	17                   	pop    %ss
f0108055:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010805a <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010805a:	90                   	nop
	...

f010805c <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f010805c:	55                   	push   %ebp
f010805d:	89 e5                	mov    %esp,%ebp
f010805f:	56                   	push   %esi
f0108060:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f0108061:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f0108066:	b9 00 00 00 00       	mov    $0x0,%ecx
f010806b:	eb 07                	jmp    f0108074 <sum+0x18>
		sum += ((uint8_t *)addr)[i];
f010806d:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0108071:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0108073:	41                   	inc    %ecx
f0108074:	39 d1                	cmp    %edx,%ecx
f0108076:	7c f5                	jl     f010806d <sum+0x11>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0108078:	88 d8                	mov    %bl,%al
f010807a:	5b                   	pop    %ebx
f010807b:	5e                   	pop    %esi
f010807c:	5d                   	pop    %ebp
f010807d:	c3                   	ret    

f010807e <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f010807e:	55                   	push   %ebp
f010807f:	89 e5                	mov    %esp,%ebp
f0108081:	56                   	push   %esi
f0108082:	53                   	push   %ebx
f0108083:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0108086:	8b 0d 88 8e 35 f0    	mov    0xf0358e88,%ecx
f010808c:	89 c3                	mov    %eax,%ebx
f010808e:	c1 eb 0c             	shr    $0xc,%ebx
f0108091:	39 cb                	cmp    %ecx,%ebx
f0108093:	72 20                	jb     f01080b5 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0108095:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0108099:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f01080a0:	f0 
f01080a1:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01080a8:	00 
f01080a9:	c7 04 24 65 ad 10 f0 	movl   $0xf010ad65,(%esp)
f01080b0:	e8 8b 7f ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01080b5:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01080b8:	89 f2                	mov    %esi,%edx
f01080ba:	c1 ea 0c             	shr    $0xc,%edx
f01080bd:	39 d1                	cmp    %edx,%ecx
f01080bf:	77 20                	ja     f01080e1 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01080c1:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01080c5:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f01080cc:	f0 
f01080cd:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01080d4:	00 
f01080d5:	c7 04 24 65 ad 10 f0 	movl   $0xf010ad65,(%esp)
f01080dc:	e8 5f 7f ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01080e1:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01080e7:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f01080ed:	eb 2f                	jmp    f010811e <mpsearch1+0xa0>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01080ef:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01080f6:	00 
f01080f7:	c7 44 24 04 75 ad 10 	movl   $0xf010ad75,0x4(%esp)
f01080fe:	f0 
f01080ff:	89 1c 24             	mov    %ebx,(%esp)
f0108102:	e8 b8 fd ff ff       	call   f0107ebf <memcmp>
f0108107:	85 c0                	test   %eax,%eax
f0108109:	75 10                	jne    f010811b <mpsearch1+0x9d>
		    sum(mp, sizeof(*mp)) == 0)
f010810b:	ba 10 00 00 00       	mov    $0x10,%edx
f0108110:	89 d8                	mov    %ebx,%eax
f0108112:	e8 45 ff ff ff       	call   f010805c <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0108117:	84 c0                	test   %al,%al
f0108119:	74 0c                	je     f0108127 <mpsearch1+0xa9>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f010811b:	83 c3 10             	add    $0x10,%ebx
f010811e:	39 f3                	cmp    %esi,%ebx
f0108120:	72 cd                	jb     f01080ef <mpsearch1+0x71>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0108122:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0108127:	89 d8                	mov    %ebx,%eax
f0108129:	83 c4 10             	add    $0x10,%esp
f010812c:	5b                   	pop    %ebx
f010812d:	5e                   	pop    %esi
f010812e:	5d                   	pop    %ebp
f010812f:	c3                   	ret    

f0108130 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0108130:	55                   	push   %ebp
f0108131:	89 e5                	mov    %esp,%ebp
f0108133:	57                   	push   %edi
f0108134:	56                   	push   %esi
f0108135:	53                   	push   %ebx
f0108136:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0108139:	c7 05 c0 93 35 f0 20 	movl   $0xf0359020,0xf03593c0
f0108140:	90 35 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0108143:	83 3d 88 8e 35 f0 00 	cmpl   $0x0,0xf0358e88
f010814a:	75 24                	jne    f0108170 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010814c:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0108153:	00 
f0108154:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f010815b:	f0 
f010815c:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0108163:	00 
f0108164:	c7 04 24 65 ad 10 f0 	movl   $0xf010ad65,(%esp)
f010816b:	e8 d0 7e ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0108170:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0108177:	85 c0                	test   %eax,%eax
f0108179:	74 16                	je     f0108191 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f010817b:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f010817e:	ba 00 04 00 00       	mov    $0x400,%edx
f0108183:	e8 f6 fe ff ff       	call   f010807e <mpsearch1>
f0108188:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010818b:	85 c0                	test   %eax,%eax
f010818d:	75 3c                	jne    f01081cb <mp_init+0x9b>
f010818f:	eb 20                	jmp    f01081b1 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0108191:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0108198:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f010819b:	2d 00 04 00 00       	sub    $0x400,%eax
f01081a0:	ba 00 04 00 00       	mov    $0x400,%edx
f01081a5:	e8 d4 fe ff ff       	call   f010807e <mpsearch1>
f01081aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01081ad:	85 c0                	test   %eax,%eax
f01081af:	75 1a                	jne    f01081cb <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01081b1:	ba 00 00 01 00       	mov    $0x10000,%edx
f01081b6:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01081bb:	e8 be fe ff ff       	call   f010807e <mpsearch1>
f01081c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01081c3:	85 c0                	test   %eax,%eax
f01081c5:	0f 84 2c 02 00 00    	je     f01083f7 <mp_init+0x2c7>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01081cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01081ce:	8b 58 04             	mov    0x4(%eax),%ebx
f01081d1:	85 db                	test   %ebx,%ebx
f01081d3:	74 06                	je     f01081db <mp_init+0xab>
f01081d5:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01081d9:	74 11                	je     f01081ec <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f01081db:	c7 04 24 d8 ab 10 f0 	movl   $0xf010abd8,(%esp)
f01081e2:	e8 a3 c0 ff ff       	call   f010428a <cprintf>
f01081e7:	e9 0b 02 00 00       	jmp    f01083f7 <mp_init+0x2c7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01081ec:	89 d8                	mov    %ebx,%eax
f01081ee:	c1 e8 0c             	shr    $0xc,%eax
f01081f1:	3b 05 88 8e 35 f0    	cmp    0xf0358e88,%eax
f01081f7:	72 20                	jb     f0108219 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01081f9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01081fd:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f0108204:	f0 
f0108205:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f010820c:	00 
f010820d:	c7 04 24 65 ad 10 f0 	movl   $0xf010ad65,(%esp)
f0108214:	e8 27 7e ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0108219:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f010821f:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0108226:	00 
f0108227:	c7 44 24 04 7a ad 10 	movl   $0xf010ad7a,0x4(%esp)
f010822e:	f0 
f010822f:	89 1c 24             	mov    %ebx,(%esp)
f0108232:	e8 88 fc ff ff       	call   f0107ebf <memcmp>
f0108237:	85 c0                	test   %eax,%eax
f0108239:	74 11                	je     f010824c <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010823b:	c7 04 24 08 ac 10 f0 	movl   $0xf010ac08,(%esp)
f0108242:	e8 43 c0 ff ff       	call   f010428a <cprintf>
f0108247:	e9 ab 01 00 00       	jmp    f01083f7 <mp_init+0x2c7>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010824c:	66 8b 73 04          	mov    0x4(%ebx),%si
f0108250:	0f b7 d6             	movzwl %si,%edx
f0108253:	89 d8                	mov    %ebx,%eax
f0108255:	e8 02 fe ff ff       	call   f010805c <sum>
f010825a:	84 c0                	test   %al,%al
f010825c:	74 11                	je     f010826f <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f010825e:	c7 04 24 3c ac 10 f0 	movl   $0xf010ac3c,(%esp)
f0108265:	e8 20 c0 ff ff       	call   f010428a <cprintf>
f010826a:	e9 88 01 00 00       	jmp    f01083f7 <mp_init+0x2c7>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f010826f:	8a 43 06             	mov    0x6(%ebx),%al
f0108272:	3c 01                	cmp    $0x1,%al
f0108274:	74 1c                	je     f0108292 <mp_init+0x162>
f0108276:	3c 04                	cmp    $0x4,%al
f0108278:	74 18                	je     f0108292 <mp_init+0x162>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010827a:	0f b6 c0             	movzbl %al,%eax
f010827d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108281:	c7 04 24 60 ac 10 f0 	movl   $0xf010ac60,(%esp)
f0108288:	e8 fd bf ff ff       	call   f010428a <cprintf>
f010828d:	e9 65 01 00 00       	jmp    f01083f7 <mp_init+0x2c7>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0108292:	0f b7 53 28          	movzwl 0x28(%ebx),%edx
f0108296:	0f b7 c6             	movzwl %si,%eax
f0108299:	01 d8                	add    %ebx,%eax
f010829b:	e8 bc fd ff ff       	call   f010805c <sum>
f01082a0:	02 43 2a             	add    0x2a(%ebx),%al
f01082a3:	84 c0                	test   %al,%al
f01082a5:	74 11                	je     f01082b8 <mp_init+0x188>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01082a7:	c7 04 24 80 ac 10 f0 	movl   $0xf010ac80,(%esp)
f01082ae:	e8 d7 bf ff ff       	call   f010428a <cprintf>
f01082b3:	e9 3f 01 00 00       	jmp    f01083f7 <mp_init+0x2c7>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01082b8:	85 db                	test   %ebx,%ebx
f01082ba:	0f 84 37 01 00 00    	je     f01083f7 <mp_init+0x2c7>
		return;
	ismp = 1;
f01082c0:	c7 05 00 90 35 f0 01 	movl   $0x1,0xf0359000
f01082c7:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01082ca:	8b 43 24             	mov    0x24(%ebx),%eax
f01082cd:	a3 00 a0 39 f0       	mov    %eax,0xf039a000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01082d2:	8d 73 2c             	lea    0x2c(%ebx),%esi
f01082d5:	bf 00 00 00 00       	mov    $0x0,%edi
f01082da:	e9 94 00 00 00       	jmp    f0108373 <mp_init+0x243>
		switch (*p) {
f01082df:	8a 06                	mov    (%esi),%al
f01082e1:	84 c0                	test   %al,%al
f01082e3:	74 06                	je     f01082eb <mp_init+0x1bb>
f01082e5:	3c 04                	cmp    $0x4,%al
f01082e7:	77 68                	ja     f0108351 <mp_init+0x221>
f01082e9:	eb 61                	jmp    f010834c <mp_init+0x21c>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01082eb:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f01082ef:	74 1d                	je     f010830e <mp_init+0x1de>
				bootcpu = &cpus[ncpu];
f01082f1:	a1 c4 93 35 f0       	mov    0xf03593c4,%eax
f01082f6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01082fd:	29 c2                	sub    %eax,%edx
f01082ff:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0108302:	8d 04 85 20 90 35 f0 	lea    -0xfca6fe0(,%eax,4),%eax
f0108309:	a3 c0 93 35 f0       	mov    %eax,0xf03593c0
			if (ncpu < NCPU) {
f010830e:	a1 c4 93 35 f0       	mov    0xf03593c4,%eax
f0108313:	83 f8 07             	cmp    $0x7,%eax
f0108316:	7f 1b                	jg     f0108333 <mp_init+0x203>
				cpus[ncpu].cpu_id = ncpu;
f0108318:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010831f:	29 c2                	sub    %eax,%edx
f0108321:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0108324:	88 04 95 20 90 35 f0 	mov    %al,-0xfca6fe0(,%edx,4)
				ncpu++;
f010832b:	40                   	inc    %eax
f010832c:	a3 c4 93 35 f0       	mov    %eax,0xf03593c4
f0108331:	eb 14                	jmp    f0108347 <mp_init+0x217>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0108333:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0108337:	89 44 24 04          	mov    %eax,0x4(%esp)
f010833b:	c7 04 24 b0 ac 10 f0 	movl   $0xf010acb0,(%esp)
f0108342:	e8 43 bf ff ff       	call   f010428a <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0108347:	83 c6 14             	add    $0x14,%esi
			continue;
f010834a:	eb 26                	jmp    f0108372 <mp_init+0x242>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f010834c:	83 c6 08             	add    $0x8,%esi
			continue;
f010834f:	eb 21                	jmp    f0108372 <mp_init+0x242>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0108351:	0f b6 c0             	movzbl %al,%eax
f0108354:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108358:	c7 04 24 d8 ac 10 f0 	movl   $0xf010acd8,(%esp)
f010835f:	e8 26 bf ff ff       	call   f010428a <cprintf>
			ismp = 0;
f0108364:	c7 05 00 90 35 f0 00 	movl   $0x0,0xf0359000
f010836b:	00 00 00 
			i = conf->entry;
f010836e:	0f b7 7b 22          	movzwl 0x22(%ebx),%edi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0108372:	47                   	inc    %edi
f0108373:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0108377:	39 c7                	cmp    %eax,%edi
f0108379:	0f 82 60 ff ff ff    	jb     f01082df <mp_init+0x1af>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010837f:	a1 c0 93 35 f0       	mov    0xf03593c0,%eax
f0108384:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010838b:	83 3d 00 90 35 f0 00 	cmpl   $0x0,0xf0359000
f0108392:	75 22                	jne    f01083b6 <mp_init+0x286>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0108394:	c7 05 c4 93 35 f0 01 	movl   $0x1,0xf03593c4
f010839b:	00 00 00 
		lapicaddr = 0;
f010839e:	c7 05 00 a0 39 f0 00 	movl   $0x0,0xf039a000
f01083a5:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01083a8:	c7 04 24 f8 ac 10 f0 	movl   $0xf010acf8,(%esp)
f01083af:	e8 d6 be ff ff       	call   f010428a <cprintf>
		return;
f01083b4:	eb 41                	jmp    f01083f7 <mp_init+0x2c7>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01083b6:	8b 15 c4 93 35 f0    	mov    0xf03593c4,%edx
f01083bc:	89 54 24 08          	mov    %edx,0x8(%esp)
f01083c0:	0f b6 00             	movzbl (%eax),%eax
f01083c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01083c7:	c7 04 24 7f ad 10 f0 	movl   $0xf010ad7f,(%esp)
f01083ce:	e8 b7 be ff ff       	call   f010428a <cprintf>

	if (mp->imcrp) {
f01083d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01083d6:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01083da:	74 1b                	je     f01083f7 <mp_init+0x2c7>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01083dc:	c7 04 24 24 ad 10 f0 	movl   $0xf010ad24,(%esp)
f01083e3:	e8 a2 be ff ff       	call   f010428a <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01083e8:	ba 22 00 00 00       	mov    $0x22,%edx
f01083ed:	b0 70                	mov    $0x70,%al
f01083ef:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01083f0:	b2 23                	mov    $0x23,%dl
f01083f2:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01083f3:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01083f6:	ee                   	out    %al,(%dx)
	}
}
f01083f7:	83 c4 2c             	add    $0x2c,%esp
f01083fa:	5b                   	pop    %ebx
f01083fb:	5e                   	pop    %esi
f01083fc:	5f                   	pop    %edi
f01083fd:	5d                   	pop    %ebp
f01083fe:	c3                   	ret    
	...

f0108400 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0108400:	55                   	push   %ebp
f0108401:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0108403:	c1 e0 02             	shl    $0x2,%eax
f0108406:	03 05 04 a0 39 f0    	add    0xf039a004,%eax
f010840c:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010840e:	a1 04 a0 39 f0       	mov    0xf039a004,%eax
f0108413:	8b 40 20             	mov    0x20(%eax),%eax
}
f0108416:	5d                   	pop    %ebp
f0108417:	c3                   	ret    

f0108418 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0108418:	55                   	push   %ebp
f0108419:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010841b:	a1 04 a0 39 f0       	mov    0xf039a004,%eax
f0108420:	85 c0                	test   %eax,%eax
f0108422:	74 08                	je     f010842c <cpunum+0x14>
		return lapic[ID] >> 24;
f0108424:	8b 40 20             	mov    0x20(%eax),%eax
f0108427:	c1 e8 18             	shr    $0x18,%eax
f010842a:	eb 05                	jmp    f0108431 <cpunum+0x19>
	return 0;
f010842c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0108431:	5d                   	pop    %ebp
f0108432:	c3                   	ret    

f0108433 <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0108433:	55                   	push   %ebp
f0108434:	89 e5                	mov    %esp,%ebp
f0108436:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f0108439:	a1 00 a0 39 f0       	mov    0xf039a000,%eax
f010843e:	85 c0                	test   %eax,%eax
f0108440:	0f 84 27 01 00 00    	je     f010856d <lapic_init+0x13a>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0108446:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010844d:	00 
f010844e:	89 04 24             	mov    %eax,(%esp)
f0108451:	e8 de 91 ff ff       	call   f0101634 <mmio_map_region>
f0108456:	a3 04 a0 39 f0       	mov    %eax,0xf039a004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010845b:	ba 27 01 00 00       	mov    $0x127,%edx
f0108460:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0108465:	e8 96 ff ff ff       	call   f0108400 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010846a:	ba 0b 00 00 00       	mov    $0xb,%edx
f010846f:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0108474:	e8 87 ff ff ff       	call   f0108400 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0108479:	ba 20 00 02 00       	mov    $0x20020,%edx
f010847e:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0108483:	e8 78 ff ff ff       	call   f0108400 <lapicw>
	lapicw(TICR, 10000000); 
f0108488:	ba 80 96 98 00       	mov    $0x989680,%edx
f010848d:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0108492:	e8 69 ff ff ff       	call   f0108400 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0108497:	e8 7c ff ff ff       	call   f0108418 <cpunum>
f010849c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01084a3:	29 c2                	sub    %eax,%edx
f01084a5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01084a8:	8d 04 85 20 90 35 f0 	lea    -0xfca6fe0(,%eax,4),%eax
f01084af:	39 05 c0 93 35 f0    	cmp    %eax,0xf03593c0
f01084b5:	74 0f                	je     f01084c6 <lapic_init+0x93>
		lapicw(LINT0, MASKED);
f01084b7:	ba 00 00 01 00       	mov    $0x10000,%edx
f01084bc:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01084c1:	e8 3a ff ff ff       	call   f0108400 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01084c6:	ba 00 00 01 00       	mov    $0x10000,%edx
f01084cb:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01084d0:	e8 2b ff ff ff       	call   f0108400 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01084d5:	a1 04 a0 39 f0       	mov    0xf039a004,%eax
f01084da:	8b 40 30             	mov    0x30(%eax),%eax
f01084dd:	c1 e8 10             	shr    $0x10,%eax
f01084e0:	3c 03                	cmp    $0x3,%al
f01084e2:	76 0f                	jbe    f01084f3 <lapic_init+0xc0>
		lapicw(PCINT, MASKED);
f01084e4:	ba 00 00 01 00       	mov    $0x10000,%edx
f01084e9:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01084ee:	e8 0d ff ff ff       	call   f0108400 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01084f3:	ba 33 00 00 00       	mov    $0x33,%edx
f01084f8:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01084fd:	e8 fe fe ff ff       	call   f0108400 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0108502:	ba 00 00 00 00       	mov    $0x0,%edx
f0108507:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010850c:	e8 ef fe ff ff       	call   f0108400 <lapicw>
	lapicw(ESR, 0);
f0108511:	ba 00 00 00 00       	mov    $0x0,%edx
f0108516:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010851b:	e8 e0 fe ff ff       	call   f0108400 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0108520:	ba 00 00 00 00       	mov    $0x0,%edx
f0108525:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010852a:	e8 d1 fe ff ff       	call   f0108400 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010852f:	ba 00 00 00 00       	mov    $0x0,%edx
f0108534:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0108539:	e8 c2 fe ff ff       	call   f0108400 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010853e:	ba 00 85 08 00       	mov    $0x88500,%edx
f0108543:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0108548:	e8 b3 fe ff ff       	call   f0108400 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010854d:	8b 15 04 a0 39 f0    	mov    0xf039a004,%edx
f0108553:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0108559:	f6 c4 10             	test   $0x10,%ah
f010855c:	75 f5                	jne    f0108553 <lapic_init+0x120>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010855e:	ba 00 00 00 00       	mov    $0x0,%edx
f0108563:	b8 20 00 00 00       	mov    $0x20,%eax
f0108568:	e8 93 fe ff ff       	call   f0108400 <lapicw>
}
f010856d:	c9                   	leave  
f010856e:	c3                   	ret    

f010856f <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010856f:	55                   	push   %ebp
f0108570:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0108572:	83 3d 04 a0 39 f0 00 	cmpl   $0x0,0xf039a004
f0108579:	74 0f                	je     f010858a <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f010857b:	ba 00 00 00 00       	mov    $0x0,%edx
f0108580:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0108585:	e8 76 fe ff ff       	call   f0108400 <lapicw>
}
f010858a:	5d                   	pop    %ebp
f010858b:	c3                   	ret    

f010858c <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010858c:	55                   	push   %ebp
f010858d:	89 e5                	mov    %esp,%ebp
f010858f:	56                   	push   %esi
f0108590:	53                   	push   %ebx
f0108591:	83 ec 10             	sub    $0x10,%esp
f0108594:	8b 75 0c             	mov    0xc(%ebp),%esi
f0108597:	8a 5d 08             	mov    0x8(%ebp),%bl
f010859a:	ba 70 00 00 00       	mov    $0x70,%edx
f010859f:	b0 0f                	mov    $0xf,%al
f01085a1:	ee                   	out    %al,(%dx)
f01085a2:	b2 71                	mov    $0x71,%dl
f01085a4:	b0 0a                	mov    $0xa,%al
f01085a6:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01085a7:	83 3d 88 8e 35 f0 00 	cmpl   $0x0,0xf0358e88
f01085ae:	75 24                	jne    f01085d4 <lapic_startap+0x48>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01085b0:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f01085b7:	00 
f01085b8:	c7 44 24 08 28 8b 10 	movl   $0xf0108b28,0x8(%esp)
f01085bf:	f0 
f01085c0:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f01085c7:	00 
f01085c8:	c7 04 24 9c ad 10 f0 	movl   $0xf010ad9c,(%esp)
f01085cf:	e8 6c 7a ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01085d4:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01085db:	00 00 
	wrv[1] = addr >> 4;
f01085dd:	89 f0                	mov    %esi,%eax
f01085df:	c1 e8 04             	shr    $0x4,%eax
f01085e2:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01085e8:	c1 e3 18             	shl    $0x18,%ebx
f01085eb:	89 da                	mov    %ebx,%edx
f01085ed:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01085f2:	e8 09 fe ff ff       	call   f0108400 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01085f7:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01085fc:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0108601:	e8 fa fd ff ff       	call   f0108400 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0108606:	ba 00 85 00 00       	mov    $0x8500,%edx
f010860b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0108610:	e8 eb fd ff ff       	call   f0108400 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0108615:	c1 ee 0c             	shr    $0xc,%esi
f0108618:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010861e:	89 da                	mov    %ebx,%edx
f0108620:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0108625:	e8 d6 fd ff ff       	call   f0108400 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010862a:	89 f2                	mov    %esi,%edx
f010862c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0108631:	e8 ca fd ff ff       	call   f0108400 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0108636:	89 da                	mov    %ebx,%edx
f0108638:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010863d:	e8 be fd ff ff       	call   f0108400 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0108642:	89 f2                	mov    %esi,%edx
f0108644:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0108649:	e8 b2 fd ff ff       	call   f0108400 <lapicw>
		microdelay(200);
	}
}
f010864e:	83 c4 10             	add    $0x10,%esp
f0108651:	5b                   	pop    %ebx
f0108652:	5e                   	pop    %esi
f0108653:	5d                   	pop    %ebp
f0108654:	c3                   	ret    

f0108655 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0108655:	55                   	push   %ebp
f0108656:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0108658:	8b 55 08             	mov    0x8(%ebp),%edx
f010865b:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0108661:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0108666:	e8 95 fd ff ff       	call   f0108400 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010866b:	8b 15 04 a0 39 f0    	mov    0xf039a004,%edx
f0108671:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0108677:	f6 c4 10             	test   $0x10,%ah
f010867a:	75 f5                	jne    f0108671 <lapic_ipi+0x1c>
		;
}
f010867c:	5d                   	pop    %ebp
f010867d:	c3                   	ret    
	...

f0108680 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0108680:	55                   	push   %ebp
f0108681:	89 e5                	mov    %esp,%ebp
f0108683:	53                   	push   %ebx
f0108684:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f0108687:	83 38 00             	cmpl   $0x0,(%eax)
f010868a:	74 25                	je     f01086b1 <holding+0x31>
f010868c:	8b 58 08             	mov    0x8(%eax),%ebx
f010868f:	e8 84 fd ff ff       	call   f0108418 <cpunum>
f0108694:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010869b:	29 c2                	sub    %eax,%edx
f010869d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01086a0:	8d 04 85 20 90 35 f0 	lea    -0xfca6fe0(,%eax,4),%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f01086a7:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f01086a9:	0f 94 c0             	sete   %al
f01086ac:	0f b6 c0             	movzbl %al,%eax
f01086af:	eb 05                	jmp    f01086b6 <holding+0x36>
f01086b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01086b6:	83 c4 04             	add    $0x4,%esp
f01086b9:	5b                   	pop    %ebx
f01086ba:	5d                   	pop    %ebp
f01086bb:	c3                   	ret    

f01086bc <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01086bc:	55                   	push   %ebp
f01086bd:	89 e5                	mov    %esp,%ebp
f01086bf:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01086c2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01086c8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01086cb:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01086ce:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01086d5:	5d                   	pop    %ebp
f01086d6:	c3                   	ret    

f01086d7 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01086d7:	55                   	push   %ebp
f01086d8:	89 e5                	mov    %esp,%ebp
f01086da:	53                   	push   %ebx
f01086db:	83 ec 24             	sub    $0x24,%esp
f01086de:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01086e1:	89 d8                	mov    %ebx,%eax
f01086e3:	e8 98 ff ff ff       	call   f0108680 <holding>
f01086e8:	85 c0                	test   %eax,%eax
f01086ea:	74 30                	je     f010871c <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01086ec:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01086ef:	e8 24 fd ff ff       	call   f0108418 <cpunum>
f01086f4:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f01086f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01086fc:	c7 44 24 08 ac ad 10 	movl   $0xf010adac,0x8(%esp)
f0108703:	f0 
f0108704:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f010870b:	00 
f010870c:	c7 04 24 10 ae 10 f0 	movl   $0xf010ae10,(%esp)
f0108713:	e8 28 79 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0108718:	f3 90                	pause  
f010871a:	eb 05                	jmp    f0108721 <spin_lock+0x4a>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010871c:	ba 01 00 00 00       	mov    $0x1,%edx
f0108721:	89 d0                	mov    %edx,%eax
f0108723:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0108726:	85 c0                	test   %eax,%eax
f0108728:	75 ee                	jne    f0108718 <spin_lock+0x41>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010872a:	e8 e9 fc ff ff       	call   f0108418 <cpunum>
f010872f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0108736:	29 c2                	sub    %eax,%edx
f0108738:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010873b:	8d 04 85 20 90 35 f0 	lea    -0xfca6fe0(,%eax,4),%eax
f0108742:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0108745:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0108748:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f010874a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010874f:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0108755:	76 10                	jbe    f0108767 <spin_lock+0x90>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0108757:	8b 4a 04             	mov    0x4(%edx),%ecx
f010875a:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010875d:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010875f:	40                   	inc    %eax
f0108760:	83 f8 0a             	cmp    $0xa,%eax
f0108763:	75 ea                	jne    f010874f <spin_lock+0x78>
f0108765:	eb 0d                	jmp    f0108774 <spin_lock+0x9d>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0108767:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f010876e:	40                   	inc    %eax
f010876f:	83 f8 09             	cmp    $0x9,%eax
f0108772:	7e f3                	jle    f0108767 <spin_lock+0x90>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0108774:	83 c4 24             	add    $0x24,%esp
f0108777:	5b                   	pop    %ebx
f0108778:	5d                   	pop    %ebp
f0108779:	c3                   	ret    

f010877a <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010877a:	55                   	push   %ebp
f010877b:	89 e5                	mov    %esp,%ebp
f010877d:	57                   	push   %edi
f010877e:	56                   	push   %esi
f010877f:	53                   	push   %ebx
f0108780:	83 ec 7c             	sub    $0x7c,%esp
f0108783:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0108786:	89 d8                	mov    %ebx,%eax
f0108788:	e8 f3 fe ff ff       	call   f0108680 <holding>
f010878d:	85 c0                	test   %eax,%eax
f010878f:	0f 85 d3 00 00 00    	jne    f0108868 <spin_unlock+0xee>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0108795:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f010879c:	00 
f010879d:	8d 43 0c             	lea    0xc(%ebx),%eax
f01087a0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01087a4:	8d 75 a8             	lea    -0x58(%ebp),%esi
f01087a7:	89 34 24             	mov    %esi,(%esp)
f01087aa:	e8 85 f6 ff ff       	call   f0107e34 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01087af:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01087b2:	0f b6 38             	movzbl (%eax),%edi
f01087b5:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01087b8:	e8 5b fc ff ff       	call   f0108418 <cpunum>
f01087bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01087c1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01087c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01087c9:	c7 04 24 d8 ad 10 f0 	movl   $0xf010add8,(%esp)
f01087d0:	e8 b5 ba ff ff       	call   f010428a <cprintf>
f01087d5:	89 f3                	mov    %esi,%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f01087d7:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01087da:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01087dd:	89 c7                	mov    %eax,%edi
f01087df:	eb 63                	jmp    f0108844 <spin_unlock+0xca>
f01087e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01087e5:	89 04 24             	mov    %eax,(%esp)
f01087e8:	e8 34 eb ff ff       	call   f0107321 <debuginfo_eip>
f01087ed:	85 c0                	test   %eax,%eax
f01087ef:	78 39                	js     f010882a <spin_unlock+0xb0>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01087f1:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01087f3:	89 c2                	mov    %eax,%edx
f01087f5:	2b 55 e0             	sub    -0x20(%ebp),%edx
f01087f8:	89 54 24 18          	mov    %edx,0x18(%esp)
f01087fc:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01087ff:	89 54 24 14          	mov    %edx,0x14(%esp)
f0108803:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0108806:	89 54 24 10          	mov    %edx,0x10(%esp)
f010880a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010880d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0108811:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0108814:	89 54 24 08          	mov    %edx,0x8(%esp)
f0108818:	89 44 24 04          	mov    %eax,0x4(%esp)
f010881c:	c7 04 24 20 ae 10 f0 	movl   $0xf010ae20,(%esp)
f0108823:	e8 62 ba ff ff       	call   f010428a <cprintf>
f0108828:	eb 12                	jmp    f010883c <spin_unlock+0xc2>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f010882a:	8b 06                	mov    (%esi),%eax
f010882c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108830:	c7 04 24 37 ae 10 f0 	movl   $0xf010ae37,(%esp)
f0108837:	e8 4e ba ff ff       	call   f010428a <cprintf>
f010883c:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010883f:	3b 5d a4             	cmp    -0x5c(%ebp),%ebx
f0108842:	74 08                	je     f010884c <spin_unlock+0xd2>
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0108844:	89 de                	mov    %ebx,%esi
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0108846:	8b 03                	mov    (%ebx),%eax
f0108848:	85 c0                	test   %eax,%eax
f010884a:	75 95                	jne    f01087e1 <spin_unlock+0x67>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010884c:	c7 44 24 08 3f ae 10 	movl   $0xf010ae3f,0x8(%esp)
f0108853:	f0 
f0108854:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f010885b:	00 
f010885c:	c7 04 24 10 ae 10 f0 	movl   $0xf010ae10,(%esp)
f0108863:	e8 d8 77 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0108868:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f010886f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
f0108876:	b8 00 00 00 00       	mov    $0x0,%eax
f010887b:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f010887e:	83 c4 7c             	add    $0x7c,%esp
f0108881:	5b                   	pop    %ebx
f0108882:	5e                   	pop    %esi
f0108883:	5f                   	pop    %edi
f0108884:	5d                   	pop    %ebp
f0108885:	c3                   	ret    
	...

f0108888 <__udivdi3>:
f0108888:	55                   	push   %ebp
f0108889:	57                   	push   %edi
f010888a:	56                   	push   %esi
f010888b:	83 ec 10             	sub    $0x10,%esp
f010888e:	8b 74 24 20          	mov    0x20(%esp),%esi
f0108892:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0108896:	89 74 24 04          	mov    %esi,0x4(%esp)
f010889a:	8b 7c 24 24          	mov    0x24(%esp),%edi
f010889e:	89 cd                	mov    %ecx,%ebp
f01088a0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f01088a4:	85 c0                	test   %eax,%eax
f01088a6:	75 2c                	jne    f01088d4 <__udivdi3+0x4c>
f01088a8:	39 f9                	cmp    %edi,%ecx
f01088aa:	77 68                	ja     f0108914 <__udivdi3+0x8c>
f01088ac:	85 c9                	test   %ecx,%ecx
f01088ae:	75 0b                	jne    f01088bb <__udivdi3+0x33>
f01088b0:	b8 01 00 00 00       	mov    $0x1,%eax
f01088b5:	31 d2                	xor    %edx,%edx
f01088b7:	f7 f1                	div    %ecx
f01088b9:	89 c1                	mov    %eax,%ecx
f01088bb:	31 d2                	xor    %edx,%edx
f01088bd:	89 f8                	mov    %edi,%eax
f01088bf:	f7 f1                	div    %ecx
f01088c1:	89 c7                	mov    %eax,%edi
f01088c3:	89 f0                	mov    %esi,%eax
f01088c5:	f7 f1                	div    %ecx
f01088c7:	89 c6                	mov    %eax,%esi
f01088c9:	89 f0                	mov    %esi,%eax
f01088cb:	89 fa                	mov    %edi,%edx
f01088cd:	83 c4 10             	add    $0x10,%esp
f01088d0:	5e                   	pop    %esi
f01088d1:	5f                   	pop    %edi
f01088d2:	5d                   	pop    %ebp
f01088d3:	c3                   	ret    
f01088d4:	39 f8                	cmp    %edi,%eax
f01088d6:	77 2c                	ja     f0108904 <__udivdi3+0x7c>
f01088d8:	0f bd f0             	bsr    %eax,%esi
f01088db:	83 f6 1f             	xor    $0x1f,%esi
f01088de:	75 4c                	jne    f010892c <__udivdi3+0xa4>
f01088e0:	39 f8                	cmp    %edi,%eax
f01088e2:	bf 00 00 00 00       	mov    $0x0,%edi
f01088e7:	72 0a                	jb     f01088f3 <__udivdi3+0x6b>
f01088e9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f01088ed:	0f 87 ad 00 00 00    	ja     f01089a0 <__udivdi3+0x118>
f01088f3:	be 01 00 00 00       	mov    $0x1,%esi
f01088f8:	89 f0                	mov    %esi,%eax
f01088fa:	89 fa                	mov    %edi,%edx
f01088fc:	83 c4 10             	add    $0x10,%esp
f01088ff:	5e                   	pop    %esi
f0108900:	5f                   	pop    %edi
f0108901:	5d                   	pop    %ebp
f0108902:	c3                   	ret    
f0108903:	90                   	nop
f0108904:	31 ff                	xor    %edi,%edi
f0108906:	31 f6                	xor    %esi,%esi
f0108908:	89 f0                	mov    %esi,%eax
f010890a:	89 fa                	mov    %edi,%edx
f010890c:	83 c4 10             	add    $0x10,%esp
f010890f:	5e                   	pop    %esi
f0108910:	5f                   	pop    %edi
f0108911:	5d                   	pop    %ebp
f0108912:	c3                   	ret    
f0108913:	90                   	nop
f0108914:	89 fa                	mov    %edi,%edx
f0108916:	89 f0                	mov    %esi,%eax
f0108918:	f7 f1                	div    %ecx
f010891a:	89 c6                	mov    %eax,%esi
f010891c:	31 ff                	xor    %edi,%edi
f010891e:	89 f0                	mov    %esi,%eax
f0108920:	89 fa                	mov    %edi,%edx
f0108922:	83 c4 10             	add    $0x10,%esp
f0108925:	5e                   	pop    %esi
f0108926:	5f                   	pop    %edi
f0108927:	5d                   	pop    %ebp
f0108928:	c3                   	ret    
f0108929:	8d 76 00             	lea    0x0(%esi),%esi
f010892c:	89 f1                	mov    %esi,%ecx
f010892e:	d3 e0                	shl    %cl,%eax
f0108930:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0108934:	b8 20 00 00 00       	mov    $0x20,%eax
f0108939:	29 f0                	sub    %esi,%eax
f010893b:	89 ea                	mov    %ebp,%edx
f010893d:	88 c1                	mov    %al,%cl
f010893f:	d3 ea                	shr    %cl,%edx
f0108941:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f0108945:	09 ca                	or     %ecx,%edx
f0108947:	89 54 24 08          	mov    %edx,0x8(%esp)
f010894b:	89 f1                	mov    %esi,%ecx
f010894d:	d3 e5                	shl    %cl,%ebp
f010894f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
f0108953:	89 fd                	mov    %edi,%ebp
f0108955:	88 c1                	mov    %al,%cl
f0108957:	d3 ed                	shr    %cl,%ebp
f0108959:	89 fa                	mov    %edi,%edx
f010895b:	89 f1                	mov    %esi,%ecx
f010895d:	d3 e2                	shl    %cl,%edx
f010895f:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0108963:	88 c1                	mov    %al,%cl
f0108965:	d3 ef                	shr    %cl,%edi
f0108967:	09 d7                	or     %edx,%edi
f0108969:	89 f8                	mov    %edi,%eax
f010896b:	89 ea                	mov    %ebp,%edx
f010896d:	f7 74 24 08          	divl   0x8(%esp)
f0108971:	89 d1                	mov    %edx,%ecx
f0108973:	89 c7                	mov    %eax,%edi
f0108975:	f7 64 24 0c          	mull   0xc(%esp)
f0108979:	39 d1                	cmp    %edx,%ecx
f010897b:	72 17                	jb     f0108994 <__udivdi3+0x10c>
f010897d:	74 09                	je     f0108988 <__udivdi3+0x100>
f010897f:	89 fe                	mov    %edi,%esi
f0108981:	31 ff                	xor    %edi,%edi
f0108983:	e9 41 ff ff ff       	jmp    f01088c9 <__udivdi3+0x41>
f0108988:	8b 54 24 04          	mov    0x4(%esp),%edx
f010898c:	89 f1                	mov    %esi,%ecx
f010898e:	d3 e2                	shl    %cl,%edx
f0108990:	39 c2                	cmp    %eax,%edx
f0108992:	73 eb                	jae    f010897f <__udivdi3+0xf7>
f0108994:	8d 77 ff             	lea    -0x1(%edi),%esi
f0108997:	31 ff                	xor    %edi,%edi
f0108999:	e9 2b ff ff ff       	jmp    f01088c9 <__udivdi3+0x41>
f010899e:	66 90                	xchg   %ax,%ax
f01089a0:	31 f6                	xor    %esi,%esi
f01089a2:	e9 22 ff ff ff       	jmp    f01088c9 <__udivdi3+0x41>
	...

f01089a8 <__umoddi3>:
f01089a8:	55                   	push   %ebp
f01089a9:	57                   	push   %edi
f01089aa:	56                   	push   %esi
f01089ab:	83 ec 20             	sub    $0x20,%esp
f01089ae:	8b 44 24 30          	mov    0x30(%esp),%eax
f01089b2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
f01089b6:	89 44 24 14          	mov    %eax,0x14(%esp)
f01089ba:	8b 74 24 34          	mov    0x34(%esp),%esi
f01089be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01089c2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01089c6:	89 c7                	mov    %eax,%edi
f01089c8:	89 f2                	mov    %esi,%edx
f01089ca:	85 ed                	test   %ebp,%ebp
f01089cc:	75 16                	jne    f01089e4 <__umoddi3+0x3c>
f01089ce:	39 f1                	cmp    %esi,%ecx
f01089d0:	0f 86 a6 00 00 00    	jbe    f0108a7c <__umoddi3+0xd4>
f01089d6:	f7 f1                	div    %ecx
f01089d8:	89 d0                	mov    %edx,%eax
f01089da:	31 d2                	xor    %edx,%edx
f01089dc:	83 c4 20             	add    $0x20,%esp
f01089df:	5e                   	pop    %esi
f01089e0:	5f                   	pop    %edi
f01089e1:	5d                   	pop    %ebp
f01089e2:	c3                   	ret    
f01089e3:	90                   	nop
f01089e4:	39 f5                	cmp    %esi,%ebp
f01089e6:	0f 87 ac 00 00 00    	ja     f0108a98 <__umoddi3+0xf0>
f01089ec:	0f bd c5             	bsr    %ebp,%eax
f01089ef:	83 f0 1f             	xor    $0x1f,%eax
f01089f2:	89 44 24 10          	mov    %eax,0x10(%esp)
f01089f6:	0f 84 a8 00 00 00    	je     f0108aa4 <__umoddi3+0xfc>
f01089fc:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0108a00:	d3 e5                	shl    %cl,%ebp
f0108a02:	bf 20 00 00 00       	mov    $0x20,%edi
f0108a07:	2b 7c 24 10          	sub    0x10(%esp),%edi
f0108a0b:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0108a0f:	89 f9                	mov    %edi,%ecx
f0108a11:	d3 e8                	shr    %cl,%eax
f0108a13:	09 e8                	or     %ebp,%eax
f0108a15:	89 44 24 18          	mov    %eax,0x18(%esp)
f0108a19:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0108a1d:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0108a21:	d3 e0                	shl    %cl,%eax
f0108a23:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0108a27:	89 f2                	mov    %esi,%edx
f0108a29:	d3 e2                	shl    %cl,%edx
f0108a2b:	8b 44 24 14          	mov    0x14(%esp),%eax
f0108a2f:	d3 e0                	shl    %cl,%eax
f0108a31:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0108a35:	8b 44 24 14          	mov    0x14(%esp),%eax
f0108a39:	89 f9                	mov    %edi,%ecx
f0108a3b:	d3 e8                	shr    %cl,%eax
f0108a3d:	09 d0                	or     %edx,%eax
f0108a3f:	d3 ee                	shr    %cl,%esi
f0108a41:	89 f2                	mov    %esi,%edx
f0108a43:	f7 74 24 18          	divl   0x18(%esp)
f0108a47:	89 d6                	mov    %edx,%esi
f0108a49:	f7 64 24 0c          	mull   0xc(%esp)
f0108a4d:	89 c5                	mov    %eax,%ebp
f0108a4f:	89 d1                	mov    %edx,%ecx
f0108a51:	39 d6                	cmp    %edx,%esi
f0108a53:	72 67                	jb     f0108abc <__umoddi3+0x114>
f0108a55:	74 75                	je     f0108acc <__umoddi3+0x124>
f0108a57:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0108a5b:	29 e8                	sub    %ebp,%eax
f0108a5d:	19 ce                	sbb    %ecx,%esi
f0108a5f:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0108a63:	d3 e8                	shr    %cl,%eax
f0108a65:	89 f2                	mov    %esi,%edx
f0108a67:	89 f9                	mov    %edi,%ecx
f0108a69:	d3 e2                	shl    %cl,%edx
f0108a6b:	09 d0                	or     %edx,%eax
f0108a6d:	89 f2                	mov    %esi,%edx
f0108a6f:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0108a73:	d3 ea                	shr    %cl,%edx
f0108a75:	83 c4 20             	add    $0x20,%esp
f0108a78:	5e                   	pop    %esi
f0108a79:	5f                   	pop    %edi
f0108a7a:	5d                   	pop    %ebp
f0108a7b:	c3                   	ret    
f0108a7c:	85 c9                	test   %ecx,%ecx
f0108a7e:	75 0b                	jne    f0108a8b <__umoddi3+0xe3>
f0108a80:	b8 01 00 00 00       	mov    $0x1,%eax
f0108a85:	31 d2                	xor    %edx,%edx
f0108a87:	f7 f1                	div    %ecx
f0108a89:	89 c1                	mov    %eax,%ecx
f0108a8b:	89 f0                	mov    %esi,%eax
f0108a8d:	31 d2                	xor    %edx,%edx
f0108a8f:	f7 f1                	div    %ecx
f0108a91:	89 f8                	mov    %edi,%eax
f0108a93:	e9 3e ff ff ff       	jmp    f01089d6 <__umoddi3+0x2e>
f0108a98:	89 f2                	mov    %esi,%edx
f0108a9a:	83 c4 20             	add    $0x20,%esp
f0108a9d:	5e                   	pop    %esi
f0108a9e:	5f                   	pop    %edi
f0108a9f:	5d                   	pop    %ebp
f0108aa0:	c3                   	ret    
f0108aa1:	8d 76 00             	lea    0x0(%esi),%esi
f0108aa4:	39 f5                	cmp    %esi,%ebp
f0108aa6:	72 04                	jb     f0108aac <__umoddi3+0x104>
f0108aa8:	39 f9                	cmp    %edi,%ecx
f0108aaa:	77 06                	ja     f0108ab2 <__umoddi3+0x10a>
f0108aac:	89 f2                	mov    %esi,%edx
f0108aae:	29 cf                	sub    %ecx,%edi
f0108ab0:	19 ea                	sbb    %ebp,%edx
f0108ab2:	89 f8                	mov    %edi,%eax
f0108ab4:	83 c4 20             	add    $0x20,%esp
f0108ab7:	5e                   	pop    %esi
f0108ab8:	5f                   	pop    %edi
f0108ab9:	5d                   	pop    %ebp
f0108aba:	c3                   	ret    
f0108abb:	90                   	nop
f0108abc:	89 d1                	mov    %edx,%ecx
f0108abe:	89 c5                	mov    %eax,%ebp
f0108ac0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0108ac4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0108ac8:	eb 8d                	jmp    f0108a57 <__umoddi3+0xaf>
f0108aca:	66 90                	xchg   %ax,%ax
f0108acc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0108ad0:	72 ea                	jb     f0108abc <__umoddi3+0x114>
f0108ad2:	89 f1                	mov    %esi,%ecx
f0108ad4:	eb 81                	jmp    f0108a57 <__umoddi3+0xaf>
