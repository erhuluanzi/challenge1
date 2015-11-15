
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
f0100015:	b8 00 80 12 00       	mov    $0x128000,%eax
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
f0100034:	bc 00 80 12 f0       	mov    $0xf0128000,%esp

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
f010004b:	83 3d 80 2e 33 f0 00 	cmpl   $0x0,0xf0332e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 2e 33 f0    	mov    %esi,0xf0332e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 c0 66 00 00       	call   f0106724 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 00 6e 10 f0 	movl   $0xf0106e00,(%esp)
f010007d:	e8 20 41 00 00       	call   f01041a2 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 e1 40 00 00       	call   f010416f <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 75 82 10 f0 	movl   $0xf0108275,(%esp)
f0100095:	e8 08 41 00 00       	call   f01041a2 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 38 0b 00 00       	call   f0100bde <monitor>
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
f01000ae:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 24 6e 10 	movl   $0xf0106e24,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 6b 6e 10 f0 	movl   $0xf0106e6b,(%esp)
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
f01000e2:	e8 3d 66 00 00       	call   f0106724 <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 77 6e 10 f0 	movl   $0xf0106e77,(%esp)
f01000f2:	e8 ab 40 00 00       	call   f01041a2 <cprintf>

	lapic_init();
f01000f7:	e8 43 66 00 00       	call   f010673f <lapic_init>
	env_init_percpu();
f01000fc:	e8 cf 37 00 00       	call   f01038d0 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 b6 40 00 00       	call   f01041bc <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 19 66 00 00       	call   f0106724 <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 30 33 f0    	add    $0xf0333020,%edx
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
f010011d:	c7 04 24 60 a4 12 f0 	movl   $0xf012a460,(%esp)
f0100124:	e8 ba 68 00 00       	call   f01069e3 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100129:	e8 b3 4a 00 00       	call   f0104be1 <sched_yield>

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
f0100135:	b8 08 40 37 f0       	mov    $0xf0374008,%eax
f010013a:	2d b5 17 33 f0       	sub    $0xf03317b5,%eax
f010013f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010014a:	00 
f010014b:	c7 04 24 b5 17 33 f0 	movl   $0xf03317b5,(%esp)
f0100152:	e8 9f 5f 00 00       	call   f01060f6 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100157:	e8 1b 05 00 00       	call   f0100677 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010015c:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100163:	00 
f0100164:	c7 04 24 8d 6e 10 f0 	movl   $0xf0106e8d,(%esp)
f010016b:	e8 32 40 00 00       	call   f01041a2 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100170:	e8 de 14 00 00       	call   f0101653 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100175:	e8 80 37 00 00       	call   f01038fa <env_init>
	trap_init();
f010017a:	e8 3a 41 00 00       	call   f01042b9 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010017f:	e8 b8 62 00 00       	call   f010643c <mp_init>
	lapic_init();
f0100184:	e8 b6 65 00 00       	call   f010673f <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100189:	e8 6a 3f 00 00       	call   f01040f8 <pic_init>
f010018e:	c7 04 24 60 a4 12 f0 	movl   $0xf012a460,(%esp)
f0100195:	e8 49 68 00 00       	call   f01069e3 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010019a:	83 3d 88 2e 33 f0 07 	cmpl   $0x7,0xf0332e88
f01001a1:	77 24                	ja     f01001c7 <i386_init+0x99>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001a3:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001aa:	00 
f01001ab:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f01001b2:	f0 
f01001b3:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01001ba:	00 
f01001bb:	c7 04 24 6b 6e 10 f0 	movl   $0xf0106e6b,(%esp)
f01001c2:	e8 79 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001c7:	b8 66 63 10 f0       	mov    $0xf0106366,%eax
f01001cc:	2d ec 62 10 f0       	sub    $0xf01062ec,%eax
f01001d1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001d5:	c7 44 24 04 ec 62 10 	movl   $0xf01062ec,0x4(%esp)
f01001dc:	f0 
f01001dd:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001e4:	e8 57 5f 00 00       	call   f0106140 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001e9:	bb 20 30 33 f0       	mov    $0xf0333020,%ebx
f01001ee:	eb 6f                	jmp    f010025f <i386_init+0x131>
		if (c == cpus + cpunum())  // We've started already.
f01001f0:	e8 2f 65 00 00       	call   f0106724 <cpunum>
f01001f5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01001fc:	29 c2                	sub    %eax,%edx
f01001fe:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100201:	8d 04 85 20 30 33 f0 	lea    -0xfcccfe0(,%eax,4),%eax
f0100208:	39 c3                	cmp    %eax,%ebx
f010020a:	74 50                	je     f010025c <i386_init+0x12e>

static void boot_aps(void);


void
i386_init(void)
f010020c:	89 d8                	mov    %ebx,%eax
f010020e:	2d 20 30 33 f0       	sub    $0xf0333020,%eax
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
f0100237:	05 00 40 33 f0       	add    $0xf0334000,%eax
f010023c:	a3 84 2e 33 f0       	mov    %eax,0xf0332e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100241:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100248:	00 
f0100249:	0f b6 03             	movzbl (%ebx),%eax
f010024c:	89 04 24             	mov    %eax,(%esp)
f010024f:	e8 44 66 00 00       	call   f0106898 <lapic_startap>
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
f010025f:	a1 c4 33 33 f0       	mov    0xf03333c4,%eax
f0100264:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010026b:	29 c2                	sub    %eax,%edx
f010026d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100270:	8d 04 85 20 30 33 f0 	lea    -0xfcccfe0(,%eax,4),%eax
f0100277:	39 c3                	cmp    %eax,%ebx
f0100279:	0f 82 71 ff ff ff    	jb     f01001f0 <i386_init+0xc2>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010027f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100286:	00 
f0100287:	c7 04 24 de fc 31 f0 	movl   $0xf031fcde,(%esp)
f010028e:	e8 88 38 00 00       	call   f0103b1b <env_create>
	ENV_CREATE(user_fairness, ENV_TYPE_USER);
	ENV_CREATE(user_fairness, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f0100293:	e8 49 49 00 00       	call   f0104be1 <sched_yield>

f0100298 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100298:	55                   	push   %ebp
f0100299:	89 e5                	mov    %esp,%ebp
f010029b:	53                   	push   %ebx
f010029c:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010029f:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002a2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01002a5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01002a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01002ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01002b0:	c7 04 24 a8 6e 10 f0 	movl   $0xf0106ea8,(%esp)
f01002b7:	e8 e6 3e 00 00       	call   f01041a2 <cprintf>
	vcprintf(fmt, ap);
f01002bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002c0:	8b 45 10             	mov    0x10(%ebp),%eax
f01002c3:	89 04 24             	mov    %eax,(%esp)
f01002c6:	e8 a4 3e 00 00       	call   f010416f <vcprintf>
	cprintf("\n");
f01002cb:	c7 04 24 75 82 10 f0 	movl   $0xf0108275,(%esp)
f01002d2:	e8 cb 3e 00 00       	call   f01041a2 <cprintf>
	va_end(ap);
}
f01002d7:	83 c4 14             	add    $0x14,%esp
f01002da:	5b                   	pop    %ebx
f01002db:	5d                   	pop    %ebp
f01002dc:	c3                   	ret    
f01002dd:	00 00                	add    %al,(%eax)
	...

f01002e0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002e0:	55                   	push   %ebp
f01002e1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002e3:	ba 84 00 00 00       	mov    $0x84,%edx
f01002e8:	ec                   	in     (%dx),%al
f01002e9:	ec                   	in     (%dx),%al
f01002ea:	ec                   	in     (%dx),%al
f01002eb:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002ec:	5d                   	pop    %ebp
f01002ed:	c3                   	ret    

f01002ee <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002ee:	55                   	push   %ebp
f01002ef:	89 e5                	mov    %esp,%ebp
f01002f1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002f6:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002f7:	a8 01                	test   $0x1,%al
f01002f9:	74 08                	je     f0100303 <serial_proc_data+0x15>
f01002fb:	b2 f8                	mov    $0xf8,%dl
f01002fd:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002fe:	0f b6 c0             	movzbl %al,%eax
f0100301:	eb 05                	jmp    f0100308 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100303:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100308:	5d                   	pop    %ebp
f0100309:	c3                   	ret    

f010030a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010030a:	55                   	push   %ebp
f010030b:	89 e5                	mov    %esp,%ebp
f010030d:	53                   	push   %ebx
f010030e:	83 ec 04             	sub    $0x4,%esp
f0100311:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100313:	eb 29                	jmp    f010033e <cons_intr+0x34>
		if (c == 0)
f0100315:	85 c0                	test   %eax,%eax
f0100317:	74 25                	je     f010033e <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f0100319:	8b 15 24 22 33 f0    	mov    0xf0332224,%edx
f010031f:	88 82 20 20 33 f0    	mov    %al,-0xfccdfe0(%edx)
f0100325:	8d 42 01             	lea    0x1(%edx),%eax
f0100328:	a3 24 22 33 f0       	mov    %eax,0xf0332224
		if (cons.wpos == CONSBUFSIZE)
f010032d:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100332:	75 0a                	jne    f010033e <cons_intr+0x34>
			cons.wpos = 0;
f0100334:	c7 05 24 22 33 f0 00 	movl   $0x0,0xf0332224
f010033b:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010033e:	ff d3                	call   *%ebx
f0100340:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100343:	75 d0                	jne    f0100315 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100345:	83 c4 04             	add    $0x4,%esp
f0100348:	5b                   	pop    %ebx
f0100349:	5d                   	pop    %ebp
f010034a:	c3                   	ret    

f010034b <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010034b:	55                   	push   %ebp
f010034c:	89 e5                	mov    %esp,%ebp
f010034e:	57                   	push   %edi
f010034f:	56                   	push   %esi
f0100350:	53                   	push   %ebx
f0100351:	83 ec 2c             	sub    $0x2c,%esp
f0100354:	89 c6                	mov    %eax,%esi
f0100356:	bb 01 32 00 00       	mov    $0x3201,%ebx
f010035b:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100360:	eb 05                	jmp    f0100367 <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100362:	e8 79 ff ff ff       	call   f01002e0 <delay>
f0100367:	89 fa                	mov    %edi,%edx
f0100369:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010036a:	a8 20                	test   $0x20,%al
f010036c:	75 03                	jne    f0100371 <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010036e:	4b                   	dec    %ebx
f010036f:	75 f1                	jne    f0100362 <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100371:	89 f2                	mov    %esi,%edx
f0100373:	89 f0                	mov    %esi,%eax
f0100375:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100378:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010037d:	ee                   	out    %al,(%dx)
f010037e:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100383:	bf 79 03 00 00       	mov    $0x379,%edi
f0100388:	eb 05                	jmp    f010038f <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f010038a:	e8 51 ff ff ff       	call   f01002e0 <delay>
f010038f:	89 fa                	mov    %edi,%edx
f0100391:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100392:	84 c0                	test   %al,%al
f0100394:	78 03                	js     f0100399 <cons_putc+0x4e>
f0100396:	4b                   	dec    %ebx
f0100397:	75 f1                	jne    f010038a <cons_putc+0x3f>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100399:	ba 78 03 00 00       	mov    $0x378,%edx
f010039e:	8a 45 e7             	mov    -0x19(%ebp),%al
f01003a1:	ee                   	out    %al,(%dx)
f01003a2:	b2 7a                	mov    $0x7a,%dl
f01003a4:	b0 0d                	mov    $0xd,%al
f01003a6:	ee                   	out    %al,(%dx)
f01003a7:	b0 08                	mov    $0x8,%al
f01003a9:	ee                   	out    %al,(%dx)
extern unsigned int console_color;
static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01003aa:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f01003b0:	75 0a                	jne    f01003bc <cons_putc+0x71>
		c |= console_color << 8;
f01003b2:	a1 48 a4 12 f0       	mov    0xf012a448,%eax
f01003b7:	c1 e0 08             	shl    $0x8,%eax
f01003ba:	09 c6                	or     %eax,%esi

	switch (c & 0xff) {
f01003bc:	89 f0                	mov    %esi,%eax
f01003be:	25 ff 00 00 00       	and    $0xff,%eax
f01003c3:	83 f8 09             	cmp    $0x9,%eax
f01003c6:	74 78                	je     f0100440 <cons_putc+0xf5>
f01003c8:	83 f8 09             	cmp    $0x9,%eax
f01003cb:	7f 0b                	jg     f01003d8 <cons_putc+0x8d>
f01003cd:	83 f8 08             	cmp    $0x8,%eax
f01003d0:	0f 85 9e 00 00 00    	jne    f0100474 <cons_putc+0x129>
f01003d6:	eb 10                	jmp    f01003e8 <cons_putc+0x9d>
f01003d8:	83 f8 0a             	cmp    $0xa,%eax
f01003db:	74 39                	je     f0100416 <cons_putc+0xcb>
f01003dd:	83 f8 0d             	cmp    $0xd,%eax
f01003e0:	0f 85 8e 00 00 00    	jne    f0100474 <cons_putc+0x129>
f01003e6:	eb 36                	jmp    f010041e <cons_putc+0xd3>
	case '\b':
		if (crt_pos > 0) {
f01003e8:	66 a1 34 22 33 f0    	mov    0xf0332234,%ax
f01003ee:	66 85 c0             	test   %ax,%ax
f01003f1:	0f 84 e2 00 00 00    	je     f01004d9 <cons_putc+0x18e>
			crt_pos--;
f01003f7:	48                   	dec    %eax
f01003f8:	66 a3 34 22 33 f0    	mov    %ax,0xf0332234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003fe:	0f b7 c0             	movzwl %ax,%eax
f0100401:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100407:	83 ce 20             	or     $0x20,%esi
f010040a:	8b 15 30 22 33 f0    	mov    0xf0332230,%edx
f0100410:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100414:	eb 78                	jmp    f010048e <cons_putc+0x143>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100416:	66 83 05 34 22 33 f0 	addw   $0x50,0xf0332234
f010041d:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010041e:	66 8b 0d 34 22 33 f0 	mov    0xf0332234,%cx
f0100425:	bb 50 00 00 00       	mov    $0x50,%ebx
f010042a:	89 c8                	mov    %ecx,%eax
f010042c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100431:	66 f7 f3             	div    %bx
f0100434:	66 29 d1             	sub    %dx,%cx
f0100437:	66 89 0d 34 22 33 f0 	mov    %cx,0xf0332234
f010043e:	eb 4e                	jmp    f010048e <cons_putc+0x143>
		break;
	case '\t':
		cons_putc(' ');
f0100440:	b8 20 00 00 00       	mov    $0x20,%eax
f0100445:	e8 01 ff ff ff       	call   f010034b <cons_putc>
		cons_putc(' ');
f010044a:	b8 20 00 00 00       	mov    $0x20,%eax
f010044f:	e8 f7 fe ff ff       	call   f010034b <cons_putc>
		cons_putc(' ');
f0100454:	b8 20 00 00 00       	mov    $0x20,%eax
f0100459:	e8 ed fe ff ff       	call   f010034b <cons_putc>
		cons_putc(' ');
f010045e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100463:	e8 e3 fe ff ff       	call   f010034b <cons_putc>
		cons_putc(' ');
f0100468:	b8 20 00 00 00       	mov    $0x20,%eax
f010046d:	e8 d9 fe ff ff       	call   f010034b <cons_putc>
f0100472:	eb 1a                	jmp    f010048e <cons_putc+0x143>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100474:	66 a1 34 22 33 f0    	mov    0xf0332234,%ax
f010047a:	0f b7 c8             	movzwl %ax,%ecx
f010047d:	8b 15 30 22 33 f0    	mov    0xf0332230,%edx
f0100483:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f0100487:	40                   	inc    %eax
f0100488:	66 a3 34 22 33 f0    	mov    %ax,0xf0332234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010048e:	66 81 3d 34 22 33 f0 	cmpw   $0x7cf,0xf0332234
f0100495:	cf 07 
f0100497:	76 40                	jbe    f01004d9 <cons_putc+0x18e>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100499:	a1 30 22 33 f0       	mov    0xf0332230,%eax
f010049e:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01004a5:	00 
f01004a6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004ac:	89 54 24 04          	mov    %edx,0x4(%esp)
f01004b0:	89 04 24             	mov    %eax,(%esp)
f01004b3:	e8 88 5c 00 00       	call   f0106140 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004b8:	8b 15 30 22 33 f0    	mov    0xf0332230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004be:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004c3:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004c9:	40                   	inc    %eax
f01004ca:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004cf:	75 f2                	jne    f01004c3 <cons_putc+0x178>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004d1:	66 83 2d 34 22 33 f0 	subw   $0x50,0xf0332234
f01004d8:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004d9:	8b 0d 2c 22 33 f0    	mov    0xf033222c,%ecx
f01004df:	b0 0e                	mov    $0xe,%al
f01004e1:	89 ca                	mov    %ecx,%edx
f01004e3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004e4:	66 8b 35 34 22 33 f0 	mov    0xf0332234,%si
f01004eb:	8d 59 01             	lea    0x1(%ecx),%ebx
f01004ee:	89 f0                	mov    %esi,%eax
f01004f0:	66 c1 e8 08          	shr    $0x8,%ax
f01004f4:	89 da                	mov    %ebx,%edx
f01004f6:	ee                   	out    %al,(%dx)
f01004f7:	b0 0f                	mov    $0xf,%al
f01004f9:	89 ca                	mov    %ecx,%edx
f01004fb:	ee                   	out    %al,(%dx)
f01004fc:	89 f0                	mov    %esi,%eax
f01004fe:	89 da                	mov    %ebx,%edx
f0100500:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100501:	83 c4 2c             	add    $0x2c,%esp
f0100504:	5b                   	pop    %ebx
f0100505:	5e                   	pop    %esi
f0100506:	5f                   	pop    %edi
f0100507:	5d                   	pop    %ebp
f0100508:	c3                   	ret    

f0100509 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100509:	55                   	push   %ebp
f010050a:	89 e5                	mov    %esp,%ebp
f010050c:	53                   	push   %ebx
f010050d:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100510:	ba 64 00 00 00       	mov    $0x64,%edx
f0100515:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100516:	a8 01                	test   $0x1,%al
f0100518:	0f 84 d8 00 00 00    	je     f01005f6 <kbd_proc_data+0xed>
f010051e:	b2 60                	mov    $0x60,%dl
f0100520:	ec                   	in     (%dx),%al
f0100521:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100523:	3c e0                	cmp    $0xe0,%al
f0100525:	75 11                	jne    f0100538 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f0100527:	83 0d 28 22 33 f0 40 	orl    $0x40,0xf0332228
		return 0;
f010052e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100533:	e9 c3 00 00 00       	jmp    f01005fb <kbd_proc_data+0xf2>
	} else if (data & 0x80) {
f0100538:	84 c0                	test   %al,%al
f010053a:	79 33                	jns    f010056f <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010053c:	8b 0d 28 22 33 f0    	mov    0xf0332228,%ecx
f0100542:	f6 c1 40             	test   $0x40,%cl
f0100545:	75 05                	jne    f010054c <kbd_proc_data+0x43>
f0100547:	88 c2                	mov    %al,%dl
f0100549:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010054c:	0f b6 d2             	movzbl %dl,%edx
f010054f:	8a 82 00 6f 10 f0    	mov    -0xfef9100(%edx),%al
f0100555:	83 c8 40             	or     $0x40,%eax
f0100558:	0f b6 c0             	movzbl %al,%eax
f010055b:	f7 d0                	not    %eax
f010055d:	21 c1                	and    %eax,%ecx
f010055f:	89 0d 28 22 33 f0    	mov    %ecx,0xf0332228
		return 0;
f0100565:	bb 00 00 00 00       	mov    $0x0,%ebx
f010056a:	e9 8c 00 00 00       	jmp    f01005fb <kbd_proc_data+0xf2>
	} else if (shift & E0ESC) {
f010056f:	8b 0d 28 22 33 f0    	mov    0xf0332228,%ecx
f0100575:	f6 c1 40             	test   $0x40,%cl
f0100578:	74 0e                	je     f0100588 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010057a:	88 c2                	mov    %al,%dl
f010057c:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010057f:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100582:	89 0d 28 22 33 f0    	mov    %ecx,0xf0332228
	}

	shift |= shiftcode[data];
f0100588:	0f b6 d2             	movzbl %dl,%edx
f010058b:	0f b6 82 00 6f 10 f0 	movzbl -0xfef9100(%edx),%eax
f0100592:	0b 05 28 22 33 f0    	or     0xf0332228,%eax
	shift ^= togglecode[data];
f0100598:	0f b6 8a 00 70 10 f0 	movzbl -0xfef9000(%edx),%ecx
f010059f:	31 c8                	xor    %ecx,%eax
f01005a1:	a3 28 22 33 f0       	mov    %eax,0xf0332228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005a6:	89 c1                	mov    %eax,%ecx
f01005a8:	83 e1 03             	and    $0x3,%ecx
f01005ab:	8b 0c 8d 00 71 10 f0 	mov    -0xfef8f00(,%ecx,4),%ecx
f01005b2:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01005b6:	a8 08                	test   $0x8,%al
f01005b8:	74 18                	je     f01005d2 <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f01005ba:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01005bd:	83 fa 19             	cmp    $0x19,%edx
f01005c0:	77 05                	ja     f01005c7 <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f01005c2:	83 eb 20             	sub    $0x20,%ebx
f01005c5:	eb 0b                	jmp    f01005d2 <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f01005c7:	8d 53 bf             	lea    -0x41(%ebx),%edx
f01005ca:	83 fa 19             	cmp    $0x19,%edx
f01005cd:	77 03                	ja     f01005d2 <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f01005cf:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005d2:	f7 d0                	not    %eax
f01005d4:	a8 06                	test   $0x6,%al
f01005d6:	75 23                	jne    f01005fb <kbd_proc_data+0xf2>
f01005d8:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01005de:	75 1b                	jne    f01005fb <kbd_proc_data+0xf2>
		cprintf("Rebooting!\n");
f01005e0:	c7 04 24 c2 6e 10 f0 	movl   $0xf0106ec2,(%esp)
f01005e7:	e8 b6 3b 00 00       	call   f01041a2 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005ec:	ba 92 00 00 00       	mov    $0x92,%edx
f01005f1:	b0 03                	mov    $0x3,%al
f01005f3:	ee                   	out    %al,(%dx)
f01005f4:	eb 05                	jmp    f01005fb <kbd_proc_data+0xf2>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01005f6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01005fb:	89 d8                	mov    %ebx,%eax
f01005fd:	83 c4 14             	add    $0x14,%esp
f0100600:	5b                   	pop    %ebx
f0100601:	5d                   	pop    %ebp
f0100602:	c3                   	ret    

f0100603 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100603:	55                   	push   %ebp
f0100604:	89 e5                	mov    %esp,%ebp
f0100606:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100609:	80 3d 00 20 33 f0 00 	cmpb   $0x0,0xf0332000
f0100610:	74 0a                	je     f010061c <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100612:	b8 ee 02 10 f0       	mov    $0xf01002ee,%eax
f0100617:	e8 ee fc ff ff       	call   f010030a <cons_intr>
}
f010061c:	c9                   	leave  
f010061d:	c3                   	ret    

f010061e <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010061e:	55                   	push   %ebp
f010061f:	89 e5                	mov    %esp,%ebp
f0100621:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100624:	b8 09 05 10 f0       	mov    $0xf0100509,%eax
f0100629:	e8 dc fc ff ff       	call   f010030a <cons_intr>
}
f010062e:	c9                   	leave  
f010062f:	c3                   	ret    

f0100630 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100630:	55                   	push   %ebp
f0100631:	89 e5                	mov    %esp,%ebp
f0100633:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100636:	e8 c8 ff ff ff       	call   f0100603 <serial_intr>
	kbd_intr();
f010063b:	e8 de ff ff ff       	call   f010061e <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100640:	8b 15 20 22 33 f0    	mov    0xf0332220,%edx
f0100646:	3b 15 24 22 33 f0    	cmp    0xf0332224,%edx
f010064c:	74 22                	je     f0100670 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f010064e:	0f b6 82 20 20 33 f0 	movzbl -0xfccdfe0(%edx),%eax
f0100655:	42                   	inc    %edx
f0100656:	89 15 20 22 33 f0    	mov    %edx,0xf0332220
		if (cons.rpos == CONSBUFSIZE)
f010065c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100662:	75 11                	jne    f0100675 <cons_getc+0x45>
			cons.rpos = 0;
f0100664:	c7 05 20 22 33 f0 00 	movl   $0x0,0xf0332220
f010066b:	00 00 00 
f010066e:	eb 05                	jmp    f0100675 <cons_getc+0x45>
		return c;
	}
	return 0;
f0100670:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100675:	c9                   	leave  
f0100676:	c3                   	ret    

f0100677 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100677:	55                   	push   %ebp
f0100678:	89 e5                	mov    %esp,%ebp
f010067a:	57                   	push   %edi
f010067b:	56                   	push   %esi
f010067c:	53                   	push   %ebx
f010067d:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100680:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100687:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010068e:	5a a5 
	if (*cp != 0xA55A) {
f0100690:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100696:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010069a:	74 11                	je     f01006ad <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010069c:	c7 05 2c 22 33 f0 b4 	movl   $0x3b4,0xf033222c
f01006a3:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006a6:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006ab:	eb 16                	jmp    f01006c3 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006ad:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006b4:	c7 05 2c 22 33 f0 d4 	movl   $0x3d4,0xf033222c
f01006bb:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006be:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006c3:	8b 0d 2c 22 33 f0    	mov    0xf033222c,%ecx
f01006c9:	b0 0e                	mov    $0xe,%al
f01006cb:	89 ca                	mov    %ecx,%edx
f01006cd:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006ce:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d1:	89 da                	mov    %ebx,%edx
f01006d3:	ec                   	in     (%dx),%al
f01006d4:	0f b6 f8             	movzbl %al,%edi
f01006d7:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006da:	b0 0f                	mov    $0xf,%al
f01006dc:	89 ca                	mov    %ecx,%edx
f01006de:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006df:	89 da                	mov    %ebx,%edx
f01006e1:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006e2:	89 35 30 22 33 f0    	mov    %esi,0xf0332230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006e8:	0f b6 d8             	movzbl %al,%ebx
f01006eb:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006ed:	66 89 3d 34 22 33 f0 	mov    %di,0xf0332234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006f4:	e8 25 ff ff ff       	call   f010061e <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006f9:	0f b7 05 a8 a3 12 f0 	movzwl 0xf012a3a8,%eax
f0100700:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100705:	89 04 24             	mov    %eax,(%esp)
f0100708:	e8 77 39 00 00       	call   f0104084 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010070d:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100712:	b0 00                	mov    $0x0,%al
f0100714:	89 da                	mov    %ebx,%edx
f0100716:	ee                   	out    %al,(%dx)
f0100717:	b2 fb                	mov    $0xfb,%dl
f0100719:	b0 80                	mov    $0x80,%al
f010071b:	ee                   	out    %al,(%dx)
f010071c:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100721:	b0 0c                	mov    $0xc,%al
f0100723:	89 ca                	mov    %ecx,%edx
f0100725:	ee                   	out    %al,(%dx)
f0100726:	b2 f9                	mov    $0xf9,%dl
f0100728:	b0 00                	mov    $0x0,%al
f010072a:	ee                   	out    %al,(%dx)
f010072b:	b2 fb                	mov    $0xfb,%dl
f010072d:	b0 03                	mov    $0x3,%al
f010072f:	ee                   	out    %al,(%dx)
f0100730:	b2 fc                	mov    $0xfc,%dl
f0100732:	b0 00                	mov    $0x0,%al
f0100734:	ee                   	out    %al,(%dx)
f0100735:	b2 f9                	mov    $0xf9,%dl
f0100737:	b0 01                	mov    $0x1,%al
f0100739:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010073a:	b2 fd                	mov    $0xfd,%dl
f010073c:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010073d:	3c ff                	cmp    $0xff,%al
f010073f:	0f 95 45 e7          	setne  -0x19(%ebp)
f0100743:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100746:	a2 00 20 33 f0       	mov    %al,0xf0332000
f010074b:	89 da                	mov    %ebx,%edx
f010074d:	ec                   	in     (%dx),%al
f010074e:	89 ca                	mov    %ecx,%edx
f0100750:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100751:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f0100755:	75 0c                	jne    f0100763 <cons_init+0xec>
		cprintf("Serial port does not exist!\n");
f0100757:	c7 04 24 ce 6e 10 f0 	movl   $0xf0106ece,(%esp)
f010075e:	e8 3f 3a 00 00       	call   f01041a2 <cprintf>
}
f0100763:	83 c4 2c             	add    $0x2c,%esp
f0100766:	5b                   	pop    %ebx
f0100767:	5e                   	pop    %esi
f0100768:	5f                   	pop    %edi
f0100769:	5d                   	pop    %ebp
f010076a:	c3                   	ret    

f010076b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010076b:	55                   	push   %ebp
f010076c:	89 e5                	mov    %esp,%ebp
f010076e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100771:	8b 45 08             	mov    0x8(%ebp),%eax
f0100774:	e8 d2 fb ff ff       	call   f010034b <cons_putc>
}
f0100779:	c9                   	leave  
f010077a:	c3                   	ret    

f010077b <getchar>:

int
getchar(void)
{
f010077b:	55                   	push   %ebp
f010077c:	89 e5                	mov    %esp,%ebp
f010077e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100781:	e8 aa fe ff ff       	call   f0100630 <cons_getc>
f0100786:	85 c0                	test   %eax,%eax
f0100788:	74 f7                	je     f0100781 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010078a:	c9                   	leave  
f010078b:	c3                   	ret    

f010078c <iscons>:

int
iscons(int fdnum)
{
f010078c:	55                   	push   %ebp
f010078d:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010078f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100794:	5d                   	pop    %ebp
f0100795:	c3                   	ret    
	...

f0100798 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100798:	55                   	push   %ebp
f0100799:	89 e5                	mov    %esp,%ebp
f010079b:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010079e:	c7 04 24 10 71 10 f0 	movl   $0xf0107110,(%esp)
f01007a5:	e8 f8 39 00 00       	call   f01041a2 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007aa:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01007b1:	00 
f01007b2:	c7 04 24 6c 72 10 f0 	movl   $0xf010726c,(%esp)
f01007b9:	e8 e4 39 00 00       	call   f01041a2 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007be:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01007c5:	00 
f01007c6:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01007cd:	f0 
f01007ce:	c7 04 24 94 72 10 f0 	movl   $0xf0107294,(%esp)
f01007d5:	e8 c8 39 00 00       	call   f01041a2 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007da:	c7 44 24 08 e2 6d 10 	movl   $0x106de2,0x8(%esp)
f01007e1:	00 
f01007e2:	c7 44 24 04 e2 6d 10 	movl   $0xf0106de2,0x4(%esp)
f01007e9:	f0 
f01007ea:	c7 04 24 b8 72 10 f0 	movl   $0xf01072b8,(%esp)
f01007f1:	e8 ac 39 00 00       	call   f01041a2 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007f6:	c7 44 24 08 b5 17 33 	movl   $0x3317b5,0x8(%esp)
f01007fd:	00 
f01007fe:	c7 44 24 04 b5 17 33 	movl   $0xf03317b5,0x4(%esp)
f0100805:	f0 
f0100806:	c7 04 24 dc 72 10 f0 	movl   $0xf01072dc,(%esp)
f010080d:	e8 90 39 00 00       	call   f01041a2 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100812:	c7 44 24 08 08 40 37 	movl   $0x374008,0x8(%esp)
f0100819:	00 
f010081a:	c7 44 24 04 08 40 37 	movl   $0xf0374008,0x4(%esp)
f0100821:	f0 
f0100822:	c7 04 24 00 73 10 f0 	movl   $0xf0107300,(%esp)
f0100829:	e8 74 39 00 00       	call   f01041a2 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010082e:	b8 07 44 37 f0       	mov    $0xf0374407,%eax
f0100833:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100838:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010083d:	89 c2                	mov    %eax,%edx
f010083f:	85 c0                	test   %eax,%eax
f0100841:	79 06                	jns    f0100849 <mon_kerninfo+0xb1>
f0100843:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100849:	c1 fa 0a             	sar    $0xa,%edx
f010084c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100850:	c7 04 24 24 73 10 f0 	movl   $0xf0107324,(%esp)
f0100857:	e8 46 39 00 00       	call   f01041a2 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010085c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100861:	c9                   	leave  
f0100862:	c3                   	ret    

f0100863 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100863:	55                   	push   %ebp
f0100864:	89 e5                	mov    %esp,%ebp
f0100866:	53                   	push   %ebx
f0100867:	83 ec 14             	sub    $0x14,%esp
f010086a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010086f:	8b 83 c4 75 10 f0    	mov    -0xfef8a3c(%ebx),%eax
f0100875:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100879:	8b 83 c0 75 10 f0    	mov    -0xfef8a40(%ebx),%eax
f010087f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100883:	c7 04 24 29 71 10 f0 	movl   $0xf0107129,(%esp)
f010088a:	e8 13 39 00 00       	call   f01041a2 <cprintf>
f010088f:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100892:	83 fb 3c             	cmp    $0x3c,%ebx
f0100895:	75 d8                	jne    f010086f <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100897:	b8 00 00 00 00       	mov    $0x0,%eax
f010089c:	83 c4 14             	add    $0x14,%esp
f010089f:	5b                   	pop    %ebx
f01008a0:	5d                   	pop    %ebp
f01008a1:	c3                   	ret    

f01008a2 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008a2:	55                   	push   %ebp
f01008a3:	89 e5                	mov    %esp,%ebp
f01008a5:	57                   	push   %edi
f01008a6:	56                   	push   %esi
f01008a7:	53                   	push   %ebx
f01008a8:	83 ec 4c             	sub    $0x4c,%esp
	// Your code here.
	unsigned int *ebp = (unsigned int*) read_ebp();
f01008ab:	89 ee                	mov    %ebp,%esi
	int i;
	cprintf("Stack backtrace:\n");
f01008ad:	c7 04 24 32 71 10 f0 	movl   $0xf0107132,(%esp)
f01008b4:	e8 e9 38 00 00       	call   f01041a2 <cprintf>
	while (ebp != 0) {
f01008b9:	e9 a2 00 00 00       	jmp    f0100960 <mon_backtrace+0xbe>
		unsigned int eip = *(ebp + 1);
f01008be:	8b 7e 04             	mov    0x4(%esi),%edi
		cprintf("  %rebp %08x  %reip %08x  %rargs", 0x0c, ebp, 0x0a, eip, 0x09);
f01008c1:	c7 44 24 14 09 00 00 	movl   $0x9,0x14(%esp)
f01008c8:	00 
f01008c9:	89 7c 24 10          	mov    %edi,0x10(%esp)
f01008cd:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
f01008d4:	00 
f01008d5:	89 74 24 08          	mov    %esi,0x8(%esp)
f01008d9:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
f01008e0:	00 
f01008e1:	c7 04 24 50 73 10 f0 	movl   $0xf0107350,(%esp)
f01008e8:	e8 b5 38 00 00       	call   f01041a2 <cprintf>
		for (i = 0; i < 5; i++) {
f01008ed:	bb 00 00 00 00       	mov    $0x0,%ebx
			cprintf(" %08x", *(ebp + i + 2));
f01008f2:	8b 44 9e 08          	mov    0x8(%esi,%ebx,4),%eax
f01008f6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008fa:	c7 04 24 44 71 10 f0 	movl   $0xf0107144,(%esp)
f0100901:	e8 9c 38 00 00       	call   f01041a2 <cprintf>
	int i;
	cprintf("Stack backtrace:\n");
	while (ebp != 0) {
		unsigned int eip = *(ebp + 1);
		cprintf("  %rebp %08x  %reip %08x  %rargs", 0x0c, ebp, 0x0a, eip, 0x09);
		for (i = 0; i < 5; i++) {
f0100906:	43                   	inc    %ebx
f0100907:	83 fb 05             	cmp    $0x5,%ebx
f010090a:	75 e6                	jne    f01008f2 <mon_backtrace+0x50>
			cprintf(" %08x", *(ebp + i + 2));
		}
		cprintf("%r\n", 0x07);
f010090c:	c7 44 24 04 07 00 00 	movl   $0x7,0x4(%esp)
f0100913:	00 
f0100914:	c7 04 24 4a 71 10 f0 	movl   $0xf010714a,(%esp)
f010091b:	e8 82 38 00 00       	call   f01041a2 <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
f0100920:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100923:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100927:	89 3c 24             	mov    %edi,(%esp)
f010092a:	e8 fe 4c 00 00       	call   f010562d <debuginfo_eip>
		cprintf("         %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
f010092f:	2b 7d e0             	sub    -0x20(%ebp),%edi
f0100932:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0100936:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100939:	89 44 24 10          	mov    %eax,0x10(%esp)
f010093d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100940:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100944:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100947:	89 44 24 08          	mov    %eax,0x8(%esp)
f010094b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010094e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100952:	c7 04 24 4e 71 10 f0 	movl   $0xf010714e,(%esp)
f0100959:	e8 44 38 00 00       	call   f01041a2 <cprintf>
		ebp = (unsigned int*)*ebp;
f010095e:	8b 36                	mov    (%esi),%esi
{
	// Your code here.
	unsigned int *ebp = (unsigned int*) read_ebp();
	int i;
	cprintf("Stack backtrace:\n");
	while (ebp != 0) {
f0100960:	85 f6                	test   %esi,%esi
f0100962:	0f 85 56 ff ff ff    	jne    f01008be <mon_backtrace+0x1c>
		debuginfo_eip(eip, &info);
		cprintf("         %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
		ebp = (unsigned int*)*ebp;
	}
	return 0;
}
f0100968:	b8 00 00 00 00       	mov    $0x0,%eax
f010096d:	83 c4 4c             	add    $0x4c,%esp
f0100970:	5b                   	pop    %ebx
f0100971:	5e                   	pop    %esi
f0100972:	5f                   	pop    %edi
f0100973:	5d                   	pop    %ebp
f0100974:	c3                   	ret    

f0100975 <xtoi>:

uint32_t xtoi(char *s) {
f0100975:	55                   	push   %ebp
f0100976:	89 e5                	mov    %esp,%ebp
f0100978:	56                   	push   %esi
f0100979:	53                   	push   %ebx
f010097a:	83 ec 10             	sub    $0x10,%esp
f010097d:	8b 75 08             	mov    0x8(%ebp),%esi
	uint32_t result = 0;
f0100980:	89 f1                	mov    %esi,%ecx
f0100982:	b8 00 00 00 00       	mov    $0x0,%eax
	int i;
	for (i = 2; s[i] != '\0'; i++) {
f0100987:	eb 5d                	jmp    f01009e6 <xtoi+0x71>
		if (s[i] >= '0' && s[i] <= '9') result = result * 16 + s[i] - '0';
f0100989:	8d 5a d0             	lea    -0x30(%edx),%ebx
f010098c:	80 fb 09             	cmp    $0x9,%bl
f010098f:	77 0c                	ja     f010099d <xtoi+0x28>
f0100991:	c1 e0 04             	shl    $0x4,%eax
f0100994:	0f be d2             	movsbl %dl,%edx
f0100997:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
f010099b:	eb 48                	jmp    f01009e5 <xtoi+0x70>
		else if (s[i] >= 'a' && s[i] <= 'f') result = result * 16 + s[i] - 'a' + 10;
f010099d:	8d 5a 9f             	lea    -0x61(%edx),%ebx
f01009a0:	80 fb 05             	cmp    $0x5,%bl
f01009a3:	77 0c                	ja     f01009b1 <xtoi+0x3c>
f01009a5:	c1 e0 04             	shl    $0x4,%eax
f01009a8:	0f be d2             	movsbl %dl,%edx
f01009ab:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
f01009af:	eb 34                	jmp    f01009e5 <xtoi+0x70>
		else if (s[i] >= 'A' && s[i] <= 'F') result = result * 16 + s[i] - 'A' + 10;
f01009b1:	8d 5a bf             	lea    -0x41(%edx),%ebx
f01009b4:	80 fb 05             	cmp    $0x5,%bl
f01009b7:	77 0c                	ja     f01009c5 <xtoi+0x50>
f01009b9:	c1 e0 04             	shl    $0x4,%eax
f01009bc:	0f be d2             	movsbl %dl,%edx
f01009bf:	8d 44 10 c9          	lea    -0x37(%eax,%edx,1),%eax
f01009c3:	eb 20                	jmp    f01009e5 <xtoi+0x70>
		else panic("xtoi: invalid string %s!", s);
f01009c5:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01009c9:	c7 44 24 08 67 71 10 	movl   $0xf0107167,0x8(%esp)
f01009d0:	f0 
f01009d1:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f01009d8:	00 
f01009d9:	c7 04 24 80 71 10 f0 	movl   $0xf0107180,(%esp)
f01009e0:	e8 5b f6 ff ff       	call   f0100040 <_panic>
f01009e5:	41                   	inc    %ecx
}

uint32_t xtoi(char *s) {
	uint32_t result = 0;
	int i;
	for (i = 2; s[i] != '\0'; i++) {
f01009e6:	8a 51 02             	mov    0x2(%ecx),%dl
f01009e9:	84 d2                	test   %dl,%dl
f01009eb:	75 9c                	jne    f0100989 <xtoi+0x14>
		else if (s[i] >= 'a' && s[i] <= 'f') result = result * 16 + s[i] - 'a' + 10;
		else if (s[i] >= 'A' && s[i] <= 'F') result = result * 16 + s[i] - 'A' + 10;
		else panic("xtoi: invalid string %s!", s);
	}
	return result;
}
f01009ed:	83 c4 10             	add    $0x10,%esp
f01009f0:	5b                   	pop    %ebx
f01009f1:	5e                   	pop    %esi
f01009f2:	5d                   	pop    %ebp
f01009f3:	c3                   	ret    

f01009f4 <print_pte_info>:

void print_pte_info(pte_t *ppte) {
f01009f4:	55                   	push   %ebp
f01009f5:	89 e5                	mov    %esp,%ebp
f01009f7:	83 ec 28             	sub    $0x28,%esp
	cprintf("Phys memory: 0x%08x, PTE_P: %x, PTE_W: %x, PTE_U: %x\n", PTE_ADDR(*ppte), *ppte & PTE_P, *ppte & PTE_W, *ppte & PTE_U);
f01009fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01009fd:	8b 00                	mov    (%eax),%eax
f01009ff:	89 c2                	mov    %eax,%edx
f0100a01:	83 e2 04             	and    $0x4,%edx
f0100a04:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100a08:	89 c2                	mov    %eax,%edx
f0100a0a:	83 e2 02             	and    $0x2,%edx
f0100a0d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100a11:	89 c2                	mov    %eax,%edx
f0100a13:	83 e2 01             	and    $0x1,%edx
f0100a16:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100a1a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a1f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a23:	c7 04 24 74 73 10 f0 	movl   $0xf0107374,(%esp)
f0100a2a:	e8 73 37 00 00       	call   f01041a2 <cprintf>
}
f0100a2f:	c9                   	leave  
f0100a30:	c3                   	ret    

f0100a31 <setperm>:
		} else cprintf("page not exist: %x\n", va);
	}
	return 0;
}

int setperm(int argc, char **argv, struct Trapframe *tf) {
f0100a31:	55                   	push   %ebp
f0100a32:	89 e5                	mov    %esp,%ebp
f0100a34:	57                   	push   %edi
f0100a35:	56                   	push   %esi
f0100a36:	53                   	push   %ebx
f0100a37:	83 ec 1c             	sub    $0x1c,%esp
f0100a3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (argc == 1) {
f0100a3d:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100a41:	75 11                	jne    f0100a54 <setperm+0x23>
		cprintf("Usage: setperm 0xaddr [(clear | set) [P | W | U] | change 0x<perm> ]\n");
f0100a43:	c7 04 24 ac 73 10 f0 	movl   $0xf01073ac,(%esp)
f0100a4a:	e8 53 37 00 00       	call   f01041a2 <cprintf>
		return 0;
f0100a4f:	e9 a9 00 00 00       	jmp    f0100afd <setperm+0xcc>
	}
	uint32_t addr = xtoi(argv[1]);
f0100a54:	8b 43 04             	mov    0x4(%ebx),%eax
f0100a57:	89 04 24             	mov    %eax,(%esp)
f0100a5a:	e8 16 ff ff ff       	call   f0100975 <xtoi>
f0100a5f:	89 c7                	mov    %eax,%edi
	pte_t *ppte = pgdir_walk(kern_pgdir, (void *)addr, 1);
f0100a61:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100a68:	00 
f0100a69:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a6d:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0100a72:	89 04 24             	mov    %eax,(%esp)
f0100a75:	e8 bf 08 00 00       	call   f0101339 <pgdir_walk>
f0100a7a:	89 c6                	mov    %eax,%esi
	uint32_t perm = 0;
	if (argv[2][1] == 'h') { //for change
f0100a7c:	8b 43 08             	mov    0x8(%ebx),%eax
f0100a7f:	8a 40 01             	mov    0x1(%eax),%al
f0100a82:	3c 68                	cmp    $0x68,%al
f0100a84:	75 19                	jne    f0100a9f <setperm+0x6e>
		perm = xtoi(argv[3]);
f0100a86:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a89:	89 04 24             	mov    %eax,(%esp)
f0100a8c:	e8 e4 fe ff ff       	call   f0100975 <xtoi>
		*ppte = (*ppte & 0xfff8) | perm;
f0100a91:	8b 16                	mov    (%esi),%edx
f0100a93:	81 e2 f8 ff 00 00    	and    $0xfff8,%edx
f0100a99:	09 d0                	or     %edx,%eax
f0100a9b:	89 06                	mov    %eax,(%esi)
f0100a9d:	eb 46                	jmp    f0100ae5 <setperm+0xb4>
	}
	else {
		if (argv[3][0] == 'P') perm = PTE_P;
f0100a9f:	8b 53 0c             	mov    0xc(%ebx),%edx
f0100aa2:	8a 12                	mov    (%edx),%dl
		if (argv[3][0] == 'W') perm = PTE_W;
f0100aa4:	80 fa 57             	cmp    $0x57,%dl
f0100aa7:	74 10                	je     f0100ab9 <setperm+0x88>
		if (argv[3][0] == 'U') perm = PTE_U;
f0100aa9:	80 fa 55             	cmp    $0x55,%dl
f0100aac:	74 12                	je     f0100ac0 <setperm+0x8f>
		cprintf("Usage: setperm 0xaddr [(clear | set) [P | W | U] | change 0x<perm> ]\n");
		return 0;
	}
	uint32_t addr = xtoi(argv[1]);
	pte_t *ppte = pgdir_walk(kern_pgdir, (void *)addr, 1);
	uint32_t perm = 0;
f0100aae:	80 fa 50             	cmp    $0x50,%dl
f0100ab1:	0f 94 c2             	sete   %dl
f0100ab4:	0f b6 d2             	movzbl %dl,%edx
f0100ab7:	eb 0c                	jmp    f0100ac5 <setperm+0x94>
		perm = xtoi(argv[3]);
		*ppte = (*ppte & 0xfff8) | perm;
	}
	else {
		if (argv[3][0] == 'P') perm = PTE_P;
		if (argv[3][0] == 'W') perm = PTE_W;
f0100ab9:	ba 02 00 00 00       	mov    $0x2,%edx
f0100abe:	eb 05                	jmp    f0100ac5 <setperm+0x94>
		if (argv[3][0] == 'U') perm = PTE_U;
f0100ac0:	ba 04 00 00 00       	mov    $0x4,%edx
		if (argv[2][1] == 'l') *ppte = *ppte & ~perm; // for clear
f0100ac5:	3c 6c                	cmp    $0x6c,%al
f0100ac7:	75 06                	jne    f0100acf <setperm+0x9e>
f0100ac9:	f7 d2                	not    %edx
f0100acb:	21 16                	and    %edx,(%esi)
f0100acd:	eb 16                	jmp    f0100ae5 <setperm+0xb4>
		else if (argv[2][1] == 'e') *ppte = *ppte | perm; // for set
f0100acf:	3c 65                	cmp    $0x65,%al
f0100ad1:	75 04                	jne    f0100ad7 <setperm+0xa6>
f0100ad3:	09 16                	or     %edx,(%esi)
f0100ad5:	eb 0e                	jmp    f0100ae5 <setperm+0xb4>
		else {
			cprintf("Parameters error!\nUsage: setperm 0xaddr [(clear | set) [P | W | U] | change <perm> ]\n");
f0100ad7:	c7 04 24 f4 73 10 f0 	movl   $0xf01073f4,(%esp)
f0100ade:	e8 bf 36 00 00       	call   f01041a2 <cprintf>
			return 0;
f0100ae3:	eb 18                	jmp    f0100afd <setperm+0xcc>
		}
	}
	cprintf("setperm success.\npage of 0x%x: ", addr);
f0100ae5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100ae9:	c7 04 24 4c 74 10 f0 	movl   $0xf010744c,(%esp)
f0100af0:	e8 ad 36 00 00       	call   f01041a2 <cprintf>
	print_pte_info(ppte);
f0100af5:	89 34 24             	mov    %esi,(%esp)
f0100af8:	e8 f7 fe ff ff       	call   f01009f4 <print_pte_info>
	return 0;
}
f0100afd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b02:	83 c4 1c             	add    $0x1c,%esp
f0100b05:	5b                   	pop    %ebx
f0100b06:	5e                   	pop    %esi
f0100b07:	5f                   	pop    %edi
f0100b08:	5d                   	pop    %ebp
f0100b09:	c3                   	ret    

f0100b0a <showmappings>:
	cprintf("Phys memory: 0x%08x, PTE_P: %x, PTE_W: %x, PTE_U: %x\n", PTE_ADDR(*ppte), *ppte & PTE_P, *ppte & PTE_W, *ppte & PTE_U);
}

int
showmappings(int argc, char **argv, struct Trapframe *tf)
{
f0100b0a:	55                   	push   %ebp
f0100b0b:	89 e5                	mov    %esp,%ebp
f0100b0d:	57                   	push   %edi
f0100b0e:	56                   	push   %esi
f0100b0f:	53                   	push   %ebx
f0100b10:	83 ec 1c             	sub    $0x1c,%esp
f0100b13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (argc != 3) {
f0100b16:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100b1a:	74 11                	je     f0100b2d <showmappings+0x23>
		cprintf("Usage: showmappings 0xbegin 0xend\nshow page mappings from begin to end.\n");
f0100b1c:	c7 04 24 6c 74 10 f0 	movl   $0xf010746c,(%esp)
f0100b23:	e8 7a 36 00 00       	call   f01041a2 <cprintf>
		return 0;
f0100b28:	e9 a4 00 00 00       	jmp    f0100bd1 <showmappings+0xc7>
	}
	uint32_t va = xtoi(argv[1]), vend = xtoi(argv[2]);
f0100b2d:	8b 43 04             	mov    0x4(%ebx),%eax
f0100b30:	89 04 24             	mov    %eax,(%esp)
f0100b33:	e8 3d fe ff ff       	call   f0100975 <xtoi>
f0100b38:	89 c6                	mov    %eax,%esi
f0100b3a:	8b 43 08             	mov    0x8(%ebx),%eax
f0100b3d:	89 04 24             	mov    %eax,(%esp)
f0100b40:	e8 30 fe ff ff       	call   f0100975 <xtoi>
f0100b45:	89 c7                	mov    %eax,%edi
	cprintf("begin: %x, end: %x\n", va, vend);
f0100b47:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b4b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b4f:	c7 04 24 8f 71 10 f0 	movl   $0xf010718f,(%esp)
f0100b56:	e8 47 36 00 00       	call   f01041a2 <cprintf>
	for (; va <= vend; va += PGSIZE) {
f0100b5b:	eb 70                	jmp    f0100bcd <showmappings+0xc3>
		pte_t *ppte = pgdir_walk(kern_pgdir, (void *)va, 1);
f0100b5d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100b64:	00 
f0100b65:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b69:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0100b6e:	89 04 24             	mov    %eax,(%esp)
f0100b71:	e8 c3 07 00 00       	call   f0101339 <pgdir_walk>
f0100b76:	89 c3                	mov    %eax,%ebx
		if (!ppte) panic("showmappings: creating page error!");
f0100b78:	85 c0                	test   %eax,%eax
f0100b7a:	75 1c                	jne    f0100b98 <showmappings+0x8e>
f0100b7c:	c7 44 24 08 b8 74 10 	movl   $0xf01074b8,0x8(%esp)
f0100b83:	f0 
f0100b84:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
f0100b8b:	00 
f0100b8c:	c7 04 24 80 71 10 f0 	movl   $0xf0107180,(%esp)
f0100b93:	e8 a8 f4 ff ff       	call   f0100040 <_panic>
		if (*ppte & PTE_P) {
f0100b98:	f6 00 01             	testb  $0x1,(%eax)
f0100b9b:	74 1a                	je     f0100bb7 <showmappings+0xad>
			cprintf("page of 0x%x: ", va);
f0100b9d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ba1:	c7 04 24 a3 71 10 f0 	movl   $0xf01071a3,(%esp)
f0100ba8:	e8 f5 35 00 00       	call   f01041a2 <cprintf>
			print_pte_info(ppte);
f0100bad:	89 1c 24             	mov    %ebx,(%esp)
f0100bb0:	e8 3f fe ff ff       	call   f01009f4 <print_pte_info>
f0100bb5:	eb 10                	jmp    f0100bc7 <showmappings+0xbd>
		} else cprintf("page not exist: %x\n", va);
f0100bb7:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100bbb:	c7 04 24 b2 71 10 f0 	movl   $0xf01071b2,(%esp)
f0100bc2:	e8 db 35 00 00       	call   f01041a2 <cprintf>
		cprintf("Usage: showmappings 0xbegin 0xend\nshow page mappings from begin to end.\n");
		return 0;
	}
	uint32_t va = xtoi(argv[1]), vend = xtoi(argv[2]);
	cprintf("begin: %x, end: %x\n", va, vend);
	for (; va <= vend; va += PGSIZE) {
f0100bc7:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0100bcd:	39 fe                	cmp    %edi,%esi
f0100bcf:	76 8c                	jbe    f0100b5d <showmappings+0x53>
			cprintf("page of 0x%x: ", va);
			print_pte_info(ppte);
		} else cprintf("page not exist: %x\n", va);
	}
	return 0;
}
f0100bd1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bd6:	83 c4 1c             	add    $0x1c,%esp
f0100bd9:	5b                   	pop    %ebx
f0100bda:	5e                   	pop    %esi
f0100bdb:	5f                   	pop    %edi
f0100bdc:	5d                   	pop    %ebp
f0100bdd:	c3                   	ret    

f0100bde <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100bde:	55                   	push   %ebp
f0100bdf:	89 e5                	mov    %esp,%ebp
f0100be1:	57                   	push   %edi
f0100be2:	56                   	push   %esi
f0100be3:	53                   	push   %ebx
f0100be4:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100be7:	c7 04 24 dc 74 10 f0 	movl   $0xf01074dc,(%esp)
f0100bee:	e8 af 35 00 00       	call   f01041a2 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100bf3:	c7 04 24 00 75 10 f0 	movl   $0xf0107500,(%esp)
f0100bfa:	e8 a3 35 00 00       	call   f01041a2 <cprintf>
	if (tf != NULL)
f0100bff:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100c03:	74 0b                	je     f0100c10 <monitor+0x32>
		print_trapframe(tf);
f0100c05:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c08:	89 04 24             	mov    %eax,(%esp)
f0100c0b:	e8 5a 38 00 00       	call   f010446a <print_trapframe>
	while (1) {
		buf = readline("K> ");
f0100c10:	c7 04 24 c6 71 10 f0 	movl   $0xf01071c6,(%esp)
f0100c17:	e8 b0 52 00 00       	call   f0105ecc <readline>
f0100c1c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100c1e:	85 c0                	test   %eax,%eax
f0100c20:	74 ee                	je     f0100c10 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100c22:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100c29:	be 00 00 00 00       	mov    $0x0,%esi
f0100c2e:	eb 04                	jmp    f0100c34 <monitor+0x56>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100c30:	c6 03 00             	movb   $0x0,(%ebx)
f0100c33:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100c34:	8a 03                	mov    (%ebx),%al
f0100c36:	84 c0                	test   %al,%al
f0100c38:	74 5e                	je     f0100c98 <monitor+0xba>
f0100c3a:	0f be c0             	movsbl %al,%eax
f0100c3d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c41:	c7 04 24 ca 71 10 f0 	movl   $0xf01071ca,(%esp)
f0100c48:	e8 74 54 00 00       	call   f01060c1 <strchr>
f0100c4d:	85 c0                	test   %eax,%eax
f0100c4f:	75 df                	jne    f0100c30 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100c51:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100c54:	74 42                	je     f0100c98 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100c56:	83 fe 0f             	cmp    $0xf,%esi
f0100c59:	75 16                	jne    f0100c71 <monitor+0x93>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100c5b:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100c62:	00 
f0100c63:	c7 04 24 cf 71 10 f0 	movl   $0xf01071cf,(%esp)
f0100c6a:	e8 33 35 00 00       	call   f01041a2 <cprintf>
f0100c6f:	eb 9f                	jmp    f0100c10 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100c71:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100c75:	46                   	inc    %esi
f0100c76:	eb 01                	jmp    f0100c79 <monitor+0x9b>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100c78:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100c79:	8a 03                	mov    (%ebx),%al
f0100c7b:	84 c0                	test   %al,%al
f0100c7d:	74 b5                	je     f0100c34 <monitor+0x56>
f0100c7f:	0f be c0             	movsbl %al,%eax
f0100c82:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c86:	c7 04 24 ca 71 10 f0 	movl   $0xf01071ca,(%esp)
f0100c8d:	e8 2f 54 00 00       	call   f01060c1 <strchr>
f0100c92:	85 c0                	test   %eax,%eax
f0100c94:	74 e2                	je     f0100c78 <monitor+0x9a>
f0100c96:	eb 9c                	jmp    f0100c34 <monitor+0x56>
			buf++;
	}
	argv[argc] = 0;
f0100c98:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100c9f:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100ca0:	85 f6                	test   %esi,%esi
f0100ca2:	0f 84 68 ff ff ff    	je     f0100c10 <monitor+0x32>
f0100ca8:	bb c0 75 10 f0       	mov    $0xf01075c0,%ebx
f0100cad:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100cb2:	8b 03                	mov    (%ebx),%eax
f0100cb4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cb8:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100cbb:	89 04 24             	mov    %eax,(%esp)
f0100cbe:	e8 ab 53 00 00       	call   f010606e <strcmp>
f0100cc3:	85 c0                	test   %eax,%eax
f0100cc5:	75 24                	jne    f0100ceb <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f0100cc7:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100cca:	8b 55 08             	mov    0x8(%ebp),%edx
f0100ccd:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100cd1:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100cd4:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100cd8:	89 34 24             	mov    %esi,(%esp)
f0100cdb:	ff 14 85 c8 75 10 f0 	call   *-0xfef8a38(,%eax,4)
	if (tf != NULL)
		print_trapframe(tf);
	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100ce2:	85 c0                	test   %eax,%eax
f0100ce4:	78 26                	js     f0100d0c <monitor+0x12e>
f0100ce6:	e9 25 ff ff ff       	jmp    f0100c10 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100ceb:	47                   	inc    %edi
f0100cec:	83 c3 0c             	add    $0xc,%ebx
f0100cef:	83 ff 05             	cmp    $0x5,%edi
f0100cf2:	75 be                	jne    f0100cb2 <monitor+0xd4>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100cf4:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100cf7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cfb:	c7 04 24 ec 71 10 f0 	movl   $0xf01071ec,(%esp)
f0100d02:	e8 9b 34 00 00       	call   f01041a2 <cprintf>
f0100d07:	e9 04 ff ff ff       	jmp    f0100c10 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100d0c:	83 c4 5c             	add    $0x5c,%esp
f0100d0f:	5b                   	pop    %ebx
f0100d10:	5e                   	pop    %esi
f0100d11:	5f                   	pop    %edi
f0100d12:	5d                   	pop    %ebp
f0100d13:	c3                   	ret    

f0100d14 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100d14:	55                   	push   %ebp
f0100d15:	89 e5                	mov    %esp,%ebp
f0100d17:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100d19:	83 3d 3c 22 33 f0 00 	cmpl   $0x0,0xf033223c
f0100d20:	75 0f                	jne    f0100d31 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100d22:	b8 07 50 37 f0       	mov    $0xf0375007,%eax
f0100d27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d2c:	a3 3c 22 33 f0       	mov    %eax,0xf033223c
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n != 0) {
f0100d31:	85 d2                	test   %edx,%edx
f0100d33:	74 26                	je     f0100d5b <boot_alloc+0x47>
		result = ROUNDUP((char *) nextfree, PGSIZE);
f0100d35:	8b 0d 3c 22 33 f0    	mov    0xf033223c,%ecx
f0100d3b:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
f0100d41:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		nextfree = ROUNDUP((char *) (nextfree + n), PGSIZE);
f0100d46:	8d 94 11 ff 0f 00 00 	lea    0xfff(%ecx,%edx,1),%edx
f0100d4d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100d53:	89 15 3c 22 33 f0    	mov    %edx,0xf033223c
		return result;
f0100d59:	eb 05                	jmp    f0100d60 <boot_alloc+0x4c>
	}
	else return nextfree;
f0100d5b:	a1 3c 22 33 f0       	mov    0xf033223c,%eax
}
f0100d60:	5d                   	pop    %ebp
f0100d61:	c3                   	ret    

f0100d62 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100d62:	55                   	push   %ebp
f0100d63:	89 e5                	mov    %esp,%ebp
f0100d65:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100d68:	89 d1                	mov    %edx,%ecx
f0100d6a:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100d6d:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100d70:	a8 01                	test   $0x1,%al
f0100d72:	74 4d                	je     f0100dc1 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100d74:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d79:	89 c1                	mov    %eax,%ecx
f0100d7b:	c1 e9 0c             	shr    $0xc,%ecx
f0100d7e:	3b 0d 88 2e 33 f0    	cmp    0xf0332e88,%ecx
f0100d84:	72 20                	jb     f0100da6 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d86:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d8a:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f0100d91:	f0 
f0100d92:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f0100d99:	00 
f0100d9a:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0100da1:	e8 9a f2 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100da6:	c1 ea 0c             	shr    $0xc,%edx
f0100da9:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100daf:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100db6:	a8 01                	test   $0x1,%al
f0100db8:	74 0e                	je     f0100dc8 <check_va2pa+0x66>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100dba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100dbf:	eb 0c                	jmp    f0100dcd <check_va2pa+0x6b>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100dc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100dc6:	eb 05                	jmp    f0100dcd <check_va2pa+0x6b>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0100dc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100dcd:	c9                   	leave  
f0100dce:	c3                   	ret    

f0100dcf <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100dcf:	55                   	push   %ebp
f0100dd0:	89 e5                	mov    %esp,%ebp
f0100dd2:	56                   	push   %esi
f0100dd3:	53                   	push   %ebx
f0100dd4:	83 ec 10             	sub    $0x10,%esp
f0100dd7:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100dd9:	89 04 24             	mov    %eax,(%esp)
f0100ddc:	e8 7b 32 00 00       	call   f010405c <mc146818_read>
f0100de1:	89 c6                	mov    %eax,%esi
f0100de3:	43                   	inc    %ebx
f0100de4:	89 1c 24             	mov    %ebx,(%esp)
f0100de7:	e8 70 32 00 00       	call   f010405c <mc146818_read>
f0100dec:	c1 e0 08             	shl    $0x8,%eax
f0100def:	09 f0                	or     %esi,%eax
}
f0100df1:	83 c4 10             	add    $0x10,%esp
f0100df4:	5b                   	pop    %ebx
f0100df5:	5e                   	pop    %esi
f0100df6:	5d                   	pop    %ebp
f0100df7:	c3                   	ret    

f0100df8 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100df8:	55                   	push   %ebp
f0100df9:	89 e5                	mov    %esp,%ebp
f0100dfb:	57                   	push   %edi
f0100dfc:	56                   	push   %esi
f0100dfd:	53                   	push   %ebx
f0100dfe:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e01:	3c 01                	cmp    $0x1,%al
f0100e03:	19 f6                	sbb    %esi,%esi
f0100e05:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100e0b:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e0c:	8b 15 40 22 33 f0    	mov    0xf0332240,%edx
f0100e12:	85 d2                	test   %edx,%edx
f0100e14:	75 1c                	jne    f0100e32 <check_page_free_list+0x3a>
		panic("'page_free_list' is a null pointer!");
f0100e16:	c7 44 24 08 fc 75 10 	movl   $0xf01075fc,0x8(%esp)
f0100e1d:	f0 
f0100e1e:	c7 44 24 04 99 02 00 	movl   $0x299,0x4(%esp)
f0100e25:	00 
f0100e26:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0100e2d:	e8 0e f2 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
f0100e32:	84 c0                	test   %al,%al
f0100e34:	74 4b                	je     f0100e81 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e36:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100e39:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100e3c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100e3f:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e42:	89 d0                	mov    %edx,%eax
f0100e44:	2b 05 90 2e 33 f0    	sub    0xf0332e90,%eax
f0100e4a:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100e4d:	c1 e8 16             	shr    $0x16,%eax
f0100e50:	39 c6                	cmp    %eax,%esi
f0100e52:	0f 96 c0             	setbe  %al
f0100e55:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100e58:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f0100e5c:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100e5e:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e62:	8b 12                	mov    (%edx),%edx
f0100e64:	85 d2                	test   %edx,%edx
f0100e66:	75 da                	jne    f0100e42 <check_page_free_list+0x4a>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100e68:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100e6b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100e71:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e74:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100e77:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e79:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e7c:	a3 40 22 33 f0       	mov    %eax,0xf0332240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e81:	8b 1d 40 22 33 f0    	mov    0xf0332240,%ebx
f0100e87:	eb 63                	jmp    f0100eec <check_page_free_list+0xf4>
f0100e89:	89 d8                	mov    %ebx,%eax
f0100e8b:	2b 05 90 2e 33 f0    	sub    0xf0332e90,%eax
f0100e91:	c1 f8 03             	sar    $0x3,%eax
f0100e94:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100e97:	89 c2                	mov    %eax,%edx
f0100e99:	c1 ea 16             	shr    $0x16,%edx
f0100e9c:	39 d6                	cmp    %edx,%esi
f0100e9e:	76 4a                	jbe    f0100eea <check_page_free_list+0xf2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ea0:	89 c2                	mov    %eax,%edx
f0100ea2:	c1 ea 0c             	shr    $0xc,%edx
f0100ea5:	3b 15 88 2e 33 f0    	cmp    0xf0332e88,%edx
f0100eab:	72 20                	jb     f0100ecd <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ead:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100eb1:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f0100eb8:	f0 
f0100eb9:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100ec0:	00 
f0100ec1:	c7 04 24 a1 7f 10 f0 	movl   $0xf0107fa1,(%esp)
f0100ec8:	e8 73 f1 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100ecd:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100ed4:	00 
f0100ed5:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100edc:	00 
	return (void *)(pa + KERNBASE);
f0100edd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ee2:	89 04 24             	mov    %eax,(%esp)
f0100ee5:	e8 0c 52 00 00       	call   f01060f6 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100eea:	8b 1b                	mov    (%ebx),%ebx
f0100eec:	85 db                	test   %ebx,%ebx
f0100eee:	75 99                	jne    f0100e89 <check_page_free_list+0x91>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100ef0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ef5:	e8 1a fe ff ff       	call   f0100d14 <boot_alloc>
f0100efa:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100efd:	8b 15 40 22 33 f0    	mov    0xf0332240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100f03:	8b 0d 90 2e 33 f0    	mov    0xf0332e90,%ecx
		assert(pp < pages + npages);
f0100f09:	a1 88 2e 33 f0       	mov    0xf0332e88,%eax
f0100f0e:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100f11:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100f14:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100f17:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100f1a:	be 00 00 00 00       	mov    $0x0,%esi
f0100f1f:	89 4d c0             	mov    %ecx,-0x40(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f22:	e9 c4 01 00 00       	jmp    f01010eb <check_page_free_list+0x2f3>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100f27:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0100f2a:	73 24                	jae    f0100f50 <check_page_free_list+0x158>
f0100f2c:	c7 44 24 0c af 7f 10 	movl   $0xf0107faf,0xc(%esp)
f0100f33:	f0 
f0100f34:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0100f3b:	f0 
f0100f3c:	c7 44 24 04 b3 02 00 	movl   $0x2b3,0x4(%esp)
f0100f43:	00 
f0100f44:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0100f4b:	e8 f0 f0 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100f50:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100f53:	72 24                	jb     f0100f79 <check_page_free_list+0x181>
f0100f55:	c7 44 24 0c d0 7f 10 	movl   $0xf0107fd0,0xc(%esp)
f0100f5c:	f0 
f0100f5d:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0100f64:	f0 
f0100f65:	c7 44 24 04 b4 02 00 	movl   $0x2b4,0x4(%esp)
f0100f6c:	00 
f0100f6d:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0100f74:	e8 c7 f0 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100f79:	89 d0                	mov    %edx,%eax
f0100f7b:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100f7e:	a8 07                	test   $0x7,%al
f0100f80:	74 24                	je     f0100fa6 <check_page_free_list+0x1ae>
f0100f82:	c7 44 24 0c 20 76 10 	movl   $0xf0107620,0xc(%esp)
f0100f89:	f0 
f0100f8a:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0100f91:	f0 
f0100f92:	c7 44 24 04 b5 02 00 	movl   $0x2b5,0x4(%esp)
f0100f99:	00 
f0100f9a:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0100fa1:	e8 9a f0 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fa6:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100fa9:	c1 e0 0c             	shl    $0xc,%eax
f0100fac:	75 24                	jne    f0100fd2 <check_page_free_list+0x1da>
f0100fae:	c7 44 24 0c e4 7f 10 	movl   $0xf0107fe4,0xc(%esp)
f0100fb5:	f0 
f0100fb6:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0100fbd:	f0 
f0100fbe:	c7 44 24 04 b8 02 00 	movl   $0x2b8,0x4(%esp)
f0100fc5:	00 
f0100fc6:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0100fcd:	e8 6e f0 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100fd2:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100fd7:	75 24                	jne    f0100ffd <check_page_free_list+0x205>
f0100fd9:	c7 44 24 0c f5 7f 10 	movl   $0xf0107ff5,0xc(%esp)
f0100fe0:	f0 
f0100fe1:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0100fe8:	f0 
f0100fe9:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
f0100ff0:	00 
f0100ff1:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0100ff8:	e8 43 f0 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ffd:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101002:	75 24                	jne    f0101028 <check_page_free_list+0x230>
f0101004:	c7 44 24 0c 54 76 10 	movl   $0xf0107654,0xc(%esp)
f010100b:	f0 
f010100c:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101013:	f0 
f0101014:	c7 44 24 04 ba 02 00 	movl   $0x2ba,0x4(%esp)
f010101b:	00 
f010101c:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101023:	e8 18 f0 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101028:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010102d:	75 24                	jne    f0101053 <check_page_free_list+0x25b>
f010102f:	c7 44 24 0c 0e 80 10 	movl   $0xf010800e,0xc(%esp)
f0101036:	f0 
f0101037:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010103e:	f0 
f010103f:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
f0101046:	00 
f0101047:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f010104e:	e8 ed ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101053:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101058:	76 59                	jbe    f01010b3 <check_page_free_list+0x2bb>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010105a:	89 c1                	mov    %eax,%ecx
f010105c:	c1 e9 0c             	shr    $0xc,%ecx
f010105f:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0101062:	77 20                	ja     f0101084 <check_page_free_list+0x28c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101064:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101068:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f010106f:	f0 
f0101070:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101077:	00 
f0101078:	c7 04 24 a1 7f 10 f0 	movl   $0xf0107fa1,(%esp)
f010107f:	e8 bc ef ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101084:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f010108a:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f010108d:	76 24                	jbe    f01010b3 <check_page_free_list+0x2bb>
f010108f:	c7 44 24 0c 78 76 10 	movl   $0xf0107678,0xc(%esp)
f0101096:	f0 
f0101097:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010109e:	f0 
f010109f:	c7 44 24 04 bc 02 00 	movl   $0x2bc,0x4(%esp)
f01010a6:	00 
f01010a7:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01010ae:	e8 8d ef ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01010b3:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01010b8:	75 24                	jne    f01010de <check_page_free_list+0x2e6>
f01010ba:	c7 44 24 0c 28 80 10 	movl   $0xf0108028,0xc(%esp)
f01010c1:	f0 
f01010c2:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01010c9:	f0 
f01010ca:	c7 44 24 04 be 02 00 	movl   $0x2be,0x4(%esp)
f01010d1:	00 
f01010d2:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01010d9:	e8 62 ef ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f01010de:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01010e3:	77 03                	ja     f01010e8 <check_page_free_list+0x2f0>
			++nfree_basemem;
f01010e5:	46                   	inc    %esi
f01010e6:	eb 01                	jmp    f01010e9 <check_page_free_list+0x2f1>
		else
			++nfree_extmem;
f01010e8:	43                   	inc    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010e9:	8b 12                	mov    (%edx),%edx
f01010eb:	85 d2                	test   %edx,%edx
f01010ed:	0f 85 34 fe ff ff    	jne    f0100f27 <check_page_free_list+0x12f>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01010f3:	85 f6                	test   %esi,%esi
f01010f5:	7f 24                	jg     f010111b <check_page_free_list+0x323>
f01010f7:	c7 44 24 0c 45 80 10 	movl   $0xf0108045,0xc(%esp)
f01010fe:	f0 
f01010ff:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101106:	f0 
f0101107:	c7 44 24 04 c6 02 00 	movl   $0x2c6,0x4(%esp)
f010110e:	00 
f010110f:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101116:	e8 25 ef ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f010111b:	85 db                	test   %ebx,%ebx
f010111d:	7f 24                	jg     f0101143 <check_page_free_list+0x34b>
f010111f:	c7 44 24 0c 57 80 10 	movl   $0xf0108057,0xc(%esp)
f0101126:	f0 
f0101127:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010112e:	f0 
f010112f:	c7 44 24 04 c7 02 00 	movl   $0x2c7,0x4(%esp)
f0101136:	00 
f0101137:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f010113e:	e8 fd ee ff ff       	call   f0100040 <_panic>
}
f0101143:	83 c4 4c             	add    $0x4c,%esp
f0101146:	5b                   	pop    %ebx
f0101147:	5e                   	pop    %esi
f0101148:	5f                   	pop    %edi
f0101149:	5d                   	pop    %ebp
f010114a:	c3                   	ret    

f010114b <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f010114b:	55                   	push   %ebp
f010114c:	89 e5                	mov    %esp,%ebp
f010114e:	53                   	push   %ebx
f010114f:	83 ec 14             	sub    $0x14,%esp
	// 3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	//    never be allocated.
	char *first_free_page;
	first_free_page = (char *) boot_alloc(0);
	struct PageInfo *tmp = pages[PGNUM(IOPHYSMEM)].pp_link;
	for (i = PGNUM(IOPHYSMEM); i < PGNUM(PADDR(first_free_page)); i++) {
f0101152:	8b 1d 40 22 33 f0    	mov    0xf0332240,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0101158:	b8 00 00 00 00       	mov    $0x0,%eax
f010115d:	eb 20                	jmp    f010117f <page_init+0x34>
		pages[i].pp_ref = 0;
f010115f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101166:	89 d1                	mov    %edx,%ecx
f0101168:	03 0d 90 2e 33 f0    	add    0xf0332e90,%ecx
f010116e:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0101174:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0101176:	89 d3                	mov    %edx,%ebx
f0101178:	03 1d 90 2e 33 f0    	add    0xf0332e90,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f010117e:	40                   	inc    %eax
f010117f:	3b 05 88 2e 33 f0    	cmp    0xf0332e88,%eax
f0101185:	72 d8                	jb     f010115f <page_init+0x14>
f0101187:	89 1d 40 22 33 f0    	mov    %ebx,0xf0332240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	uint32_t index = MPENTRY_PADDR/PGSIZE;
	pages[index].pp_ref = 1;
f010118d:	a1 90 2e 33 f0       	mov    0xf0332e90,%eax
f0101192:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
	pages[index].pp_link = NULL;
f0101198:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
	pages[index + 1].pp_link = &pages[index - 1];
f010119f:	8d 50 30             	lea    0x30(%eax),%edx
f01011a2:	89 50 40             	mov    %edx,0x40(%eax)

	// 1) Mark physical page 0 as in use.
	pages[0].pp_ref = 1;
f01011a5:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = NULL;
f01011ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pages[1].pp_link = NULL;
f01011b1:	a1 90 2e 33 f0       	mov    0xf0332e90,%eax
f01011b6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	// 3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	//    never be allocated.
	char *first_free_page;
	first_free_page = (char *) boot_alloc(0);
f01011bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01011c2:	e8 4d fb ff ff       	call   f0100d14 <boot_alloc>
	struct PageInfo *tmp = pages[PGNUM(IOPHYSMEM)].pp_link;
f01011c7:	8b 15 90 2e 33 f0    	mov    0xf0332e90,%edx
f01011cd:	8b 9a 00 05 00 00    	mov    0x500(%edx),%ebx
static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f01011d3:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
	for (i = PGNUM(IOPHYSMEM); i < PGNUM(PADDR(first_free_page)); i++) {
f01011d9:	c1 e9 0c             	shr    $0xc,%ecx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01011dc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01011e1:	76 23                	jbe    f0101206 <page_init+0xbb>
f01011e3:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01011e8:	eb 3c                	jmp    f0101226 <page_init+0xdb>
		pages[i].pp_ref = 1;
f01011ea:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01011f1:	03 15 90 2e 33 f0    	add    0xf0332e90,%edx
f01011f7:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = NULL;
f01011fd:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	// 3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	//    never be allocated.
	char *first_free_page;
	first_free_page = (char *) boot_alloc(0);
	struct PageInfo *tmp = pages[PGNUM(IOPHYSMEM)].pp_link;
	for (i = PGNUM(IOPHYSMEM); i < PGNUM(PADDR(first_free_page)); i++) {
f0101203:	40                   	inc    %eax
f0101204:	eb 20                	jmp    f0101226 <page_init+0xdb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101206:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010120a:	c7 44 24 08 24 6e 10 	movl   $0xf0106e24,0x8(%esp)
f0101211:	f0 
f0101212:	c7 44 24 04 4c 01 00 	movl   $0x14c,0x4(%esp)
f0101219:	00 
f010121a:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101221:	e8 1a ee ff ff       	call   f0100040 <_panic>
f0101226:	39 c8                	cmp    %ecx,%eax
f0101228:	72 c0                	jb     f01011ea <page_init+0x9f>
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
	pages[i].pp_link = tmp;
f010122a:	8b 15 90 2e 33 f0    	mov    0xf0332e90,%edx
f0101230:	89 1c c2             	mov    %ebx,(%edx,%eax,8)
}
f0101233:	83 c4 14             	add    $0x14,%esp
f0101236:	5b                   	pop    %ebx
f0101237:	5d                   	pop    %ebp
f0101238:	c3                   	ret    

f0101239 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101239:	55                   	push   %ebp
f010123a:	89 e5                	mov    %esp,%ebp
f010123c:	53                   	push   %ebx
f010123d:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	if (page_free_list == NULL) return NULL;
f0101240:	8b 1d 40 22 33 f0    	mov    0xf0332240,%ebx
f0101246:	85 db                	test   %ebx,%ebx
f0101248:	74 6b                	je     f01012b5 <page_alloc+0x7c>
	struct PageInfo *result;
	result = page_free_list;
	page_free_list = result->pp_link;
f010124a:	8b 03                	mov    (%ebx),%eax
f010124c:	a3 40 22 33 f0       	mov    %eax,0xf0332240
	result->pp_link = NULL;
f0101251:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) memset(page2kva(result), 0, PGSIZE);
f0101257:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010125b:	74 58                	je     f01012b5 <page_alloc+0x7c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010125d:	89 d8                	mov    %ebx,%eax
f010125f:	2b 05 90 2e 33 f0    	sub    0xf0332e90,%eax
f0101265:	c1 f8 03             	sar    $0x3,%eax
f0101268:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010126b:	89 c2                	mov    %eax,%edx
f010126d:	c1 ea 0c             	shr    $0xc,%edx
f0101270:	3b 15 88 2e 33 f0    	cmp    0xf0332e88,%edx
f0101276:	72 20                	jb     f0101298 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101278:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010127c:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f0101283:	f0 
f0101284:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010128b:	00 
f010128c:	c7 04 24 a1 7f 10 f0 	movl   $0xf0107fa1,(%esp)
f0101293:	e8 a8 ed ff ff       	call   f0100040 <_panic>
f0101298:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010129f:	00 
f01012a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01012a7:	00 
	return (void *)(pa + KERNBASE);
f01012a8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01012ad:	89 04 24             	mov    %eax,(%esp)
f01012b0:	e8 41 4e 00 00       	call   f01060f6 <memset>
	return result;
}
f01012b5:	89 d8                	mov    %ebx,%eax
f01012b7:	83 c4 14             	add    $0x14,%esp
f01012ba:	5b                   	pop    %ebx
f01012bb:	5d                   	pop    %ebp
f01012bc:	c3                   	ret    

f01012bd <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01012bd:	55                   	push   %ebp
f01012be:	89 e5                	mov    %esp,%ebp
f01012c0:	83 ec 18             	sub    $0x18,%esp
f01012c3:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0) panic("page_free: pp->pp_ref is nonzero!");
f01012c6:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01012cb:	74 1c                	je     f01012e9 <page_free+0x2c>
f01012cd:	c7 44 24 08 c0 76 10 	movl   $0xf01076c0,0x8(%esp)
f01012d4:	f0 
f01012d5:	c7 44 24 04 76 01 00 	movl   $0x176,0x4(%esp)
f01012dc:	00 
f01012dd:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01012e4:	e8 57 ed ff ff       	call   f0100040 <_panic>
	if (pp->pp_link != NULL) panic("page_free: pp->pp_link is not NULL!");
f01012e9:	83 38 00             	cmpl   $0x0,(%eax)
f01012ec:	74 1c                	je     f010130a <page_free+0x4d>
f01012ee:	c7 44 24 08 e4 76 10 	movl   $0xf01076e4,0x8(%esp)
f01012f5:	f0 
f01012f6:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
f01012fd:	00 
f01012fe:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101305:	e8 36 ed ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f010130a:	8b 15 40 22 33 f0    	mov    0xf0332240,%edx
f0101310:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101312:	a3 40 22 33 f0       	mov    %eax,0xf0332240
	return;
}
f0101317:	c9                   	leave  
f0101318:	c3                   	ret    

f0101319 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101319:	55                   	push   %ebp
f010131a:	89 e5                	mov    %esp,%ebp
f010131c:	83 ec 18             	sub    $0x18,%esp
f010131f:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101322:	8b 50 04             	mov    0x4(%eax),%edx
f0101325:	4a                   	dec    %edx
f0101326:	66 89 50 04          	mov    %dx,0x4(%eax)
f010132a:	66 85 d2             	test   %dx,%dx
f010132d:	75 08                	jne    f0101337 <page_decref+0x1e>
		page_free(pp);
f010132f:	89 04 24             	mov    %eax,(%esp)
f0101332:	e8 86 ff ff ff       	call   f01012bd <page_free>
}
f0101337:	c9                   	leave  
f0101338:	c3                   	ret    

f0101339 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101339:	55                   	push   %ebp
f010133a:	89 e5                	mov    %esp,%ebp
f010133c:	56                   	push   %esi
f010133d:	53                   	push   %ebx
f010133e:	83 ec 10             	sub    $0x10,%esp
f0101341:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	if (!(pgdir[PDX(va)] & PTE_P)) {
f0101344:	89 f3                	mov    %esi,%ebx
f0101346:	c1 eb 16             	shr    $0x16,%ebx
f0101349:	c1 e3 02             	shl    $0x2,%ebx
f010134c:	03 5d 08             	add    0x8(%ebp),%ebx
f010134f:	f6 03 01             	testb  $0x1,(%ebx)
f0101352:	75 2b                	jne    f010137f <pgdir_walk+0x46>
		if (!create) return NULL;
f0101354:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101358:	74 6b                	je     f01013c5 <pgdir_walk+0x8c>
		struct PageInfo *pp = page_alloc(1);
f010135a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101361:	e8 d3 fe ff ff       	call   f0101239 <page_alloc>
		if (!pp) return NULL;
f0101366:	85 c0                	test   %eax,%eax
f0101368:	74 62                	je     f01013cc <pgdir_walk+0x93>
		pp->pp_ref++;
f010136a:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010136e:	2b 05 90 2e 33 f0    	sub    0xf0332e90,%eax
f0101374:	c1 f8 03             	sar    $0x3,%eax
f0101377:	c1 e0 0c             	shl    $0xc,%eax
		pgdir[PDX(va)] = page2pa(pp) | PTE_P | PTE_W | PTE_U;
f010137a:	83 c8 07             	or     $0x7,%eax
f010137d:	89 03                	mov    %eax,(%ebx)
	}
	return (pte_t *)((pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va));
f010137f:	8b 03                	mov    (%ebx),%eax
f0101381:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101386:	89 c2                	mov    %eax,%edx
f0101388:	c1 ea 0c             	shr    $0xc,%edx
f010138b:	3b 15 88 2e 33 f0    	cmp    0xf0332e88,%edx
f0101391:	72 20                	jb     f01013b3 <pgdir_walk+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101393:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101397:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f010139e:	f0 
f010139f:	c7 44 24 04 a9 01 00 	movl   $0x1a9,0x4(%esp)
f01013a6:	00 
f01013a7:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01013ae:	e8 8d ec ff ff       	call   f0100040 <_panic>
f01013b3:	c1 ee 0a             	shr    $0xa,%esi
f01013b6:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01013bc:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f01013c3:	eb 0c                	jmp    f01013d1 <pgdir_walk+0x98>
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
	if (!(pgdir[PDX(va)] & PTE_P)) {
		if (!create) return NULL;
f01013c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01013ca:	eb 05                	jmp    f01013d1 <pgdir_walk+0x98>
		struct PageInfo *pp = page_alloc(1);
		if (!pp) return NULL;
f01013cc:	b8 00 00 00 00       	mov    $0x0,%eax
		pp->pp_ref++;
		pgdir[PDX(va)] = page2pa(pp) | PTE_P | PTE_W | PTE_U;
	}
	return (pte_t *)((pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va));
}
f01013d1:	83 c4 10             	add    $0x10,%esp
f01013d4:	5b                   	pop    %ebx
f01013d5:	5e                   	pop    %esi
f01013d6:	5d                   	pop    %ebp
f01013d7:	c3                   	ret    

f01013d8 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01013d8:	55                   	push   %ebp
f01013d9:	89 e5                	mov    %esp,%ebp
f01013db:	57                   	push   %edi
f01013dc:	56                   	push   %esi
f01013dd:	53                   	push   %ebx
f01013de:	83 ec 2c             	sub    $0x2c,%esp
f01013e1:	89 c7                	mov    %eax,%edi
	// Fill this function in
	uintptr_t va_ptr, vend_ptr;
	physaddr_t pa_ptr;
	pte_t *ppte;
	vend_ptr = va + size;
f01013e3:	8d 04 11             	lea    (%ecx,%edx,1),%eax
f01013e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (size > (unsigned)0xffffffff - vend_ptr + 1) vend_ptr = ROUNDUP(0xfffff000, PGSIZE);
f01013e9:	f7 d8                	neg    %eax
f01013eb:	39 c1                	cmp    %eax,%ecx
f01013ed:	76 07                	jbe    f01013f6 <boot_map_region+0x1e>
f01013ef:	c7 45 e4 00 f0 ff ff 	movl   $0xfffff000,-0x1c(%ebp)
	for (va_ptr = va, pa_ptr = pa; va_ptr != vend_ptr; va_ptr += PGSIZE, pa_ptr += PGSIZE) {
f01013f6:	8b 75 08             	mov    0x8(%ebp),%esi
f01013f9:	89 d3                	mov    %edx,%ebx
		ppte = pgdir_walk(pgdir, (void *)va_ptr, 1);
		if (!ppte) panic("boot_map_region: cannot find valid page!");
		*ppte = PTE_ADDR(pa_ptr) | perm | PTE_P;
f01013fb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013fe:	83 c8 01             	or     $0x1,%eax
f0101401:	89 45 e0             	mov    %eax,-0x20(%ebp)
	uintptr_t va_ptr, vend_ptr;
	physaddr_t pa_ptr;
	pte_t *ppte;
	vend_ptr = va + size;
	if (size > (unsigned)0xffffffff - vend_ptr + 1) vend_ptr = ROUNDUP(0xfffff000, PGSIZE);
	for (va_ptr = va, pa_ptr = pa; va_ptr != vend_ptr; va_ptr += PGSIZE, pa_ptr += PGSIZE) {
f0101404:	eb 4d                	jmp    f0101453 <boot_map_region+0x7b>
		ppte = pgdir_walk(pgdir, (void *)va_ptr, 1);
f0101406:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010140d:	00 
f010140e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101412:	89 3c 24             	mov    %edi,(%esp)
f0101415:	e8 1f ff ff ff       	call   f0101339 <pgdir_walk>
		if (!ppte) panic("boot_map_region: cannot find valid page!");
f010141a:	85 c0                	test   %eax,%eax
f010141c:	75 1c                	jne    f010143a <boot_map_region+0x62>
f010141e:	c7 44 24 08 08 77 10 	movl   $0xf0107708,0x8(%esp)
f0101425:	f0 
f0101426:	c7 44 24 04 c2 01 00 	movl   $0x1c2,0x4(%esp)
f010142d:	00 
f010142e:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101435:	e8 06 ec ff ff       	call   f0100040 <_panic>
		*ppte = PTE_ADDR(pa_ptr) | perm | PTE_P;
f010143a:	89 f2                	mov    %esi,%edx
f010143c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101442:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101445:	89 10                	mov    %edx,(%eax)
	uintptr_t va_ptr, vend_ptr;
	physaddr_t pa_ptr;
	pte_t *ppte;
	vend_ptr = va + size;
	if (size > (unsigned)0xffffffff - vend_ptr + 1) vend_ptr = ROUNDUP(0xfffff000, PGSIZE);
	for (va_ptr = va, pa_ptr = pa; va_ptr != vend_ptr; va_ptr += PGSIZE, pa_ptr += PGSIZE) {
f0101447:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010144d:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101453:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101456:	75 ae                	jne    f0101406 <boot_map_region+0x2e>
		ppte = pgdir_walk(pgdir, (void *)va_ptr, 1);
		if (!ppte) panic("boot_map_region: cannot find valid page!");
		*ppte = PTE_ADDR(pa_ptr) | perm | PTE_P;
	}
	return;
}
f0101458:	83 c4 2c             	add    $0x2c,%esp
f010145b:	5b                   	pop    %ebx
f010145c:	5e                   	pop    %esi
f010145d:	5f                   	pop    %edi
f010145e:	5d                   	pop    %ebp
f010145f:	c3                   	ret    

f0101460 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101460:	55                   	push   %ebp
f0101461:	89 e5                	mov    %esp,%ebp
f0101463:	53                   	push   %ebx
f0101464:	83 ec 14             	sub    $0x14,%esp
f0101467:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *ppte = pgdir_walk(pgdir, va, 0);
f010146a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101471:	00 
f0101472:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101475:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101479:	8b 45 08             	mov    0x8(%ebp),%eax
f010147c:	89 04 24             	mov    %eax,(%esp)
f010147f:	e8 b5 fe ff ff       	call   f0101339 <pgdir_walk>
	if (pte_store) *pte_store = ppte;
f0101484:	85 db                	test   %ebx,%ebx
f0101486:	74 02                	je     f010148a <page_lookup+0x2a>
f0101488:	89 03                	mov    %eax,(%ebx)
	if (!ppte || !(*ppte & PTE_P)) return NULL;
f010148a:	85 c0                	test   %eax,%eax
f010148c:	74 38                	je     f01014c6 <page_lookup+0x66>
f010148e:	8b 00                	mov    (%eax),%eax
f0101490:	a8 01                	test   $0x1,%al
f0101492:	74 39                	je     f01014cd <page_lookup+0x6d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101494:	c1 e8 0c             	shr    $0xc,%eax
f0101497:	3b 05 88 2e 33 f0    	cmp    0xf0332e88,%eax
f010149d:	72 1c                	jb     f01014bb <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f010149f:	c7 44 24 08 34 77 10 	movl   $0xf0107734,0x8(%esp)
f01014a6:	f0 
f01014a7:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01014ae:	00 
f01014af:	c7 04 24 a1 7f 10 f0 	movl   $0xf0107fa1,(%esp)
f01014b6:	e8 85 eb ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01014bb:	c1 e0 03             	shl    $0x3,%eax
f01014be:	03 05 90 2e 33 f0    	add    0xf0332e90,%eax
	return pa2page(PTE_ADDR(*ppte));
f01014c4:	eb 0c                	jmp    f01014d2 <page_lookup+0x72>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *ppte = pgdir_walk(pgdir, va, 0);
	if (pte_store) *pte_store = ppte;
	if (!ppte || !(*ppte & PTE_P)) return NULL;
f01014c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01014cb:	eb 05                	jmp    f01014d2 <page_lookup+0x72>
f01014cd:	b8 00 00 00 00       	mov    $0x0,%eax
	return pa2page(PTE_ADDR(*ppte));
}
f01014d2:	83 c4 14             	add    $0x14,%esp
f01014d5:	5b                   	pop    %ebx
f01014d6:	5d                   	pop    %ebp
f01014d7:	c3                   	ret    

f01014d8 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01014d8:	55                   	push   %ebp
f01014d9:	89 e5                	mov    %esp,%ebp
f01014db:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01014de:	e8 41 52 00 00       	call   f0106724 <cpunum>
f01014e3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01014ea:	29 c2                	sub    %eax,%edx
f01014ec:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01014ef:	83 3c 85 28 30 33 f0 	cmpl   $0x0,-0xfcccfd8(,%eax,4)
f01014f6:	00 
f01014f7:	74 20                	je     f0101519 <tlb_invalidate+0x41>
f01014f9:	e8 26 52 00 00       	call   f0106724 <cpunum>
f01014fe:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101505:	29 c2                	sub    %eax,%edx
f0101507:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010150a:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0101511:	8b 55 08             	mov    0x8(%ebp),%edx
f0101514:	39 50 60             	cmp    %edx,0x60(%eax)
f0101517:	75 06                	jne    f010151f <tlb_invalidate+0x47>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101519:	8b 45 0c             	mov    0xc(%ebp),%eax
f010151c:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f010151f:	c9                   	leave  
f0101520:	c3                   	ret    

f0101521 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101521:	55                   	push   %ebp
f0101522:	89 e5                	mov    %esp,%ebp
f0101524:	56                   	push   %esi
f0101525:	53                   	push   %ebx
f0101526:	83 ec 20             	sub    $0x20,%esp
f0101529:	8b 75 08             	mov    0x8(%ebp),%esi
f010152c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *ppte;
	struct PageInfo *pp;
	pp = page_lookup(pgdir, va, &ppte);
f010152f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101532:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101536:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010153a:	89 34 24             	mov    %esi,(%esp)
f010153d:	e8 1e ff ff ff       	call   f0101460 <page_lookup>
	if (!pp || !(*ppte & PTE_P)) return;
f0101542:	85 c0                	test   %eax,%eax
f0101544:	74 25                	je     f010156b <page_remove+0x4a>
f0101546:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101549:	f6 02 01             	testb  $0x1,(%edx)
f010154c:	74 1d                	je     f010156b <page_remove+0x4a>
	page_decref(pp);
f010154e:	89 04 24             	mov    %eax,(%esp)
f0101551:	e8 c3 fd ff ff       	call   f0101319 <page_decref>
	*ppte = 0;
f0101556:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101559:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f010155f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101563:	89 34 24             	mov    %esi,(%esp)
f0101566:	e8 6d ff ff ff       	call   f01014d8 <tlb_invalidate>
}
f010156b:	83 c4 20             	add    $0x20,%esp
f010156e:	5b                   	pop    %ebx
f010156f:	5e                   	pop    %esi
f0101570:	5d                   	pop    %ebp
f0101571:	c3                   	ret    

f0101572 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101572:	55                   	push   %ebp
f0101573:	89 e5                	mov    %esp,%ebp
f0101575:	57                   	push   %edi
f0101576:	56                   	push   %esi
f0101577:	53                   	push   %ebx
f0101578:	83 ec 1c             	sub    $0x1c,%esp
f010157b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010157e:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *ppte = pgdir_walk(pgdir, va, 1);
f0101581:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101588:	00 
f0101589:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010158d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101590:	89 04 24             	mov    %eax,(%esp)
f0101593:	e8 a1 fd ff ff       	call   f0101339 <pgdir_walk>
f0101598:	89 c3                	mov    %eax,%ebx
	if (!ppte) return -E_NO_MEM;
f010159a:	85 c0                	test   %eax,%eax
f010159c:	74 39                	je     f01015d7 <page_insert+0x65>
	pp->pp_ref++;
f010159e:	66 ff 46 04          	incw   0x4(%esi)
	if (*ppte & PTE_P) {
f01015a2:	f6 00 01             	testb  $0x1,(%eax)
f01015a5:	74 0f                	je     f01015b6 <page_insert+0x44>
		page_remove(pgdir, va);
f01015a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01015ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01015ae:	89 04 24             	mov    %eax,(%esp)
f01015b1:	e8 6b ff ff ff       	call   f0101521 <page_remove>
	}
	*ppte = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
f01015b6:	8b 55 14             	mov    0x14(%ebp),%edx
f01015b9:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015bc:	2b 35 90 2e 33 f0    	sub    0xf0332e90,%esi
f01015c2:	c1 fe 03             	sar    $0x3,%esi
f01015c5:	89 f0                	mov    %esi,%eax
f01015c7:	c1 e0 0c             	shl    $0xc,%eax
f01015ca:	89 d6                	mov    %edx,%esi
f01015cc:	09 c6                	or     %eax,%esi
f01015ce:	89 33                	mov    %esi,(%ebx)
	return 0;
f01015d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01015d5:	eb 05                	jmp    f01015dc <page_insert+0x6a>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t *ppte = pgdir_walk(pgdir, va, 1);
	if (!ppte) return -E_NO_MEM;
f01015d7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	if (*ppte & PTE_P) {
		page_remove(pgdir, va);
	}
	*ppte = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
	return 0;
}
f01015dc:	83 c4 1c             	add    $0x1c,%esp
f01015df:	5b                   	pop    %ebx
f01015e0:	5e                   	pop    %esi
f01015e1:	5f                   	pop    %edi
f01015e2:	5d                   	pop    %ebp
f01015e3:	c3                   	ret    

f01015e4 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01015e4:	55                   	push   %ebp
f01015e5:	89 e5                	mov    %esp,%ebp
f01015e7:	53                   	push   %ebx
f01015e8:	83 ec 14             	sub    $0x14,%esp
f01015eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	if (base + size > MMIOLIM)
f01015ee:	8b 15 00 a3 12 f0    	mov    0xf012a300,%edx
f01015f4:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f01015f7:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01015fc:	76 1c                	jbe    f010161a <mmio_map_region+0x36>
		panic("mmio_map_region: too big for MMIOLIM!");
f01015fe:	c7 44 24 08 54 77 10 	movl   $0xf0107754,0x8(%esp)
f0101605:	f0 
f0101606:	c7 44 24 04 4d 02 00 	movl   $0x24d,0x4(%esp)
f010160d:	00 
f010160e:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101615:	e8 26 ea ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, base, ROUNDUP(size, PGSIZE), pa, PTE_PCD | PTE_PWT | PTE_W);
f010161a:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f0101620:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0101626:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f010162d:	00 
f010162e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101631:	89 04 24             	mov    %eax,(%esp)
f0101634:	89 d9                	mov    %ebx,%ecx
f0101636:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f010163b:	e8 98 fd ff ff       	call   f01013d8 <boot_map_region>
	base += ROUNDUP(size, PGSIZE);
f0101640:	a1 00 a3 12 f0       	mov    0xf012a300,%eax
f0101645:	01 c3                	add    %eax,%ebx
f0101647:	89 1d 00 a3 12 f0    	mov    %ebx,0xf012a300
	return (void *)(base-ROUNDUP(size, PGSIZE));
}
f010164d:	83 c4 14             	add    $0x14,%esp
f0101650:	5b                   	pop    %ebx
f0101651:	5d                   	pop    %ebp
f0101652:	c3                   	ret    

f0101653 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101653:	55                   	push   %ebp
f0101654:	89 e5                	mov    %esp,%ebp
f0101656:	57                   	push   %edi
f0101657:	56                   	push   %esi
f0101658:	53                   	push   %ebx
f0101659:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010165c:	b8 15 00 00 00       	mov    $0x15,%eax
f0101661:	e8 69 f7 ff ff       	call   f0100dcf <nvram_read>
f0101666:	c1 e0 0a             	shl    $0xa,%eax
f0101669:	89 c2                	mov    %eax,%edx
f010166b:	85 c0                	test   %eax,%eax
f010166d:	79 06                	jns    f0101675 <mem_init+0x22>
f010166f:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101675:	c1 fa 0c             	sar    $0xc,%edx
f0101678:	89 15 38 22 33 f0    	mov    %edx,0xf0332238
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010167e:	b8 17 00 00 00       	mov    $0x17,%eax
f0101683:	e8 47 f7 ff ff       	call   f0100dcf <nvram_read>
f0101688:	89 c2                	mov    %eax,%edx
f010168a:	c1 e2 0a             	shl    $0xa,%edx
f010168d:	89 d0                	mov    %edx,%eax
f010168f:	85 d2                	test   %edx,%edx
f0101691:	79 06                	jns    f0101699 <mem_init+0x46>
f0101693:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101699:	c1 f8 0c             	sar    $0xc,%eax
f010169c:	74 0e                	je     f01016ac <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010169e:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01016a4:	89 15 88 2e 33 f0    	mov    %edx,0xf0332e88
f01016aa:	eb 0c                	jmp    f01016b8 <mem_init+0x65>
	else
		npages = npages_basemem;
f01016ac:	8b 15 38 22 33 f0    	mov    0xf0332238,%edx
f01016b2:	89 15 88 2e 33 f0    	mov    %edx,0xf0332e88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f01016b8:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01016bb:	c1 e8 0a             	shr    $0xa,%eax
f01016be:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01016c2:	a1 38 22 33 f0       	mov    0xf0332238,%eax
f01016c7:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01016ca:	c1 e8 0a             	shr    $0xa,%eax
f01016cd:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01016d1:	a1 88 2e 33 f0       	mov    0xf0332e88,%eax
f01016d6:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01016d9:	c1 e8 0a             	shr    $0xa,%eax
f01016dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01016e0:	c7 04 24 7c 77 10 f0 	movl   $0xf010777c,(%esp)
f01016e7:	e8 b6 2a 00 00       	call   f01041a2 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01016ec:	b8 00 10 00 00       	mov    $0x1000,%eax
f01016f1:	e8 1e f6 ff ff       	call   f0100d14 <boot_alloc>
f01016f6:	a3 8c 2e 33 f0       	mov    %eax,0xf0332e8c
	memset(kern_pgdir, 0, PGSIZE);
f01016fb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101702:	00 
f0101703:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010170a:	00 
f010170b:	89 04 24             	mov    %eax,(%esp)
f010170e:	e8 e3 49 00 00       	call   f01060f6 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101713:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101718:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010171d:	77 20                	ja     f010173f <mem_init+0xec>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010171f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101723:	c7 44 24 08 24 6e 10 	movl   $0xf0106e24,0x8(%esp)
f010172a:	f0 
f010172b:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
f0101732:	00 
f0101733:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f010173a:	e8 01 e9 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010173f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101745:	83 ca 05             	or     $0x5,%edx
f0101748:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo) * npages);
f010174e:	a1 88 2e 33 f0       	mov    0xf0332e88,%eax
f0101753:	c1 e0 03             	shl    $0x3,%eax
f0101756:	e8 b9 f5 ff ff       	call   f0100d14 <boot_alloc>
f010175b:	a3 90 2e 33 f0       	mov    %eax,0xf0332e90
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f0101760:	8b 15 88 2e 33 f0    	mov    0xf0332e88,%edx
f0101766:	c1 e2 03             	shl    $0x3,%edx
f0101769:	89 54 24 08          	mov    %edx,0x8(%esp)
f010176d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101774:	00 
f0101775:	89 04 24             	mov    %eax,(%esp)
f0101778:	e8 79 49 00 00       	call   f01060f6 <memset>


	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(sizeof(struct Env) * NENV);
f010177d:	b8 00 b0 02 00       	mov    $0x2b000,%eax
f0101782:	e8 8d f5 ff ff       	call   f0100d14 <boot_alloc>
f0101787:	a3 48 22 33 f0       	mov    %eax,0xf0332248
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010178c:	e8 ba f9 ff ff       	call   f010114b <page_init>

	check_page_free_list(1);
f0101791:	b8 01 00 00 00       	mov    $0x1,%eax
f0101796:	e8 5d f6 ff ff       	call   f0100df8 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010179b:	83 3d 90 2e 33 f0 00 	cmpl   $0x0,0xf0332e90
f01017a2:	75 1c                	jne    f01017c0 <mem_init+0x16d>
		panic("'pages' is a null pointer!");
f01017a4:	c7 44 24 08 68 80 10 	movl   $0xf0108068,0x8(%esp)
f01017ab:	f0 
f01017ac:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f01017b3:	00 
f01017b4:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01017bb:	e8 80 e8 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01017c0:	a1 40 22 33 f0       	mov    0xf0332240,%eax
f01017c5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01017ca:	eb 03                	jmp    f01017cf <mem_init+0x17c>
		++nfree;
f01017cc:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01017cd:	8b 00                	mov    (%eax),%eax
f01017cf:	85 c0                	test   %eax,%eax
f01017d1:	75 f9                	jne    f01017cc <mem_init+0x179>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017da:	e8 5a fa ff ff       	call   f0101239 <page_alloc>
f01017df:	89 c6                	mov    %eax,%esi
f01017e1:	85 c0                	test   %eax,%eax
f01017e3:	75 24                	jne    f0101809 <mem_init+0x1b6>
f01017e5:	c7 44 24 0c 83 80 10 	movl   $0xf0108083,0xc(%esp)
f01017ec:	f0 
f01017ed:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01017f4:	f0 
f01017f5:	c7 44 24 04 e0 02 00 	movl   $0x2e0,0x4(%esp)
f01017fc:	00 
f01017fd:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101804:	e8 37 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101809:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101810:	e8 24 fa ff ff       	call   f0101239 <page_alloc>
f0101815:	89 c7                	mov    %eax,%edi
f0101817:	85 c0                	test   %eax,%eax
f0101819:	75 24                	jne    f010183f <mem_init+0x1ec>
f010181b:	c7 44 24 0c 99 80 10 	movl   $0xf0108099,0xc(%esp)
f0101822:	f0 
f0101823:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010182a:	f0 
f010182b:	c7 44 24 04 e1 02 00 	movl   $0x2e1,0x4(%esp)
f0101832:	00 
f0101833:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f010183a:	e8 01 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010183f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101846:	e8 ee f9 ff ff       	call   f0101239 <page_alloc>
f010184b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010184e:	85 c0                	test   %eax,%eax
f0101850:	75 24                	jne    f0101876 <mem_init+0x223>
f0101852:	c7 44 24 0c af 80 10 	movl   $0xf01080af,0xc(%esp)
f0101859:	f0 
f010185a:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101861:	f0 
f0101862:	c7 44 24 04 e2 02 00 	movl   $0x2e2,0x4(%esp)
f0101869:	00 
f010186a:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101871:	e8 ca e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101876:	39 fe                	cmp    %edi,%esi
f0101878:	75 24                	jne    f010189e <mem_init+0x24b>
f010187a:	c7 44 24 0c c5 80 10 	movl   $0xf01080c5,0xc(%esp)
f0101881:	f0 
f0101882:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101889:	f0 
f010188a:	c7 44 24 04 e5 02 00 	movl   $0x2e5,0x4(%esp)
f0101891:	00 
f0101892:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101899:	e8 a2 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010189e:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01018a1:	74 05                	je     f01018a8 <mem_init+0x255>
f01018a3:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01018a6:	75 24                	jne    f01018cc <mem_init+0x279>
f01018a8:	c7 44 24 0c b8 77 10 	movl   $0xf01077b8,0xc(%esp)
f01018af:	f0 
f01018b0:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01018b7:	f0 
f01018b8:	c7 44 24 04 e6 02 00 	movl   $0x2e6,0x4(%esp)
f01018bf:	00 
f01018c0:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01018c7:	e8 74 e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018cc:	8b 15 90 2e 33 f0    	mov    0xf0332e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01018d2:	a1 88 2e 33 f0       	mov    0xf0332e88,%eax
f01018d7:	c1 e0 0c             	shl    $0xc,%eax
f01018da:	89 f1                	mov    %esi,%ecx
f01018dc:	29 d1                	sub    %edx,%ecx
f01018de:	c1 f9 03             	sar    $0x3,%ecx
f01018e1:	c1 e1 0c             	shl    $0xc,%ecx
f01018e4:	39 c1                	cmp    %eax,%ecx
f01018e6:	72 24                	jb     f010190c <mem_init+0x2b9>
f01018e8:	c7 44 24 0c d7 80 10 	movl   $0xf01080d7,0xc(%esp)
f01018ef:	f0 
f01018f0:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01018f7:	f0 
f01018f8:	c7 44 24 04 e7 02 00 	movl   $0x2e7,0x4(%esp)
f01018ff:	00 
f0101900:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101907:	e8 34 e7 ff ff       	call   f0100040 <_panic>
f010190c:	89 f9                	mov    %edi,%ecx
f010190e:	29 d1                	sub    %edx,%ecx
f0101910:	c1 f9 03             	sar    $0x3,%ecx
f0101913:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101916:	39 c8                	cmp    %ecx,%eax
f0101918:	77 24                	ja     f010193e <mem_init+0x2eb>
f010191a:	c7 44 24 0c f4 80 10 	movl   $0xf01080f4,0xc(%esp)
f0101921:	f0 
f0101922:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101929:	f0 
f010192a:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0101931:	00 
f0101932:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101939:	e8 02 e7 ff ff       	call   f0100040 <_panic>
f010193e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101941:	29 d1                	sub    %edx,%ecx
f0101943:	89 ca                	mov    %ecx,%edx
f0101945:	c1 fa 03             	sar    $0x3,%edx
f0101948:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010194b:	39 d0                	cmp    %edx,%eax
f010194d:	77 24                	ja     f0101973 <mem_init+0x320>
f010194f:	c7 44 24 0c 11 81 10 	movl   $0xf0108111,0xc(%esp)
f0101956:	f0 
f0101957:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010195e:	f0 
f010195f:	c7 44 24 04 e9 02 00 	movl   $0x2e9,0x4(%esp)
f0101966:	00 
f0101967:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f010196e:	e8 cd e6 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101973:	a1 40 22 33 f0       	mov    0xf0332240,%eax
f0101978:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010197b:	c7 05 40 22 33 f0 00 	movl   $0x0,0xf0332240
f0101982:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101985:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010198c:	e8 a8 f8 ff ff       	call   f0101239 <page_alloc>
f0101991:	85 c0                	test   %eax,%eax
f0101993:	74 24                	je     f01019b9 <mem_init+0x366>
f0101995:	c7 44 24 0c 2e 81 10 	movl   $0xf010812e,0xc(%esp)
f010199c:	f0 
f010199d:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01019a4:	f0 
f01019a5:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f01019ac:	00 
f01019ad:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01019b4:	e8 87 e6 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01019b9:	89 34 24             	mov    %esi,(%esp)
f01019bc:	e8 fc f8 ff ff       	call   f01012bd <page_free>
	page_free(pp1);
f01019c1:	89 3c 24             	mov    %edi,(%esp)
f01019c4:	e8 f4 f8 ff ff       	call   f01012bd <page_free>
	page_free(pp2);
f01019c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019cc:	89 04 24             	mov    %eax,(%esp)
f01019cf:	e8 e9 f8 ff ff       	call   f01012bd <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01019d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019db:	e8 59 f8 ff ff       	call   f0101239 <page_alloc>
f01019e0:	89 c6                	mov    %eax,%esi
f01019e2:	85 c0                	test   %eax,%eax
f01019e4:	75 24                	jne    f0101a0a <mem_init+0x3b7>
f01019e6:	c7 44 24 0c 83 80 10 	movl   $0xf0108083,0xc(%esp)
f01019ed:	f0 
f01019ee:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01019f5:	f0 
f01019f6:	c7 44 24 04 f7 02 00 	movl   $0x2f7,0x4(%esp)
f01019fd:	00 
f01019fe:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101a05:	e8 36 e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a11:	e8 23 f8 ff ff       	call   f0101239 <page_alloc>
f0101a16:	89 c7                	mov    %eax,%edi
f0101a18:	85 c0                	test   %eax,%eax
f0101a1a:	75 24                	jne    f0101a40 <mem_init+0x3ed>
f0101a1c:	c7 44 24 0c 99 80 10 	movl   $0xf0108099,0xc(%esp)
f0101a23:	f0 
f0101a24:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101a2b:	f0 
f0101a2c:	c7 44 24 04 f8 02 00 	movl   $0x2f8,0x4(%esp)
f0101a33:	00 
f0101a34:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101a3b:	e8 00 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a47:	e8 ed f7 ff ff       	call   f0101239 <page_alloc>
f0101a4c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a4f:	85 c0                	test   %eax,%eax
f0101a51:	75 24                	jne    f0101a77 <mem_init+0x424>
f0101a53:	c7 44 24 0c af 80 10 	movl   $0xf01080af,0xc(%esp)
f0101a5a:	f0 
f0101a5b:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101a62:	f0 
f0101a63:	c7 44 24 04 f9 02 00 	movl   $0x2f9,0x4(%esp)
f0101a6a:	00 
f0101a6b:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101a72:	e8 c9 e5 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a77:	39 fe                	cmp    %edi,%esi
f0101a79:	75 24                	jne    f0101a9f <mem_init+0x44c>
f0101a7b:	c7 44 24 0c c5 80 10 	movl   $0xf01080c5,0xc(%esp)
f0101a82:	f0 
f0101a83:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101a8a:	f0 
f0101a8b:	c7 44 24 04 fb 02 00 	movl   $0x2fb,0x4(%esp)
f0101a92:	00 
f0101a93:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101a9a:	e8 a1 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a9f:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101aa2:	74 05                	je     f0101aa9 <mem_init+0x456>
f0101aa4:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101aa7:	75 24                	jne    f0101acd <mem_init+0x47a>
f0101aa9:	c7 44 24 0c b8 77 10 	movl   $0xf01077b8,0xc(%esp)
f0101ab0:	f0 
f0101ab1:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101ab8:	f0 
f0101ab9:	c7 44 24 04 fc 02 00 	movl   $0x2fc,0x4(%esp)
f0101ac0:	00 
f0101ac1:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101ac8:	e8 73 e5 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101acd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ad4:	e8 60 f7 ff ff       	call   f0101239 <page_alloc>
f0101ad9:	85 c0                	test   %eax,%eax
f0101adb:	74 24                	je     f0101b01 <mem_init+0x4ae>
f0101add:	c7 44 24 0c 2e 81 10 	movl   $0xf010812e,0xc(%esp)
f0101ae4:	f0 
f0101ae5:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101aec:	f0 
f0101aed:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f0101af4:	00 
f0101af5:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101afc:	e8 3f e5 ff ff       	call   f0100040 <_panic>
f0101b01:	89 f0                	mov    %esi,%eax
f0101b03:	2b 05 90 2e 33 f0    	sub    0xf0332e90,%eax
f0101b09:	c1 f8 03             	sar    $0x3,%eax
f0101b0c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b0f:	89 c2                	mov    %eax,%edx
f0101b11:	c1 ea 0c             	shr    $0xc,%edx
f0101b14:	3b 15 88 2e 33 f0    	cmp    0xf0332e88,%edx
f0101b1a:	72 20                	jb     f0101b3c <mem_init+0x4e9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101b20:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f0101b27:	f0 
f0101b28:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101b2f:	00 
f0101b30:	c7 04 24 a1 7f 10 f0 	movl   $0xf0107fa1,(%esp)
f0101b37:	e8 04 e5 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101b3c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101b43:	00 
f0101b44:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101b4b:	00 
	return (void *)(pa + KERNBASE);
f0101b4c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b51:	89 04 24             	mov    %eax,(%esp)
f0101b54:	e8 9d 45 00 00       	call   f01060f6 <memset>
	page_free(pp0);
f0101b59:	89 34 24             	mov    %esi,(%esp)
f0101b5c:	e8 5c f7 ff ff       	call   f01012bd <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101b61:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101b68:	e8 cc f6 ff ff       	call   f0101239 <page_alloc>
f0101b6d:	85 c0                	test   %eax,%eax
f0101b6f:	75 24                	jne    f0101b95 <mem_init+0x542>
f0101b71:	c7 44 24 0c 3d 81 10 	movl   $0xf010813d,0xc(%esp)
f0101b78:	f0 
f0101b79:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101b80:	f0 
f0101b81:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f0101b88:	00 
f0101b89:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101b90:	e8 ab e4 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101b95:	39 c6                	cmp    %eax,%esi
f0101b97:	74 24                	je     f0101bbd <mem_init+0x56a>
f0101b99:	c7 44 24 0c 5b 81 10 	movl   $0xf010815b,0xc(%esp)
f0101ba0:	f0 
f0101ba1:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101ba8:	f0 
f0101ba9:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f0101bb0:	00 
f0101bb1:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101bb8:	e8 83 e4 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101bbd:	89 f2                	mov    %esi,%edx
f0101bbf:	2b 15 90 2e 33 f0    	sub    0xf0332e90,%edx
f0101bc5:	c1 fa 03             	sar    $0x3,%edx
f0101bc8:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101bcb:	89 d0                	mov    %edx,%eax
f0101bcd:	c1 e8 0c             	shr    $0xc,%eax
f0101bd0:	3b 05 88 2e 33 f0    	cmp    0xf0332e88,%eax
f0101bd6:	72 20                	jb     f0101bf8 <mem_init+0x5a5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101bd8:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101bdc:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f0101be3:	f0 
f0101be4:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101beb:	00 
f0101bec:	c7 04 24 a1 7f 10 f0 	movl   $0xf0107fa1,(%esp)
f0101bf3:	e8 48 e4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101bf8:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101bfe:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101c04:	80 38 00             	cmpb   $0x0,(%eax)
f0101c07:	74 24                	je     f0101c2d <mem_init+0x5da>
f0101c09:	c7 44 24 0c 6b 81 10 	movl   $0xf010816b,0xc(%esp)
f0101c10:	f0 
f0101c11:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101c18:	f0 
f0101c19:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f0101c20:	00 
f0101c21:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101c28:	e8 13 e4 ff ff       	call   f0100040 <_panic>
f0101c2d:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101c2e:	39 d0                	cmp    %edx,%eax
f0101c30:	75 d2                	jne    f0101c04 <mem_init+0x5b1>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101c32:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101c35:	89 15 40 22 33 f0    	mov    %edx,0xf0332240

	// free the pages we took
	page_free(pp0);
f0101c3b:	89 34 24             	mov    %esi,(%esp)
f0101c3e:	e8 7a f6 ff ff       	call   f01012bd <page_free>
	page_free(pp1);
f0101c43:	89 3c 24             	mov    %edi,(%esp)
f0101c46:	e8 72 f6 ff ff       	call   f01012bd <page_free>
	page_free(pp2);
f0101c4b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c4e:	89 04 24             	mov    %eax,(%esp)
f0101c51:	e8 67 f6 ff ff       	call   f01012bd <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101c56:	a1 40 22 33 f0       	mov    0xf0332240,%eax
f0101c5b:	eb 03                	jmp    f0101c60 <mem_init+0x60d>
		--nfree;
f0101c5d:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101c5e:	8b 00                	mov    (%eax),%eax
f0101c60:	85 c0                	test   %eax,%eax
f0101c62:	75 f9                	jne    f0101c5d <mem_init+0x60a>
		--nfree;
	assert(nfree == 0);
f0101c64:	85 db                	test   %ebx,%ebx
f0101c66:	74 24                	je     f0101c8c <mem_init+0x639>
f0101c68:	c7 44 24 0c 75 81 10 	movl   $0xf0108175,0xc(%esp)
f0101c6f:	f0 
f0101c70:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101c77:	f0 
f0101c78:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f0101c7f:	00 
f0101c80:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101c87:	e8 b4 e3 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101c8c:	c7 04 24 d8 77 10 f0 	movl   $0xf01077d8,(%esp)
f0101c93:	e8 0a 25 00 00       	call   f01041a2 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c9f:	e8 95 f5 ff ff       	call   f0101239 <page_alloc>
f0101ca4:	89 c7                	mov    %eax,%edi
f0101ca6:	85 c0                	test   %eax,%eax
f0101ca8:	75 24                	jne    f0101cce <mem_init+0x67b>
f0101caa:	c7 44 24 0c 83 80 10 	movl   $0xf0108083,0xc(%esp)
f0101cb1:	f0 
f0101cb2:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101cb9:	f0 
f0101cba:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0101cc1:	00 
f0101cc2:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101cc9:	e8 72 e3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101cce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cd5:	e8 5f f5 ff ff       	call   f0101239 <page_alloc>
f0101cda:	89 c6                	mov    %eax,%esi
f0101cdc:	85 c0                	test   %eax,%eax
f0101cde:	75 24                	jne    f0101d04 <mem_init+0x6b1>
f0101ce0:	c7 44 24 0c 99 80 10 	movl   $0xf0108099,0xc(%esp)
f0101ce7:	f0 
f0101ce8:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101cef:	f0 
f0101cf0:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0101cf7:	00 
f0101cf8:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101cff:	e8 3c e3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101d04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d0b:	e8 29 f5 ff ff       	call   f0101239 <page_alloc>
f0101d10:	89 c3                	mov    %eax,%ebx
f0101d12:	85 c0                	test   %eax,%eax
f0101d14:	75 24                	jne    f0101d3a <mem_init+0x6e7>
f0101d16:	c7 44 24 0c af 80 10 	movl   $0xf01080af,0xc(%esp)
f0101d1d:	f0 
f0101d1e:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101d25:	f0 
f0101d26:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0101d2d:	00 
f0101d2e:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101d35:	e8 06 e3 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101d3a:	39 f7                	cmp    %esi,%edi
f0101d3c:	75 24                	jne    f0101d62 <mem_init+0x70f>
f0101d3e:	c7 44 24 0c c5 80 10 	movl   $0xf01080c5,0xc(%esp)
f0101d45:	f0 
f0101d46:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101d4d:	f0 
f0101d4e:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0101d55:	00 
f0101d56:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101d5d:	e8 de e2 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d62:	39 c6                	cmp    %eax,%esi
f0101d64:	74 04                	je     f0101d6a <mem_init+0x717>
f0101d66:	39 c7                	cmp    %eax,%edi
f0101d68:	75 24                	jne    f0101d8e <mem_init+0x73b>
f0101d6a:	c7 44 24 0c b8 77 10 	movl   $0xf01077b8,0xc(%esp)
f0101d71:	f0 
f0101d72:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101d79:	f0 
f0101d7a:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0101d81:	00 
f0101d82:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101d89:	e8 b2 e2 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101d8e:	8b 15 40 22 33 f0    	mov    0xf0332240,%edx
f0101d94:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101d97:	c7 05 40 22 33 f0 00 	movl   $0x0,0xf0332240
f0101d9e:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101da1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101da8:	e8 8c f4 ff ff       	call   f0101239 <page_alloc>
f0101dad:	85 c0                	test   %eax,%eax
f0101daf:	74 24                	je     f0101dd5 <mem_init+0x782>
f0101db1:	c7 44 24 0c 2e 81 10 	movl   $0xf010812e,0xc(%esp)
f0101db8:	f0 
f0101db9:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101dc0:	f0 
f0101dc1:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f0101dc8:	00 
f0101dc9:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101dd0:	e8 6b e2 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101dd5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101dd8:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101ddc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101de3:	00 
f0101de4:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0101de9:	89 04 24             	mov    %eax,(%esp)
f0101dec:	e8 6f f6 ff ff       	call   f0101460 <page_lookup>
f0101df1:	85 c0                	test   %eax,%eax
f0101df3:	74 24                	je     f0101e19 <mem_init+0x7c6>
f0101df5:	c7 44 24 0c f8 77 10 	movl   $0xf01077f8,0xc(%esp)
f0101dfc:	f0 
f0101dfd:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101e04:	f0 
f0101e05:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0101e0c:	00 
f0101e0d:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101e14:	e8 27 e2 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101e19:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e20:	00 
f0101e21:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e28:	00 
f0101e29:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e2d:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0101e32:	89 04 24             	mov    %eax,(%esp)
f0101e35:	e8 38 f7 ff ff       	call   f0101572 <page_insert>
f0101e3a:	85 c0                	test   %eax,%eax
f0101e3c:	78 24                	js     f0101e62 <mem_init+0x80f>
f0101e3e:	c7 44 24 0c 30 78 10 	movl   $0xf0107830,0xc(%esp)
f0101e45:	f0 
f0101e46:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101e4d:	f0 
f0101e4e:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f0101e55:	00 
f0101e56:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101e5d:	e8 de e1 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101e62:	89 3c 24             	mov    %edi,(%esp)
f0101e65:	e8 53 f4 ff ff       	call   f01012bd <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101e6a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e71:	00 
f0101e72:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e79:	00 
f0101e7a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e7e:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0101e83:	89 04 24             	mov    %eax,(%esp)
f0101e86:	e8 e7 f6 ff ff       	call   f0101572 <page_insert>
f0101e8b:	85 c0                	test   %eax,%eax
f0101e8d:	74 24                	je     f0101eb3 <mem_init+0x860>
f0101e8f:	c7 44 24 0c 60 78 10 	movl   $0xf0107860,0xc(%esp)
f0101e96:	f0 
f0101e97:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101e9e:	f0 
f0101e9f:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0101ea6:	00 
f0101ea7:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101eae:	e8 8d e1 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101eb3:	8b 0d 8c 2e 33 f0    	mov    0xf0332e8c,%ecx
f0101eb9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ebc:	a1 90 2e 33 f0       	mov    0xf0332e90,%eax
f0101ec1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101ec4:	8b 11                	mov    (%ecx),%edx
f0101ec6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ecc:	89 f8                	mov    %edi,%eax
f0101ece:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101ed1:	c1 f8 03             	sar    $0x3,%eax
f0101ed4:	c1 e0 0c             	shl    $0xc,%eax
f0101ed7:	39 c2                	cmp    %eax,%edx
f0101ed9:	74 24                	je     f0101eff <mem_init+0x8ac>
f0101edb:	c7 44 24 0c 90 78 10 	movl   $0xf0107890,0xc(%esp)
f0101ee2:	f0 
f0101ee3:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101eea:	f0 
f0101eeb:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0101ef2:	00 
f0101ef3:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101efa:	e8 41 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101eff:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f07:	e8 56 ee ff ff       	call   f0100d62 <check_va2pa>
f0101f0c:	89 f2                	mov    %esi,%edx
f0101f0e:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101f11:	c1 fa 03             	sar    $0x3,%edx
f0101f14:	c1 e2 0c             	shl    $0xc,%edx
f0101f17:	39 d0                	cmp    %edx,%eax
f0101f19:	74 24                	je     f0101f3f <mem_init+0x8ec>
f0101f1b:	c7 44 24 0c b8 78 10 	movl   $0xf01078b8,0xc(%esp)
f0101f22:	f0 
f0101f23:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101f2a:	f0 
f0101f2b:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0101f32:	00 
f0101f33:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101f3a:	e8 01 e1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101f3f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f44:	74 24                	je     f0101f6a <mem_init+0x917>
f0101f46:	c7 44 24 0c 80 81 10 	movl   $0xf0108180,0xc(%esp)
f0101f4d:	f0 
f0101f4e:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101f55:	f0 
f0101f56:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f0101f5d:	00 
f0101f5e:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101f65:	e8 d6 e0 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101f6a:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101f6f:	74 24                	je     f0101f95 <mem_init+0x942>
f0101f71:	c7 44 24 0c 91 81 10 	movl   $0xf0108191,0xc(%esp)
f0101f78:	f0 
f0101f79:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101f80:	f0 
f0101f81:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0101f88:	00 
f0101f89:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101f90:	e8 ab e0 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f95:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f9c:	00 
f0101f9d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101fa4:	00 
f0101fa5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101fa9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101fac:	89 14 24             	mov    %edx,(%esp)
f0101faf:	e8 be f5 ff ff       	call   f0101572 <page_insert>
f0101fb4:	85 c0                	test   %eax,%eax
f0101fb6:	74 24                	je     f0101fdc <mem_init+0x989>
f0101fb8:	c7 44 24 0c e8 78 10 	movl   $0xf01078e8,0xc(%esp)
f0101fbf:	f0 
f0101fc0:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0101fc7:	f0 
f0101fc8:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0101fcf:	00 
f0101fd0:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0101fd7:	e8 64 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101fdc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fe1:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0101fe6:	e8 77 ed ff ff       	call   f0100d62 <check_va2pa>
f0101feb:	89 da                	mov    %ebx,%edx
f0101fed:	2b 15 90 2e 33 f0    	sub    0xf0332e90,%edx
f0101ff3:	c1 fa 03             	sar    $0x3,%edx
f0101ff6:	c1 e2 0c             	shl    $0xc,%edx
f0101ff9:	39 d0                	cmp    %edx,%eax
f0101ffb:	74 24                	je     f0102021 <mem_init+0x9ce>
f0101ffd:	c7 44 24 0c 24 79 10 	movl   $0xf0107924,0xc(%esp)
f0102004:	f0 
f0102005:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010200c:	f0 
f010200d:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f0102014:	00 
f0102015:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f010201c:	e8 1f e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102021:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102026:	74 24                	je     f010204c <mem_init+0x9f9>
f0102028:	c7 44 24 0c a2 81 10 	movl   $0xf01081a2,0xc(%esp)
f010202f:	f0 
f0102030:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102037:	f0 
f0102038:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f010203f:	00 
f0102040:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102047:	e8 f4 df ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010204c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102053:	e8 e1 f1 ff ff       	call   f0101239 <page_alloc>
f0102058:	85 c0                	test   %eax,%eax
f010205a:	74 24                	je     f0102080 <mem_init+0xa2d>
f010205c:	c7 44 24 0c 2e 81 10 	movl   $0xf010812e,0xc(%esp)
f0102063:	f0 
f0102064:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010206b:	f0 
f010206c:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f0102073:	00 
f0102074:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f010207b:	e8 c0 df ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102080:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102087:	00 
f0102088:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010208f:	00 
f0102090:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102094:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102099:	89 04 24             	mov    %eax,(%esp)
f010209c:	e8 d1 f4 ff ff       	call   f0101572 <page_insert>
f01020a1:	85 c0                	test   %eax,%eax
f01020a3:	74 24                	je     f01020c9 <mem_init+0xa76>
f01020a5:	c7 44 24 0c e8 78 10 	movl   $0xf01078e8,0xc(%esp)
f01020ac:	f0 
f01020ad:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01020b4:	f0 
f01020b5:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f01020bc:	00 
f01020bd:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01020c4:	e8 77 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020c9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020ce:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f01020d3:	e8 8a ec ff ff       	call   f0100d62 <check_va2pa>
f01020d8:	89 da                	mov    %ebx,%edx
f01020da:	2b 15 90 2e 33 f0    	sub    0xf0332e90,%edx
f01020e0:	c1 fa 03             	sar    $0x3,%edx
f01020e3:	c1 e2 0c             	shl    $0xc,%edx
f01020e6:	39 d0                	cmp    %edx,%eax
f01020e8:	74 24                	je     f010210e <mem_init+0xabb>
f01020ea:	c7 44 24 0c 24 79 10 	movl   $0xf0107924,0xc(%esp)
f01020f1:	f0 
f01020f2:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01020f9:	f0 
f01020fa:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f0102101:	00 
f0102102:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102109:	e8 32 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010210e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102113:	74 24                	je     f0102139 <mem_init+0xae6>
f0102115:	c7 44 24 0c a2 81 10 	movl   $0xf01081a2,0xc(%esp)
f010211c:	f0 
f010211d:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102124:	f0 
f0102125:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f010212c:	00 
f010212d:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102134:	e8 07 df ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102139:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102140:	e8 f4 f0 ff ff       	call   f0101239 <page_alloc>
f0102145:	85 c0                	test   %eax,%eax
f0102147:	74 24                	je     f010216d <mem_init+0xb1a>
f0102149:	c7 44 24 0c 2e 81 10 	movl   $0xf010812e,0xc(%esp)
f0102150:	f0 
f0102151:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102158:	f0 
f0102159:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f0102160:	00 
f0102161:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102168:	e8 d3 de ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010216d:	8b 15 8c 2e 33 f0    	mov    0xf0332e8c,%edx
f0102173:	8b 02                	mov    (%edx),%eax
f0102175:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010217a:	89 c1                	mov    %eax,%ecx
f010217c:	c1 e9 0c             	shr    $0xc,%ecx
f010217f:	3b 0d 88 2e 33 f0    	cmp    0xf0332e88,%ecx
f0102185:	72 20                	jb     f01021a7 <mem_init+0xb54>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102187:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010218b:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f0102192:	f0 
f0102193:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f010219a:	00 
f010219b:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01021a2:	e8 99 de ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01021a7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01021ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01021af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01021b6:	00 
f01021b7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021be:	00 
f01021bf:	89 14 24             	mov    %edx,(%esp)
f01021c2:	e8 72 f1 ff ff       	call   f0101339 <pgdir_walk>
f01021c7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01021ca:	83 c2 04             	add    $0x4,%edx
f01021cd:	39 d0                	cmp    %edx,%eax
f01021cf:	74 24                	je     f01021f5 <mem_init+0xba2>
f01021d1:	c7 44 24 0c 54 79 10 	movl   $0xf0107954,0xc(%esp)
f01021d8:	f0 
f01021d9:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01021e0:	f0 
f01021e1:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f01021e8:	00 
f01021e9:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01021f0:	e8 4b de ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01021f5:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01021fc:	00 
f01021fd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102204:	00 
f0102205:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102209:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f010220e:	89 04 24             	mov    %eax,(%esp)
f0102211:	e8 5c f3 ff ff       	call   f0101572 <page_insert>
f0102216:	85 c0                	test   %eax,%eax
f0102218:	74 24                	je     f010223e <mem_init+0xbeb>
f010221a:	c7 44 24 0c 94 79 10 	movl   $0xf0107994,0xc(%esp)
f0102221:	f0 
f0102222:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102229:	f0 
f010222a:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f0102231:	00 
f0102232:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102239:	e8 02 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010223e:	8b 0d 8c 2e 33 f0    	mov    0xf0332e8c,%ecx
f0102244:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102247:	ba 00 10 00 00       	mov    $0x1000,%edx
f010224c:	89 c8                	mov    %ecx,%eax
f010224e:	e8 0f eb ff ff       	call   f0100d62 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102253:	89 da                	mov    %ebx,%edx
f0102255:	2b 15 90 2e 33 f0    	sub    0xf0332e90,%edx
f010225b:	c1 fa 03             	sar    $0x3,%edx
f010225e:	c1 e2 0c             	shl    $0xc,%edx
f0102261:	39 d0                	cmp    %edx,%eax
f0102263:	74 24                	je     f0102289 <mem_init+0xc36>
f0102265:	c7 44 24 0c 24 79 10 	movl   $0xf0107924,0xc(%esp)
f010226c:	f0 
f010226d:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102274:	f0 
f0102275:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f010227c:	00 
f010227d:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102284:	e8 b7 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102289:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010228e:	74 24                	je     f01022b4 <mem_init+0xc61>
f0102290:	c7 44 24 0c a2 81 10 	movl   $0xf01081a2,0xc(%esp)
f0102297:	f0 
f0102298:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010229f:	f0 
f01022a0:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f01022a7:	00 
f01022a8:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01022af:	e8 8c dd ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01022b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01022bb:	00 
f01022bc:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01022c3:	00 
f01022c4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022c7:	89 04 24             	mov    %eax,(%esp)
f01022ca:	e8 6a f0 ff ff       	call   f0101339 <pgdir_walk>
f01022cf:	f6 00 04             	testb  $0x4,(%eax)
f01022d2:	75 24                	jne    f01022f8 <mem_init+0xca5>
f01022d4:	c7 44 24 0c d4 79 10 	movl   $0xf01079d4,0xc(%esp)
f01022db:	f0 
f01022dc:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01022e3:	f0 
f01022e4:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f01022eb:	00 
f01022ec:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01022f3:	e8 48 dd ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01022f8:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f01022fd:	f6 00 04             	testb  $0x4,(%eax)
f0102300:	75 24                	jne    f0102326 <mem_init+0xcd3>
f0102302:	c7 44 24 0c b3 81 10 	movl   $0xf01081b3,0xc(%esp)
f0102309:	f0 
f010230a:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102311:	f0 
f0102312:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0102319:	00 
f010231a:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102321:	e8 1a dd ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102326:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010232d:	00 
f010232e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102335:	00 
f0102336:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010233a:	89 04 24             	mov    %eax,(%esp)
f010233d:	e8 30 f2 ff ff       	call   f0101572 <page_insert>
f0102342:	85 c0                	test   %eax,%eax
f0102344:	74 24                	je     f010236a <mem_init+0xd17>
f0102346:	c7 44 24 0c e8 78 10 	movl   $0xf01078e8,0xc(%esp)
f010234d:	f0 
f010234e:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102355:	f0 
f0102356:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f010235d:	00 
f010235e:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102365:	e8 d6 dc ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010236a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102371:	00 
f0102372:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102379:	00 
f010237a:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f010237f:	89 04 24             	mov    %eax,(%esp)
f0102382:	e8 b2 ef ff ff       	call   f0101339 <pgdir_walk>
f0102387:	f6 00 02             	testb  $0x2,(%eax)
f010238a:	75 24                	jne    f01023b0 <mem_init+0xd5d>
f010238c:	c7 44 24 0c 08 7a 10 	movl   $0xf0107a08,0xc(%esp)
f0102393:	f0 
f0102394:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010239b:	f0 
f010239c:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f01023a3:	00 
f01023a4:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01023ab:	e8 90 dc ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01023b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01023b7:	00 
f01023b8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01023bf:	00 
f01023c0:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f01023c5:	89 04 24             	mov    %eax,(%esp)
f01023c8:	e8 6c ef ff ff       	call   f0101339 <pgdir_walk>
f01023cd:	f6 00 04             	testb  $0x4,(%eax)
f01023d0:	74 24                	je     f01023f6 <mem_init+0xda3>
f01023d2:	c7 44 24 0c 3c 7a 10 	movl   $0xf0107a3c,0xc(%esp)
f01023d9:	f0 
f01023da:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01023e1:	f0 
f01023e2:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f01023e9:	00 
f01023ea:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01023f1:	e8 4a dc ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01023f6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01023fd:	00 
f01023fe:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102405:	00 
f0102406:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010240a:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f010240f:	89 04 24             	mov    %eax,(%esp)
f0102412:	e8 5b f1 ff ff       	call   f0101572 <page_insert>
f0102417:	85 c0                	test   %eax,%eax
f0102419:	78 24                	js     f010243f <mem_init+0xdec>
f010241b:	c7 44 24 0c 74 7a 10 	movl   $0xf0107a74,0xc(%esp)
f0102422:	f0 
f0102423:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010242a:	f0 
f010242b:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0102432:	00 
f0102433:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f010243a:	e8 01 dc ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010243f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102446:	00 
f0102447:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010244e:	00 
f010244f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102453:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102458:	89 04 24             	mov    %eax,(%esp)
f010245b:	e8 12 f1 ff ff       	call   f0101572 <page_insert>
f0102460:	85 c0                	test   %eax,%eax
f0102462:	74 24                	je     f0102488 <mem_init+0xe35>
f0102464:	c7 44 24 0c ac 7a 10 	movl   $0xf0107aac,0xc(%esp)
f010246b:	f0 
f010246c:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102473:	f0 
f0102474:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f010247b:	00 
f010247c:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102483:	e8 b8 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102488:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010248f:	00 
f0102490:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102497:	00 
f0102498:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f010249d:	89 04 24             	mov    %eax,(%esp)
f01024a0:	e8 94 ee ff ff       	call   f0101339 <pgdir_walk>
f01024a5:	f6 00 04             	testb  $0x4,(%eax)
f01024a8:	74 24                	je     f01024ce <mem_init+0xe7b>
f01024aa:	c7 44 24 0c 3c 7a 10 	movl   $0xf0107a3c,0xc(%esp)
f01024b1:	f0 
f01024b2:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01024b9:	f0 
f01024ba:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f01024c1:	00 
f01024c2:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01024c9:	e8 72 db ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01024ce:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f01024d3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01024d6:	ba 00 00 00 00       	mov    $0x0,%edx
f01024db:	e8 82 e8 ff ff       	call   f0100d62 <check_va2pa>
f01024e0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01024e3:	89 f0                	mov    %esi,%eax
f01024e5:	2b 05 90 2e 33 f0    	sub    0xf0332e90,%eax
f01024eb:	c1 f8 03             	sar    $0x3,%eax
f01024ee:	c1 e0 0c             	shl    $0xc,%eax
f01024f1:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01024f4:	74 24                	je     f010251a <mem_init+0xec7>
f01024f6:	c7 44 24 0c e8 7a 10 	movl   $0xf0107ae8,0xc(%esp)
f01024fd:	f0 
f01024fe:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102505:	f0 
f0102506:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f010250d:	00 
f010250e:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102515:	e8 26 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010251a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010251f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102522:	e8 3b e8 ff ff       	call   f0100d62 <check_va2pa>
f0102527:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010252a:	74 24                	je     f0102550 <mem_init+0xefd>
f010252c:	c7 44 24 0c 14 7b 10 	movl   $0xf0107b14,0xc(%esp)
f0102533:	f0 
f0102534:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010253b:	f0 
f010253c:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0102543:	00 
f0102544:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f010254b:	e8 f0 da ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102550:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102555:	74 24                	je     f010257b <mem_init+0xf28>
f0102557:	c7 44 24 0c c9 81 10 	movl   $0xf01081c9,0xc(%esp)
f010255e:	f0 
f010255f:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102566:	f0 
f0102567:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f010256e:	00 
f010256f:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102576:	e8 c5 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010257b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102580:	74 24                	je     f01025a6 <mem_init+0xf53>
f0102582:	c7 44 24 0c da 81 10 	movl   $0xf01081da,0xc(%esp)
f0102589:	f0 
f010258a:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102591:	f0 
f0102592:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0102599:	00 
f010259a:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01025a1:	e8 9a da ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01025a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01025ad:	e8 87 ec ff ff       	call   f0101239 <page_alloc>
f01025b2:	85 c0                	test   %eax,%eax
f01025b4:	74 04                	je     f01025ba <mem_init+0xf67>
f01025b6:	39 c3                	cmp    %eax,%ebx
f01025b8:	74 24                	je     f01025de <mem_init+0xf8b>
f01025ba:	c7 44 24 0c 44 7b 10 	movl   $0xf0107b44,0xc(%esp)
f01025c1:	f0 
f01025c2:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01025c9:	f0 
f01025ca:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f01025d1:	00 
f01025d2:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01025d9:	e8 62 da ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01025de:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01025e5:	00 
f01025e6:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f01025eb:	89 04 24             	mov    %eax,(%esp)
f01025ee:	e8 2e ef ff ff       	call   f0101521 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025f3:	8b 15 8c 2e 33 f0    	mov    0xf0332e8c,%edx
f01025f9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01025fc:	ba 00 00 00 00       	mov    $0x0,%edx
f0102601:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102604:	e8 59 e7 ff ff       	call   f0100d62 <check_va2pa>
f0102609:	83 f8 ff             	cmp    $0xffffffff,%eax
f010260c:	74 24                	je     f0102632 <mem_init+0xfdf>
f010260e:	c7 44 24 0c 68 7b 10 	movl   $0xf0107b68,0xc(%esp)
f0102615:	f0 
f0102616:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010261d:	f0 
f010261e:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f0102625:	00 
f0102626:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f010262d:	e8 0e da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102632:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102637:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010263a:	e8 23 e7 ff ff       	call   f0100d62 <check_va2pa>
f010263f:	89 f2                	mov    %esi,%edx
f0102641:	2b 15 90 2e 33 f0    	sub    0xf0332e90,%edx
f0102647:	c1 fa 03             	sar    $0x3,%edx
f010264a:	c1 e2 0c             	shl    $0xc,%edx
f010264d:	39 d0                	cmp    %edx,%eax
f010264f:	74 24                	je     f0102675 <mem_init+0x1022>
f0102651:	c7 44 24 0c 14 7b 10 	movl   $0xf0107b14,0xc(%esp)
f0102658:	f0 
f0102659:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102660:	f0 
f0102661:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0102668:	00 
f0102669:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102670:	e8 cb d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102675:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010267a:	74 24                	je     f01026a0 <mem_init+0x104d>
f010267c:	c7 44 24 0c 80 81 10 	movl   $0xf0108180,0xc(%esp)
f0102683:	f0 
f0102684:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010268b:	f0 
f010268c:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0102693:	00 
f0102694:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f010269b:	e8 a0 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01026a0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01026a5:	74 24                	je     f01026cb <mem_init+0x1078>
f01026a7:	c7 44 24 0c da 81 10 	movl   $0xf01081da,0xc(%esp)
f01026ae:	f0 
f01026af:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01026b6:	f0 
f01026b7:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f01026be:	00 
f01026bf:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01026c6:	e8 75 d9 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01026cb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01026d2:	00 
f01026d3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01026da:	00 
f01026db:	89 74 24 04          	mov    %esi,0x4(%esp)
f01026df:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01026e2:	89 0c 24             	mov    %ecx,(%esp)
f01026e5:	e8 88 ee ff ff       	call   f0101572 <page_insert>
f01026ea:	85 c0                	test   %eax,%eax
f01026ec:	74 24                	je     f0102712 <mem_init+0x10bf>
f01026ee:	c7 44 24 0c 8c 7b 10 	movl   $0xf0107b8c,0xc(%esp)
f01026f5:	f0 
f01026f6:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01026fd:	f0 
f01026fe:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f0102705:	00 
f0102706:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f010270d:	e8 2e d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102712:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102717:	75 24                	jne    f010273d <mem_init+0x10ea>
f0102719:	c7 44 24 0c eb 81 10 	movl   $0xf01081eb,0xc(%esp)
f0102720:	f0 
f0102721:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102728:	f0 
f0102729:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f0102730:	00 
f0102731:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102738:	e8 03 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f010273d:	83 3e 00             	cmpl   $0x0,(%esi)
f0102740:	74 24                	je     f0102766 <mem_init+0x1113>
f0102742:	c7 44 24 0c f7 81 10 	movl   $0xf01081f7,0xc(%esp)
f0102749:	f0 
f010274a:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102751:	f0 
f0102752:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0102759:	00 
f010275a:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102761:	e8 da d8 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102766:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010276d:	00 
f010276e:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102773:	89 04 24             	mov    %eax,(%esp)
f0102776:	e8 a6 ed ff ff       	call   f0101521 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010277b:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102780:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102783:	ba 00 00 00 00       	mov    $0x0,%edx
f0102788:	e8 d5 e5 ff ff       	call   f0100d62 <check_va2pa>
f010278d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102790:	74 24                	je     f01027b6 <mem_init+0x1163>
f0102792:	c7 44 24 0c 68 7b 10 	movl   $0xf0107b68,0xc(%esp)
f0102799:	f0 
f010279a:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01027a1:	f0 
f01027a2:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f01027a9:	00 
f01027aa:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01027b1:	e8 8a d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01027b6:	ba 00 10 00 00       	mov    $0x1000,%edx
f01027bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01027be:	e8 9f e5 ff ff       	call   f0100d62 <check_va2pa>
f01027c3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01027c6:	74 24                	je     f01027ec <mem_init+0x1199>
f01027c8:	c7 44 24 0c c4 7b 10 	movl   $0xf0107bc4,0xc(%esp)
f01027cf:	f0 
f01027d0:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01027d7:	f0 
f01027d8:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f01027df:	00 
f01027e0:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01027e7:	e8 54 d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01027ec:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01027f1:	74 24                	je     f0102817 <mem_init+0x11c4>
f01027f3:	c7 44 24 0c 0c 82 10 	movl   $0xf010820c,0xc(%esp)
f01027fa:	f0 
f01027fb:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102802:	f0 
f0102803:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f010280a:	00 
f010280b:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102812:	e8 29 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102817:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010281c:	74 24                	je     f0102842 <mem_init+0x11ef>
f010281e:	c7 44 24 0c da 81 10 	movl   $0xf01081da,0xc(%esp)
f0102825:	f0 
f0102826:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010282d:	f0 
f010282e:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0102835:	00 
f0102836:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f010283d:	e8 fe d7 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102842:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102849:	e8 eb e9 ff ff       	call   f0101239 <page_alloc>
f010284e:	85 c0                	test   %eax,%eax
f0102850:	74 04                	je     f0102856 <mem_init+0x1203>
f0102852:	39 c6                	cmp    %eax,%esi
f0102854:	74 24                	je     f010287a <mem_init+0x1227>
f0102856:	c7 44 24 0c ec 7b 10 	movl   $0xf0107bec,0xc(%esp)
f010285d:	f0 
f010285e:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102865:	f0 
f0102866:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f010286d:	00 
f010286e:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102875:	e8 c6 d7 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010287a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102881:	e8 b3 e9 ff ff       	call   f0101239 <page_alloc>
f0102886:	85 c0                	test   %eax,%eax
f0102888:	74 24                	je     f01028ae <mem_init+0x125b>
f010288a:	c7 44 24 0c 2e 81 10 	movl   $0xf010812e,0xc(%esp)
f0102891:	f0 
f0102892:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102899:	f0 
f010289a:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f01028a1:	00 
f01028a2:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01028a9:	e8 92 d7 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01028ae:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f01028b3:	8b 08                	mov    (%eax),%ecx
f01028b5:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01028bb:	89 fa                	mov    %edi,%edx
f01028bd:	2b 15 90 2e 33 f0    	sub    0xf0332e90,%edx
f01028c3:	c1 fa 03             	sar    $0x3,%edx
f01028c6:	c1 e2 0c             	shl    $0xc,%edx
f01028c9:	39 d1                	cmp    %edx,%ecx
f01028cb:	74 24                	je     f01028f1 <mem_init+0x129e>
f01028cd:	c7 44 24 0c 90 78 10 	movl   $0xf0107890,0xc(%esp)
f01028d4:	f0 
f01028d5:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01028dc:	f0 
f01028dd:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f01028e4:	00 
f01028e5:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01028ec:	e8 4f d7 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01028f1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01028f7:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01028fc:	74 24                	je     f0102922 <mem_init+0x12cf>
f01028fe:	c7 44 24 0c 91 81 10 	movl   $0xf0108191,0xc(%esp)
f0102905:	f0 
f0102906:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010290d:	f0 
f010290e:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0102915:	00 
f0102916:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f010291d:	e8 1e d7 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102922:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102928:	89 3c 24             	mov    %edi,(%esp)
f010292b:	e8 8d e9 ff ff       	call   f01012bd <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102930:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102937:	00 
f0102938:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f010293f:	00 
f0102940:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102945:	89 04 24             	mov    %eax,(%esp)
f0102948:	e8 ec e9 ff ff       	call   f0101339 <pgdir_walk>
f010294d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102950:	8b 0d 8c 2e 33 f0    	mov    0xf0332e8c,%ecx
f0102956:	8b 51 04             	mov    0x4(%ecx),%edx
f0102959:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010295f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102962:	8b 15 88 2e 33 f0    	mov    0xf0332e88,%edx
f0102968:	89 55 c8             	mov    %edx,-0x38(%ebp)
f010296b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010296e:	c1 ea 0c             	shr    $0xc,%edx
f0102971:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102974:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102977:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f010297a:	72 23                	jb     f010299f <mem_init+0x134c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010297c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010297f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102983:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f010298a:	f0 
f010298b:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0102992:	00 
f0102993:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f010299a:	e8 a1 d6 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010299f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01029a2:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01029a8:	39 d0                	cmp    %edx,%eax
f01029aa:	74 24                	je     f01029d0 <mem_init+0x137d>
f01029ac:	c7 44 24 0c 1d 82 10 	movl   $0xf010821d,0xc(%esp)
f01029b3:	f0 
f01029b4:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01029bb:	f0 
f01029bc:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f01029c3:	00 
f01029c4:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01029cb:	e8 70 d6 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01029d0:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f01029d7:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01029dd:	89 f8                	mov    %edi,%eax
f01029df:	2b 05 90 2e 33 f0    	sub    0xf0332e90,%eax
f01029e5:	c1 f8 03             	sar    $0x3,%eax
f01029e8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029eb:	89 c1                	mov    %eax,%ecx
f01029ed:	c1 e9 0c             	shr    $0xc,%ecx
f01029f0:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01029f3:	77 20                	ja     f0102a15 <mem_init+0x13c2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01029f9:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f0102a00:	f0 
f0102a01:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102a08:	00 
f0102a09:	c7 04 24 a1 7f 10 f0 	movl   $0xf0107fa1,(%esp)
f0102a10:	e8 2b d6 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102a15:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102a1c:	00 
f0102a1d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102a24:	00 
	return (void *)(pa + KERNBASE);
f0102a25:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a2a:	89 04 24             	mov    %eax,(%esp)
f0102a2d:	e8 c4 36 00 00       	call   f01060f6 <memset>
	page_free(pp0);
f0102a32:	89 3c 24             	mov    %edi,(%esp)
f0102a35:	e8 83 e8 ff ff       	call   f01012bd <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102a3a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102a41:	00 
f0102a42:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102a49:	00 
f0102a4a:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102a4f:	89 04 24             	mov    %eax,(%esp)
f0102a52:	e8 e2 e8 ff ff       	call   f0101339 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a57:	89 fa                	mov    %edi,%edx
f0102a59:	2b 15 90 2e 33 f0    	sub    0xf0332e90,%edx
f0102a5f:	c1 fa 03             	sar    $0x3,%edx
f0102a62:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a65:	89 d0                	mov    %edx,%eax
f0102a67:	c1 e8 0c             	shr    $0xc,%eax
f0102a6a:	3b 05 88 2e 33 f0    	cmp    0xf0332e88,%eax
f0102a70:	72 20                	jb     f0102a92 <mem_init+0x143f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a72:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102a76:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f0102a7d:	f0 
f0102a7e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102a85:	00 
f0102a86:	c7 04 24 a1 7f 10 f0 	movl   $0xf0107fa1,(%esp)
f0102a8d:	e8 ae d5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102a92:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102a98:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102a9b:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102aa1:	f6 00 01             	testb  $0x1,(%eax)
f0102aa4:	74 24                	je     f0102aca <mem_init+0x1477>
f0102aa6:	c7 44 24 0c 35 82 10 	movl   $0xf0108235,0xc(%esp)
f0102aad:	f0 
f0102aae:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102ab5:	f0 
f0102ab6:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0102abd:	00 
f0102abe:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102ac5:	e8 76 d5 ff ff       	call   f0100040 <_panic>
f0102aca:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102acd:	39 d0                	cmp    %edx,%eax
f0102acf:	75 d0                	jne    f0102aa1 <mem_init+0x144e>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102ad1:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102ad6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102adc:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102ae2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102ae5:	89 0d 40 22 33 f0    	mov    %ecx,0xf0332240

	// free the pages we took
	page_free(pp0);
f0102aeb:	89 3c 24             	mov    %edi,(%esp)
f0102aee:	e8 ca e7 ff ff       	call   f01012bd <page_free>
	page_free(pp1);
f0102af3:	89 34 24             	mov    %esi,(%esp)
f0102af6:	e8 c2 e7 ff ff       	call   f01012bd <page_free>
	page_free(pp2);
f0102afb:	89 1c 24             	mov    %ebx,(%esp)
f0102afe:	e8 ba e7 ff ff       	call   f01012bd <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102b03:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102b0a:	00 
f0102b0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b12:	e8 cd ea ff ff       	call   f01015e4 <mmio_map_region>
f0102b17:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102b19:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102b20:	00 
f0102b21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b28:	e8 b7 ea ff ff       	call   f01015e4 <mmio_map_region>
f0102b2d:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102b2f:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102b35:	76 0d                	jbe    f0102b44 <mem_init+0x14f1>
f0102b37:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102b3d:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102b42:	76 24                	jbe    f0102b68 <mem_init+0x1515>
f0102b44:	c7 44 24 0c 10 7c 10 	movl   $0xf0107c10,0xc(%esp)
f0102b4b:	f0 
f0102b4c:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102b53:	f0 
f0102b54:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f0102b5b:	00 
f0102b5c:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102b63:	e8 d8 d4 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102b68:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102b6e:	76 0e                	jbe    f0102b7e <mem_init+0x152b>
f0102b70:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102b76:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102b7c:	76 24                	jbe    f0102ba2 <mem_init+0x154f>
f0102b7e:	c7 44 24 0c 38 7c 10 	movl   $0xf0107c38,0xc(%esp)
f0102b85:	f0 
f0102b86:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102b8d:	f0 
f0102b8e:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f0102b95:	00 
f0102b96:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102b9d:	e8 9e d4 ff ff       	call   f0100040 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102ba2:	89 da                	mov    %ebx,%edx
f0102ba4:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102ba6:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102bac:	74 24                	je     f0102bd2 <mem_init+0x157f>
f0102bae:	c7 44 24 0c 60 7c 10 	movl   $0xf0107c60,0xc(%esp)
f0102bb5:	f0 
f0102bb6:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102bbd:	f0 
f0102bbe:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f0102bc5:	00 
f0102bc6:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102bcd:	e8 6e d4 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102bd2:	39 c6                	cmp    %eax,%esi
f0102bd4:	73 24                	jae    f0102bfa <mem_init+0x15a7>
f0102bd6:	c7 44 24 0c 4c 82 10 	movl   $0xf010824c,0xc(%esp)
f0102bdd:	f0 
f0102bde:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102be5:	f0 
f0102be6:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0102bed:	00 
f0102bee:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102bf5:	e8 46 d4 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102bfa:	8b 3d 8c 2e 33 f0    	mov    0xf0332e8c,%edi
f0102c00:	89 da                	mov    %ebx,%edx
f0102c02:	89 f8                	mov    %edi,%eax
f0102c04:	e8 59 e1 ff ff       	call   f0100d62 <check_va2pa>
f0102c09:	85 c0                	test   %eax,%eax
f0102c0b:	74 24                	je     f0102c31 <mem_init+0x15de>
f0102c0d:	c7 44 24 0c 88 7c 10 	movl   $0xf0107c88,0xc(%esp)
f0102c14:	f0 
f0102c15:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102c1c:	f0 
f0102c1d:	c7 44 24 04 0d 04 00 	movl   $0x40d,0x4(%esp)
f0102c24:	00 
f0102c25:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102c2c:	e8 0f d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102c31:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102c37:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102c3a:	89 c2                	mov    %eax,%edx
f0102c3c:	89 f8                	mov    %edi,%eax
f0102c3e:	e8 1f e1 ff ff       	call   f0100d62 <check_va2pa>
f0102c43:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102c48:	74 24                	je     f0102c6e <mem_init+0x161b>
f0102c4a:	c7 44 24 0c ac 7c 10 	movl   $0xf0107cac,0xc(%esp)
f0102c51:	f0 
f0102c52:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102c59:	f0 
f0102c5a:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f0102c61:	00 
f0102c62:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102c69:	e8 d2 d3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102c6e:	89 f2                	mov    %esi,%edx
f0102c70:	89 f8                	mov    %edi,%eax
f0102c72:	e8 eb e0 ff ff       	call   f0100d62 <check_va2pa>
f0102c77:	85 c0                	test   %eax,%eax
f0102c79:	74 24                	je     f0102c9f <mem_init+0x164c>
f0102c7b:	c7 44 24 0c dc 7c 10 	movl   $0xf0107cdc,0xc(%esp)
f0102c82:	f0 
f0102c83:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102c8a:	f0 
f0102c8b:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f0102c92:	00 
f0102c93:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102c9a:	e8 a1 d3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102c9f:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102ca5:	89 f8                	mov    %edi,%eax
f0102ca7:	e8 b6 e0 ff ff       	call   f0100d62 <check_va2pa>
f0102cac:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102caf:	74 24                	je     f0102cd5 <mem_init+0x1682>
f0102cb1:	c7 44 24 0c 00 7d 10 	movl   $0xf0107d00,0xc(%esp)
f0102cb8:	f0 
f0102cb9:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102cc0:	f0 
f0102cc1:	c7 44 24 04 10 04 00 	movl   $0x410,0x4(%esp)
f0102cc8:	00 
f0102cc9:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102cd0:	e8 6b d3 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102cd5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102cdc:	00 
f0102cdd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102ce1:	89 3c 24             	mov    %edi,(%esp)
f0102ce4:	e8 50 e6 ff ff       	call   f0101339 <pgdir_walk>
f0102ce9:	f6 00 1a             	testb  $0x1a,(%eax)
f0102cec:	75 24                	jne    f0102d12 <mem_init+0x16bf>
f0102cee:	c7 44 24 0c 2c 7d 10 	movl   $0xf0107d2c,0xc(%esp)
f0102cf5:	f0 
f0102cf6:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102cfd:	f0 
f0102cfe:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f0102d05:	00 
f0102d06:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102d0d:	e8 2e d3 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102d12:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102d19:	00 
f0102d1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102d1e:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102d23:	89 04 24             	mov    %eax,(%esp)
f0102d26:	e8 0e e6 ff ff       	call   f0101339 <pgdir_walk>
f0102d2b:	f6 00 04             	testb  $0x4,(%eax)
f0102d2e:	74 24                	je     f0102d54 <mem_init+0x1701>
f0102d30:	c7 44 24 0c 70 7d 10 	movl   $0xf0107d70,0xc(%esp)
f0102d37:	f0 
f0102d38:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102d3f:	f0 
f0102d40:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f0102d47:	00 
f0102d48:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102d4f:	e8 ec d2 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102d54:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102d5b:	00 
f0102d5c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102d60:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102d65:	89 04 24             	mov    %eax,(%esp)
f0102d68:	e8 cc e5 ff ff       	call   f0101339 <pgdir_walk>
f0102d6d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102d73:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102d7a:	00 
f0102d7b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102d7e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102d82:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102d87:	89 04 24             	mov    %eax,(%esp)
f0102d8a:	e8 aa e5 ff ff       	call   f0101339 <pgdir_walk>
f0102d8f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102d95:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102d9c:	00 
f0102d9d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102da1:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102da6:	89 04 24             	mov    %eax,(%esp)
f0102da9:	e8 8b e5 ff ff       	call   f0101339 <pgdir_walk>
f0102dae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102db4:	c7 04 24 5e 82 10 f0 	movl   $0xf010825e,(%esp)
f0102dbb:	e8 e2 13 00 00       	call   f01041a2 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), PADDR(pages), PTE_U);
f0102dc0:	a1 90 2e 33 f0       	mov    0xf0332e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102dc5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102dca:	77 20                	ja     f0102dec <mem_init+0x1799>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dcc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102dd0:	c7 44 24 08 24 6e 10 	movl   $0xf0106e24,0x8(%esp)
f0102dd7:	f0 
f0102dd8:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
f0102ddf:	00 
f0102de0:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102de7:	e8 54 d2 ff ff       	call   f0100040 <_panic>
f0102dec:	8b 15 88 2e 33 f0    	mov    0xf0332e88,%edx
f0102df2:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102df9:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102dff:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102e06:	00 
	return (physaddr_t)kva - KERNBASE;
f0102e07:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e0c:	89 04 24             	mov    %eax,(%esp)
f0102e0f:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102e14:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102e19:	e8 ba e5 ff ff       	call   f01013d8 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f0102e1e:	a1 48 22 33 f0       	mov    0xf0332248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e23:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e28:	77 20                	ja     f0102e4a <mem_init+0x17f7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e2a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e2e:	c7 44 24 08 24 6e 10 	movl   $0xf0106e24,0x8(%esp)
f0102e35:	f0 
f0102e36:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
f0102e3d:	00 
f0102e3e:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102e45:	e8 f6 d1 ff ff       	call   f0100040 <_panic>
f0102e4a:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102e51:	00 
	return (physaddr_t)kva - KERNBASE;
f0102e52:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e57:	89 04 24             	mov    %eax,(%esp)
f0102e5a:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102e5f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102e64:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102e69:	e8 6a e5 ff ff       	call   f01013d8 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e6e:	b8 00 00 12 f0       	mov    $0xf0120000,%eax
f0102e73:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e78:	77 20                	ja     f0102e9a <mem_init+0x1847>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e7a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e7e:	c7 44 24 08 24 6e 10 	movl   $0xf0106e24,0x8(%esp)
f0102e85:	f0 
f0102e86:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
f0102e8d:	00 
f0102e8e:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102e95:	e8 a6 d1 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102e9a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102ea1:	00 
f0102ea2:	c7 04 24 00 00 12 00 	movl   $0x120000,(%esp)
f0102ea9:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102eae:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102eb3:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102eb8:	e8 1b e5 ff ff       	call   f01013d8 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, (unsigned)0xffffffff-KERNBASE+1, 0, PTE_W);
f0102ebd:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102ec4:	00 
f0102ec5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ecc:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102ed1:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102ed6:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102edb:	e8 f8 e4 ff ff       	call   f01013d8 <boot_map_region>
f0102ee0:	c7 45 cc 00 40 33 f0 	movl   $0xf0334000,-0x34(%ebp)
f0102ee7:	bb 00 40 33 f0       	mov    $0xf0334000,%ebx
f0102eec:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ef1:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102ef7:	77 20                	ja     f0102f19 <mem_init+0x18c6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ef9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102efd:	c7 44 24 08 24 6e 10 	movl   $0xf0106e24,0x8(%esp)
f0102f04:	f0 
f0102f05:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
f0102f0c:	00 
f0102f0d:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102f14:	e8 27 d1 ff ff       	call   f0100040 <_panic>
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; i++) {
		boot_map_region(kern_pgdir, KSTACKTOP - i * (KSTKSIZE + KSTKGAP) - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f0102f19:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102f20:	00 
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102f21:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; i++) {
		boot_map_region(kern_pgdir, KSTACKTOP - i * (KSTKSIZE + KSTKGAP) - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f0102f27:	89 04 24             	mov    %eax,(%esp)
f0102f2a:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102f2f:	89 f2                	mov    %esi,%edx
f0102f31:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102f36:	e8 9d e4 ff ff       	call   f01013d8 <boot_map_region>
f0102f3b:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102f41:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; i++) {
f0102f47:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0102f4d:	75 a2                	jne    f0102ef1 <mem_init+0x189e>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102f4f:	8b 1d 8c 2e 33 f0    	mov    0xf0332e8c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102f55:	8b 0d 88 2e 33 f0    	mov    0xf0332e88,%ecx
f0102f5b:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102f5e:	8d 3c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%edi
f0102f65:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102f6b:	be 00 00 00 00       	mov    $0x0,%esi
f0102f70:	eb 70                	jmp    f0102fe2 <mem_init+0x198f>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102f72:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102f78:	89 d8                	mov    %ebx,%eax
f0102f7a:	e8 e3 dd ff ff       	call   f0100d62 <check_va2pa>
f0102f7f:	8b 15 90 2e 33 f0    	mov    0xf0332e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f85:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102f8b:	77 20                	ja     f0102fad <mem_init+0x195a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f8d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102f91:	c7 44 24 08 24 6e 10 	movl   $0xf0106e24,0x8(%esp)
f0102f98:	f0 
f0102f99:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f0102fa0:	00 
f0102fa1:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102fa8:	e8 93 d0 ff ff       	call   f0100040 <_panic>
f0102fad:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102fb4:	39 d0                	cmp    %edx,%eax
f0102fb6:	74 24                	je     f0102fdc <mem_init+0x1989>
f0102fb8:	c7 44 24 0c a4 7d 10 	movl   $0xf0107da4,0xc(%esp)
f0102fbf:	f0 
f0102fc0:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0102fc7:	f0 
f0102fc8:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f0102fcf:	00 
f0102fd0:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0102fd7:	e8 64 d0 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102fdc:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102fe2:	39 f7                	cmp    %esi,%edi
f0102fe4:	77 8c                	ja     f0102f72 <mem_init+0x191f>
f0102fe6:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102feb:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102ff1:	89 d8                	mov    %ebx,%eax
f0102ff3:	e8 6a dd ff ff       	call   f0100d62 <check_va2pa>
f0102ff8:	8b 15 48 22 33 f0    	mov    0xf0332248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ffe:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103004:	77 20                	ja     f0103026 <mem_init+0x19d3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103006:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010300a:	c7 44 24 08 24 6e 10 	movl   $0xf0106e24,0x8(%esp)
f0103011:	f0 
f0103012:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f0103019:	00 
f010301a:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0103021:	e8 1a d0 ff ff       	call   f0100040 <_panic>
f0103026:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f010302d:	39 d0                	cmp    %edx,%eax
f010302f:	74 24                	je     f0103055 <mem_init+0x1a02>
f0103031:	c7 44 24 0c d8 7d 10 	movl   $0xf0107dd8,0xc(%esp)
f0103038:	f0 
f0103039:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0103040:	f0 
f0103041:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f0103048:	00 
f0103049:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0103050:	e8 eb cf ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0103055:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010305b:	81 fe 00 b0 02 00    	cmp    $0x2b000,%esi
f0103061:	75 88                	jne    f0102feb <mem_init+0x1998>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103063:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103066:	c1 e7 0c             	shl    $0xc,%edi
f0103069:	be 00 00 00 00       	mov    $0x0,%esi
f010306e:	eb 3b                	jmp    f01030ab <mem_init+0x1a58>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103070:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0103076:	89 d8                	mov    %ebx,%eax
f0103078:	e8 e5 dc ff ff       	call   f0100d62 <check_va2pa>
f010307d:	39 c6                	cmp    %eax,%esi
f010307f:	74 24                	je     f01030a5 <mem_init+0x1a52>
f0103081:	c7 44 24 0c 0c 7e 10 	movl   $0xf0107e0c,0xc(%esp)
f0103088:	f0 
f0103089:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0103090:	f0 
f0103091:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f0103098:	00 
f0103099:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01030a0:	e8 9b cf ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01030a5:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01030ab:	39 fe                	cmp    %edi,%esi
f01030ad:	72 c1                	jb     f0103070 <mem_init+0x1a1d>
f01030af:	bf 00 00 ff ef       	mov    $0xefff0000,%edi
f01030b4:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01030b7:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01030ba:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01030bd:	8d 9f 00 80 00 00    	lea    0x8000(%edi),%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01030c3:	89 c6                	mov    %eax,%esi
f01030c5:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f01030cb:	8d 97 00 00 01 00    	lea    0x10000(%edi),%edx
f01030d1:	89 55 d0             	mov    %edx,-0x30(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01030d4:	89 da                	mov    %ebx,%edx
f01030d6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01030d9:	e8 84 dc ff ff       	call   f0100d62 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01030de:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f01030e5:	77 23                	ja     f010310a <mem_init+0x1ab7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030e7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01030ea:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01030ee:	c7 44 24 08 24 6e 10 	movl   $0xf0106e24,0x8(%esp)
f01030f5:	f0 
f01030f6:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f01030fd:	00 
f01030fe:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0103105:	e8 36 cf ff ff       	call   f0100040 <_panic>
f010310a:	39 f0                	cmp    %esi,%eax
f010310c:	74 24                	je     f0103132 <mem_init+0x1adf>
f010310e:	c7 44 24 0c 34 7e 10 	movl   $0xf0107e34,0xc(%esp)
f0103115:	f0 
f0103116:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010311d:	f0 
f010311e:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f0103125:	00 
f0103126:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f010312d:	e8 0e cf ff ff       	call   f0100040 <_panic>
f0103132:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103138:	81 c6 00 10 00 00    	add    $0x1000,%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010313e:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0103141:	0f 85 55 05 00 00    	jne    f010369c <mem_init+0x2049>
f0103147:	bb 00 00 00 00       	mov    $0x0,%ebx
f010314c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f010314f:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0103152:	89 f0                	mov    %esi,%eax
f0103154:	e8 09 dc ff ff       	call   f0100d62 <check_va2pa>
f0103159:	83 f8 ff             	cmp    $0xffffffff,%eax
f010315c:	74 24                	je     f0103182 <mem_init+0x1b2f>
f010315e:	c7 44 24 0c 7c 7e 10 	movl   $0xf0107e7c,0xc(%esp)
f0103165:	f0 
f0103166:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010316d:	f0 
f010316e:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f0103175:	00 
f0103176:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f010317d:	e8 be ce ff ff       	call   f0100040 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0103182:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103188:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f010318e:	75 bf                	jne    f010314f <mem_init+0x1afc>
f0103190:	81 ef 00 00 01 00    	sub    $0x10000,%edi
f0103196:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f010319d:	81 ff 00 00 f7 ef    	cmp    $0xeff70000,%edi
f01031a3:	0f 85 0e ff ff ff    	jne    f01030b7 <mem_init+0x1a64>
f01031a9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031ac:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01031b1:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01031b7:	83 fa 04             	cmp    $0x4,%edx
f01031ba:	77 2e                	ja     f01031ea <mem_init+0x1b97>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f01031bc:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f01031c0:	0f 85 aa 00 00 00    	jne    f0103270 <mem_init+0x1c1d>
f01031c6:	c7 44 24 0c 77 82 10 	movl   $0xf0108277,0xc(%esp)
f01031cd:	f0 
f01031ce:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01031d5:	f0 
f01031d6:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f01031dd:	00 
f01031de:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01031e5:	e8 56 ce ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01031ea:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01031ef:	76 55                	jbe    f0103246 <mem_init+0x1bf3>
				assert(pgdir[i] & PTE_P);
f01031f1:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01031f4:	f6 c2 01             	test   $0x1,%dl
f01031f7:	75 24                	jne    f010321d <mem_init+0x1bca>
f01031f9:	c7 44 24 0c 77 82 10 	movl   $0xf0108277,0xc(%esp)
f0103200:	f0 
f0103201:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0103208:	f0 
f0103209:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0103210:	00 
f0103211:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0103218:	e8 23 ce ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f010321d:	f6 c2 02             	test   $0x2,%dl
f0103220:	75 4e                	jne    f0103270 <mem_init+0x1c1d>
f0103222:	c7 44 24 0c 88 82 10 	movl   $0xf0108288,0xc(%esp)
f0103229:	f0 
f010322a:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0103231:	f0 
f0103232:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f0103239:	00 
f010323a:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0103241:	e8 fa cd ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0103246:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f010324a:	74 24                	je     f0103270 <mem_init+0x1c1d>
f010324c:	c7 44 24 0c 99 82 10 	movl   $0xf0108299,0xc(%esp)
f0103253:	f0 
f0103254:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010325b:	f0 
f010325c:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0103263:	00 
f0103264:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f010326b:	e8 d0 cd ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0103270:	40                   	inc    %eax
f0103271:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103276:	0f 85 35 ff ff ff    	jne    f01031b1 <mem_init+0x1b5e>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010327c:	c7 04 24 a0 7e 10 f0 	movl   $0xf0107ea0,(%esp)
f0103283:	e8 1a 0f 00 00       	call   f01041a2 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103288:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010328d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103292:	77 20                	ja     f01032b4 <mem_init+0x1c61>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103294:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103298:	c7 44 24 08 24 6e 10 	movl   $0xf0106e24,0x8(%esp)
f010329f:	f0 
f01032a0:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
f01032a7:	00 
f01032a8:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01032af:	e8 8c cd ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01032b4:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01032b9:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01032bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01032c1:	e8 32 db ff ff       	call   f0100df8 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01032c6:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f01032c9:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01032ce:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01032d1:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01032d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01032db:	e8 59 df ff ff       	call   f0101239 <page_alloc>
f01032e0:	89 c6                	mov    %eax,%esi
f01032e2:	85 c0                	test   %eax,%eax
f01032e4:	75 24                	jne    f010330a <mem_init+0x1cb7>
f01032e6:	c7 44 24 0c 83 80 10 	movl   $0xf0108083,0xc(%esp)
f01032ed:	f0 
f01032ee:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01032f5:	f0 
f01032f6:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f01032fd:	00 
f01032fe:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0103305:	e8 36 cd ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010330a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103311:	e8 23 df ff ff       	call   f0101239 <page_alloc>
f0103316:	89 c7                	mov    %eax,%edi
f0103318:	85 c0                	test   %eax,%eax
f010331a:	75 24                	jne    f0103340 <mem_init+0x1ced>
f010331c:	c7 44 24 0c 99 80 10 	movl   $0xf0108099,0xc(%esp)
f0103323:	f0 
f0103324:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010332b:	f0 
f010332c:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f0103333:	00 
f0103334:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f010333b:	e8 00 cd ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0103340:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103347:	e8 ed de ff ff       	call   f0101239 <page_alloc>
f010334c:	89 c3                	mov    %eax,%ebx
f010334e:	85 c0                	test   %eax,%eax
f0103350:	75 24                	jne    f0103376 <mem_init+0x1d23>
f0103352:	c7 44 24 0c af 80 10 	movl   $0xf01080af,0xc(%esp)
f0103359:	f0 
f010335a:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0103361:	f0 
f0103362:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f0103369:	00 
f010336a:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0103371:	e8 ca cc ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0103376:	89 34 24             	mov    %esi,(%esp)
f0103379:	e8 3f df ff ff       	call   f01012bd <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010337e:	89 f8                	mov    %edi,%eax
f0103380:	2b 05 90 2e 33 f0    	sub    0xf0332e90,%eax
f0103386:	c1 f8 03             	sar    $0x3,%eax
f0103389:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010338c:	89 c2                	mov    %eax,%edx
f010338e:	c1 ea 0c             	shr    $0xc,%edx
f0103391:	3b 15 88 2e 33 f0    	cmp    0xf0332e88,%edx
f0103397:	72 20                	jb     f01033b9 <mem_init+0x1d66>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103399:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010339d:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f01033a4:	f0 
f01033a5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01033ac:	00 
f01033ad:	c7 04 24 a1 7f 10 f0 	movl   $0xf0107fa1,(%esp)
f01033b4:	e8 87 cc ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01033b9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01033c0:	00 
f01033c1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01033c8:	00 
	return (void *)(pa + KERNBASE);
f01033c9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01033ce:	89 04 24             	mov    %eax,(%esp)
f01033d1:	e8 20 2d 00 00       	call   f01060f6 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01033d6:	89 d8                	mov    %ebx,%eax
f01033d8:	2b 05 90 2e 33 f0    	sub    0xf0332e90,%eax
f01033de:	c1 f8 03             	sar    $0x3,%eax
f01033e1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033e4:	89 c2                	mov    %eax,%edx
f01033e6:	c1 ea 0c             	shr    $0xc,%edx
f01033e9:	3b 15 88 2e 33 f0    	cmp    0xf0332e88,%edx
f01033ef:	72 20                	jb     f0103411 <mem_init+0x1dbe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01033f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01033f5:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f01033fc:	f0 
f01033fd:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103404:	00 
f0103405:	c7 04 24 a1 7f 10 f0 	movl   $0xf0107fa1,(%esp)
f010340c:	e8 2f cc ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0103411:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103418:	00 
f0103419:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103420:	00 
	return (void *)(pa + KERNBASE);
f0103421:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103426:	89 04 24             	mov    %eax,(%esp)
f0103429:	e8 c8 2c 00 00       	call   f01060f6 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010342e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103435:	00 
f0103436:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010343d:	00 
f010343e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103442:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0103447:	89 04 24             	mov    %eax,(%esp)
f010344a:	e8 23 e1 ff ff       	call   f0101572 <page_insert>
	assert(pp1->pp_ref == 1);
f010344f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103454:	74 24                	je     f010347a <mem_init+0x1e27>
f0103456:	c7 44 24 0c 80 81 10 	movl   $0xf0108180,0xc(%esp)
f010345d:	f0 
f010345e:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0103465:	f0 
f0103466:	c7 44 24 04 2f 04 00 	movl   $0x42f,0x4(%esp)
f010346d:	00 
f010346e:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0103475:	e8 c6 cb ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010347a:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103481:	01 01 01 
f0103484:	74 24                	je     f01034aa <mem_init+0x1e57>
f0103486:	c7 44 24 0c c0 7e 10 	movl   $0xf0107ec0,0xc(%esp)
f010348d:	f0 
f010348e:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0103495:	f0 
f0103496:	c7 44 24 04 30 04 00 	movl   $0x430,0x4(%esp)
f010349d:	00 
f010349e:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01034a5:	e8 96 cb ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01034aa:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01034b1:	00 
f01034b2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01034b9:	00 
f01034ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01034be:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f01034c3:	89 04 24             	mov    %eax,(%esp)
f01034c6:	e8 a7 e0 ff ff       	call   f0101572 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01034cb:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01034d2:	02 02 02 
f01034d5:	74 24                	je     f01034fb <mem_init+0x1ea8>
f01034d7:	c7 44 24 0c e4 7e 10 	movl   $0xf0107ee4,0xc(%esp)
f01034de:	f0 
f01034df:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01034e6:	f0 
f01034e7:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f01034ee:	00 
f01034ef:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01034f6:	e8 45 cb ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01034fb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103500:	74 24                	je     f0103526 <mem_init+0x1ed3>
f0103502:	c7 44 24 0c a2 81 10 	movl   $0xf01081a2,0xc(%esp)
f0103509:	f0 
f010350a:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0103511:	f0 
f0103512:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f0103519:	00 
f010351a:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0103521:	e8 1a cb ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103526:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010352b:	74 24                	je     f0103551 <mem_init+0x1efe>
f010352d:	c7 44 24 0c 0c 82 10 	movl   $0xf010820c,0xc(%esp)
f0103534:	f0 
f0103535:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010353c:	f0 
f010353d:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f0103544:	00 
f0103545:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f010354c:	e8 ef ca ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103551:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103558:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010355b:	89 d8                	mov    %ebx,%eax
f010355d:	2b 05 90 2e 33 f0    	sub    0xf0332e90,%eax
f0103563:	c1 f8 03             	sar    $0x3,%eax
f0103566:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103569:	89 c2                	mov    %eax,%edx
f010356b:	c1 ea 0c             	shr    $0xc,%edx
f010356e:	3b 15 88 2e 33 f0    	cmp    0xf0332e88,%edx
f0103574:	72 20                	jb     f0103596 <mem_init+0x1f43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103576:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010357a:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f0103581:	f0 
f0103582:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103589:	00 
f010358a:	c7 04 24 a1 7f 10 f0 	movl   $0xf0107fa1,(%esp)
f0103591:	e8 aa ca ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103596:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010359d:	03 03 03 
f01035a0:	74 24                	je     f01035c6 <mem_init+0x1f73>
f01035a2:	c7 44 24 0c 08 7f 10 	movl   $0xf0107f08,0xc(%esp)
f01035a9:	f0 
f01035aa:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01035b1:	f0 
f01035b2:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
f01035b9:	00 
f01035ba:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f01035c1:	e8 7a ca ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01035c6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01035cd:	00 
f01035ce:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f01035d3:	89 04 24             	mov    %eax,(%esp)
f01035d6:	e8 46 df ff ff       	call   f0101521 <page_remove>
	assert(pp2->pp_ref == 0);
f01035db:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01035e0:	74 24                	je     f0103606 <mem_init+0x1fb3>
f01035e2:	c7 44 24 0c da 81 10 	movl   $0xf01081da,0xc(%esp)
f01035e9:	f0 
f01035ea:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f01035f1:	f0 
f01035f2:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
f01035f9:	00 
f01035fa:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0103601:	e8 3a ca ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103606:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f010360b:	8b 08                	mov    (%eax),%ecx
f010360d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103613:	89 f2                	mov    %esi,%edx
f0103615:	2b 15 90 2e 33 f0    	sub    0xf0332e90,%edx
f010361b:	c1 fa 03             	sar    $0x3,%edx
f010361e:	c1 e2 0c             	shl    $0xc,%edx
f0103621:	39 d1                	cmp    %edx,%ecx
f0103623:	74 24                	je     f0103649 <mem_init+0x1ff6>
f0103625:	c7 44 24 0c 90 78 10 	movl   $0xf0107890,0xc(%esp)
f010362c:	f0 
f010362d:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0103634:	f0 
f0103635:	c7 44 24 04 3b 04 00 	movl   $0x43b,0x4(%esp)
f010363c:	00 
f010363d:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0103644:	e8 f7 c9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103649:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010364f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103654:	74 24                	je     f010367a <mem_init+0x2027>
f0103656:	c7 44 24 0c 91 81 10 	movl   $0xf0108191,0xc(%esp)
f010365d:	f0 
f010365e:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0103665:	f0 
f0103666:	c7 44 24 04 3d 04 00 	movl   $0x43d,0x4(%esp)
f010366d:	00 
f010366e:	c7 04 24 95 7f 10 f0 	movl   $0xf0107f95,(%esp)
f0103675:	e8 c6 c9 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010367a:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0103680:	89 34 24             	mov    %esi,(%esp)
f0103683:	e8 35 dc ff ff       	call   f01012bd <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103688:	c7 04 24 34 7f 10 f0 	movl   $0xf0107f34,(%esp)
f010368f:	e8 0e 0b 00 00       	call   f01041a2 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103694:	83 c4 3c             	add    $0x3c,%esp
f0103697:	5b                   	pop    %ebx
f0103698:	5e                   	pop    %esi
f0103699:	5f                   	pop    %edi
f010369a:	5d                   	pop    %ebp
f010369b:	c3                   	ret    
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010369c:	89 da                	mov    %ebx,%edx
f010369e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01036a1:	e8 bc d6 ff ff       	call   f0100d62 <check_va2pa>
f01036a6:	e9 5f fa ff ff       	jmp    f010310a <mem_init+0x1ab7>

f01036ab <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01036ab:	55                   	push   %ebp
f01036ac:	89 e5                	mov    %esp,%ebp
f01036ae:	57                   	push   %edi
f01036af:	56                   	push   %esi
f01036b0:	53                   	push   %ebx
f01036b1:	83 ec 2c             	sub    $0x2c,%esp
f01036b4:	8b 75 08             	mov    0x8(%ebp),%esi
f01036b7:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 3: Your code here.
	const void *va_ptr = ROUNDDOWN(va, PGSIZE);
f01036ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01036bd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// page alignment
	for (; va_ptr < ROUNDUP(va+len, PGSIZE); va_ptr += PGSIZE) {
f01036c3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036c6:	03 45 10             	add    0x10(%ebp),%eax
f01036c9:	05 ff 0f 00 00       	add    $0xfff,%eax
f01036ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01036d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01036d6:	eb 4b                	jmp    f0103723 <user_mem_check+0x78>
		pte_t *ppte = pgdir_walk(env->env_pgdir, va_ptr, 0);
f01036d8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01036df:	00 
f01036e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01036e4:	8b 46 60             	mov    0x60(%esi),%eax
f01036e7:	89 04 24             	mov    %eax,(%esp)
f01036ea:	e8 4a dc ff ff       	call   f0101339 <pgdir_walk>
		if (((uintptr_t)va_ptr >= ULIM) || !ppte || !(*ppte & PTE_P) || (*ppte & perm) != perm) {
f01036ef:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01036f5:	77 10                	ja     f0103707 <user_mem_check+0x5c>
f01036f7:	85 c0                	test   %eax,%eax
f01036f9:	74 0c                	je     f0103707 <user_mem_check+0x5c>
f01036fb:	8b 00                	mov    (%eax),%eax
f01036fd:	a8 01                	test   $0x1,%al
f01036ff:	74 06                	je     f0103707 <user_mem_check+0x5c>
f0103701:	21 f8                	and    %edi,%eax
f0103703:	39 c7                	cmp    %eax,%edi
f0103705:	74 16                	je     f010371d <user_mem_check+0x72>
			user_mem_check_addr = (uintptr_t)(va_ptr < va ? va : va_ptr);
f0103707:	89 d8                	mov    %ebx,%eax
f0103709:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f010370c:	76 03                	jbe    f0103711 <user_mem_check+0x66>
f010370e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103711:	a3 44 22 33 f0       	mov    %eax,0xf0332244
			return -E_FAULT;
f0103716:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010371b:	eb 10                	jmp    f010372d <user_mem_check+0x82>
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	const void *va_ptr = ROUNDDOWN(va, PGSIZE);
	// page alignment
	for (; va_ptr < ROUNDUP(va+len, PGSIZE); va_ptr += PGSIZE) {
f010371d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103723:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0103726:	72 b0                	jb     f01036d8 <user_mem_check+0x2d>
		if (((uintptr_t)va_ptr >= ULIM) || !ppte || !(*ppte & PTE_P) || (*ppte & perm) != perm) {
			user_mem_check_addr = (uintptr_t)(va_ptr < va ? va : va_ptr);
			return -E_FAULT;
		}
	}
	return 0;
f0103728:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010372d:	83 c4 2c             	add    $0x2c,%esp
f0103730:	5b                   	pop    %ebx
f0103731:	5e                   	pop    %esi
f0103732:	5f                   	pop    %edi
f0103733:	5d                   	pop    %ebp
f0103734:	c3                   	ret    

f0103735 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103735:	55                   	push   %ebp
f0103736:	89 e5                	mov    %esp,%ebp
f0103738:	53                   	push   %ebx
f0103739:	83 ec 14             	sub    $0x14,%esp
f010373c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f010373f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103742:	83 c8 04             	or     $0x4,%eax
f0103745:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103749:	8b 45 10             	mov    0x10(%ebp),%eax
f010374c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103750:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103753:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103757:	89 1c 24             	mov    %ebx,(%esp)
f010375a:	e8 4c ff ff ff       	call   f01036ab <user_mem_check>
f010375f:	85 c0                	test   %eax,%eax
f0103761:	79 24                	jns    f0103787 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103763:	a1 44 22 33 f0       	mov    0xf0332244,%eax
f0103768:	89 44 24 08          	mov    %eax,0x8(%esp)
f010376c:	8b 43 48             	mov    0x48(%ebx),%eax
f010376f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103773:	c7 04 24 60 7f 10 f0 	movl   $0xf0107f60,(%esp)
f010377a:	e8 23 0a 00 00       	call   f01041a2 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f010377f:	89 1c 24             	mov    %ebx,(%esp)
f0103782:	e8 0d 07 00 00       	call   f0103e94 <env_destroy>
	}
}
f0103787:	83 c4 14             	add    $0x14,%esp
f010378a:	5b                   	pop    %ebx
f010378b:	5d                   	pop    %ebp
f010378c:	c3                   	ret    
f010378d:	00 00                	add    %al,(%eax)
	...

f0103790 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103790:	55                   	push   %ebp
f0103791:	89 e5                	mov    %esp,%ebp
f0103793:	57                   	push   %edi
f0103794:	56                   	push   %esi
f0103795:	53                   	push   %ebx
f0103796:	83 ec 1c             	sub    $0x1c,%esp
f0103799:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *va_ptr = ROUNDDOWN(va, PGSIZE);
f010379b:	89 d3                	mov    %edx,%ebx
f010379d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// page alignment
	for (; va_ptr < ROUNDUP(va+len, PGSIZE); va_ptr += PGSIZE) {
f01037a3:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f01037aa:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01037b0:	eb 4d                	jmp    f01037ff <region_alloc+0x6f>
		struct PageInfo *pp = page_alloc(0);
f01037b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01037b9:	e8 7b da ff ff       	call   f0101239 <page_alloc>
		// if page alloction failed
		if (!pp) panic("region_alloc: page alloc failed!");
f01037be:	85 c0                	test   %eax,%eax
f01037c0:	75 1c                	jne    f01037de <region_alloc+0x4e>
f01037c2:	c7 44 24 08 a8 82 10 	movl   $0xf01082a8,0x8(%esp)
f01037c9:	f0 
f01037ca:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
f01037d1:	00 
f01037d2:	c7 04 24 01 83 10 f0 	movl   $0xf0108301,(%esp)
f01037d9:	e8 62 c8 ff ff       	call   f0100040 <_panic>
		page_insert(e->env_pgdir, pp, va_ptr, PTE_W | PTE_U);
f01037de:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01037e5:	00 
f01037e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01037ea:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037ee:	8b 46 60             	mov    0x60(%esi),%eax
f01037f1:	89 04 24             	mov    %eax,(%esp)
f01037f4:	e8 79 dd ff ff       	call   f0101572 <page_insert>
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *va_ptr = ROUNDDOWN(va, PGSIZE);
	// page alignment
	for (; va_ptr < ROUNDUP(va+len, PGSIZE); va_ptr += PGSIZE) {
f01037f9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01037ff:	39 fb                	cmp    %edi,%ebx
f0103801:	72 af                	jb     f01037b2 <region_alloc+0x22>
		struct PageInfo *pp = page_alloc(0);
		// if page alloction failed
		if (!pp) panic("region_alloc: page alloc failed!");
		page_insert(e->env_pgdir, pp, va_ptr, PTE_W | PTE_U);
	}
}
f0103803:	83 c4 1c             	add    $0x1c,%esp
f0103806:	5b                   	pop    %ebx
f0103807:	5e                   	pop    %esi
f0103808:	5f                   	pop    %edi
f0103809:	5d                   	pop    %ebp
f010380a:	c3                   	ret    

f010380b <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010380b:	55                   	push   %ebp
f010380c:	89 e5                	mov    %esp,%ebp
f010380e:	57                   	push   %edi
f010380f:	56                   	push   %esi
f0103810:	53                   	push   %ebx
f0103811:	83 ec 0c             	sub    $0xc,%esp
f0103814:	8b 55 08             	mov    0x8(%ebp),%edx
f0103817:	8b 75 0c             	mov    0xc(%ebp),%esi
f010381a:	8a 4d 10             	mov    0x10(%ebp),%cl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010381d:	85 d2                	test   %edx,%edx
f010381f:	75 24                	jne    f0103845 <envid2env+0x3a>
		*env_store = curenv;
f0103821:	e8 fe 2e 00 00       	call   f0106724 <cpunum>
f0103826:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010382d:	29 c2                	sub    %eax,%edx
f010382f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103832:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0103839:	89 06                	mov    %eax,(%esi)
		return 0;
f010383b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103840:	e9 83 00 00 00       	jmp    f01038c8 <envid2env+0xbd>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103845:	89 d0                	mov    %edx,%eax
f0103847:	25 ff 03 00 00       	and    $0x3ff,%eax
f010384c:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
f010384f:	8d 1c 98             	lea    (%eax,%ebx,4),%ebx
f0103852:	8d 1c 58             	lea    (%eax,%ebx,2),%ebx
f0103855:	c1 e3 02             	shl    $0x2,%ebx
f0103858:	03 1d 48 22 33 f0    	add    0xf0332248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010385e:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103862:	74 05                	je     f0103869 <envid2env+0x5e>
f0103864:	39 53 48             	cmp    %edx,0x48(%ebx)
f0103867:	74 0d                	je     f0103876 <envid2env+0x6b>
		*env_store = 0;
f0103869:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f010386f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103874:	eb 52                	jmp    f01038c8 <envid2env+0xbd>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103876:	84 c9                	test   %cl,%cl
f0103878:	74 47                	je     f01038c1 <envid2env+0xb6>
f010387a:	e8 a5 2e 00 00       	call   f0106724 <cpunum>
f010387f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103886:	29 c2                	sub    %eax,%edx
f0103888:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010388b:	39 1c 85 28 30 33 f0 	cmp    %ebx,-0xfcccfd8(,%eax,4)
f0103892:	74 2d                	je     f01038c1 <envid2env+0xb6>
f0103894:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f0103897:	e8 88 2e 00 00       	call   f0106724 <cpunum>
f010389c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01038a3:	29 c2                	sub    %eax,%edx
f01038a5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01038a8:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f01038af:	3b 78 48             	cmp    0x48(%eax),%edi
f01038b2:	74 0d                	je     f01038c1 <envid2env+0xb6>
		*env_store = 0;
f01038b4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01038ba:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01038bf:	eb 07                	jmp    f01038c8 <envid2env+0xbd>
	}

	*env_store = e;
f01038c1:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01038c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01038c8:	83 c4 0c             	add    $0xc,%esp
f01038cb:	5b                   	pop    %ebx
f01038cc:	5e                   	pop    %esi
f01038cd:	5f                   	pop    %edi
f01038ce:	5d                   	pop    %ebp
f01038cf:	c3                   	ret    

f01038d0 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01038d0:	55                   	push   %ebp
f01038d1:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01038d3:	b8 20 a3 12 f0       	mov    $0xf012a320,%eax
f01038d8:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01038db:	b8 23 00 00 00       	mov    $0x23,%eax
f01038e0:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01038e2:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01038e4:	b0 10                	mov    $0x10,%al
f01038e6:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01038e8:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01038ea:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01038ec:	ea f3 38 10 f0 08 00 	ljmp   $0x8,$0xf01038f3
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01038f3:	b0 00                	mov    $0x0,%al
f01038f5:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01038f8:	5d                   	pop    %ebp
f01038f9:	c3                   	ret    

f01038fa <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01038fa:	55                   	push   %ebp
f01038fb:	89 e5                	mov    %esp,%ebp
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f01038fd:	a1 48 22 33 f0       	mov    0xf0332248,%eax
f0103902:	05 ac 00 00 00       	add    $0xac,%eax
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = 0; i < NENV; i++) {
f0103907:	ba 00 00 00 00       	mov    $0x0,%edx
		envs[i].env_id = 0;
f010390c:	c7 40 9c 00 00 00 00 	movl   $0x0,-0x64(%eax)
		envs[i].env_link = &envs[i+1];
f0103913:	89 40 98             	mov    %eax,-0x68(%eax)
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = 0; i < NENV; i++) {
f0103916:	42                   	inc    %edx
f0103917:	05 ac 00 00 00       	add    $0xac,%eax
f010391c:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0103922:	75 e8                	jne    f010390c <env_init+0x12>
		envs[i].env_id = 0;
		envs[i].env_link = &envs[i+1];
	}
	// point env_free_list to the first free env
	env_free_list = envs;
f0103924:	a1 48 22 33 f0       	mov    0xf0332248,%eax
f0103929:	a3 4c 22 33 f0       	mov    %eax,0xf033224c
	// Per-CPU part of the initialization
	env_init_percpu();
f010392e:	e8 9d ff ff ff       	call   f01038d0 <env_init_percpu>
}
f0103933:	5d                   	pop    %ebp
f0103934:	c3                   	ret    

f0103935 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103935:	55                   	push   %ebp
f0103936:	89 e5                	mov    %esp,%ebp
f0103938:	56                   	push   %esi
f0103939:	53                   	push   %ebx
f010393a:	83 ec 10             	sub    $0x10,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010393d:	8b 1d 4c 22 33 f0    	mov    0xf033224c,%ebx
f0103943:	85 db                	test   %ebx,%ebx
f0103945:	0f 84 bd 01 00 00    	je     f0103b08 <env_alloc+0x1d3>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010394b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103952:	e8 e2 d8 ff ff       	call   f0101239 <page_alloc>
f0103957:	85 c0                	test   %eax,%eax
f0103959:	0f 84 b0 01 00 00    	je     f0103b0f <env_alloc+0x1da>
f010395f:	89 c2                	mov    %eax,%edx
f0103961:	2b 15 90 2e 33 f0    	sub    0xf0332e90,%edx
f0103967:	c1 fa 03             	sar    $0x3,%edx
f010396a:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010396d:	89 d1                	mov    %edx,%ecx
f010396f:	c1 e9 0c             	shr    $0xc,%ecx
f0103972:	3b 0d 88 2e 33 f0    	cmp    0xf0332e88,%ecx
f0103978:	72 20                	jb     f010399a <env_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010397a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010397e:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f0103985:	f0 
f0103986:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010398d:	00 
f010398e:	c7 04 24 a1 7f 10 f0 	movl   $0xf0107fa1,(%esp)
f0103995:	e8 a6 c6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010399a:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01039a0:	89 53 60             	mov    %edx,0x60(%ebx)
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = page2kva(p);
	p->pp_ref++;
f01039a3:	66 ff 40 04          	incw   0x4(%eax)
	// use kern_pgdir as a template
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01039a7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01039ae:	00 
f01039af:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f01039b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039b8:	8b 43 60             	mov    0x60(%ebx),%eax
f01039bb:	89 04 24             	mov    %eax,(%esp)
f01039be:	e8 e7 27 00 00       	call   f01061aa <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01039c3:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01039c6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039cb:	77 20                	ja     f01039ed <env_alloc+0xb8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039d1:	c7 44 24 08 24 6e 10 	movl   $0xf0106e24,0x8(%esp)
f01039d8:	f0 
f01039d9:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
f01039e0:	00 
f01039e1:	c7 04 24 01 83 10 f0 	movl   $0xf0108301,(%esp)
f01039e8:	e8 53 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01039ed:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01039f3:	83 ca 05             	or     $0x5,%edx
f01039f6:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01039fc:	8b 43 48             	mov    0x48(%ebx),%eax
f01039ff:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103a04:	89 c6                	mov    %eax,%esi
f0103a06:	81 e6 00 fc ff ff    	and    $0xfffffc00,%esi
f0103a0c:	7f 05                	jg     f0103a13 <env_alloc+0xde>
		generation = 1 << ENVGENSHIFT;
f0103a0e:	be 00 10 00 00       	mov    $0x1000,%esi
	e->env_id = generation | (e - envs);
f0103a13:	89 d8                	mov    %ebx,%eax
f0103a15:	2b 05 48 22 33 f0    	sub    0xf0332248,%eax
f0103a1b:	c1 f8 02             	sar    $0x2,%eax
f0103a1e:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0103a21:	c1 e1 06             	shl    $0x6,%ecx
f0103a24:	89 ca                	mov    %ecx,%edx
f0103a26:	c1 e2 07             	shl    $0x7,%edx
f0103a29:	29 ca                	sub    %ecx,%edx
f0103a2b:	89 d1                	mov    %edx,%ecx
f0103a2d:	c1 e1 0e             	shl    $0xe,%ecx
f0103a30:	01 ca                	add    %ecx,%edx
f0103a32:	01 c2                	add    %eax,%edx
f0103a34:	8d 04 50             	lea    (%eax,%edx,2),%eax
f0103a37:	09 c6                	or     %eax,%esi
f0103a39:	89 73 48             	mov    %esi,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a3f:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103a42:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103a49:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103a50:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103a57:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103a5e:	00 
f0103a5f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103a66:	00 
f0103a67:	89 1c 24             	mov    %ebx,(%esp)
f0103a6a:	e8 87 26 00 00       	call   f01060f6 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103a6f:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103a75:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103a7b:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103a81:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103a88:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103a8e:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103a95:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103a9c:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103aa0:	8b 43 44             	mov    0x44(%ebx),%eax
f0103aa3:	a3 4c 22 33 f0       	mov    %eax,0xf033224c
	*newenv_store = e;
f0103aa8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103aab:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103aad:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103ab0:	e8 6f 2c 00 00       	call   f0106724 <cpunum>
f0103ab5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103abc:	29 c2                	sub    %eax,%edx
f0103abe:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ac1:	83 3c 85 28 30 33 f0 	cmpl   $0x0,-0xfcccfd8(,%eax,4)
f0103ac8:	00 
f0103ac9:	74 1d                	je     f0103ae8 <env_alloc+0x1b3>
f0103acb:	e8 54 2c 00 00       	call   f0106724 <cpunum>
f0103ad0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ad7:	29 c2                	sub    %eax,%edx
f0103ad9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103adc:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0103ae3:	8b 40 48             	mov    0x48(%eax),%eax
f0103ae6:	eb 05                	jmp    f0103aed <env_alloc+0x1b8>
f0103ae8:	b8 00 00 00 00       	mov    $0x0,%eax
f0103aed:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103af1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103af5:	c7 04 24 0c 83 10 f0 	movl   $0xf010830c,(%esp)
f0103afc:	e8 a1 06 00 00       	call   f01041a2 <cprintf>
	return 0;
f0103b01:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b06:	eb 0c                	jmp    f0103b14 <env_alloc+0x1df>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103b08:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103b0d:	eb 05                	jmp    f0103b14 <env_alloc+0x1df>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103b0f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103b14:	83 c4 10             	add    $0x10,%esp
f0103b17:	5b                   	pop    %ebx
f0103b18:	5e                   	pop    %esi
f0103b19:	5d                   	pop    %ebp
f0103b1a:	c3                   	ret    

f0103b1b <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103b1b:	55                   	push   %ebp
f0103b1c:	89 e5                	mov    %esp,%ebp
f0103b1e:	57                   	push   %edi
f0103b1f:	56                   	push   %esi
f0103b20:	53                   	push   %ebx
f0103b21:	83 ec 3c             	sub    $0x3c,%esp
f0103b24:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *penv;
	// new env's parent ID is set to 0
	env_alloc(&penv, 0);
f0103b27:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103b2e:	00 
f0103b2f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103b32:	89 04 24             	mov    %eax,(%esp)
f0103b35:	e8 fb fd ff ff       	call   f0103935 <env_alloc>
	load_icode(penv, binary);
f0103b3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b3d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// LAB 3: Your code here.
	struct Proghdr *ph, *eph;
	struct Elf *ELFHDR = (struct Elf *)binary;

	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
f0103b40:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103b46:	74 1c                	je     f0103b64 <env_create+0x49>
		panic("load_icode: invalid ELF file!");
f0103b48:	c7 44 24 08 21 83 10 	movl   $0xf0108321,0x8(%esp)
f0103b4f:	f0 
f0103b50:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
f0103b57:	00 
f0103b58:	c7 04 24 01 83 10 f0 	movl   $0xf0108301,(%esp)
f0103b5f:	e8 dc c4 ff ff       	call   f0100040 <_panic>

	// load each program segment
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0103b64:	89 fb                	mov    %edi,%ebx
f0103b66:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f0103b69:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103b6d:	c1 e6 05             	shl    $0x5,%esi
f0103b70:	01 de                	add    %ebx,%esi

	lcr3(PADDR(e->env_pgdir));
f0103b72:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103b75:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103b78:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103b7d:	77 20                	ja     f0103b9f <env_create+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103b7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b83:	c7 44 24 08 24 6e 10 	movl   $0xf0106e24,0x8(%esp)
f0103b8a:	f0 
f0103b8b:	c7 44 24 04 6f 01 00 	movl   $0x16f,0x4(%esp)
f0103b92:	00 
f0103b93:	c7 04 24 01 83 10 f0 	movl   $0xf0108301,(%esp)
f0103b9a:	e8 a1 c4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103b9f:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103ba4:	0f 22 d8             	mov    %eax,%cr3
f0103ba7:	eb 6c                	jmp    f0103c15 <env_create+0xfa>
	for (; ph < eph; ph++) {
		if (ph->p_filesz > ph->p_memsz) panic("load_icode: ph->p_filesz is larger than ph->p_memsz!");
f0103ba9:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103bac:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103baf:	76 1c                	jbe    f0103bcd <env_create+0xb2>
f0103bb1:	c7 44 24 08 cc 82 10 	movl   $0xf01082cc,0x8(%esp)
f0103bb8:	f0 
f0103bb9:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
f0103bc0:	00 
f0103bc1:	c7 04 24 01 83 10 f0 	movl   $0xf0108301,(%esp)
f0103bc8:	e8 73 c4 ff ff       	call   f0100040 <_panic>
		if (ph->p_type == ELF_PROG_LOAD){
f0103bcd:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103bd0:	75 40                	jne    f0103c12 <env_create+0xf7>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103bd2:	8b 53 08             	mov    0x8(%ebx),%edx
f0103bd5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103bd8:	e8 b3 fb ff ff       	call   f0103790 <region_alloc>
			memset((void *)ph->p_va, 0, ph->p_memsz);
f0103bdd:	8b 43 14             	mov    0x14(%ebx),%eax
f0103be0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103be4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103beb:	00 
f0103bec:	8b 43 08             	mov    0x8(%ebx),%eax
f0103bef:	89 04 24             	mov    %eax,(%esp)
f0103bf2:	e8 ff 24 00 00       	call   f01060f6 <memset>
			memcpy((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f0103bf7:	8b 43 10             	mov    0x10(%ebx),%eax
f0103bfa:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103bfe:	89 f8                	mov    %edi,%eax
f0103c00:	03 43 04             	add    0x4(%ebx),%eax
f0103c03:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c07:	8b 43 08             	mov    0x8(%ebx),%eax
f0103c0a:	89 04 24             	mov    %eax,(%esp)
f0103c0d:	e8 98 25 00 00       	call   f01061aa <memcpy>
	// load each program segment
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;

	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++) {
f0103c12:	83 c3 20             	add    $0x20,%ebx
f0103c15:	39 de                	cmp    %ebx,%esi
f0103c17:	77 90                	ja     f0103ba9 <env_create+0x8e>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
			memset((void *)ph->p_va, 0, ph->p_memsz);
			memcpy((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
		}
	}
	lcr3(PADDR(kern_pgdir));
f0103c19:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103c1e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103c23:	77 20                	ja     f0103c45 <env_create+0x12a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c25:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c29:	c7 44 24 08 24 6e 10 	movl   $0xf0106e24,0x8(%esp)
f0103c30:	f0 
f0103c31:	c7 44 24 04 78 01 00 	movl   $0x178,0x4(%esp)
f0103c38:	00 
f0103c39:	c7 04 24 01 83 10 f0 	movl   $0xf0108301,(%esp)
f0103c40:	e8 fb c3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103c45:	05 00 00 00 10       	add    $0x10000000,%eax
f0103c4a:	0f 22 d8             	mov    %eax,%cr3

	// set eip to the program's entry point
	e->env_tf.tf_eip = ELFHDR->e_entry;
f0103c4d:	8b 47 18             	mov    0x18(%edi),%eax
f0103c50:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103c53:	89 42 30             	mov    %eax,0x30(%edx)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103c56:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103c5b:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103c60:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103c63:	e8 28 fb ff ff       	call   f0103790 <region_alloc>
	// LAB 3: Your code here.
	struct Env *penv;
	// new env's parent ID is set to 0
	env_alloc(&penv, 0);
	load_icode(penv, binary);
}
f0103c68:	83 c4 3c             	add    $0x3c,%esp
f0103c6b:	5b                   	pop    %ebx
f0103c6c:	5e                   	pop    %esi
f0103c6d:	5f                   	pop    %edi
f0103c6e:	5d                   	pop    %ebp
f0103c6f:	c3                   	ret    

f0103c70 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103c70:	55                   	push   %ebp
f0103c71:	89 e5                	mov    %esp,%ebp
f0103c73:	57                   	push   %edi
f0103c74:	56                   	push   %esi
f0103c75:	53                   	push   %ebx
f0103c76:	83 ec 2c             	sub    $0x2c,%esp
f0103c79:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103c7c:	e8 a3 2a 00 00       	call   f0106724 <cpunum>
f0103c81:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c88:	29 c2                	sub    %eax,%edx
f0103c8a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c8d:	39 3c 85 28 30 33 f0 	cmp    %edi,-0xfcccfd8(,%eax,4)
f0103c94:	75 34                	jne    f0103cca <env_free+0x5a>
		lcr3(PADDR(kern_pgdir));
f0103c96:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103c9b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ca0:	77 20                	ja     f0103cc2 <env_free+0x52>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ca2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ca6:	c7 44 24 08 24 6e 10 	movl   $0xf0106e24,0x8(%esp)
f0103cad:	f0 
f0103cae:	c7 44 24 04 a3 01 00 	movl   $0x1a3,0x4(%esp)
f0103cb5:	00 
f0103cb6:	c7 04 24 01 83 10 f0 	movl   $0xf0108301,(%esp)
f0103cbd:	e8 7e c3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103cc2:	05 00 00 00 10       	add    $0x10000000,%eax
f0103cc7:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103cca:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103ccd:	e8 52 2a 00 00       	call   f0106724 <cpunum>
f0103cd2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103cd9:	29 c2                	sub    %eax,%edx
f0103cdb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103cde:	83 3c 85 28 30 33 f0 	cmpl   $0x0,-0xfcccfd8(,%eax,4)
f0103ce5:	00 
f0103ce6:	74 1d                	je     f0103d05 <env_free+0x95>
f0103ce8:	e8 37 2a 00 00       	call   f0106724 <cpunum>
f0103ced:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103cf4:	29 c2                	sub    %eax,%edx
f0103cf6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103cf9:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0103d00:	8b 40 48             	mov    0x48(%eax),%eax
f0103d03:	eb 05                	jmp    f0103d0a <env_free+0x9a>
f0103d05:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d0a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103d0e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d12:	c7 04 24 3f 83 10 f0 	movl   $0xf010833f,(%esp)
f0103d19:	e8 84 04 00 00       	call   f01041a2 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103d1e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103d25:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103d28:	c1 e0 02             	shl    $0x2,%eax
f0103d2b:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103d2e:	8b 47 60             	mov    0x60(%edi),%eax
f0103d31:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103d34:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103d37:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103d3d:	0f 84 b6 00 00 00    	je     f0103df9 <env_free+0x189>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103d43:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103d49:	89 f0                	mov    %esi,%eax
f0103d4b:	c1 e8 0c             	shr    $0xc,%eax
f0103d4e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103d51:	3b 05 88 2e 33 f0    	cmp    0xf0332e88,%eax
f0103d57:	72 20                	jb     f0103d79 <env_free+0x109>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103d59:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103d5d:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f0103d64:	f0 
f0103d65:	c7 44 24 04 b2 01 00 	movl   $0x1b2,0x4(%esp)
f0103d6c:	00 
f0103d6d:	c7 04 24 01 83 10 f0 	movl   $0xf0108301,(%esp)
f0103d74:	e8 c7 c2 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103d79:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103d7c:	c1 e2 16             	shl    $0x16,%edx
f0103d7f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103d82:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103d87:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103d8e:	01 
f0103d8f:	74 17                	je     f0103da8 <env_free+0x138>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103d91:	89 d8                	mov    %ebx,%eax
f0103d93:	c1 e0 0c             	shl    $0xc,%eax
f0103d96:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103d99:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d9d:	8b 47 60             	mov    0x60(%edi),%eax
f0103da0:	89 04 24             	mov    %eax,(%esp)
f0103da3:	e8 79 d7 ff ff       	call   f0101521 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103da8:	43                   	inc    %ebx
f0103da9:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103daf:	75 d6                	jne    f0103d87 <env_free+0x117>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103db1:	8b 47 60             	mov    0x60(%edi),%eax
f0103db4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103db7:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103dbe:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103dc1:	3b 05 88 2e 33 f0    	cmp    0xf0332e88,%eax
f0103dc7:	72 1c                	jb     f0103de5 <env_free+0x175>
		panic("pa2page called with invalid pa");
f0103dc9:	c7 44 24 08 34 77 10 	movl   $0xf0107734,0x8(%esp)
f0103dd0:	f0 
f0103dd1:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103dd8:	00 
f0103dd9:	c7 04 24 a1 7f 10 f0 	movl   $0xf0107fa1,(%esp)
f0103de0:	e8 5b c2 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103de5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103de8:	c1 e0 03             	shl    $0x3,%eax
f0103deb:	03 05 90 2e 33 f0    	add    0xf0332e90,%eax
		page_decref(pa2page(pa));
f0103df1:	89 04 24             	mov    %eax,(%esp)
f0103df4:	e8 20 d5 ff ff       	call   f0101319 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103df9:	ff 45 e0             	incl   -0x20(%ebp)
f0103dfc:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103e03:	0f 85 1c ff ff ff    	jne    f0103d25 <env_free+0xb5>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103e09:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e0c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103e11:	77 20                	ja     f0103e33 <env_free+0x1c3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e13:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e17:	c7 44 24 08 24 6e 10 	movl   $0xf0106e24,0x8(%esp)
f0103e1e:	f0 
f0103e1f:	c7 44 24 04 c0 01 00 	movl   $0x1c0,0x4(%esp)
f0103e26:	00 
f0103e27:	c7 04 24 01 83 10 f0 	movl   $0xf0108301,(%esp)
f0103e2e:	e8 0d c2 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103e33:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103e3a:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103e3f:	c1 e8 0c             	shr    $0xc,%eax
f0103e42:	3b 05 88 2e 33 f0    	cmp    0xf0332e88,%eax
f0103e48:	72 1c                	jb     f0103e66 <env_free+0x1f6>
		panic("pa2page called with invalid pa");
f0103e4a:	c7 44 24 08 34 77 10 	movl   $0xf0107734,0x8(%esp)
f0103e51:	f0 
f0103e52:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103e59:	00 
f0103e5a:	c7 04 24 a1 7f 10 f0 	movl   $0xf0107fa1,(%esp)
f0103e61:	e8 da c1 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103e66:	c1 e0 03             	shl    $0x3,%eax
f0103e69:	03 05 90 2e 33 f0    	add    0xf0332e90,%eax
	page_decref(pa2page(pa));
f0103e6f:	89 04 24             	mov    %eax,(%esp)
f0103e72:	e8 a2 d4 ff ff       	call   f0101319 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103e77:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103e7e:	a1 4c 22 33 f0       	mov    0xf033224c,%eax
f0103e83:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103e86:	89 3d 4c 22 33 f0    	mov    %edi,0xf033224c
}
f0103e8c:	83 c4 2c             	add    $0x2c,%esp
f0103e8f:	5b                   	pop    %ebx
f0103e90:	5e                   	pop    %esi
f0103e91:	5f                   	pop    %edi
f0103e92:	5d                   	pop    %ebp
f0103e93:	c3                   	ret    

f0103e94 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103e94:	55                   	push   %ebp
f0103e95:	89 e5                	mov    %esp,%ebp
f0103e97:	53                   	push   %ebx
f0103e98:	83 ec 14             	sub    $0x14,%esp
f0103e9b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103e9e:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103ea2:	75 23                	jne    f0103ec7 <env_destroy+0x33>
f0103ea4:	e8 7b 28 00 00       	call   f0106724 <cpunum>
f0103ea9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103eb0:	29 c2                	sub    %eax,%edx
f0103eb2:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103eb5:	39 1c 85 28 30 33 f0 	cmp    %ebx,-0xfcccfd8(,%eax,4)
f0103ebc:	74 09                	je     f0103ec7 <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103ebe:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103ec5:	eb 39                	jmp    f0103f00 <env_destroy+0x6c>
	}

	env_free(e);
f0103ec7:	89 1c 24             	mov    %ebx,(%esp)
f0103eca:	e8 a1 fd ff ff       	call   f0103c70 <env_free>

	if (curenv == e) {
f0103ecf:	e8 50 28 00 00       	call   f0106724 <cpunum>
f0103ed4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103edb:	29 c2                	sub    %eax,%edx
f0103edd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ee0:	39 1c 85 28 30 33 f0 	cmp    %ebx,-0xfcccfd8(,%eax,4)
f0103ee7:	75 17                	jne    f0103f00 <env_destroy+0x6c>
		curenv = NULL;
f0103ee9:	e8 36 28 00 00       	call   f0106724 <cpunum>
f0103eee:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ef1:	c7 80 28 30 33 f0 00 	movl   $0x0,-0xfcccfd8(%eax)
f0103ef8:	00 00 00 
		sched_yield();
f0103efb:	e8 e1 0c 00 00       	call   f0104be1 <sched_yield>
	}
}
f0103f00:	83 c4 14             	add    $0x14,%esp
f0103f03:	5b                   	pop    %ebx
f0103f04:	5d                   	pop    %ebp
f0103f05:	c3                   	ret    

f0103f06 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103f06:	55                   	push   %ebp
f0103f07:	89 e5                	mov    %esp,%ebp
f0103f09:	53                   	push   %ebx
f0103f0a:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103f0d:	e8 12 28 00 00       	call   f0106724 <cpunum>
f0103f12:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103f19:	29 c2                	sub    %eax,%edx
f0103f1b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103f1e:	8b 1c 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%ebx
f0103f25:	e8 fa 27 00 00       	call   f0106724 <cpunum>
f0103f2a:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103f2d:	8b 65 08             	mov    0x8(%ebp),%esp
f0103f30:	61                   	popa   
f0103f31:	07                   	pop    %es
f0103f32:	1f                   	pop    %ds
f0103f33:	83 c4 08             	add    $0x8,%esp
f0103f36:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103f37:	c7 44 24 08 55 83 10 	movl   $0xf0108355,0x8(%esp)
f0103f3e:	f0 
f0103f3f:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
f0103f46:	00 
f0103f47:	c7 04 24 01 83 10 f0 	movl   $0xf0108301,(%esp)
f0103f4e:	e8 ed c0 ff ff       	call   f0100040 <_panic>

f0103f53 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103f53:	55                   	push   %ebp
f0103f54:	89 e5                	mov    %esp,%ebp
f0103f56:	53                   	push   %ebx
f0103f57:	83 ec 14             	sub    $0x14,%esp
f0103f5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv != e) {
f0103f5d:	e8 c2 27 00 00       	call   f0106724 <cpunum>
f0103f62:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103f69:	29 c2                	sub    %eax,%edx
f0103f6b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103f6e:	39 1c 85 28 30 33 f0 	cmp    %ebx,-0xfcccfd8(,%eax,4)
f0103f75:	0f 84 c8 00 00 00    	je     f0104043 <env_run+0xf0>
		if (curenv && curenv->env_status == ENV_RUNNING)
f0103f7b:	e8 a4 27 00 00       	call   f0106724 <cpunum>
f0103f80:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103f87:	29 c2                	sub    %eax,%edx
f0103f89:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103f8c:	83 3c 85 28 30 33 f0 	cmpl   $0x0,-0xfcccfd8(,%eax,4)
f0103f93:	00 
f0103f94:	74 29                	je     f0103fbf <env_run+0x6c>
f0103f96:	e8 89 27 00 00       	call   f0106724 <cpunum>
f0103f9b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f9e:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f0103fa4:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103fa8:	75 15                	jne    f0103fbf <env_run+0x6c>
			curenv->env_status = ENV_RUNNABLE;
f0103faa:	e8 75 27 00 00       	call   f0106724 <cpunum>
f0103faf:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fb2:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f0103fb8:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		curenv = e;
f0103fbf:	e8 60 27 00 00       	call   f0106724 <cpunum>
f0103fc4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103fcb:	29 c2                	sub    %eax,%edx
f0103fcd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103fd0:	89 1c 85 28 30 33 f0 	mov    %ebx,-0xfcccfd8(,%eax,4)
		curenv->env_status = ENV_RUNNING;
f0103fd7:	e8 48 27 00 00       	call   f0106724 <cpunum>
f0103fdc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103fe3:	29 c2                	sub    %eax,%edx
f0103fe5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103fe8:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0103fef:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs++;
f0103ff6:	e8 29 27 00 00       	call   f0106724 <cpunum>
f0103ffb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104002:	29 c2                	sub    %eax,%edx
f0104004:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104007:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f010400e:	ff 40 58             	incl   0x58(%eax)
		lcr3(PADDR(e->env_pgdir));
f0104011:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104014:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104019:	77 20                	ja     f010403b <env_run+0xe8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010401b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010401f:	c7 44 24 08 24 6e 10 	movl   $0xf0106e24,0x8(%esp)
f0104026:	f0 
f0104027:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
f010402e:	00 
f010402f:	c7 04 24 01 83 10 f0 	movl   $0xf0108301,(%esp)
f0104036:	e8 05 c0 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010403b:	05 00 00 00 10       	add    $0x10000000,%eax
f0104040:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104043:	c7 04 24 60 a4 12 f0 	movl   $0xf012a460,(%esp)
f010404a:	e8 37 2a 00 00       	call   f0106a86 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010404f:	f3 90                	pause  
	}
	unlock_kernel();
	env_pop_tf(&e->env_tf);
f0104051:	89 1c 24             	mov    %ebx,(%esp)
f0104054:	e8 ad fe ff ff       	call   f0103f06 <env_pop_tf>
f0104059:	00 00                	add    %al,(%eax)
	...

f010405c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010405c:	55                   	push   %ebp
f010405d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010405f:	ba 70 00 00 00       	mov    $0x70,%edx
f0104064:	8b 45 08             	mov    0x8(%ebp),%eax
f0104067:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0104068:	b2 71                	mov    $0x71,%dl
f010406a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010406b:	0f b6 c0             	movzbl %al,%eax
}
f010406e:	5d                   	pop    %ebp
f010406f:	c3                   	ret    

f0104070 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0104070:	55                   	push   %ebp
f0104071:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104073:	ba 70 00 00 00       	mov    $0x70,%edx
f0104078:	8b 45 08             	mov    0x8(%ebp),%eax
f010407b:	ee                   	out    %al,(%dx)
f010407c:	b2 71                	mov    $0x71,%dl
f010407e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104081:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0104082:	5d                   	pop    %ebp
f0104083:	c3                   	ret    

f0104084 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0104084:	55                   	push   %ebp
f0104085:	89 e5                	mov    %esp,%ebp
f0104087:	56                   	push   %esi
f0104088:	53                   	push   %ebx
f0104089:	83 ec 10             	sub    $0x10,%esp
f010408c:	8b 45 08             	mov    0x8(%ebp),%eax
f010408f:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0104091:	66 a3 a8 a3 12 f0    	mov    %ax,0xf012a3a8
	if (!didinit)
f0104097:	80 3d 50 22 33 f0 00 	cmpb   $0x0,0xf0332250
f010409e:	74 51                	je     f01040f1 <irq_setmask_8259A+0x6d>
f01040a0:	ba 21 00 00 00       	mov    $0x21,%edx
f01040a5:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f01040a6:	89 f0                	mov    %esi,%eax
f01040a8:	66 c1 e8 08          	shr    $0x8,%ax
f01040ac:	b2 a1                	mov    $0xa1,%dl
f01040ae:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01040af:	c7 04 24 61 83 10 f0 	movl   $0xf0108361,(%esp)
f01040b6:	e8 e7 00 00 00       	call   f01041a2 <cprintf>
	for (i = 0; i < 16; i++)
f01040bb:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01040c0:	0f b7 f6             	movzwl %si,%esi
f01040c3:	f7 d6                	not    %esi
f01040c5:	89 f0                	mov    %esi,%eax
f01040c7:	88 d9                	mov    %bl,%cl
f01040c9:	d3 f8                	sar    %cl,%eax
f01040cb:	a8 01                	test   $0x1,%al
f01040cd:	74 10                	je     f01040df <irq_setmask_8259A+0x5b>
			cprintf(" %d", i);
f01040cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01040d3:	c7 04 24 8b 88 10 f0 	movl   $0xf010888b,(%esp)
f01040da:	e8 c3 00 00 00       	call   f01041a2 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01040df:	43                   	inc    %ebx
f01040e0:	83 fb 10             	cmp    $0x10,%ebx
f01040e3:	75 e0                	jne    f01040c5 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01040e5:	c7 04 24 75 82 10 f0 	movl   $0xf0108275,(%esp)
f01040ec:	e8 b1 00 00 00       	call   f01041a2 <cprintf>
}
f01040f1:	83 c4 10             	add    $0x10,%esp
f01040f4:	5b                   	pop    %ebx
f01040f5:	5e                   	pop    %esi
f01040f6:	5d                   	pop    %ebp
f01040f7:	c3                   	ret    

f01040f8 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01040f8:	55                   	push   %ebp
f01040f9:	89 e5                	mov    %esp,%ebp
f01040fb:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f01040fe:	c6 05 50 22 33 f0 01 	movb   $0x1,0xf0332250
f0104105:	ba 21 00 00 00       	mov    $0x21,%edx
f010410a:	b0 ff                	mov    $0xff,%al
f010410c:	ee                   	out    %al,(%dx)
f010410d:	b2 a1                	mov    $0xa1,%dl
f010410f:	ee                   	out    %al,(%dx)
f0104110:	b2 20                	mov    $0x20,%dl
f0104112:	b0 11                	mov    $0x11,%al
f0104114:	ee                   	out    %al,(%dx)
f0104115:	b2 21                	mov    $0x21,%dl
f0104117:	b0 20                	mov    $0x20,%al
f0104119:	ee                   	out    %al,(%dx)
f010411a:	b0 04                	mov    $0x4,%al
f010411c:	ee                   	out    %al,(%dx)
f010411d:	b0 03                	mov    $0x3,%al
f010411f:	ee                   	out    %al,(%dx)
f0104120:	b2 a0                	mov    $0xa0,%dl
f0104122:	b0 11                	mov    $0x11,%al
f0104124:	ee                   	out    %al,(%dx)
f0104125:	b2 a1                	mov    $0xa1,%dl
f0104127:	b0 28                	mov    $0x28,%al
f0104129:	ee                   	out    %al,(%dx)
f010412a:	b0 02                	mov    $0x2,%al
f010412c:	ee                   	out    %al,(%dx)
f010412d:	b0 01                	mov    $0x1,%al
f010412f:	ee                   	out    %al,(%dx)
f0104130:	b2 20                	mov    $0x20,%dl
f0104132:	b0 68                	mov    $0x68,%al
f0104134:	ee                   	out    %al,(%dx)
f0104135:	b0 0a                	mov    $0xa,%al
f0104137:	ee                   	out    %al,(%dx)
f0104138:	b2 a0                	mov    $0xa0,%dl
f010413a:	b0 68                	mov    $0x68,%al
f010413c:	ee                   	out    %al,(%dx)
f010413d:	b0 0a                	mov    $0xa,%al
f010413f:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0104140:	66 a1 a8 a3 12 f0    	mov    0xf012a3a8,%ax
f0104146:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f010414a:	74 0b                	je     f0104157 <pic_init+0x5f>
		irq_setmask_8259A(irq_mask_8259A);
f010414c:	0f b7 c0             	movzwl %ax,%eax
f010414f:	89 04 24             	mov    %eax,(%esp)
f0104152:	e8 2d ff ff ff       	call   f0104084 <irq_setmask_8259A>
}
f0104157:	c9                   	leave  
f0104158:	c3                   	ret    
f0104159:	00 00                	add    %al,(%eax)
	...

f010415c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010415c:	55                   	push   %ebp
f010415d:	89 e5                	mov    %esp,%ebp
f010415f:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0104162:	8b 45 08             	mov    0x8(%ebp),%eax
f0104165:	89 04 24             	mov    %eax,(%esp)
f0104168:	e8 fe c5 ff ff       	call   f010076b <cputchar>
	*cnt++;
}
f010416d:	c9                   	leave  
f010416e:	c3                   	ret    

f010416f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010416f:	55                   	push   %ebp
f0104170:	89 e5                	mov    %esp,%ebp
f0104172:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0104175:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010417c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010417f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104183:	8b 45 08             	mov    0x8(%ebp),%eax
f0104186:	89 44 24 08          	mov    %eax,0x8(%esp)
f010418a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010418d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104191:	c7 04 24 5c 41 10 f0 	movl   $0xf010415c,(%esp)
f0104198:	e8 47 19 00 00       	call   f0105ae4 <vprintfmt>
	return cnt;
}
f010419d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01041a0:	c9                   	leave  
f01041a1:	c3                   	ret    

f01041a2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01041a2:	55                   	push   %ebp
f01041a3:	89 e5                	mov    %esp,%ebp
f01041a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01041a8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01041ab:	89 44 24 04          	mov    %eax,0x4(%esp)
f01041af:	8b 45 08             	mov    0x8(%ebp),%eax
f01041b2:	89 04 24             	mov    %eax,(%esp)
f01041b5:	e8 b5 ff ff ff       	call   f010416f <vcprintf>
	va_end(ap);

	return cnt;
}
f01041ba:	c9                   	leave  
f01041bb:	c3                   	ret    

f01041bc <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01041bc:	55                   	push   %ebp
f01041bd:	89 e5                	mov    %esp,%ebp
f01041bf:	57                   	push   %edi
f01041c0:	56                   	push   %esi
f01041c1:	53                   	push   %ebx
f01041c2:	83 ec 0c             	sub    $0xc,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int cid = thiscpu->cpu_id;
f01041c5:	e8 5a 25 00 00       	call   f0106724 <cpunum>
f01041ca:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01041d1:	29 c2                	sub    %eax,%edx
f01041d3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01041d6:	0f b6 1c 85 20 30 33 	movzbl -0xfcccfe0(,%eax,4),%ebx
f01041dd:	f0 

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cid * (KSTKSIZE + KSTKGAP);
f01041de:	e8 41 25 00 00       	call   f0106724 <cpunum>
f01041e3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01041ea:	29 c2                	sub    %eax,%edx
f01041ec:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01041ef:	89 da                	mov    %ebx,%edx
f01041f1:	f7 da                	neg    %edx
f01041f3:	c1 e2 10             	shl    $0x10,%edx
f01041f6:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01041fc:	89 14 85 30 30 33 f0 	mov    %edx,-0xfcccfd0(,%eax,4)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0104203:	e8 1c 25 00 00       	call   f0106724 <cpunum>
f0104208:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010420f:	29 c2                	sub    %eax,%edx
f0104211:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104214:	66 c7 04 85 34 30 33 	movw   $0x10,-0xfcccfcc(,%eax,4)
f010421b:	f0 10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cid] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f010421e:	83 c3 05             	add    $0x5,%ebx
f0104221:	e8 fe 24 00 00       	call   f0106724 <cpunum>
f0104226:	89 c6                	mov    %eax,%esi
f0104228:	e8 f7 24 00 00       	call   f0106724 <cpunum>
f010422d:	89 c7                	mov    %eax,%edi
f010422f:	e8 f0 24 00 00       	call   f0106724 <cpunum>
f0104234:	66 c7 04 dd 40 a3 12 	movw   $0x67,-0xfed5cc0(,%ebx,8)
f010423b:	f0 67 00 
f010423e:	8d 14 f5 00 00 00 00 	lea    0x0(,%esi,8),%edx
f0104245:	29 f2                	sub    %esi,%edx
f0104247:	8d 14 96             	lea    (%esi,%edx,4),%edx
f010424a:	8d 14 95 2c 30 33 f0 	lea    -0xfcccfd4(,%edx,4),%edx
f0104251:	66 89 14 dd 42 a3 12 	mov    %dx,-0xfed5cbe(,%ebx,8)
f0104258:	f0 
f0104259:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0104260:	29 fa                	sub    %edi,%edx
f0104262:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104265:	8d 14 95 2c 30 33 f0 	lea    -0xfcccfd4(,%edx,4),%edx
f010426c:	c1 ea 10             	shr    $0x10,%edx
f010426f:	88 14 dd 44 a3 12 f0 	mov    %dl,-0xfed5cbc(,%ebx,8)
f0104276:	c6 04 dd 46 a3 12 f0 	movb   $0x40,-0xfed5cba(,%ebx,8)
f010427d:	40 
f010427e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104285:	29 c2                	sub    %eax,%edx
f0104287:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010428a:	8d 04 85 2c 30 33 f0 	lea    -0xfcccfd4(,%eax,4),%eax
f0104291:	c1 e8 18             	shr    $0x18,%eax
f0104294:	88 04 dd 47 a3 12 f0 	mov    %al,-0xfed5cb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cid].sd_s = 0;
f010429b:	c6 04 dd 45 a3 12 f0 	movb   $0x89,-0xfed5cbb(,%ebx,8)
f01042a2:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + 8 * cid);
f01042a3:	c1 e3 03             	shl    $0x3,%ebx
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01042a6:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01042a9:	b8 ac a3 12 f0       	mov    $0xf012a3ac,%eax
f01042ae:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f01042b1:	83 c4 0c             	add    $0xc,%esp
f01042b4:	5b                   	pop    %ebx
f01042b5:	5e                   	pop    %esi
f01042b6:	5f                   	pop    %edi
f01042b7:	5d                   	pop    %ebp
f01042b8:	c3                   	ret    

f01042b9 <trap_init>:
}


void
trap_init(void)
{
f01042b9:	55                   	push   %ebp
f01042ba:	89 e5                	mov    %esp,%ebp
f01042bc:	83 ec 08             	sub    $0x8,%esp

	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall_handler, 3);
*/
	extern void (*t_handler[])();
	int i;
	for (i = 0; i < 20; i++) {
f01042bf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (i == T_BRKPT) {
f01042c4:	83 f8 03             	cmp    $0x3,%eax
f01042c7:	75 33                	jne    f01042fc <trap_init+0x43>
			SETGATE(idt[i], 0, GD_KT, t_handler[i], 3);
f01042c9:	8b 15 c0 a3 12 f0    	mov    0xf012a3c0,%edx
f01042cf:	66 89 15 78 22 33 f0 	mov    %dx,0xf0332278
f01042d6:	66 c7 05 7a 22 33 f0 	movw   $0x8,0xf033227a
f01042dd:	08 00 
f01042df:	c6 05 7c 22 33 f0 00 	movb   $0x0,0xf033227c
f01042e6:	c6 05 7d 22 33 f0 ee 	movb   $0xee,0xf033227d
f01042ed:	c1 ea 10             	shr    $0x10,%edx
f01042f0:	66 89 15 7e 22 33 f0 	mov    %dx,0xf033227e
f01042f7:	e9 c1 00 00 00       	jmp    f01043bd <trap_init+0x104>
		}
		else if (i !=9 && i != 15) {
f01042fc:	83 f8 09             	cmp    $0x9,%eax
f01042ff:	0f 84 b8 00 00 00    	je     f01043bd <trap_init+0x104>
f0104305:	83 f8 0f             	cmp    $0xf,%eax
f0104308:	0f 84 af 00 00 00    	je     f01043bd <trap_init+0x104>
			SETGATE(idt[i], 0, GD_KT, t_handler[i], 0);
f010430e:	8b 14 85 b4 a3 12 f0 	mov    -0xfed5c4c(,%eax,4),%edx
f0104315:	66 89 14 c5 60 22 33 	mov    %dx,-0xfccdda0(,%eax,8)
f010431c:	f0 
f010431d:	66 c7 04 c5 62 22 33 	movw   $0x8,-0xfccdd9e(,%eax,8)
f0104324:	f0 08 00 
f0104327:	c6 04 c5 64 22 33 f0 	movb   $0x0,-0xfccdd9c(,%eax,8)
f010432e:	00 
f010432f:	c6 04 c5 65 22 33 f0 	movb   $0x8e,-0xfccdd9b(,%eax,8)
f0104336:	8e 
f0104337:	c1 ea 10             	shr    $0x10,%edx
f010433a:	66 89 14 c5 66 22 33 	mov    %dx,-0xfccdd9a(,%eax,8)
f0104341:	f0 

	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall_handler, 3);
*/
	extern void (*t_handler[])();
	int i;
	for (i = 0; i < 20; i++) {
f0104342:	40                   	inc    %eax
f0104343:	83 f8 14             	cmp    $0x14,%eax
f0104346:	0f 85 78 ff ff ff    	jne    f01042c4 <trap_init+0xb>
		}
		else if (i !=9 && i != 15) {
			SETGATE(idt[i], 0, GD_KT, t_handler[i], 0);
		}
	}
	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_handler[20], 3);
f010434c:	a1 04 a4 12 f0       	mov    0xf012a404,%eax
f0104351:	66 a3 e0 23 33 f0    	mov    %ax,0xf03323e0
f0104357:	66 c7 05 e2 23 33 f0 	movw   $0x8,0xf03323e2
f010435e:	08 00 
f0104360:	c6 05 e4 23 33 f0 00 	movb   $0x0,0xf03323e4
f0104367:	c6 05 e5 23 33 f0 ee 	movb   $0xee,0xf03323e5
f010436e:	c1 e8 10             	shr    $0x10,%eax
f0104371:	66 a3 e6 23 33 f0    	mov    %ax,0xf03323e6
f0104377:	b8 20 00 00 00       	mov    $0x20,%eax
	for (i = 0; i < 16; i++) {
		SETGATE(idt[IRQ_OFFSET + i], 0, GD_KT, t_handler[21 + i], 0);
f010437c:	8b 14 85 88 a3 12 f0 	mov    -0xfed5c78(,%eax,4),%edx
f0104383:	66 89 14 c5 60 22 33 	mov    %dx,-0xfccdda0(,%eax,8)
f010438a:	f0 
f010438b:	66 c7 04 c5 62 22 33 	movw   $0x8,-0xfccdd9e(,%eax,8)
f0104392:	f0 08 00 
f0104395:	c6 04 c5 64 22 33 f0 	movb   $0x0,-0xfccdd9c(,%eax,8)
f010439c:	00 
f010439d:	c6 04 c5 65 22 33 f0 	movb   $0x8e,-0xfccdd9b(,%eax,8)
f01043a4:	8e 
f01043a5:	c1 ea 10             	shr    $0x10,%edx
f01043a8:	66 89 14 c5 66 22 33 	mov    %dx,-0xfccdd9a(,%eax,8)
f01043af:	f0 
f01043b0:	40                   	inc    %eax
		else if (i !=9 && i != 15) {
			SETGATE(idt[i], 0, GD_KT, t_handler[i], 0);
		}
	}
	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_handler[20], 3);
	for (i = 0; i < 16; i++) {
f01043b1:	83 f8 30             	cmp    $0x30,%eax
f01043b4:	75 c6                	jne    f010437c <trap_init+0xc3>
		SETGATE(idt[IRQ_OFFSET + i], 0, GD_KT, t_handler[21 + i], 0);
	}
	// Per-CPU setup
	trap_init_percpu();
f01043b6:	e8 01 fe ff ff       	call   f01041bc <trap_init_percpu>
}
f01043bb:	c9                   	leave  
f01043bc:	c3                   	ret    

	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall_handler, 3);
*/
	extern void (*t_handler[])();
	int i;
	for (i = 0; i < 20; i++) {
f01043bd:	40                   	inc    %eax
f01043be:	e9 01 ff ff ff       	jmp    f01042c4 <trap_init+0xb>

f01043c3 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01043c3:	55                   	push   %ebp
f01043c4:	89 e5                	mov    %esp,%ebp
f01043c6:	53                   	push   %ebx
f01043c7:	83 ec 14             	sub    $0x14,%esp
f01043ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01043cd:	8b 03                	mov    (%ebx),%eax
f01043cf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043d3:	c7 04 24 75 83 10 f0 	movl   $0xf0108375,(%esp)
f01043da:	e8 c3 fd ff ff       	call   f01041a2 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01043df:	8b 43 04             	mov    0x4(%ebx),%eax
f01043e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043e6:	c7 04 24 84 83 10 f0 	movl   $0xf0108384,(%esp)
f01043ed:	e8 b0 fd ff ff       	call   f01041a2 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01043f2:	8b 43 08             	mov    0x8(%ebx),%eax
f01043f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043f9:	c7 04 24 93 83 10 f0 	movl   $0xf0108393,(%esp)
f0104400:	e8 9d fd ff ff       	call   f01041a2 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104405:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104408:	89 44 24 04          	mov    %eax,0x4(%esp)
f010440c:	c7 04 24 a2 83 10 f0 	movl   $0xf01083a2,(%esp)
f0104413:	e8 8a fd ff ff       	call   f01041a2 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104418:	8b 43 10             	mov    0x10(%ebx),%eax
f010441b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010441f:	c7 04 24 b1 83 10 f0 	movl   $0xf01083b1,(%esp)
f0104426:	e8 77 fd ff ff       	call   f01041a2 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010442b:	8b 43 14             	mov    0x14(%ebx),%eax
f010442e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104432:	c7 04 24 c0 83 10 f0 	movl   $0xf01083c0,(%esp)
f0104439:	e8 64 fd ff ff       	call   f01041a2 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010443e:	8b 43 18             	mov    0x18(%ebx),%eax
f0104441:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104445:	c7 04 24 cf 83 10 f0 	movl   $0xf01083cf,(%esp)
f010444c:	e8 51 fd ff ff       	call   f01041a2 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104451:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104454:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104458:	c7 04 24 de 83 10 f0 	movl   $0xf01083de,(%esp)
f010445f:	e8 3e fd ff ff       	call   f01041a2 <cprintf>
}
f0104464:	83 c4 14             	add    $0x14,%esp
f0104467:	5b                   	pop    %ebx
f0104468:	5d                   	pop    %ebp
f0104469:	c3                   	ret    

f010446a <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010446a:	55                   	push   %ebp
f010446b:	89 e5                	mov    %esp,%ebp
f010446d:	53                   	push   %ebx
f010446e:	83 ec 14             	sub    $0x14,%esp
f0104471:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104474:	e8 ab 22 00 00       	call   f0106724 <cpunum>
f0104479:	89 44 24 08          	mov    %eax,0x8(%esp)
f010447d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104481:	c7 04 24 42 84 10 f0 	movl   $0xf0108442,(%esp)
f0104488:	e8 15 fd ff ff       	call   f01041a2 <cprintf>
	print_regs(&tf->tf_regs);
f010448d:	89 1c 24             	mov    %ebx,(%esp)
f0104490:	e8 2e ff ff ff       	call   f01043c3 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104495:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104499:	89 44 24 04          	mov    %eax,0x4(%esp)
f010449d:	c7 04 24 60 84 10 f0 	movl   $0xf0108460,(%esp)
f01044a4:	e8 f9 fc ff ff       	call   f01041a2 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01044a9:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01044ad:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044b1:	c7 04 24 73 84 10 f0 	movl   $0xf0108473,(%esp)
f01044b8:	e8 e5 fc ff ff       	call   f01041a2 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01044bd:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01044c0:	83 f8 13             	cmp    $0x13,%eax
f01044c3:	77 09                	ja     f01044ce <print_trapframe+0x64>
		return excnames[trapno];
f01044c5:	8b 14 85 00 87 10 f0 	mov    -0xfef7900(,%eax,4),%edx
f01044cc:	eb 20                	jmp    f01044ee <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f01044ce:	83 f8 30             	cmp    $0x30,%eax
f01044d1:	74 0f                	je     f01044e2 <print_trapframe+0x78>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01044d3:	8d 50 e0             	lea    -0x20(%eax),%edx
f01044d6:	83 fa 0f             	cmp    $0xf,%edx
f01044d9:	77 0e                	ja     f01044e9 <print_trapframe+0x7f>
		return "Hardware Interrupt";
f01044db:	ba f9 83 10 f0       	mov    $0xf01083f9,%edx
f01044e0:	eb 0c                	jmp    f01044ee <print_trapframe+0x84>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01044e2:	ba ed 83 10 f0       	mov    $0xf01083ed,%edx
f01044e7:	eb 05                	jmp    f01044ee <print_trapframe+0x84>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
f01044e9:	ba 0c 84 10 f0       	mov    $0xf010840c,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01044ee:	89 54 24 08          	mov    %edx,0x8(%esp)
f01044f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044f6:	c7 04 24 86 84 10 f0 	movl   $0xf0108486,(%esp)
f01044fd:	e8 a0 fc ff ff       	call   f01041a2 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104502:	3b 1d 60 2a 33 f0    	cmp    0xf0332a60,%ebx
f0104508:	75 19                	jne    f0104523 <print_trapframe+0xb9>
f010450a:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010450e:	75 13                	jne    f0104523 <print_trapframe+0xb9>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104510:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104513:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104517:	c7 04 24 98 84 10 f0 	movl   $0xf0108498,(%esp)
f010451e:	e8 7f fc ff ff       	call   f01041a2 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104523:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104526:	89 44 24 04          	mov    %eax,0x4(%esp)
f010452a:	c7 04 24 a7 84 10 f0 	movl   $0xf01084a7,(%esp)
f0104531:	e8 6c fc ff ff       	call   f01041a2 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104536:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010453a:	75 4d                	jne    f0104589 <print_trapframe+0x11f>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010453c:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010453f:	a8 01                	test   $0x1,%al
f0104541:	74 07                	je     f010454a <print_trapframe+0xe0>
f0104543:	b9 1b 84 10 f0       	mov    $0xf010841b,%ecx
f0104548:	eb 05                	jmp    f010454f <print_trapframe+0xe5>
f010454a:	b9 26 84 10 f0       	mov    $0xf0108426,%ecx
f010454f:	a8 02                	test   $0x2,%al
f0104551:	74 07                	je     f010455a <print_trapframe+0xf0>
f0104553:	ba 32 84 10 f0       	mov    $0xf0108432,%edx
f0104558:	eb 05                	jmp    f010455f <print_trapframe+0xf5>
f010455a:	ba 38 84 10 f0       	mov    $0xf0108438,%edx
f010455f:	a8 04                	test   $0x4,%al
f0104561:	74 07                	je     f010456a <print_trapframe+0x100>
f0104563:	b8 3d 84 10 f0       	mov    $0xf010843d,%eax
f0104568:	eb 05                	jmp    f010456f <print_trapframe+0x105>
f010456a:	b8 8d 85 10 f0       	mov    $0xf010858d,%eax
f010456f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104573:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104577:	89 44 24 04          	mov    %eax,0x4(%esp)
f010457b:	c7 04 24 b5 84 10 f0 	movl   $0xf01084b5,(%esp)
f0104582:	e8 1b fc ff ff       	call   f01041a2 <cprintf>
f0104587:	eb 0c                	jmp    f0104595 <print_trapframe+0x12b>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104589:	c7 04 24 75 82 10 f0 	movl   $0xf0108275,(%esp)
f0104590:	e8 0d fc ff ff       	call   f01041a2 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104595:	8b 43 30             	mov    0x30(%ebx),%eax
f0104598:	89 44 24 04          	mov    %eax,0x4(%esp)
f010459c:	c7 04 24 c4 84 10 f0 	movl   $0xf01084c4,(%esp)
f01045a3:	e8 fa fb ff ff       	call   f01041a2 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01045a8:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01045ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045b0:	c7 04 24 d3 84 10 f0 	movl   $0xf01084d3,(%esp)
f01045b7:	e8 e6 fb ff ff       	call   f01041a2 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01045bc:	8b 43 38             	mov    0x38(%ebx),%eax
f01045bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045c3:	c7 04 24 e6 84 10 f0 	movl   $0xf01084e6,(%esp)
f01045ca:	e8 d3 fb ff ff       	call   f01041a2 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01045cf:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01045d3:	74 27                	je     f01045fc <print_trapframe+0x192>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01045d5:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01045d8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045dc:	c7 04 24 f5 84 10 f0 	movl   $0xf01084f5,(%esp)
f01045e3:	e8 ba fb ff ff       	call   f01041a2 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01045e8:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01045ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045f0:	c7 04 24 04 85 10 f0 	movl   $0xf0108504,(%esp)
f01045f7:	e8 a6 fb ff ff       	call   f01041a2 <cprintf>
	}
}
f01045fc:	83 c4 14             	add    $0x14,%esp
f01045ff:	5b                   	pop    %ebx
f0104600:	5d                   	pop    %ebp
f0104601:	c3                   	ret    

f0104602 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104602:	55                   	push   %ebp
f0104603:	89 e5                	mov    %esp,%ebp
f0104605:	57                   	push   %edi
f0104606:	56                   	push   %esi
f0104607:	53                   	push   %ebx
f0104608:	83 ec 2c             	sub    $0x2c,%esp
f010460b:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010460e:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f0104611:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104615:	75 1c                	jne    f0104633 <page_fault_handler+0x31>
		panic("page fault in kernel mode!");
f0104617:	c7 44 24 08 17 85 10 	movl   $0xf0108517,0x8(%esp)
f010461e:	f0 
f010461f:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
f0104626:	00 
f0104627:	c7 04 24 32 85 10 f0 	movl   $0xf0108532,(%esp)
f010462e:	e8 0d ba ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
f0104633:	e8 ec 20 00 00       	call   f0106724 <cpunum>
f0104638:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010463f:	29 c2                	sub    %eax,%edx
f0104641:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104644:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f010464b:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010464f:	0f 84 f0 00 00 00    	je     f0104745 <page_fault_handler+0x143>
		struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
f0104655:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104658:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
							(struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
f010465e:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f0104665:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010466b:	77 06                	ja     f0104673 <page_fault_handler+0x71>
f010466d:	83 e8 38             	sub    $0x38,%eax
f0104670:	89 45 e4             	mov    %eax,-0x1c(%ebp)
							(struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
		// this is a totally wrong statement!
		// struct UTrapframe *utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
		user_mem_assert(curenv, (void *)utf, 1, PTE_W);
f0104673:	e8 ac 20 00 00       	call   f0106724 <cpunum>
f0104678:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010467f:	00 
f0104680:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104687:	00 
f0104688:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010468b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010468f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104692:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f0104698:	89 04 24             	mov    %eax,(%esp)
f010469b:	e8 95 f0 ff ff       	call   f0103735 <user_mem_assert>
		utf->utf_fault_va = fault_va;
f01046a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046a3:	89 30                	mov    %esi,(%eax)
		utf->utf_err = tf->tf_err;
f01046a5:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01046a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01046ab:	89 42 04             	mov    %eax,0x4(%edx)
		utf->utf_regs = tf->tf_regs;
f01046ae:	89 d7                	mov    %edx,%edi
f01046b0:	83 c7 08             	add    $0x8,%edi
f01046b3:	89 de                	mov    %ebx,%esi
f01046b5:	b8 20 00 00 00       	mov    $0x20,%eax
f01046ba:	f7 c7 01 00 00 00    	test   $0x1,%edi
f01046c0:	74 03                	je     f01046c5 <page_fault_handler+0xc3>
f01046c2:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f01046c3:	b0 1f                	mov    $0x1f,%al
f01046c5:	f7 c7 02 00 00 00    	test   $0x2,%edi
f01046cb:	74 05                	je     f01046d2 <page_fault_handler+0xd0>
f01046cd:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01046cf:	83 e8 02             	sub    $0x2,%eax
f01046d2:	89 c1                	mov    %eax,%ecx
f01046d4:	c1 e9 02             	shr    $0x2,%ecx
f01046d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01046d9:	a8 02                	test   $0x2,%al
f01046db:	74 02                	je     f01046df <page_fault_handler+0xdd>
f01046dd:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01046df:	a8 01                	test   $0x1,%al
f01046e1:	74 01                	je     f01046e4 <page_fault_handler+0xe2>
f01046e3:	a4                   	movsb  %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f01046e4:	8b 43 30             	mov    0x30(%ebx),%eax
f01046e7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01046ea:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f01046ed:	8b 43 38             	mov    0x38(%ebx),%eax
f01046f0:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f01046f3:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01046f6:	89 42 30             	mov    %eax,0x30(%edx)
		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f01046f9:	e8 26 20 00 00       	call   f0106724 <cpunum>
f01046fe:	6b c0 74             	imul   $0x74,%eax,%eax
f0104701:	8b 98 28 30 33 f0    	mov    -0xfcccfd8(%eax),%ebx
f0104707:	e8 18 20 00 00       	call   f0106724 <cpunum>
f010470c:	6b c0 74             	imul   $0x74,%eax,%eax
f010470f:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f0104715:	8b 40 64             	mov    0x64(%eax),%eax
f0104718:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = (uintptr_t)utf;
f010471b:	e8 04 20 00 00       	call   f0106724 <cpunum>
f0104720:	6b c0 74             	imul   $0x74,%eax,%eax
f0104723:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f0104729:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010472c:	89 50 3c             	mov    %edx,0x3c(%eax)
		env_run(curenv);
f010472f:	e8 f0 1f 00 00       	call   f0106724 <cpunum>
f0104734:	6b c0 74             	imul   $0x74,%eax,%eax
f0104737:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f010473d:	89 04 24             	mov    %eax,(%esp)
f0104740:	e8 0e f8 ff ff       	call   f0103f53 <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104745:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104748:	e8 d7 1f 00 00       	call   f0106724 <cpunum>
		curenv->env_tf.tf_esp = (uintptr_t)utf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010474d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104751:	89 74 24 08          	mov    %esi,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0104755:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010475c:	29 c2                	sub    %eax,%edx
f010475e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104761:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
		curenv->env_tf.tf_esp = (uintptr_t)utf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104768:	8b 40 48             	mov    0x48(%eax),%eax
f010476b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010476f:	c7 04 24 d8 86 10 f0 	movl   $0xf01086d8,(%esp)
f0104776:	e8 27 fa ff ff       	call   f01041a2 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010477b:	89 1c 24             	mov    %ebx,(%esp)
f010477e:	e8 e7 fc ff ff       	call   f010446a <print_trapframe>
	env_destroy(curenv);
f0104783:	e8 9c 1f 00 00       	call   f0106724 <cpunum>
f0104788:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010478f:	29 c2                	sub    %eax,%edx
f0104791:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104794:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f010479b:	89 04 24             	mov    %eax,(%esp)
f010479e:	e8 f1 f6 ff ff       	call   f0103e94 <env_destroy>
}
f01047a3:	83 c4 2c             	add    $0x2c,%esp
f01047a6:	5b                   	pop    %ebx
f01047a7:	5e                   	pop    %esi
f01047a8:	5f                   	pop    %edi
f01047a9:	5d                   	pop    %ebp
f01047aa:	c3                   	ret    

f01047ab <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01047ab:	55                   	push   %ebp
f01047ac:	89 e5                	mov    %esp,%ebp
f01047ae:	57                   	push   %edi
f01047af:	56                   	push   %esi
f01047b0:	83 ec 20             	sub    $0x20,%esp
f01047b3:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01047b6:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01047b7:	83 3d 80 2e 33 f0 00 	cmpl   $0x0,0xf0332e80
f01047be:	74 01                	je     f01047c1 <trap+0x16>
		asm volatile("hlt");
f01047c0:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01047c1:	e8 5e 1f 00 00       	call   f0106724 <cpunum>
f01047c6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01047cd:	29 c2                	sub    %eax,%edx
f01047cf:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01047d2:	8d 14 85 20 30 33 f0 	lea    -0xfcccfe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01047d9:	b8 01 00 00 00       	mov    $0x1,%eax
f01047de:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01047e2:	83 f8 02             	cmp    $0x2,%eax
f01047e5:	75 0c                	jne    f01047f3 <trap+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01047e7:	c7 04 24 60 a4 12 f0 	movl   $0xf012a460,(%esp)
f01047ee:	e8 f0 21 00 00       	call   f01069e3 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01047f3:	9c                   	pushf  
f01047f4:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01047f5:	f6 c4 02             	test   $0x2,%ah
f01047f8:	74 24                	je     f010481e <trap+0x73>
f01047fa:	c7 44 24 0c 3e 85 10 	movl   $0xf010853e,0xc(%esp)
f0104801:	f0 
f0104802:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f0104809:	f0 
f010480a:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
f0104811:	00 
f0104812:	c7 04 24 32 85 10 f0 	movl   $0xf0108532,(%esp)
f0104819:	e8 22 b8 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010481e:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104822:	83 e0 03             	and    $0x3,%eax
f0104825:	83 f8 03             	cmp    $0x3,%eax
f0104828:	0f 85 a7 00 00 00    	jne    f01048d5 <trap+0x12a>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f010482e:	e8 f1 1e 00 00       	call   f0106724 <cpunum>
f0104833:	6b c0 74             	imul   $0x74,%eax,%eax
f0104836:	83 b8 28 30 33 f0 00 	cmpl   $0x0,-0xfcccfd8(%eax)
f010483d:	75 24                	jne    f0104863 <trap+0xb8>
f010483f:	c7 44 24 0c 57 85 10 	movl   $0xf0108557,0xc(%esp)
f0104846:	f0 
f0104847:	c7 44 24 08 bb 7f 10 	movl   $0xf0107fbb,0x8(%esp)
f010484e:	f0 
f010484f:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
f0104856:	00 
f0104857:	c7 04 24 32 85 10 f0 	movl   $0xf0108532,(%esp)
f010485e:	e8 dd b7 ff ff       	call   f0100040 <_panic>
f0104863:	c7 04 24 60 a4 12 f0 	movl   $0xf012a460,(%esp)
f010486a:	e8 74 21 00 00       	call   f01069e3 <spin_lock>
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010486f:	e8 b0 1e 00 00       	call   f0106724 <cpunum>
f0104874:	6b c0 74             	imul   $0x74,%eax,%eax
f0104877:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f010487d:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104881:	75 2d                	jne    f01048b0 <trap+0x105>
			env_free(curenv);
f0104883:	e8 9c 1e 00 00       	call   f0106724 <cpunum>
f0104888:	6b c0 74             	imul   $0x74,%eax,%eax
f010488b:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f0104891:	89 04 24             	mov    %eax,(%esp)
f0104894:	e8 d7 f3 ff ff       	call   f0103c70 <env_free>
			curenv = NULL;
f0104899:	e8 86 1e 00 00       	call   f0106724 <cpunum>
f010489e:	6b c0 74             	imul   $0x74,%eax,%eax
f01048a1:	c7 80 28 30 33 f0 00 	movl   $0x0,-0xfcccfd8(%eax)
f01048a8:	00 00 00 
			sched_yield();
f01048ab:	e8 31 03 00 00       	call   f0104be1 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01048b0:	e8 6f 1e 00 00       	call   f0106724 <cpunum>
f01048b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01048b8:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f01048be:	b9 11 00 00 00       	mov    $0x11,%ecx
f01048c3:	89 c7                	mov    %eax,%edi
f01048c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01048c7:	e8 58 1e 00 00       	call   f0106724 <cpunum>
f01048cc:	6b c0 74             	imul   $0x74,%eax,%eax
f01048cf:	8b b0 28 30 33 f0    	mov    -0xfcccfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01048d5:	89 35 60 2a 33 f0    	mov    %esi,0xf0332a60
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	switch (tf->tf_trapno) {
f01048db:	8b 46 28             	mov    0x28(%esi),%eax
f01048de:	83 f8 0e             	cmp    $0xe,%eax
f01048e1:	74 0c                	je     f01048ef <trap+0x144>
f01048e3:	83 f8 30             	cmp    $0x30,%eax
f01048e6:	74 21                	je     f0104909 <trap+0x15e>
f01048e8:	83 f8 03             	cmp    $0x3,%eax
f01048eb:	75 4e                	jne    f010493b <trap+0x190>
f01048ed:	eb 0d                	jmp    f01048fc <trap+0x151>
	case T_PGFLT:
		page_fault_handler(tf);
f01048ef:	89 34 24             	mov    %esi,(%esp)
f01048f2:	e8 0b fd ff ff       	call   f0104602 <page_fault_handler>
f01048f7:	e9 aa 00 00 00       	jmp    f01049a6 <trap+0x1fb>
		return;
	case T_BRKPT:
		monitor(tf);
f01048fc:	89 34 24             	mov    %esi,(%esp)
f01048ff:	e8 da c2 ff ff       	call   f0100bde <monitor>
f0104904:	e9 9d 00 00 00       	jmp    f01049a6 <trap+0x1fb>
		return;
	case T_SYSCALL:
		// we should put the return value in %eax
		tf->tf_regs.reg_eax =
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0104909:	8b 46 04             	mov    0x4(%esi),%eax
f010490c:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104910:	8b 06                	mov    (%esi),%eax
f0104912:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104916:	8b 46 10             	mov    0x10(%esi),%eax
f0104919:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010491d:	8b 46 18             	mov    0x18(%esi),%eax
f0104920:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104924:	8b 46 14             	mov    0x14(%esi),%eax
f0104927:	89 44 24 04          	mov    %eax,0x4(%esp)
f010492b:	8b 46 1c             	mov    0x1c(%esi),%eax
f010492e:	89 04 24             	mov    %eax,(%esp)
f0104931:	e8 a5 03 00 00       	call   f0104cdb <syscall>
	case T_BRKPT:
		monitor(tf);
		return;
	case T_SYSCALL:
		// we should put the return value in %eax
		tf->tf_regs.reg_eax =
f0104936:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104939:	eb 6b                	jmp    f01049a6 <trap+0x1fb>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010493b:	83 f8 27             	cmp    $0x27,%eax
f010493e:	75 16                	jne    f0104956 <trap+0x1ab>
		cprintf("Spurious interrupt on irq 7\n");
f0104940:	c7 04 24 5e 85 10 f0 	movl   $0xf010855e,(%esp)
f0104947:	e8 56 f8 ff ff       	call   f01041a2 <cprintf>
		print_trapframe(tf);
f010494c:	89 34 24             	mov    %esi,(%esp)
f010494f:	e8 16 fb ff ff       	call   f010446a <print_trapframe>
f0104954:	eb 50                	jmp    f01049a6 <trap+0x1fb>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0104956:	83 f8 20             	cmp    $0x20,%eax
f0104959:	75 0a                	jne    f0104965 <trap+0x1ba>
		lapic_eoi();
f010495b:	e8 1b 1f 00 00       	call   f010687b <lapic_eoi>
		sched_yield();
f0104960:	e8 7c 02 00 00       	call   f0104be1 <sched_yield>
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104965:	89 34 24             	mov    %esi,(%esp)
f0104968:	e8 fd fa ff ff       	call   f010446a <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010496d:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104972:	75 1c                	jne    f0104990 <trap+0x1e5>
		panic("unhandled trap in kernel");
f0104974:	c7 44 24 08 7b 85 10 	movl   $0xf010857b,0x8(%esp)
f010497b:	f0 
f010497c:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
f0104983:	00 
f0104984:	c7 04 24 32 85 10 f0 	movl   $0xf0108532,(%esp)
f010498b:	e8 b0 b6 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104990:	e8 8f 1d 00 00       	call   f0106724 <cpunum>
f0104995:	6b c0 74             	imul   $0x74,%eax,%eax
f0104998:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f010499e:	89 04 24             	mov    %eax,(%esp)
f01049a1:	e8 ee f4 ff ff       	call   f0103e94 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01049a6:	e8 79 1d 00 00       	call   f0106724 <cpunum>
f01049ab:	6b c0 74             	imul   $0x74,%eax,%eax
f01049ae:	83 b8 28 30 33 f0 00 	cmpl   $0x0,-0xfcccfd8(%eax)
f01049b5:	74 2a                	je     f01049e1 <trap+0x236>
f01049b7:	e8 68 1d 00 00       	call   f0106724 <cpunum>
f01049bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01049bf:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f01049c5:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01049c9:	75 16                	jne    f01049e1 <trap+0x236>
		env_run(curenv);
f01049cb:	e8 54 1d 00 00       	call   f0106724 <cpunum>
f01049d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01049d3:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f01049d9:	89 04 24             	mov    %eax,(%esp)
f01049dc:	e8 72 f5 ff ff       	call   f0103f53 <env_run>
	else
		sched_yield();
f01049e1:	e8 fb 01 00 00       	call   f0104be1 <sched_yield>
	...

f01049e8 <t_divide_handler>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC_AUTO(t_divide_handler, T_DIVIDE)
f01049e8:	6a 00                	push   $0x0
f01049ea:	6a 00                	push   $0x0
f01049ec:	e9 e7 00 00 00       	jmp    f0104ad8 <_alltraps>
f01049f1:	90                   	nop

f01049f2 <t_debug_handler>:
TRAPHANDLER_NOEC_AUTO(t_debug_handler, T_DEBUG)
f01049f2:	6a 00                	push   $0x0
f01049f4:	6a 01                	push   $0x1
f01049f6:	e9 dd 00 00 00       	jmp    f0104ad8 <_alltraps>
f01049fb:	90                   	nop

f01049fc <t_nmi_handler>:
TRAPHANDLER_NOEC_AUTO(t_nmi_handler, T_NMI)
f01049fc:	6a 00                	push   $0x0
f01049fe:	6a 02                	push   $0x2
f0104a00:	e9 d3 00 00 00       	jmp    f0104ad8 <_alltraps>
f0104a05:	90                   	nop

f0104a06 <t_brkpt_handler>:
TRAPHANDLER_NOEC_AUTO(t_brkpt_handler, T_BRKPT)
f0104a06:	6a 00                	push   $0x0
f0104a08:	6a 03                	push   $0x3
f0104a0a:	e9 c9 00 00 00       	jmp    f0104ad8 <_alltraps>
f0104a0f:	90                   	nop

f0104a10 <t_oflow_handler>:
TRAPHANDLER_NOEC_AUTO(t_oflow_handler, T_OFLOW)
f0104a10:	6a 00                	push   $0x0
f0104a12:	6a 04                	push   $0x4
f0104a14:	e9 bf 00 00 00       	jmp    f0104ad8 <_alltraps>
f0104a19:	90                   	nop

f0104a1a <t_bound_handler>:
TRAPHANDLER_NOEC_AUTO(t_bound_handler, T_BOUND)
f0104a1a:	6a 00                	push   $0x0
f0104a1c:	6a 05                	push   $0x5
f0104a1e:	e9 b5 00 00 00       	jmp    f0104ad8 <_alltraps>
f0104a23:	90                   	nop

f0104a24 <t_illop_handler>:
TRAPHANDLER_NOEC_AUTO(t_illop_handler, T_ILLOP)
f0104a24:	6a 00                	push   $0x0
f0104a26:	6a 06                	push   $0x6
f0104a28:	e9 ab 00 00 00       	jmp    f0104ad8 <_alltraps>
f0104a2d:	90                   	nop

f0104a2e <t_device_handler>:
TRAPHANDLER_NOEC_AUTO(t_device_handler, T_DEVICE)
f0104a2e:	6a 00                	push   $0x0
f0104a30:	6a 07                	push   $0x7
f0104a32:	e9 a1 00 00 00       	jmp    f0104ad8 <_alltraps>
f0104a37:	90                   	nop

f0104a38 <t_dblflt_handler>:
TRAPHANDLER_AUTO(t_dblflt_handler, T_DBLFLT)
f0104a38:	6a 08                	push   $0x8
f0104a3a:	e9 99 00 00 00       	jmp    f0104ad8 <_alltraps>
f0104a3f:	90                   	nop

f0104a40 <t_tss_handler>:
PADDING()/* #define T_COPROC  9 */	// reserved (not generated by recent processors)
TRAPHANDLER_AUTO(t_tss_handler, T_TSS)
f0104a40:	6a 0a                	push   $0xa
f0104a42:	e9 91 00 00 00       	jmp    f0104ad8 <_alltraps>
f0104a47:	90                   	nop

f0104a48 <t_segnp_handler>:
TRAPHANDLER_AUTO(t_segnp_handler, T_SEGNP)
f0104a48:	6a 0b                	push   $0xb
f0104a4a:	e9 89 00 00 00       	jmp    f0104ad8 <_alltraps>
f0104a4f:	90                   	nop

f0104a50 <t_stack_handler>:
TRAPHANDLER_AUTO(t_stack_handler, T_STACK)
f0104a50:	6a 0c                	push   $0xc
f0104a52:	e9 81 00 00 00       	jmp    f0104ad8 <_alltraps>
f0104a57:	90                   	nop

f0104a58 <t_gpflt_handler>:
TRAPHANDLER_AUTO(t_gpflt_handler, T_GPFLT)
f0104a58:	6a 0d                	push   $0xd
f0104a5a:	eb 7c                	jmp    f0104ad8 <_alltraps>

f0104a5c <t_pgflt_handler>:
TRAPHANDLER_AUTO(t_pgflt_handler, T_PGFLT)
f0104a5c:	6a 0e                	push   $0xe
f0104a5e:	eb 78                	jmp    f0104ad8 <_alltraps>

f0104a60 <t_fperr_handler>:
PADDING()/* #define T_RES    15 */	// reserved
TRAPHANDLER_NOEC_AUTO(t_fperr_handler, T_FPERR)
f0104a60:	6a 00                	push   $0x0
f0104a62:	6a 10                	push   $0x10
f0104a64:	eb 72                	jmp    f0104ad8 <_alltraps>

f0104a66 <t_align_handler>:
TRAPHANDLER_AUTO(t_align_handler, T_ALIGN)
f0104a66:	6a 11                	push   $0x11
f0104a68:	eb 6e                	jmp    f0104ad8 <_alltraps>

f0104a6a <t_mchk_handler>:
TRAPHANDLER_AUTO(t_mchk_handler, T_MCHK)
f0104a6a:	6a 12                	push   $0x12
f0104a6c:	eb 6a                	jmp    f0104ad8 <_alltraps>

f0104a6e <t_simderr_handler>:
TRAPHANDLER_AUTO(t_simderr_handler, T_SIMDERR)
f0104a6e:	6a 13                	push   $0x13
f0104a70:	eb 66                	jmp    f0104ad8 <_alltraps>

f0104a72 <t_syscall_handler>:
TRAPHANDLER_NOEC_AUTO(t_syscall_handler, T_SYSCALL)
f0104a72:	6a 00                	push   $0x0
f0104a74:	6a 30                	push   $0x30
f0104a76:	eb 60                	jmp    f0104ad8 <_alltraps>

f0104a78 <irq_handler_0>:

/*
 * Lab 4: For IRQs
 */

TRAPHANDLER_NOEC_AUTO(irq_handler_0, 32)
f0104a78:	6a 00                	push   $0x0
f0104a7a:	6a 20                	push   $0x20
f0104a7c:	eb 5a                	jmp    f0104ad8 <_alltraps>

f0104a7e <irq_handler_1>:
TRAPHANDLER_NOEC_AUTO(irq_handler_1, 33)
f0104a7e:	6a 00                	push   $0x0
f0104a80:	6a 21                	push   $0x21
f0104a82:	eb 54                	jmp    f0104ad8 <_alltraps>

f0104a84 <irq_handler_2>:
TRAPHANDLER_NOEC_AUTO(irq_handler_2, 34)
f0104a84:	6a 00                	push   $0x0
f0104a86:	6a 22                	push   $0x22
f0104a88:	eb 4e                	jmp    f0104ad8 <_alltraps>

f0104a8a <irq_handler_3>:
TRAPHANDLER_NOEC_AUTO(irq_handler_3, 35)
f0104a8a:	6a 00                	push   $0x0
f0104a8c:	6a 23                	push   $0x23
f0104a8e:	eb 48                	jmp    f0104ad8 <_alltraps>

f0104a90 <irq_handler_4>:
TRAPHANDLER_NOEC_AUTO(irq_handler_4, 36)
f0104a90:	6a 00                	push   $0x0
f0104a92:	6a 24                	push   $0x24
f0104a94:	eb 42                	jmp    f0104ad8 <_alltraps>

f0104a96 <irq_handler_5>:
TRAPHANDLER_NOEC_AUTO(irq_handler_5, 37)
f0104a96:	6a 00                	push   $0x0
f0104a98:	6a 25                	push   $0x25
f0104a9a:	eb 3c                	jmp    f0104ad8 <_alltraps>

f0104a9c <irq_handler_6>:
TRAPHANDLER_NOEC_AUTO(irq_handler_6, 38)
f0104a9c:	6a 00                	push   $0x0
f0104a9e:	6a 26                	push   $0x26
f0104aa0:	eb 36                	jmp    f0104ad8 <_alltraps>

f0104aa2 <irq_handler_7>:
TRAPHANDLER_NOEC_AUTO(irq_handler_7, 39)
f0104aa2:	6a 00                	push   $0x0
f0104aa4:	6a 27                	push   $0x27
f0104aa6:	eb 30                	jmp    f0104ad8 <_alltraps>

f0104aa8 <irq_handler_8>:
TRAPHANDLER_NOEC_AUTO(irq_handler_8, 40)
f0104aa8:	6a 00                	push   $0x0
f0104aaa:	6a 28                	push   $0x28
f0104aac:	eb 2a                	jmp    f0104ad8 <_alltraps>

f0104aae <irq_handler_9>:
TRAPHANDLER_NOEC_AUTO(irq_handler_9, 41)
f0104aae:	6a 00                	push   $0x0
f0104ab0:	6a 29                	push   $0x29
f0104ab2:	eb 24                	jmp    f0104ad8 <_alltraps>

f0104ab4 <irq_handler_10>:
TRAPHANDLER_NOEC_AUTO(irq_handler_10, 42)
f0104ab4:	6a 00                	push   $0x0
f0104ab6:	6a 2a                	push   $0x2a
f0104ab8:	eb 1e                	jmp    f0104ad8 <_alltraps>

f0104aba <irq_handler_11>:
TRAPHANDLER_NOEC_AUTO(irq_handler_11, 43)
f0104aba:	6a 00                	push   $0x0
f0104abc:	6a 2b                	push   $0x2b
f0104abe:	eb 18                	jmp    f0104ad8 <_alltraps>

f0104ac0 <irq_handler_12>:
TRAPHANDLER_NOEC_AUTO(irq_handler_12, 44)
f0104ac0:	6a 00                	push   $0x0
f0104ac2:	6a 2c                	push   $0x2c
f0104ac4:	eb 12                	jmp    f0104ad8 <_alltraps>

f0104ac6 <irq_handler_13>:
TRAPHANDLER_NOEC_AUTO(irq_handler_13, 45)
f0104ac6:	6a 00                	push   $0x0
f0104ac8:	6a 2d                	push   $0x2d
f0104aca:	eb 0c                	jmp    f0104ad8 <_alltraps>

f0104acc <irq_handler_14>:
TRAPHANDLER_NOEC_AUTO(irq_handler_14, 46)
f0104acc:	6a 00                	push   $0x0
f0104ace:	6a 2e                	push   $0x2e
f0104ad0:	eb 06                	jmp    f0104ad8 <_alltraps>

f0104ad2 <irq_handler_15>:
TRAPHANDLER_NOEC_AUTO(irq_handler_15, 47)
f0104ad2:	6a 00                	push   $0x0
f0104ad4:	6a 2f                	push   $0x2f
f0104ad6:	eb 00                	jmp    f0104ad8 <_alltraps>

f0104ad8 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushl %ds
f0104ad8:	1e                   	push   %ds
	pushl %es
f0104ad9:	06                   	push   %es
	pushal
f0104ada:	60                   	pusha  
	movl $GD_KD, %eax
f0104adb:	b8 10 00 00 00       	mov    $0x10,%eax
	movl %eax, %ds
f0104ae0:	8e d8                	mov    %eax,%ds
	movl %eax, %es
f0104ae2:	8e c0                	mov    %eax,%es
	pushl %esp
f0104ae4:	54                   	push   %esp
	call trap
f0104ae5:	e8 c1 fc ff ff       	call   f01047ab <trap>
	...

f0104aec <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104aec:	55                   	push   %ebp
f0104aed:	89 e5                	mov    %esp,%ebp
f0104aef:	83 ec 18             	sub    $0x18,%esp

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0104af2:	8b 15 48 22 33 f0    	mov    0xf0332248,%edx
f0104af8:	83 c2 54             	add    $0x54,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104afb:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104b00:	8b 0a                	mov    (%edx),%ecx
f0104b02:	49                   	dec    %ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104b03:	83 f9 02             	cmp    $0x2,%ecx
f0104b06:	76 10                	jbe    f0104b18 <sched_halt+0x2c>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104b08:	40                   	inc    %eax
f0104b09:	81 c2 ac 00 00 00    	add    $0xac,%edx
f0104b0f:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104b14:	75 ea                	jne    f0104b00 <sched_halt+0x14>
f0104b16:	eb 07                	jmp    f0104b1f <sched_halt+0x33>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104b18:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104b1d:	75 1a                	jne    f0104b39 <sched_halt+0x4d>
		cprintf("No runnable environments in the system!\n");
f0104b1f:	c7 04 24 50 87 10 f0 	movl   $0xf0108750,(%esp)
f0104b26:	e8 77 f6 ff ff       	call   f01041a2 <cprintf>
		while (1)
			monitor(NULL);
f0104b2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104b32:	e8 a7 c0 ff ff       	call   f0100bde <monitor>
f0104b37:	eb f2                	jmp    f0104b2b <sched_halt+0x3f>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104b39:	e8 e6 1b 00 00       	call   f0106724 <cpunum>
f0104b3e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104b45:	29 c2                	sub    %eax,%edx
f0104b47:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b4a:	c7 04 85 28 30 33 f0 	movl   $0x0,-0xfcccfd8(,%eax,4)
f0104b51:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104b55:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104b5a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104b5f:	77 20                	ja     f0104b81 <sched_halt+0x95>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104b61:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104b65:	c7 44 24 08 24 6e 10 	movl   $0xf0106e24,0x8(%esp)
f0104b6c:	f0 
f0104b6d:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
f0104b74:	00 
f0104b75:	c7 04 24 79 87 10 f0 	movl   $0xf0108779,(%esp)
f0104b7c:	e8 bf b4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104b81:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104b86:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104b89:	e8 96 1b 00 00       	call   f0106724 <cpunum>
f0104b8e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104b95:	29 c2                	sub    %eax,%edx
f0104b97:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b9a:	8d 14 85 20 30 33 f0 	lea    -0xfcccfe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104ba1:	b8 02 00 00 00       	mov    $0x2,%eax
f0104ba6:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104baa:	c7 04 24 60 a4 12 f0 	movl   $0xf012a460,(%esp)
f0104bb1:	e8 d0 1e 00 00       	call   f0106a86 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104bb6:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104bb8:	e8 67 1b 00 00       	call   f0106724 <cpunum>
f0104bbd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104bc4:	29 c2                	sub    %eax,%edx
f0104bc6:	8d 04 90             	lea    (%eax,%edx,4),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104bc9:	8b 04 85 30 30 33 f0 	mov    -0xfcccfd0(,%eax,4),%eax
f0104bd0:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104bd5:	89 c4                	mov    %eax,%esp
f0104bd7:	6a 00                	push   $0x0
f0104bd9:	6a 00                	push   $0x0
f0104bdb:	fb                   	sti    
f0104bdc:	f4                   	hlt    
f0104bdd:	eb fd                	jmp    f0104bdc <sched_halt+0xf0>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104bdf:	c9                   	leave  
f0104be0:	c3                   	ret    

f0104be1 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104be1:	55                   	push   %ebp
f0104be2:	89 e5                	mov    %esp,%ebp
f0104be4:	56                   	push   %esi
f0104be5:	53                   	push   %ebx
f0104be6:	83 ec 10             	sub    $0x10,%esp
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int offset = curenv ? ENVX(curenv->env_id) : 0;
f0104be9:	e8 36 1b 00 00       	call   f0106724 <cpunum>
f0104bee:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104bf5:	29 c2                	sub    %eax,%edx
f0104bf7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104bfa:	83 3c 85 28 30 33 f0 	cmpl   $0x0,-0xfcccfd8(,%eax,4)
f0104c01:	00 
f0104c02:	74 23                	je     f0104c27 <sched_yield+0x46>
f0104c04:	e8 1b 1b 00 00       	call   f0106724 <cpunum>
f0104c09:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c10:	29 c2                	sub    %eax,%edx
f0104c12:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c15:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0104c1c:	8b 58 48             	mov    0x48(%eax),%ebx
f0104c1f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0104c25:	eb 05                	jmp    f0104c2c <sched_yield+0x4b>
f0104c27:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < NENV; i++) {
		int id = (i + offset) % NENV;
		if (envs[id].env_status == ENV_RUNNABLE)
f0104c2c:	8b 0d 48 22 33 f0    	mov    0xf0332248,%ecx
	// below to halt the cpu.

	// LAB 4: Your code here.
	int offset = curenv ? ENVX(curenv->env_id) : 0;
	int i;
	for (i = 0; i < NENV; i++) {
f0104c32:	ba 00 00 00 00       	mov    $0x0,%edx

void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
f0104c37:	8d 04 1a             	lea    (%edx,%ebx,1),%eax

	// LAB 4: Your code here.
	int offset = curenv ? ENVX(curenv->env_id) : 0;
	int i;
	for (i = 0; i < NENV; i++) {
		int id = (i + offset) % NENV;
f0104c3a:	25 ff 03 00 80       	and    $0x800003ff,%eax
f0104c3f:	79 07                	jns    f0104c48 <sched_yield+0x67>
f0104c41:	48                   	dec    %eax
f0104c42:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f0104c47:	40                   	inc    %eax
		if (envs[id].env_status == ENV_RUNNABLE)
f0104c48:	8d 34 80             	lea    (%eax,%eax,4),%esi
f0104c4b:	8d 34 b0             	lea    (%eax,%esi,4),%esi
f0104c4e:	8d 04 70             	lea    (%eax,%esi,2),%eax
f0104c51:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104c54:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104c58:	75 08                	jne    f0104c62 <sched_yield+0x81>
			env_run(&envs[id]);
f0104c5a:	89 04 24             	mov    %eax,(%esp)
f0104c5d:	e8 f1 f2 ff ff       	call   f0103f53 <env_run>
	// below to halt the cpu.

	// LAB 4: Your code here.
	int offset = curenv ? ENVX(curenv->env_id) : 0;
	int i;
	for (i = 0; i < NENV; i++) {
f0104c62:	42                   	inc    %edx
f0104c63:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0104c69:	75 cc                	jne    f0104c37 <sched_yield+0x56>
		int id = (i + offset) % NENV;
		if (envs[id].env_status == ENV_RUNNABLE)
			env_run(&envs[id]);
	}
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104c6b:	e8 b4 1a 00 00       	call   f0106724 <cpunum>
f0104c70:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c77:	29 c2                	sub    %eax,%edx
f0104c79:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c7c:	83 3c 85 28 30 33 f0 	cmpl   $0x0,-0xfcccfd8(,%eax,4)
f0104c83:	00 
f0104c84:	74 3e                	je     f0104cc4 <sched_yield+0xe3>
f0104c86:	e8 99 1a 00 00       	call   f0106724 <cpunum>
f0104c8b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c92:	29 c2                	sub    %eax,%edx
f0104c94:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c97:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0104c9e:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104ca2:	75 20                	jne    f0104cc4 <sched_yield+0xe3>
		env_run(curenv);
f0104ca4:	e8 7b 1a 00 00       	call   f0106724 <cpunum>
f0104ca9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104cb0:	29 c2                	sub    %eax,%edx
f0104cb2:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104cb5:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0104cbc:	89 04 24             	mov    %eax,(%esp)
f0104cbf:	e8 8f f2 ff ff       	call   f0103f53 <env_run>

	// sched_halt never returns
	sched_halt();
f0104cc4:	e8 23 fe ff ff       	call   f0104aec <sched_halt>
}
f0104cc9:	83 c4 10             	add    $0x10,%esp
f0104ccc:	5b                   	pop    %ebx
f0104ccd:	5e                   	pop    %esi
f0104cce:	5d                   	pop    %ebp
f0104ccf:	c3                   	ret    

f0104cd0 <sys_yield>:
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
f0104cd0:	55                   	push   %ebp
f0104cd1:	89 e5                	mov    %esp,%ebp
f0104cd3:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f0104cd6:	e8 06 ff ff ff       	call   f0104be1 <sched_yield>

f0104cdb <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104cdb:	55                   	push   %ebp
f0104cdc:	89 e5                	mov    %esp,%ebp
f0104cde:	57                   	push   %edi
f0104cdf:	56                   	push   %esi
f0104ce0:	53                   	push   %ebx
f0104ce1:	83 ec 3c             	sub    $0x3c,%esp
f0104ce4:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ce7:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104cea:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104ced:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
f0104cf0:	83 f8 0c             	cmp    $0xc,%eax
f0104cf3:	0f 87 22 08 00 00    	ja     f010551b <syscall+0x840>
f0104cf9:	ff 24 85 30 88 10 f0 	jmp    *-0xfef77d0(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);
f0104d00:	e8 1f 1a 00 00       	call   f0106724 <cpunum>
f0104d05:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104d0c:	00 
f0104d0d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104d11:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104d15:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d1c:	29 c2                	sub    %eax,%edx
f0104d1e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d21:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0104d28:	89 04 24             	mov    %eax,(%esp)
f0104d2b:	e8 05 ea ff ff       	call   f0103735 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104d30:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104d34:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104d38:	c7 04 24 86 87 10 f0 	movl   $0xf0108786,(%esp)
f0104d3f:	e8 5e f4 ff ff       	call   f01041a2 <cprintf>
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *)a1, a2);
		return 0;
f0104d44:	be 00 00 00 00       	mov    $0x0,%esi
f0104d49:	e9 d9 07 00 00       	jmp    f0105527 <syscall+0x84c>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104d4e:	e8 dd b8 ff ff       	call   f0100630 <cons_getc>
f0104d53:	89 c6                	mov    %eax,%esi
	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *)a1, a2);
		return 0;
	case SYS_cgetc:
		return sys_cgetc();
f0104d55:	e9 cd 07 00 00       	jmp    f0105527 <syscall+0x84c>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104d5a:	e8 c5 19 00 00       	call   f0106724 <cpunum>
f0104d5f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d66:	29 c2                	sub    %eax,%edx
f0104d68:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d6b:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0104d72:	8b 70 48             	mov    0x48(%eax),%esi
		sys_cputs((char *)a1, a2);
		return 0;
	case SYS_cgetc:
		return sys_cgetc();
	case SYS_getenvid:
		return sys_getenvid();
f0104d75:	e9 ad 07 00 00       	jmp    f0105527 <syscall+0x84c>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104d7a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104d81:	00 
f0104d82:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104d85:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d89:	89 34 24             	mov    %esi,(%esp)
f0104d8c:	e8 7a ea ff ff       	call   f010380b <envid2env>
f0104d91:	85 c0                	test   %eax,%eax
f0104d93:	0f 88 89 07 00 00    	js     f0105522 <syscall+0x847>
		return r;
	if (e == curenv)
f0104d99:	e8 86 19 00 00       	call   f0106724 <cpunum>
f0104d9e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104da1:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0104da8:	29 c1                	sub    %eax,%ecx
f0104daa:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f0104dad:	39 14 85 28 30 33 f0 	cmp    %edx,-0xfcccfd8(,%eax,4)
f0104db4:	75 2d                	jne    f0104de3 <syscall+0x108>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104db6:	e8 69 19 00 00       	call   f0106724 <cpunum>
f0104dbb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104dc2:	29 c2                	sub    %eax,%edx
f0104dc4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104dc7:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0104dce:	8b 40 48             	mov    0x48(%eax),%eax
f0104dd1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104dd5:	c7 04 24 8b 87 10 f0 	movl   $0xf010878b,(%esp)
f0104ddc:	e8 c1 f3 ff ff       	call   f01041a2 <cprintf>
f0104de1:	eb 32                	jmp    f0104e15 <syscall+0x13a>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104de3:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104de6:	e8 39 19 00 00       	call   f0106724 <cpunum>
f0104deb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104def:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104df6:	29 c2                	sub    %eax,%edx
f0104df8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104dfb:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0104e02:	8b 40 48             	mov    0x48(%eax),%eax
f0104e05:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e09:	c7 04 24 a6 87 10 f0 	movl   $0xf01087a6,(%esp)
f0104e10:	e8 8d f3 ff ff       	call   f01041a2 <cprintf>
	env_destroy(e);
f0104e15:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e18:	89 04 24             	mov    %eax,(%esp)
f0104e1b:	e8 74 f0 ff ff       	call   f0103e94 <env_destroy>
		return sys_cgetc();
	case SYS_getenvid:
		return sys_getenvid();
	case SYS_env_destroy:
		sys_env_destroy(a1);
		return 0;
f0104e20:	be 00 00 00 00       	mov    $0x0,%esi
f0104e25:	e9 fd 06 00 00       	jmp    f0105527 <syscall+0x84c>
	case SYS_yield:
		sys_yield();
f0104e2a:	e8 a1 fe ff ff       	call   f0104cd0 <sys_yield>

	// LAB 4: Your code here.
	int r;
	struct Env *e;
	// catch -E_NO_FREE_ENV and -E_NO_MEM from env_alloc()
	if ((r = env_alloc(&e, curenv->env_id)) < 0)
f0104e2f:	e8 f0 18 00 00       	call   f0106724 <cpunum>
f0104e34:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e3b:	29 c2                	sub    %eax,%edx
f0104e3d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e40:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0104e47:	8b 40 48             	mov    0x48(%eax),%eax
f0104e4a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e4e:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104e51:	89 04 24             	mov    %eax,(%esp)
f0104e54:	e8 dc ea ff ff       	call   f0103935 <env_alloc>
f0104e59:	89 c6                	mov    %eax,%esi
f0104e5b:	85 c0                	test   %eax,%eax
f0104e5d:	0f 88 c4 06 00 00    	js     f0105527 <syscall+0x84c>
		return r;
	e->env_status = ENV_NOT_RUNNABLE;
f0104e63:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104e66:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf;
f0104e6d:	e8 b2 18 00 00       	call   f0106724 <cpunum>
f0104e72:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e79:	29 c2                	sub    %eax,%edx
f0104e7b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e7e:	8b 34 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%esi
f0104e85:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104e8a:	89 df                	mov    %ebx,%edi
f0104e8c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	// set return value for child process
	e->env_tf.tf_regs.reg_eax = 0;
f0104e8e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e91:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f0104e98:	8b 70 48             	mov    0x48(%eax),%esi
		return 0;
	case SYS_yield:
		sys_yield();
		return 0;
	case SYS_exofork:
		return sys_exofork();
f0104e9b:	e9 87 06 00 00       	jmp    f0105527 <syscall+0x84c>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if (!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
f0104ea0:	83 ff 02             	cmp    $0x2,%edi
f0104ea3:	74 05                	je     f0104eaa <syscall+0x1cf>
f0104ea5:	83 ff 04             	cmp    $0x4,%edi
f0104ea8:	75 31                	jne    f0104edb <syscall+0x200>
		return -E_INVAL;
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104eaa:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104eb1:	00 
f0104eb2:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104eb5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104eb9:	89 34 24             	mov    %esi,(%esp)
f0104ebc:	e8 4a e9 ff ff       	call   f010380b <envid2env>
f0104ec1:	89 c6                	mov    %eax,%esi
f0104ec3:	85 c0                	test   %eax,%eax
f0104ec5:	0f 88 5c 06 00 00    	js     f0105527 <syscall+0x84c>
		return r;
	e->env_status = status;
f0104ecb:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ece:	89 78 54             	mov    %edi,0x54(%eax)
	return 0;
f0104ed1:	be 00 00 00 00       	mov    $0x0,%esi
f0104ed6:	e9 4c 06 00 00       	jmp    f0105527 <syscall+0x84c>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if (!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
		return -E_INVAL;
f0104edb:	be fd ff ff ff       	mov    $0xfffffffd,%esi
		sys_yield();
		return 0;
	case SYS_exofork:
		return sys_exofork();
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
f0104ee0:	e9 42 06 00 00       	jmp    f0105527 <syscall+0x84c>

	// LAB 4: Your code here.
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104ee5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104eec:	00 
f0104eed:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104ef0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ef4:	89 34 24             	mov    %esi,(%esp)
f0104ef7:	e8 0f e9 ff ff       	call   f010380b <envid2env>
f0104efc:	89 c6                	mov    %eax,%esi
f0104efe:	85 c0                	test   %eax,%eax
f0104f00:	0f 88 21 06 00 00    	js     f0105527 <syscall+0x84c>
		return r;
	if ((uintptr_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104f06:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104f0c:	77 60                	ja     f0104f6e <syscall+0x293>
f0104f0e:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
f0104f14:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104f19:	39 c7                	cmp    %eax,%edi
f0104f1b:	75 5b                	jne    f0104f78 <syscall+0x29d>
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) return -E_INVAL;
f0104f1d:	89 d8                	mov    %ebx,%eax
f0104f1f:	83 e0 05             	and    $0x5,%eax
f0104f22:	83 f8 05             	cmp    $0x5,%eax
f0104f25:	75 5b                	jne    f0104f82 <syscall+0x2a7>
	struct PageInfo *pp = page_alloc(1);
f0104f27:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104f2e:	e8 06 c3 ff ff       	call   f0101239 <page_alloc>
f0104f33:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (!pp) return E_NO_MEM;
f0104f36:	85 c0                	test   %eax,%eax
f0104f38:	74 52                	je     f0104f8c <syscall+0x2b1>
	pp->pp_ref++;
f0104f3a:	66 ff 40 04          	incw   0x4(%eax)
	if ((r = page_insert(e->env_pgdir, pp, va, perm)) < 0) {
f0104f3e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104f42:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104f46:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104f4d:	8b 40 60             	mov    0x60(%eax),%eax
f0104f50:	89 04 24             	mov    %eax,(%esp)
f0104f53:	e8 1a c6 ff ff       	call   f0101572 <page_insert>
f0104f58:	89 c6                	mov    %eax,%esi
f0104f5a:	85 c0                	test   %eax,%eax
f0104f5c:	79 38                	jns    f0104f96 <syscall+0x2bb>
		page_free(pp);
f0104f5e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104f61:	89 04 24             	mov    %eax,(%esp)
f0104f64:	e8 54 c3 ff ff       	call   f01012bd <page_free>
f0104f69:	e9 b9 05 00 00       	jmp    f0105527 <syscall+0x84c>
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if ((uintptr_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104f6e:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104f73:	e9 af 05 00 00       	jmp    f0105527 <syscall+0x84c>
f0104f78:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104f7d:	e9 a5 05 00 00       	jmp    f0105527 <syscall+0x84c>
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) return -E_INVAL;
f0104f82:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104f87:	e9 9b 05 00 00       	jmp    f0105527 <syscall+0x84c>
	struct PageInfo *pp = page_alloc(1);
	if (!pp) return E_NO_MEM;
f0104f8c:	be 04 00 00 00       	mov    $0x4,%esi
f0104f91:	e9 91 05 00 00       	jmp    f0105527 <syscall+0x84c>
	pp->pp_ref++;
	if ((r = page_insert(e->env_pgdir, pp, va, perm)) < 0) {
		page_free(pp);
		return r;
	}
	return 0;
f0104f96:	be 00 00 00 00       	mov    $0x0,%esi
	case SYS_exofork:
		return sys_exofork();
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *)a2, a3);
f0104f9b:	e9 87 05 00 00       	jmp    f0105527 <syscall+0x84c>

	// LAB 4: Your code here.
	int r;
	struct Env *srce, *dste;
	// catch -E_BAD_ENV
	if ((r = envid2env(srcenvid, &srce, 1)) < 0)
f0104fa0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104fa7:	00 
f0104fa8:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104fab:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104faf:	89 34 24             	mov    %esi,(%esp)
f0104fb2:	e8 54 e8 ff ff       	call   f010380b <envid2env>
f0104fb7:	89 c6                	mov    %eax,%esi
f0104fb9:	85 c0                	test   %eax,%eax
f0104fbb:	0f 88 66 05 00 00    	js     f0105527 <syscall+0x84c>
		return r;
	if ((r = envid2env(dstenvid, &dste, 1)) < 0)
f0104fc1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104fc8:	00 
f0104fc9:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104fcc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fd0:	89 1c 24             	mov    %ebx,(%esp)
f0104fd3:	e8 33 e8 ff ff       	call   f010380b <envid2env>
f0104fd8:	89 c6                	mov    %eax,%esi
f0104fda:	85 c0                	test   %eax,%eax
f0104fdc:	0f 88 45 05 00 00    	js     f0105527 <syscall+0x84c>
		return r;
	if ((uintptr_t)srcva>=UTOP || ROUNDUP(srcva, PGSIZE) != srcva ||
f0104fe2:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104fe8:	0f 87 8f 00 00 00    	ja     f010507d <syscall+0x3a2>
f0104fee:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
f0104ff4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104ff9:	39 c7                	cmp    %eax,%edi
f0104ffb:	0f 85 86 00 00 00    	jne    f0105087 <syscall+0x3ac>
f0105001:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0105008:	0f 87 83 00 00 00    	ja     f0105091 <syscall+0x3b6>
		(uintptr_t)dstva>=UTOP || ROUNDUP(dstva, PGSIZE) != dstva)
f010500e:	8b 45 18             	mov    0x18(%ebp),%eax
f0105011:	05 ff 0f 00 00       	add    $0xfff,%eax
f0105016:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010501b:	39 45 18             	cmp    %eax,0x18(%ebp)
f010501e:	75 7b                	jne    f010509b <syscall+0x3c0>
		return -E_INVAL;
	pte_t *ppte;
	struct PageInfo *pp = page_lookup(srce->env_pgdir, srcva, &ppte);
f0105020:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105023:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105027:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010502b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010502e:	8b 40 60             	mov    0x60(%eax),%eax
f0105031:	89 04 24             	mov    %eax,(%esp)
f0105034:	e8 27 c4 ff ff       	call   f0101460 <page_lookup>
	if (!pp) return -E_INVAL;
f0105039:	85 c0                	test   %eax,%eax
f010503b:	74 68                	je     f01050a5 <syscall+0x3ca>
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) return -E_INVAL;
f010503d:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0105040:	83 e2 05             	and    $0x5,%edx
f0105043:	83 fa 05             	cmp    $0x5,%edx
f0105046:	75 67                	jne    f01050af <syscall+0x3d4>
	if ((perm & PTE_W) && !(*ppte & PTE_W)) return -E_INVAL;
f0105048:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f010504c:	74 08                	je     f0105056 <syscall+0x37b>
f010504e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105051:	f6 02 02             	testb  $0x2,(%edx)
f0105054:	74 63                	je     f01050b9 <syscall+0x3de>
	// catch -E_NO_MEM
	return page_insert(dste->env_pgdir, pp, dstva, perm);
f0105056:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f0105059:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010505d:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0105060:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105064:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105068:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010506b:	8b 40 60             	mov    0x60(%eax),%eax
f010506e:	89 04 24             	mov    %eax,(%esp)
f0105071:	e8 fc c4 ff ff       	call   f0101572 <page_insert>
f0105076:	89 c6                	mov    %eax,%esi
f0105078:	e9 aa 04 00 00       	jmp    f0105527 <syscall+0x84c>
		return r;
	if ((r = envid2env(dstenvid, &dste, 1)) < 0)
		return r;
	if ((uintptr_t)srcva>=UTOP || ROUNDUP(srcva, PGSIZE) != srcva ||
		(uintptr_t)dstva>=UTOP || ROUNDUP(dstva, PGSIZE) != dstva)
		return -E_INVAL;
f010507d:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105082:	e9 a0 04 00 00       	jmp    f0105527 <syscall+0x84c>
f0105087:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010508c:	e9 96 04 00 00       	jmp    f0105527 <syscall+0x84c>
f0105091:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105096:	e9 8c 04 00 00       	jmp    f0105527 <syscall+0x84c>
f010509b:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01050a0:	e9 82 04 00 00       	jmp    f0105527 <syscall+0x84c>
	pte_t *ppte;
	struct PageInfo *pp = page_lookup(srce->env_pgdir, srcva, &ppte);
	if (!pp) return -E_INVAL;
f01050a5:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01050aa:	e9 78 04 00 00       	jmp    f0105527 <syscall+0x84c>
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) return -E_INVAL;
f01050af:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01050b4:	e9 6e 04 00 00       	jmp    f0105527 <syscall+0x84c>
	if ((perm & PTE_W) && !(*ppte & PTE_W)) return -E_INVAL;
f01050b9:	be fd ff ff ff       	mov    $0xfffffffd,%esi
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *)a2, a3);
	case SYS_page_map:
		return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
f01050be:	e9 64 04 00 00       	jmp    f0105527 <syscall+0x84c>

	// LAB 4: Your code here.
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 0)) < 0)
f01050c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01050ca:	00 
f01050cb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01050ce:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050d2:	89 34 24             	mov    %esi,(%esp)
f01050d5:	e8 31 e7 ff ff       	call   f010380b <envid2env>
f01050da:	89 c6                	mov    %eax,%esi
f01050dc:	85 c0                	test   %eax,%eax
f01050de:	0f 88 43 04 00 00    	js     f0105527 <syscall+0x84c>
		return r;
	if ((uintptr_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f01050e4:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f01050ea:	77 2b                	ja     f0105117 <syscall+0x43c>
f01050ec:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
f01050f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01050f7:	39 c7                	cmp    %eax,%edi
f01050f9:	75 26                	jne    f0105121 <syscall+0x446>
	page_remove(e->env_pgdir, va);
f01050fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01050ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105102:	8b 40 60             	mov    0x60(%eax),%eax
f0105105:	89 04 24             	mov    %eax,(%esp)
f0105108:	e8 14 c4 ff ff       	call   f0101521 <page_remove>
	return 0;
f010510d:	be 00 00 00 00       	mov    $0x0,%esi
f0105112:	e9 10 04 00 00       	jmp    f0105527 <syscall+0x84c>
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 0)) < 0)
		return r;
	if ((uintptr_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0105117:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010511c:	e9 06 04 00 00       	jmp    f0105527 <syscall+0x84c>
f0105121:	be fd ff ff ff       	mov    $0xfffffffd,%esi
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *)a2, a3);
	case SYS_page_map:
		return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *)a2);
f0105126:	e9 fc 03 00 00       	jmp    f0105527 <syscall+0x84c>
{
	// LAB 4: Your code here.
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 1)) < 0)
f010512b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105132:	00 
f0105133:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105136:	89 44 24 04          	mov    %eax,0x4(%esp)
f010513a:	89 34 24             	mov    %esi,(%esp)
f010513d:	e8 c9 e6 ff ff       	call   f010380b <envid2env>
f0105142:	89 c6                	mov    %eax,%esi
f0105144:	85 c0                	test   %eax,%eax
f0105146:	0f 88 db 03 00 00    	js     f0105527 <syscall+0x84c>
		return r;
	e->env_pgfault_upcall = func;
f010514c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010514f:	89 78 64             	mov    %edi,0x64(%eax)
	return 0;
f0105152:	be 00 00 00 00       	mov    $0x0,%esi
	case SYS_page_map:
		return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *)a2);
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *)a2);
f0105157:	e9 cb 03 00 00       	jmp    f0105527 <syscall+0x84c>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uintptr_t)dstva < UTOP && ROUNDUP(dstva, PGSIZE) != dstva)
f010515c:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0105162:	77 13                	ja     f0105177 <syscall+0x49c>
f0105164:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
f010516a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010516f:	39 c6                	cmp    %eax,%esi
f0105171:	0f 85 55 01 00 00    	jne    f01052cc <syscall+0x5f1>
		return -E_INVAL;
	curenv->env_ipc_recving = 1;
f0105177:	e8 a8 15 00 00       	call   f0106724 <cpunum>
f010517c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105183:	29 c2                	sub    %eax,%edx
f0105185:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105188:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f010518f:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0105193:	e8 8c 15 00 00       	call   f0106724 <cpunum>
f0105198:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010519f:	29 c2                	sub    %eax,%edx
f01051a1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01051a4:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f01051ab:	89 70 6c             	mov    %esi,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f01051ae:	e8 71 15 00 00       	call   f0106724 <cpunum>
f01051b3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01051ba:	29 c2                	sub    %eax,%edx
f01051bc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01051bf:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f01051c6:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	// If waiting queue is not empty, wake up one
	if (curenv->env_ipc_waiting_head != curenv->env_ipc_waiting_tail) {
f01051cd:	e8 52 15 00 00       	call   f0106724 <cpunum>
f01051d2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01051d9:	29 c2                	sub    %eax,%edx
f01051db:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01051de:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f01051e5:	8b 70 7c             	mov    0x7c(%eax),%esi
f01051e8:	e8 37 15 00 00       	call   f0106724 <cpunum>
f01051ed:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01051f4:	29 c2                	sub    %eax,%edx
f01051f6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01051f9:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0105200:	3b b0 80 00 00 00    	cmp    0x80(%eax),%esi
f0105206:	0f 84 bb 00 00 00    	je     f01052c7 <syscall+0x5ec>
		int r;
		struct Env *e;
		envid_t envid = curenv->env_ipc_waiting[curenv->env_ipc_waiting_head];
f010520c:	e8 13 15 00 00       	call   f0106724 <cpunum>
f0105211:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105218:	29 c2                	sub    %eax,%edx
f010521a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010521d:	8b 34 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%esi
f0105224:	e8 fb 14 00 00       	call   f0106724 <cpunum>
f0105229:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105230:	29 c2                	sub    %eax,%edx
f0105232:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105235:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f010523c:	8b 40 7c             	mov    0x7c(%eax),%eax
f010523f:	8b 9c 86 84 00 00 00 	mov    0x84(%esi,%eax,4),%ebx
		curenv->env_ipc_waiting_head = (curenv->env_ipc_waiting_head + 1) % MAXIPCWAITING;
f0105246:	e8 d9 14 00 00       	call   f0106724 <cpunum>
f010524b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105252:	29 c2                	sub    %eax,%edx
f0105254:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105257:	8b 34 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%esi
f010525e:	e8 c1 14 00 00       	call   f0106724 <cpunum>
f0105263:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010526a:	29 c2                	sub    %eax,%edx
f010526c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010526f:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0105276:	8b 40 7c             	mov    0x7c(%eax),%eax
f0105279:	40                   	inc    %eax
f010527a:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010527f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105284:	f7 f1                	div    %ecx
f0105286:	89 56 7c             	mov    %edx,0x7c(%esi)
		if ((r = envid2env(envid, &e, 0)) < 0)
f0105289:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0105290:	00 
f0105291:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105294:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105298:	89 1c 24             	mov    %ebx,(%esp)
f010529b:	e8 6b e5 ff ff       	call   f010380b <envid2env>
f01052a0:	89 c6                	mov    %eax,%esi
f01052a2:	85 c0                	test   %eax,%eax
f01052a4:	0f 88 7d 02 00 00    	js     f0105527 <syscall+0x84c>
			return r;
		e->env_status = ENV_RUNNABLE;
f01052aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052ad:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		cprintf("Wake up env %x.\n", e->env_id);
f01052b4:	8b 40 48             	mov    0x48(%eax),%eax
f01052b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052bb:	c7 04 24 be 87 10 f0 	movl   $0xf01087be,(%esp)
f01052c2:	e8 db ee ff ff       	call   f01041a2 <cprintf>
	}
	sys_yield();
f01052c7:	e8 04 fa ff ff       	call   f0104cd0 <sys_yield>
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uintptr_t)dstva < UTOP && ROUNDUP(dstva, PGSIZE) != dstva)
		return -E_INVAL;
f01052cc:	be fd ff ff ff       	mov    $0xfffffffd,%esi
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *)a2);
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *)a2);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *)a1);
f01052d1:	e9 51 02 00 00       	jmp    f0105527 <syscall+0x84c>
{
	// LAB 4: Your code here.
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 0)) < 0)
f01052d6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01052dd:	00 
f01052de:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01052e1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052e5:	89 34 24             	mov    %esi,(%esp)
f01052e8:	e8 1e e5 ff ff       	call   f010380b <envid2env>
f01052ed:	89 c6                	mov    %eax,%esi
f01052ef:	85 c0                	test   %eax,%eax
f01052f1:	0f 88 30 02 00 00    	js     f0105527 <syscall+0x84c>
		return r;
	if (!e->env_ipc_recving) {
f01052f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052fa:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01052fe:	0f 85 07 01 00 00    	jne    f010540b <syscall+0x730>
		// If waiting queue is not full
		cprintf("env %x is busy: ", e->env_id);
f0105304:	8b 40 48             	mov    0x48(%eax),%eax
f0105307:	89 44 24 04          	mov    %eax,0x4(%esp)
f010530b:	c7 04 24 cf 87 10 f0 	movl   $0xf01087cf,(%esp)
f0105312:	e8 8b ee ff ff       	call   f01041a2 <cprintf>
		if ((e->env_ipc_waiting_tail + 1) % MAXIPCWAITING != e->env_ipc_waiting_head) {
f0105317:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010531a:	8b 81 80 00 00 00    	mov    0x80(%ecx),%eax
f0105320:	40                   	inc    %eax
f0105321:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0105326:	ba 00 00 00 00       	mov    $0x0,%edx
f010532b:	f7 f3                	div    %ebx
f010532d:	3b 51 7c             	cmp    0x7c(%ecx),%edx
f0105330:	74 75                	je     f01053a7 <syscall+0x6cc>
			// Block the sender
			cprintf("env %x is put in waiting queue.\n", curenv->env_id);
f0105332:	e8 ed 13 00 00       	call   f0106724 <cpunum>
f0105337:	6b c0 74             	imul   $0x74,%eax,%eax
f010533a:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f0105340:	8b 40 48             	mov    0x48(%eax),%eax
f0105343:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105347:	c7 04 24 0c 88 10 f0 	movl   $0xf010880c,(%esp)
f010534e:	e8 4f ee ff ff       	call   f01041a2 <cprintf>
			curenv->env_status = ENV_NOT_RUNNABLE;
f0105353:	e8 cc 13 00 00       	call   f0106724 <cpunum>
f0105358:	6b c0 74             	imul   $0x74,%eax,%eax
f010535b:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f0105361:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
			e->env_ipc_waiting[e->env_ipc_waiting_tail] = curenv->env_id;
f0105368:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010536b:	8b b3 80 00 00 00    	mov    0x80(%ebx),%esi
f0105371:	e8 ae 13 00 00       	call   f0106724 <cpunum>
f0105376:	6b c0 74             	imul   $0x74,%eax,%eax
f0105379:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f010537f:	8b 40 48             	mov    0x48(%eax),%eax
f0105382:	89 84 b3 84 00 00 00 	mov    %eax,0x84(%ebx,%esi,4)
			e->env_ipc_waiting_tail = (e->env_ipc_waiting_tail + 1) % MAXIPCWAITING;
f0105389:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010538c:	8b 81 80 00 00 00    	mov    0x80(%ecx),%eax
f0105392:	40                   	inc    %eax
f0105393:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0105398:	ba 00 00 00 00       	mov    $0x0,%edx
f010539d:	f7 f3                	div    %ebx
f010539f:	89 91 80 00 00 00    	mov    %edx,0x80(%ecx)
f01053a5:	eb 0c                	jmp    f01053b3 <syscall+0x6d8>
		}
		else
			cprintf("waiting queue is full.\n");
f01053a7:	c7 04 24 e0 87 10 f0 	movl   $0xf01087e0,(%esp)
f01053ae:	e8 ef ed ff ff       	call   f01041a2 <cprintf>
		cprintf("Waiting envs: ");
f01053b3:	c7 04 24 f8 87 10 f0 	movl   $0xf01087f8,(%esp)
f01053ba:	e8 e3 ed ff ff       	call   f01041a2 <cprintf>
		int i;
		for (i = 0; i < MAXIPCWAITING; i++)
f01053bf:	bb 00 00 00 00       	mov    $0x0,%ebx
			cprintf("%x ", e->env_ipc_waiting[(i + e->env_ipc_waiting_head) % MAXIPCWAITING]);
f01053c4:	be 0a 00 00 00       	mov    $0xa,%esi
f01053c9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01053cc:	89 d8                	mov    %ebx,%eax
f01053ce:	03 41 7c             	add    0x7c(%ecx),%eax
f01053d1:	ba 00 00 00 00       	mov    $0x0,%edx
f01053d6:	f7 f6                	div    %esi
f01053d8:	8b 84 91 84 00 00 00 	mov    0x84(%ecx,%edx,4),%eax
f01053df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053e3:	c7 04 24 07 88 10 f0 	movl   $0xf0108807,(%esp)
f01053ea:	e8 b3 ed ff ff       	call   f01041a2 <cprintf>
		}
		else
			cprintf("waiting queue is full.\n");
		cprintf("Waiting envs: ");
		int i;
		for (i = 0; i < MAXIPCWAITING; i++)
f01053ef:	43                   	inc    %ebx
f01053f0:	83 fb 0a             	cmp    $0xa,%ebx
f01053f3:	75 d4                	jne    f01053c9 <syscall+0x6ee>
			cprintf("%x ", e->env_ipc_waiting[(i + e->env_ipc_waiting_head) % MAXIPCWAITING]);
		cprintf("\n");
f01053f5:	c7 04 24 75 82 10 f0 	movl   $0xf0108275,(%esp)
f01053fc:	e8 a1 ed ff ff       	call   f01041a2 <cprintf>
		return -E_IPC_NOT_RECV;
f0105401:	be f8 ff ff ff       	mov    $0xfffffff8,%esi
f0105406:	e9 1c 01 00 00       	jmp    f0105527 <syscall+0x84c>
	}
	if ((uintptr_t)srcva < UTOP) {
f010540b:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105411:	0f 87 a1 00 00 00    	ja     f01054b8 <syscall+0x7dd>
		if (ROUNDUP(srcva, PGSIZE) != srcva) return -E_INVAL;
f0105417:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
f010541d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105422:	39 c3                	cmp    %eax,%ebx
f0105424:	0f 85 d5 00 00 00    	jne    f01054ff <syscall+0x824>
		pte_t *ppte;
		struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &ppte);
f010542a:	e8 f5 12 00 00       	call   f0106724 <cpunum>
f010542f:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0105432:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105436:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010543a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105441:	29 c2                	sub    %eax,%edx
f0105443:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105446:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f010544d:	8b 40 60             	mov    0x60(%eax),%eax
f0105450:	89 04 24             	mov    %eax,(%esp)
f0105453:	e8 08 c0 ff ff       	call   f0101460 <page_lookup>
		//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
		//		address space.
		if (!pp) return -E_INVAL;
f0105458:	85 c0                	test   %eax,%eax
f010545a:	0f 84 a6 00 00 00    	je     f0105506 <syscall+0x82b>
		//	-E_INVAL if srcva < UTOP and perm is inappropriate
		if ((perm & *ppte) != perm) return -E_INVAL;
f0105460:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105463:	8b 12                	mov    (%edx),%edx
f0105465:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105468:	21 d1                	and    %edx,%ecx
f010546a:	39 4d 18             	cmp    %ecx,0x18(%ebp)
f010546d:	0f 85 9a 00 00 00    	jne    f010550d <syscall+0x832>
		//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
		//		current environment's address space.
		if ((perm & PTE_W) && !(*ppte & PTE_W)) return -E_INVAL;
f0105473:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0105477:	74 09                	je     f0105482 <syscall+0x7a7>
f0105479:	f6 c2 02             	test   $0x2,%dl
f010547c:	0f 84 92 00 00 00    	je     f0105514 <syscall+0x839>
		if ((uintptr_t)e->env_ipc_dstva < UTOP) {
f0105482:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105485:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0105488:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f010548e:	77 2f                	ja     f01054bf <syscall+0x7e4>
			if ((r = page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm)) < 0)
f0105490:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0105493:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105497:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010549b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010549f:	8b 42 60             	mov    0x60(%edx),%eax
f01054a2:	89 04 24             	mov    %eax,(%esp)
f01054a5:	e8 c8 c0 ff ff       	call   f0101572 <page_insert>
f01054aa:	89 c6                	mov    %eax,%esi
f01054ac:	85 c0                	test   %eax,%eax
f01054ae:	78 77                	js     f0105527 <syscall+0x84c>
				return r;
			e->env_ipc_perm = perm;
f01054b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054b3:	89 58 78             	mov    %ebx,0x78(%eax)
f01054b6:	eb 07                	jmp    f01054bf <syscall+0x7e4>
		}
	}
	else e->env_ipc_perm = 0;
f01054b8:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	e->env_ipc_recving = 0;
f01054bf:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01054c2:	c6 46 68 00          	movb   $0x0,0x68(%esi)
	e->env_ipc_from = curenv->env_id;
f01054c6:	e8 59 12 00 00       	call   f0106724 <cpunum>
f01054cb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01054d2:	29 c2                	sub    %eax,%edx
f01054d4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01054d7:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f01054de:	8b 40 48             	mov    0x48(%eax),%eax
f01054e1:	89 46 74             	mov    %eax,0x74(%esi)
	e->env_ipc_value = value;
f01054e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054e7:	89 78 70             	mov    %edi,0x70(%eax)
	e->env_status = ENV_RUNNABLE;
f01054ea:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;
f01054f1:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f01054f8:	be 00 00 00 00       	mov    $0x0,%esi
f01054fd:	eb 28                	jmp    f0105527 <syscall+0x84c>
			cprintf("%x ", e->env_ipc_waiting[(i + e->env_ipc_waiting_head) % MAXIPCWAITING]);
		cprintf("\n");
		return -E_IPC_NOT_RECV;
	}
	if ((uintptr_t)srcva < UTOP) {
		if (ROUNDUP(srcva, PGSIZE) != srcva) return -E_INVAL;
f01054ff:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105504:	eb 21                	jmp    f0105527 <syscall+0x84c>
		pte_t *ppte;
		struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &ppte);
		//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
		//		address space.
		if (!pp) return -E_INVAL;
f0105506:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010550b:	eb 1a                	jmp    f0105527 <syscall+0x84c>
		//	-E_INVAL if srcva < UTOP and perm is inappropriate
		if ((perm & *ppte) != perm) return -E_INVAL;
f010550d:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105512:	eb 13                	jmp    f0105527 <syscall+0x84c>
		//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
		//		current environment's address space.
		if ((perm & PTE_W) && !(*ppte & PTE_W)) return -E_INVAL;
f0105514:	be fd ff ff ff       	mov    $0xfffffffd,%esi
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *)a2);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *)a1);
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f0105519:	eb 0c                	jmp    f0105527 <syscall+0x84c>
	default:
		// should I change it into -E_INVAL?
		return -E_NO_SYS;
f010551b:	be f9 ff ff ff       	mov    $0xfffffff9,%esi
f0105520:	eb 05                	jmp    f0105527 <syscall+0x84c>
		return sys_cgetc();
	case SYS_getenvid:
		return sys_getenvid();
	case SYS_env_destroy:
		sys_env_destroy(a1);
		return 0;
f0105522:	be 00 00 00 00       	mov    $0x0,%esi
		return sys_ipc_try_send(a1, a2, (void *)a3, a4);
	default:
		// should I change it into -E_INVAL?
		return -E_NO_SYS;
	}
}
f0105527:	89 f0                	mov    %esi,%eax
f0105529:	83 c4 3c             	add    $0x3c,%esp
f010552c:	5b                   	pop    %ebx
f010552d:	5e                   	pop    %esi
f010552e:	5f                   	pop    %edi
f010552f:	5d                   	pop    %ebp
f0105530:	c3                   	ret    
f0105531:	00 00                	add    %al,(%eax)
	...

f0105534 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105534:	55                   	push   %ebp
f0105535:	89 e5                	mov    %esp,%ebp
f0105537:	57                   	push   %edi
f0105538:	56                   	push   %esi
f0105539:	53                   	push   %ebx
f010553a:	83 ec 14             	sub    $0x14,%esp
f010553d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105540:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0105543:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105546:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105549:	8b 1a                	mov    (%edx),%ebx
f010554b:	8b 01                	mov    (%ecx),%eax
f010554d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105550:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f0105557:	e9 83 00 00 00       	jmp    f01055df <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f010555c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010555f:	01 d8                	add    %ebx,%eax
f0105561:	89 c7                	mov    %eax,%edi
f0105563:	c1 ef 1f             	shr    $0x1f,%edi
f0105566:	01 c7                	add    %eax,%edi
f0105568:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010556a:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f010556d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105570:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105574:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105576:	eb 01                	jmp    f0105579 <stab_binsearch+0x45>
			m--;
f0105578:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105579:	39 c3                	cmp    %eax,%ebx
f010557b:	7f 1e                	jg     f010559b <stab_binsearch+0x67>
f010557d:	0f b6 0a             	movzbl (%edx),%ecx
f0105580:	83 ea 0c             	sub    $0xc,%edx
f0105583:	39 f1                	cmp    %esi,%ecx
f0105585:	75 f1                	jne    f0105578 <stab_binsearch+0x44>
f0105587:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010558a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010558d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105590:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105594:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105597:	76 18                	jbe    f01055b1 <stab_binsearch+0x7d>
f0105599:	eb 05                	jmp    f01055a0 <stab_binsearch+0x6c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010559b:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010559e:	eb 3f                	jmp    f01055df <stab_binsearch+0xab>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01055a0:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01055a3:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f01055a5:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01055a8:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01055af:	eb 2e                	jmp    f01055df <stab_binsearch+0xab>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01055b1:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01055b4:	73 15                	jae    f01055cb <stab_binsearch+0x97>
			*region_right = m - 1;
f01055b6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01055b9:	49                   	dec    %ecx
f01055ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01055bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01055c0:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01055c2:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01055c9:	eb 14                	jmp    f01055df <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01055cb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01055ce:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01055d1:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f01055d3:	ff 45 0c             	incl   0xc(%ebp)
f01055d6:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01055d8:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01055df:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01055e2:	0f 8e 74 ff ff ff    	jle    f010555c <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01055e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01055ec:	75 0d                	jne    f01055fb <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f01055ee:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01055f1:	8b 02                	mov    (%edx),%eax
f01055f3:	48                   	dec    %eax
f01055f4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01055f7:	89 01                	mov    %eax,(%ecx)
f01055f9:	eb 2a                	jmp    f0105625 <stab_binsearch+0xf1>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01055fb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01055fe:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105600:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105603:	8b 0a                	mov    (%edx),%ecx
f0105605:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105608:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f010560b:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010560f:	eb 01                	jmp    f0105612 <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105611:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105612:	39 c8                	cmp    %ecx,%eax
f0105614:	7e 0a                	jle    f0105620 <stab_binsearch+0xec>
		     l > *region_left && stabs[l].n_type != type;
f0105616:	0f b6 1a             	movzbl (%edx),%ebx
f0105619:	83 ea 0c             	sub    $0xc,%edx
f010561c:	39 f3                	cmp    %esi,%ebx
f010561e:	75 f1                	jne    f0105611 <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105620:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105623:	89 02                	mov    %eax,(%edx)
	}
}
f0105625:	83 c4 14             	add    $0x14,%esp
f0105628:	5b                   	pop    %ebx
f0105629:	5e                   	pop    %esi
f010562a:	5f                   	pop    %edi
f010562b:	5d                   	pop    %ebp
f010562c:	c3                   	ret    

f010562d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010562d:	55                   	push   %ebp
f010562e:	89 e5                	mov    %esp,%ebp
f0105630:	57                   	push   %edi
f0105631:	56                   	push   %esi
f0105632:	53                   	push   %ebx
f0105633:	83 ec 5c             	sub    $0x5c,%esp
f0105636:	8b 75 08             	mov    0x8(%ebp),%esi
f0105639:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010563c:	c7 03 64 88 10 f0    	movl   $0xf0108864,(%ebx)
	info->eip_line = 0;
f0105642:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105649:	c7 43 08 64 88 10 f0 	movl   $0xf0108864,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0105650:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105657:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010565a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105661:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0105667:	0f 87 e1 00 00 00    	ja     f010574e <debuginfo_eip+0x121>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f010566d:	e8 b2 10 00 00       	call   f0106724 <cpunum>
f0105672:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105679:	00 
f010567a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0105681:	00 
f0105682:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0105689:	00 
f010568a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105691:	29 c2                	sub    %eax,%edx
f0105693:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105696:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f010569d:	89 04 24             	mov    %eax,(%esp)
f01056a0:	e8 06 e0 ff ff       	call   f01036ab <user_mem_check>
f01056a5:	85 c0                	test   %eax,%eax
f01056a7:	0f 85 5d 02 00 00    	jne    f010590a <debuginfo_eip+0x2dd>
			return -1;

		stabs = usd->stabs;
f01056ad:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f01056b3:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f01056b6:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f01056bc:	a1 08 00 20 00       	mov    0x200008,%eax
f01056c1:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f01056c4:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f01056ca:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f01056cd:	e8 52 10 00 00       	call   f0106724 <cpunum>
f01056d2:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01056d9:	00 
f01056da:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f01056e1:	00 
f01056e2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01056e5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01056e9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01056f0:	29 c2                	sub    %eax,%edx
f01056f2:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01056f5:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f01056fc:	89 04 24             	mov    %eax,(%esp)
f01056ff:	e8 a7 df ff ff       	call   f01036ab <user_mem_check>
f0105704:	85 c0                	test   %eax,%eax
f0105706:	0f 85 05 02 00 00    	jne    f0105911 <debuginfo_eip+0x2e4>
			return -1;
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
f010570c:	e8 13 10 00 00       	call   f0106724 <cpunum>
f0105711:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105718:	00 
f0105719:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010571c:	2b 55 bc             	sub    -0x44(%ebp),%edx
f010571f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105723:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105726:	89 54 24 04          	mov    %edx,0x4(%esp)
f010572a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105731:	29 c2                	sub    %eax,%edx
f0105733:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105736:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f010573d:	89 04 24             	mov    %eax,(%esp)
f0105740:	e8 66 df ff ff       	call   f01036ab <user_mem_check>
f0105745:	85 c0                	test   %eax,%eax
f0105747:	74 1f                	je     f0105768 <debuginfo_eip+0x13b>
f0105749:	e9 ca 01 00 00       	jmp    f0105918 <debuginfo_eip+0x2eb>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010574e:	c7 45 c0 a0 f6 11 f0 	movl   $0xf011f6a0,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0105755:	c7 45 bc 21 46 11 f0 	movl   $0xf0114621,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f010575c:	bf 20 46 11 f0       	mov    $0xf0114620,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0105761:	c7 45 c4 58 8d 10 f0 	movl   $0xf0108d58,-0x3c(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105768:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010576b:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f010576e:	0f 83 ab 01 00 00    	jae    f010591f <debuginfo_eip+0x2f2>
f0105774:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0105778:	0f 85 a8 01 00 00    	jne    f0105926 <debuginfo_eip+0x2f9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010577e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105785:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f0105788:	c1 ff 02             	sar    $0x2,%edi
f010578b:	8d 04 bf             	lea    (%edi,%edi,4),%eax
f010578e:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0105791:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0105794:	89 c2                	mov    %eax,%edx
f0105796:	c1 e2 08             	shl    $0x8,%edx
f0105799:	01 d0                	add    %edx,%eax
f010579b:	89 c2                	mov    %eax,%edx
f010579d:	c1 e2 10             	shl    $0x10,%edx
f01057a0:	01 d0                	add    %edx,%eax
f01057a2:	8d 44 47 ff          	lea    -0x1(%edi,%eax,2),%eax
f01057a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01057a9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01057ad:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01057b4:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01057b7:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01057ba:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01057bd:	e8 72 fd ff ff       	call   f0105534 <stab_binsearch>
	if (lfile == 0)
f01057c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01057c5:	85 c0                	test   %eax,%eax
f01057c7:	0f 84 60 01 00 00    	je     f010592d <debuginfo_eip+0x300>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01057cd:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01057d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01057d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01057d6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01057da:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01057e1:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01057e4:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01057e7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01057ea:	e8 45 fd ff ff       	call   f0105534 <stab_binsearch>

	if (lfun <= rfun) {
f01057ef:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01057f2:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01057f5:	39 d0                	cmp    %edx,%eax
f01057f7:	7f 32                	jg     f010582b <debuginfo_eip+0x1fe>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01057f9:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01057fc:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01057ff:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f0105802:	8b 39                	mov    (%ecx),%edi
f0105804:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0105807:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010580a:	2b 7d bc             	sub    -0x44(%ebp),%edi
f010580d:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0105810:	73 09                	jae    f010581b <debuginfo_eip+0x1ee>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105812:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0105815:	03 7d bc             	add    -0x44(%ebp),%edi
f0105818:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010581b:	8b 49 08             	mov    0x8(%ecx),%ecx
f010581e:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105821:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105823:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105826:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105829:	eb 0f                	jmp    f010583a <debuginfo_eip+0x20d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010582b:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010582e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105831:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105834:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105837:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010583a:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105841:	00 
f0105842:	8b 43 08             	mov    0x8(%ebx),%eax
f0105845:	89 04 24             	mov    %eax,(%esp)
f0105848:	e8 91 08 00 00       	call   f01060de <strfind>
f010584d:	2b 43 08             	sub    0x8(%ebx),%eax
f0105850:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105853:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105857:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f010585e:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105861:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105864:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105867:	e8 c8 fc ff ff       	call   f0105534 <stab_binsearch>
	if (lline <= rline)
f010586c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010586f:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0105872:	7f 10                	jg     f0105884 <debuginfo_eip+0x257>
		info->eip_line = stabs[rline].n_desc;
f0105874:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105877:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010587a:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f010587f:	89 43 04             	mov    %eax,0x4(%ebx)
f0105882:	eb 07                	jmp    f010588b <debuginfo_eip+0x25e>
	else
		info->eip_line = -1;
f0105884:	c7 43 04 ff ff ff ff 	movl   $0xffffffff,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010588b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010588e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105891:	8d 14 40             	lea    (%eax,%eax,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105894:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105897:	8d 54 97 08          	lea    0x8(%edi,%edx,4),%edx
f010589b:	89 5d b8             	mov    %ebx,-0x48(%ebp)
f010589e:	eb 04                	jmp    f01058a4 <debuginfo_eip+0x277>
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01058a0:	48                   	dec    %eax
f01058a1:	83 ea 0c             	sub    $0xc,%edx
f01058a4:	89 c7                	mov    %eax,%edi
f01058a6:	39 c6                	cmp    %eax,%esi
f01058a8:	7f 28                	jg     f01058d2 <debuginfo_eip+0x2a5>
	       && stabs[lline].n_type != N_SOL
f01058aa:	8a 4a fc             	mov    -0x4(%edx),%cl
f01058ad:	80 f9 84             	cmp    $0x84,%cl
f01058b0:	0f 84 92 00 00 00    	je     f0105948 <debuginfo_eip+0x31b>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01058b6:	80 f9 64             	cmp    $0x64,%cl
f01058b9:	75 e5                	jne    f01058a0 <debuginfo_eip+0x273>
f01058bb:	83 3a 00             	cmpl   $0x0,(%edx)
f01058be:	74 e0                	je     f01058a0 <debuginfo_eip+0x273>
f01058c0:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f01058c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01058c6:	e9 83 00 00 00       	jmp    f010594e <debuginfo_eip+0x321>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f01058cb:	03 45 bc             	add    -0x44(%ebp),%eax
f01058ce:	89 03                	mov    %eax,(%ebx)
f01058d0:	eb 03                	jmp    f01058d5 <debuginfo_eip+0x2a8>
f01058d2:	8b 5d b8             	mov    -0x48(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01058d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01058d8:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01058db:	39 f2                	cmp    %esi,%edx
f01058dd:	7d 55                	jge    f0105934 <debuginfo_eip+0x307>
		for (lline = lfun + 1;
f01058df:	42                   	inc    %edx
f01058e0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01058e3:	89 d0                	mov    %edx,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01058e5:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01058e8:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01058eb:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01058ef:	eb 03                	jmp    f01058f4 <debuginfo_eip+0x2c7>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01058f1:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01058f4:	39 f0                	cmp    %esi,%eax
f01058f6:	7d 43                	jge    f010593b <debuginfo_eip+0x30e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01058f8:	8a 0a                	mov    (%edx),%cl
f01058fa:	40                   	inc    %eax
f01058fb:	83 c2 0c             	add    $0xc,%edx
f01058fe:	80 f9 a0             	cmp    $0xa0,%cl
f0105901:	74 ee                	je     f01058f1 <debuginfo_eip+0x2c4>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105903:	b8 00 00 00 00       	mov    $0x0,%eax
f0105908:	eb 36                	jmp    f0105940 <debuginfo_eip+0x313>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f010590a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010590f:	eb 2f                	jmp    f0105940 <debuginfo_eip+0x313>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;
f0105911:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105916:	eb 28                	jmp    f0105940 <debuginfo_eip+0x313>
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
			return -1;
f0105918:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010591d:	eb 21                	jmp    f0105940 <debuginfo_eip+0x313>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010591f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105924:	eb 1a                	jmp    f0105940 <debuginfo_eip+0x313>
f0105926:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010592b:	eb 13                	jmp    f0105940 <debuginfo_eip+0x313>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010592d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105932:	eb 0c                	jmp    f0105940 <debuginfo_eip+0x313>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105934:	b8 00 00 00 00       	mov    $0x0,%eax
f0105939:	eb 05                	jmp    f0105940 <debuginfo_eip+0x313>
f010593b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105940:	83 c4 5c             	add    $0x5c,%esp
f0105943:	5b                   	pop    %ebx
f0105944:	5e                   	pop    %esi
f0105945:	5f                   	pop    %edi
f0105946:	5d                   	pop    %ebp
f0105947:	c3                   	ret    
f0105948:	8b 5d b8             	mov    -0x48(%ebp),%ebx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010594b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010594e:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105951:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105954:	8b 04 87             	mov    (%edi,%eax,4),%eax
f0105957:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010595a:	2b 55 bc             	sub    -0x44(%ebp),%edx
f010595d:	39 d0                	cmp    %edx,%eax
f010595f:	0f 82 66 ff ff ff    	jb     f01058cb <debuginfo_eip+0x29e>
f0105965:	e9 6b ff ff ff       	jmp    f01058d5 <debuginfo_eip+0x2a8>
	...

f010596c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010596c:	55                   	push   %ebp
f010596d:	89 e5                	mov    %esp,%ebp
f010596f:	57                   	push   %edi
f0105970:	56                   	push   %esi
f0105971:	53                   	push   %ebx
f0105972:	83 ec 3c             	sub    $0x3c,%esp
f0105975:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105978:	89 d7                	mov    %edx,%edi
f010597a:	8b 45 08             	mov    0x8(%ebp),%eax
f010597d:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105980:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105983:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105986:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105989:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010598c:	85 c0                	test   %eax,%eax
f010598e:	75 08                	jne    f0105998 <printnum+0x2c>
f0105990:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105993:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105996:	77 57                	ja     f01059ef <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105998:	89 74 24 10          	mov    %esi,0x10(%esp)
f010599c:	4b                   	dec    %ebx
f010599d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01059a1:	8b 45 10             	mov    0x10(%ebp),%eax
f01059a4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01059a8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f01059ac:	8b 74 24 0c          	mov    0xc(%esp),%esi
f01059b0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01059b7:	00 
f01059b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01059bb:	89 04 24             	mov    %eax,(%esp)
f01059be:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01059c1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01059c5:	e8 ca 11 00 00       	call   f0106b94 <__udivdi3>
f01059ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01059ce:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01059d2:	89 04 24             	mov    %eax,(%esp)
f01059d5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01059d9:	89 fa                	mov    %edi,%edx
f01059db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01059de:	e8 89 ff ff ff       	call   f010596c <printnum>
f01059e3:	eb 0f                	jmp    f01059f4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01059e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01059e9:	89 34 24             	mov    %esi,(%esp)
f01059ec:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01059ef:	4b                   	dec    %ebx
f01059f0:	85 db                	test   %ebx,%ebx
f01059f2:	7f f1                	jg     f01059e5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01059f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01059f8:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01059fc:	8b 45 10             	mov    0x10(%ebp),%eax
f01059ff:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a03:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105a0a:	00 
f0105a0b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105a0e:	89 04 24             	mov    %eax,(%esp)
f0105a11:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105a14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a18:	e8 97 12 00 00       	call   f0106cb4 <__umoddi3>
f0105a1d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a21:	0f be 80 6e 88 10 f0 	movsbl -0xfef7792(%eax),%eax
f0105a28:	89 04 24             	mov    %eax,(%esp)
f0105a2b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0105a2e:	83 c4 3c             	add    $0x3c,%esp
f0105a31:	5b                   	pop    %ebx
f0105a32:	5e                   	pop    %esi
f0105a33:	5f                   	pop    %edi
f0105a34:	5d                   	pop    %ebp
f0105a35:	c3                   	ret    

f0105a36 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105a36:	55                   	push   %ebp
f0105a37:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105a39:	83 fa 01             	cmp    $0x1,%edx
f0105a3c:	7e 0e                	jle    f0105a4c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105a3e:	8b 10                	mov    (%eax),%edx
f0105a40:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105a43:	89 08                	mov    %ecx,(%eax)
f0105a45:	8b 02                	mov    (%edx),%eax
f0105a47:	8b 52 04             	mov    0x4(%edx),%edx
f0105a4a:	eb 22                	jmp    f0105a6e <getuint+0x38>
	else if (lflag)
f0105a4c:	85 d2                	test   %edx,%edx
f0105a4e:	74 10                	je     f0105a60 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105a50:	8b 10                	mov    (%eax),%edx
f0105a52:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105a55:	89 08                	mov    %ecx,(%eax)
f0105a57:	8b 02                	mov    (%edx),%eax
f0105a59:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a5e:	eb 0e                	jmp    f0105a6e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105a60:	8b 10                	mov    (%eax),%edx
f0105a62:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105a65:	89 08                	mov    %ecx,(%eax)
f0105a67:	8b 02                	mov    (%edx),%eax
f0105a69:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105a6e:	5d                   	pop    %ebp
f0105a6f:	c3                   	ret    

f0105a70 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0105a70:	55                   	push   %ebp
f0105a71:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105a73:	83 fa 01             	cmp    $0x1,%edx
f0105a76:	7e 0e                	jle    f0105a86 <getint+0x16>
		return va_arg(*ap, long long);
f0105a78:	8b 10                	mov    (%eax),%edx
f0105a7a:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105a7d:	89 08                	mov    %ecx,(%eax)
f0105a7f:	8b 02                	mov    (%edx),%eax
f0105a81:	8b 52 04             	mov    0x4(%edx),%edx
f0105a84:	eb 1a                	jmp    f0105aa0 <getint+0x30>
	else if (lflag)
f0105a86:	85 d2                	test   %edx,%edx
f0105a88:	74 0c                	je     f0105a96 <getint+0x26>
		return va_arg(*ap, long);
f0105a8a:	8b 10                	mov    (%eax),%edx
f0105a8c:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105a8f:	89 08                	mov    %ecx,(%eax)
f0105a91:	8b 02                	mov    (%edx),%eax
f0105a93:	99                   	cltd   
f0105a94:	eb 0a                	jmp    f0105aa0 <getint+0x30>
	else
		return va_arg(*ap, int);
f0105a96:	8b 10                	mov    (%eax),%edx
f0105a98:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105a9b:	89 08                	mov    %ecx,(%eax)
f0105a9d:	8b 02                	mov    (%edx),%eax
f0105a9f:	99                   	cltd   
}
f0105aa0:	5d                   	pop    %ebp
f0105aa1:	c3                   	ret    

f0105aa2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105aa2:	55                   	push   %ebp
f0105aa3:	89 e5                	mov    %esp,%ebp
f0105aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105aa8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0105aab:	8b 10                	mov    (%eax),%edx
f0105aad:	3b 50 04             	cmp    0x4(%eax),%edx
f0105ab0:	73 08                	jae    f0105aba <sprintputch+0x18>
		*b->buf++ = ch;
f0105ab2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105ab5:	88 0a                	mov    %cl,(%edx)
f0105ab7:	42                   	inc    %edx
f0105ab8:	89 10                	mov    %edx,(%eax)
}
f0105aba:	5d                   	pop    %ebp
f0105abb:	c3                   	ret    

f0105abc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105abc:	55                   	push   %ebp
f0105abd:	89 e5                	mov    %esp,%ebp
f0105abf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105ac2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105ac5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105ac9:	8b 45 10             	mov    0x10(%ebp),%eax
f0105acc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105ad3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ad7:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ada:	89 04 24             	mov    %eax,(%esp)
f0105add:	e8 02 00 00 00       	call   f0105ae4 <vprintfmt>
	va_end(ap);
}
f0105ae2:	c9                   	leave  
f0105ae3:	c3                   	ret    

f0105ae4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105ae4:	55                   	push   %ebp
f0105ae5:	89 e5                	mov    %esp,%ebp
f0105ae7:	57                   	push   %edi
f0105ae8:	56                   	push   %esi
f0105ae9:	53                   	push   %ebx
f0105aea:	83 ec 4c             	sub    $0x4c,%esp
f0105aed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105af0:	8b 75 10             	mov    0x10(%ebp),%esi
f0105af3:	eb 12                	jmp    f0105b07 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105af5:	85 c0                	test   %eax,%eax
f0105af7:	0f 84 40 03 00 00    	je     f0105e3d <vprintfmt+0x359>
				return;
			putch(ch, putdat);
f0105afd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b01:	89 04 24             	mov    %eax,(%esp)
f0105b04:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105b07:	0f b6 06             	movzbl (%esi),%eax
f0105b0a:	46                   	inc    %esi
f0105b0b:	83 f8 25             	cmp    $0x25,%eax
f0105b0e:	75 e5                	jne    f0105af5 <vprintfmt+0x11>
f0105b10:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0105b14:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0105b1b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0105b20:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0105b27:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b2c:	eb 26                	jmp    f0105b54 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b2e:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105b31:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0105b35:	eb 1d                	jmp    f0105b54 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b37:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105b3a:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0105b3e:	eb 14                	jmp    f0105b54 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b40:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105b43:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105b4a:	eb 08                	jmp    f0105b54 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105b4c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0105b4f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b54:	0f b6 06             	movzbl (%esi),%eax
f0105b57:	8d 4e 01             	lea    0x1(%esi),%ecx
f0105b5a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105b5d:	8a 0e                	mov    (%esi),%cl
f0105b5f:	83 e9 23             	sub    $0x23,%ecx
f0105b62:	80 f9 55             	cmp    $0x55,%cl
f0105b65:	0f 87 b6 02 00 00    	ja     f0105e21 <vprintfmt+0x33d>
f0105b6b:	0f b6 c9             	movzbl %cl,%ecx
f0105b6e:	ff 24 8d 40 89 10 f0 	jmp    *-0xfef76c0(,%ecx,4)
f0105b75:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105b78:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105b7d:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
f0105b80:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
f0105b84:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105b87:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0105b8a:	83 f9 09             	cmp    $0x9,%ecx
f0105b8d:	77 2a                	ja     f0105bb9 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105b8f:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105b90:	eb eb                	jmp    f0105b7d <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105b92:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b95:	8d 48 04             	lea    0x4(%eax),%ecx
f0105b98:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105b9b:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b9d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105ba0:	eb 17                	jmp    f0105bb9 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f0105ba2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105ba6:	78 98                	js     f0105b40 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ba8:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105bab:	eb a7                	jmp    f0105b54 <vprintfmt+0x70>
f0105bad:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105bb0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0105bb7:	eb 9b                	jmp    f0105b54 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f0105bb9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105bbd:	79 95                	jns    f0105b54 <vprintfmt+0x70>
f0105bbf:	eb 8b                	jmp    f0105b4c <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105bc1:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105bc2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105bc5:	eb 8d                	jmp    f0105b54 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105bc7:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bca:	8d 50 04             	lea    0x4(%eax),%edx
f0105bcd:	89 55 14             	mov    %edx,0x14(%ebp)
f0105bd0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105bd4:	8b 00                	mov    (%eax),%eax
f0105bd6:	89 04 24             	mov    %eax,(%esp)
f0105bd9:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105bdc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105bdf:	e9 23 ff ff ff       	jmp    f0105b07 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105be4:	8b 45 14             	mov    0x14(%ebp),%eax
f0105be7:	8d 50 04             	lea    0x4(%eax),%edx
f0105bea:	89 55 14             	mov    %edx,0x14(%ebp)
f0105bed:	8b 00                	mov    (%eax),%eax
f0105bef:	85 c0                	test   %eax,%eax
f0105bf1:	79 02                	jns    f0105bf5 <vprintfmt+0x111>
f0105bf3:	f7 d8                	neg    %eax
f0105bf5:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105bf7:	83 f8 09             	cmp    $0x9,%eax
f0105bfa:	7f 0b                	jg     f0105c07 <vprintfmt+0x123>
f0105bfc:	8b 04 85 a0 8a 10 f0 	mov    -0xfef7560(,%eax,4),%eax
f0105c03:	85 c0                	test   %eax,%eax
f0105c05:	75 23                	jne    f0105c2a <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f0105c07:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105c0b:	c7 44 24 08 86 88 10 	movl   $0xf0108886,0x8(%esp)
f0105c12:	f0 
f0105c13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c17:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c1a:	89 04 24             	mov    %eax,(%esp)
f0105c1d:	e8 9a fe ff ff       	call   f0105abc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105c22:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105c25:	e9 dd fe ff ff       	jmp    f0105b07 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0105c2a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105c2e:	c7 44 24 08 cd 7f 10 	movl   $0xf0107fcd,0x8(%esp)
f0105c35:	f0 
f0105c36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c3a:	8b 55 08             	mov    0x8(%ebp),%edx
f0105c3d:	89 14 24             	mov    %edx,(%esp)
f0105c40:	e8 77 fe ff ff       	call   f0105abc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105c45:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105c48:	e9 ba fe ff ff       	jmp    f0105b07 <vprintfmt+0x23>
f0105c4d:	89 f9                	mov    %edi,%ecx
f0105c4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105c52:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105c55:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c58:	8d 50 04             	lea    0x4(%eax),%edx
f0105c5b:	89 55 14             	mov    %edx,0x14(%ebp)
f0105c5e:	8b 30                	mov    (%eax),%esi
f0105c60:	85 f6                	test   %esi,%esi
f0105c62:	75 05                	jne    f0105c69 <vprintfmt+0x185>
				p = "(null)";
f0105c64:	be 7f 88 10 f0       	mov    $0xf010887f,%esi
			if (width > 0 && padc != '-')
f0105c69:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105c6d:	0f 8e 84 00 00 00    	jle    f0105cf7 <vprintfmt+0x213>
f0105c73:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0105c77:	74 7e                	je     f0105cf7 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105c79:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105c7d:	89 34 24             	mov    %esi,(%esp)
f0105c80:	e8 25 03 00 00       	call   f0105faa <strnlen>
f0105c85:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105c88:	29 c2                	sub    %eax,%edx
f0105c8a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0105c8d:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
f0105c91:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0105c94:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0105c97:	89 de                	mov    %ebx,%esi
f0105c99:	89 d3                	mov    %edx,%ebx
f0105c9b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105c9d:	eb 0b                	jmp    f0105caa <vprintfmt+0x1c6>
					putch(padc, putdat);
f0105c9f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105ca3:	89 3c 24             	mov    %edi,(%esp)
f0105ca6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105ca9:	4b                   	dec    %ebx
f0105caa:	85 db                	test   %ebx,%ebx
f0105cac:	7f f1                	jg     f0105c9f <vprintfmt+0x1bb>
f0105cae:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0105cb1:	89 f3                	mov    %esi,%ebx
f0105cb3:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0105cb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105cb9:	85 c0                	test   %eax,%eax
f0105cbb:	79 05                	jns    f0105cc2 <vprintfmt+0x1de>
f0105cbd:	b8 00 00 00 00       	mov    $0x0,%eax
f0105cc2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105cc5:	29 c2                	sub    %eax,%edx
f0105cc7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105cca:	eb 2b                	jmp    f0105cf7 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105ccc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105cd0:	74 18                	je     f0105cea <vprintfmt+0x206>
f0105cd2:	8d 50 e0             	lea    -0x20(%eax),%edx
f0105cd5:	83 fa 5e             	cmp    $0x5e,%edx
f0105cd8:	76 10                	jbe    f0105cea <vprintfmt+0x206>
					putch('?', putdat);
f0105cda:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105cde:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105ce5:	ff 55 08             	call   *0x8(%ebp)
f0105ce8:	eb 0a                	jmp    f0105cf4 <vprintfmt+0x210>
				else
					putch(ch, putdat);
f0105cea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105cee:	89 04 24             	mov    %eax,(%esp)
f0105cf1:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105cf4:	ff 4d e4             	decl   -0x1c(%ebp)
f0105cf7:	0f be 06             	movsbl (%esi),%eax
f0105cfa:	46                   	inc    %esi
f0105cfb:	85 c0                	test   %eax,%eax
f0105cfd:	74 21                	je     f0105d20 <vprintfmt+0x23c>
f0105cff:	85 ff                	test   %edi,%edi
f0105d01:	78 c9                	js     f0105ccc <vprintfmt+0x1e8>
f0105d03:	4f                   	dec    %edi
f0105d04:	79 c6                	jns    f0105ccc <vprintfmt+0x1e8>
f0105d06:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105d09:	89 de                	mov    %ebx,%esi
f0105d0b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105d0e:	eb 18                	jmp    f0105d28 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105d10:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105d14:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105d1b:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105d1d:	4b                   	dec    %ebx
f0105d1e:	eb 08                	jmp    f0105d28 <vprintfmt+0x244>
f0105d20:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105d23:	89 de                	mov    %ebx,%esi
f0105d25:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105d28:	85 db                	test   %ebx,%ebx
f0105d2a:	7f e4                	jg     f0105d10 <vprintfmt+0x22c>
f0105d2c:	89 7d 08             	mov    %edi,0x8(%ebp)
f0105d2f:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d31:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105d34:	e9 ce fd ff ff       	jmp    f0105b07 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105d39:	8d 45 14             	lea    0x14(%ebp),%eax
f0105d3c:	e8 2f fd ff ff       	call   f0105a70 <getint>
f0105d41:	89 c6                	mov    %eax,%esi
f0105d43:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
f0105d45:	85 d2                	test   %edx,%edx
f0105d47:	78 07                	js     f0105d50 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105d49:	be 0a 00 00 00       	mov    $0xa,%esi
f0105d4e:	eb 7e                	jmp    f0105dce <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0105d50:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105d54:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105d5b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105d5e:	89 f0                	mov    %esi,%eax
f0105d60:	89 fa                	mov    %edi,%edx
f0105d62:	f7 d8                	neg    %eax
f0105d64:	83 d2 00             	adc    $0x0,%edx
f0105d67:	f7 da                	neg    %edx
			}
			base = 10;
f0105d69:	be 0a 00 00 00       	mov    $0xa,%esi
f0105d6e:	eb 5e                	jmp    f0105dce <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105d70:	8d 45 14             	lea    0x14(%ebp),%eax
f0105d73:	e8 be fc ff ff       	call   f0105a36 <getuint>
			base = 10;
f0105d78:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
f0105d7d:	eb 4f                	jmp    f0105dce <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0105d7f:	8d 45 14             	lea    0x14(%ebp),%eax
f0105d82:	e8 af fc ff ff       	call   f0105a36 <getuint>
			base = 8;
f0105d87:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
f0105d8c:	eb 40                	jmp    f0105dce <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
f0105d8e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105d92:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105d99:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105d9c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105da0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105da7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105daa:	8b 45 14             	mov    0x14(%ebp),%eax
f0105dad:	8d 50 04             	lea    0x4(%eax),%edx
f0105db0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105db3:	8b 00                	mov    (%eax),%eax
f0105db5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105dba:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
f0105dbf:	eb 0d                	jmp    f0105dce <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105dc1:	8d 45 14             	lea    0x14(%ebp),%eax
f0105dc4:	e8 6d fc ff ff       	call   f0105a36 <getuint>
			base = 16;
f0105dc9:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105dce:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
f0105dd2:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0105dd6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105dd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105ddd:	89 74 24 08          	mov    %esi,0x8(%esp)
f0105de1:	89 04 24             	mov    %eax,(%esp)
f0105de4:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105de8:	89 da                	mov    %ebx,%edx
f0105dea:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ded:	e8 7a fb ff ff       	call   f010596c <printnum>
			break;
f0105df2:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105df5:	e9 0d fd ff ff       	jmp    f0105b07 <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
f0105dfa:	8d 45 14             	lea    0x14(%ebp),%eax
f0105dfd:	e8 6e fc ff ff       	call   f0105a70 <getint>
f0105e02:	a3 48 a4 12 f0       	mov    %eax,0xf012a448
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105e07:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
f0105e0a:	e9 f8 fc ff ff       	jmp    f0105b07 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105e0f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105e13:	89 04 24             	mov    %eax,(%esp)
f0105e16:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105e19:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105e1c:	e9 e6 fc ff ff       	jmp    f0105b07 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105e21:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105e25:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105e2c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105e2f:	eb 01                	jmp    f0105e32 <vprintfmt+0x34e>
f0105e31:	4e                   	dec    %esi
f0105e32:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105e36:	75 f9                	jne    f0105e31 <vprintfmt+0x34d>
f0105e38:	e9 ca fc ff ff       	jmp    f0105b07 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0105e3d:	83 c4 4c             	add    $0x4c,%esp
f0105e40:	5b                   	pop    %ebx
f0105e41:	5e                   	pop    %esi
f0105e42:	5f                   	pop    %edi
f0105e43:	5d                   	pop    %ebp
f0105e44:	c3                   	ret    

f0105e45 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105e45:	55                   	push   %ebp
f0105e46:	89 e5                	mov    %esp,%ebp
f0105e48:	83 ec 28             	sub    $0x28,%esp
f0105e4b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e4e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105e51:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105e54:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105e58:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105e5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105e62:	85 c0                	test   %eax,%eax
f0105e64:	74 30                	je     f0105e96 <vsnprintf+0x51>
f0105e66:	85 d2                	test   %edx,%edx
f0105e68:	7e 33                	jle    f0105e9d <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105e6a:	8b 45 14             	mov    0x14(%ebp),%eax
f0105e6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105e71:	8b 45 10             	mov    0x10(%ebp),%eax
f0105e74:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105e78:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105e7b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e7f:	c7 04 24 a2 5a 10 f0 	movl   $0xf0105aa2,(%esp)
f0105e86:	e8 59 fc ff ff       	call   f0105ae4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105e8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105e8e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105e94:	eb 0c                	jmp    f0105ea2 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105e96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105e9b:	eb 05                	jmp    f0105ea2 <vsnprintf+0x5d>
f0105e9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105ea2:	c9                   	leave  
f0105ea3:	c3                   	ret    

f0105ea4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105ea4:	55                   	push   %ebp
f0105ea5:	89 e5                	mov    %esp,%ebp
f0105ea7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105eaa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105ead:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105eb1:	8b 45 10             	mov    0x10(%ebp),%eax
f0105eb4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105eb8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105ebb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ebf:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ec2:	89 04 24             	mov    %eax,(%esp)
f0105ec5:	e8 7b ff ff ff       	call   f0105e45 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105eca:	c9                   	leave  
f0105ecb:	c3                   	ret    

f0105ecc <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105ecc:	55                   	push   %ebp
f0105ecd:	89 e5                	mov    %esp,%ebp
f0105ecf:	57                   	push   %edi
f0105ed0:	56                   	push   %esi
f0105ed1:	53                   	push   %ebx
f0105ed2:	83 ec 1c             	sub    $0x1c,%esp
f0105ed5:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105ed8:	85 c0                	test   %eax,%eax
f0105eda:	74 10                	je     f0105eec <readline+0x20>
		cprintf("%s", prompt);
f0105edc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ee0:	c7 04 24 cd 7f 10 f0 	movl   $0xf0107fcd,(%esp)
f0105ee7:	e8 b6 e2 ff ff       	call   f01041a2 <cprintf>

	i = 0;
	echoing = iscons(0);
f0105eec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105ef3:	e8 94 a8 ff ff       	call   f010078c <iscons>
f0105ef8:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105efa:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105eff:	e8 77 a8 ff ff       	call   f010077b <getchar>
f0105f04:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105f06:	85 c0                	test   %eax,%eax
f0105f08:	79 17                	jns    f0105f21 <readline+0x55>
			cprintf("read error: %e\n", c);
f0105f0a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f0e:	c7 04 24 c8 8a 10 f0 	movl   $0xf0108ac8,(%esp)
f0105f15:	e8 88 e2 ff ff       	call   f01041a2 <cprintf>
			return NULL;
f0105f1a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f1f:	eb 69                	jmp    f0105f8a <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105f21:	83 f8 08             	cmp    $0x8,%eax
f0105f24:	74 05                	je     f0105f2b <readline+0x5f>
f0105f26:	83 f8 7f             	cmp    $0x7f,%eax
f0105f29:	75 17                	jne    f0105f42 <readline+0x76>
f0105f2b:	85 f6                	test   %esi,%esi
f0105f2d:	7e 13                	jle    f0105f42 <readline+0x76>
			if (echoing)
f0105f2f:	85 ff                	test   %edi,%edi
f0105f31:	74 0c                	je     f0105f3f <readline+0x73>
				cputchar('\b');
f0105f33:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105f3a:	e8 2c a8 ff ff       	call   f010076b <cputchar>
			i--;
f0105f3f:	4e                   	dec    %esi
f0105f40:	eb bd                	jmp    f0105eff <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105f42:	83 fb 1f             	cmp    $0x1f,%ebx
f0105f45:	7e 1d                	jle    f0105f64 <readline+0x98>
f0105f47:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105f4d:	7f 15                	jg     f0105f64 <readline+0x98>
			if (echoing)
f0105f4f:	85 ff                	test   %edi,%edi
f0105f51:	74 08                	je     f0105f5b <readline+0x8f>
				cputchar(c);
f0105f53:	89 1c 24             	mov    %ebx,(%esp)
f0105f56:	e8 10 a8 ff ff       	call   f010076b <cputchar>
			buf[i++] = c;
f0105f5b:	88 9e 80 2a 33 f0    	mov    %bl,-0xfccd580(%esi)
f0105f61:	46                   	inc    %esi
f0105f62:	eb 9b                	jmp    f0105eff <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105f64:	83 fb 0a             	cmp    $0xa,%ebx
f0105f67:	74 05                	je     f0105f6e <readline+0xa2>
f0105f69:	83 fb 0d             	cmp    $0xd,%ebx
f0105f6c:	75 91                	jne    f0105eff <readline+0x33>
			if (echoing)
f0105f6e:	85 ff                	test   %edi,%edi
f0105f70:	74 0c                	je     f0105f7e <readline+0xb2>
				cputchar('\n');
f0105f72:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105f79:	e8 ed a7 ff ff       	call   f010076b <cputchar>
			buf[i] = 0;
f0105f7e:	c6 86 80 2a 33 f0 00 	movb   $0x0,-0xfccd580(%esi)
			return buf;
f0105f85:	b8 80 2a 33 f0       	mov    $0xf0332a80,%eax
		}
	}
}
f0105f8a:	83 c4 1c             	add    $0x1c,%esp
f0105f8d:	5b                   	pop    %ebx
f0105f8e:	5e                   	pop    %esi
f0105f8f:	5f                   	pop    %edi
f0105f90:	5d                   	pop    %ebp
f0105f91:	c3                   	ret    
	...

f0105f94 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105f94:	55                   	push   %ebp
f0105f95:	89 e5                	mov    %esp,%ebp
f0105f97:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105f9a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f9f:	eb 01                	jmp    f0105fa2 <strlen+0xe>
		n++;
f0105fa1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105fa2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105fa6:	75 f9                	jne    f0105fa1 <strlen+0xd>
		n++;
	return n;
}
f0105fa8:	5d                   	pop    %ebp
f0105fa9:	c3                   	ret    

f0105faa <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105faa:	55                   	push   %ebp
f0105fab:	89 e5                	mov    %esp,%ebp
f0105fad:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f0105fb0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105fb3:	b8 00 00 00 00       	mov    $0x0,%eax
f0105fb8:	eb 01                	jmp    f0105fbb <strnlen+0x11>
		n++;
f0105fba:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105fbb:	39 d0                	cmp    %edx,%eax
f0105fbd:	74 06                	je     f0105fc5 <strnlen+0x1b>
f0105fbf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105fc3:	75 f5                	jne    f0105fba <strnlen+0x10>
		n++;
	return n;
}
f0105fc5:	5d                   	pop    %ebp
f0105fc6:	c3                   	ret    

f0105fc7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105fc7:	55                   	push   %ebp
f0105fc8:	89 e5                	mov    %esp,%ebp
f0105fca:	53                   	push   %ebx
f0105fcb:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105fd1:	ba 00 00 00 00       	mov    $0x0,%edx
f0105fd6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0105fd9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0105fdc:	42                   	inc    %edx
f0105fdd:	84 c9                	test   %cl,%cl
f0105fdf:	75 f5                	jne    f0105fd6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105fe1:	5b                   	pop    %ebx
f0105fe2:	5d                   	pop    %ebp
f0105fe3:	c3                   	ret    

f0105fe4 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105fe4:	55                   	push   %ebp
f0105fe5:	89 e5                	mov    %esp,%ebp
f0105fe7:	53                   	push   %ebx
f0105fe8:	83 ec 08             	sub    $0x8,%esp
f0105feb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105fee:	89 1c 24             	mov    %ebx,(%esp)
f0105ff1:	e8 9e ff ff ff       	call   f0105f94 <strlen>
	strcpy(dst + len, src);
f0105ff6:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105ff9:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105ffd:	01 d8                	add    %ebx,%eax
f0105fff:	89 04 24             	mov    %eax,(%esp)
f0106002:	e8 c0 ff ff ff       	call   f0105fc7 <strcpy>
	return dst;
}
f0106007:	89 d8                	mov    %ebx,%eax
f0106009:	83 c4 08             	add    $0x8,%esp
f010600c:	5b                   	pop    %ebx
f010600d:	5d                   	pop    %ebp
f010600e:	c3                   	ret    

f010600f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010600f:	55                   	push   %ebp
f0106010:	89 e5                	mov    %esp,%ebp
f0106012:	56                   	push   %esi
f0106013:	53                   	push   %ebx
f0106014:	8b 45 08             	mov    0x8(%ebp),%eax
f0106017:	8b 55 0c             	mov    0xc(%ebp),%edx
f010601a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010601d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0106022:	eb 0c                	jmp    f0106030 <strncpy+0x21>
		*dst++ = *src;
f0106024:	8a 1a                	mov    (%edx),%bl
f0106026:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0106029:	80 3a 01             	cmpb   $0x1,(%edx)
f010602c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010602f:	41                   	inc    %ecx
f0106030:	39 f1                	cmp    %esi,%ecx
f0106032:	75 f0                	jne    f0106024 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0106034:	5b                   	pop    %ebx
f0106035:	5e                   	pop    %esi
f0106036:	5d                   	pop    %ebp
f0106037:	c3                   	ret    

f0106038 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0106038:	55                   	push   %ebp
f0106039:	89 e5                	mov    %esp,%ebp
f010603b:	56                   	push   %esi
f010603c:	53                   	push   %ebx
f010603d:	8b 75 08             	mov    0x8(%ebp),%esi
f0106040:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106043:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0106046:	85 d2                	test   %edx,%edx
f0106048:	75 0a                	jne    f0106054 <strlcpy+0x1c>
f010604a:	89 f0                	mov    %esi,%eax
f010604c:	eb 1a                	jmp    f0106068 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010604e:	88 18                	mov    %bl,(%eax)
f0106050:	40                   	inc    %eax
f0106051:	41                   	inc    %ecx
f0106052:	eb 02                	jmp    f0106056 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0106054:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f0106056:	4a                   	dec    %edx
f0106057:	74 0a                	je     f0106063 <strlcpy+0x2b>
f0106059:	8a 19                	mov    (%ecx),%bl
f010605b:	84 db                	test   %bl,%bl
f010605d:	75 ef                	jne    f010604e <strlcpy+0x16>
f010605f:	89 c2                	mov    %eax,%edx
f0106061:	eb 02                	jmp    f0106065 <strlcpy+0x2d>
f0106063:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0106065:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0106068:	29 f0                	sub    %esi,%eax
}
f010606a:	5b                   	pop    %ebx
f010606b:	5e                   	pop    %esi
f010606c:	5d                   	pop    %ebp
f010606d:	c3                   	ret    

f010606e <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010606e:	55                   	push   %ebp
f010606f:	89 e5                	mov    %esp,%ebp
f0106071:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106074:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0106077:	eb 02                	jmp    f010607b <strcmp+0xd>
		p++, q++;
f0106079:	41                   	inc    %ecx
f010607a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010607b:	8a 01                	mov    (%ecx),%al
f010607d:	84 c0                	test   %al,%al
f010607f:	74 04                	je     f0106085 <strcmp+0x17>
f0106081:	3a 02                	cmp    (%edx),%al
f0106083:	74 f4                	je     f0106079 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0106085:	0f b6 c0             	movzbl %al,%eax
f0106088:	0f b6 12             	movzbl (%edx),%edx
f010608b:	29 d0                	sub    %edx,%eax
}
f010608d:	5d                   	pop    %ebp
f010608e:	c3                   	ret    

f010608f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010608f:	55                   	push   %ebp
f0106090:	89 e5                	mov    %esp,%ebp
f0106092:	53                   	push   %ebx
f0106093:	8b 45 08             	mov    0x8(%ebp),%eax
f0106096:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106099:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f010609c:	eb 03                	jmp    f01060a1 <strncmp+0x12>
		n--, p++, q++;
f010609e:	4a                   	dec    %edx
f010609f:	40                   	inc    %eax
f01060a0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01060a1:	85 d2                	test   %edx,%edx
f01060a3:	74 14                	je     f01060b9 <strncmp+0x2a>
f01060a5:	8a 18                	mov    (%eax),%bl
f01060a7:	84 db                	test   %bl,%bl
f01060a9:	74 04                	je     f01060af <strncmp+0x20>
f01060ab:	3a 19                	cmp    (%ecx),%bl
f01060ad:	74 ef                	je     f010609e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01060af:	0f b6 00             	movzbl (%eax),%eax
f01060b2:	0f b6 11             	movzbl (%ecx),%edx
f01060b5:	29 d0                	sub    %edx,%eax
f01060b7:	eb 05                	jmp    f01060be <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01060b9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01060be:	5b                   	pop    %ebx
f01060bf:	5d                   	pop    %ebp
f01060c0:	c3                   	ret    

f01060c1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01060c1:	55                   	push   %ebp
f01060c2:	89 e5                	mov    %esp,%ebp
f01060c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01060c7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01060ca:	eb 05                	jmp    f01060d1 <strchr+0x10>
		if (*s == c)
f01060cc:	38 ca                	cmp    %cl,%dl
f01060ce:	74 0c                	je     f01060dc <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01060d0:	40                   	inc    %eax
f01060d1:	8a 10                	mov    (%eax),%dl
f01060d3:	84 d2                	test   %dl,%dl
f01060d5:	75 f5                	jne    f01060cc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f01060d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01060dc:	5d                   	pop    %ebp
f01060dd:	c3                   	ret    

f01060de <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01060de:	55                   	push   %ebp
f01060df:	89 e5                	mov    %esp,%ebp
f01060e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01060e4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01060e7:	eb 05                	jmp    f01060ee <strfind+0x10>
		if (*s == c)
f01060e9:	38 ca                	cmp    %cl,%dl
f01060eb:	74 07                	je     f01060f4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01060ed:	40                   	inc    %eax
f01060ee:	8a 10                	mov    (%eax),%dl
f01060f0:	84 d2                	test   %dl,%dl
f01060f2:	75 f5                	jne    f01060e9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f01060f4:	5d                   	pop    %ebp
f01060f5:	c3                   	ret    

f01060f6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01060f6:	55                   	push   %ebp
f01060f7:	89 e5                	mov    %esp,%ebp
f01060f9:	57                   	push   %edi
f01060fa:	56                   	push   %esi
f01060fb:	53                   	push   %ebx
f01060fc:	8b 7d 08             	mov    0x8(%ebp),%edi
f01060ff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106102:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0106105:	85 c9                	test   %ecx,%ecx
f0106107:	74 30                	je     f0106139 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0106109:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010610f:	75 25                	jne    f0106136 <memset+0x40>
f0106111:	f6 c1 03             	test   $0x3,%cl
f0106114:	75 20                	jne    f0106136 <memset+0x40>
		c &= 0xFF;
f0106116:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0106119:	89 d3                	mov    %edx,%ebx
f010611b:	c1 e3 08             	shl    $0x8,%ebx
f010611e:	89 d6                	mov    %edx,%esi
f0106120:	c1 e6 18             	shl    $0x18,%esi
f0106123:	89 d0                	mov    %edx,%eax
f0106125:	c1 e0 10             	shl    $0x10,%eax
f0106128:	09 f0                	or     %esi,%eax
f010612a:	09 d0                	or     %edx,%eax
f010612c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010612e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0106131:	fc                   	cld    
f0106132:	f3 ab                	rep stos %eax,%es:(%edi)
f0106134:	eb 03                	jmp    f0106139 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0106136:	fc                   	cld    
f0106137:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0106139:	89 f8                	mov    %edi,%eax
f010613b:	5b                   	pop    %ebx
f010613c:	5e                   	pop    %esi
f010613d:	5f                   	pop    %edi
f010613e:	5d                   	pop    %ebp
f010613f:	c3                   	ret    

f0106140 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0106140:	55                   	push   %ebp
f0106141:	89 e5                	mov    %esp,%ebp
f0106143:	57                   	push   %edi
f0106144:	56                   	push   %esi
f0106145:	8b 45 08             	mov    0x8(%ebp),%eax
f0106148:	8b 75 0c             	mov    0xc(%ebp),%esi
f010614b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010614e:	39 c6                	cmp    %eax,%esi
f0106150:	73 34                	jae    f0106186 <memmove+0x46>
f0106152:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0106155:	39 d0                	cmp    %edx,%eax
f0106157:	73 2d                	jae    f0106186 <memmove+0x46>
		s += n;
		d += n;
f0106159:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010615c:	f6 c2 03             	test   $0x3,%dl
f010615f:	75 1b                	jne    f010617c <memmove+0x3c>
f0106161:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0106167:	75 13                	jne    f010617c <memmove+0x3c>
f0106169:	f6 c1 03             	test   $0x3,%cl
f010616c:	75 0e                	jne    f010617c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010616e:	83 ef 04             	sub    $0x4,%edi
f0106171:	8d 72 fc             	lea    -0x4(%edx),%esi
f0106174:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0106177:	fd                   	std    
f0106178:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010617a:	eb 07                	jmp    f0106183 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010617c:	4f                   	dec    %edi
f010617d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0106180:	fd                   	std    
f0106181:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0106183:	fc                   	cld    
f0106184:	eb 20                	jmp    f01061a6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106186:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010618c:	75 13                	jne    f01061a1 <memmove+0x61>
f010618e:	a8 03                	test   $0x3,%al
f0106190:	75 0f                	jne    f01061a1 <memmove+0x61>
f0106192:	f6 c1 03             	test   $0x3,%cl
f0106195:	75 0a                	jne    f01061a1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0106197:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010619a:	89 c7                	mov    %eax,%edi
f010619c:	fc                   	cld    
f010619d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010619f:	eb 05                	jmp    f01061a6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01061a1:	89 c7                	mov    %eax,%edi
f01061a3:	fc                   	cld    
f01061a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01061a6:	5e                   	pop    %esi
f01061a7:	5f                   	pop    %edi
f01061a8:	5d                   	pop    %ebp
f01061a9:	c3                   	ret    

f01061aa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01061aa:	55                   	push   %ebp
f01061ab:	89 e5                	mov    %esp,%ebp
f01061ad:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01061b0:	8b 45 10             	mov    0x10(%ebp),%eax
f01061b3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01061b7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01061ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061be:	8b 45 08             	mov    0x8(%ebp),%eax
f01061c1:	89 04 24             	mov    %eax,(%esp)
f01061c4:	e8 77 ff ff ff       	call   f0106140 <memmove>
}
f01061c9:	c9                   	leave  
f01061ca:	c3                   	ret    

f01061cb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01061cb:	55                   	push   %ebp
f01061cc:	89 e5                	mov    %esp,%ebp
f01061ce:	57                   	push   %edi
f01061cf:	56                   	push   %esi
f01061d0:	53                   	push   %ebx
f01061d1:	8b 7d 08             	mov    0x8(%ebp),%edi
f01061d4:	8b 75 0c             	mov    0xc(%ebp),%esi
f01061d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01061da:	ba 00 00 00 00       	mov    $0x0,%edx
f01061df:	eb 16                	jmp    f01061f7 <memcmp+0x2c>
		if (*s1 != *s2)
f01061e1:	8a 04 17             	mov    (%edi,%edx,1),%al
f01061e4:	42                   	inc    %edx
f01061e5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f01061e9:	38 c8                	cmp    %cl,%al
f01061eb:	74 0a                	je     f01061f7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f01061ed:	0f b6 c0             	movzbl %al,%eax
f01061f0:	0f b6 c9             	movzbl %cl,%ecx
f01061f3:	29 c8                	sub    %ecx,%eax
f01061f5:	eb 09                	jmp    f0106200 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01061f7:	39 da                	cmp    %ebx,%edx
f01061f9:	75 e6                	jne    f01061e1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01061fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106200:	5b                   	pop    %ebx
f0106201:	5e                   	pop    %esi
f0106202:	5f                   	pop    %edi
f0106203:	5d                   	pop    %ebp
f0106204:	c3                   	ret    

f0106205 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0106205:	55                   	push   %ebp
f0106206:	89 e5                	mov    %esp,%ebp
f0106208:	8b 45 08             	mov    0x8(%ebp),%eax
f010620b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010620e:	89 c2                	mov    %eax,%edx
f0106210:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0106213:	eb 05                	jmp    f010621a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106215:	38 08                	cmp    %cl,(%eax)
f0106217:	74 05                	je     f010621e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0106219:	40                   	inc    %eax
f010621a:	39 d0                	cmp    %edx,%eax
f010621c:	72 f7                	jb     f0106215 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010621e:	5d                   	pop    %ebp
f010621f:	c3                   	ret    

f0106220 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0106220:	55                   	push   %ebp
f0106221:	89 e5                	mov    %esp,%ebp
f0106223:	57                   	push   %edi
f0106224:	56                   	push   %esi
f0106225:	53                   	push   %ebx
f0106226:	8b 55 08             	mov    0x8(%ebp),%edx
f0106229:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010622c:	eb 01                	jmp    f010622f <strtol+0xf>
		s++;
f010622e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010622f:	8a 02                	mov    (%edx),%al
f0106231:	3c 20                	cmp    $0x20,%al
f0106233:	74 f9                	je     f010622e <strtol+0xe>
f0106235:	3c 09                	cmp    $0x9,%al
f0106237:	74 f5                	je     f010622e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0106239:	3c 2b                	cmp    $0x2b,%al
f010623b:	75 08                	jne    f0106245 <strtol+0x25>
		s++;
f010623d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010623e:	bf 00 00 00 00       	mov    $0x0,%edi
f0106243:	eb 13                	jmp    f0106258 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0106245:	3c 2d                	cmp    $0x2d,%al
f0106247:	75 0a                	jne    f0106253 <strtol+0x33>
		s++, neg = 1;
f0106249:	8d 52 01             	lea    0x1(%edx),%edx
f010624c:	bf 01 00 00 00       	mov    $0x1,%edi
f0106251:	eb 05                	jmp    f0106258 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0106253:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106258:	85 db                	test   %ebx,%ebx
f010625a:	74 05                	je     f0106261 <strtol+0x41>
f010625c:	83 fb 10             	cmp    $0x10,%ebx
f010625f:	75 28                	jne    f0106289 <strtol+0x69>
f0106261:	8a 02                	mov    (%edx),%al
f0106263:	3c 30                	cmp    $0x30,%al
f0106265:	75 10                	jne    f0106277 <strtol+0x57>
f0106267:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010626b:	75 0a                	jne    f0106277 <strtol+0x57>
		s += 2, base = 16;
f010626d:	83 c2 02             	add    $0x2,%edx
f0106270:	bb 10 00 00 00       	mov    $0x10,%ebx
f0106275:	eb 12                	jmp    f0106289 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0106277:	85 db                	test   %ebx,%ebx
f0106279:	75 0e                	jne    f0106289 <strtol+0x69>
f010627b:	3c 30                	cmp    $0x30,%al
f010627d:	75 05                	jne    f0106284 <strtol+0x64>
		s++, base = 8;
f010627f:	42                   	inc    %edx
f0106280:	b3 08                	mov    $0x8,%bl
f0106282:	eb 05                	jmp    f0106289 <strtol+0x69>
	else if (base == 0)
		base = 10;
f0106284:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0106289:	b8 00 00 00 00       	mov    $0x0,%eax
f010628e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106290:	8a 0a                	mov    (%edx),%cl
f0106292:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0106295:	80 fb 09             	cmp    $0x9,%bl
f0106298:	77 08                	ja     f01062a2 <strtol+0x82>
			dig = *s - '0';
f010629a:	0f be c9             	movsbl %cl,%ecx
f010629d:	83 e9 30             	sub    $0x30,%ecx
f01062a0:	eb 1e                	jmp    f01062c0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f01062a2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01062a5:	80 fb 19             	cmp    $0x19,%bl
f01062a8:	77 08                	ja     f01062b2 <strtol+0x92>
			dig = *s - 'a' + 10;
f01062aa:	0f be c9             	movsbl %cl,%ecx
f01062ad:	83 e9 57             	sub    $0x57,%ecx
f01062b0:	eb 0e                	jmp    f01062c0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f01062b2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01062b5:	80 fb 19             	cmp    $0x19,%bl
f01062b8:	77 12                	ja     f01062cc <strtol+0xac>
			dig = *s - 'A' + 10;
f01062ba:	0f be c9             	movsbl %cl,%ecx
f01062bd:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01062c0:	39 f1                	cmp    %esi,%ecx
f01062c2:	7d 0c                	jge    f01062d0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f01062c4:	42                   	inc    %edx
f01062c5:	0f af c6             	imul   %esi,%eax
f01062c8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01062ca:	eb c4                	jmp    f0106290 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01062cc:	89 c1                	mov    %eax,%ecx
f01062ce:	eb 02                	jmp    f01062d2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01062d0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01062d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01062d6:	74 05                	je     f01062dd <strtol+0xbd>
		*endptr = (char *) s;
f01062d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01062db:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01062dd:	85 ff                	test   %edi,%edi
f01062df:	74 04                	je     f01062e5 <strtol+0xc5>
f01062e1:	89 c8                	mov    %ecx,%eax
f01062e3:	f7 d8                	neg    %eax
}
f01062e5:	5b                   	pop    %ebx
f01062e6:	5e                   	pop    %esi
f01062e7:	5f                   	pop    %edi
f01062e8:	5d                   	pop    %ebp
f01062e9:	c3                   	ret    
	...

f01062ec <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01062ec:	fa                   	cli    

	xorw    %ax, %ax
f01062ed:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01062ef:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01062f1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01062f3:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01062f5:	0f 01 16             	lgdtl  (%esi)
f01062f8:	74 70                	je     f010636a <sum+0x2>
	movl    %cr0, %eax
f01062fa:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01062fd:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106301:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106304:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010630a:	08 00                	or     %al,(%eax)

f010630c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f010630c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106310:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106312:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106314:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0106316:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010631a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f010631c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010631e:	b8 00 80 12 00       	mov    $0x128000,%eax
	movl    %eax, %cr3
f0106323:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106326:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106329:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010632e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0106331:	8b 25 84 2e 33 f0    	mov    0xf0332e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106337:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010633c:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f0106341:	ff d0                	call   *%eax

f0106343 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0106343:	eb fe                	jmp    f0106343 <spin>
f0106345:	8d 76 00             	lea    0x0(%esi),%esi

f0106348 <gdt>:
	...
f0106350:	ff                   	(bad)  
f0106351:	ff 00                	incl   (%eax)
f0106353:	00 00                	add    %al,(%eax)
f0106355:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f010635c:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0106360 <gdtdesc>:
f0106360:	17                   	pop    %ss
f0106361:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106366 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106366:	90                   	nop
	...

f0106368 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0106368:	55                   	push   %ebp
f0106369:	89 e5                	mov    %esp,%ebp
f010636b:	56                   	push   %esi
f010636c:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f010636d:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f0106372:	b9 00 00 00 00       	mov    $0x0,%ecx
f0106377:	eb 07                	jmp    f0106380 <sum+0x18>
		sum += ((uint8_t *)addr)[i];
f0106379:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f010637d:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010637f:	41                   	inc    %ecx
f0106380:	39 d1                	cmp    %edx,%ecx
f0106382:	7c f5                	jl     f0106379 <sum+0x11>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0106384:	88 d8                	mov    %bl,%al
f0106386:	5b                   	pop    %ebx
f0106387:	5e                   	pop    %esi
f0106388:	5d                   	pop    %ebp
f0106389:	c3                   	ret    

f010638a <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f010638a:	55                   	push   %ebp
f010638b:	89 e5                	mov    %esp,%ebp
f010638d:	56                   	push   %esi
f010638e:	53                   	push   %ebx
f010638f:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106392:	8b 0d 88 2e 33 f0    	mov    0xf0332e88,%ecx
f0106398:	89 c3                	mov    %eax,%ebx
f010639a:	c1 eb 0c             	shr    $0xc,%ebx
f010639d:	39 cb                	cmp    %ecx,%ebx
f010639f:	72 20                	jb     f01063c1 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01063a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01063a5:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f01063ac:	f0 
f01063ad:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01063b4:	00 
f01063b5:	c7 04 24 65 8c 10 f0 	movl   $0xf0108c65,(%esp)
f01063bc:	e8 7f 9c ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01063c1:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01063c4:	89 f2                	mov    %esi,%edx
f01063c6:	c1 ea 0c             	shr    $0xc,%edx
f01063c9:	39 d1                	cmp    %edx,%ecx
f01063cb:	77 20                	ja     f01063ed <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01063cd:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01063d1:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f01063d8:	f0 
f01063d9:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01063e0:	00 
f01063e1:	c7 04 24 65 8c 10 f0 	movl   $0xf0108c65,(%esp)
f01063e8:	e8 53 9c ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01063ed:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01063f3:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f01063f9:	eb 2f                	jmp    f010642a <mpsearch1+0xa0>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01063fb:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106402:	00 
f0106403:	c7 44 24 04 75 8c 10 	movl   $0xf0108c75,0x4(%esp)
f010640a:	f0 
f010640b:	89 1c 24             	mov    %ebx,(%esp)
f010640e:	e8 b8 fd ff ff       	call   f01061cb <memcmp>
f0106413:	85 c0                	test   %eax,%eax
f0106415:	75 10                	jne    f0106427 <mpsearch1+0x9d>
		    sum(mp, sizeof(*mp)) == 0)
f0106417:	ba 10 00 00 00       	mov    $0x10,%edx
f010641c:	89 d8                	mov    %ebx,%eax
f010641e:	e8 45 ff ff ff       	call   f0106368 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106423:	84 c0                	test   %al,%al
f0106425:	74 0c                	je     f0106433 <mpsearch1+0xa9>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106427:	83 c3 10             	add    $0x10,%ebx
f010642a:	39 f3                	cmp    %esi,%ebx
f010642c:	72 cd                	jb     f01063fb <mpsearch1+0x71>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010642e:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0106433:	89 d8                	mov    %ebx,%eax
f0106435:	83 c4 10             	add    $0x10,%esp
f0106438:	5b                   	pop    %ebx
f0106439:	5e                   	pop    %esi
f010643a:	5d                   	pop    %ebp
f010643b:	c3                   	ret    

f010643c <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010643c:	55                   	push   %ebp
f010643d:	89 e5                	mov    %esp,%ebp
f010643f:	57                   	push   %edi
f0106440:	56                   	push   %esi
f0106441:	53                   	push   %ebx
f0106442:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106445:	c7 05 c0 33 33 f0 20 	movl   $0xf0333020,0xf03333c0
f010644c:	30 33 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010644f:	83 3d 88 2e 33 f0 00 	cmpl   $0x0,0xf0332e88
f0106456:	75 24                	jne    f010647c <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106458:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f010645f:	00 
f0106460:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f0106467:	f0 
f0106468:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f010646f:	00 
f0106470:	c7 04 24 65 8c 10 f0 	movl   $0xf0108c65,(%esp)
f0106477:	e8 c4 9b ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010647c:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106483:	85 c0                	test   %eax,%eax
f0106485:	74 16                	je     f010649d <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f0106487:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f010648a:	ba 00 04 00 00       	mov    $0x400,%edx
f010648f:	e8 f6 fe ff ff       	call   f010638a <mpsearch1>
f0106494:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106497:	85 c0                	test   %eax,%eax
f0106499:	75 3c                	jne    f01064d7 <mp_init+0x9b>
f010649b:	eb 20                	jmp    f01064bd <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f010649d:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01064a4:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01064a7:	2d 00 04 00 00       	sub    $0x400,%eax
f01064ac:	ba 00 04 00 00       	mov    $0x400,%edx
f01064b1:	e8 d4 fe ff ff       	call   f010638a <mpsearch1>
f01064b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01064b9:	85 c0                	test   %eax,%eax
f01064bb:	75 1a                	jne    f01064d7 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01064bd:	ba 00 00 01 00       	mov    $0x10000,%edx
f01064c2:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01064c7:	e8 be fe ff ff       	call   f010638a <mpsearch1>
f01064cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01064cf:	85 c0                	test   %eax,%eax
f01064d1:	0f 84 2c 02 00 00    	je     f0106703 <mp_init+0x2c7>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01064d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01064da:	8b 58 04             	mov    0x4(%eax),%ebx
f01064dd:	85 db                	test   %ebx,%ebx
f01064df:	74 06                	je     f01064e7 <mp_init+0xab>
f01064e1:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01064e5:	74 11                	je     f01064f8 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f01064e7:	c7 04 24 d8 8a 10 f0 	movl   $0xf0108ad8,(%esp)
f01064ee:	e8 af dc ff ff       	call   f01041a2 <cprintf>
f01064f3:	e9 0b 02 00 00       	jmp    f0106703 <mp_init+0x2c7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01064f8:	89 d8                	mov    %ebx,%eax
f01064fa:	c1 e8 0c             	shr    $0xc,%eax
f01064fd:	3b 05 88 2e 33 f0    	cmp    0xf0332e88,%eax
f0106503:	72 20                	jb     f0106525 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106505:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106509:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f0106510:	f0 
f0106511:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106518:	00 
f0106519:	c7 04 24 65 8c 10 f0 	movl   $0xf0108c65,(%esp)
f0106520:	e8 1b 9b ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106525:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f010652b:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106532:	00 
f0106533:	c7 44 24 04 7a 8c 10 	movl   $0xf0108c7a,0x4(%esp)
f010653a:	f0 
f010653b:	89 1c 24             	mov    %ebx,(%esp)
f010653e:	e8 88 fc ff ff       	call   f01061cb <memcmp>
f0106543:	85 c0                	test   %eax,%eax
f0106545:	74 11                	je     f0106558 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106547:	c7 04 24 08 8b 10 f0 	movl   $0xf0108b08,(%esp)
f010654e:	e8 4f dc ff ff       	call   f01041a2 <cprintf>
f0106553:	e9 ab 01 00 00       	jmp    f0106703 <mp_init+0x2c7>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106558:	66 8b 73 04          	mov    0x4(%ebx),%si
f010655c:	0f b7 d6             	movzwl %si,%edx
f010655f:	89 d8                	mov    %ebx,%eax
f0106561:	e8 02 fe ff ff       	call   f0106368 <sum>
f0106566:	84 c0                	test   %al,%al
f0106568:	74 11                	je     f010657b <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f010656a:	c7 04 24 3c 8b 10 f0 	movl   $0xf0108b3c,(%esp)
f0106571:	e8 2c dc ff ff       	call   f01041a2 <cprintf>
f0106576:	e9 88 01 00 00       	jmp    f0106703 <mp_init+0x2c7>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f010657b:	8a 43 06             	mov    0x6(%ebx),%al
f010657e:	3c 01                	cmp    $0x1,%al
f0106580:	74 1c                	je     f010659e <mp_init+0x162>
f0106582:	3c 04                	cmp    $0x4,%al
f0106584:	74 18                	je     f010659e <mp_init+0x162>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106586:	0f b6 c0             	movzbl %al,%eax
f0106589:	89 44 24 04          	mov    %eax,0x4(%esp)
f010658d:	c7 04 24 60 8b 10 f0 	movl   $0xf0108b60,(%esp)
f0106594:	e8 09 dc ff ff       	call   f01041a2 <cprintf>
f0106599:	e9 65 01 00 00       	jmp    f0106703 <mp_init+0x2c7>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010659e:	0f b7 53 28          	movzwl 0x28(%ebx),%edx
f01065a2:	0f b7 c6             	movzwl %si,%eax
f01065a5:	01 d8                	add    %ebx,%eax
f01065a7:	e8 bc fd ff ff       	call   f0106368 <sum>
f01065ac:	02 43 2a             	add    0x2a(%ebx),%al
f01065af:	84 c0                	test   %al,%al
f01065b1:	74 11                	je     f01065c4 <mp_init+0x188>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01065b3:	c7 04 24 80 8b 10 f0 	movl   $0xf0108b80,(%esp)
f01065ba:	e8 e3 db ff ff       	call   f01041a2 <cprintf>
f01065bf:	e9 3f 01 00 00       	jmp    f0106703 <mp_init+0x2c7>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01065c4:	85 db                	test   %ebx,%ebx
f01065c6:	0f 84 37 01 00 00    	je     f0106703 <mp_init+0x2c7>
		return;
	ismp = 1;
f01065cc:	c7 05 00 30 33 f0 01 	movl   $0x1,0xf0333000
f01065d3:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01065d6:	8b 43 24             	mov    0x24(%ebx),%eax
f01065d9:	a3 00 40 37 f0       	mov    %eax,0xf0374000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01065de:	8d 73 2c             	lea    0x2c(%ebx),%esi
f01065e1:	bf 00 00 00 00       	mov    $0x0,%edi
f01065e6:	e9 94 00 00 00       	jmp    f010667f <mp_init+0x243>
		switch (*p) {
f01065eb:	8a 06                	mov    (%esi),%al
f01065ed:	84 c0                	test   %al,%al
f01065ef:	74 06                	je     f01065f7 <mp_init+0x1bb>
f01065f1:	3c 04                	cmp    $0x4,%al
f01065f3:	77 68                	ja     f010665d <mp_init+0x221>
f01065f5:	eb 61                	jmp    f0106658 <mp_init+0x21c>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01065f7:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f01065fb:	74 1d                	je     f010661a <mp_init+0x1de>
				bootcpu = &cpus[ncpu];
f01065fd:	a1 c4 33 33 f0       	mov    0xf03333c4,%eax
f0106602:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106609:	29 c2                	sub    %eax,%edx
f010660b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010660e:	8d 04 85 20 30 33 f0 	lea    -0xfcccfe0(,%eax,4),%eax
f0106615:	a3 c0 33 33 f0       	mov    %eax,0xf03333c0
			if (ncpu < NCPU) {
f010661a:	a1 c4 33 33 f0       	mov    0xf03333c4,%eax
f010661f:	83 f8 07             	cmp    $0x7,%eax
f0106622:	7f 1b                	jg     f010663f <mp_init+0x203>
				cpus[ncpu].cpu_id = ncpu;
f0106624:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010662b:	29 c2                	sub    %eax,%edx
f010662d:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0106630:	88 04 95 20 30 33 f0 	mov    %al,-0xfcccfe0(,%edx,4)
				ncpu++;
f0106637:	40                   	inc    %eax
f0106638:	a3 c4 33 33 f0       	mov    %eax,0xf03333c4
f010663d:	eb 14                	jmp    f0106653 <mp_init+0x217>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010663f:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0106643:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106647:	c7 04 24 b0 8b 10 f0 	movl   $0xf0108bb0,(%esp)
f010664e:	e8 4f db ff ff       	call   f01041a2 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106653:	83 c6 14             	add    $0x14,%esi
			continue;
f0106656:	eb 26                	jmp    f010667e <mp_init+0x242>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106658:	83 c6 08             	add    $0x8,%esi
			continue;
f010665b:	eb 21                	jmp    f010667e <mp_init+0x242>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010665d:	0f b6 c0             	movzbl %al,%eax
f0106660:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106664:	c7 04 24 d8 8b 10 f0 	movl   $0xf0108bd8,(%esp)
f010666b:	e8 32 db ff ff       	call   f01041a2 <cprintf>
			ismp = 0;
f0106670:	c7 05 00 30 33 f0 00 	movl   $0x0,0xf0333000
f0106677:	00 00 00 
			i = conf->entry;
f010667a:	0f b7 7b 22          	movzwl 0x22(%ebx),%edi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010667e:	47                   	inc    %edi
f010667f:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0106683:	39 c7                	cmp    %eax,%edi
f0106685:	0f 82 60 ff ff ff    	jb     f01065eb <mp_init+0x1af>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010668b:	a1 c0 33 33 f0       	mov    0xf03333c0,%eax
f0106690:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106697:	83 3d 00 30 33 f0 00 	cmpl   $0x0,0xf0333000
f010669e:	75 22                	jne    f01066c2 <mp_init+0x286>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01066a0:	c7 05 c4 33 33 f0 01 	movl   $0x1,0xf03333c4
f01066a7:	00 00 00 
		lapicaddr = 0;
f01066aa:	c7 05 00 40 37 f0 00 	movl   $0x0,0xf0374000
f01066b1:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01066b4:	c7 04 24 f8 8b 10 f0 	movl   $0xf0108bf8,(%esp)
f01066bb:	e8 e2 da ff ff       	call   f01041a2 <cprintf>
		return;
f01066c0:	eb 41                	jmp    f0106703 <mp_init+0x2c7>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01066c2:	8b 15 c4 33 33 f0    	mov    0xf03333c4,%edx
f01066c8:	89 54 24 08          	mov    %edx,0x8(%esp)
f01066cc:	0f b6 00             	movzbl (%eax),%eax
f01066cf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066d3:	c7 04 24 7f 8c 10 f0 	movl   $0xf0108c7f,(%esp)
f01066da:	e8 c3 da ff ff       	call   f01041a2 <cprintf>

	if (mp->imcrp) {
f01066df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01066e2:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01066e6:	74 1b                	je     f0106703 <mp_init+0x2c7>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01066e8:	c7 04 24 24 8c 10 f0 	movl   $0xf0108c24,(%esp)
f01066ef:	e8 ae da ff ff       	call   f01041a2 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01066f4:	ba 22 00 00 00       	mov    $0x22,%edx
f01066f9:	b0 70                	mov    $0x70,%al
f01066fb:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01066fc:	b2 23                	mov    $0x23,%dl
f01066fe:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01066ff:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106702:	ee                   	out    %al,(%dx)
	}
}
f0106703:	83 c4 2c             	add    $0x2c,%esp
f0106706:	5b                   	pop    %ebx
f0106707:	5e                   	pop    %esi
f0106708:	5f                   	pop    %edi
f0106709:	5d                   	pop    %ebp
f010670a:	c3                   	ret    
	...

f010670c <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f010670c:	55                   	push   %ebp
f010670d:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f010670f:	c1 e0 02             	shl    $0x2,%eax
f0106712:	03 05 04 40 37 f0    	add    0xf0374004,%eax
f0106718:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010671a:	a1 04 40 37 f0       	mov    0xf0374004,%eax
f010671f:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106722:	5d                   	pop    %ebp
f0106723:	c3                   	ret    

f0106724 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106724:	55                   	push   %ebp
f0106725:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106727:	a1 04 40 37 f0       	mov    0xf0374004,%eax
f010672c:	85 c0                	test   %eax,%eax
f010672e:	74 08                	je     f0106738 <cpunum+0x14>
		return lapic[ID] >> 24;
f0106730:	8b 40 20             	mov    0x20(%eax),%eax
f0106733:	c1 e8 18             	shr    $0x18,%eax
f0106736:	eb 05                	jmp    f010673d <cpunum+0x19>
	return 0;
f0106738:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010673d:	5d                   	pop    %ebp
f010673e:	c3                   	ret    

f010673f <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f010673f:	55                   	push   %ebp
f0106740:	89 e5                	mov    %esp,%ebp
f0106742:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f0106745:	a1 00 40 37 f0       	mov    0xf0374000,%eax
f010674a:	85 c0                	test   %eax,%eax
f010674c:	0f 84 27 01 00 00    	je     f0106879 <lapic_init+0x13a>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106752:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0106759:	00 
f010675a:	89 04 24             	mov    %eax,(%esp)
f010675d:	e8 82 ae ff ff       	call   f01015e4 <mmio_map_region>
f0106762:	a3 04 40 37 f0       	mov    %eax,0xf0374004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106767:	ba 27 01 00 00       	mov    $0x127,%edx
f010676c:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106771:	e8 96 ff ff ff       	call   f010670c <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0106776:	ba 0b 00 00 00       	mov    $0xb,%edx
f010677b:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106780:	e8 87 ff ff ff       	call   f010670c <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106785:	ba 20 00 02 00       	mov    $0x20020,%edx
f010678a:	b8 c8 00 00 00       	mov    $0xc8,%eax
f010678f:	e8 78 ff ff ff       	call   f010670c <lapicw>
	lapicw(TICR, 10000000); 
f0106794:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106799:	b8 e0 00 00 00       	mov    $0xe0,%eax
f010679e:	e8 69 ff ff ff       	call   f010670c <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01067a3:	e8 7c ff ff ff       	call   f0106724 <cpunum>
f01067a8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01067af:	29 c2                	sub    %eax,%edx
f01067b1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01067b4:	8d 04 85 20 30 33 f0 	lea    -0xfcccfe0(,%eax,4),%eax
f01067bb:	39 05 c0 33 33 f0    	cmp    %eax,0xf03333c0
f01067c1:	74 0f                	je     f01067d2 <lapic_init+0x93>
		lapicw(LINT0, MASKED);
f01067c3:	ba 00 00 01 00       	mov    $0x10000,%edx
f01067c8:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01067cd:	e8 3a ff ff ff       	call   f010670c <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01067d2:	ba 00 00 01 00       	mov    $0x10000,%edx
f01067d7:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01067dc:	e8 2b ff ff ff       	call   f010670c <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01067e1:	a1 04 40 37 f0       	mov    0xf0374004,%eax
f01067e6:	8b 40 30             	mov    0x30(%eax),%eax
f01067e9:	c1 e8 10             	shr    $0x10,%eax
f01067ec:	3c 03                	cmp    $0x3,%al
f01067ee:	76 0f                	jbe    f01067ff <lapic_init+0xc0>
		lapicw(PCINT, MASKED);
f01067f0:	ba 00 00 01 00       	mov    $0x10000,%edx
f01067f5:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01067fa:	e8 0d ff ff ff       	call   f010670c <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01067ff:	ba 33 00 00 00       	mov    $0x33,%edx
f0106804:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106809:	e8 fe fe ff ff       	call   f010670c <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f010680e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106813:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106818:	e8 ef fe ff ff       	call   f010670c <lapicw>
	lapicw(ESR, 0);
f010681d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106822:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106827:	e8 e0 fe ff ff       	call   f010670c <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f010682c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106831:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106836:	e8 d1 fe ff ff       	call   f010670c <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010683b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106840:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106845:	e8 c2 fe ff ff       	call   f010670c <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010684a:	ba 00 85 08 00       	mov    $0x88500,%edx
f010684f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106854:	e8 b3 fe ff ff       	call   f010670c <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106859:	8b 15 04 40 37 f0    	mov    0xf0374004,%edx
f010685f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106865:	f6 c4 10             	test   $0x10,%ah
f0106868:	75 f5                	jne    f010685f <lapic_init+0x120>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010686a:	ba 00 00 00 00       	mov    $0x0,%edx
f010686f:	b8 20 00 00 00       	mov    $0x20,%eax
f0106874:	e8 93 fe ff ff       	call   f010670c <lapicw>
}
f0106879:	c9                   	leave  
f010687a:	c3                   	ret    

f010687b <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010687b:	55                   	push   %ebp
f010687c:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010687e:	83 3d 04 40 37 f0 00 	cmpl   $0x0,0xf0374004
f0106885:	74 0f                	je     f0106896 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f0106887:	ba 00 00 00 00       	mov    $0x0,%edx
f010688c:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106891:	e8 76 fe ff ff       	call   f010670c <lapicw>
}
f0106896:	5d                   	pop    %ebp
f0106897:	c3                   	ret    

f0106898 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106898:	55                   	push   %ebp
f0106899:	89 e5                	mov    %esp,%ebp
f010689b:	56                   	push   %esi
f010689c:	53                   	push   %ebx
f010689d:	83 ec 10             	sub    $0x10,%esp
f01068a0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01068a3:	8a 5d 08             	mov    0x8(%ebp),%bl
f01068a6:	ba 70 00 00 00       	mov    $0x70,%edx
f01068ab:	b0 0f                	mov    $0xf,%al
f01068ad:	ee                   	out    %al,(%dx)
f01068ae:	b2 71                	mov    $0x71,%dl
f01068b0:	b0 0a                	mov    $0xa,%al
f01068b2:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01068b3:	83 3d 88 2e 33 f0 00 	cmpl   $0x0,0xf0332e88
f01068ba:	75 24                	jne    f01068e0 <lapic_startap+0x48>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01068bc:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f01068c3:	00 
f01068c4:	c7 44 24 08 48 6e 10 	movl   $0xf0106e48,0x8(%esp)
f01068cb:	f0 
f01068cc:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f01068d3:	00 
f01068d4:	c7 04 24 9c 8c 10 f0 	movl   $0xf0108c9c,(%esp)
f01068db:	e8 60 97 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01068e0:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01068e7:	00 00 
	wrv[1] = addr >> 4;
f01068e9:	89 f0                	mov    %esi,%eax
f01068eb:	c1 e8 04             	shr    $0x4,%eax
f01068ee:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01068f4:	c1 e3 18             	shl    $0x18,%ebx
f01068f7:	89 da                	mov    %ebx,%edx
f01068f9:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01068fe:	e8 09 fe ff ff       	call   f010670c <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106903:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106908:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010690d:	e8 fa fd ff ff       	call   f010670c <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106912:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106917:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010691c:	e8 eb fd ff ff       	call   f010670c <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106921:	c1 ee 0c             	shr    $0xc,%esi
f0106924:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010692a:	89 da                	mov    %ebx,%edx
f010692c:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106931:	e8 d6 fd ff ff       	call   f010670c <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106936:	89 f2                	mov    %esi,%edx
f0106938:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010693d:	e8 ca fd ff ff       	call   f010670c <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106942:	89 da                	mov    %ebx,%edx
f0106944:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106949:	e8 be fd ff ff       	call   f010670c <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010694e:	89 f2                	mov    %esi,%edx
f0106950:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106955:	e8 b2 fd ff ff       	call   f010670c <lapicw>
		microdelay(200);
	}
}
f010695a:	83 c4 10             	add    $0x10,%esp
f010695d:	5b                   	pop    %ebx
f010695e:	5e                   	pop    %esi
f010695f:	5d                   	pop    %ebp
f0106960:	c3                   	ret    

f0106961 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106961:	55                   	push   %ebp
f0106962:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106964:	8b 55 08             	mov    0x8(%ebp),%edx
f0106967:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010696d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106972:	e8 95 fd ff ff       	call   f010670c <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106977:	8b 15 04 40 37 f0    	mov    0xf0374004,%edx
f010697d:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106983:	f6 c4 10             	test   $0x10,%ah
f0106986:	75 f5                	jne    f010697d <lapic_ipi+0x1c>
		;
}
f0106988:	5d                   	pop    %ebp
f0106989:	c3                   	ret    
	...

f010698c <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f010698c:	55                   	push   %ebp
f010698d:	89 e5                	mov    %esp,%ebp
f010698f:	53                   	push   %ebx
f0106990:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f0106993:	83 38 00             	cmpl   $0x0,(%eax)
f0106996:	74 25                	je     f01069bd <holding+0x31>
f0106998:	8b 58 08             	mov    0x8(%eax),%ebx
f010699b:	e8 84 fd ff ff       	call   f0106724 <cpunum>
f01069a0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01069a7:	29 c2                	sub    %eax,%edx
f01069a9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01069ac:	8d 04 85 20 30 33 f0 	lea    -0xfcccfe0(,%eax,4),%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f01069b3:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f01069b5:	0f 94 c0             	sete   %al
f01069b8:	0f b6 c0             	movzbl %al,%eax
f01069bb:	eb 05                	jmp    f01069c2 <holding+0x36>
f01069bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01069c2:	83 c4 04             	add    $0x4,%esp
f01069c5:	5b                   	pop    %ebx
f01069c6:	5d                   	pop    %ebp
f01069c7:	c3                   	ret    

f01069c8 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01069c8:	55                   	push   %ebp
f01069c9:	89 e5                	mov    %esp,%ebp
f01069cb:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01069ce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01069d4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01069d7:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01069da:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01069e1:	5d                   	pop    %ebp
f01069e2:	c3                   	ret    

f01069e3 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01069e3:	55                   	push   %ebp
f01069e4:	89 e5                	mov    %esp,%ebp
f01069e6:	53                   	push   %ebx
f01069e7:	83 ec 24             	sub    $0x24,%esp
f01069ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01069ed:	89 d8                	mov    %ebx,%eax
f01069ef:	e8 98 ff ff ff       	call   f010698c <holding>
f01069f4:	85 c0                	test   %eax,%eax
f01069f6:	74 30                	je     f0106a28 <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01069f8:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01069fb:	e8 24 fd ff ff       	call   f0106724 <cpunum>
f0106a00:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106a04:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106a08:	c7 44 24 08 ac 8c 10 	movl   $0xf0108cac,0x8(%esp)
f0106a0f:	f0 
f0106a10:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106a17:	00 
f0106a18:	c7 04 24 10 8d 10 f0 	movl   $0xf0108d10,(%esp)
f0106a1f:	e8 1c 96 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106a24:	f3 90                	pause  
f0106a26:	eb 05                	jmp    f0106a2d <spin_lock+0x4a>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106a28:	ba 01 00 00 00       	mov    $0x1,%edx
f0106a2d:	89 d0                	mov    %edx,%eax
f0106a2f:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106a32:	85 c0                	test   %eax,%eax
f0106a34:	75 ee                	jne    f0106a24 <spin_lock+0x41>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106a36:	e8 e9 fc ff ff       	call   f0106724 <cpunum>
f0106a3b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106a42:	29 c2                	sub    %eax,%edx
f0106a44:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106a47:	8d 04 85 20 30 33 f0 	lea    -0xfcccfe0(,%eax,4),%eax
f0106a4e:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106a51:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0106a54:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106a56:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106a5b:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106a61:	76 10                	jbe    f0106a73 <spin_lock+0x90>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106a63:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106a66:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106a69:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106a6b:	40                   	inc    %eax
f0106a6c:	83 f8 0a             	cmp    $0xa,%eax
f0106a6f:	75 ea                	jne    f0106a5b <spin_lock+0x78>
f0106a71:	eb 0d                	jmp    f0106a80 <spin_lock+0x9d>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106a73:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106a7a:	40                   	inc    %eax
f0106a7b:	83 f8 09             	cmp    $0x9,%eax
f0106a7e:	7e f3                	jle    f0106a73 <spin_lock+0x90>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106a80:	83 c4 24             	add    $0x24,%esp
f0106a83:	5b                   	pop    %ebx
f0106a84:	5d                   	pop    %ebp
f0106a85:	c3                   	ret    

f0106a86 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106a86:	55                   	push   %ebp
f0106a87:	89 e5                	mov    %esp,%ebp
f0106a89:	57                   	push   %edi
f0106a8a:	56                   	push   %esi
f0106a8b:	53                   	push   %ebx
f0106a8c:	83 ec 7c             	sub    $0x7c,%esp
f0106a8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106a92:	89 d8                	mov    %ebx,%eax
f0106a94:	e8 f3 fe ff ff       	call   f010698c <holding>
f0106a99:	85 c0                	test   %eax,%eax
f0106a9b:	0f 85 d3 00 00 00    	jne    f0106b74 <spin_unlock+0xee>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106aa1:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106aa8:	00 
f0106aa9:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106aac:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ab0:	8d 75 a8             	lea    -0x58(%ebp),%esi
f0106ab3:	89 34 24             	mov    %esi,(%esp)
f0106ab6:	e8 85 f6 ff ff       	call   f0106140 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106abb:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106abe:	0f b6 38             	movzbl (%eax),%edi
f0106ac1:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106ac4:	e8 5b fc ff ff       	call   f0106724 <cpunum>
f0106ac9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106acd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106ad1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ad5:	c7 04 24 d8 8c 10 f0 	movl   $0xf0108cd8,(%esp)
f0106adc:	e8 c1 d6 ff ff       	call   f01041a2 <cprintf>
f0106ae1:	89 f3                	mov    %esi,%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106ae3:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0106ae6:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106ae9:	89 c7                	mov    %eax,%edi
f0106aeb:	eb 63                	jmp    f0106b50 <spin_unlock+0xca>
f0106aed:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106af1:	89 04 24             	mov    %eax,(%esp)
f0106af4:	e8 34 eb ff ff       	call   f010562d <debuginfo_eip>
f0106af9:	85 c0                	test   %eax,%eax
f0106afb:	78 39                	js     f0106b36 <spin_unlock+0xb0>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106afd:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106aff:	89 c2                	mov    %eax,%edx
f0106b01:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0106b04:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106b08:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106b0b:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106b0f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106b12:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106b16:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0106b19:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106b1d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0106b20:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106b24:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b28:	c7 04 24 20 8d 10 f0 	movl   $0xf0108d20,(%esp)
f0106b2f:	e8 6e d6 ff ff       	call   f01041a2 <cprintf>
f0106b34:	eb 12                	jmp    f0106b48 <spin_unlock+0xc2>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106b36:	8b 06                	mov    (%esi),%eax
f0106b38:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b3c:	c7 04 24 37 8d 10 f0 	movl   $0xf0108d37,(%esp)
f0106b43:	e8 5a d6 ff ff       	call   f01041a2 <cprintf>
f0106b48:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106b4b:	3b 5d a4             	cmp    -0x5c(%ebp),%ebx
f0106b4e:	74 08                	je     f0106b58 <spin_unlock+0xd2>
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106b50:	89 de                	mov    %ebx,%esi
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106b52:	8b 03                	mov    (%ebx),%eax
f0106b54:	85 c0                	test   %eax,%eax
f0106b56:	75 95                	jne    f0106aed <spin_unlock+0x67>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106b58:	c7 44 24 08 3f 8d 10 	movl   $0xf0108d3f,0x8(%esp)
f0106b5f:	f0 
f0106b60:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0106b67:	00 
f0106b68:	c7 04 24 10 8d 10 f0 	movl   $0xf0108d10,(%esp)
f0106b6f:	e8 cc 94 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106b74:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0106b7b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
f0106b82:	b8 00 00 00 00       	mov    $0x0,%eax
f0106b87:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106b8a:	83 c4 7c             	add    $0x7c,%esp
f0106b8d:	5b                   	pop    %ebx
f0106b8e:	5e                   	pop    %esi
f0106b8f:	5f                   	pop    %edi
f0106b90:	5d                   	pop    %ebp
f0106b91:	c3                   	ret    
	...

f0106b94 <__udivdi3>:
f0106b94:	55                   	push   %ebp
f0106b95:	57                   	push   %edi
f0106b96:	56                   	push   %esi
f0106b97:	83 ec 10             	sub    $0x10,%esp
f0106b9a:	8b 74 24 20          	mov    0x20(%esp),%esi
f0106b9e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0106ba2:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106ba6:	8b 7c 24 24          	mov    0x24(%esp),%edi
f0106baa:	89 cd                	mov    %ecx,%ebp
f0106bac:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f0106bb0:	85 c0                	test   %eax,%eax
f0106bb2:	75 2c                	jne    f0106be0 <__udivdi3+0x4c>
f0106bb4:	39 f9                	cmp    %edi,%ecx
f0106bb6:	77 68                	ja     f0106c20 <__udivdi3+0x8c>
f0106bb8:	85 c9                	test   %ecx,%ecx
f0106bba:	75 0b                	jne    f0106bc7 <__udivdi3+0x33>
f0106bbc:	b8 01 00 00 00       	mov    $0x1,%eax
f0106bc1:	31 d2                	xor    %edx,%edx
f0106bc3:	f7 f1                	div    %ecx
f0106bc5:	89 c1                	mov    %eax,%ecx
f0106bc7:	31 d2                	xor    %edx,%edx
f0106bc9:	89 f8                	mov    %edi,%eax
f0106bcb:	f7 f1                	div    %ecx
f0106bcd:	89 c7                	mov    %eax,%edi
f0106bcf:	89 f0                	mov    %esi,%eax
f0106bd1:	f7 f1                	div    %ecx
f0106bd3:	89 c6                	mov    %eax,%esi
f0106bd5:	89 f0                	mov    %esi,%eax
f0106bd7:	89 fa                	mov    %edi,%edx
f0106bd9:	83 c4 10             	add    $0x10,%esp
f0106bdc:	5e                   	pop    %esi
f0106bdd:	5f                   	pop    %edi
f0106bde:	5d                   	pop    %ebp
f0106bdf:	c3                   	ret    
f0106be0:	39 f8                	cmp    %edi,%eax
f0106be2:	77 2c                	ja     f0106c10 <__udivdi3+0x7c>
f0106be4:	0f bd f0             	bsr    %eax,%esi
f0106be7:	83 f6 1f             	xor    $0x1f,%esi
f0106bea:	75 4c                	jne    f0106c38 <__udivdi3+0xa4>
f0106bec:	39 f8                	cmp    %edi,%eax
f0106bee:	bf 00 00 00 00       	mov    $0x0,%edi
f0106bf3:	72 0a                	jb     f0106bff <__udivdi3+0x6b>
f0106bf5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0106bf9:	0f 87 ad 00 00 00    	ja     f0106cac <__udivdi3+0x118>
f0106bff:	be 01 00 00 00       	mov    $0x1,%esi
f0106c04:	89 f0                	mov    %esi,%eax
f0106c06:	89 fa                	mov    %edi,%edx
f0106c08:	83 c4 10             	add    $0x10,%esp
f0106c0b:	5e                   	pop    %esi
f0106c0c:	5f                   	pop    %edi
f0106c0d:	5d                   	pop    %ebp
f0106c0e:	c3                   	ret    
f0106c0f:	90                   	nop
f0106c10:	31 ff                	xor    %edi,%edi
f0106c12:	31 f6                	xor    %esi,%esi
f0106c14:	89 f0                	mov    %esi,%eax
f0106c16:	89 fa                	mov    %edi,%edx
f0106c18:	83 c4 10             	add    $0x10,%esp
f0106c1b:	5e                   	pop    %esi
f0106c1c:	5f                   	pop    %edi
f0106c1d:	5d                   	pop    %ebp
f0106c1e:	c3                   	ret    
f0106c1f:	90                   	nop
f0106c20:	89 fa                	mov    %edi,%edx
f0106c22:	89 f0                	mov    %esi,%eax
f0106c24:	f7 f1                	div    %ecx
f0106c26:	89 c6                	mov    %eax,%esi
f0106c28:	31 ff                	xor    %edi,%edi
f0106c2a:	89 f0                	mov    %esi,%eax
f0106c2c:	89 fa                	mov    %edi,%edx
f0106c2e:	83 c4 10             	add    $0x10,%esp
f0106c31:	5e                   	pop    %esi
f0106c32:	5f                   	pop    %edi
f0106c33:	5d                   	pop    %ebp
f0106c34:	c3                   	ret    
f0106c35:	8d 76 00             	lea    0x0(%esi),%esi
f0106c38:	89 f1                	mov    %esi,%ecx
f0106c3a:	d3 e0                	shl    %cl,%eax
f0106c3c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106c40:	b8 20 00 00 00       	mov    $0x20,%eax
f0106c45:	29 f0                	sub    %esi,%eax
f0106c47:	89 ea                	mov    %ebp,%edx
f0106c49:	88 c1                	mov    %al,%cl
f0106c4b:	d3 ea                	shr    %cl,%edx
f0106c4d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f0106c51:	09 ca                	or     %ecx,%edx
f0106c53:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106c57:	89 f1                	mov    %esi,%ecx
f0106c59:	d3 e5                	shl    %cl,%ebp
f0106c5b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
f0106c5f:	89 fd                	mov    %edi,%ebp
f0106c61:	88 c1                	mov    %al,%cl
f0106c63:	d3 ed                	shr    %cl,%ebp
f0106c65:	89 fa                	mov    %edi,%edx
f0106c67:	89 f1                	mov    %esi,%ecx
f0106c69:	d3 e2                	shl    %cl,%edx
f0106c6b:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106c6f:	88 c1                	mov    %al,%cl
f0106c71:	d3 ef                	shr    %cl,%edi
f0106c73:	09 d7                	or     %edx,%edi
f0106c75:	89 f8                	mov    %edi,%eax
f0106c77:	89 ea                	mov    %ebp,%edx
f0106c79:	f7 74 24 08          	divl   0x8(%esp)
f0106c7d:	89 d1                	mov    %edx,%ecx
f0106c7f:	89 c7                	mov    %eax,%edi
f0106c81:	f7 64 24 0c          	mull   0xc(%esp)
f0106c85:	39 d1                	cmp    %edx,%ecx
f0106c87:	72 17                	jb     f0106ca0 <__udivdi3+0x10c>
f0106c89:	74 09                	je     f0106c94 <__udivdi3+0x100>
f0106c8b:	89 fe                	mov    %edi,%esi
f0106c8d:	31 ff                	xor    %edi,%edi
f0106c8f:	e9 41 ff ff ff       	jmp    f0106bd5 <__udivdi3+0x41>
f0106c94:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106c98:	89 f1                	mov    %esi,%ecx
f0106c9a:	d3 e2                	shl    %cl,%edx
f0106c9c:	39 c2                	cmp    %eax,%edx
f0106c9e:	73 eb                	jae    f0106c8b <__udivdi3+0xf7>
f0106ca0:	8d 77 ff             	lea    -0x1(%edi),%esi
f0106ca3:	31 ff                	xor    %edi,%edi
f0106ca5:	e9 2b ff ff ff       	jmp    f0106bd5 <__udivdi3+0x41>
f0106caa:	66 90                	xchg   %ax,%ax
f0106cac:	31 f6                	xor    %esi,%esi
f0106cae:	e9 22 ff ff ff       	jmp    f0106bd5 <__udivdi3+0x41>
	...

f0106cb4 <__umoddi3>:
f0106cb4:	55                   	push   %ebp
f0106cb5:	57                   	push   %edi
f0106cb6:	56                   	push   %esi
f0106cb7:	83 ec 20             	sub    $0x20,%esp
f0106cba:	8b 44 24 30          	mov    0x30(%esp),%eax
f0106cbe:	8b 4c 24 38          	mov    0x38(%esp),%ecx
f0106cc2:	89 44 24 14          	mov    %eax,0x14(%esp)
f0106cc6:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106cca:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0106cce:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0106cd2:	89 c7                	mov    %eax,%edi
f0106cd4:	89 f2                	mov    %esi,%edx
f0106cd6:	85 ed                	test   %ebp,%ebp
f0106cd8:	75 16                	jne    f0106cf0 <__umoddi3+0x3c>
f0106cda:	39 f1                	cmp    %esi,%ecx
f0106cdc:	0f 86 a6 00 00 00    	jbe    f0106d88 <__umoddi3+0xd4>
f0106ce2:	f7 f1                	div    %ecx
f0106ce4:	89 d0                	mov    %edx,%eax
f0106ce6:	31 d2                	xor    %edx,%edx
f0106ce8:	83 c4 20             	add    $0x20,%esp
f0106ceb:	5e                   	pop    %esi
f0106cec:	5f                   	pop    %edi
f0106ced:	5d                   	pop    %ebp
f0106cee:	c3                   	ret    
f0106cef:	90                   	nop
f0106cf0:	39 f5                	cmp    %esi,%ebp
f0106cf2:	0f 87 ac 00 00 00    	ja     f0106da4 <__umoddi3+0xf0>
f0106cf8:	0f bd c5             	bsr    %ebp,%eax
f0106cfb:	83 f0 1f             	xor    $0x1f,%eax
f0106cfe:	89 44 24 10          	mov    %eax,0x10(%esp)
f0106d02:	0f 84 a8 00 00 00    	je     f0106db0 <__umoddi3+0xfc>
f0106d08:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106d0c:	d3 e5                	shl    %cl,%ebp
f0106d0e:	bf 20 00 00 00       	mov    $0x20,%edi
f0106d13:	2b 7c 24 10          	sub    0x10(%esp),%edi
f0106d17:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106d1b:	89 f9                	mov    %edi,%ecx
f0106d1d:	d3 e8                	shr    %cl,%eax
f0106d1f:	09 e8                	or     %ebp,%eax
f0106d21:	89 44 24 18          	mov    %eax,0x18(%esp)
f0106d25:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106d29:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106d2d:	d3 e0                	shl    %cl,%eax
f0106d2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106d33:	89 f2                	mov    %esi,%edx
f0106d35:	d3 e2                	shl    %cl,%edx
f0106d37:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106d3b:	d3 e0                	shl    %cl,%eax
f0106d3d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0106d41:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106d45:	89 f9                	mov    %edi,%ecx
f0106d47:	d3 e8                	shr    %cl,%eax
f0106d49:	09 d0                	or     %edx,%eax
f0106d4b:	d3 ee                	shr    %cl,%esi
f0106d4d:	89 f2                	mov    %esi,%edx
f0106d4f:	f7 74 24 18          	divl   0x18(%esp)
f0106d53:	89 d6                	mov    %edx,%esi
f0106d55:	f7 64 24 0c          	mull   0xc(%esp)
f0106d59:	89 c5                	mov    %eax,%ebp
f0106d5b:	89 d1                	mov    %edx,%ecx
f0106d5d:	39 d6                	cmp    %edx,%esi
f0106d5f:	72 67                	jb     f0106dc8 <__umoddi3+0x114>
f0106d61:	74 75                	je     f0106dd8 <__umoddi3+0x124>
f0106d63:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0106d67:	29 e8                	sub    %ebp,%eax
f0106d69:	19 ce                	sbb    %ecx,%esi
f0106d6b:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106d6f:	d3 e8                	shr    %cl,%eax
f0106d71:	89 f2                	mov    %esi,%edx
f0106d73:	89 f9                	mov    %edi,%ecx
f0106d75:	d3 e2                	shl    %cl,%edx
f0106d77:	09 d0                	or     %edx,%eax
f0106d79:	89 f2                	mov    %esi,%edx
f0106d7b:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106d7f:	d3 ea                	shr    %cl,%edx
f0106d81:	83 c4 20             	add    $0x20,%esp
f0106d84:	5e                   	pop    %esi
f0106d85:	5f                   	pop    %edi
f0106d86:	5d                   	pop    %ebp
f0106d87:	c3                   	ret    
f0106d88:	85 c9                	test   %ecx,%ecx
f0106d8a:	75 0b                	jne    f0106d97 <__umoddi3+0xe3>
f0106d8c:	b8 01 00 00 00       	mov    $0x1,%eax
f0106d91:	31 d2                	xor    %edx,%edx
f0106d93:	f7 f1                	div    %ecx
f0106d95:	89 c1                	mov    %eax,%ecx
f0106d97:	89 f0                	mov    %esi,%eax
f0106d99:	31 d2                	xor    %edx,%edx
f0106d9b:	f7 f1                	div    %ecx
f0106d9d:	89 f8                	mov    %edi,%eax
f0106d9f:	e9 3e ff ff ff       	jmp    f0106ce2 <__umoddi3+0x2e>
f0106da4:	89 f2                	mov    %esi,%edx
f0106da6:	83 c4 20             	add    $0x20,%esp
f0106da9:	5e                   	pop    %esi
f0106daa:	5f                   	pop    %edi
f0106dab:	5d                   	pop    %ebp
f0106dac:	c3                   	ret    
f0106dad:	8d 76 00             	lea    0x0(%esi),%esi
f0106db0:	39 f5                	cmp    %esi,%ebp
f0106db2:	72 04                	jb     f0106db8 <__umoddi3+0x104>
f0106db4:	39 f9                	cmp    %edi,%ecx
f0106db6:	77 06                	ja     f0106dbe <__umoddi3+0x10a>
f0106db8:	89 f2                	mov    %esi,%edx
f0106dba:	29 cf                	sub    %ecx,%edi
f0106dbc:	19 ea                	sbb    %ebp,%edx
f0106dbe:	89 f8                	mov    %edi,%eax
f0106dc0:	83 c4 20             	add    $0x20,%esp
f0106dc3:	5e                   	pop    %esi
f0106dc4:	5f                   	pop    %edi
f0106dc5:	5d                   	pop    %ebp
f0106dc6:	c3                   	ret    
f0106dc7:	90                   	nop
f0106dc8:	89 d1                	mov    %edx,%ecx
f0106dca:	89 c5                	mov    %eax,%ebp
f0106dcc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0106dd0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0106dd4:	eb 8d                	jmp    f0106d63 <__umoddi3+0xaf>
f0106dd6:	66 90                	xchg   %ax,%ax
f0106dd8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0106ddc:	72 ea                	jb     f0106dc8 <__umoddi3+0x114>
f0106dde:	89 f1                	mov    %esi,%ecx
f0106de0:	eb 81                	jmp    f0106d63 <__umoddi3+0xaf>
